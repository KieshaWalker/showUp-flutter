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

class HabitWithStatus {
  final Habit habit;
  final bool completedToday;
  final bool completedThisWeek;
  final int completionsThisWeek;
  final int skipsThisWeek;
  final int streak;

  const HabitWithStatus({
    required this.habit,
    required this.completedToday,
    required this.completedThisWeek,
    required this.completionsThisWeek,
    required this.skipsThisWeek,
    required this.streak,
  });

  /// Effective completions = actual completions + skips used
  bool get isDone {
    if (habit.frequencyType == 'weekly') {
      return (completionsThisWeek + skipsThisWeek) >= habit.targetDaysPerWeek;
    }
    return completedToday;
  }

  int get skipsRemaining =>
      (habit.skipsAllowedPerWeek - skipsThisWeek).clamp(0, 99);
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

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

      final skips =
          await (db.select(db.habitSkips)
            ..where((s) => s.userId.equals(userId))).get();

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

        final skipsThisWeek =
            skips
                .where(
                  (s) =>
                      s.habitId == habit.id &&
                      _dateOnly(s.weekStart) == weekStart,
                )
                .length;

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
          skipsThisWeek: skipsThisWeek,
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
    int skipsAllowedPerWeek = 0,
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
            skipsAllowedPerWeek: Value(skipsAllowedPerWeek),
          ),
        );

    try {
      await Supabase.instance.client.from('habits').insert({
        'id': id,
        'user_id': userId,
        'name': name,
        'frequency_type': frequencyType,
        'target_days_per_week': targetDaysPerWeek,
        'skips_allowed_per_week': skipsAllowedPerWeek,
      });
      await (db.update(db.habits)..where(
        (h) => h.id.equals(id),
      )).write(const HabitsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  Future<void> updateHabit(
    String id, {
    String? name,
    String? frequencyType,
    int? targetDaysPerWeek,
    int? skipsAllowedPerWeek,
  }) async {
    final db = ref.read(databaseProvider);

    await (db.update(db.habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        frequencyType: frequencyType != null
            ? Value(frequencyType)
            : const Value.absent(),
        targetDaysPerWeek: targetDaysPerWeek != null
            ? Value(targetDaysPerWeek)
            : const Value.absent(),
        skipsAllowedPerWeek: skipsAllowedPerWeek != null
            ? Value(skipsAllowedPerWeek)
            : const Value.absent(),
        synced: const Value(false),
      ),
    );

    try {
      await Supabase.instance.client.from('habits').update({
        if (name != null) 'name': name,
        if (frequencyType != null) 'frequency_type': frequencyType,
        if (targetDaysPerWeek != null) 'target_days_per_week': targetDaysPerWeek,
        if (skipsAllowedPerWeek != null)
          'skips_allowed_per_week': skipsAllowedPerWeek,
      }).eq('id', id);
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
        await Supabase.instance.client.from('habit_completions').insert({
          'id': id,
          'habit_id': habitId,
          'user_id': userId,
          'completed_date': today.toIso8601String(),
        });
        await (db.update(db.habitCompletions)..where(
          (c) => c.id.equals(id),
        )).write(const HabitCompletionsCompanion(synced: Value(true)));
      } catch (_) {}
    }
  }

  /// Use a skip for the current week. No-op if no skips remaining.
  Future<void> skipWeek(String habitId) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final weekStart = _startOfWeek(_dateOnly(DateTime.now()));
    final id = _uuid.v4();

    await db
        .into(db.habitSkips)
        .insert(
          HabitSkipsCompanion.insert(
            id: id,
            habitId: habitId,
            userId: userId,
            weekStart: weekStart,
          ),
        );

    try {
      await Supabase.instance.client.from('habit_skips').insert({
        'id': id,
        'habit_id': habitId,
        'user_id': userId,
        'week_start': weekStart.toIso8601String(),
      });
      await (db.update(db.habitSkips)..where(
        (s) => s.id.equals(id),
      )).write(const HabitSkipsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Remove a skip for the current week (undo skip).
  Future<void> unskipWeek(String habitId) async {
    final db = ref.read(databaseProvider);
    final weekStart = _startOfWeek(_dateOnly(DateTime.now()));

    final existing =
        await (db.select(db.habitSkips)..where(
          (s) =>
              s.habitId.equals(habitId) & s.weekStart.equals(weekStart),
        )).get();

    if (existing.isEmpty) return;
    final last = existing.last;

    await (db.delete(db.habitSkips)..where((s) => s.id.equals(last.id))).go();
    try {
      await Supabase.instance.client
          .from('habit_skips')
          .delete()
          .eq('id', last.id);
    } catch (_) {}
  }

  Future<void> deleteHabit(String habitId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.habits)..where((h) => h.id.equals(habitId))).go();
    await (db.delete(db.habitCompletions)
      ..where((c) => c.habitId.equals(habitId))).go();
    await (db.delete(db.habitSkips)
      ..where((s) => s.habitId.equals(habitId))).go();
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
                skipsAllowedPerWeek: Value(
                  (h['skips_allowed_per_week'] as int?) ?? 0,
                ),
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

      final skips = await Supabase.instance.client
          .from('habit_skips')
          .select()
          .eq('user_id', userId);

      for (final s in skips as List) {
        await db
            .into(db.habitSkips)
            .insertOnConflictUpdate(
              HabitSkipsCompanion.insert(
                id: s['id'] as String,
                habitId: s['habit_id'] as String,
                userId: s['user_id'] as String,
                weekStart: DateTime.parse(s['week_start'] as String),
                synced: const Value(true),
              ),
            );
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Calendar queries
  // ---------------------------------------------------------------------------

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

  Future<({int done, int total})> getWeekHabitStats(
    DateTime weekStart,
    DateTime weekEnd,
  ) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final habits = await (db.select(db.habits)
          ..where((h) => h.userId.equals(userId)))
        .get();
    if (habits.isEmpty) return (done: 0, total: 0);

    final completions = await (db.select(db.habitCompletions)
          ..where(
            (c) =>
                c.userId.equals(userId) &
                c.completedDate.isBiggerOrEqualValue(weekStart) &
                c.completedDate.isSmallerThanValue(weekEnd),
          ))
        .get();

    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final effectiveEnd = weekEnd.isAfter(todayUtc)
        ? todayUtc.add(const Duration(days: 1))
        : weekEnd;
    final elapsedDays = effectiveEnd.difference(weekStart).inDays.clamp(0, 7);

    return (done: completions.length, total: habits.length * elapsedDays);
  }

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

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

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

  int _calculateWeeklyStreak(List<HabitCompletion> completions, int target) {
    if (completions.isEmpty) return 0;
    final today = _dateOnly(DateTime.now());
    int streak = 0;
    DateTime weekStart = _startOfWeek(today);

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
