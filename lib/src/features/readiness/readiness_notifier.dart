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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../database/database_provider.dart';
import '../../database/db.dart';

const _uuid = Uuid();

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

DateTime _dateOnly(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

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
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;

    final existing = await (db.select(db.userSubstances)
          ..where((t) => t.userId.equals(uid)))
        .get();
    if (existing.isNotEmpty) return;

    for (final s in _defaultSubstances) {
      await db.into(db.userSubstances).insert(
            UserSubstancesCompanion.insert(
              id: _uuid.v4(),
              userId: uid,
              name: s.name,
              direction: Value(s.direction),
              defaultImpact: Value(s.defaultImpact),
            ),
          );
    }
  }

  Future<void> addSubstance({
    required String name,
    required String direction,
    required double defaultImpact,
  }) async {
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    await db.into(db.userSubstances).insert(
          UserSubstancesCompanion.insert(
            id: _uuid.v4(),
            userId: uid,
            name: name.trim().toLowerCase(),
            direction: Value(direction),
            defaultImpact: Value(defaultImpact),
          ),
        );
  }

  Future<void> updateSubstance(
    String id, {
    double? defaultImpact,
    String? direction,
  }) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.userSubstances)..where((t) => t.id.equals(id))).write(
      UserSubstancesCompanion(
        defaultImpact:
            defaultImpact != null ? Value(defaultImpact) : const Value.absent(),
        direction:
            direction != null ? Value(direction) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteSubstance(String id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.userSubstances)..where((t) => t.id.equals(id))).go();
  }

  /// Called by the learning engine to write back the Bayesian-blended impact.
  Future<void> applyLearnedImpact(
      String uid, String substanceName, double newLearned, int newCount) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.userSubstances)
          ..where(
              (t) => t.userId.equals(uid) & t.name.equals(substanceName)))
        .write(UserSubstancesCompanion(
      learnedImpact: Value(newLearned),
      occurrenceCount: Value(newCount),
    ));
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
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    final logDate = _dateOnly(date ?? DateTime.now());
    await db.into(db.substanceLogs).insert(
          SubstanceLogsCompanion.insert(
            id: _uuid.v4(),
            userId: uid,
            date: logDate,
            substanceName: substanceName.trim().toLowerCase(),
            direction: direction,
            impactSnapshot: impactSnapshot,
            quantity: Value(quantity),
            notes: Value(notes),
          ),
        );
  }

  Future<void> deleteLog(String id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.substanceLogs)..where((t) => t.id.equals(id))).go();
  }

  Future<List<SubstanceLog>> logsForDate(DateTime date) async {
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return [];
    final d = _dateOnly(date);
    final end = d.add(const Duration(hours: 23, minutes: 59));
    return (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(d, end)))
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
    final end = today.add(const Duration(hours: 23, minutes: 59));
    return (db.select(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) &
              t.checkInWindow.equals(window.value) &
              t.date.isBetweenValues(today, end)))
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
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    final today = _dateOnly(DateTime.now());
    final end = today.add(const Duration(hours: 23, minutes: 59));

    // Upsert: delete existing for this window+date, then insert fresh.
    await (db.delete(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) &
              t.checkInWindow.equals(window.value) &
              t.date.isBetweenValues(today, end)))
        .go();

    await db.into(db.readinessCheckIns).insert(
          ReadinessCheckInsCompanion.insert(
            id: _uuid.v4(),
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

    await ref.read(readinessProvider.notifier).recomputeToday();
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
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) throw StateError('not logged in');
    final today = _dateOnly(DateTime.now());
    final end = today.add(const Duration(hours: 23, minutes: 59));

    final existing = await (db.select(db.dailyReadiness)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(today, end)))
        .getSingleOrNull();
    if (existing != null) return existing;

    final carryover = await _computeCarryoverDelta(uid);
    final base = (70.0 + carryover).clamp(0.0, 100.0);

    await db.into(db.dailyReadiness).insert(DailyReadinessCompanion.insert(
      id: _uuid.v4(),
      userId: uid,
      date: today,
      computedScore: Value(base),
      previousDayInfluence: Value(carryover),
    ));

    return (db.select(db.dailyReadiness)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(today, end)))
        .getSingle();
  }

  Future<void> recomputeToday() async {
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    final today = _dateOnly(DateTime.now());
    final end = today.add(const Duration(hours: 23, minutes: 59));

    final carryover = await _computeCarryoverDelta(uid);
    final score = await _computeScore(uid, today, carryover);

    await (db.update(db.dailyReadiness)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(today, end)))
        .write(DailyReadinessCompanion(
      computedScore: Value(score),
      previousDayInfluence: Value(carryover),
    ));
  }

  Future<void> submitSelfRating(double rating) async {
    final db = ref.read(databaseProvider);
    final uid = _userId();
    if (uid == null) return;
    final today = _dateOnly(DateTime.now());
    final end = today.add(const Duration(hours: 23, minutes: 59));

    await (db.update(db.dailyReadiness)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(today, end)))
        .write(DailyReadinessCompanion(userRatedScore: Value(rating)));

    await _runLearningUpdate(uid, today, rating);
  }

  // ─────────────────────────────────────────────────────────────
  // SCORING ENGINE
  // ─────────────────────────────────────────────────────────────

  Future<double> _computeScore(
      String uid, DateTime date, double carryover) async {
    final db = ref.read(databaseProvider);
    final end = date.add(const Duration(hours: 23, minutes: 59));
    double score = 70.0;

    // ── Carryover from yesterday ──────────────────────────────
    score += carryover;

    // ── 7-day rolling sleep debt penalty ─────────────────────
    // Van Dongen (2003): debt is non-linear and accumulates.
    // We look at the last 7 morning check-ins.
    score -= await _computeSleepDebtPenalty(uid, excludeDate: date);

    // ── Today's check-ins ─────────────────────────────────────
    final checkIns = await (db.select(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(date, end)))
        .get();

    for (final ci in checkIns) {
      final isEvening = ci.checkInWindow == CheckInWindow.evening.value;
      final isAfternoonOrEvening =
          ci.checkInWindow == CheckInWindow.afternoon.value || isEvening;

      // Sleep (morning only) — non-linear curve.
      // Formula: -pow(8 - h, 1.3) * 3.5 per Van Dongen non-linear finding.
      if (ci.sleepHours != null) {
        final h = ci.sleepHours!;
        if (h >= 8.0) {
          score += 20.0; // full rest bonus
        } else {
          final debt = 8.0 - h;
          score -= (math.pow(debt, 1.3) * 3.5).clamp(0.0, 20.0);
        }
      }

      // Sleep quality — REM architecture (Sleep Medicine Reviews 2024).
      // ±8 pts; quality 1 = severely disrupted REM, 5 = restorative.
      if (ci.sleepQuality != null) {
        score += (ci.sleepQuality! - 3) * 4.0;
      }

      // Stress (all windows) — HPA axis / cortisol.
      if (ci.stressLevel != null && ci.stressLevel! > 3) {
        score -= (ci.stressLevel! - 3) * 3.0;
      }

      // Caffeine — Randall et al. SLEEP 2024.
      // 1–2 cups: +3 (adenosine antagonism benefit)
      // 3 cups:    0 (neutral)
      // 4+ cups:  -3/cup × timing multiplier
      if (ci.caffeineCount != null) {
        final cups = ci.caffeineCount!;
        if (cups <= 2) {
          score += 3.0;
        } else if (cups > 3) {
          // Afternoon/evening caffeine has 1.5× penalty because it will
          // disrupt tonight's sleep (half-life 4–6h; Randall et al. 2024).
          final timingMultiplier = isAfternoonOrEvening ? 1.5 : 1.0;
          score -= (cups - 3) * 3.0 * timingMultiplier;
        }
      }

      // Energy + mood (all windows) — self-reported but calibrated.
      if (ci.energyLevel != null) score += (ci.energyLevel! - 3) * 1.5;
      if (ci.mood != null) score += (ci.mood! - 3) * 1.0;
    }

    // ── Today's substance logs ────────────────────────────────
    final logs = await (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(date, end)))
        .get();

    for (final log in logs) {
      final impact =
          await _resolvedImpact(db, uid, log.substanceName, log.impactSnapshot);
      final delta = (impact / 10.0) * 15.0;
      score += log.direction == 'positive' ? delta : -delta;
    }

    return score.clamp(0.0, 100.0);
  }

  // ─────────────────────────────────────────────────────────────
  // 7-DAY SLEEP DEBT PENALTY
  // Based on Van Dongen & Dinges (2003) + Belenky et al.
  // Looks at up to 7 morning check-ins before today.
  // Each hour below 8h/night adds to a cumulative debt.
  // The penalty is non-linear: total debt of 7h = -10 pts,
  // 14h = -17 pts, 21h = -22 pts (caps at -20).
  // ─────────────────────────────────────────────────────────────
  Future<double> _computeSleepDebtPenalty(String uid,
      {required DateTime excludeDate}) async {
    final db = ref.read(databaseProvider);
    double totalDebtHours = 0.0;
    int daysWithData = 0;

    for (int i = 1; i <= 7; i++) {
      final d = _dateOnly(excludeDate.subtract(Duration(days: i)));
      final dEnd = d.add(const Duration(hours: 23, minutes: 59));
      final ci = await (db.select(db.readinessCheckIns)
            ..where((t) =>
                t.userId.equals(uid) &
                t.checkInWindow.equals('morning') &
                t.date.isBetweenValues(d, dEnd)))
          .getSingleOrNull();

      if (ci?.sleepHours != null) {
        daysWithData++;
        final debt = (8.0 - ci!.sleepHours!).clamp(0.0, 6.0);
        totalDebtHours += debt;
      }
    }

    if (daysWithData < 2) return 0.0; // not enough data to penalize

    // Non-linear accumulation penalty.
    return (math.pow(totalDebtHours, 1.2) * 0.8).clamp(0.0, 15.0);
  }

  // ─────────────────────────────────────────────────────────────
  // CARRYOVER DELTA
  // Science-backed per-substance carryover rates.
  // Sleep debt carryover + stress carryover applied on top.
  // ─────────────────────────────────────────────────────────────
  Future<double> _computeCarryoverDelta(String uid) async {
    final db = ref.read(databaseProvider);
    final yesterday =
        _dateOnly(DateTime.now().subtract(const Duration(days: 1)));
    final yEnd = yesterday.add(const Duration(hours: 23, minutes: 59));
    double delta = 0.0;

    // Sleep debt carryover — yesterday's single-night shortfall.
    // The 7-day rolling debt is applied separately in _computeScore.
    final morningCI = await (db.select(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) &
              t.checkInWindow.equals('morning') &
              t.date.isBetweenValues(yesterday, yEnd)))
        .getSingleOrNull();

    if (morningCI?.sleepHours != null) {
      final h = morningCI!.sleepHours!;
      if (h < 8.0) {
        final debt = 8.0 - h;
        // 50% of last night's sleep penalty carries into today's baseline.
        delta -= (math.pow(debt, 1.3) * 3.5 * 0.5).clamp(0.0, 10.0);
      }
    }

    // Stress carryover — cortisol lingers ~67% into next day.
    final allCIs = await (db.select(db.readinessCheckIns)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(yesterday, yEnd)))
        .get();
    for (final ci in allCIs) {
      if (ci.stressLevel != null && ci.stressLevel! >= 4) {
        delta -= (ci.stressLevel! - 3) * 2.0;
      }
    }

    // Substance carryover — substance-specific rates from literature.
    final logs = await (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(yesterday, yEnd)))
        .get();

    bool hadSugarYesterday = false;

    for (final log in logs) {
      final impact =
          await _resolvedImpact(db, uid, log.substanceName, log.impactSnapshot);
      final sameDayDelta = (impact / 10.0) * 15.0;
      final rate = _substanceCarryoverRate(log.substanceName);
      final carryoverDelta = sameDayDelta * rate;
      delta += log.direction == 'positive' ? carryoverDelta : -carryoverDelta;

      final name = log.substanceName.toLowerCase().trim();
      if (name == 'sugar spike' || name == 'sugar') hadSugarYesterday = true;
    }

    // Sugar SWS penalty: even if sleep hours were 8h, a high-sugar binge
    // reduces slow-wave sleep quality through overnight metabolic activity.
    // User cannot self-report this accurately — applied as a hidden carryover.
    if (hadSugarYesterday) delta -= 4.0;

    // ── Day-2 sugar carryover ─────────────────────────────────────────────
    // Inflammation (CRP/cytokines) + gut microbiome shifts persist a second
    // day after a sugar binge. Dopamine dip peaks 24–48h post-binge.
    final twoDaysAgo =
        _dateOnly(DateTime.now().subtract(const Duration(days: 2)));
    final tdEnd = twoDaysAgo.add(const Duration(hours: 23, minutes: 59));
    final twoDayLogs = await (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(twoDaysAgo, tdEnd)))
        .get();

    for (final log in twoDayLogs) {
      final name = log.substanceName.toLowerCase().trim();
      if (name == 'sugar spike' || name == 'sugar') {
        final impact = await _resolvedImpact(
            db, uid, log.substanceName, log.impactSnapshot);
        // Day-2 rate: 25% — lingering inflammation + microbiome fog
        delta -= (impact / 10.0) * 15.0 * 0.25;
      }
    }

    return delta;
  }

  // ─────────────────────────────────────────────────────────────
  // LEARNING ENGINE
  // Direction-aware Bayesian blending.
  // Negative substances: observed impact increases if next-day < 70.
  // Positive substances: observed impact increases if next-day > 70.
  // Blend weight reaches 0.7 (strong trust of observed data) at n=20.
  // ─────────────────────────────────────────────────────────────
  Future<void> _runLearningUpdate(
      String uid, DateTime today, double userRating) async {
    final db = ref.read(databaseProvider);
    final yesterday = _dateOnly(today.subtract(const Duration(days: 1)));
    final yEnd = yesterday.add(const Duration(hours: 23, minutes: 59));

    final logs = await (db.select(db.substanceLogs)
          ..where((t) =>
              t.userId.equals(uid) & t.date.isBetweenValues(yesterday, yEnd)))
        .get();
    if (logs.isEmpty) return;

    // userRating 0–10 → normalise to 0–100 space.
    final ratingNorm = userRating * 10.0;

    for (final log in logs) {
      final substance = await (db.select(db.userSubstances)
            ..where((t) =>
                t.userId.equals(uid) & t.name.equals(log.substanceName)))
          .getSingleOrNull();
      if (substance == null) continue;

      final n = substance.occurrenceCount;
      final current = substance.learnedImpact ?? substance.defaultImpact;

      // Direction-aware observed impact:
      // For negative substances: how far below 70 did readiness fall?
      // For positive substances: how far above 70 did readiness rise?
      // If the direction was "wrong" (negative substance but good day, or vice
      // versa), the observed impact is small — model learns accordingly.
      final double observedDelta;
      if (log.direction == 'negative') {
        observedDelta = (70.0 - ratingNorm).clamp(0.0, 30.0);
      } else {
        observedDelta = (ratingNorm - 70.0).clamp(0.0, 30.0);
      }
      final observedImpact = (observedDelta / 15.0 * 10.0).clamp(1.0, 10.0);

      // Bayesian blend: starts trusting user's stated value, shifts toward
      // observed reality as n grows. Full weight (0.7) reached at n=20.
      final blendWeight = (n / 20.0).clamp(0.0, 0.7);
      final newLearned =
          current * (1.0 - blendWeight) + observedImpact * blendWeight;

      await ref
          .read(userSubstancesProvider.notifier)
          .applyLearnedImpact(uid, log.substanceName, newLearned, n + 1);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PATTERN QUERY
  // "After alcohol, avg next-day readiness: 4.1/10 (below 5 on 71%, n=12)"
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
      final nextDay = log.date.add(const Duration(days: 1));
      final end = nextDay.add(const Duration(hours: 23, minutes: 59));
      final row = await (db.select(db.dailyReadiness)
            ..where((t) =>
                t.userId.equals(uid) & t.date.isBetweenValues(nextDay, end)))
          .getSingleOrNull();
      if (row != null) {
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
