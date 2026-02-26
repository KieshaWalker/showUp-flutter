import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
// Preset foods (seeded on first launch)
// ---------------------------------------------------------------------------

const _presets = [
  (
    name: 'White Bread',
    cal: 75.0,
    pro: 2.5,
    carb: 14.0,
    fat: 1.0,
    label: '1 slice (28 g)',
  ),
  (
    name: 'Egg',
    cal: 70.0,
    pro: 6.0,
    carb: 0.5,
    fat: 5.0,
    label: '1 large (50 g)',
  ),
  (
    name: 'Butter',
    cal: 100.0,
    pro: 0.1,
    carb: 0.0,
    fat: 11.0,
    label: '1 tbsp (14 g)',
  ),
  (
    name: 'Bacon',
    cal: 85.0,
    pro: 6.0,
    carb: 0.0,
    fat: 7.0,
    label: '2 strips cooked (14 g)',
  ),
  (
    name: 'Chicken Breast',
    cal: 165.0,
    pro: 31.0,
    carb: 0.0,
    fat: 3.6,
    label: '100 g cooked',
  ),
  (
    name: 'White Rice',
    cal: 130.0,
    pro: 2.7,
    carb: 28.0,
    fat: 0.3,
    label: '100 g cooked',
  ),
  (
    name: 'Rolled Oats',
    cal: 156.0,
    pro: 5.5,
    carb: 27.0,
    fat: 3.0,
    label: '40 g dry',
  ),
  (
    name: 'Banana',
    cal: 105.0,
    pro: 1.3,
    carb: 27.0,
    fat: 0.4,
    label: '1 medium (120 g)',
  ),
  (
    name: 'Whole Milk',
    cal: 149.0,
    pro: 8.0,
    carb: 12.0,
    fat: 8.0,
    label: '1 cup (240 ml)',
  ),
  (
    name: 'Broccoli',
    cal: 34.0,
    pro: 2.8,
    carb: 7.0,
    fat: 0.4,
    label: '100 g',
  ),
  (
    name: 'Olive Oil',
    cal: 124.0,
    pro: 0.0,
    carb: 0.0,
    fat: 14.0,
    label: '1 tbsp (14 g)',
  ),
  (
    name: 'Almonds',
    cal: 174.0,
    pro: 6.0,
    carb: 6.0,
    fat: 15.0,
    label: 'small handful (30 g)',
  ),
  (
    name: 'Greek Yogurt',
    cal: 100.0,
    pro: 17.0,
    carb: 6.0,
    fat: 0.7,
    label: '1 container (170 g)',
  ),
  (
    name: 'Sweet Potato',
    cal: 112.0,
    pro: 2.0,
    carb: 26.0,
    fat: 0.1,
    label: '1 medium (130 g)',
  ),
  (
    name: 'Salmon',
    cal: 208.0,
    pro: 20.0,
    carb: 0.0,
    fat: 13.0,
    label: '100 g fillet',
  ),
  (
    name: 'Cheddar Cheese',
    cal: 120.0,
    pro: 7.0,
    carb: 0.4,
    fat: 10.0,
    label: '1 oz (30 g)',
  ),
  (
    name: 'Black Coffee',
    cal: 2.0,
    pro: 0.3,
    carb: 0.0,
    fat: 0.0,
    label: '1 cup (240 ml)',
  ),
  (
    name: 'Orange Juice',
    cal: 112.0,
    pro: 1.7,
    carb: 26.0,
    fat: 0.5,
    label: '1 cup (240 ml)',
  ),
];

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PantryNotifier extends StreamNotifier<List<PantryFood>> {
  @override
  Stream<List<PantryFood>> build() {
    final db = ref.watch(databaseProvider);
    _seedPresetsIfEmpty(db);
    return (db.select(db.pantryFoods)
          ..orderBy([
            (t) => OrderingTerm(expression: t.isPreset, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  Future<void> _seedPresetsIfEmpty(AppDatabase db) async {
    final count =
        await (db.select(db.pantryFoods)..where((t) => t.isPreset.equals(true)))
            .get();
    if (count.isNotEmpty) return;

    await db.batch((batch) {
      for (final p in _presets) {
        batch.insert(
          db.pantryFoods,
          PantryFoodsCompanion.insert(
            id: _uuid.v4(),
            name: p.name,
            calories: Value(p.cal),
            protein: Value(p.pro),
            carbs: Value(p.carb),
            fat: Value(p.fat),
            servingLabel: Value(p.label),
            isPreset: const Value(true),
          ),
        );
      }
    });
  }

  Future<void> addFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String servingLabel,
  }) async {
    final db = ref.read(databaseProvider);
    await db.into(db.pantryFoods).insert(
          PantryFoodsCompanion.insert(
            id: _uuid.v4(),
            name: name,
            calories: Value(calories),
            protein: Value(protein),
            carbs: Value(carbs),
            fat: Value(fat),
            servingLabel: Value(servingLabel),
            isPreset: const Value(false),
          ),
        );
  }

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
      ),
    );
  }

  Future<void> deleteFood(String id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.pantryFoods)..where((t) => t.id.equals(id))).go();
  }

  /// Creates a named meal in today's nutrition from a list of pantry foods
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
}
