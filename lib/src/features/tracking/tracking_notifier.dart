// tracking_notifier.dart — Tracking logic for unwanted habits (alcohol,
// nicotine, etc.): create/edit/delete substances, log occurrences, sync.
//
// Data model:
//   TrackedSubstanceWithStats — pairs a TrackedSubstance row with computed
//     todayTotal/weekTotal, summed from SubstanceLogs.amount
//
// trackingNotifierProvider (StreamNotifierProvider<List<TrackedSubstanceWithStats>>):
//   build()          — streams substances + today/week totals from SQLite
//   addSubstance()   — creates a new tracked substance locally, then Supabase
//   updateSubstance()— edits name/unit/limits locally, then Supabase
//   deleteSubstance()— deletes a substance and all its logs locally, then Supabase
//   logEntry()       — records one occurrence (default amount 1.0) locally,
//                      then Supabase
//   deleteLog()      — removes a single logged occurrence locally, then Supabase
//   pushUnsyncedChanges() / syncFromRemote() — same bootstrap pattern as the
//                      other notifiers, called from main.dart on login
//
// Write strategy (local-first), same as habits/nutrition:
//   SQLite is written first so the UI is instant. Supabase sync is
//   fire-and-forget in try/catch — failures are silent, data stays local.
//
// Connections:
//   database_provider.dart  — ref.watch(databaseProvider) for SQLite access
//   tracking_screen.dart    — the UI for logging and viewing substances
//   main.dart                — calls pushUnsyncedChanges()/syncFromRemote() on login

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:async/async.dart';
import '../../database/database_provider.dart';
import '../../database/db.dart';

const _uuid = Uuid();

/// A tracked substance (e.g. "Alcohol") paired with how much has been
/// logged today and so far this week (Mon–Sun, local time).
class TrackedSubstanceWithStats {
  final TrackedSubstance substance;
  final double todayTotal;
  final double weekTotal;

  const TrackedSubstanceWithStats({
    required this.substance,
    required this.todayTotal,
    required this.weekTotal,
  });

  bool get isOverDailyLimit =>
      substance.dailyLimit != null && todayTotal > substance.dailyLimit!;
  bool get isOverWeeklyLimit =>
      substance.weeklyLimit != null && weekTotal > substance.weeklyLimit!;
}

class TrackingNotifier extends StreamNotifier<List<TrackedSubstanceWithStats>> {
  @override
  Stream<List<TrackedSubstanceWithStats>> build() {
    final db = ref.watch(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    // Only a cheap COUNT is watched (not the full rows), same trick used by
    // nutrition_notifier — Drift's watch() invalidates per-table regardless
    // of selected columns, so this still fires on every write without
    // materializing full history just to discard it.
    final substancesStream =
        (db.selectOnly(db.trackedSubstances)
              ..addColumns([db.trackedSubstances.id.count()])
              ..where(db.trackedSubstances.userId.equals(userId)))
            .watchSingle();

    final logsStream =
        (db.selectOnly(db.substanceLogs)
              ..addColumns([db.substanceLogs.id.count()])
              ..where(db.substanceLogs.userId.equals(userId)))
            .watchSingle();

    final trigger = StreamGroup.merge<List<dynamic>>([
      substancesStream.map((_) => []),
      logsStream.map((_) => []),
    ]).map((_) => null);

    return trigger.asyncMap((_) => _computeStats(db, userId));
  }

  Future<List<TrackedSubstanceWithStats>> _computeStats(
    AppDatabase db,
    String userId,
  ) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final startOfWeek = startOfDay.subtract(Duration(days: now.weekday - 1));

    final substances =
        await (db.select(db.trackedSubstances)
          ..where((s) => s.userId.equals(userId))
          ..orderBy([(s) => OrderingTerm.asc(s.createdAt)])).get();

    final weekLogs =
        await (db.select(db.substanceLogs)..where(
          (l) =>
              l.userId.equals(userId) &
              l.loggedAt.isBiggerOrEqualValue(startOfWeek) &
              l.loggedAt.isSmallerThanValue(endOfDay),
        )).get();

    return substances.map((substance) {
      double today = 0, week = 0;
      for (final log in weekLogs) {
        if (log.substanceId != substance.id) continue;
        week += log.amount;
        if (!log.loggedAt.isBefore(startOfDay)) today += log.amount;
      }
      return TrackedSubstanceWithStats(
        substance: substance,
        todayTotal: today,
        weekTotal: week,
      );
    }).toList();
  }

