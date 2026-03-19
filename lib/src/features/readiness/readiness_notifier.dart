// readiness_notifier.dart — Readiness scoring, check-ins, and learning engine.
//
// ═══════════════════════════════════════════════════════════════
// SCIENCE BASIS (sources: peer-reviewed studies 2015–2025)
// ═══════════════════════════════════════════════════════════════
//
// SLEEP — Van Dongen, Maislin, Mullington & Dinges (UPenn, SLEEP 2003):
//   - 6h/night for 14 days ≡ 2 full nights of zero sleep (non-linear accumulation)
//   - Subjects were largely unaware of their own impairment
//   - Scoring uses pow(8-h, 1.3) * 3.5 to reflect the non-linear curve:
//       8h = 0 pts  |  7h = -3.5  |  6h = -8.6  |  5h = -14.6  |  4h = -21 (capped)
//   - 7-day rolling sleep debt added on top: each cumulative hour below 8h/night
//     compounds further (non-linear) — Belenky et al.; PMC 2022 dynamics-of-recovery
//
// SLEEP QUALITY — REM architecture data (Sleep Medicine Reviews meta-analysis 2024):
//   - Alcohol at 0.5 g/kg cuts REM by 11.3 min and delays onset by 18 min
//   - Quality 1-5 maps to ±8 pts; compounds with hours to reflect REM interaction
//
// ALCOHOL — Ogeil et al. / Sleep Medicine Reviews 2024 (27-study meta-analysis):
//   - Disruption begins at ~2 standard drinks (0.50 g/kg)
//   - REM severely fragmented at 4+ drinks
//   - Cortisol elevated all next morning even at BAC=0
//   - Carryover: 65% (cortisol + REM deficit persist into next day)
//   - Max same-day impact: 15 pts; next-day carryover: 9.75 pts at full impact
//
// CANNABIS/THC — Manning et al. / Cannabis and Cannabinoid Research 2023:
//   - Only 3.5% of next-day performance tests showed significant impairment
//   - Carryover: 30% (much lower than alcohol)
//   - Heavy chronic use carries higher residual; captured by learnedImpact over time
//
// SUGAR — Mantantzis et al. / Neuroscience & Biobehavioral Reviews 2019 (31 studies)
//         + gut-brain axis / microbiome research (2020–2024):
//   - No evidence for sugar rush in healthy adults
//   - Strong evidence for crash: fatigue +30–60 min, resolves ~2–3 hours
//   - Day-after inflammation: single high-glycemic meal spikes CRP + cytokines;
//     low-grade inflammation persists 1–2 days (joint stiffness, malaise)
//   - Dopamine dip 24–48h later: brain down-regulates dopamine receptors
//     after a large dopamine release → low motivation, irritability, anhedonia
//   - SWS disruption: high sugar intake linked to lighter, fragmented sleep
//     and reduced slow-wave sleep; morning grogginess even after 8h
//   - Gut microbiome: flora shifts begin within 24h; sugar-loving bacteria
//     overgrowth produces brain-fog byproducts persisting several days
//   - Day-1 carryover: 55% (inflammation + dopamine dip peak)
//   - Day-2 carryover: 25% (lingering inflammation + microbiome)
//   - SWS penalty applied to carryover: −4 pts (metabolic overnight disruption)
//
// CAFFEINE — Randall et al. SLEEP 2024 (randomized crossover):
//   - 1–2 cups: alertness +4 pts (adenosine antagonism)
//   - 3 cups: neutral performance point
//   - 4+ cups above 3: -3 pts/cup (anxiety, cortisol spike — Lane et al. UKentucky)
//   - Half-life 4–6h (CYP1A2 dependent): afternoon caffeine disrupts tonight's sleep
//   - Evening window caffeine (logged in afternoon/evening CI): 1.5× multiplier
//
// NICOTINE — Westminster Research / Mendrek et al. PMC 2013:
//   - Withdrawal begins 2–4h after last cigarette (half-life ~2h)
//   - Carryover: 40% (withdrawal cycle affects next-morning cortisol baseline)
//
// PSILOCYBIN MICRODOSE — Szigeti/Erritzoe three double-blind RCTs 2025:
//   - One confirmed finding: increased originality in divergent thinking
//   - No confirmed energy or mood enhancement in blinded conditions
//   - No hangover / carryover at microdose levels: 0%
//
// STRESS — HPA axis / cortisol literature (elevated IL-6, CRP):
//   - Stress level 4–5 elevates cortisol measurably; partial carryover ~67%
//   - Penalty: -3 pts per level above 3; carryover: -2 pts per level ≥4
//
// ═══════════════════════════════════════════════════════════════
// SCORING FORMULA
// ═══════════════════════════════════════════════════════════════
//
//   Base:               70.0
//   Sleep hours:        -pow(8-h, 1.3) * 3.5  (non-linear; capped -20)
//   Sleep quality:      (quality - 3) * 4.0   (±8 pts, 1–5 scale)
//   Sleep debt (7-day): -pow(totalDebtHours, 1.2) * 0.8  (capped -15)
//   Caffeine 1–2 cups:  +3.0 (alertness boost)
//   Caffeine 4+ cups:   -3.0 per cup above 3; ×1.5 if afternoon/evening window
//   Stress > 3:         -3.0 per level above 3
//   Energy/mood:        ±1.5 / ±1.0 per point from neutral
//   Substances today:   ±(learnedImpact ?? defaultImpact) / 10 * 15 per event
//   Carryover delta:    substance-specific rate * yesterday's same-day delta
//                       + sleep debt carryover
//                       + stress carryover
//
// ═══════════════════════════════════════════════════════════════
// LEARNING ENGINE
// ═══════════════════════════════════════════════════════════════
//
//   After user rates their day (0–10), observed impact is computed
//   direction-aware: negative substances increase impact if next-day score < 70,
//   positive substances increase impact if next-day score > 70.
//   Bayesian blend weight: (n / 20.0).clamp(0.0, 0.7)
//   Reaches full trust of observed data at n=20 observations.
//
// ═══════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════
//
//   userSubstancesProvider  — StreamNotifierProvider<List<UserSubstance>>
//   substanceLogsProvider   — StreamNotifierProvider<List<SubstanceLog>>
//   checkInsProvider        — StreamNotifierProvider<List<ReadinessCheckIn>>
//   readinessProvider       — StreamNotifierProvider<List<DailyReadinessData>>
//
// Connections:
//   db.dart                — all four readiness tables
//   database_provider.dart — databaseProvider
//   readiness_screen.dart  — consumes all four providers

import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../database/database_provider.dart';
import '../../database/db.dart';

const _uuid = Uuid();

// ─────────────────────────────────────────────────────────────────────────────
// Science constants — keyed to the literature cited in the header.
// ─────────────────────────────────────────────────────────────────────────────

// Baseline
const double _kBase = 70.0;

