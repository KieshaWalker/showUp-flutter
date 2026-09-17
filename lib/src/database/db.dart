// db.dart — The local SQLite database schema for Show Up.
//
// This file uses Drift (a type-safe SQLite library for Flutter) to define
// every table the app stores locally on the device. Data is written here
// FIRST (offline-first), then synced to Supabase in the background.
//
// Tables overview:
//   Habits               — user's recurring habits (daily or weekly)
//   HabitCompletions     — one row per habit per day it was marked done
//   HabitSkips           — tracks allowed skips for weekly habits
//   Meals                — named meal containers (e.g. "Breakfast")
//   FoodEntries          — individual foods logged inside a meal
//   WaterLogs            — water intake entries (in ml)
//   DailyNutritionGoals  — calorie/macro/water targets + weight info
//   PantryFoods          — food library (global presets + personal foods)
//
// The `synced` boolean column on each table tracks whether a row has been
// pushed to Supabase yet. The notifiers read this to know what to sync.
//
// Schema version history (schemaVersion in AppDatabase):
//   v1 — initial
//   v2 — full recreate
//   v3 — added skipsAllowedPerWeek + HabitSkips table
//   v4 — added PantryFoods table
//   v5 — added userId + synced to pantry_foods, removed local presets
//   v6 — added currentWeightKg + targetWeightKg to DailyNutritionGoals
//   v7 — added readiness system: UserSubstances, SubstanceLogs,
//         ReadinessCheckIns, DailyReadiness
//   v8 — added sugar to FoodEntries
//   v9 — added sugar + micronutrients (fiber, sodium, cholesterol,
//         potassium, calcium, iron, vitaminA, vitaminC) to PantryFoods
//   v10 — removed the readiness system (UserSubstances, SubstanceLogs,
//         ReadinessCheckIns, DailyReadiness) and the unused AgentMemory table
//   v11 — added micronutrients (fiber, sodium, cholesterol, potassium,
//         calcium, iron, vitaminA, vitaminC) to FoodEntries, and matching
//         per-user goal columns (defaulted to FDA daily values) to
//         DailyNutritionGoals
//
// Connections:
//   database_provider.dart — wraps AppDatabase in a Riverpod provider
//   db.g.dart              — auto-generated Drift code (do not edit)
//   habits_notifier, nutrition_notifier,
//   pantry_notifier         — read/write tables via ref.watch(databaseProvider)

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

// ---------------------------------------------------------------------------
// Habits tables
// ---------------------------------------------------------------------------

class Habits extends Table {
  TextColumn get id => text()(); // UUID from Supabase
  TextColumn get userId => text()();
  TextColumn get name => text()();
  // 'daily' or 'weekly'
  TextColumn get frequencyType => text().withDefault(const Constant('daily'))();
  // For weekly habits: how many days per week (1-7)
  IntColumn get targetDaysPerWeek => integer().withDefault(const Constant(1))();
  IntColumn get skipsAllowedPerWeek =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitCompletions extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  TextColumn get userId => text()();
  // Date only — stored as local midnight to avoid timezone issues
  DateTimeColumn get completedDate => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitSkips extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  TextColumn get userId => text()();
  // Monday of the week this skip applies to (midnight UTC)
  DateTimeColumn get weekStart => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Nutrition tables
// ---------------------------------------------------------------------------

class Meals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class FoodEntries extends Table {
  TextColumn get id => text()();
  TextColumn get mealId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  RealColumn get calories => real().withDefault(const Constant(0.0))();
  RealColumn get protein => real().withDefault(const Constant(0.0))();
  RealColumn get carbs => real().withDefault(const Constant(0.0))();
  RealColumn get fat => real().withDefault(const Constant(0.0))();
  RealColumn get sugar => real().withDefault(const Constant(0.0))();

  /// Fiber (g)
  RealColumn get fiber => real().withDefault(const Constant(0.0))();

  /// Sodium (mg)
  RealColumn get sodium => real().withDefault(const Constant(0.0))();

