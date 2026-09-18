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

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../database/database_provider.dart';
import '../../database/db.dart';
import '../nutrition/nutrition_notifier.dart';

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
final otherUserPantryProvider =
    FutureProvider.family<List<PantryFood>, String>((ref, userId) async {
  final rows = await Supabase.instance.client
      .from('pantry_foods')
      .select()
      .eq('user_id', userId)
      .order('name');

  return (rows as List)
      .map((row) => _pantryFoodFromRow(row as Map<String, dynamic>, userId))
      .toList();
});

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
    createdAt: row['created_at'] != null
        ? DateTime.parse(row['created_at'] as String)
        : DateTime.now(),
    synced: true,
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
            (t) => OrderingTerm(expression: t.isPreset, mode: OrderingMode.desc),
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
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final id = _uuid.v4();

    // 1. Write locally first so the UI updates instantly.
    await db.into(db.pantryFoods).insert(
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
      });
      await (db.update(db.pantryFoods)..where((t) => t.id.equals(id)))
          .write(const PantryFoodsCompanion(synced: Value(true)));
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
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final updated = await (db.update(db.pantryFoods)
          ..where((t) => t.id.equals(id) & t.userId.equals(userId)))
        .write(
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
          })
          .eq('id', id)
          .eq('user_id', userId);
      await (db.update(db.pantryFoods)..where((t) => t.id.equals(id)))
          .write(const PantryFoodsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Delete a personal food. Global presets are protected here the same way
  /// as [updateFood] — the `userId.equals` clause excludes rows with a NULL
  /// userId (presets) and rows owned by a different user.
  Future<void> deleteFood(String id) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final deleted = await (db.delete(db.pantryFoods)
          ..where((t) => t.id.equals(id) & t.userId.equals(userId)))
        .go();
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
  /// with their serving counts.
  Future<void> createMealFromPantry({
    required String mealName,
    required List<({PantryFood food, double servings})> selections,
  }) async {
    final notifier = ref.read(nutritionNotifierProvider.notifier);
    final mealId = await notifier.addMeal(mealName);

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
      );
    }
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

    final unsynced = await (db.select(db.pantryFoods)
          ..where((t) => t.userId.equals(userId) & t.synced.equals(false)))
        .get();
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
        });
        await (db.update(db.pantryFoods)..where((t) => t.id.equals(f.id)))
            .write(const PantryFoodsCompanion(synced: Value(true)));
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
        await db.into(db.pantryFoods).insertOnConflictUpdate(
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
              ),
            );
      }

      // ── 2. User's personal pantry foods ───────────────────────────────────
      final personal = await Supabase.instance.client
          .from('pantry_foods')
          .select()
          .eq('user_id', userId);

      for (final row in personal as List) {
        await db.into(db.pantryFoods).insertOnConflictUpdate(
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
              ),
            );
      }
    } catch (_) {}
  }
}
