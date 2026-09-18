// nutrition_notifier.dart — All nutrition logic: meals, food entries, water, goals, sync.
//
// Data model:
//   NutritionState — a snapshot of everything nutrition-related for today
//     meals          — list of Meal rows, each containing its FoodEntry rows
//     waterLogs      — all WaterLog rows for today
//     goals          — the user's DailyNutritionGoal row (targets)
//     totalCalories/protein/carbs/fat — computed from all food entries today
//     totalWaterMl   — computed from all water logs today
//
// nutritionNotifierProvider (StreamNotifierProvider<NutritionState>):
//   build()          — streams meals + food entries + water + goals from SQLite,
//                      rebuilds NutritionState whenever any row changes
//   addMeal()        — creates a new named meal locally, then Supabase
//   deleteMeal()     — deletes a meal and all its food entries locally, then Supabase
//   addFoodEntry()   — adds a food item to an existing meal locally, then Supabase
//   deleteFoodEntry()— removes a food item locally, then Supabase
//   logWater()       — adds a water intake record locally, then Supabase
//   deleteWaterLog() — removes a water record locally, then Supabase
//   saveGoals()      — upserts the user's calorie/macro/weight targets locally + Supabase
//   syncFromRemote() — pulls all nutrition data from Supabase on login,
//                      upserts into local SQLite
//
// Write strategy (local-first):
//   SQLite is written first so the UI is instant. Supabase sync is
//   fire-and-forget in try/catch — failures are silent, data stays local.
//
// Connections:
//   database_provider.dart  — ref.watch(databaseProvider) for SQLite access
//   auth_provider.dart      — currentUserIdProvider to scope to logged-in user
//   nutrition_screen.dart   — the UI for logging meals and viewing macros
//   presentation_screen.dart— reads totals for the overview dashboard

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:async/async.dart';
import '../../database/database_provider.dart';
import '../../database/db.dart';

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Data model for today's nutrition summary
// ---------------------------------------------------------------------------

/// Aggregated nutrition data for the current day.
/// Combines all meals, food entries, water logs, and goals.
///
/// Widget hierarchy connection:
///   ↓
/// _NutritionBody uses TodayNutrition to display:
///   - Macro progress bars (calories, protein, carbs, fat)
///   - Water intake progress
///   - List of meals with food items
class TodayNutrition {
  final List<MealWithEntries> meals;
  final DailyNutritionGoal? goals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalSugar;
  final double totalFiber;
  final double totalSodium;
  final double totalCholesterol;
  final double totalPotassium;
  final double totalCalcium;
  final double totalIron;
  final double totalVitaminA;
  final double totalVitaminC;
  final double totalWaterMl;

  const TodayNutrition({
    required this.meals,
    required this.goals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalSugar,
    required this.totalFiber,
    required this.totalSodium,
    required this.totalCholesterol,
    required this.totalPotassium,
    required this.totalCalcium,
    required this.totalIron,
    required this.totalVitaminA,
    required this.totalVitaminC,
    required this.totalWaterMl,
  });
}

/// A meal with its associated food entries.
/// Provides convenience computed properties for macro totals per meal.
///
/// Data flow:
/// - Meal: Database record (Breakfast, Lunch, Snack, etc.)
/// - entries: List of FoodEntry items added to this meal
/// - Computed totals: Used by _MealCard to show meal-level macros
class MealWithEntries {
  final Meal meal;
  final List<FoodEntry> entries;

  const MealWithEntries({required this.meal, required this.entries});