  /// Cholesterol (mg)
  RealColumn get cholesterol => real().withDefault(const Constant(0.0))();

  /// Potassium (mg)
  RealColumn get potassium => real().withDefault(const Constant(0.0))();

  /// Calcium (mg)
  RealColumn get calcium => real().withDefault(const Constant(0.0))();

  /// Iron (mg)
  RealColumn get iron => real().withDefault(const Constant(0.0))();

  /// Vitamin A (mcg)
  RealColumn get vitaminA => real().withDefault(const Constant(0.0))();

  /// Vitamin C (mg)
  RealColumn get vitaminC => real().withDefault(const Constant(0.0))();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class WaterLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  // Amount in ml
  RealColumn get amountMl => real()();
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DailyNutritionGoals extends Table {
  TextColumn get userId => text()();
  RealColumn get calories => real().withDefault(const Constant(2000.0))();
  RealColumn get protein => real().withDefault(const Constant(150.0))();
  RealColumn get carbs => real().withDefault(const Constant(250.0))();
  RealColumn get fat => real().withDefault(const Constant(65.0))();
  RealColumn get waterMl => real().withDefault(const Constant(2500.0))();

  // Micronutrient targets — default to the FDA's general adult Daily Values
  // (used as the "recommended" reference shown in the goals editor too).
  /// Fiber (g)
  RealColumn get fiber => real().withDefault(const Constant(28.0))();

  /// Sodium (mg)
  RealColumn get sodium => real().withDefault(const Constant(2300.0))();

  /// Cholesterol (mg)
  RealColumn get cholesterol => real().withDefault(const Constant(300.0))();

  /// Potassium (mg)
  RealColumn get potassium => real().withDefault(const Constant(4700.0))();

  /// Calcium (mg)
  RealColumn get calcium => real().withDefault(const Constant(1300.0))();

  /// Iron (mg)
  RealColumn get iron => real().withDefault(const Constant(18.0))();

  /// Vitamin A (mcg)
  RealColumn get vitaminA => real().withDefault(const Constant(900.0))();

  /// Vitamin C (mg)
  RealColumn get vitaminC => real().withDefault(const Constant(90.0))();

  RealColumn get currentWeightKg => real().nullable()();
  RealColumn get targetWeightKg => real().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {userId};
}

// ---------------------------------------------------------------------------
// Pantry table
// ---------------------------------------------------------------------------

class PantryFoods extends Table {
  TextColumn get id => text()();

  /// NULL = global preset (admin-managed, visible to all users).
  /// Non-null = personal food belonging to this user.
  TextColumn get userId => text().nullable()();
  TextColumn get name => text()();

  /// Calories per serving
  RealColumn get calories => real().withDefault(const Constant(0.0))();

  /// Protein per serving (g)
  RealColumn get protein => real().withDefault(const Constant(0.0))();

  /// Carbs per serving (g)
  RealColumn get carbs => real().withDefault(const Constant(0.0))();

  /// Fat per serving (g)
  RealColumn get fat => real().withDefault(const Constant(0.0))();

  /// Sugar per serving (g)
  RealColumn get sugar => real().withDefault(const Constant(0.0))();

  /// Fiber per serving (g)
  RealColumn get fiber => real().withDefault(const Constant(0.0))();

  /// Sodium per serving (mg)
  RealColumn get sodium => real().withDefault(const Constant(0.0))();

  /// Cholesterol per serving (mg)
  RealColumn get cholesterol => real().withDefault(const Constant(0.0))();

  /// Potassium per serving (mg)
  RealColumn get potassium => real().withDefault(const Constant(0.0))();

  /// Calcium per serving (mg)
  RealColumn get calcium => real().withDefault(const Constant(0.0))();

  /// Iron per serving (mg)
  RealColumn get iron => real().withDefault(const Constant(0.0))();

  /// Vitamin A per serving (mcg)
  RealColumn get vitaminA => real().withDefault(const Constant(0.0))();

