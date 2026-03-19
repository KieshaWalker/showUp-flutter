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
//   AgentMemory          — AI assistant's per-user memory/chat log
//   UserSubstances       — personal substance library with stated + learned impact
//   SubstanceLogs        — each individual substance use event
//   ReadinessCheckIns    — morning / afternoon / evening check-in data
//   DailyReadiness       — final computed score + user self-rating per day
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
//
// Connections:
//   database_provider.dart — wraps AppDatabase in a Riverpod provider
//   db.g.dart              — auto-generated Drift code (do not edit)
//   habits_notifier, nutrition_notifier, pantry_notifier,
//   readiness_notifier     — read/write tables via ref.watch(databaseProvider)

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
// Readiness tables
// ---------------------------------------------------------------------------

/// Personal substance library. One row per substance per user.
/// defaultImpact = user's stated 1–10 rating.
/// learnedImpact = null until enough data, then Bayesian blend of stated + observed.
class UserSubstances extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()(); // e.g. "alcohol", "weed", "shrooms"
  // 'positive' or 'negative' — user decides which way it affects readiness
  TextColumn get direction => text().withDefault(const Constant('negative'))();
  // User's self-assessed impact 1–10
  RealColumn get defaultImpact => real().withDefault(const Constant(5.0))();
  // Learned from observed next-day readiness deltas; null until n >= 3
  RealColumn get learnedImpact => real().nullable()();
  // How many times this substance has been logged (drives Bayesian weight)
  IntColumn get occurrenceCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per substance use event.
/// Links back to UserSubstances by name (not FK, for flexibility).
class SubstanceLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  // Stored date only as local midnight
  DateTimeColumn get date => dateTime()();
  TextColumn get substanceName => text()();
  // Snapshot of direction at time of logging
  TextColumn get direction => text()();
  // Snapshot of impact rating at time of logging (1–10)
  RealColumn get impactSnapshot => real()();
  // Optional: how much (e.g. "2 drinks", "1 joint") — free text
  TextColumn get quantity => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Time-gated check-in: one row per user per window ('morning','afternoon','evening') per day.
/// Nullable columns only apply to the window where they're asked.
class ReadinessCheckIns extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  // Date only — stored as local midnight
  DateTimeColumn get date => dateTime()();
  // 'morning' | 'afternoon' | 'evening'
  TextColumn get checkInWindow => text()();

  // --- morning only ---
  RealColumn get sleepHours => real().nullable()();
  IntColumn get sleepQuality => integer().nullable()(); // 1–5

  // --- all windows ---
  IntColumn get stressLevel => integer().nullable()(); // 1–5
  IntColumn get energyLevel => integer().nullable()(); // 1–5
  IntColumn get mood => integer().nullable()(); // 1–5

  // --- afternoon only ---
  IntColumn get caffeineCount => integer().nullable()(); // cups

  // --- afternoon + evening ---
  IntColumn get focusLevel => integer().nullable()(); // 1–5

  TextColumn get notes => text().nullable()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per user per day. Holds computed score, user self-rating, and
/// the carryover delta applied from the previous day's data.
class DailyReadiness extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  // Date only — stored as local midnight
  DateTimeColumn get date => dateTime()();
  // Algorithm output 0–100
  RealColumn get computedScore => real().withDefault(const Constant(70.0))();
  // User's honest self-rating (0–10); null until they submit it
  RealColumn get userRatedScore => real().nullable()();
  // How many points yesterday's data shifted today's baseline (can be negative)
  RealColumn get previousDayInfluence => real().withDefault(const Constant(0.0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Agent memory
// ---------------------------------------------------------------------------

// Agent memory for the individual user
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

// AppDatabase registers all tables with Drift. The @DriftDatabase annotation
// tells the code generator (db.g.dart) which tables to include.
// Note: AgentMemory is stored in Supabase only (not listed here) — the
// agent_notifier writes directly to Supabase rather than local SQLite.
@DriftDatabase(tables: [
  Habits,
  HabitCompletions,
  HabitSkips,
  Meals,
  FoodEntries,
  WaterLogs,
  DailyNutritionGoals,
  PantryFoods,
  UserSubstances,
  SubstanceLogs,
  ReadinessCheckIns,
  DailyReadiness,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

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
                'ALTER TABLE pantry_foods ADD COLUMN user_id TEXT');
            await customStatement(
                'ALTER TABLE pantry_foods ADD COLUMN synced INTEGER NOT NULL DEFAULT 0');
            await customStatement(
                'DELETE FROM pantry_foods WHERE is_preset = 1');
          }
          if (from < 6) {
            await customStatement(
                'ALTER TABLE daily_nutrition_goals ADD COLUMN current_weight_kg REAL');
            await customStatement(
                'ALTER TABLE daily_nutrition_goals ADD COLUMN target_weight_kg REAL');
          }
          if (from < 7) {
            await m.createTable(userSubstances);
            await m.createTable(substanceLogs);
            await m.createTable(readinessCheckIns);
            await m.createTable(dailyReadiness);
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


