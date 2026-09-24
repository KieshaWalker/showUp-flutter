// pantry_notifier.dart — Food library: global presets + user's personal foods.
//
// The pantry is a searchable list of foods with macro info. There are two kinds:
//   Global presets — userId IS NULL in the DB; shared across all users;
//                    seeded by admins in Supabase SQL editor; read-only for users.
//   Personal foods — userId = logged-in user's UUID; created/edited by the user.
//
// pantryNotifierProvider (StreamNotifierProvider<List<PantryFood>>):
//   build()          — streams all pantry foods visible to the current user
//                      (their personal foods + global presets) from local SQLite
//   addFood()        — creates a personal food locally, then syncs to Supabase
//   updateFood()     — updates a personal food locally, then syncs to Supabase
//   deleteFood()     — deletes a personal food locally, then from Supabase
//   syncFromRemote() — pulls global presets + user's personal foods from Supabase
//                      and upserts into local SQLite (called on login in main.dart)
//
// otherUserPantryProvider (FutureProvider.family<List<PantryFood>, userId>):
//   Reads another user's personal foods straight from Supabase (no local
//   cache) for the community "view their pantry" screen. See
//   public_profile_screen.dart.
//
// Why local cache for global presets?
//   Caching presets locally means the pantry works offline and search is instant
//   without a network round-trip on every keystroke.
//
// Write strategy (local-first):
//   Personal food writes hit SQLite first, then Supabase fire-and-forget.
//   Global presets are never written from the app — admin-only via Supabase.
//
// Connections:
//   database_provider.dart  — ref.watch(databaseProvider) for SQLite access
//   auth_provider.dart      — currentUserIdProvider to scope personal foods
//   pantry_screen.dart      — search/browse UI, calls addFood/updateFood/deleteFood
//   nutrition_screen.dart   — "add from pantry" flow calls pantryNotifierProvider

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../database/database_provider.dart';
import '../../database/db.dart';
import '../nutrition/nutrition_notifier.dart';
import '../nutrition/nutrition_screen.dart' show resolveMealNameForTime;

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final pantryNotifierProvider =
    StreamNotifierProvider<PantryNotifier, List<PantryFood>>(
      PantryNotifier.new,
    );

/// Another user's personal pantry foods, fetched directly from Supabase
/// (not cached locally — local Drift only ever holds the current user's
/// own rows + presets). Used by the community "view their pantry" screen.
/// Relies on the `pantry_foods` SELECT RLS policy being open to any
/// authenticated user (widened 2026-09-18 alongside `habits`/
/// `habit_completions`/`habit_skips` for this feature).
final otherUserPantryProvider = FutureProvider.family<List<PantryFood>, String>(
  (ref, userId) async {
    final rows = await Supabase.instance.client
        .from('pantry_foods')
        .select()
        .eq('user_id', userId)
        .order('name');

    return (rows as List)
        .map((row) => _pantryFoodFromRow(row as Map<String, dynamic>, userId))
        .toList();
  },
);

/// Per-food usage counts for the current time-of-day meal window (Breakfast/
/// Lunch/Dinner/Snack, same buckets as [resolveMealNameForTime]) vs. all
/// time. Powers Quick Add's chip ordering on the Overview tab.
final quickAddRankingProvider = FutureProvider.autoDispose<
  Map<String, (int window, int total)>
