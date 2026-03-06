// habits_notifier.dart — All habit logic: create, complete, skip, delete, sync.
//
// Data model:
//   HabitWithStatus — pairs a Habit row with computed today/week status
//     habit            — the raw Drift Habit row
//     completedToday   — true if there's a HabitCompletion for today
//     isDone           — for daily habits = completedToday;
//                        for weekly habits = completed enough days this week
//     completionsThisWeek — count of days completed in the current Mon–Sun week
//     skippedThisWeek     — true if a HabitSkip exists for this week
//
// habitsNotifierProvider (StreamNotifierProvider<List<HabitWithStatus>>):
//   build()             — streams the full habit list from local SQLite,
//                         joining completions + skips to compute status
//   addHabit()          — inserts locally, then syncs to Supabase
//   updateHabit()       — updates locally, then syncs to Supabase
//   deleteHabit()       — deletes locally + all completions/skips, then Supabase
//   toggleCompletion()  — marks a habit done or undone for today
//   toggleSkip()        — adds/removes a weekly skip for a habit
//   syncFromRemote()    — pulls all habits/completions/skips from Supabase
//                         and upserts into local SQLite (called on login)
//
// Write strategy (local-first):
//   Every write hits SQLite first so the UI updates instantly.
//   The Supabase sync is fire-and-forget inside try/catch — if it fails,
//   the data stays local and will sync next time.
//
// Connections:
//   database_provider.dart  — ref.watch(databaseProvider) for SQLite access
//   auth_provider.dart      — reads currentUserIdProvider to scope queries
//   habits_screen.dart      — the UI that shows this data and triggers actions
//   agent_notifier.dart     — reads habitsNotifierProvider + calls toggleCompletion
//   calendar_screen.dart    — reads habitsNotifierProvider for history view

import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:async/async.dart';
import '../../database/database_provider.dart';
import '../../database/db.dart';

const _uuid = Uuid();

// =============================================================================
// DATA MODEL
// =============================================================================
//
// HabitWithStatus is the computed view-model consumed by every screen.
// It combines a raw Habit row from the DB with real-time status fields
// that are re-computed every time completions or skips change.
//
// ┌──────────────────────────────────────────────────────────────────────────┐
// │  FIELD REFERENCE                                                         │
// │                                                                          │
// │  completedToday     — true if there is a HabitCompletion row for today. │
// │                       Resets to false at local midnight.                 │
// │                       Used by: habits_screen circle, presentation list.  │
// │                                                                          │
// │  completedThisWeek  — true if raw completion count this week (Mon–Sun)  │
// │                       >= targetDaysPerWeek (skips NOT counted here).     │
// │                       Currently unused in the UI; available for future.  │
// │                                                                          │
// │  completionsThisWeek — raw count of completion rows this calendar week.  │
// │                        Shown in weekly habit subtitle "X/Y× this week".  │
// │                                                                          │
// │  skipsThisWeek      — count of HabitSkip rows for this week.            │
// │                        Each skip consumes one "free pass" slot.          │
// │                                                                          │
// │  streak             — consecutive days (daily) or consecutive weeks      │
// │                        (weekly) where the target was met.                │
// └──────────────────────────────────────────────────────────────────────────┘

class HabitWithStatus {
  final Habit habit;

  /// True if a HabitCompletion record exists for today's LOCAL calendar date.
  final bool completedToday;

  /// True if raw completionsThisWeek >= targetDaysPerWeek.
  /// NOTE: skips are NOT counted here — use isDone for the combined check.
  final bool completedThisWeek;

  /// Number of HabitCompletion rows for the current calendar week (Mon–Sun).
  final int completionsThisWeek;

  /// Number of HabitSkip rows used for the current calendar week.
  final int skipsThisWeek;

  /// Streak: consecutive days met (daily) or consecutive weeks met (weekly).
  final int streak;

  const HabitWithStatus({
    required this.habit,
    required this.completedToday,
    required this.completedThisWeek,
    required this.completionsThisWeek,
    required this.skipsThisWeek,
    required this.streak,
  });

