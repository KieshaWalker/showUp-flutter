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
  IntColumn get skipsAllowedPerWeek => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitCompletions extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  TextColumn get userId => text()();
  // Date only — stored as midnight UTC to avoid timezone issues
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


// Agent memory for the indiviudal user
class AgentMemory extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get content => text()();
  TextColumn get type => text()(); // e.g. 'summary', 'reflection', 'plan'
  TextColumn get source => text()(); // e.g. 'agent', 'user', 'system'
  TextColumn get relatedHabitId => text().nullable()(); // optional link to a habit
  TextColumn get relatedMealId => text().nullable()(); // optional link to a meal
  TextColumn get relatedFoodEntryId => text().nullable()(); // optional link to a food entry
  TextColumn get relatedWaterLogId => text().nullable()(); // optional link to a water log
  // get historic habit completion status for the week this memory is related to (for habit-related memories)
  TextColumn get relatedHabitCompletionStatus => text().nullable()();
  TextColumn get relatedNutritionSummary => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // get most recent question
  TextColumn get mostRecentQuestion => text().nullable()();
  TextColumn get mostRecentAnswer => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}













// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  Habits,
  HabitCompletions,
  HabitSkips,
  Meals,
  FoodEntries,
  WaterLogs,
  DailyNutritionGoals,
  PantryFoods,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

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
            // Add user_id (nullable text — NULL = global preset)
            await customStatement(
                'ALTER TABLE pantry_foods ADD COLUMN user_id TEXT');
            // Add synced flag (integer 0/1, Drift stores bools as int)
            await customStatement(
                'ALTER TABLE pantry_foods ADD COLUMN synced INTEGER NOT NULL DEFAULT 0');
            // Remove locally-seeded presets; they'll be replaced by the
            // global Supabase presets the next time syncFromRemote() runs.
            await customStatement(
                'DELETE FROM pantry_foods WHERE is_preset = 1');
          }
        },
      );

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


