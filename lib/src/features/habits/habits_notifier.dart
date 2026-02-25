import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../database/database_provider.dart';
import '../../database/db.dart';

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Represents a habit with its completion status and streak information.
/// Combines the raw Habit data with computed completion metrics.
///
/// Widget hierarchy connection:
/// HabitsScreen watches habitsNotifierProvider → receives List<HabitWithStatus>
///   ↓
/// _HabitTile displays each HabitWithStatus (shows name, streak, completion button)
///   ↓
/// User taps completion button → triggers toggleCompletion() mutation
class HabitWithStatus {
  final Habit habit;
  final bool completedToday;
  final bool completedThisWeek; // weekly habits: met full weekly target
  final int completionsThisWeek;
  final int streak; // days (daily) or weeks (weekly)

  const HabitWithStatus({
    required this.habit,
    required this.completedToday,
    required this.completedThisWeek,
    required this.completionsThisWeek,
    required this.streak,
  });

  /// Whether to show this habit as "done" and visually fade it out.
  /// - Daily: done when completed today
  /// - Weekly: done when completionsThisWeek >= targetDaysPerWeek
  bool get isDone {
    if (habit.frequencyType == 'weekly') return completedThisWeek;
    return completedToday;
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Manages all habit data and operations.
/// Provides a real-time stream of habits with completion status and streak calculations.
///
/// Data flow:
/// 1. HabitsScreen watches habitsNotifierProvider
/// 2. build() returns Stream<List<HabitWithStatus>> by combining:
///    - habits table (habit definitions)
///    - habitCompletions table (today's + historical completions)
/// 3. Each habit is with computed values (streaks, completion status)
/// 4. Whenever database changes, stream updates automatically
/// 5. UI widgets receive updated data and rebuild
///
/// Mutations (triggered by UI interactions):
/// - addHabit() - Creates new habit in local DB and syncs to Supabase
/// - toggleCompletion() - Marks habit complete/incomplete for today
/// - deleteHabit() - Removes habit and all its history
class HabitsNotifier extends StreamNotifier<List<HabitWithStatus>> {
  @override
  Stream<List<HabitWithStatus>> build() {
    final db = ref.watch(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final habitsStream =
        (db.select(db.habits)..where((h) => h.userId.equals(userId))).watch();

    return habitsStream.asyncMap((habits) async {
      final completions =
          await (db.select(db.habitCompletions)
            ..where((c) => c.userId.equals(userId))).get();

      final today = _dateOnly(DateTime.now());
      final weekStart = _startOfWeek(today);

      return habits.map((habit) {
        final habitCompletions =
            completions.where((c) => c.habitId == habit.id).toList()
              ..sort((a, b) => b.completedDate.compareTo(a.completedDate));

        final completedToday = habitCompletions.any(
          (c) => _dateOnly(c.completedDate) == today,
        );

        final thisWeekCompletions =
            habitCompletions
                .where((c) => !_dateOnly(c.completedDate).isBefore(weekStart))
                .toList();

        final completionsThisWeek = thisWeekCompletions.length;
        final completedThisWeek =
            completionsThisWeek >= habit.targetDaysPerWeek;

        final streak =
            habit.frequencyType == 'weekly'
                ? _calculateWeeklyStreak(
                  habitCompletions,
                  habit.targetDaysPerWeek,
                )
                : _calculateDailyStreak(habitCompletions);

        return HabitWithStatus(
          habit: habit,
          completedToday: completedToday,
          completedThisWeek: completedThisWeek,
          completionsThisWeek: completionsThisWeek,
          streak: streak,
        );
      }).toList();
    });
  }

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  Future<void> addHabit(
    String name, {
    String frequencyType = 'daily',
    int targetDaysPerWeek = 7,
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final id = _uuid.v4();

    await db
        .into(db.habits)
        .insert(
          HabitsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            frequencyType: Value(frequencyType),
            targetDaysPerWeek: Value(targetDaysPerWeek),
          ),
        );

    try {
      await Supabase.instance.client.from('habits').insert({
        'id': id,
        'user_id': userId,
        'name': name,
        'frequency_type': frequencyType,
        'target_days_per_week': targetDaysPerWeek,
      });
      await (db.update(db.habits)..where(
        (h) => h.id.equals(id),
      )).write(const HabitsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  Future<void> toggleCompletion(String habitId) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final today = _dateOnly(DateTime.now());

    final existing =
        await (db.select(db.habitCompletions)..where(
          (c) => c.habitId.equals(habitId) & c.completedDate.equals(today),
        )).getSingleOrNull();

    if (existing != null) {
      await (db.delete(db.habitCompletions)
        ..where((c) => c.id.equals(existing.id))).go();
      try {
        await Supabase.instance.client
            .from('habit_completions')
            .delete()
            .eq('id', existing.id);
      } catch (_) {}
    } else {
      final id = _uuid.v4();
      await db
          .into(db.habitCompletions)
          .insert(
            HabitCompletionsCompanion.insert(
              id: id,
              habitId: habitId,
              userId: userId,
              completedDate: today,
            ),
          );
      try {
        print('Inserting  for habit $habitId on ${today.toIso8601String()}');
        // Insert new completion record for today
        await Supabase.instance.client.from('habit_completions').insert({
          'id': id,
          'habit_id': habitId,
          'user_id': userId,
          'completed_date': today.toIso8601String(),
        });
        // Mark local record as synced
        await (db.update(db.habitCompletions)..where(
          (c) => c.id.equals(id),
        )).write(const HabitCompletionsCompanion(synced: Value(true)));
        // line by line explanation for 148-149 --- When toggling a completion,
        //we first check if a completion record already exists for today.
        //If it does, we delete it (marking as incomplete).
        //If it doesn't exist, we create a new completion record for today.
        // After inserting or deleting the record in Supabase, we also update
        // our local Drift database to keep the 'synced' status accurate. This ensures that our UI reflects the correct completion status and that any future sync operations know which records are already in sync with the backend.
      } catch (_) {}
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.habits)..where((h) => h.id.equals(habitId))).go();
    await (db.delete(db.habitCompletions)
      ..where((c) => c.habitId.equals(habitId))).go();
    try {
      await Supabase.instance.client.from('habits').delete().eq('id', habitId);
    } catch (_) {}
  }

  Future<void> syncFromRemote() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final habits = await Supabase.instance.client
          .from('habits')
          .select()
          .eq('user_id', userId);

      for (final h in habits as List) {
        await db
            .into(db.habits)
            .insertOnConflictUpdate(
              HabitsCompanion.insert(
                id: h['id'] as String,
                userId: h['user_id'] as String,
                name: h['name'] as String,
                frequencyType: Value(h['frequency_type'] as String),
                targetDaysPerWeek: Value(h['target_days_per_week'] as int),
                synced: const Value(true),
              ),
            );
      }

      final completions = await Supabase.instance.client
          .from('habit_completions')
          .select()
          .eq('user_id', userId);

      for (final c in completions as List) {
        await db
            .into(db.habitCompletions)
            .insertOnConflictUpdate(
              HabitCompletionsCompanion.insert(
                id: c['id'] as String,
                habitId: c['habit_id'] as String,
                userId: c['user_id'] as String,
                completedDate: DateTime.parse(c['completed_date'] as String),
                synced: const Value(true),
              ),
            );
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Calendar queries
  // ---------------------------------------------------------------------------

  /// Returns all habits with their completion status for the given [date].
  Future<List<({Habit habit, bool completed})>> getHabitsForDate(
    DateTime date,
  ) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final d = DateTime.utc(date.year, date.month, date.day);

    final habits = await (db.select(db.habits)
          ..where((h) => h.userId.equals(userId)))
        .get();

    final completions = await (db.select(db.habitCompletions)
          ..where(
            (c) => c.userId.equals(userId) & c.completedDate.equals(d),
          ))
        .get();

    final completedIds = completions.map((c) => c.habitId).toSet();
    return habits
        .map((h) => (habit: h, completed: completedIds.contains(h.id)))
        .toList();
  }

  /// Returns Set<DateTime> of completed dates for a habit in a given month.
  Future<Set<DateTime>> getCompletedDatesForMonth(
    String habitId,
    int year,
    int month,
  ) async {
    final db = ref.read(databaseProvider);
    final start = DateTime.utc(year, month, 1);
    final end = DateTime.utc(year, month + 1, 1);

    final rows =
        await (db.select(db.habitCompletions)..where(
          (c) =>
              c.habitId.equals(habitId) &
              c.completedDate.isBiggerOrEqualValue(start) &
              c.completedDate.isSmallerThanValue(end),
        )).get();

    return rows.map((r) => _dateOnly(r.completedDate)).toSet();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  DateTime _dateOnly(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

  /// Monday of the week containing [date]
  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday; // Mon=1, Sun=7
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Consecutive daily completions ending today or yesterday
  int _calculateDailyStreak(List<HabitCompletion> completions) {
    if (completions.isEmpty) return 0;
    final today = _dateOnly(DateTime.now());
    int streak = 0;
    DateTime cursor = today;

    for (final c in completions) {
      final d = _dateOnly(c.completedDate);
      if (d == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (d.isBefore(cursor)) {
        break;
      }
    }
    return streak;
  }

  /// Consecutive weeks where target was met
  int _calculateWeeklyStreak(List<HabitCompletion> completions, int target) {
    if (completions.isEmpty) return 0;
    final today = _dateOnly(DateTime.now());
    int streak = 0;
    DateTime weekStart = _startOfWeek(today);

    // Walk backwards week by week
    for (var i = 0; i < 52; i++) {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final count =
          completions
              .where(
                (c) =>
                    !_dateOnly(c.completedDate).isBefore(weekStart) &&
                    _dateOnly(c.completedDate).isBefore(weekEnd),
              )
              .length;

      if (count >= target) {
        streak++;
        weekStart = weekStart.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }
    return streak;
  }
}

final habitsNotifierProvider =
    StreamNotifierProvider<HabitsNotifier, List<HabitWithStatus>>(
      HabitsNotifier.new,
    );