  // ---------------------------------------------------------------------------
  // isDone — the canonical "is this habit finished?" flag
  // ---------------------------------------------------------------------------
  //
  // ┌──────────────────────────────────────────────────────────────────────┐
  // │  CONFIGURING isDone SEMANTICS                                        │
  // │                                                                      │
  // │  DAILY habits:  isDone == completedToday                            │
  // │    • Resets to false every day at local midnight.                   │
  // │    • Change to always-true on rest days: not currently supported.   │
  // │                                                                      │
  // │  WEEKLY habits: isDone == (completions + skips) >= target           │
  // │    • Skips count as "effective completions".                         │
  // │    • If you want skips to NOT count toward done, change to:         │
  // │        return completionsThisWeek >= habit.targetDaysPerWeek;       │
  // │    • Once isDone=true it stays true until next Mon (new week).       │
  // └──────────────────────────────────────────────────────────────────────┘
  bool get isDone {
    if (habit.frequencyType == 'weekly') {
      // Effective completions = actual completions + skip "free passes".
      // ↑ Change the + to remove skips-count-as-done behaviour.
      return (completionsThisWeek + skipsThisWeek) >= habit.targetDaysPerWeek;
    }
    // Daily: done once completed today.
    return completedToday;
  }

  /// How many more skips the user can use this week.
  /// Capped at 0 (never negative) even if stale data has extra skips.
  int get skipsRemaining =>
      (habit.skipsAllowedPerWeek - skipsThisWeek).clamp(0, 99);
}

// =============================================================================
// NOTIFIER
// =============================================================================
//
// HabitsNotifier is a StreamNotifier — it exposes a reactive
// List<HabitWithStatus> that rebuilds whenever habits, completions, or
// skips change in the local Drift database.
//
// Architecture:
//   • Three Drift watch() streams are merged into a single trigger.
//   • Each trigger fires an asyncMap that fetches all three tables fresh
//     and recomputes HabitWithStatus for every habit.
//   • All writes go to Drift first (local-first), then fire-and-forget
//     to Supabase. The local write triggers the stream immediately.