// Sleep — Van Dongen et al. (SLEEP 2003); Belenky et al.
const double _kSleepDebtExp         = 1.3;   // non-linear exponent
const double _kSleepDebtMult        = 3.5;   // pts-per-hour-of-debt
const double _kSleepFullRestBonus   = 20.0;  // ≥8 h bonus cap
const double _kSleepPenaltyCap      = 20.0;
const double _kSleepQualityMult     = 4.0;   // Sleep Medicine Reviews 2024; ±8 pts over 1–5 scale
const double _kRollingDebtExp       = 1.2;   // Belenky / PMC 2022 dynamics
const double _kRollingDebtMult      = 0.8;
const double _kRollingDebtCap       = 15.0;
const double _kCarryoverSleepFrac   = 0.5;   // 50 % of last-night penalty bleeds into today
const double _kCarryoverSleepCap    = 10.0;
const int    _kSleepDebtLookbackDays = 7;
const int    _kSleepDebtMinDays     = 2;     // need ≥2 data points to penalise

// Stress — HPA axis / cortisol literature (IL-6, CRP)
const int    _kStressPenaltyThreshold  = 3;  // levels above this are penalised
const double _kStressPenaltyPerLevel   = 3.0;
const int    _kStressCarryoverThreshold = 4;
const double _kStressCarryoverPerLevel  = 2.0; // ~67 % cortisol carryover

// Caffeine — Randall et al. SLEEP 2024; Lane et al. UKentucky
const int    _kCaffeineBoostMaxCups    = 2;
const double _kCaffeineBoost           = 3.0;
const int    _kCaffeineNeutralCups     = 3;
const double _kCaffeinePenaltyPerCup   = 3.0;
const double _kCaffeineTimingMult      = 1.5; // afternoon/evening × 1.5

// Mood / energy — self-report calibration
const double _kEnergyMult = 1.5;
const double _kMoodMult   = 1.0;

// Substance scaling — (impact / 10) × 15 maps 0–10 impact to 0–15 score pts
const double _kSubstanceScaleDenominator = 10.0;
const double _kSubstanceScaleMax         = 15.0;

// Sugar — Mantantzis et al. (2019) + gut-brain axis research 2020–2024
const double _kSugarSwsPenalty = 4.0;   // hidden SWS disruption carryover
const double _kSugarDay2Rate   = 0.25;  // day-2: lingering inflammation + microbiome fog

// Learning engine — Bayesian blend
const int    _kLearningFullTrustN        = 20;   // n=20 → max blend weight
const double _kLearningMaxBlend          = 0.7;
const double _kLearningObservedDeltaCap  = 30.0;
const double _kLearningObservedImpactMin = 1.0;
const double _kLearningObservedImpactMax = 10.0;

// ─────────────────────────────────────────────────────────────────────────────
// Science-backed default substance library seeded for new users.
// defaultImpact = population-level estimate from literature.
// learnedImpact overrides this once the user has enough personal data.
// ─────────────────────────────────────────────────────────────────────────────
const List<_SubstanceDefault> _defaultSubstances = [
  _SubstanceDefault('alcohol',          'negative', 7.0),
  _SubstanceDefault('weed',             'negative', 3.0),
  _SubstanceDefault('sugar spike',      'negative', 3.0),
  _SubstanceDefault('nicotine',         'negative', 4.0),
  _SubstanceDefault('psilocybin (md)',  'positive', 2.0),
  _SubstanceDefault('cbd',              'positive', 2.0),
];

class _SubstanceDefault {
  final String name;
  final String direction;
  final double defaultImpact;
  const _SubstanceDefault(this.name, this.direction, this.defaultImpact);
}

// ─────────────────────────────────────────────────────────────────────────────
// Science-backed per-substance carryover rates.
// Source: REM disruption persistence, cortisol timelines, metabolite data.
// ─────────────────────────────────────────────────────────────────────────────
double _substanceCarryoverRate(String name) {
  switch (name.toLowerCase().trim()) {
    case 'alcohol':
      return 0.65; // cortisol + REM deficit persist into next morning
    case 'weed':
    case 'cannabis':
    case 'thc':
    case 'marijuana':
      return 0.30; // minimal next-day impairment (Manning et al. 2023)
    case 'sugar spike':
    case 'sugar':
      return 0.55; // day-after inflammation + dopamine dip (day-1 rate)
                   // day-2 rate (0.25) handled separately in carryover calc
    case 'nicotine':
    case 'cigarettes':
    case 'smoking':
    case 'vaping':
      return 0.40; // withdrawal cycle; cortisol disruption
    case 'psilocybin (md)':
    case 'psilocybin':
    case 'shrooms':
    case 'microdose':
      return 0.00; // no known hangover at microdose levels
    case 'cbd':
      return 0.00;
    default:
      return 0.50; // conservative default for unknown substances
  }
}

// ---------------------------------------------------------------------------
// Check-in window helpers
// ---------------------------------------------------------------------------

enum CheckInWindow { morning, afternoon, evening }

extension CheckInWindowX on CheckInWindow {
  String get value => name; // 'morning' | 'afternoon' | 'evening'
}