  double get calories => entries.fold(0, (s, e) => s + e.calories);
  double get protein => entries.fold(0, (s, e) => s + e.protein);
  double get carbs => entries.fold(0, (s, e) => s + e.carbs);
  double get fat => entries.fold(0, (s, e) => s + e.fat);
  double get sugar => entries.fold(0, (s, e) => s + e.sugar);
  double get fiber => entries.fold(0, (s, e) => s + e.fiber);
  double get sodium => entries.fold(0, (s, e) => s + e.sodium);
  double get cholesterol => entries.fold(0, (s, e) => s + e.cholesterol);
  double get potassium => entries.fold(0, (s, e) => s + e.potassium);
  double get calcium => entries.fold(0, (s, e) => s + e.calcium);
  double get iron => entries.fold(0, (s, e) => s + e.iron);
  double get vitaminA => entries.fold(0, (s, e) => s + e.vitaminA);
  double get vitaminC => entries.fold(0, (s, e) => s + e.vitaminC);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class NutritionNotifier extends StreamNotifier<TodayNutrition> {
  @override
  Stream<TodayNutrition> build() {
    final db = ref.watch(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    // Stream watchers are date-agnostic so they still fire after midnight
    // without needing to recreate the provider. The asyncMap recomputes the
    // current day's window fresh on every trigger.
    //
    // Only a cheap COUNT is watched (not the full rows) — Drift's watch()
    // invalidation is table-level regardless of which columns are selected,
    // so a COUNT still fires on every insert/update/delete to the table,
    // but without materializing the user's entire history into Dart objects
    // on every write just to immediately discard it.
    final mealsStream =
        (db.selectOnly(db.meals)
              ..addColumns([db.meals.id.count()])
              ..where(db.meals.userId.equals(userId)))
            .watchSingle();

    final entriesStream =
        (db.selectOnly(db.foodEntries)
              ..addColumns([db.foodEntries.id.count()])
              ..where(db.foodEntries.userId.equals(userId)))
            .watchSingle();

    final waterStream =
        (db.selectOnly(db.waterLogs)
              ..addColumns([db.waterLogs.id.count()])
              ..where(db.waterLogs.userId.equals(userId)))
            .watchSingle();

    final goalsStream =
        (db.select(db.dailyNutritionGoals)
          ..where((g) => g.userId.equals(userId))).watch();

    // merge all query streams into a single trigger stream; we ignore the
    // payload and recompute the full TodayNutrition on any change.
    final trigger = StreamGroup.merge<List<dynamic>>([
      mealsStream.map((_) => []),
      entriesStream.map((_) => []),
      waterStream.map((_) => []),
      goalsStream.map((_) => []),
    ]).map((_) => null);

    return trigger.asyncMap((_) async {
      // Compute today's window fresh on every trigger so the view stays correct
      // if the app is used past midnight.
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      return _computeNutrition(db, userId, startOfDay, endOfDay);
    });
  }

  /// Shared aggregation used by [build], [getNutritionForDate], and
  /// [getNutritionForDateRange] — fetches meals/entries/goals/water for
  /// [start, end) and folds them into a [TodayNutrition].
  Future<TodayNutrition> _computeNutrition(
    AppDatabase db,
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final meals =
        await (db.select(db.meals)..where(
          (m) =>
              m.userId.equals(userId) &
              m.loggedAt.isBiggerOrEqualValue(start) &
              m.loggedAt.isSmallerThanValue(end),
        )).get();

    final allEntries =
        await (db.select(db.foodEntries)
          ..where((e) => e.userId.equals(userId))).get();

    final goals =
        await (db.select(db.dailyNutritionGoals)
          ..where((g) => g.userId.equals(userId))).getSingleOrNull();

    final waterLogs =
        await (db.select(db.waterLogs)..where(
          (w) =>
              w.userId.equals(userId) &
              w.loggedAt.isBiggerOrEqualValue(start) &
              w.loggedAt.isSmallerThanValue(end),
        )).get();

    final mealsWithEntries =
        meals.map((meal) {
          final entries = allEntries.where((e) => e.mealId == meal.id).toList();
          return MealWithEntries(meal: meal, entries: entries);
        }).toList();

    double totalCal = 0,
        totalPro = 0,
        totalCarb = 0,
        totalFat = 0,
        totalSugar = 0,
        totalFiber = 0,
        totalSodium = 0,
        totalCholesterol = 0,
        totalPotassium = 0,
        totalCalcium = 0,
        totalIron = 0,
        totalVitaminA = 0,
        totalVitaminC = 0;
    for (final m in mealsWithEntries) {
      totalCal += m.calories;
      totalPro += m.protein;
      totalCarb += m.carbs;
      totalFat += m.fat;
      totalSugar += m.sugar;
      totalFiber += m.fiber;
      totalSodium += m.sodium;
      totalCholesterol += m.cholesterol;
      totalPotassium += m.potassium;
      totalCalcium += m.calcium;
      totalIron += m.iron;
      totalVitaminA += m.vitaminA;
      totalVitaminC += m.vitaminC;
    }

    return TodayNutrition(
      meals: mealsWithEntries,
      goals: goals,
      totalCalories: totalCal,
      totalProtein: totalPro,
      totalCarbs: totalCarb,
      totalFat: totalFat,
      totalSugar: totalSugar,
      totalFiber: totalFiber,
      totalSodium: totalSodium,
      totalCholesterol: totalCholesterol,
      totalPotassium: totalPotassium,
      totalCalcium: totalCalcium,
      totalIron: totalIron,
      totalVitaminA: totalVitaminA,
      totalVitaminC: totalVitaminC,
      totalWaterMl: waterLogs.fold<double>(0.0, (s, w) => s + w.amountMl),
    );
  }

  /// Creates a meal logged at [loggedAt] (defaults to now) — pass an
  /// explicit date to log a meal onto a past day, e.g. from the Calendar
  /// tab's day-detail editor.
  Future<String> addMeal(String name, {DateTime? loggedAt}) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Cannot add a meal: no signed-in user.');
    }
    final id = _uuid.v4();
    final at = loggedAt ?? DateTime.now();

    await db
        .into(db.meals)
        .insert(
          MealsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            loggedAt: Value(at),
          ),
        );