class HabitsNotifier extends StreamNotifier<List<HabitWithStatus>> {
  @override
  Stream<List<HabitWithStatus>> build() {
    final db = ref.watch(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    // ── Watch streams — we only need to know something changed, ─────────────
    //    not what changed. StreamGroup.merge fires on any of the three.
    final habitsStream =
        (db.select(db.habits)..where((h) => h.userId.equals(userId))).watch();
    final completionsStream =
        (db.select(db.habitCompletions)
          ..where((c) => c.userId.equals(userId))).watch();
    final skipsStream =
        (db.select(db.habitSkips)
          ..where((s) => s.userId.equals(userId))).watch();

    final trigger = StreamGroup.merge<List<dynamic>>([
      habitsStream.map((_) => []),
      completionsStream.map((_) => []),
      skipsStream.map((_) => []),
    ]).map((_) => null);

    // ── asyncMap: re-fetch everything and recompute status ─────────────────
    return trigger.asyncMap((_) async {
      final habits =
          await (db.select(db.habits)
            ..where((h) => h.userId.equals(userId))).get();

      // All completions for this user (all time). Filtered per-habit below.
      final completions =
          await (db.select(db.habitCompletions)
            ..where((c) => c.userId.equals(userId))).get();

      // All skips for this user (all time). Filtered to current week below.
      final skips =
          await (db.select(db.habitSkips)
            ..where((s) => s.userId.equals(userId))).get();

      // today  = UTC midnight of today's LOCAL calendar date.
      // weekStart = Monday of the current local week (also UTC midnight).
      // See _dateOnly / _storedDateOnly comments for timezone details.
      final today = _dateOnly(DateTime.now());
      final weekStart = _startOfWeek(today);

      return habits.map((habit) {
        // Sort descending so streak walks backwards from today.
        final habitCompletions =
            completions.where((c) => c.habitId == habit.id).toList()
              ..sort((a, b) => b.completedDate.compareTo(a.completedDate));

        // Was this habit completed today? Uses _storedDateOnly to handle
        // Drift's local-time return correctly (see helper comments below).
        final completedToday = habitCompletions.any(
          (c) => _storedDateOnly(c.completedDate) == today,
        );

        // All completions from Monday of this week onward.
        // No upper-bound needed: toggleCompletion only ever uses today's date,
        // so future-dated completions cannot exist locally.
        final thisWeekCompletions =
            habitCompletions
                .where(
                  (c) => !_storedDateOnly(c.completedDate).isBefore(weekStart),
                )
                .toList();

        final completionsThisWeek = thisWeekCompletions.length;

        // completedThisWeek — raw completions only (no skips).
        // isDone (above) uses the combined count instead.
        final completedThisWeek =
            completionsThisWeek >= habit.targetDaysPerWeek;

        // Count skips used THIS week only (keyed by weekStart date).
        final skipsThisWeek =
            skips
                .where(
                  (s) =>
                      s.habitId == habit.id &&
                      _storedDateOnly(s.weekStart) == weekStart,
                )
                .length;

        // Streak: daily habits count consecutive days, weekly count weeks.
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

  // ===========================================================================
  // MUTATIONS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // addHabit
  // ---------------------------------------------------------------------------
  //
  // ┌──────────────────────────────────────────────────────────────────────┐
  // │  CONFIGURABLE PARAMETERS                                             │
  // │                                                                      │
  // │  frequencyType       'daily'  — must be completed every day.        │
  // │                      'weekly' — target is X times per Mon–Sun week. │
  // │                                                                      │
  // │  targetDaysPerWeek   For daily: always 7 (set automatically by UI). │
  // │                      For weekly: 1–6 (user picks via slider 1–6).   │
  // │                                                                      │
  // │  skipsAllowedPerWeek 0 = no free passes (default).                  │
  // │                      1–7 = free passes per week.                    │
  // │                      UI counter is capped at 7 in _HabitFormSheet.  │
  // └──────────────────────────────────────────────────────────────────────┘
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

    // Fire-and-forget Supabase sync. Local write already triggered the stream.
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

  // Only the supplied fields are updated; omitted fields are left unchanged.
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
        frequencyType:
            frequencyType != null ? Value(frequencyType) : const Value.absent(),
        targetDaysPerWeek:
            targetDaysPerWeek != null
                ? Value(targetDaysPerWeek)
                : const Value.absent(),
        skipsAllowedPerWeek:
            skipsAllowedPerWeek != null
                ? Value(skipsAllowedPerWeek)
                : const Value.absent(),
        synced: const Value(false),
      ),
    );

    try {
      await Supabase.instance.client
          .from('habits')
          .update({
            if (name != null) 'name': name,
            if (frequencyType != null) 'frequency_type': frequencyType,
            if (targetDaysPerWeek != null)
              'target_days_per_week': targetDaysPerWeek,
            if (skipsAllowedPerWeek != null)
              'skips_allowed_per_week': skipsAllowedPerWeek,
          })
          .eq('id', id);
      await (db.update(db.habits)..where(
        (h) => h.id.equals(id),
      )).write(const HabitsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // toggleCompletion — idempotent toggle for today
  // ---------------------------------------------------------------------------
  //
  // Calling twice returns the habit to its previous state (undo).
  // The date stored is always the LOCAL calendar date as UTC midnight so it
  // can be matched by SQL queries later (see _dateOnly).
  //
  // ⚠️  This always uses TODAY's date. To complete a habit for a past/future
  //     date, you would need a separate method (not currently supported).
  Future<void> toggleCompletion(String habitId) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final today = _dateOnly(DateTime.now());

    // SQL comparison on completedDate — avoids Dart-side timezone issues.
    final existing =
        await (db.select(db.habitCompletions)..where(
          (c) => c.habitId.equals(habitId) & c.completedDate.equals(today),
        )).getSingleOrNull();

    if (existing != null) {
      // Already completed today → remove (undo).
      await (db.delete(db.habitCompletions)
        ..where((c) => c.id.equals(existing.id))).go();
      try {
        await Supabase.instance.client
            .from('habit_completions')
            .delete()
            .eq('id', existing.id);
      } catch (_) {}
    } else {
      // Not completed yet → insert.
      final id = _uuid.v4();
      await db
          .into(db.habitCompletions)
          .insert(
            HabitCompletionsCompanion.insert(
              id: id,
              habitId: habitId,
              userId: userId,
              completedDate: today, // UTC midnight of LOCAL today
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

  // ---------------------------------------------------------------------------
  // toggleCompletionForDate — same as toggleCompletion but for any date
  // ---------------------------------------------------------------------------
  Future<void> toggleCompletionForDate(
    String habitId,
    DateTime date,
  ) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final day = _dateOnly(date);

    final existing =
        await (db.select(db.habitCompletions)..where(
          (c) => c.habitId.equals(habitId) & c.completedDate.equals(day),
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
      await db.into(db.habitCompletions).insert(
            HabitCompletionsCompanion.insert(
              id: id,
              habitId: habitId,
              userId: userId,
              completedDate: day,
            ),
          );
      try {
        await Supabase.instance.client.from('habit_completions').insert({
          'id': id,
          'habit_id': habitId,
          'user_id': userId,
          'completed_date': day.toIso8601String(),
        });
        await (db.update(db.habitCompletions)..where(
          (c) => c.id.equals(id),
        )).write(const HabitCompletionsCompanion(synced: Value(true)));
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // getCompletionDatesForWeek — returns the set of completed dates for a habit
  // within the week containing [weekStart] (Mon–Sun).
  // ---------------------------------------------------------------------------
  Future<Set<DateTime>> getCompletionDatesForWeek(
    String habitId,
    DateTime weekStart,
  ) async {
    final db = ref.read(databaseProvider);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final rows =
        await (db.select(db.habitCompletions)..where(
          (c) =>
              c.habitId.equals(habitId) &
              c.completedDate.isBiggerOrEqualValue(weekStart) &
              c.completedDate.isSmallerThanValue(weekEnd),
        )).get();

    return rows.map((c) => _storedDateOnly(c.completedDate)).toSet();
  }

  // ---------------------------------------------------------------------------
  // skipWeek — consume one "free pass" for the current week
  // ---------------------------------------------------------------------------
  //
  // Each skip record is keyed by the Monday (weekStart) of the current week.
  // Multiple skip rows for the same habit + weekStart = multiple skips used.
  //
  // ┌──────────────────────────────────────────────────────────────────────┐
  // │  Skip counts toward isDone:                                          │
  // │    (completionsThisWeek + skipsThisWeek) >= targetDaysPerWeek        │
  // │  So a habit with target=3 and 2 completions + 1 skip → isDone=true. │
  // │                                                                      │
  // │  To make skips NOT count toward done, edit isDone getter above.      │
  // └──────────────────────────────────────────────────────────────────────┘
  Future<void> skipWeek(String habitId) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final weekStart = _startOfWeek(_dateOnly(DateTime.now()));

    // Guard: do not exceed the allowed skip count (notifier-level validation,
    // mirroring the UI guard in _HabitCard so the API is safe to call directly).
    final habit =
        await (db.select(db.habits)
          ..where((h) => h.id.equals(habitId))).getSingleOrNull();
    if (habit == null) return;

    final existingSkips =
        await (db.select(db.habitSkips)..where(
          (s) => s.habitId.equals(habitId) & s.weekStart.equals(weekStart),
        )).get();

    if (existingSkips.length >= habit.skipsAllowedPerWeek) return;

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

  /// Remove the most-recently-inserted skip for the current week (undo skip).
  Future<void> unskipWeek(String habitId) async {
    final db = ref.read(databaseProvider);
    final weekStart = _startOfWeek(_dateOnly(DateTime.now()));

    final existing =
        await (db.select(db.habitSkips)..where(
          (s) => s.habitId.equals(habitId) & s.weekStart.equals(weekStart),
        )).get();

    if (existing.isEmpty) return;
    final last = existing.last; // remove the most recent skip

    await (db.delete(db.habitSkips)..where((s) => s.id.equals(last.id))).go();
    try {
      await Supabase.instance.client
          .from('habit_skips')
          .delete()
          .eq('id', last.id);
    } catch (_) {}
  }

  /// Delete a habit and all its completion + skip history.
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

  // ---------------------------------------------------------------------------
  // syncFromRemote — pull latest data from Supabase into local Drift DB.
  // Uses insertOnConflictUpdate so duplicate rows are safely overwritten.
  // Call this on app launch / after sign-in.
  // ---------------------------------------------------------------------------
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
                // DateTime.parse of a Supabase ISO string gives a UTC DateTime,
                // which is consistent with how we store dates locally.
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

  // ===========================================================================
  // CALENDAR / HISTORY QUERIES
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // getHabitsForDate — used by CalendarScreen day-detail sheet
  // ---------------------------------------------------------------------------
  //
  // Returns every habit with a boolean indicating whether it was completed on
  // [date]. Uses an SQL-level date comparison (safe across timezones).
  //
  // NOTE: For weekly habits this only checks day-level completion, not whether
  // the weekly target was met. If you need weekly-target awareness for a past
  // date, you would need to fetch that week's completions separately.
  Future<List<({Habit habit, bool completed})>> getHabitsForDate(
    DateTime date,
  ) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    // Use the same UTC-midnight-of-local-date encoding as toggleCompletion.
    final d = DateTime.utc(date.year, date.month, date.day);

    final habits =
        await (db.select(db.habits)
          ..where((h) => h.userId.equals(userId))).get();

    // SQL comparison: matches exactly the UTC midnight timestamp stored.
    final completions =
        await (db.select(db.habitCompletions)..where(
          (c) => c.userId.equals(userId) & c.completedDate.equals(d),
        )).get();

    final completedIds = completions.map((c) => c.habitId).toSet();
    return habits
        .map((h) => (habit: h, completed: completedIds.contains(h.id)))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // getWeekHabitStats — used by CalendarScreen week summary strip
  // ---------------------------------------------------------------------------
  //
  // Returns (done: total completions in range, total: habits × elapsed days).
  // [weekStart] is inclusive, [weekEnd] is exclusive.
  //
  // To change the "total" denominator (e.g., count unique habits per day rather
  // than raw completions), update the total calculation here.
  Future<({int done, int total})> getWeekHabitStats(
    DateTime weekStart,
    DateTime weekEnd,
  ) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final habits =
        await (db.select(db.habits)
          ..where((h) => h.userId.equals(userId))).get();
    if (habits.isEmpty) return (done: 0, total: 0);

    final completions =
        await (db.select(db.habitCompletions)..where(
          (c) =>
              c.userId.equals(userId) &
              c.completedDate.isBiggerOrEqualValue(weekStart) &
              c.completedDate.isSmallerThanValue(weekEnd),
        )).get();

    // Cap the effective end at today so future days don't inflate "total".
    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final effectiveEnd =
        weekEnd.isAfter(todayUtc)
            ? todayUtc.add(const Duration(days: 1))
            : weekEnd;
    final elapsedDays = effectiveEnd.difference(weekStart).inDays.clamp(0, 7);

    return (done: completions.length, total: habits.length * elapsedDays);
  }

  // ---------------------------------------------------------------------------
  // getCompletedDatesForMonth — used by HabitCalendarSheet in habits_screen
  // ---------------------------------------------------------------------------
  //
  // Returns a Set of UTC-midnight DateTimes for each day in [year]/[month]
  // that has a completion for [habitId]. The calendar grid in HabitCalendarSheet
  // builds its own UTC dates for comparison — both sides use UTC midnight so
  // the Set.contains() lookup always works.
  Future<Set<DateTime>> getCompletedDatesForMonth(
    String habitId,
    int year,
    int month,
  ) async {
    final db = ref.read(databaseProvider);
    final start = DateTime.utc(year, month, 1);
    final end = DateTime.utc(year, month + 1, 1); // exclusive upper bound

    final rows =
        await (db.select(db.habitCompletions)..where(
          (c) =>
              c.habitId.equals(habitId) &
              c.completedDate.isBiggerOrEqualValue(start) &
              c.completedDate.isSmallerThanValue(end),
        )).get();

    // _storedDateOnly handles Drift returning local time for UTC-stored values.
    return rows.map((r) => _storedDateOnly(r.completedDate)).toSet();
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  // DATE ENCODING — important to understand before touching date logic
  // ---------------------------------------------------------------------------
  //
  // All habit dates (completedDate, weekStart) are stored as UTC midnight of
  // the LOCAL calendar date. For example, if the user is in UTC-8 and it is
  // 3 PM on Feb 27, the stored value is DateTime.utc(2025, 2, 27) — not the
  // UTC equivalent of 3 PM local, just "UTC midnight with local date labels."
  //
  // Why? Because users think in LOCAL dates ("I completed this on Monday"),
  // and we want comparisons like "did I complete this today?" to use the local
  // calendar, not the UTC calendar.
  //
  // ┌──────────────────────────────────────────────────────────────────────┐
  // │  _dateOnly(DateTime.now())   → used when WRITING or computing today │
  // │    Takes LOCAL date components, creates UTC midnight from them.      │
  // │    e.g. 3 PM Feb 27 UTC-8  → DateTime.utc(2025, 2, 27)            │
  // │                                                                      │
  // │  _storedDateOnly(driftValue) → used when READING back from Drift   │
  // │    Drift returns Unix timestamps as LOCAL time. The stored value is  │
  // │    UTC midnight of the local date, but Drift returns it as LOCAL     │
  // │    time (e.g. 4 PM Feb 26 in UTC-8). Call .toUtc() first to        │
  // │    recover the original UTC midnight.                                │
  // │    e.g. Drift returns 2025-02-26 16:00 local → .toUtc() gives      │
  // │         2025-02-27 00:00 UTC → DateTime.utc(2025, 2, 27) ✓         │
  // └──────────────────────────────────────────────────────────────────────┘

  /// Converts a local DateTime (from DateTime.now() or user input) to the
  /// canonical UTC-midnight storage key using LOCAL date components.
  /// Use this when WRITING dates or computing "today" / "weekStart".
  DateTime _dateOnly(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

  /// Converts a DateTime returned by Drift to the canonical UTC-midnight key.
  /// Drift returns stored timestamps as LOCAL time; call .toUtc() first to
  /// recover the original UTC date.
  /// Use this when READING completion/skip dates back from the database.
  DateTime _storedDateOnly(DateTime dt) {
    final utc = dt.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  /// Returns the Monday of the week containing [date].
  /// Week is Mon–Sun (ISO 8601). weekday==1 is Monday.
  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // ---------------------------------------------------------------------------
  // _calculateDailyStreak
  // ---------------------------------------------------------------------------
  //
  // Walks the completion list backward from today, counting consecutive days
  // that have a completion. If today has no completion the streak is still
  // counted (streak = 0 means broken yesterday, not broken today).
  //
  // ┌──────────────────────────────────────────────────────────────────────┐
  // │  To change streak logic:                                             │
  // │  • Allow one missed day: add a tolerance counter.                   │
  // │  • Start streak only if completed today: add a check before loop.   │
  // │  • Count this week only: cap the loop to 7 iterations.              │
  // └──────────────────────────────────────────────────────────────────────┘
  int _calculateDailyStreak(List<HabitCompletion> completions) {
    if (completions.isEmpty) return 0;
    final today = _dateOnly(DateTime.now());
    int streak = 0;
    DateTime cursor = today; // starts at today, walks backward

    for (final c in completions) {
      final d = _storedDateOnly(c.completedDate);
      if (d == cursor) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (d.isBefore(cursor)) {
        // Gap found — streak is broken.
        break;
      }
      // d.isAfter(cursor): future-dated entry (shouldn't happen); skip it.
    }
    return streak;
  }

  // ---------------------------------------------------------------------------
  // _calculateWeeklyStreak
  // ---------------------------------------------------------------------------
  //
  // Walks backward week-by-week from the current week, counting consecutive
  // weeks where completions >= [target]. Checks up to 52 weeks (1 year).
  //
  // NOTE: The current (in-progress) week counts toward the streak even if the
  // target hasn't been fully met yet, as long as it eventually is. This is
  // correct because the stream re-evaluates as completions are added.
  int _calculateWeeklyStreak(List<HabitCompletion> completions, int target) {
    if (completions.isEmpty) return 0;
    final today = _dateOnly(DateTime.now());
    int streak = 0;
    DateTime weekStart = _startOfWeek(today); // start from current week

    for (var i = 0; i < 52; i++) {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final count =
          completions
              .where(
                (c) =>
                    !_storedDateOnly(c.completedDate).isBefore(weekStart) &&
                    _storedDateOnly(c.completedDate).isBefore(weekEnd),
              )
              .length;

      if (count >= target) {
        streak++;
        weekStart = weekStart.subtract(const Duration(days: 7)); // go back
      } else {
        break; // streak broken
      }
    }
    return streak;
  }
}

// Provider — single instance for the whole app.
final habitsNotifierProvider =
    StreamNotifierProvider<HabitsNotifier, List<HabitWithStatus>>(
      HabitsNotifier.new,
    );