CheckInWindow currentWindow() {
  final h = DateTime.now().hour;
  if (h >= 5 && h < 12) return CheckInWindow.morning;
  if (h >= 12 && h < 18) return CheckInWindow.afternoon;
  return CheckInWindow.evening;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
DateTime _dayEnd(DateTime d)   => d.add(const Duration(hours: 23, minutes: 59));

String? _userId() => Supabase.instance.client.auth.currentUser?.id;

// ---------------------------------------------------------------------------
// UserSubstances notifier
// ---------------------------------------------------------------------------

class UserSubstancesNotifier extends StreamNotifier<List<UserSubstance>> {
  @override
  Stream<List<UserSubstance>> build() {
    final db = ref.watch(databaseProvider);
    final uid = _userId();
    if (uid == null) return const Stream.empty();
    return (db.select(db.userSubstances)
          ..where((t) => t.userId.equals(uid))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Seeds the science-backed default substances for new users.
  /// Called once on first login if the library is empty.
  Future<void> seedDefaultsIfEmpty() async {
    debugPrint('[Readiness:UserSubstances] seedDefaultsIfEmpty — checking');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;

    final existing = await (db.select(db.userSubstances)
          ..where((t) => t.userId.equals(uid)))
        .get();
    if (existing.isNotEmpty) {
      debugPrint('[Readiness:UserSubstances] seedDefaultsIfEmpty — already seeded (${existing.length} substances)');
      return;
    }
    debugPrint('[Readiness:UserSubstances] seedDefaultsIfEmpty — seeding ${_defaultSubstances.length} defaults');

    for (final s in _defaultSubstances) {
      final id = _uuid.v4();
      await db.into(db.userSubstances).insert(
            UserSubstancesCompanion.insert(
              id: id,
              userId: uid,
              name: s.name,
              direction: Value(s.direction),
              defaultImpact: Value(s.defaultImpact),
            ),
          );
      try {
        await Supabase.instance.client.from('user_substances').insert({
          'id': id,
          'user_id': uid,
          'name': s.name,
          'direction': s.direction,
          'default_impact': s.defaultImpact,
        });
      } catch (e) { debugPrint('[Readiness] seedDefaults sync error: $e'); }
    }
  }

  Future<void> addSubstance({
    required String name,
    required String direction,
    required double defaultImpact,
  }) async {
    debugPrint('[Readiness:UserSubstances] addSubstance — name=$name direction=$direction impact=$defaultImpact');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    final id = _uuid.v4();
    final trimmed = name.trim().toLowerCase();
    await db.into(db.userSubstances).insert(
          UserSubstancesCompanion.insert(
            id: id,
            userId: uid,
            name: trimmed,
            direction: Value(direction),
            defaultImpact: Value(defaultImpact),
          ),
        );
    try {
      await Supabase.instance.client.from('user_substances').insert({
        'id': id,
        'user_id': uid,
        'name': trimmed,
        'direction': direction,
        'default_impact': defaultImpact,
      });
    } catch (e) { debugPrint('[Readiness] addSubstance sync error: $e'); }
  }

  Future<void> updateSubstance(
    String id, {
    double? defaultImpact,
    String? direction,
  }) async {
    debugPrint('[Readiness:UserSubstances] updateSubstance — id=$id impact=$defaultImpact direction=$direction');
    final db = ref.read(databaseProvider);
    await (db.update(db.userSubstances)..where((t) => t.id.equals(id))).write(
      UserSubstancesCompanion(
        defaultImpact:
            defaultImpact != null ? Value(defaultImpact) : const Value.absent(),
        direction:
            direction != null ? Value(direction) : const Value.absent(),
      ),
    );
    try {
      await Supabase.instance.client.from('user_substances').upsert({
        'id': id,
        if (defaultImpact != null) 'default_impact': defaultImpact,
        if (direction != null) 'direction': direction,
      }, onConflict: 'id');
    } catch (e) { debugPrint('[Readiness] updateSubstance sync error: $e'); }
  }

  Future<void> deleteSubstance(String id) async {
    debugPrint('[Readiness:UserSubstances] deleteSubstance — id=$id');
    final db = ref.read(databaseProvider);
    await (db.delete(db.userSubstances)..where((t) => t.id.equals(id))).go();
    try {
      await Supabase.instance.client.from('user_substances').delete().eq('id', id);
    } catch (e) { debugPrint('[Readiness] deleteSubstance sync error: $e'); }
  }

  /// Called by the learning engine to write back the Bayesian-blended impact.
  Future<void> applyLearnedImpact(
      String uid, String substanceName, double newLearned, int newCount) async {
    debugPrint('[Readiness:Learning] applyLearnedImpact — substance=$substanceName newLearned=${newLearned.toStringAsFixed(2)} n=$newCount');
    final db = ref.read(databaseProvider);
    await (db.update(db.userSubstances)
          ..where(
              (t) => t.userId.equals(uid) & t.name.equals(substanceName)))
        .write(UserSubstancesCompanion(
      learnedImpact: Value(newLearned),
      occurrenceCount: Value(newCount),
    ));
    try {
      final row = await (db.select(db.userSubstances)
            ..where((t) => t.userId.equals(uid) & t.name.equals(substanceName)))
          .getSingleOrNull();
      if (row != null) {
        await Supabase.instance.client.from('user_substances').upsert({
          'id': row.id,
          'user_id': uid,
          'learned_impact': newLearned,
          'occurrence_count': newCount,
        }, onConflict: 'id');
      }
    } catch (e) { debugPrint('[Readiness] applyLearnedImpact sync error: $e'); }
  }

  // ---------------------------------------------------------------------------
  // syncFromRemote — pull user_substances from Supabase into local Drift DB.
  // ---------------------------------------------------------------------------
  Future<void> syncFromRemote() async {
    debugPrint('[Readiness:Sync] userSubstances syncFromRemote — start');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    try {
      final rows = await Supabase.instance.client
          .from('user_substances')
          .select()
          .eq('user_id', uid);
      debugPrint('[Readiness:Sync] userSubstances — pulled ${(rows as List).length} rows');
      for (final r in rows) {
        await db.into(db.userSubstances).insertOnConflictUpdate(
              UserSubstancesCompanion.insert(
                id: r['id'] as String,
                userId: r['user_id'] as String,
                name: r['name'] as String,
                direction: Value(r['direction'] as String? ?? 'negative'),
                defaultImpact: Value((r['default_impact'] as num?)?.toDouble() ?? 5.0),
                learnedImpact: Value((r['learned_impact'] as num?)?.toDouble()),
                occurrenceCount: Value(r['occurrence_count'] as int? ?? 0),
                synced: const Value(true),
              ),
            );
      }
    } catch (e) { debugPrint('[Readiness] userSubstances syncFromRemote error: $e'); }
    await seedDefaultsIfEmpty();
  }
}

final userSubstancesProvider =
    StreamNotifierProvider<UserSubstancesNotifier, List<UserSubstance>>(
  UserSubstancesNotifier.new,
);

// ---------------------------------------------------------------------------
// SubstanceLogs notifier
// ---------------------------------------------------------------------------

class SubstanceLogsNotifier extends StreamNotifier<List<SubstanceLog>> {
  @override
  Stream<List<SubstanceLog>> build() {
    final db = ref.watch(databaseProvider);
    final uid = _userId();
    if (uid == null) return const Stream.empty();
    return (db.select(db.substanceLogs)
          ..where((t) => t.userId.equals(uid))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<void> logSubstance({
    required String substanceName,
    required String direction,
    required double impactSnapshot,
    String? quantity,
    String? notes,
    DateTime? date, // defaults to today; pass yesterday's date to backfill
  }) async {
    debugPrint('[Readiness:SubstanceLogs] logSubstance — name=$substanceName direction=$direction impact=$impactSnapshot date=${date ?? 'today'}');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    final id = _uuid.v4();
    final logDate = _dateOnly(date ?? DateTime.now());
    final name = substanceName.trim().toLowerCase();
    await db.into(db.substanceLogs).insert(
          SubstanceLogsCompanion.insert(
            id: id,
            userId: uid,
            date: logDate,
            substanceName: name,
            direction: direction,
            impactSnapshot: impactSnapshot,
            quantity: Value(quantity),
            notes: Value(notes),
          ),
        );
    try {
      await Supabase.instance.client.from('substance_logs').insert({
        'id': id,
        'user_id': uid,
        'date': logDate.toIso8601String(),
        'substance_name': name,
        'direction': direction,
        'impact_snapshot': impactSnapshot,
        if (quantity != null) 'quantity': quantity,
        if (notes != null) 'notes': notes,
      });
    } catch (e) { debugPrint('[Readiness] logSubstance sync error: $e'); }
  }

  Future<void> deleteLog(String id) async {
    debugPrint('[Readiness:SubstanceLogs] deleteLog — id=$id');
    final db = ref.read(databaseProvider);
    await (db.delete(db.substanceLogs)..where((t) => t.id.equals(id))).go();
    try {
      await Supabase.instance.client.from('substance_logs').delete().eq('id', id);
    } catch (e) { debugPrint('[Readiness] deleteLog sync error: $e'); }
  }

  // ---------------------------------------------------------------------------
  // syncFromRemote — pull substance_logs from Supabase into local Drift DB.
  // ---------------------------------------------------------------------------
  Future<void> syncFromRemote() async {
    debugPrint('[Readiness:Sync] substanceLogs syncFromRemote — start');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    try {
      final rows = await Supabase.instance.client
          .from('substance_logs')
          .select()
          .eq('user_id', uid);
      debugPrint('[Readiness:Sync] substanceLogs — pulled ${(rows as List).length} rows');
      for (final r in rows) {
        await db.into(db.substanceLogs).insertOnConflictUpdate(
              SubstanceLogsCompanion.insert(
                id: r['id'] as String,
                userId: r['user_id'] as String,
                date: _dateOnly(DateTime.parse((r['date'] as String).substring(0, 10))),
                substanceName: r['substance_name'] as String,
                direction: r['direction'] as String,
                impactSnapshot: (r['impact_snapshot'] as num).toDouble(),
                quantity: Value(r['quantity'] as String?),
                notes: Value(r['notes'] as String?),
                synced: const Value(true),
              ),
            );
      }
    } catch (e) { debugPrint('[Readiness] substanceLogs syncFromRemote error: $e'); }
  }

  Future<List<SubstanceLog>> logsForDate(DateTime date) async {
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return [];
    final d = _dateOnly(date);
    return (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(d, _dayEnd(d))))
        .get();
  }
}

final substanceLogsProvider =
    StreamNotifierProvider<SubstanceLogsNotifier, List<SubstanceLog>>(
  SubstanceLogsNotifier.new,
);

// ---------------------------------------------------------------------------
// ReadinessCheckIns notifier
// ---------------------------------------------------------------------------

class ReadinessCheckInsNotifier
    extends StreamNotifier<List<ReadinessCheckIn>> {
  @override
  Stream<List<ReadinessCheckIn>> build() {
    final db = ref.watch(databaseProvider);
    final uid = _userId();
    if (uid == null) return const Stream.empty();
    return (db.select(db.readinessCheckIns)
          ..where((t) => t.userId.equals(uid))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<ReadinessCheckIn?> todaysCheckIn(CheckInWindow window) async {
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return null;
    final today = _dateOnly(DateTime.now());
    return (db.select(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) &
              t.checkInWindow.equals(window.value) &
              t.date.isBetweenValues(today, _dayEnd(today))))
        .getSingleOrNull();
  }

  Future<void> submitCheckIn({
    required CheckInWindow window,
    double? sleepHours,
    int? sleepQuality,
    int? stressLevel,
    int? energyLevel,
    int? mood,
    int? caffeineCount,
    int? focusLevel,
    String? notes,
  }) async {
    debugPrint('[Readiness:CheckIns] submitCheckIn — window=${window.name} sleep=$sleepHours quality=$sleepQuality stress=$stressLevel energy=$energyLevel mood=$mood caffeine=$caffeineCount focus=$focusLevel');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    final today = _dateOnly(DateTime.now());

    // Upsert: delete existing for this window+date, then insert fresh.
    await (db.delete(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) &
              t.checkInWindow.equals(window.value) &
              t.date.isBetweenValues(today, _dayEnd(today))))
        .go();

    final id = _uuid.v4();
    await db.into(db.readinessCheckIns).insert(
          ReadinessCheckInsCompanion.insert(
            id: id,
            userId: uid,
            date: today,
            checkInWindow: window.value,
            sleepHours: Value(sleepHours),
            sleepQuality: Value(sleepQuality),
            stressLevel: Value(stressLevel),
            energyLevel: Value(energyLevel),
            mood: Value(mood),
            caffeineCount: Value(caffeineCount),
            focusLevel: Value(focusLevel),
            notes: Value(notes),
          ),
        );
    try {
      await Supabase.instance.client.from('readiness_check_ins').upsert({
        'id': id,
        'user_id': uid,
        'date': today.toIso8601String(),
        'check_in_window': window.name,
        if (sleepHours != null) 'sleep_hours': sleepHours,
        if (sleepQuality != null) 'sleep_quality': sleepQuality,
        if (stressLevel != null) 'stress_level': stressLevel,
        if (energyLevel != null) 'energy_level': energyLevel,
        if (mood != null) 'mood': mood,
        if (caffeineCount != null) 'caffeine_count': caffeineCount,
        if (focusLevel != null) 'focus_level': focusLevel,
        if (notes != null) 'notes': notes,
      }, onConflict: 'id');
    } catch (e) { debugPrint('[Readiness] submitCheckIn sync error: $e'); }

    await ref.read(readinessProvider.notifier).recomputeToday();
  }

  // ---------------------------------------------------------------------------
  // syncFromRemote — pull readiness_check_ins from Supabase into local Drift DB.
  // ---------------------------------------------------------------------------
  Future<void> syncFromRemote() async {
    debugPrint('[Readiness:Sync] checkIns syncFromRemote — start');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    try {
      final rows = await Supabase.instance.client
          .from('readiness_check_ins')
          .select()
          .eq('user_id', uid);
      debugPrint('[Readiness:Sync] checkIns — pulled ${(rows as List).length} rows');
      for (final r in rows) {
        await db.into(db.readinessCheckIns).insertOnConflictUpdate(
              ReadinessCheckInsCompanion.insert(
                id: r['id'] as String,
                userId: r['user_id'] as String,
                date: _dateOnly(DateTime.parse((r['date'] as String).substring(0, 10))),
                checkInWindow: r['check_in_window'] as String,
                sleepHours: Value((r['sleep_hours'] as num?)?.toDouble()),
                sleepQuality: Value(r['sleep_quality'] as int?),
                stressLevel: Value(r['stress_level'] as int?),
                energyLevel: Value(r['energy_level'] as int?),
                mood: Value(r['mood'] as int?),
                caffeineCount: Value(r['caffeine_count'] as int?),
                focusLevel: Value(r['focus_level'] as int?),
                notes: Value(r['notes'] as String?),
                synced: const Value(true),
              ),
            );
      }
    } catch (e) { debugPrint('[Readiness] checkIns syncFromRemote error: $e'); }
  }
}

final checkInsProvider =
    StreamNotifierProvider<ReadinessCheckInsNotifier, List<ReadinessCheckIn>>(
  ReadinessCheckInsNotifier.new,
);

// ---------------------------------------------------------------------------
// DailyReadiness notifier — scoring + learning engine
// ---------------------------------------------------------------------------

class ReadinessNotifier extends StreamNotifier<List<DailyReadinessData>> {
  @override
  Stream<List<DailyReadinessData>> build() {
    final db = ref.watch(databaseProvider);
    final uid = _userId();
    if (uid == null) return const Stream.empty();
    return (db.select(db.dailyReadiness)
          ..where((t) => t.userId.equals(uid))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<DailyReadinessData> todaysReadiness() async {
    debugPrint('[Readiness:Score] todaysReadiness — fetching');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) throw StateError('not logged in');
    final today = _dateOnly(DateTime.now());

    final existing = await (db.select(db.dailyReadiness)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(today, _dayEnd(today))))
        .getSingleOrNull();
    if (existing != null) {
      debugPrint('[Readiness:Score] todaysReadiness — found existing score=${existing.computedScore.toStringAsFixed(1)} carryover=${existing.previousDayInfluence.toStringAsFixed(1)}');
      return existing;
    }
    debugPrint('[Readiness:Score] todaysReadiness — no row for today, creating');

    final carryover = await _computeCarryoverDelta(uid);
    final base = (_kBase + carryover).clamp(0.0, 100.0);

    await db.into(db.dailyReadiness).insert(DailyReadinessCompanion.insert(
      id: _uuid.v4(),
      userId: uid,
      date: today,
      computedScore: Value(base),
      previousDayInfluence: Value(carryover),
    ));

    return (db.select(db.dailyReadiness)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(today, _dayEnd(today))))
        .getSingle();
  }

  Future<void> recomputeToday() async {
    debugPrint('[Readiness:Score] recomputeToday — start');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    final today = _dateOnly(DateTime.now());

    final carryover = await _computeCarryoverDelta(uid);
    final score = await _computeScore(uid, today, carryover);
    debugPrint('[Readiness:Score] recomputeToday — score=${score.toStringAsFixed(1)} carryover=${carryover.toStringAsFixed(1)}');

    await (db.update(db.dailyReadiness)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(today, _dayEnd(today))))
        .write(DailyReadinessCompanion(
      computedScore: Value(score),
      previousDayInfluence: Value(carryover),
    ));
    try {
      final row = await (db.select(db.dailyReadiness)
            ..where((t) =>
                t.userId.equals(uid) & t.date.isBetweenValues(today, _dayEnd(today))))
          .getSingleOrNull();
      if (row != null) {
        await Supabase.instance.client.from('daily_readiness').upsert({
          'id': row.id,
          'user_id': uid,
          'date': today.toIso8601String(),
          'computed_score': score,
          'previous_day_influence': carryover,
        }, onConflict: 'id');
      }
    } catch (e) { debugPrint('[Readiness] recomputeToday sync error: $e'); }
  }

  Future<void> submitSelfRating(double rating) async {
    debugPrint('[Readiness:Score] submitSelfRating — rating=$rating');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    final today = _dateOnly(DateTime.now());

    await (db.update(db.dailyReadiness)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(today, _dayEnd(today))))
        .write(DailyReadinessCompanion(userRatedScore: Value(rating)));
    try {
      final row = await (db.select(db.dailyReadiness)
            ..where((t) =>
                t.userId.equals(uid) & t.date.isBetweenValues(today, _dayEnd(today))))
          .getSingleOrNull();
      if (row != null) {
        await Supabase.instance.client.from('daily_readiness').upsert({
          'id': row.id,
          'user_id': uid,
          'date': today.toIso8601String(),
          'user_rated_score': rating,
        }, onConflict: 'id');
      }
    } catch (e) { debugPrint('[Readiness] submitSelfRating sync error: $e'); }

    await _runLearningUpdate(uid, today, rating);
  }

  // ---------------------------------------------------------------------------
  // syncFromRemote — pull daily_readiness from Supabase into local Drift DB.
  // ---------------------------------------------------------------------------
  Future<void> syncFromRemote() async {
    debugPrint('[Readiness:Sync] dailyReadiness syncFromRemote — start');
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    try {
      final rows = await Supabase.instance.client
          .from('daily_readiness')
          .select()
          .eq('user_id', uid);
      debugPrint('[Readiness:Sync] dailyReadiness — pulled ${(rows as List).length} rows');
      for (final r in rows) {
        await db.into(db.dailyReadiness).insertOnConflictUpdate(
              DailyReadinessCompanion.insert(
                id: r['id'] as String,
                userId: r['user_id'] as String,
                date: _dateOnly(DateTime.parse((r['date'] as String).substring(0, 10))),
                computedScore: Value((r['computed_score'] as num?)?.toDouble() ?? 70.0),
                userRatedScore: Value((r['user_rated_score'] as num?)?.toDouble()),
                previousDayInfluence: Value((r['previous_day_influence'] as num?)?.toDouble() ?? 0.0),
                synced: const Value(true),
              ),
            );
      }
    } catch (e) { debugPrint('[Readiness] dailyReadiness syncFromRemote error: $e'); }
  }

  // ─────────────────────────────────────────────────────────────
  // SCORING ENGINE
  //
  // Assembles all same-day signals into a single 0–100 readiness
  // score. The pipeline is:
  //
  //   1. Start at _kBase (70) — population average for a healthy day.
  //   2. Add the carryover delta from yesterday's data (sleep shortfall,
  //      stress residue, substance hangover).
  //   3. Subtract the 7-day rolling sleep debt penalty.
  //   4. Apply each check-in's contribution (sleep hours/quality,
  //      stress, caffeine, energy, mood).
  //   5. Apply same-day substance logs.
  //   6. Clamp to [0, 100].
  // ─────────────────────────────────────────────────────────────

  Future<double> _computeScore(
      String uid, DateTime date, double carryover) async {
    debugPrint('[Readiness:Score] _computeScore — date=$date carryover=${carryover.toStringAsFixed(1)}');
    final db = ref.read(databaseProvider);
    double score = _kBase; // 70 — healthy-adult population mean

    // ── 1. Yesterday's residue ────────────────────────────────
    // Carryover encodes overnight persistence of sleep debt,
    // cortisol from stress, and substance metabolites. It is
    // computed separately so it can also be stored as
    // previousDayInfluence for display in the UI.
    score += carryover;

    // ── 2. 7-day rolling sleep debt ───────────────────────────
    // Van Dongen et al. (2003): cumulative sleep restriction
    // impairs performance non-linearly, and subjects are mostly
    // unaware of it. A single night of 6h feels fine but 14 days
    // of it equals 48h of total deprivation. We penalise the
    // rolling total, not just last night, to capture this.
    score -= await _computeSleepDebtPenalty(uid, excludeDate: date);

    // ── 3. Check-in signals ───────────────────────────────────
    final checkIns = await (db.select(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(date, _dayEnd(date))))
        .get();

    for (final ci in checkIns) {
      // Used for the caffeine timing multiplier below.
      final isAfternoonOrEvening =
          ci.checkInWindow == CheckInWindow.afternoon.value ||
          ci.checkInWindow == CheckInWindow.evening.value;

      debugPrint('[Readiness:Score]   check-in window=${ci.checkInWindow} sleep=${ci.sleepHours} quality=${ci.sleepQuality} stress=${ci.stressLevel} caffeine=${ci.caffeineCount} energy=${ci.energyLevel} mood=${ci.mood}');
      // ── Sleep hours (morning check-in only) ──────────────────
      // Van Dongen non-linear formula: -pow(8 - h, 1.3) * 3.5
      //   8 h →   0 pts (full rest bonus applied instead)
      //   7 h →  -3.5 pts
      //   6 h →  -8.6 pts
      //   5 h → -14.6 pts
      //   4 h → -21   pts (capped at -_kSleepPenaltyCap)
      // The exponent > 1 reflects the non-linear dose-response:
      // going from 7→6 h hurts more than going from 8→7 h.
      if (ci.sleepHours != null) {
        final h = ci.sleepHours!;
        if (h >= 8.0) {
          // Full 8 h+ means adenosine fully cleared, glymphatic
          // system completed waste clearance — award bonus.
          score += _kSleepFullRestBonus;
        } else {
          score -= (math.pow(8.0 - h, _kSleepDebtExp) * _kSleepDebtMult)
              .clamp(0.0, _kSleepPenaltyCap);
        }
      }

      // ── Sleep quality ─────────────────────────────────────────
      // Sleep Medicine Reviews meta-analysis (2024) on REM
      // architecture: quality 1 = severely fragmented REM (e.g.
      // alcohol-disrupted), quality 5 = restorative with full
      // slow-wave and REM cycles. Centered at 3 (neutral) so
      // good quality adds points and poor quality subtracts.
      //   quality 5 → +8 pts   quality 1 → -8 pts
      if (ci.sleepQuality != null) {
        score += (ci.sleepQuality! - 3) * _kSleepQualityMult;
      }

      // ── Stress ────────────────────────────────────────────────
      // HPA axis / cortisol literature (elevated IL-6, CRP):
      // stress levels 1–3 are within a healthy arousal range and
      // have no penalty. Levels 4–5 activate the HPA axis enough
      // to measurably elevate cortisol, suppress immune function,
      // and fragment sleep architecture.
      //   level 4 → -3 pts   level 5 → -6 pts
      if (ci.stressLevel != null && ci.stressLevel! > _kStressPenaltyThreshold) {
        score -= (ci.stressLevel! - _kStressPenaltyThreshold) * _kStressPenaltyPerLevel;
      }

      // ── Caffeine ──────────────────────────────────────────────
      // Randall et al. SLEEP 2024 (randomised crossover):
      //   1–2 cups: adenosine antagonism → clear alertness boost (+3)
      //   3 cups:   performance at neutral; no net benefit or harm
      //   4+ cups:  anxiety + cortisol spike (Lane et al.) → -3/cup
      //
      // Timing multiplier (×1.5 for afternoon/evening):
      // Caffeine half-life is 4–6 h (CYP1A2-dependent). A cup at
      // 3 pm still has ~50% circulating at 9 pm, delaying sleep
      // onset and suppressing slow-wave sleep — so the penalty is
      // amplified when the check-in window is afternoon/evening.
      if (ci.caffeineCount != null) {
        final cups = ci.caffeineCount!;
        if (cups <= _kCaffeineBoostMaxCups) {
          score += _kCaffeineBoost;
        } else if (cups > _kCaffeineNeutralCups) {
          final timingMult = isAfternoonOrEvening ? _kCaffeineTimingMult : 1.0;
          score -= (cups - _kCaffeineNeutralCups) * _kCaffeinePenaltyPerCup * timingMult;
        }
      }

      // ── Energy + mood ─────────────────────────────────────────
      // Self-reported signals calibrated to the scoring range.
      // Both are centered at 3 (neutral on a 1–5 scale) so they
      // add or subtract symmetrically. Energy is weighted higher
      // than mood because it correlates more directly with
      // physical readiness and cognitive performance measures.
      if (ci.energyLevel != null) score += (ci.energyLevel! - 3) * _kEnergyMult;
      if (ci.mood != null) score += (ci.mood! - 3) * _kMoodMult;
    }

    // ── 4. Same-day substance logs ────────────────────────────
    // Scales each substance's impact (1–10 user rating) to the
    // 0–15 pt score range: delta = (impact / 10) * 15.
    // learnedImpact overrides the logged snapshot once the
    // Bayesian engine has enough observations.
    final logs = await (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(date, _dayEnd(date))))
        .get();

    for (final log in logs) {
      final impact =
          await _resolvedImpact(db, uid, log.substanceName, log.impactSnapshot);
      final delta = (impact / _kSubstanceScaleDenominator) * _kSubstanceScaleMax;
      debugPrint('[Readiness:Score]   substance=${log.substanceName} direction=${log.direction} resolvedImpact=${impact.toStringAsFixed(2)} delta=${delta.toStringAsFixed(1)}');
      score += log.direction == 'positive' ? delta : -delta;
    }

    debugPrint('[Readiness:Score] _computeScore — final=${score.clamp(0.0, 100.0).toStringAsFixed(1)}');
    return score.clamp(0.0, 100.0);
  }

  // ─────────────────────────────────────────────────────────────
  // 7-DAY SLEEP DEBT PENALTY
  //
  // Van Dongen & Dinges (2003) + Belenky et al. + PMC 2022
  // dynamics-of-recovery paper.
  //
  // Key finding: 6 h/night for 14 days produces the same
  // performance deficit as 2 full nights of total sleep
  // deprivation, yet subjects rated their sleepiness as only
  // mildly elevated — they are "adapted" to the impairment.
  //
  // Implementation:
  //   - Look back up to 7 morning check-ins (the only window
  //     where sleep hours are collected).
  //   - Sum each night's shortfall below 8 h (capped at 6 h per
  //     night to avoid a single extreme outlier dominating).
  //   - Apply a non-linear penalty: pow(totalDebtHours, 1.2) * 0.8
  //     This means debt accumulates faster as it grows — consistent
  //     with Van Dongen's non-linear dose–response curve.
  //   - Require ≥2 data points before penalising; with only one
  //     morning check-in we can't distinguish chronic debt from
  //     a one-off late night.
  // ─────────────────────────────────────────────────────────────
  Future<double> _computeSleepDebtPenalty(String uid,
      {required DateTime excludeDate}) async {
    final db = ref.read(databaseProvider);
    double totalDebtHours = 0.0;
    int daysWithData = 0;

    for (int i = 1; i <= _kSleepDebtLookbackDays; i++) {
      final d = _dateOnly(excludeDate.subtract(Duration(days: i)));
      // Only morning check-ins capture sleep hours; afternoon/
      // evening check-ins don't ask about last night's sleep.
      final ci = await (db.select(db.readinessCheckIns)
            ..where((t) =>
                t.userId.equals(uid) &
                t.checkInWindow.equals('morning') &
                t.date.isBetweenValues(d, _dayEnd(d))))
          .getSingleOrNull();

      if (ci?.sleepHours != null) {
        daysWithData++;
        // Cap single-night debt at 6 h: beyond that the user
        // almost certainly had a sick/travel night that isn't
        // representative of their baseline pattern.
        totalDebtHours += (8.0 - ci!.sleepHours!).clamp(0.0, 6.0);
      }
    }

    // Fewer than 2 data points means we can't yet distinguish
    // a chronic pattern from noise — return 0 to avoid false penalties.
    if (daysWithData < _kSleepDebtMinDays) {
      debugPrint('[Readiness:Score] _computeSleepDebtPenalty — not enough data ($daysWithData days), skipping');
      return 0.0;
    }

    final penalty = (math.pow(totalDebtHours, _kRollingDebtExp) * _kRollingDebtMult)
        .clamp(0.0, _kRollingDebtCap);
    debugPrint('[Readiness:Score] _computeSleepDebtPenalty — daysWithData=$daysWithData totalDebtHours=${totalDebtHours.toStringAsFixed(1)} penalty=${penalty.toStringAsFixed(1)}');
    // Non-linear accumulation: a total debt of 7 h → -10 pts,
    // 14 h → -17 pts, 21 h → -22 pts (capped at -_kRollingDebtCap).
    return penalty;
  }

  // ─────────────────────────────────────────────────────────────
  // CARRYOVER DELTA
  //
  // Computes how much yesterday's physiology shifts today's
  // baseline — before any of today's check-ins are factored in.
  // Three independent carryover sources are summed:
  //
  //   1. Sleep shortfall carryover — 50% of last night's debt
  //      penalty bleeds into today. This reflects the real-world
  //      observation that one night of poor sleep still impairs
  //      the following morning even after waking up.
  //
  //   2. Stress (cortisol) carryover — the HPA axis takes ~24 h
  //      to return to baseline after activation. At stress levels
  //      ≥4, we carry forward -2 pts per level above 3. Only
  //      levels ≥4 qualify because sub-threshold stress resolves
  //      quickly via normal diurnal cortisol rhythm.
  //
  //   3. Substance carryover — each substance has a literature-
  //      backed rate (see _substanceCarryoverRate). The same-day
  //      delta is scaled by that rate and added to the baseline.
  //
  // Sugar gets two additional adjustments not covered by the
  // generic carryover rate:
  //   • SWS penalty (-4 pts) on day 1: high glycaemic load
  //     disrupts slow-wave sleep even when total hours look
  //     normal — the user cannot observe this themselves.
  //   • Day-2 carryover (25%): CRP/cytokine inflammation and
  //     gut microbiome shifts persist a second day; dopamine
  //     receptor down-regulation peaks at 24–48 h post-binge.
  // ─────────────────────────────────────────────────────────────
  Future<double> _computeCarryoverDelta(String uid) async {
    debugPrint('[Readiness:Score] _computeCarryoverDelta — start');
    final db = ref.read(databaseProvider);
    final yesterday = _dateOnly(DateTime.now().subtract(const Duration(days: 1)));
    double delta = 0.0;

    // ── 1. Sleep shortfall carryover ──────────────────────────
    // Re-applies 50% of the single-night penalty to today's
    // baseline. The 7-day rolling debt is a separate, additive
    // penalty applied later in _computeScore — they measure
    // different things: acute vs. chronic deprivation.
    final morningCI = await (db.select(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) &
              t.checkInWindow.equals('morning') &
              t.date.isBetweenValues(yesterday, _dayEnd(yesterday))))
        .getSingleOrNull();

    if (morningCI?.sleepHours != null) {
      final h = morningCI!.sleepHours!;
      if (h < 8.0) {
        // Same non-linear formula as the same-day penalty, but
        // scaled by _kCarryoverSleepFrac (0.5) — only half the
        // deficit persists into the next morning.
        delta -= (math.pow(8.0 - h, _kSleepDebtExp) * _kSleepDebtMult * _kCarryoverSleepFrac)
            .clamp(0.0, _kCarryoverSleepCap);
      }
    }

    // ── 2. Stress (cortisol) carryover ────────────────────────
    // Cortisol elevation from HPA axis activation (stress ≥4)
    // persists approximately 67% into the next day. We query all
    // windows because a high-stress evening matters as much as a
    // high-stress morning — cortisol takes the same time to clear.
    final allCIs = await (db.select(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(yesterday, _dayEnd(yesterday))))
        .get();
    for (final ci in allCIs) {
      if (ci.stressLevel != null && ci.stressLevel! >= _kStressCarryoverThreshold) {
        // -2 pts per level above 3: level 4 → -2, level 5 → -4.
        delta -= (ci.stressLevel! - _kStressPenaltyThreshold) * _kStressCarryoverPerLevel;
      }
    }

    // ── 3. Substance carryover ────────────────────────────────
    // For each substance logged yesterday, scale its same-day
    // delta by the literature-backed carryover rate to get
    // today's residual. Positive substances carry forward a
    // positive delta; negative ones carry forward a negative one.
    final logs = await (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(yesterday, _dayEnd(yesterday))))
        .get();

    bool hadSugarYesterday = false;

    for (final log in logs) {
      final impact =
          await _resolvedImpact(db, uid, log.substanceName, log.impactSnapshot);
      final sameDayDelta = (impact / _kSubstanceScaleDenominator) * _kSubstanceScaleMax;
      final rate = _substanceCarryoverRate(log.substanceName);
      final carryoverDelta = sameDayDelta * rate;
      delta += log.direction == 'positive' ? carryoverDelta : -carryoverDelta;

      final name = log.substanceName.toLowerCase().trim();
      if (name == 'sugar spike' || name == 'sugar') hadSugarYesterday = true;
    }

    debugPrint('[Readiness:Score] _computeCarryoverDelta — after sleep+stress+substances: delta=${delta.toStringAsFixed(1)}');
    // ── 3a. Sugar SWS penalty (day 1) ─────────────────────────
    // Mantantzis et al. (2019) + gut-brain axis research (2024):
    // high glycaemic intake suppresses slow-wave sleep (SWS) via
    // overnight insulin/glucagon oscillations and neuroinflammatory
    // signalling. The user cannot detect this — their reported
    // sleep hours and quality may look fine while SWS was actually
    // fragmented. Applied as a hidden penalty on top of the
    // substance carryover.
    if (hadSugarYesterday) delta -= _kSugarSwsPenalty;

    // ── 3b. Sugar carryover (day 2) ───────────────────────────
    // Two distinct mechanisms extend the penalty into a second day:
    //   - CRP/cytokine inflammation peaks ~24 h after a large
    //     glycaemic spike and resolves slowly over 1–2 days.
    //   - Dopamine receptor down-regulation: a large dopamine
    //     release (reward from sugar) triggers compensatory
    //     receptor reduction; the trough manifests as low
    //     motivation and anhedonia 24–48 h later.
    //   - Gut microbiome: sugar-loving bacteria overgrowth begins
    //     within 24 h and produces brain-fog metabolites.
    // Combined rate: 25% of the original same-day delta.
    final twoDaysAgo = _dateOnly(DateTime.now().subtract(const Duration(days: 2)));
    final twoDayLogs = await (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(twoDaysAgo, _dayEnd(twoDaysAgo))))
        .get();

    for (final log in twoDayLogs) {
      final name = log.substanceName.toLowerCase().trim();
      if (name == 'sugar spike' || name == 'sugar') {
        final impact =
            await _resolvedImpact(db, uid, log.substanceName, log.impactSnapshot);
        delta -= (impact / _kSubstanceScaleDenominator) * _kSubstanceScaleMax * _kSugarDay2Rate;
      }
    }

    debugPrint('[Readiness:Score] _computeCarryoverDelta — final delta=${delta.toStringAsFixed(1)}');
    return delta;
  }

  // ─────────────────────────────────────────────────────────────
  // LEARNING ENGINE
  //
  // Each time the user rates their day (0–10), we compare that
  // rating to the baseline (70/100) to infer how much the
  // substances they used yesterday actually affected them —
  // as opposed to how much we predicted they would.
  //
  // Direction-aware observed impact:
  //   negative substance → observed impact = how far *below* 70
  //     the user rated themselves (if they rated 40, the
  //     substance produced a 30-pt drop → impact ≈ 10/10)
  //   positive substance → observed impact = how far *above* 70
  //     they rated (if they rated 90, the substance helped by
  //     20 pts → impact ≈ 6.7/10)
  //   "wrong direction" (negative substance, great day): the
  //     observed delta clamps to 0, so the model learns that
  //     this substance had little effect today.
  //
  // Bayesian blend:
  //   newLearned = current * (1 - w) + observed * w
  //   where w = (n / 20).clamp(0, 0.7)
  //
  //   At n=0:  w=0.0 → fully trust the user's stated default
  //   At n=10: w=0.5 → 50/50 blend of stated and observed
  //   At n=20: w=0.7 → observed data has strong influence
  //   Beyond:  w never exceeds 0.7, preserving 30% of the
  //            stated prior in case personal variation is high.
  // ─────────────────────────────────────────────────────────────
  Future<void> _runLearningUpdate(
      String uid, DateTime today, double userRating) async {
    debugPrint('[Readiness:Learning] _runLearningUpdate — userRating=$userRating');
    final db = ref.read(databaseProvider);
    final yesterday = _dateOnly(today.subtract(const Duration(days: 1)));

    // We look at yesterday's substances because the user is
    // rating how they feel *today*, which reflects yesterday's
    // behaviour (sleep, substances) via the carryover mechanism.
    final logs = await (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(yesterday, _dayEnd(yesterday))))
        .get();
    if (logs.isEmpty) return;

    // Map the user's 0–10 rating into the 0–100 score space so
    // we can compare directly against _kBase (70).
    final ratingNorm = userRating * 10.0;

    for (final log in logs) {
      final substance = await (db.select(db.userSubstances)
            ..where((t) =>
                t.userId.equals(uid) & t.name.equals(log.substanceName)))
          .getSingleOrNull();
      if (substance == null) continue;

      final n = substance.occurrenceCount;
      final current = substance.learnedImpact ?? substance.defaultImpact;

      // Infer what this substance's impact "should" have been,
      // given how far the user's self-rating deviated from the
      // population baseline. Capped at 30 pts (~impact 10/10) to
      // avoid a confounded outlier day (illness, big life event)
      // permanently distorting the substance model.
      final double observedDelta;
      if (log.direction == 'negative') {
        // A negative substance that tanks readiness: the further
        // below 70 the user rates, the higher the inferred impact.
        observedDelta = (_kBase - ratingNorm).clamp(0.0, _kLearningObservedDeltaCap);
      } else {
        // A positive substance that lifts readiness: the further
        // above 70 the user rates, the higher the inferred benefit.
        observedDelta = (ratingNorm - _kBase).clamp(0.0, _kLearningObservedDeltaCap);
      }
      // Re-scale from score-space back to 1–10 impact scale.
      final observedImpact = (observedDelta / _kSubstanceScaleMax * _kSubstanceScaleDenominator)
          .clamp(_kLearningObservedImpactMin, _kLearningObservedImpactMax);

      // Bayesian blend: weight grows with n, capped at 0.7 so
      // the stated prior never drops below 30% influence.
      final blendWeight = (n / _kLearningFullTrustN).clamp(0.0, _kLearningMaxBlend);
      final newLearned = current * (1.0 - blendWeight) + observedImpact * blendWeight;
      debugPrint('[Readiness:Learning]   substance=${log.substanceName} n=$n observedDelta=${observedDelta.toStringAsFixed(1)} observedImpact=${observedImpact.toStringAsFixed(2)} blendWeight=${blendWeight.toStringAsFixed(2)} current=${current.toStringAsFixed(2)} → newLearned=${newLearned.toStringAsFixed(2)}');

      await ref
          .read(userSubstancesProvider.notifier)
          .applyLearnedImpact(uid, log.substanceName, newLearned, n + 1);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PATTERN QUERY
  //
  // Surfaces a user-facing summary of the correlation between
  // a given substance and their next-day readiness scores, e.g.:
  // "After alcohol, avg next-day readiness: 4.1/10
  //  (below 5 on 71% of days, n=12)"
  //
  // Uses userRatedScore when available (the user's honest
  // self-assessment), falling back to computedScore / 10 so
  // the denominator is consistent with the 0–10 display scale.
  // ─────────────────────────────────────────────────────────────
  Future<SubstancePattern> getSubstancePattern(String substanceName) async {
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return SubstancePattern.empty(substanceName);

    final logs = await (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.substanceName.equals(substanceName)))
        .get();
    if (logs.isEmpty) return SubstancePattern.empty(substanceName);

    final nextDayScores = <double>[];
    for (final log in logs) {
      final nextDay = _dateOnly(log.date.add(const Duration(days: 1)));
      final row = await (db.select(db.dailyReadiness)
            ..where((t) =>
                t.userId.equals(uid) & t.date.isBetweenValues(nextDay, _dayEnd(nextDay))))
          .getSingleOrNull();
      if (row != null) {
        // Prefer the user's self-rating (0–10 scale); fall back to
        // the algorithm's output divided by 10 to match the scale.
        final score = row.userRatedScore ?? row.computedScore / 10.0;
        nextDayScores.add(score);
      }
    }

    if (nextDayScores.isEmpty) return SubstancePattern.empty(substanceName);

    final avg = nextDayScores.reduce((a, b) => a + b) / nextDayScores.length;
    final belowFiveRate =
        nextDayScores.where((s) => s < 5).length / nextDayScores.length;

    return SubstancePattern(
      substanceName: substanceName,
      occurrences: logs.length,
      avgNextDayReadiness: avg,
      belowFiveRate: belowFiveRate,
      nextDayScores: nextDayScores,
    );
  }
}