  Future<void> addSubstance({
    required String name,
    String unitLabel = 'drink',
    double? dailyLimit,
    double? weeklyLimit,
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final id = _uuid.v4();

    await db
        .into(db.trackedSubstances)
        .insert(
          TrackedSubstancesCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            unitLabel: Value(unitLabel),
            dailyLimit: Value(dailyLimit),
            weeklyLimit: Value(weeklyLimit),
          ),
        );

    try {
      await Supabase.instance.client.from('tracked_substances').insert({
        'id': id,
        'user_id': userId,
        'name': name,
        'unit_label': unitLabel,
        'daily_limit': dailyLimit,
        'weekly_limit': weeklyLimit,
        'created_at': DateTime.now().toIso8601String(),
      });
      await (db.update(db.trackedSubstances)..where(
        (s) => s.id.equals(id),
      )).write(const TrackedSubstancesCompanion(synced: Value(true)));
    } catch (_) {}
  }

  Future<void> updateSubstance({
    required String id,
    required String name,
    required String unitLabel,
    double? dailyLimit,
    double? weeklyLimit,
  }) async {
    final db = ref.read(databaseProvider);

    await (db.update(db.trackedSubstances)..where((s) => s.id.equals(id)))
        .write(
          TrackedSubstancesCompanion(
            name: Value(name),
            unitLabel: Value(unitLabel),
            dailyLimit: Value(dailyLimit),
            weeklyLimit: Value(weeklyLimit),
            synced: const Value(false),
          ),
        );

    try {
      await Supabase.instance.client
          .from('tracked_substances')
          .update({
            'name': name,
            'unit_label': unitLabel,
            'daily_limit': dailyLimit,
            'weekly_limit': weeklyLimit,
          })
          .eq('id', id);
      await (db.update(db.trackedSubstances)..where(
        (s) => s.id.equals(id),
      )).write(const TrackedSubstancesCompanion(synced: Value(true)));
    } catch (_) {}
  }

  Future<void> deleteSubstance(String id) async {
    final db = ref.read(databaseProvider);

    await (db.delete(db.substanceLogs)
      ..where((l) => l.substanceId.equals(id))).go();
    await (db.delete(db.trackedSubstances)..where((s) => s.id.equals(id))).go();

    try {
      await Supabase.instance.client
          .from('substance_logs')
          .delete()
          .eq('substance_id', id);
      await Supabase.instance.client
          .from('tracked_substances')
          .delete()
          .eq('id', id);
    } catch (_) {}
  }

  Future<void> logEntry(String substanceId, {double amount = 1.0}) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final id = _uuid.v4();

    await db
        .into(db.substanceLogs)
        .insert(
          SubstanceLogsCompanion.insert(
            id: id,
            substanceId: substanceId,
            userId: userId,
            amount: Value(amount),
          ),
        );

    try {
      await Supabase.instance.client.from('substance_logs').insert({
        'id': id,
        'substance_id': substanceId,
        'user_id': userId,
        'amount': amount,
        'logged_at': DateTime.now().toIso8601String(),
      });
      await (db.update(db.substanceLogs)..where(
        (l) => l.id.equals(id),
      )).write(const SubstanceLogsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  Future<void> deleteLog(String logId) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.substanceLogs)..where((l) => l.id.equals(logId))).go();