  /// Vitamin C per serving (mg)
  RealColumn get vitaminC => real().withDefault(const Constant(0.0))();

  /// Human-readable serving description e.g. "1 slice (28g)", "1 egg (50g)"
  TextColumn get servingLabel =>
      text().withDefault(const Constant('1 serving'))();

  /// True for global preset foods managed in Supabase.
  BoolColumn get isPreset => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

// AppDatabase registers all tables with Drift. The @DriftDatabase annotation
// tells the code generator (db.g.dart) which tables to include.
@DriftDatabase(
  tables: [
    Habits,
    HabitCompletions,
    HabitSkips,
    Meals,
    FoodEntries,
    WaterLogs,
    DailyNutritionGoals,
    PantryFoods,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 11;

  // Migration runs automatically when the app detects the on-device schema
  // version is older than schemaVersion. Each `if (from < N)` block applies
  // changes incrementally so users upgrading from any version get the right
  // columns without losing their data.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createAll();
        return;
      }
      if (from < 3) {
        await m.addColumn(habits, habits.skipsAllowedPerWeek);
        await m.createTable(habitSkips);
      }
      if (from < 4) {
        await m.createTable(pantryFoods);
      }
      if (from < 5) {
        await customStatement(
          'ALTER TABLE pantry_foods ADD COLUMN user_id TEXT',
        );
        await customStatement(
          'ALTER TABLE pantry_foods ADD COLUMN synced INTEGER NOT NULL DEFAULT 0',
        );
        await customStatement('DELETE FROM pantry_foods WHERE is_preset = 1');
      }
      if (from < 6) {
        await customStatement(
          'ALTER TABLE daily_nutrition_goals ADD COLUMN current_weight_kg REAL',
        );
        await customStatement(
          'ALTER TABLE daily_nutrition_goals ADD COLUMN target_weight_kg REAL',
        );
      }
      if (from < 8) {
        await customStatement(
          'ALTER TABLE food_entries ADD COLUMN sugar REAL NOT NULL DEFAULT 0.0',
        );
      }
      if (from < 9) {
        for (final column in [
          'sugar',
          'fiber',
          'sodium',
          'cholesterol',
          'potassium',
          'calcium',
          'iron',
          'vitamin_a',
          'vitamin_c',
        ]) {
          await customStatement(
            'ALTER TABLE pantry_foods ADD COLUMN $column REAL NOT NULL DEFAULT 0.0',
          );
        }
      }
      if (from < 10) {
        await customStatement('DROP TABLE IF EXISTS user_substances');
        await customStatement('DROP TABLE IF EXISTS substance_logs');
        await customStatement('DROP TABLE IF EXISTS readiness_check_ins');
        await customStatement('DROP TABLE IF EXISTS daily_readiness');
      }
      if (from < 11) {
        for (final column in [
          'fiber',
          'sodium',
          'cholesterol',
          'potassium',
          'calcium',
          'iron',
          'vitamin_a',
          'vitamin_c',
        ]) {
          await customStatement(
            'ALTER TABLE food_entries ADD COLUMN $column REAL NOT NULL DEFAULT 0.0',
          );
        }
        for (final entry in {
          'fiber': 28.0,
          'sodium': 2300.0,
          'cholesterol': 300.0,
          'potassium': 4700.0,
          'calcium': 1300.0,
          'iron': 18.0,
          'vitamin_a': 900.0,
          'vitamin_c': 90.0,
        }.entries) {
          await customStatement(
            'ALTER TABLE daily_nutrition_goals ADD COLUMN ${entry.key} REAL NOT NULL DEFAULT ${entry.value}',
          );
        }
      }
    },
  );

  // Opens the correct SQLite connection depending on the platform.
  // On mobile/desktop: uses the native file system (application support dir).
  // On web (Vercel deployment): uses sqlite3.wasm + drift_worker.js which
  //   are copied into build/web/ during `flutter build web`.
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'show_up',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