final readinessProvider =
    StreamNotifierProvider<ReadinessNotifier, List<DailyReadinessData>>(
  ReadinessNotifier.new,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Uses learnedImpact when the model has enough observations;
/// otherwise falls back to the snapshot at time of logging.
Future<double> _resolvedImpact(
    AppDatabase db, String uid, String substanceName, double snapshot) async {
  final substance = await (db.select(db.userSubstances)
        ..where(
            (t) => t.userId.equals(uid) & t.name.equals(substanceName)))
      .getSingleOrNull();
  return substance?.learnedImpact ?? snapshot;
}

// ---------------------------------------------------------------------------
// SubstancePattern value object
// ---------------------------------------------------------------------------

class SubstancePattern {
  final String substanceName;
  final int occurrences;
  final double avgNextDayReadiness;
  final double belowFiveRate; // 0.0–1.0
  final List<double> nextDayScores;

  const SubstancePattern({
    required this.substanceName,
    required this.occurrences,
    required this.avgNextDayReadiness,
    required this.belowFiveRate,
    required this.nextDayScores,
  });

  factory SubstancePattern.empty(String name) => SubstancePattern(
        substanceName: name,
        occurrences: 0,
        avgNextDayReadiness: 0,
        belowFiveRate: 0,
        nextDayScores: [],
      );

  String get summaryText {
    if (occurrences < 3) return 'Not enough data yet ($occurrences logs).';
    final pct = (belowFiveRate * 100).toStringAsFixed(0);
    final avg = avgNextDayReadiness.toStringAsFixed(1);
    return 'After $substanceName, avg next-day readiness: $avg/10 '
        '(below 5 on $pct% of days, n=$occurrences)';
  }
}