    try {
      await Supabase.instance.client
          .from('substance_logs')
          .delete()
          .eq('id', logId);
    } catch (_) {}
  }

  /// Returns today's logs for a substance, most recent first — used to let
  /// a user undo a specific entry rather than only the running total.
  Future<List<SubstanceLog>> getTodaysLogs(String substanceId) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (db.select(db.substanceLogs)
          ..where(
            (l) =>
                l.substanceId.equals(substanceId) &
                l.loggedAt.isBiggerOrEqualValue(startOfDay) &
                l.loggedAt.isSmallerThanValue(endOfDay),
          )
          ..orderBy([(l) => OrderingTerm.desc(l.loggedAt)]))
        .get();
  }

  Future<void> pushUnsyncedChanges() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final unsyncedSubstances =
        await (db.select(db.trackedSubstances)..where(
          (s) => s.userId.equals(userId) & s.synced.equals(false),
        )).get();
    for (final s in unsyncedSubstances) {
      try {
        await Supabase.instance.client.from('tracked_substances').upsert({
          'id': s.id,
          'user_id': s.userId,
          'name': s.name,
          'unit_label': s.unitLabel,
          'daily_limit': s.dailyLimit,
          'weekly_limit': s.weeklyLimit,
          'created_at': s.createdAt.toIso8601String(),
        });
        await (db.update(db.trackedSubstances)..where(
          (t) => t.id.equals(s.id),
        )).write(const TrackedSubstancesCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('[Tracking] pushUnsyncedChanges substance error: $e');
      }
    }

    final unsyncedLogs =
        await (db.select(db.substanceLogs)..where(
          (l) => l.userId.equals(userId) & l.synced.equals(false),
        )).get();
    for (final l in unsyncedLogs) {
      try {
        await Supabase.instance.client.from('substance_logs').upsert({
          'id': l.id,
          'substance_id': l.substanceId,
          'user_id': l.userId,
          'amount': l.amount,
          'logged_at': l.loggedAt.toIso8601String(),
        });
        await (db.update(db.substanceLogs)..where(
          (t) => t.id.equals(l.id),
        )).write(const SubstanceLogsCompanion(synced: Value(true)));
      } catch (e) {
        debugPrint('[Tracking] pushUnsyncedChanges log error: $e');
      }
    }
  }

  Future<void> syncFromRemote() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final substances = await Supabase.instance.client
          .from('tracked_substances')
          .select()
          .eq('user_id', userId);
      for (final s in substances as List) {
        await db
            .into(db.trackedSubstances)
            .insertOnConflictUpdate(
              TrackedSubstancesCompanion.insert(
                id: s['id'] as String,
                userId: s['user_id'] as String,
                name: s['name'] as String,
                unitLabel: Value(s['unit_label'] as String? ?? 'drink'),
                dailyLimit: Value((s['daily_limit'] as num?)?.toDouble()),
                weeklyLimit: Value((s['weekly_limit'] as num?)?.toDouble()),
                createdAt: Value(DateTime.parse(s['created_at'] as String)),
                synced: const Value(true),
              ),
            );
      }

      final logs = await Supabase.instance.client
          .from('substance_logs')
          .select()
          .eq('user_id', userId);
      for (final l in logs as List) {
        await db
            .into(db.substanceLogs)
            .insertOnConflictUpdate(
              SubstanceLogsCompanion.insert(
                id: l['id'] as String,
                substanceId: l['substance_id'] as String,
                userId: l['user_id'] as String,
                amount: Value((l['amount'] as num).toDouble()),
                loggedAt: Value(DateTime.parse(l['logged_at'] as String)),
                synced: const Value(true),
              ),
            );
      }
    } catch (_) {}
  }
}

final trackingNotifierProvider =
    StreamNotifierProvider<TrackingNotifier, List<TrackedSubstanceWithStats>>(
      TrackingNotifier.new,
    );
