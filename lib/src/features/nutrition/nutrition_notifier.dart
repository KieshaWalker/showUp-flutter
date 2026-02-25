import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
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
/// NutritionScreen watches nutritionNotifierProvider → receives AsyncValue<TodayNutrition>
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
  final double totalWaterMl;

  const TodayNutrition({
    required this.meals,
    required this.goals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
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
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Manages all nutrition data and operations for today.
/// Provides a real-time stream of today's meals, food entries, macros, and water intake.
///
/// Data flow:
/// 1. NutritionScreen watches nutritionNotifierProvider
/// 2. build() returns Stream<TodayNutrition> by combining:
///    - meals table (breakfast, lunch, snacks logged today)
///    - foodEntries table (individual food items in each meal)
///    - waterLogs table (water drinks logged today)
///    - dailyNutritionGoals table (user's daily macro/calorie targets)
/// 3. Aggregates food entries into meals with computed totals
/// 4. Calculates daily totals for all macros
/// 5. Whenever database changes, stream updates automatically
/// 6. UI widgets receive updated data and rebuild with new macros
///
/// Mutations (triggered by UI interactions):
/// - addMeal() - Creates new meal (Breakfast, Lunch, etc.)
/// - addFoodEntry() - Adds food item to a meal with macro info
/// - addWaterLog() - Logs water drink
/// - setGoals() - Updates daily nutrition targets
/// - deleteMeal()/deleteFoodEntry() - Remove items from database
class NutritionNotifier extends StreamNotifier<TodayNutrition> {
  @override
  Stream<TodayNutrition> build() {
    final db = ref.watch(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final mealsStream =
        (db.select(db.meals)..where(
          (m) =>
              m.userId.equals(userId) &
              m.loggedAt.isBiggerOrEqualValue(startOfDay) &
              m.loggedAt.isSmallerThanValue(endOfDay),
        )).watch();

    return mealsStream.asyncMap((meals) async {
      final allEntries =
          await (db.select(db.foodEntries)
            ..where((e) => e.userId.equals(userId))).get();

      final goals =
          await (db.select(db.dailyNutritionGoals)
            ..where((g) => g.userId.equals(userId))).getSingleOrNull();

      final waterToday =
          await (db.select(db.waterLogs)..where(
            (w) =>
                w.userId.equals(userId) &
                w.loggedAt.isBiggerOrEqualValue(startOfDay) &
                w.loggedAt.isSmallerThanValue(endOfDay),
          )).get();

      final mealsWithEntries =
          meals.map((meal) {
            final entries =
                allEntries.where((e) => e.mealId == meal.id).toList();
            return MealWithEntries(meal: meal, entries: entries);
          }).toList();

      double totalCal = 0, totalPro = 0, totalCarb = 0, totalFat = 0;
      for (final m in mealsWithEntries) {
        totalCal += m.calories;
        totalPro += m.protein;
        totalCarb += m.carbs;
        totalFat += m.fat;
      }

      final totalWater = waterToday.fold<double>(0, (s, w) => s + w.amountMl);

      return TodayNutrition(
        meals: mealsWithEntries,
        goals: goals,
        totalCalories: totalCal,
        totalProtein: totalPro,
        totalCarbs: totalCarb,
        totalFat: totalFat,
        totalWaterMl: totalWater,
      );
    });
  }

  Future<String> addMeal(String name) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final id = _uuid.v4();

    await db
        .into(db.meals)
        .insert(MealsCompanion.insert(id: id, userId: userId, name: name));

    try {
      await Supabase.instance.client.from('meals').insert({
        'id': id,
        'user_id': userId,
        'name': name,
        'logged_at': DateTime.now().toIso8601String(),
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
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
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
      });
      await (db.update(db.foodEntries)..where(
        (e) => e.id.equals(id),
      )).write(const FoodEntriesCompanion(synced: Value(true)));
    } catch (_) {}
  }

  Future<void> logWater(double amountMl) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
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
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;

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
      });
    } catch (_) {}
  }

  /// Returns aggregated nutrition data for the given [date].
  Future<TodayNutrition> getNutritionForDate(DateTime date) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final meals = await (db.select(db.meals)
          ..where(
            (m) =>
                m.userId.equals(userId) &
                m.loggedAt.isBiggerOrEqualValue(start) &
                m.loggedAt.isSmallerThanValue(end),
          ))
        .get();

    final allEntries = await (db.select(db.foodEntries)
          ..where((e) => e.userId.equals(userId)))
        .get();

    final goals = await (db.select(db.dailyNutritionGoals)
          ..where((g) => g.userId.equals(userId)))
        .getSingleOrNull();

    final waterLogs = await (db.select(db.waterLogs)
          ..where(
            (w) =>
                w.userId.equals(userId) &
                w.loggedAt.isBiggerOrEqualValue(start) &
                w.loggedAt.isSmallerThanValue(end),
          ))
        .get();

    final mealsWithEntries = meals.map((meal) {
      final entries = allEntries.where((e) => e.mealId == meal.id).toList();
      return MealWithEntries(meal: meal, entries: entries);
    }).toList();

    double cal = 0, pro = 0, carb = 0, fat = 0;
    for (final m in mealsWithEntries) {
      cal += m.calories;
      pro += m.protein;
      carb += m.carbs;
      fat += m.fat;
    }

    return TodayNutrition(
      meals: mealsWithEntries,
      goals: goals,
      totalCalories: cal,
      totalProtein: pro,
      totalCarbs: carb,
      totalFat: fat,
      totalWaterMl: waterLogs.fold<double>(0.0, (s, w) => s + w.amountMl),
    );
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