>((ref) async {
  // Re-rank whenever the pantry list changes or any food entry is
  // logged/deleted. NutritionNotifier's build() stream is an unfiltered,
  // all-dates COUNT on food_entries (nutrition_notifier.dart), so it fires
  // correctly here even though ranking looks across all history, not just today.
  ref.watch(pantryNotifierProvider);
  ref.watch(nutritionNotifierProvider);

  final db = ref.read(databaseProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return {};

  final resolvedMealName = resolveMealNameForTime(DateTime.now());

  // The CASE expression below mirrors resolveMealNameForTime's boundaries in
  // SQL so "Snack" (which spans two disjoint hour ranges) buckets correctly —
  // a plain BETWEEN on hour-of-day can't express that split.
  final rows =
      await db
          .customSelect(
            '''
        SELECT fe.pantry_food_id AS food_id,
               SUM(CASE WHEN (
                 CASE
                   WHEN CAST(strftime('%H', m.logged_at, 'unixepoch', 'localtime') AS INTEGER) BETWEEN 5 AND 10 THEN 'Breakfast'
                   WHEN CAST(strftime('%H', m.logged_at, 'unixepoch', 'localtime') AS INTEGER) BETWEEN 11 AND 14 THEN 'Lunch'
                   WHEN CAST(strftime('%H', m.logged_at, 'unixepoch', 'localtime') AS INTEGER) BETWEEN 17 AND 21 THEN 'Dinner'
                   ELSE 'Snack'
                 END
               ) = ?1 THEN 1 ELSE 0 END) AS window_count,
               COUNT(*) AS total_count
        FROM food_entries fe
        JOIN meals m ON m.id = fe.meal_id
        WHERE fe.user_id = ?2 AND fe.pantry_food_id IS NOT NULL
        GROUP BY fe.pantry_food_id
        ''',
            variables: [
              Variable.withString(resolvedMealName),
              Variable.withString(userId),
            ],
            readsFrom: {db.foodEntries, db.meals},
          )
          .get();

  return {
    for (final row in rows)
      row.read<String>('food_id'): (
        row.read<int>('window_count'),
        row.read<int>('total_count'),
      ),
  };
});

/// Reorders [foods] so ones logged more often during the current time-of-day
/// window rise to the front, falling back to all-time frequency, then the
/// original order (a cold-start user/window with zero counts everywhere is
/// left untouched — [mergeSort] is stable, unlike [List.sort]).
List<PantryFood> rankPantryFoodsForQuickAdd(
  List<PantryFood> foods,
  Map<String, (int window, int total)> counts,
) {
  final ranked = [...foods];
  mergeSort(
    ranked,
    compare: (a, b) {
      final ca = counts[a.id] ?? (0, 0);
      final cb = counts[b.id] ?? (0, 0);
      if (ca.$1 != cb.$1) return cb.$1.compareTo(ca.$1);
      if (ca.$2 != cb.$2) return cb.$2.compareTo(ca.$2);
      return 0;
    },
  );
  return ranked;
}

PantryFood _pantryFoodFromRow(Map<String, dynamic> row, String userId) {
  return PantryFood(
    id: row['id'] as String,
    userId: userId,
    name: row['name'] as String,
    calories: (row['calories'] as num).toDouble(),
    protein: (row['protein'] as num).toDouble(),
    carbs: (row['carbs'] as num).toDouble(),
    fat: (row['fat'] as num).toDouble(),
    sugar: ((row['sugar'] as num?) ?? 0).toDouble(),
    fiber: ((row['fiber'] as num?) ?? 0).toDouble(),
    sodium: ((row['sodium'] as num?) ?? 0).toDouble(),
    cholesterol: ((row['cholesterol'] as num?) ?? 0).toDouble(),
    potassium: ((row['potassium'] as num?) ?? 0).toDouble(),
    calcium: ((row['calcium'] as num?) ?? 0).toDouble(),
    iron: ((row['iron'] as num?) ?? 0).toDouble(),
    vitaminA: ((row['vitamin_a'] as num?) ?? 0).toDouble(),
    vitaminC: ((row['vitamin_c'] as num?) ?? 0).toDouble(),
    servingLabel: row['serving_label'] as String,
    isPreset: row['is_preset'] as bool? ?? false,
    createdAt:
        row['created_at'] != null
            ? DateTime.parse(row['created_at'] as String)
            : DateTime.now(),
    synced: true,
    category: row['category'] as String?,
  );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Manages the pantry food library — a reusable catalog of foods that can be
/// added to any meal via [createMealFromPantry].
///
/// ## Two kinds of pantry rows
///
/// | Kind            | user_id in Supabase | is_preset | Who can edit?  |
/// |-----------------|---------------------|-----------|----------------|
/// | Global preset   | NULL                | true      | Admin SQL only |
/// | Personal food   | user UUID           | false     | Owner only     |
///
/// ## Sync strategy (local-first)
/// 1. On login — [syncFromRemote] pulls both global rows and the user's own
///    rows from Supabase and upserts them into the local Drift DB.
/// 2. On write  — local Drift is updated first; Supabase is updated
///    fire-and-forget inside a try/catch so the UI never blocks.
class PantryNotifier extends StreamNotifier<List<PantryFood>> {
  @override
  Stream<List<PantryFood>> build() {
    final db = ref.watch(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    // Show global presets (userId IS NULL) + the current user's personal foods,
    // sorted: presets first, then alphabetically by name.
    return (db.select(db.pantryFoods)
          ..where((t) => t.userId.isNull() | t.userId.equals(userId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.isPreset, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  // ── Write operations ───────────────────────────────────────────────────────

  /// Add a personal food to the current user's pantry.
  Future<void> addFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String servingLabel,
    double sugar = 0,
    double fiber = 0,
    double sodium = 0,
    double cholesterol = 0,
    double potassium = 0,
    double calcium = 0,
    double iron = 0,
    double vitaminA = 0,
    double vitaminC = 0,
    String? category,
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final id = _uuid.v4();

    // 1. Write locally first so the UI updates instantly.
    await db
        .into(db.pantryFoods)
        .insert(
          PantryFoodsCompanion.insert(
            id: id,
            userId: Value(userId),
            name: name,
            calories: Value(calories),
            protein: Value(protein),
            carbs: Value(carbs),
            fat: Value(fat),
            sugar: Value(sugar),
            fiber: Value(fiber),
            sodium: Value(sodium),
            cholesterol: Value(cholesterol),
            potassium: Value(potassium),
            calcium: Value(calcium),
            iron: Value(iron),
            vitaminA: Value(vitaminA),
            vitaminC: Value(vitaminC),
            servingLabel: Value(servingLabel),
            isPreset: const Value(false),
            category: Value(category),
          ),
        );

    // 2. Fire-and-forget Supabase sync.
    try {
      await Supabase.instance.client.from('pantry_foods').insert({
        'id': id,
        'user_id': userId,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'sugar': sugar,
        'fiber': fiber,
        'sodium': sodium,
        'cholesterol': cholesterol,
        'potassium': potassium,
        'calcium': calcium,
        'iron': iron,
        'vitamin_a': vitaminA,
        'vitamin_c': vitaminC,
        'serving_label': servingLabel,
        'is_preset': false,
        'category': category,
      });
      await (db.update(db.pantryFoods)..where(
        (t) => t.id.equals(id),
      )).write(const PantryFoodsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Update an existing personal food. Global presets cannot be edited from
  /// the app — use the Supabase SQL editor for those. The `userId.equals`
  /// clause enforces this: a preset's userId is NULL so it never matches.
  Future<void> updateFood({
    required String id,
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String servingLabel,
    double sugar = 0,
    double fiber = 0,
    double sodium = 0,
    double cholesterol = 0,
    double potassium = 0,
    double calcium = 0,
    double iron = 0,
    double vitaminA = 0,
    double vitaminC = 0,
    String? category,
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final updated = await (db.update(db.pantryFoods)
      ..where((t) => t.id.equals(id) & t.userId.equals(userId))).write(
      PantryFoodsCompanion(
        name: Value(name),
        calories: Value(calories),
        protein: Value(protein),
        carbs: Value(carbs),
        fat: Value(fat),
        sugar: Value(sugar),
        fiber: Value(fiber),
        sodium: Value(sodium),
        cholesterol: Value(cholesterol),
        potassium: Value(potassium),
        calcium: Value(calcium),
        iron: Value(iron),
        vitaminA: Value(vitaminA),
        vitaminC: Value(vitaminC),
        servingLabel: Value(servingLabel),
        category: Value(category),
        synced: const Value(false),
      ),
    );
    if (updated == 0) return; // not owned by this user (e.g. a global preset)

    try {
      await Supabase.instance.client
          .from('pantry_foods')
          .update({
            'name': name,
            'calories': calories,
            'protein': protein,
            'carbs': carbs,
            'fat': fat,
            'sugar': sugar,
            'fiber': fiber,
            'sodium': sodium,
            'cholesterol': cholesterol,
            'potassium': potassium,
            'calcium': calcium,
            'iron': iron,
            'vitamin_a': vitaminA,
            'vitamin_c': vitaminC,
            'serving_label': servingLabel,
            'category': category,
          })
          .eq('id', id)
          .eq('user_id', userId);
      await (db.update(db.pantryFoods)..where(
        (t) => t.id.equals(id),
      )).write(const PantryFoodsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Delete a personal food. Global presets are protected here the same way
  /// as [updateFood] — the `userId.equals` clause excludes rows with a NULL
  /// userId (presets) and rows owned by a different user.
  Future<void> deleteFood(String id) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final deleted =
        await (db.delete(db.pantryFoods)
          ..where((t) => t.id.equals(id) & t.userId.equals(userId))).go();
    if (deleted == 0) return; // not owned by this user (e.g. a global preset)

    try {
      await Supabase.instance.client
          .from('pantry_foods')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (_) {}
  }

  // ── Meal creation ──────────────────────────────────────────────────────────

  /// Creates a named meal in today's nutrition log from a list of pantry foods
  /// with their serving counts. Returns the new meal's id.
  Future<String> createMealFromPantry({
    required String mealName,
    required List<({PantryFood food, double servings})> selections,
    DateTime? loggedAt,
  }) async {
    final notifier = ref.read(nutritionNotifierProvider.notifier);
    final mealId = await notifier.addMeal(mealName, loggedAt: loggedAt);

    for (final s in selections) {
      await notifier.addFoodEntry(
        mealId: mealId,
        name: s.food.name,
        calories: s.food.calories * s.servings,
        protein: s.food.protein * s.servings,
        carbs: s.food.carbs * s.servings,
        fat: s.food.fat * s.servings,
        sugar: s.food.sugar * s.servings,
        fiber: s.food.fiber * s.servings,
        sodium: s.food.sodium * s.servings,
        cholesterol: s.food.cholesterol * s.servings,
        potassium: s.food.potassium * s.servings,
        calcium: s.food.calcium * s.servings,
        iron: s.food.iron * s.servings,
        vitaminA: s.food.vitaminA * s.servings,
        vitaminC: s.food.vitaminC * s.servings,
        pantryFoodId: s.food.id,
        servings: s.servings,
      );
    }

    return mealId;
  }

  // ── Remote sync ────────────────────────────────────────────────────────────

  /// Retry personal-food writes whose Supabase sync previously failed (e.g.
  /// made while offline). Presets are never written from the app, so only
  /// personal foods (userId == current user) are ever unsynced here. Uses
  /// upsert since a prior attempt may have partially succeeded remotely.
  /// Call this before syncFromRemote() on app launch.
  Future<void> pushUnsyncedChanges() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final unsynced =
        await (db.select(db.pantryFoods)..where(
          (t) => t.userId.equals(userId) & t.synced.equals(false),
        )).get();
    for (final f in unsynced) {
      try {
        await Supabase.instance.client.from('pantry_foods').upsert({
          'id': f.id,
          'user_id': f.userId,
          'name': f.name,
          'calories': f.calories,
          'protein': f.protein,
          'carbs': f.carbs,
          'fat': f.fat,
          'sugar': f.sugar,
          'fiber': f.fiber,
          'sodium': f.sodium,
          'cholesterol': f.cholesterol,
          'potassium': f.potassium,
          'calcium': f.calcium,
          'iron': f.iron,
          'vitamin_a': f.vitaminA,
          'vitamin_c': f.vitaminC,
          'serving_label': f.servingLabel,
          'is_preset': false,
          'category': f.category,
        });
        await (db.update(db.pantryFoods)..where(
          (t) => t.id.equals(f.id),
        )).write(const PantryFoodsCompanion(synced: Value(true)));
      } catch (_) {}
    }
  }

  /// Pull global presets and the current user's personal foods from Supabase
  /// into the local Drift DB. Called once on login.
  ///
  /// Uses upsert (insertOnConflictUpdate) so existing rows are overwritten with
  /// the latest Supabase values, and new rows are inserted.
  Future<void> syncFromRemote() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // ── 1. Global presets (user_id IS NULL in Supabase) ──────────────────
      final globals = await Supabase.instance.client
          .from('pantry_foods')
          .select()
          .filter('user_id', 'is', null);

      for (final row in globals as List) {
        await db
            .into(db.pantryFoods)
            .insertOnConflictUpdate(
              PantryFoodsCompanion.insert(
                id: row['id'] as String,
                // userId left absent (null) — marks this as a global preset locally
                name: row['name'] as String,
                calories: Value((row['calories'] as num).toDouble()),
                protein: Value((row['protein'] as num).toDouble()),
                carbs: Value((row['carbs'] as num).toDouble()),
                fat: Value((row['fat'] as num).toDouble()),
                sugar: Value(((row['sugar'] as num?) ?? 0).toDouble()),
                fiber: Value(((row['fiber'] as num?) ?? 0).toDouble()),
                sodium: Value(((row['sodium'] as num?) ?? 0).toDouble()),
                cholesterol: Value(
                  ((row['cholesterol'] as num?) ?? 0).toDouble(),
                ),
                potassium: Value(((row['potassium'] as num?) ?? 0).toDouble()),
                calcium: Value(((row['calcium'] as num?) ?? 0).toDouble()),
                iron: Value(((row['iron'] as num?) ?? 0).toDouble()),
                vitaminA: Value(((row['vitamin_a'] as num?) ?? 0).toDouble()),
                vitaminC: Value(((row['vitamin_c'] as num?) ?? 0).toDouble()),
                servingLabel: Value(row['serving_label'] as String),
                isPreset: const Value(true),
                synced: const Value(true),
                category: Value(row['category'] as String?),
              ),
            );
      }

      // ── 2. User's personal pantry foods ───────────────────────────────────
      final personal = await Supabase.instance.client
          .from('pantry_foods')
          .select()
          .eq('user_id', userId);

      for (final row in personal as List) {
        await db
            .into(db.pantryFoods)
            .insertOnConflictUpdate(
              PantryFoodsCompanion.insert(
                id: row['id'] as String,
                userId: Value(userId),
                name: row['name'] as String,
                calories: Value((row['calories'] as num).toDouble()),
                protein: Value((row['protein'] as num).toDouble()),
                carbs: Value((row['carbs'] as num).toDouble()),
                fat: Value((row['fat'] as num).toDouble()),
                sugar: Value(((row['sugar'] as num?) ?? 0).toDouble()),
                fiber: Value(((row['fiber'] as num?) ?? 0).toDouble()),
                sodium: Value(((row['sodium'] as num?) ?? 0).toDouble()),
                cholesterol: Value(
                  ((row['cholesterol'] as num?) ?? 0).toDouble(),
                ),
                potassium: Value(((row['potassium'] as num?) ?? 0).toDouble()),
                calcium: Value(((row['calcium'] as num?) ?? 0).toDouble()),
                iron: Value(((row['iron'] as num?) ?? 0).toDouble()),
                vitaminA: Value(((row['vitamin_a'] as num?) ?? 0).toDouble()),
                vitaminC: Value(((row['vitamin_c'] as num?) ?? 0).toDouble()),
                servingLabel: Value(row['serving_label'] as String),
                isPreset: Value(row['is_preset'] as bool? ?? false),
                synced: const Value(true),
                category: Value(row['category'] as String?),
              ),
            );
      }
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Meal templates — saved, reusable pantry-food bundles
// ---------------------------------------------------------------------------

/// A saved meal template with its food items.
class MealTemplateWithItems {
  final MealTemplate template;
  final List<MealTemplateItem> items;

  const MealTemplateWithItems({required this.template, required this.items});
}

/// One item to save into a template — either a pantry-linked food (looked
/// up live from the current [PantryFood] row at apply time) or a manually
/// entered snapshot (replayed as-is, since there's no pantry row to re-read
/// macros from). Build these from logged [FoodEntry] rows via
/// [MealTemplateItemInput.fromFoodEntry].
class MealTemplateItemInput {
  final String? pantryFoodId;
  final double servings;
  final String? name;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? sugar;
  final double? fiber;
  final double? sodium;
  final double? cholesterol;
  final double? potassium;
  final double? calcium;
  final double? iron;
  final double? vitaminA;
  final double? vitaminC;

  const MealTemplateItemInput.pantry({
    required this.pantryFoodId,
    required this.servings,
  }) : name = null,
       calories = null,
       protein = null,
       carbs = null,
       fat = null,
       sugar = null,
       fiber = null,
       sodium = null,
       cholesterol = null,
       potassium = null,
       calcium = null,
       iron = null,
       vitaminA = null,
       vitaminC = null;

  const MealTemplateItemInput.manual({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.sugar = 0,
    this.fiber = 0,
    this.sodium = 0,
    this.cholesterol = 0,
    this.potassium = 0,
    this.calcium = 0,
    this.iron = 0,
    this.vitaminA = 0,
    this.vitaminC = 0,
  }) : pantryFoodId = null,
       servings = 1.0;

  factory MealTemplateItemInput.fromFoodEntry(FoodEntry e) {
    if (e.pantryFoodId != null) {
      return MealTemplateItemInput.pantry(
        pantryFoodId: e.pantryFoodId!,
        servings: e.servings,
      );
    }
    return MealTemplateItemInput.manual(
      name: e.name,
      calories: e.calories,
      protein: e.protein,
      carbs: e.carbs,
      fat: e.fat,
      sugar: e.sugar,
      fiber: e.fiber,
      sodium: e.sodium,
      cholesterol: e.cholesterol,
      potassium: e.potassium,
      calcium: e.calcium,
      iron: e.iron,
      vitaminA: e.vitaminA,
      vitaminC: e.vitaminC,
    );
  }

  /// Builds this item straight from an existing [MealTemplateItem] row, so
  /// an edit that keeps an item unchanged can round-trip it without the
  /// caller re-deriving every field.
  factory MealTemplateItemInput.fromRow(MealTemplateItem i) {
    if (i.pantryFoodId != null) {
      return MealTemplateItemInput.pantry(
        pantryFoodId: i.pantryFoodId!,
        servings: i.servings,
      );
    }
    return MealTemplateItemInput.manual(
      name: i.name ?? '',
      calories: i.calories ?? 0,
      protein: i.protein ?? 0,
      carbs: i.carbs ?? 0,
      fat: i.fat ?? 0,
      sugar: i.sugar ?? 0,
      fiber: i.fiber ?? 0,
      sodium: i.sodium ?? 0,
      cholesterol: i.cholesterol ?? 0,
      potassium: i.potassium ?? 0,
      calcium: i.calcium ?? 0,
      iron: i.iron ?? 0,
      vitaminA: i.vitaminA ?? 0,
      vitaminC: i.vitaminC ?? 0,
    );
  }

  MealTemplateItemsCompanion _toCompanion({
    required String id,
    required String templateId,
    required String userId,
  }) {
    return MealTemplateItemsCompanion.insert(
      id: id,
      templateId: templateId,
      userId: userId,
      pantryFoodId: Value(pantryFoodId),
      servings: Value(servings),
      name: Value(name),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      sugar: Value(sugar),
      fiber: Value(fiber),
      sodium: Value(sodium),
      cholesterol: Value(cholesterol),
      potassium: Value(potassium),
      calcium: Value(calcium),
      iron: Value(iron),
      vitaminA: Value(vitaminA),
      vitaminC: Value(vitaminC),
    );
  }

  Map<String, dynamic> _toRemoteJson({
    required String id,
    required String templateId,
    required String userId,
  }) {
    return {
      'id': id,
      'template_id': templateId,
      'user_id': userId,
      'pantry_food_id': pantryFoodId,
      'servings': servings,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'sugar': sugar,
      'fiber': fiber,
      'sodium': sodium,
      'cholesterol': cholesterol,
      'potassium': potassium,
      'calcium': calcium,
      'iron': iron,
      'vitamin_a': vitaminA,
      'vitamin_c': vitaminC,
    };
  }
}

final mealTemplatesNotifierProvider =
    StreamNotifierProvider<MealTemplatesNotifier, List<MealTemplateWithItems>>(
      MealTemplatesNotifier.new,
    );

/// Manages user-saved "meal templates" — a named bundle of pantry foods +
/// servings the user can re-log in one tap from Quick Add, instead of
/// rebuilding the same meal from scratch every time. See [createMealFromPantry]
/// for the underlying meal+entry creation this reuses.
class MealTemplatesNotifier
    extends StreamNotifier<List<MealTemplateWithItems>> {
  @override
  Stream<List<MealTemplateWithItems>> build() {
    final db = ref.watch(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    // Same count-only-watch-as-trigger pattern as NutritionNotifier.build():
    // cheap COUNT streams fire the rebuild, then a fresh full query assembles
    // the result.
    final templatesStream =
        (db.selectOnly(db.mealTemplates)
              ..addColumns([db.mealTemplates.id.count()])
              ..where(db.mealTemplates.userId.equals(userId)))
            .watchSingle();
    final itemsStream =
        (db.selectOnly(db.mealTemplateItems)
              ..addColumns([db.mealTemplateItems.id.count()])
              ..where(db.mealTemplateItems.userId.equals(userId)))
            .watchSingle();

    final trigger = StreamGroup.merge<List<dynamic>>([
      templatesStream.map((_) => []),
      itemsStream.map((_) => []),
    ]).map((_) => null);

    return trigger.asyncMap((_) => _loadAll(db, userId));
  }

  Future<List<MealTemplateWithItems>> _loadAll(
    AppDatabase db,
    String userId,
  ) async {
    final templates =
        await (db.select(db.mealTemplates)
              ..where((t) => t.userId.equals(userId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    final items =
        await (db.select(db.mealTemplateItems)
          ..where((i) => i.userId.equals(userId))).get();

    return [
      for (final t in templates)
        MealTemplateWithItems(
          template: t,
          items: items.where((i) => i.templateId == t.id).toList(),
        ),
    ];
  }

  /// Saves [items] as a new named template.
  Future<void> saveTemplate({
    required String name,
    required List<MealTemplateItemInput> items,
  }) async {
    if (items.isEmpty) return;
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final templateId = _uuid.v4();
    await db
        .into(db.mealTemplates)
        .insert(
          MealTemplatesCompanion.insert(
            id: templateId,
            userId: userId,
            name: name,
          ),
        );

    final itemIds = [for (final _ in items) _uuid.v4()];
    final itemRows = [
      for (var idx = 0; idx < items.length; idx++)
        items[idx]._toCompanion(
          id: itemIds[idx],
          templateId: templateId,
          userId: userId,
        ),
    ];
    await db.batch((b) => b.insertAll(db.mealTemplateItems, itemRows));

    try {
      await Supabase.instance.client.from('meal_templates').insert({
        'id': templateId,
        'user_id': userId,
        'name': name,
      });
      await Supabase.instance.client.from('meal_template_items').insert([
        for (var idx = 0; idx < items.length; idx++)
          items[idx]._toRemoteJson(
            id: itemIds[idx],
            templateId: templateId,
            userId: userId,
          ),
      ]);
      await (db.update(db.mealTemplates)..where(
        (t) => t.id.equals(templateId),
      )).write(const MealTemplatesCompanion(synced: Value(true)));
      await (db.update(db.mealTemplateItems)..where(
        (i) => i.templateId.equals(templateId),
      )).write(const MealTemplateItemsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Renames a template and replaces its items wholesale — used for editing
  /// (renaming, removing items, or changing servings all flow through this;
  /// there's no per-item update).
  Future<void> updateTemplate({
    required String templateId,
    required String name,
    required List<MealTemplateItemInput> items,
  }) async {
    if (items.isEmpty) return;
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await (db.update(db.mealTemplates)
      ..where((t) => t.id.equals(templateId))).write(
      MealTemplatesCompanion(name: Value(name), synced: const Value(false)),
    );
    await (db.delete(db.mealTemplateItems)
      ..where((i) => i.templateId.equals(templateId))).go();

    final itemIds = [for (final _ in items) _uuid.v4()];
    final itemRows = [
      for (var idx = 0; idx < items.length; idx++)
        items[idx]._toCompanion(
          id: itemIds[idx],
          templateId: templateId,
          userId: userId,
        ),
    ];
    await db.batch((b) => b.insertAll(db.mealTemplateItems, itemRows));

    try {
      await Supabase.instance.client
          .from('meal_templates')
          .update({'name': name})
          .eq('id', templateId);
      await Supabase.instance.client
          .from('meal_template_items')
          .delete()
          .eq('template_id', templateId);
      await Supabase.instance.client.from('meal_template_items').insert([
        for (var idx = 0; idx < items.length; idx++)
          items[idx]._toRemoteJson(
            id: itemIds[idx],
            templateId: templateId,
            userId: userId,
          ),
      ]);
      await (db.update(db.mealTemplates)..where(
        (t) => t.id.equals(templateId),
      )).write(const MealTemplatesCompanion(synced: Value(true)));
      await (db.update(db.mealTemplateItems)..where(
        (i) => i.templateId.equals(templateId),
      )).write(const MealTemplateItemsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Re-logs a saved template as a brand-new meal. Pantry-linked items whose
  /// pantry food was deleted since the template was saved are skipped (their
  /// pantry food ids are returned, since a name can't be looked up once
  /// deleted) rather than failing the whole apply. Manually-entered items
  /// are always replayed since their name/macros are stored on the item.
  Future<({String mealId, List<String> skippedPantryFoodIds})> applyTemplate(
    String templateId, {
    DateTime? loggedAt,
  }) async {
    final db = ref.read(databaseProvider);
    final template =
        await (db.select(db.mealTemplates)
          ..where((t) => t.id.equals(templateId))).getSingle();
    final items =
        await (db.select(db.mealTemplateItems)
          ..where((i) => i.templateId.equals(templateId))).get();

    final selections = <({PantryFood food, double servings})>[];
    final manualItems = <MealTemplateItem>[];
    final skipped = <String>[];
    for (final item in items) {
      final pantryFoodId = item.pantryFoodId;
      if (pantryFoodId == null) {
        manualItems.add(item);
        continue;
      }
      final food =
          await (db.select(db.pantryFoods)
            ..where((f) => f.id.equals(pantryFoodId))).getSingleOrNull();
      if (food == null) {
        skipped.add(pantryFoodId);
        continue;
      }
      selections.add((food: food, servings: item.servings));
    }

    final mealId = await ref
        .read(pantryNotifierProvider.notifier)
        .createMealFromPantry(
          mealName: template.name,
          selections: selections,
          loggedAt: loggedAt,
        );

    final nutritionNotifier = ref.read(nutritionNotifierProvider.notifier);
    for (final item in manualItems) {
      await nutritionNotifier.addFoodEntry(
        mealId: mealId,
        name: item.name ?? 'Food',
        calories: item.calories ?? 0,
        protein: item.protein ?? 0,
        carbs: item.carbs ?? 0,
        fat: item.fat ?? 0,
        sugar: item.sugar ?? 0,
        fiber: item.fiber ?? 0,
        sodium: item.sodium ?? 0,
        cholesterol: item.cholesterol ?? 0,
        potassium: item.potassium ?? 0,
        calcium: item.calcium ?? 0,
        iron: item.iron ?? 0,
        vitaminA: item.vitaminA ?? 0,
        vitaminC: item.vitaminC ?? 0,
      );
    }

    return (mealId: mealId, skippedPantryFoodIds: skipped);
  }

  Future<void> deleteTemplate(String templateId) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await (db.delete(db.mealTemplateItems)
      ..where((i) => i.templateId.equals(templateId))).go();
    final deleted =
        await (db.delete(db.mealTemplates)..where(
          (t) => t.id.equals(templateId) & t.userId.equals(userId),
        )).go();
    if (deleted == 0) return;

    try {
      await Supabase.instance.client
          .from('meal_template_items')
          .delete()
          .eq('template_id', templateId);
      await Supabase.instance.client
          .from('meal_templates')
          .delete()
          .eq('id', templateId)
          .eq('user_id', userId);
    } catch (_) {}
  }

  /// Retry template writes whose Supabase sync previously failed. Call this
  /// before [syncFromRemote] on app launch, same as the pantry/nutrition
  /// bootstrap in main.dart.
  Future<void> pushUnsyncedChanges() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final unsyncedTemplates =
        await (db.select(db.mealTemplates)..where(
          (t) => t.userId.equals(userId) & t.synced.equals(false),
        )).get();
    for (final t in unsyncedTemplates) {
      try {
        await Supabase.instance.client.from('meal_templates').upsert({
          'id': t.id,
          'user_id': t.userId,
          'name': t.name,
        });
        await (db.update(db.mealTemplates)..where(
          (row) => row.id.equals(t.id),
        )).write(const MealTemplatesCompanion(synced: Value(true)));
      } catch (_) {}
    }

    final unsyncedItems =
        await (db.select(db.mealTemplateItems)..where(
          (i) => i.userId.equals(userId) & i.synced.equals(false),
        )).get();
    for (final i in unsyncedItems) {
      try {
        await Supabase.instance.client
            .from('meal_template_items')
            .upsert(_mealTemplateItemRowToRemoteJson(i));
        await (db.update(db.mealTemplateItems)..where(
          (row) => row.id.equals(i.id),
        )).write(const MealTemplateItemsCompanion(synced: Value(true)));
      } catch (err) {
        if (err is PostgrestException && err.code == '23503') {
          // Parent template no longer exists remotely — drop the orphaned item.
          await (db.delete(db.mealTemplateItems)
            ..where((row) => row.id.equals(i.id))).go();
        }
      }
    }
  }

  /// Pulls the current user's templates from Supabase into local Drift.
  /// Called once on login, alongside habits/nutrition/pantry.
  Future<void> syncFromRemote() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final templates = await Supabase.instance.client
          .from('meal_templates')
          .select()
          .eq('user_id', userId);
      for (final row in templates as List) {
        await db
            .into(db.mealTemplates)
            .insertOnConflictUpdate(
              MealTemplatesCompanion.insert(
                id: row['id'] as String,
                userId: userId,
                name: row['name'] as String,
                createdAt: Value(DateTime.parse(row['created_at'] as String)),
                synced: const Value(true),
              ),
            );
      }

      final items = await Supabase.instance.client
          .from('meal_template_items')
          .select()
          .eq('user_id', userId);
      for (final row in items as List) {
        await db
            .into(db.mealTemplateItems)
            .insertOnConflictUpdate(
              MealTemplateItemsCompanion.insert(
                id: row['id'] as String,
                templateId: row['template_id'] as String,
                userId: userId,
                pantryFoodId: Value(row['pantry_food_id'] as String?),
                servings: Value(((row['servings'] as num?) ?? 1.0).toDouble()),
                synced: const Value(true),
                name: Value(row['name'] as String?),
                calories: Value(_asDouble(row['calories'])),
                protein: Value(_asDouble(row['protein'])),
                carbs: Value(_asDouble(row['carbs'])),
                fat: Value(_asDouble(row['fat'])),
                sugar: Value(_asDouble(row['sugar'])),
                fiber: Value(_asDouble(row['fiber'])),
                sodium: Value(_asDouble(row['sodium'])),
                cholesterol: Value(_asDouble(row['cholesterol'])),
                potassium: Value(_asDouble(row['potassium'])),
                calcium: Value(_asDouble(row['calcium'])),
                iron: Value(_asDouble(row['iron'])),
                vitaminA: Value(_asDouble(row['vitamin_a'])),
                vitaminC: Value(_asDouble(row['vitamin_c'])),
              ),
            );
      }
    } catch (_) {}
  }
}

/// Builds the Supabase row for a locally-stored [MealTemplateItem] — shared
/// by [MealTemplatesNotifier.pushUnsyncedChanges] and any other push path.
Map<String, dynamic> _mealTemplateItemRowToRemoteJson(MealTemplateItem i) {
  return {
    'id': i.id,
    'template_id': i.templateId,
    'user_id': i.userId,
    'pantry_food_id': i.pantryFoodId,
    'servings': i.servings,
    'name': i.name,
    'calories': i.calories,
    'protein': i.protein,
    'carbs': i.carbs,
    'fat': i.fat,
    'sugar': i.sugar,
    'fiber': i.fiber,
    'sodium': i.sodium,
    'cholesterol': i.cholesterol,
    'potassium': i.potassium,
    'calcium': i.calcium,
    'iron': i.iron,
    'vitamin_a': i.vitaminA,
    'vitamin_c': i.vitaminC,
  };
}

double? _asDouble(dynamic v) => (v as num?)?.toDouble();
