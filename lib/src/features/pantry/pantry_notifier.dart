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
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
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
        'serving_label': servingLabel,
        'is_preset': false,
      });
      await (db.update(db.pantryFoods)..where((t) => t.id.equals(id)))
          .write(const PantryFoodsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Update an existing personal food. Global presets cannot be edited from
  /// the app — use the Supabase SQL editor for those.
  Future<void> updateFood({
    required String id,
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String servingLabel,
  }) async {
    final db = ref.read(databaseProvider);

    await (db.update(db.pantryFoods)..where((t) => t.id.equals(id))).write(
      PantryFoodsCompanion(
        name: Value(name),
        calories: Value(calories),
        protein: Value(protein),
        carbs: Value(carbs),
        fat: Value(fat),
        servingLabel: Value(servingLabel),
        synced: const Value(false),
      ),
    );

    try {
      await Supabase.instance.client.from('pantry_foods').update({
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'serving_label': servingLabel,
      }).eq('id', id);
      await (db.update(db.pantryFoods)..where((t) => t.id.equals(id)))
          .write(const PantryFoodsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Delete a personal food. Global presets are protected by Supabase RLS and
  /// cannot be deleted by regular users.
  Future<void> deleteFood(String id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.pantryFoods)..where((t) => t.id.equals(id))).go();
    try {
      await Supabase.instance.client
          .from('pantry_foods')
          .delete()
          .eq('id', id);
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
      );
    }
  }

  // ── Remote sync ────────────────────────────────────────────────────────────

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
                servingLabel: Value(row['serving_label'] as String),
                isPreset: Value(row['is_preset'] as bool? ?? false),
                synced: const Value(true),
              ),
            );
      }
    } catch (_) {}
  }
}