    try {
      await Supabase.instance.client.from('meals').insert({
        'id': id,
        'user_id': userId,
        'name': name,
        'logged_at': at.toIso8601String(),
      });
      await (db.update(db.meals)..where(
        (m) => m.id.equals(id),
      )).write(const MealsCompanion(synced: Value(true)));
    } catch (_) {}

    return id;
  }

  Future<void> addFoodEntry({
    required String mealId,
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    double sugar = 0,
    double fiber = 0,
    double sodium = 0,
    double cholesterol = 0,
    double potassium = 0,
    double calcium = 0,
    double iron = 0,
    double vitaminA = 0,
    double vitaminC = 0,
    String? pantryFoodId,
    double servings = 1.0,
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final id = _uuid.v4();

    await db
        .into(db.foodEntries)
        .insert(
          FoodEntriesCompanion.insert(
            id: id,
            mealId: mealId,
            userId: userId,
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
            pantryFoodId: Value(pantryFoodId),
            servings: Value(servings),
          ),
        );

    try {
      await Supabase.instance.client.from('food_entries').insert({
        'id': id,
        'meal_id': mealId,
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
        'pantry_food_id': pantryFoodId,
        'servings': servings,
      });
      await (db.update(db.foodEntries)..where(
        (e) => e.id.equals(id),
      )).write(const FoodEntriesCompanion(synced: Value(true)));
    } catch (_) {}
  }

  Future<void> deleteMeal(String mealId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.foodEntries)
      ..where((e) => e.mealId.equals(mealId))).go();
    await (db.delete(db.meals)..where((m) => m.id.equals(mealId))).go();
    try {
      await Supabase.instance.client
          .from('food_entries')
          .delete()
          .eq('meal_id', mealId);
      await Supabase.instance.client.from('meals').delete().eq('id', mealId);
    } catch (_) {}
  }

  Future<void> deleteFoodEntry(String entryId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.foodEntries)..where((e) => e.id.equals(entryId))).go();
    try {
      await Supabase.instance.client
          .from('food_entries')
          .delete()
          .eq('id', entryId);
    } catch (_) {}
  }

  Future<void> deleteWaterLog(String logId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.waterLogs)..where((w) => w.id.equals(logId))).go();
    try {
      await Supabase.instance.client
          .from('water_logs')
          .delete()
          .eq('id', logId);
    } catch (_) {}
  }

  Future<void> updateMeal(String mealId, String newName) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.meals)..where(
      (m) => m.id.equals(mealId),
    )).write(MealsCompanion(name: Value(newName), synced: const Value(false)));
    try {
      await Supabase.instance.client
          .from('meals')
          .update({'name': newName})
          .eq('id', mealId);
      await (db.update(db.meals)..where(
        (m) => m.id.equals(mealId),
      )).write(const MealsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  Future<void> logWater(double amountMl) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final id = _uuid.v4();

    await db
        .into(db.waterLogs)
        .insert(
          WaterLogsCompanion.insert(id: id, userId: userId, amountMl: amountMl),
        );

    try {
      await Supabase.instance.client.from('water_logs').insert({
        'id': id,
        'user_id': userId,
        'amount_ml': amountMl,
        'logged_at': DateTime.now().toIso8601String(),
      });
      await (db.update(db.waterLogs)..where(
        (w) => w.id.equals(id),
      )).write(const WaterLogsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  Future<void> updateGoals({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double waterMl,
    double fiber = 28,
    double sodium = 2300,
    double cholesterol = 300,
    double potassium = 4700,
    double calcium = 1300,
    double iron = 18,
    double vitaminA = 900,
    double vitaminC = 90,
    double? currentWeightKg,
    double? targetWeightKg,
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await db
        .into(db.dailyNutritionGoals)
        .insertOnConflictUpdate(
          DailyNutritionGoalsCompanion.insert(
            userId: userId,
            calories: Value(calories),
            protein: Value(protein),
            carbs: Value(carbs),
            fat: Value(fat),
            waterMl: Value(waterMl),
            fiber: Value(fiber),
            sodium: Value(sodium),
            cholesterol: Value(cholesterol),
            potassium: Value(potassium),
            calcium: Value(calcium),
            iron: Value(iron),
            vitaminA: Value(vitaminA),
            vitaminC: Value(vitaminC),
            currentWeightKg: Value(currentWeightKg),
            targetWeightKg: Value(targetWeightKg),
          ),
        );

    try {
      await Supabase.instance.client.from('daily_nutrition_goals').upsert({
        'user_id': userId,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'water_ml': waterMl,
        'fiber': fiber,
        'sodium': sodium,
        'cholesterol': cholesterol,
        'potassium': potassium,
        'calcium': calcium,
        'iron': iron,
        'vitamin_a': vitaminA,
        'vitamin_c': vitaminC,
        'current_weight_kg': currentWeightKg,
        'target_weight_kg': targetWeightKg,
      });
      await (db.update(db.dailyNutritionGoals)..where(
        (g) => g.userId.equals(userId),
      )).write(const DailyNutritionGoalsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Returns aggregated nutrition data for the given [date].
  Future<TodayNutrition> getNutritionForDate(DateTime date) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _computeNutrition(db, userId, start, end);
  }

  /// Aggregates nutrition data across a date range (used for weekly calendar summaries).
  Future<TodayNutrition> getNutritionForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    return _computeNutrition(db, userId, start, end);
  }

  /// Copies yesterday's meals and food entries into today.
  /// Returns true if any meals were copied, false if yesterday had none.
  Future<bool> copyYesterdaysMeals() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final startOfYesterday = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );
    final endOfYesterday = startOfYesterday.add(const Duration(days: 1));

    final yesterdayMeals =
        await (db.select(db.meals)..where(
          (m) =>
              m.userId.equals(userId) &
              m.loggedAt.isBiggerOrEqualValue(startOfYesterday) &
              m.loggedAt.isSmallerThanValue(endOfYesterday),
        )).get();

    if (yesterdayMeals.isEmpty) return false;

    final yesterdayMealIds = yesterdayMeals.map((m) => m.id).toList();
    final yesterdayEntries =
        await (db.select(db.foodEntries)
          ..where((e) => e.mealId.isIn(yesterdayMealIds))).get();

    final now = DateTime.now();

    for (final meal in yesterdayMeals) {
      final newMealId = _uuid.v4();

      await db
          .into(db.meals)
          .insert(
            MealsCompanion.insert(
              id: newMealId,
              userId: userId,
              name: meal.name,
              loggedAt: Value(now),
            ),
          );

      final mealEntries =
          yesterdayEntries.where((e) => e.mealId == meal.id).toList();
      final remoteEntries = <Map<String, dynamic>>[];

      for (final entry in mealEntries) {
        final newEntryId = _uuid.v4();
        await db
            .into(db.foodEntries)
            .insert(
              FoodEntriesCompanion.insert(
                id: newEntryId,
                mealId: newMealId,
                userId: userId,
                name: entry.name,
                calories: Value(entry.calories),
                protein: Value(entry.protein),
                carbs: Value(entry.carbs),
                fat: Value(entry.fat),
                sugar: Value(entry.sugar),
                fiber: Value(entry.fiber),
                sodium: Value(entry.sodium),
                cholesterol: Value(entry.cholesterol),
                potassium: Value(entry.potassium),
                calcium: Value(entry.calcium),
                iron: Value(entry.iron),
                vitaminA: Value(entry.vitaminA),
                vitaminC: Value(entry.vitaminC),
                pantryFoodId: Value(entry.pantryFoodId),
                servings: Value(entry.servings),
              ),
            );
        remoteEntries.add({
          'id': newEntryId,
          'meal_id': newMealId,
          'user_id': userId,
          'name': entry.name,
          'calories': entry.calories,
          'protein': entry.protein,
          'carbs': entry.carbs,
          'fat': entry.fat,
          'sugar': entry.sugar,
          'fiber': entry.fiber,
          'sodium': entry.sodium,
          'cholesterol': entry.cholesterol,
          'potassium': entry.potassium,
          'calcium': entry.calcium,
          'iron': entry.iron,
          'vitamin_a': entry.vitaminA,
          'vitamin_c': entry.vitaminC,
          'pantry_food_id': entry.pantryFoodId,
          'servings': entry.servings,
        });
      }

      try {
        await Supabase.instance.client.from('meals').insert({
          'id': newMealId,
          'user_id': userId,
          'name': meal.name,
          'logged_at': now.toIso8601String(),
        });
        if (remoteEntries.isNotEmpty) {
          await Supabase.instance.client
              .from('food_entries')
              .insert(remoteEntries);
        }
        await (db.update(db.meals)..where(
          (m) => m.id.equals(newMealId),
        )).write(const MealsCompanion(synced: Value(true)));
      } catch (_) {}
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // pushUnsyncedChanges — retry local writes whose Supabase sync previously
  // failed (e.g. made while offline). Uses upsert (not insert) since a prior
  // attempt may have partially succeeded remotely before failing to update
  // the local `synced` flag. Call this before syncFromRemote() on app launch.
  // ---------------------------------------------------------------------------
  Future<void> pushUnsyncedChanges() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final unsyncedMeals =
        await (db.select(db.meals)..where(
          (m) => m.userId.equals(userId) & m.synced.equals(false),
        )).get();
    for (final m in unsyncedMeals) {
      try {
        await Supabase.instance.client.from('meals').upsert({
          'id': m.id,
          'user_id': m.userId,
          'name': m.name,
          'logged_at': m.loggedAt.toIso8601String(),
        });
        await (db.update(db.meals)..where(
          (t) => t.id.equals(m.id),
        )).write(const MealsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('[Nutrition] pushUnsyncedChanges meal error: $e');
      }
    }

    final unsyncedEntries =
        await (db.select(db.foodEntries)..where(
          (e) => e.userId.equals(userId) & e.synced.equals(false),
        )).get();
    for (final e in unsyncedEntries) {
      try {
        await Supabase.instance.client.from('food_entries').upsert({
          'id': e.id,
          'meal_id': e.mealId,
          'user_id': e.userId,
          'name': e.name,
          'calories': e.calories,
          'protein': e.protein,
          'carbs': e.carbs,
          'fat': e.fat,
          'sugar': e.sugar,
          'fiber': e.fiber,
          'sodium': e.sodium,
          'cholesterol': e.cholesterol,
          'potassium': e.potassium,
          'calcium': e.calcium,
          'iron': e.iron,
          'vitamin_a': e.vitaminA,
          'vitamin_c': e.vitaminC,
          'pantry_food_id': e.pantryFoodId,
          'servings': e.servings,
        });
        await (db.update(db.foodEntries)..where(
          (t) => t.id.equals(e.id),
        )).write(const FoodEntriesCompanion(synced: Value(true)));
      } catch (err) {
        if (err is PostgrestException && err.code == '23503') {
          // Parent meal no longer exists remotely (deleted from another
          // device/session before this entry ever synced) — the meal-entry
          // link is unrecoverable, so drop the orphaned local entry instead
          // of retrying forever.
          await (db.delete(
            db.foodEntries,
          )..where((t) => t.id.equals(e.id))).go();
        } else {
          debugPrint('[Nutrition] pushUnsyncedChanges entry error: $err');
        }
      }
    }

    final unsyncedWater =
        await (db.select(db.waterLogs)..where(
          (w) => w.userId.equals(userId) & w.synced.equals(false),
        )).get();
    for (final w in unsyncedWater) {
      try {
        await Supabase.instance.client.from('water_logs').upsert({
          'id': w.id,
          'user_id': w.userId,
          'amount_ml': w.amountMl,
          'logged_at': w.loggedAt.toIso8601String(),
        });
        await (db.update(db.waterLogs)..where(
          (t) => t.id.equals(w.id),
        )).write(const WaterLogsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('[Nutrition] pushUnsyncedChanges water error: $e');
      }
    }

    final unsyncedGoals =
        await (db.select(db.dailyNutritionGoals)..where(
          (g) => g.userId.equals(userId) & g.synced.equals(false),
        )).get();
    for (final g in unsyncedGoals) {
      try {
        await Supabase.instance.client.from('daily_nutrition_goals').upsert({
          'user_id': g.userId,
          'calories': g.calories,
          'protein': g.protein,
          'carbs': g.carbs,
          'fat': g.fat,
          'water_ml': g.waterMl,
          'fiber': g.fiber,
          'sodium': g.sodium,
          'cholesterol': g.cholesterol,
          'potassium': g.potassium,
          'calcium': g.calcium,
          'iron': g.iron,
          'vitamin_a': g.vitaminA,
          'vitamin_c': g.vitaminC,
          'current_weight_kg': g.currentWeightKg,
          'target_weight_kg': g.targetWeightKg,
        });
        await (db.update(db.dailyNutritionGoals)..where(
          (t) => t.userId.equals(g.userId),
        )).write(const DailyNutritionGoalsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('[Nutrition] pushUnsyncedChanges goals error: $e');
      }
    }
  }

  Future<void> syncFromRemote() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final meals = await Supabase.instance.client
          .from('meals')
          .select()
          .eq('user_id', userId);
      for (final m in meals as List) {
        await db
            .into(db.meals)
            .insertOnConflictUpdate(
              MealsCompanion.insert(
                id: m['id'] as String,
                userId: m['user_id'] as String,
                name: m['name'] as String,
                loggedAt: Value(DateTime.parse(m['logged_at'] as String)),
                synced: const Value(true),
              ),
            );
      }

      final entries = await Supabase.instance.client
          .from('food_entries')
          .select()
          .eq('user_id', userId);
      for (final e in entries as List) {
        await db
            .into(db.foodEntries)
            .insertOnConflictUpdate(
              FoodEntriesCompanion.insert(
                id: e['id'] as String,
                mealId: e['meal_id'] as String,
                userId: e['user_id'] as String,
                name: e['name'] as String,
                calories: Value((e['calories'] as num).toDouble()),
                protein: Value((e['protein'] as num).toDouble()),
                carbs: Value((e['carbs'] as num).toDouble()),
                fat: Value((e['fat'] as num).toDouble()),
                sugar: Value((e['sugar'] as num?)?.toDouble() ?? 0.0),
                fiber: Value((e['fiber'] as num?)?.toDouble() ?? 0.0),
                sodium: Value((e['sodium'] as num?)?.toDouble() ?? 0.0),
                cholesterol: Value(
                  (e['cholesterol'] as num?)?.toDouble() ?? 0.0,
                ),
                potassium: Value((e['potassium'] as num?)?.toDouble() ?? 0.0),
                calcium: Value((e['calcium'] as num?)?.toDouble() ?? 0.0),
                iron: Value((e['iron'] as num?)?.toDouble() ?? 0.0),
                vitaminA: Value((e['vitamin_a'] as num?)?.toDouble() ?? 0.0),
                vitaminC: Value((e['vitamin_c'] as num?)?.toDouble() ?? 0.0),
                pantryFoodId: Value(e['pantry_food_id'] as String?),
                servings: Value((e['servings'] as num?)?.toDouble() ?? 1.0),
                synced: const Value(true),
              ),
            );
      }

      final water = await Supabase.instance.client
          .from('water_logs')
          .select()
          .eq('user_id', userId);
      for (final w in water as List) {
        await db
            .into(db.waterLogs)
            .insertOnConflictUpdate(
              WaterLogsCompanion.insert(
                id: w['id'] as String,
                userId: w['user_id'] as String,
                amountMl: (w['amount_ml'] as num).toDouble(),
                loggedAt: Value(DateTime.parse(w['logged_at'] as String)),
                synced: const Value(true),
              ),
            );
      }

      final goals =
          await Supabase.instance.client
              .from('daily_nutrition_goals')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
      if (goals != null) {
        await db
            .into(db.dailyNutritionGoals)
            .insertOnConflictUpdate(
              DailyNutritionGoalsCompanion.insert(
                userId: goals['user_id'] as String,
                calories: Value((goals['calories'] as num).toDouble()),
                protein: Value((goals['protein'] as num).toDouble()),
                carbs: Value((goals['carbs'] as num).toDouble()),
                fat: Value((goals['fat'] as num).toDouble()),
                waterMl: Value((goals['water_ml'] as num).toDouble()),
                fiber: Value((goals['fiber'] as num?)?.toDouble() ?? 28.0),
                sodium: Value(
                  (goals['sodium'] as num?)?.toDouble() ?? 2300.0,
                ),
                cholesterol: Value(
                  (goals['cholesterol'] as num?)?.toDouble() ?? 300.0,
                ),
                potassium: Value(
                  (goals['potassium'] as num?)?.toDouble() ?? 4700.0,
                ),
                calcium: Value(
                  (goals['calcium'] as num?)?.toDouble() ?? 1300.0,
                ),
                iron: Value((goals['iron'] as num?)?.toDouble() ?? 18.0),
                vitaminA: Value(
                  (goals['vitamin_a'] as num?)?.toDouble() ?? 900.0,
                ),
                vitaminC: Value(
                  (goals['vitamin_c'] as num?)?.toDouble() ?? 90.0,
                ),
                currentWeightKg: Value(
                  (goals['current_weight_kg'] as num?)?.toDouble(),
                ),
                targetWeightKg: Value(
                  (goals['target_weight_kg'] as num?)?.toDouble(),
                ),
                synced: const Value(true),
              ),
            );
      }
    } catch (_) {}
  }
}

final nutritionNotifierProvider =
    StreamNotifierProvider<NutritionNotifier, TodayNutrition>(
      NutritionNotifier.new,
    );
