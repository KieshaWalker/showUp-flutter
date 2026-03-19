// readiness_screen.dart — Readiness hub: score ring, time-gated check-ins,
// substance logging, and learned pattern insights.
//
// Exported widgets (importable by other screens):
//   ReadinessSummaryCard — compact score ring + status for presentation_screen
//
// Full screen sections:
//   • Score ring with colour gradient (green → ochre → terracotta)
//   • Today's influencers: what's helping vs dragging
//   • Time-gated check-in card (morning / afternoon / evening questions)
//   • Substance log for today + quick-add from library
//   • Pattern insight: "After alcohol, you feel below 5 on 71% of days"
//
// Connections:
//   readiness_notifier.dart — all four providers + helpers
//   app_theme.dart          — AppGlass, AppColors, AppTextStyles

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../database/db.dart';
import 'readiness_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FULL READINESS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ReadinessScreen extends ConsumerStatefulWidget {
  const ReadinessScreen({super.key});

  @override
  ConsumerState<ReadinessScreen> createState() => _ReadinessScreenState();
}

class _ReadinessScreenState extends ConsumerState<ReadinessScreen> {
  DailyReadinessData? _todaysRow;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureToday());
  }

  Future<void> _ensureToday() async {
    debugPrint('[ReadinessScreen] _ensureToday — fetching');
    final row = await ref.read(readinessProvider.notifier).todaysReadiness();
    debugPrint(
      '[ReadinessScreen] _ensureToday — score=${row.computedScore.toStringAsFixed(1)} rated=${row.userRatedScore}',
    );
    if (mounted) setState(() => _todaysRow = row);
  }

  @override
  Widget build(BuildContext context) {
    final checkIns = ref.watch(checkInsProvider).value ?? [];
    final substances = ref.watch(substanceLogsProvider).value ?? [];
    final window = currentWindow();
    final hasCheckIn = checkIns.any(
      (c) => c.checkInWindow == window.value && _isToday(c.date),
    );
    final todaySubstances = substances.where((s) => _isToday(s.date)).toList();
    final yesterdaySubstances =
        substances.where((s) => _isYesterday(s.date)).toList();

    final score = _todaysRow?.computedScore ?? 70.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 46, 16, 32),
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Text('Readiness', style: AppTextStyles.displayLarge),
          const SizedBox(height: 4),
          Text(_windowGreeting(window), style: AppTextStyles.bodyMedium),
          const SizedBox(height: 20),

          // ── Score ring ─────────────────────────────────────────────────────
          _ScoreRingCard(score: score, todaysRow: _todaysRow),
          const SizedBox(height: 6),

          // ── Check-in card ───────────────────────────────────────────────────
          if (!hasCheckIn)
            _CheckInPromptCard(window: window, onDone: _ensureToday),
          if (hasCheckIn)
            _CheckInDoneCard(
              window: window,
              onEdit: () => _showCheckIn(context, window),
            ),
          const SizedBox(height: 6),

         // ── Substance logs — Side by Side ─────────────────────────────────────
  IntrinsicHeight(
    child: Row(
  crossAxisAlignment: CrossAxisAlignment.start, // Keeps tops aligned
  children: [
    Expanded(
      child: _SubstanceLogCard(
        title: "Today", // Shortened title to fit better
        logs: todaySubstances,
        onAdd: () => _showSubstanceSheet(context, null),
      ),
    ),
    const SizedBox(width: 6), // Gap between the two cards
    Expanded(
      child: _SubstanceLogCard(
        title: 'Yesterday',
        logs: yesterdaySubstances,
        onAdd: () => _showSubstanceSheet(
          context,
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      ),
    ),
  ],
),
  ),
          const SizedBox(height: 6),
          // ── Pattern insights ────────────────────────────────────────────────
          _PatternInsightsCard(substances: todaySubstances),
          const SizedBox(height: 6),

          // ── Self-rating ─────────────────────────────────────────────────────
          _SelfRatingCard(
            current: _todaysRow?.userRatedScore,
            onRate: (v) async {
              debugPrint('[ReadinessScreen] submitSelfRating — value=$v');
              await ref.read(readinessProvider.notifier).submitSelfRating(v);
              _ensureToday();
            },
          ),
          const SizedBox(height: 16),

          // ── Substance science ───────────────────────────────────────────────
          const _SubstanceScienceSection(),
        ],
      ),
    );
  }

  void _showCheckIn(BuildContext context, CheckInWindow window) {
    debugPrint('[ReadinessScreen] _showCheckIn — window=${window.name}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckInSheet(window: window, onDone: _ensureToday),
    );
  }

  void _showSubstanceSheet(BuildContext context, DateTime? date) {
    debugPrint(
      '[ReadinessScreen] _showSubstanceSheet — date=${date ?? 'today'}',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubstanceLogSheet(date: date, onDone: _ensureToday),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPORTABLE SUMMARY CARD — used in presentation_screen
// ─────────────────────────────────────────────────────────────────────────────

class ReadinessSummaryCard extends ConsumerStatefulWidget {
  const ReadinessSummaryCard({super.key});

  @override
  ConsumerState<ReadinessSummaryCard> createState() =>
      _ReadinessSummaryCardState();
}

class _ReadinessSummaryCardState extends ConsumerState<ReadinessSummaryCard> {
  DailyReadinessData? _row;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final row = await ref.read(readinessProvider.notifier).todaysReadiness();
      if (mounted) setState(() => _row = row);
    });
  }

  @override
  Widget build(BuildContext context) {
    final score = _row?.computedScore ?? 70.0;
    final window = currentWindow();
    final checkIns = ref.watch(checkInsProvider).value ?? [];
    final hasCheckIn = checkIns.any(
      (c) => c.checkInWindow == window.value && _isToday(c.date),
    );

    return AppGlass.card(
      padding: const EdgeInsets.all(50),
      child: Row(
        children: [
          // Mini ring
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _ArcPainter(score / 100, _scoreColor(score), thin: true),
              child: Center(
                child: Text(
                  score.round().toString(),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _scoreColor(score),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Readiness', style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(_scoreLabel(score), style: AppTextStyles.bodyMedium),
                const SizedBox(height: 6),
                if (!hasCheckIn)
                  Text(
                    '${_windowLabel(window)} check-in pending',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.ochre,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textOnDarkTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCORE RING CARD
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreRingCard extends StatelessWidget {
  final double score;
  final DailyReadinessData? todaysRow;

  const _ScoreRingCard({required this.score, this.todaysRow});

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);
    return AppGlass.card(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CustomPaint(
              painter: _ArcPainter(score / 100, color),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score.round().toString(),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: color,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDarkTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _scoreLabel(score),
            style: AppTextStyles.titleLarge.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            _scoreSubtitle(score),
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (todaysRow?.previousDayInfluence != null &&
              todaysRow!.previousDayInfluence != 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.glassBg,
                borderRadius: AppRadius.smAll,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    todaysRow!.previousDayInfluence < 0
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    size: 13,
                    color:
                        todaysRow!.previousDayInfluence < 0
                            ? AppColors.terracotta
                            : AppColors.eucalyptus,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${todaysRow!.previousDayInfluence.abs().toStringAsFixed(1)} pts from yesterday',
                    style: AppTextStyles.labelSmall.copyWith(
                      color:
                          todaysRow!.previousDayInfluence < 0
                              ? AppColors.terracotta
                              : AppColors.eucalyptus,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK-IN PROMPT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CheckInPromptCard extends ConsumerWidget {
  final CheckInWindow window;
  final VoidCallback onDone;

  const _CheckInPromptCard({required this.window, required this.onDone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppGlass.card(
      padding: const EdgeInsets.all(20),
      bg: const Color(0x33D04820),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.glassBg,
                  borderRadius: AppRadius.smAll,
                ),
                child: Icon(
                  _windowIcon(window),
                  color: AppColors.terracotta,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _windowLabel(window),
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_windowPrompt(window), style: AppTextStyles.bodyLarge),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder:
                        (_) => _CheckInSheet(window: window, onDone: onDone),
                  ),
              child: Text('Start ${_windowLabel(window)} Check-in'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInDoneCard extends StatelessWidget {
  final CheckInWindow window;
  final VoidCallback onEdit;

  const _CheckInDoneCard({required this.window, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return AppGlass.card(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0x334A9C2F),
              borderRadius: AppRadius.smAll,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.eucalyptus,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_windowLabel(window)} done',
                  style: AppTextStyles.titleMedium,
                ),
                Text('Check-in logged', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Edit')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBSTANCE TODAY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SubstanceLogCard extends ConsumerWidget {
  final String title;
  final List<SubstanceLog> logs;
  final VoidCallback onAdd;

  const _SubstanceLogCard({
    required this.title,
    required this.logs,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppGlass.card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.titleMedium),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassBg,
                    borderRadius: AppRadius.smAll,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add,
                        size: 14,
                        color: AppColors.textOnDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Log',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (logs.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Nothing logged today.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...logs.map(
              (log) => _SubstanceLogRow(
                log: log,
                onDelete: () {
                  debugPrint(
                    '[ReadinessScreen] deleteLog — id=${log.id} substance=${log.substanceName}',
                  );
                  ref.read(substanceLogsProvider.notifier).deleteLog(log.id);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubstanceLogRow extends StatelessWidget {
  final SubstanceLog log;
  final VoidCallback onDelete;

  const _SubstanceLogRow({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isPositive = log.direction == 'positive';
    final color = isPositive ? AppColors.eucalyptus : AppColors.terracotta;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppRadius.smAll,
            ),
            child: Center(
              child: Text(
                isPositive ? '+' : '−',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(log.substanceName),
                  style: AppTextStyles.bodyLarge,
                ),
                if (log.quantity != null)
                  Text(log.quantity!, style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Text(
            '${log.impactSnapshot.toStringAsFixed(0)}/10',
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.textOnDarkTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PATTERN INSIGHTS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PatternInsightsCard extends ConsumerWidget {
  final List<SubstanceLog> substances;

  const _PatternInsightsCard({required this.substances});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allLogs = ref.watch(substanceLogsProvider).value ?? [];
    // Only show substances that have been logged ≥3 times (minimum for a pattern).
    final counts = <String, int>{};
    for (final l in allLogs) {
      counts[l.substanceName] = (counts[l.substanceName] ?? 0) + 1;
    }
    final names = counts.entries
        .where((e) => e.value >= 3)
        .map((e) => e.key)
        .toList();

    if (names.isEmpty) return const SizedBox.shrink();

    return AppGlass.card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, size: 16, color: AppColors.ochre),
              const SizedBox(width: 8),
              Text('What the data shows', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          ...names.take(3).map((name) => _PatternRow(substanceName: name)),
        ],
      ),
    );
  }
}

class _PatternRow extends ConsumerStatefulWidget {
  final String substanceName;

  const _PatternRow({required this.substanceName});

  @override
  ConsumerState<_PatternRow> createState() => _PatternRowState();
}

class _PatternRowState extends ConsumerState<_PatternRow> {
  SubstancePattern? _pattern;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final p = await ref
        .read(readinessProvider.notifier)
        .getSubstancePattern(widget.substanceName);
    if (mounted) setState(() => _pattern = p);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(readinessProvider, (_, _) => _load());
    ref.listen(substanceLogsProvider, (_, _) => _load());

    if (_pattern == null || _pattern!.occurrences < 3) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          '${_capitalize(widget.substanceName)}: collecting data...',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _capitalize(widget.substanceName),
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(_pattern!.summaryText, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: LinearProgressIndicator(
              value: _pattern!.belowFiveRate,
              backgroundColor: AppColors.glassBorder,
              color: _belowFiveColor(_pattern!.belowFiveRate),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELF-RATING CARD
// ─────────────────────────────────────────────────────────────────────────────

class _SelfRatingCard extends StatefulWidget {
  final double? current;
  final ValueChanged<double> onRate;

  const _SelfRatingCard({this.current, required this.onRate});

  @override
  State<_SelfRatingCard> createState() => _SelfRatingCardState();
}

class _SelfRatingCardState extends State<_SelfRatingCard> {
  double _value = 7;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.current != null) {
      _value = widget.current!;
      _submitted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGlass.card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How do you actually feel?', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Your honest rating trains the learning engine.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(11, (i) {
              final selected = _value.round() == i;
              return GestureDetector(
                onTap: () => setState(() => _value = i.toDouble()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: selected ? 34 : 26,
                  height: selected ? 34 : 26,
                  decoration: BoxDecoration(
                    color:
                        selected ? _scoreColor(_value * 10) : AppColors.glassBg,
                    borderRadius: AppRadius.smAll,
                    border: Border.all(
                      color:
                          selected
                              ? _scoreColor(_value * 10)
                              : AppColors.glassBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$i',
                      style: TextStyle(
                        fontSize: selected ? 13 : 11,
                        fontWeight: FontWeight.w600,
                        color:
                            selected
                                ? Colors.white
                                : AppColors.textOnDarkTertiary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          if (!_submitted)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onRate(_value);
                  setState(() => _submitted = true);
                },
                child: const Text('Submit Rating'),
              ),
            )
          else
            Center(
              child: Text(
                'Rated ${_value.round()}/10 — learning updated',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.eucalyptus,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBSTANCE SCIENCE SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _SubstanceEntry {
  final String name;
  final bool positive;
  final IconData icon;
  final String tagline;
  final String detail;
  final String appDefault; // e.g. "−7/10" or "via check-in"
  final String carryover;  // e.g. "65%" or "none"

  const _SubstanceEntry({
    required this.name,
    required this.positive,
    required this.icon,
    required this.tagline,
    required this.detail,
    required this.appDefault,
    required this.carryover,
  });
}

const _kSubstanceEntries = [
  _SubstanceEntry(
    name: 'Alcohol',
    positive: false,
    icon: Icons.local_bar_outlined,
    tagline: '2 drinks delays REM by 18 min. You feel like you slept fine — your brain didn\'t recover.',
    detail:
        'A 27-study meta-analysis (Sleep Medicine Reviews, 2024) found alcohol at 0.5 g/kg cuts REM '
        'duration by 11 minutes and delays onset by 18 minutes. At 4+ drinks REM is severely fragmented, '
        'with rebound insomnia in the second half of the night. Total sleep time barely changes — so drinkers '
        'genuinely believe they slept well. Cortisol remains elevated all morning even after BAC hits zero. '
        'Cognitive deficits (reaction time, recall, multitasking) persist 12–24 hours for moderate drinking. '
        'Women are measurably more affected than men on objective metrics.',
    appDefault: '−7/10',
    carryover: '65%',
  ),
  _SubstanceEntry(
    name: 'Cannabis',
    positive: false,
    icon: Icons.spa_outlined,
    tagline: 'Only 3.5% of next-day tests show impairment — but chronic use compounds differently.',
    detail:
        'A University of Sydney systematic review (16 studies, 2023) found only 3.5% of next-day '
        'performance tests showed significant impairment — far below alcohol. Cannabis suppresses REM '
        'acutely (similar direction to alcohol, different mechanism). On withdrawal: REM rebound with '
        'vivid dreams and disrupted sleep for 1–4 weeks. Heavy chronic use leads to working memory and '
        'processing speed deficits that persist days into abstinence. CBD appears to buffer most negative '
        'cognitive and anxiogenic effects of THC — which is why CBD carries a positive default.',
    appDefault: '−3/10',
    carryover: '30%',
  ),
  _SubstanceEntry(
    name: 'Sugar spike',
    positive: false,
    icon: Icons.cake_outlined,
    tagline: 'Zero evidence for a sugar rush. Strong evidence for a two-day crash.',
    detail:
        'A meta-analysis of 31 studies (Neuroscience & Biobehavioral Reviews, 2019) found no evidence '
        'for a sugar rush in healthy adults — and strong evidence for a crash at 30–60 minutes. Beyond that: '
        'a single high-glycemic meal spikes CRP and cytokines (inflammation persists 1–2 days, causing joint '
        'stiffness and malaise). The brain down-regulates dopamine receptors after a large release, creating '
        'a motivation and mood dip 24–48 hours later. High sugar also disrupts slow-wave sleep even when '
        'total hours look fine, and gut flora shifts within 24h produce brain-fog byproducts for several days.',
    appDefault: '−3/10',
    carryover: '55% day 1, 25% day 2',
  ),
  _SubstanceEntry(
    name: 'Caffeine',
    positive: false,
    icon: Icons.coffee_outlined,
    tagline: 'Half-life 4–6h. A 3pm cup is still 50% active at midnight for slow metabolisers.',
    detail:
        'A 2024 randomised crossover trial (SLEEP journal) found 400mg consumed 4 hours before bed '
        'cuts total sleep by 20+ minutes. 1–2 cups provide an alertness boost via adenosine antagonism; '
        '3+ cups tip into anxiety and cortisol spikes. The CYP1A2 gene splits people into fast metabolisers '
        '(half-life 3–4h) and slow (7–10h) — for slow metabolisers, a 3pm coffee is still half-active at '
        'midnight. Afternoon and evening caffeine carries a 1.5× score penalty to reflect this. '
        'Caffeine is tracked via the count field in your check-in, not as a substance log.',
    appDefault: 'via check-in',
    carryover: 'none',
  ),
  _SubstanceEntry(
    name: 'Nicotine',
    positive: false,
    icon: Icons.air_outlined,
    tagline: 'Withdrawal starts 2–4h after last use, cycling through the night.',
    detail:
        'Nicotine has a half-life of ~2 hours, so withdrawal begins during sleep for most users. '
        'Westminster Research and PMC 2013 data show the withdrawal cycle disrupts sleep architecture '
        'and elevates morning cortisol baseline. The result: lighter sleep, more arousals, and blunted '
        'morning alertness. The 40% carryover reflects the next-morning cortisol disruption that '
        'persists even after the nicotine itself has fully metabolised.',
    appDefault: '−4/10',
    carryover: '40%',
  ),
  _SubstanceEntry(
    name: 'Psilocybin (microdose)',
    positive: true,
    icon: Icons.grain_outlined,
    tagline: 'One confirmed benefit in blind conditions: divergent thinking. The rest is likely expectancy.',
    detail:
        'Three double-blind RCTs (Szigeti/Erritzoe, 2025) are the most rigorous data yet. '
        'One finding survived blinding: increased originality in divergent thinking tasks. '
        'Mood, energy, focus, and general cognitive performance effects largely disappeared when '
        'participants didn\'t know whether they received the dose. Observational studies show large effects '
        '— but expectancy accounts for most of it. No hangover or carryover at microdose levels. '
        'The app default is intentionally low (+2) so your personal logged data takes over quickly.',
    appDefault: '+2/10',
    carryover: 'none',
  ),
  _SubstanceEntry(
    name: 'Sleep deprivation',
    positive: false,
    icon: Icons.bedtime_outlined,
    tagline: '6h/night for 2 weeks equals 2 nights of zero sleep — and you won\'t know it.',
    detail:
        'Van Dongen & Dinges (UPenn, SLEEP 2003) — still the defining dataset. At 6h/night for '
        '14 days, performance equals 48h of total deprivation, yet subjects rated their sleepiness '
        'as only mildly elevated. At 5h/night: equivalent to 3+ nights of zero sleep. A 2025 Frontiers '
        'study found chronic partial restriction produces 17ms longer reaction times than acute total '
        'deprivation — because chronic loss feels normal. Recovery is slow: 7 nights at 5h/night '
        'requires 3+ recovery nights to restore performance, not one. '
        'Sleep is the single biggest lever in the readiness model.',
    appDefault: 'scored directly',
    carryover: '50% of last-night penalty',
  ),
];

class _SubstanceScienceSection extends StatelessWidget {
  const _SubstanceScienceSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.science_outlined, size: 16, color: AppColors.khaki),
            const SizedBox(width: 8),
            Text('The Science', style: AppTextStyles.titleLarge),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'How common substances affect readiness — and why.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 12),
        ..._kSubstanceEntries.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SubstanceInfoCard(entry: s),
          ),
        ),
      ],
    );
  }
}

class _SubstanceInfoCard extends StatefulWidget {
  final _SubstanceEntry entry;
  const _SubstanceInfoCard({required this.entry});

  @override
  State<_SubstanceInfoCard> createState() => _SubstanceInfoCardState();
}

class _SubstanceInfoCardState extends State<_SubstanceInfoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final accentColor = e.positive ? AppColors.eucalyptus : AppColors.terracotta;

    return AppGlass.card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row (always visible) ──────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Icon(e.icon, size: 18, color: accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(e.name, style: AppTextStyles.titleMedium),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: AppRadius.smAll,
                                border: Border.all(
                                    color: accentColor.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                e.appDefault,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          e.tagline,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnDarkSecondary,
                          ),
                          maxLines: _expanded ? null : 2,
                          overflow:
                              _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: AppColors.textOnDarkTertiary,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded detail ──────────────────────────────────────────────
          if (_expanded) ...[
            Divider(
              height: 1,
              color: AppColors.glassBorder,
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.detail, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoPill(
                        label: 'Next-day carryover',
                        value: e.carryover,
                        color: e.carryover == 'none'
                            ? AppColors.eucalyptus
                            : AppColors.ochre,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.smAll,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textOnDarkTertiary,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK-IN BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _CheckInSheet extends ConsumerStatefulWidget {
  final CheckInWindow window;
  final VoidCallback onDone;

  const _CheckInSheet({required this.window, required this.onDone});

  @override
  ConsumerState<_CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends ConsumerState<_CheckInSheet> {
  double _sleepHours = 7.5;
  int _sleepQuality = 3;
  int _stressLevel = 3;
  int _energyLevel = 3;
  int _mood = 3;
  int _caffeineCount = 1;
  int _focusLevel = 3;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: AppGlass.modal(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: AppRadius.smAll,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    _windowIcon(widget.window),
                    color: AppColors.terracotta,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_windowLabel(widget.window)} Check-in',
                    style: AppTextStyles.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Morning: sleep ────────────────────────────────────────────
              if (widget.window == CheckInWindow.morning) ...[
                _SheetLabel('How many hours did you sleep?'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _sleepHours,
                        min: 2,
                        max: 12,
                        divisions: 20,
                        onChanged: (v) => setState(() => _sleepHours = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_sleepHours.toStringAsFixed(1)}h',
                      style: AppTextStyles.titleMedium.copyWith(
                        color:
                            _sleepHours >= 8
                                ? AppColors.eucalyptus
                                : AppColors.terracotta,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SheetLabel('Sleep quality'),
                const SizedBox(height: 8),
                _RatingRow(
                  value: _sleepQuality,
                  labels: const ['Poor', '', '', '', 'Great'],
                  onChanged: (v) => setState(() => _sleepQuality = v),
                ),
                const SizedBox(height: 16),
              ],

              // ── All: stress ───────────────────────────────────────────────
              _SheetLabel('Stress level'),
              const SizedBox(height: 8),
              _RatingRow(
                value: _stressLevel,
                labels: const ['Calm', '', '', '', 'Wired'],
                onChanged: (v) => setState(() => _stressLevel = v),
              ),
              const SizedBox(height: 16),

              // ── All: energy + mood ────────────────────────────────────────
              _SheetLabel('Energy level'),
              const SizedBox(height: 8),
              _RatingRow(
                value: _energyLevel,
                labels: const ['Dead', '', '', '', 'Buzzing'],
                onChanged: (v) => setState(() => _energyLevel = v),
              ),
              const SizedBox(height: 16),

              _SheetLabel('Mood'),
              const SizedBox(height: 8),
              _RatingRow(
                value: _mood,
                labels: const ['Low', '', '', '', 'Great'],
                onChanged: (v) => setState(() => _mood = v),
              ),
              const SizedBox(height: 16),

              // ── Afternoon: caffeine + focus ───────────────────────────────
              if (widget.window == CheckInWindow.afternoon ||
                  widget.window == CheckInWindow.evening) ...[
                _SheetLabel('Cups of caffeine today'),
                const SizedBox(height: 8),
                _CounterRow(
                  value: _caffeineCount,
                  max: 10,
                  onChanged: (v) => setState(() => _caffeineCount = v),
                ),
                const SizedBox(height: 16),
                _SheetLabel('Focus level'),
                const SizedBox(height: 8),
                _RatingRow(
                  value: _focusLevel,
                  labels: const ['Scattered', '', '', '', 'Locked in'],
                  onChanged: (v) => setState(() => _focusLevel = v),
                ),
                const SizedBox(height: 16),
              ],

              // ── Notes ─────────────────────────────────────────────────────
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Anything else on your mind?',
                  labelText: 'Notes (optional)',
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Save Check-in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    debugPrint(
      '[ReadinessScreen:CheckInSheet] _submit — window=${widget.window.name} sleep=$_sleepHours quality=$_sleepQuality stress=$_stressLevel energy=$_energyLevel mood=$_mood caffeine=$_caffeineCount focus=$_focusLevel',
    );
    await ref
        .read(checkInsProvider.notifier)
        .submitCheckIn(
          window: widget.window,
          sleepHours:
              widget.window == CheckInWindow.morning ? _sleepHours : null,
          sleepQuality:
              widget.window == CheckInWindow.morning ? _sleepQuality : null,
          stressLevel: _stressLevel,
          energyLevel: _energyLevel,
          mood: _mood,
          caffeineCount:
              widget.window != CheckInWindow.morning ? _caffeineCount : null,
          focusLevel:
              widget.window != CheckInWindow.morning ? _focusLevel : null,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
    if (mounted) {
      Navigator.pop(context);
      widget.onDone();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBSTANCE LOG BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _SubstanceLogSheet extends ConsumerStatefulWidget {
  final DateTime? date; // null = today
  final VoidCallback onDone;

  const _SubstanceLogSheet({this.date, required this.onDone});

  @override
  ConsumerState<_SubstanceLogSheet> createState() => _SubstanceLogSheetState();
}

class _SubstanceLogSheetState extends ConsumerState<_SubstanceLogSheet> {
  final _nameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  String _direction = 'negative';
  double _impact = 5.0;
  UserSubstance? _selected;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(userSubstancesProvider).value ?? [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: AppGlass.modal(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: AppRadius.smAll,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.date == null ? 'Log a Substance' : 'Log for Yesterday',
                style: AppTextStyles.titleLarge,
              ),
              if (widget.date != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Adding to yesterday\'s record',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.ochre,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Saved library chips
              if (library.isNotEmpty) ...[
                Text('Your library', style: AppTextStyles.labelSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      library.map((s) {
                        final isSel = _selected?.id == s.id;
                        return GestureDetector(
                          onTap:
                              () => setState(() {
                                _selected = s;
                                _nameCtrl.text = s.name;
                                _direction = s.direction;
                                _impact = s.learnedImpact ?? s.defaultImpact;
                              }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSel
                                      ? AppColors.terracotta.withValues(
                                        alpha: 0.25,
                                      )
                                      : AppColors.glassBg,
                              borderRadius: AppRadius.smAll,
                              border: Border.all(
                                color:
                                    isSel
                                        ? AppColors.terracotta
                                        : AppColors.glassBorder,
                              ),
                            ),
                            child: Text(
                              _capitalize(s.name),
                              style: AppTextStyles.labelSmall.copyWith(
                                color:
                                    isSel
                                        ? AppColors.terracotta
                                        : AppColors.textOnDark,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Name input (for new substances)
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Substance name',
                  hintText: 'e.g. alcohol, weed, shrooms',
                ),
                onChanged: (_) => setState(() => _selected = null),
              ),
              const SizedBox(height: 16),

              // Direction toggle
              _SheetLabel('Effect on readiness'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _DirectionChip(
                    label: '− Negative',
                    color: AppColors.terracotta,
                    selected: _direction == 'negative',
                    onTap: () => setState(() => _direction = 'negative'),
                  ),
                  const SizedBox(width: 10),
                  _DirectionChip(
                    label: '+ Positive',
                    color: AppColors.eucalyptus,
                    selected: _direction == 'positive',
                    onTap: () => setState(() => _direction = 'positive'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Impact slider
              _SheetLabel('Personal impact: ${_impact.toStringAsFixed(0)}/10'),
              Slider(
                value: _impact,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setState(() => _impact = v),
              ),
              const SizedBox(height: 12),

              // Quantity
              TextField(
                controller: _quantityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Quantity (optional)',
                  hintText: 'e.g. 2 glasses, 1 joint',
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _log,
                  child: const Text('Log Substance'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _log() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    debugPrint(
      '[ReadinessScreen:SubstanceSheet] _log — name=$name direction=$_direction impact=$_impact date=${widget.date ?? 'today'} isNew=${_selected == null}',
    );

    // Save to library if new
    if (_selected == null) {
      await ref
          .read(userSubstancesProvider.notifier)
          .addSubstance(
            name: name,
            direction: _direction,
            defaultImpact: _impact,
          );
    }

    await ref
        .read(substanceLogsProvider.notifier)
        .logSubstance(
          substanceName: name,
          direction: _direction,
          impactSnapshot: _impact,
          quantity:
              _quantityCtrl.text.trim().isEmpty
                  ? null
                  : _quantityCtrl.text.trim(),
          date: widget.date,
        );

    if (mounted) {
      Navigator.pop(context);
      widget.onDone();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelSmall);
}

class _RatingRow extends StatelessWidget {
  final int value;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _RatingRow({
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final n = i + 1;
            final sel = value == n;
            return GestureDetector(
              onTap: () => onChanged(n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      sel
                          ? AppColors.terracotta.withValues(alpha: 0.25)
                          : AppColors.glassBg,
                  borderRadius: AppRadius.smAll,
                  border: Border.all(
                    color: sel ? AppColors.terracotta : AppColors.glassBorder,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$n',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color:
                          sel
                              ? AppColors.terracotta
                              : AppColors.textOnDarkSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              labels
                  .map(
                    (l) => SizedBox(
                      width: 52,
                      child: Text(
                        l,
                        style: AppTextStyles.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  const _CounterRow({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (value > 0) onChanged(value - 1);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: AppRadius.smAll,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(
              Icons.remove,
              size: 18,
              color: AppColors.textOnDark,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text('$value', style: AppTextStyles.headlineMedium),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            if (value < max) onChanged(value + 1);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: AppRadius.smAll,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(Icons.add, size: 18, color: AppColors.textOnDark),
          ),
        ),
      ],
    );
  }
}

class _DirectionChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _DirectionChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : AppColors.glassBg,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: selected ? color : AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.titleMedium.copyWith(
            color: selected ? color : AppColors.textOnDarkSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCORE RING PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress; // 0.0–1.0
  final Color color;
  final bool thin;

  _ArcPainter(this.progress, this.color, {this.thin = false});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = thin ? 5.0 : 10.0;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    // Background track
    final trackPaint =
        Paint()
          ..color = AppColors.glassBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi * 0.75, math.pi * 1.5, false, trackPaint);

    // Progress arc
    final arcPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi * 0.75,
      math.pi * 1.5 * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Color _scoreColor(double score) {
  if (score >= 80) return AppColors.eucalyptus;
  if (score >= 60) return AppColors.ochre;
  if (score >= 40) return AppColors.terracotta;
  return AppColors.mahogany;
}

String _scoreLabel(double score) {
  if (score >= 80) return 'Peak';
  if (score >= 65) return 'Good';
  if (score >= 50) return 'Moderate';
  if (score >= 35) return 'Low';
  return 'Depleted';
}

String _scoreSubtitle(double score) {
  if (score >= 80) return "You're firing on all cylinders today.";
  if (score >= 65) return "Solid baseline. Good day to push.";
  if (score >= 50) return "You've got enough — pace yourself.";
  if (score >= 35) return "Take it easy. Recovery is progress.";
  return "Rest is the move today.";
}

IconData _windowIcon(CheckInWindow w) {
  switch (w) {
    case CheckInWindow.morning:
      return Icons.wb_sunny_outlined;
    case CheckInWindow.afternoon:
      return Icons.wb_cloudy_outlined;
    case CheckInWindow.evening:
      return Icons.nights_stay_outlined;
  }
}

String _windowLabel(CheckInWindow w) {
  switch (w) {
    case CheckInWindow.morning:
      return 'Morning';
    case CheckInWindow.afternoon:
      return 'Afternoon';
    case CheckInWindow.evening:
      return 'Evening';
  }
}

String _windowGreeting(CheckInWindow w) {
  switch (w) {
    case CheckInWindow.morning:
      return 'Good morning — how did you sleep?';
    case CheckInWindow.afternoon:
      return 'Good afternoon — how\'s your energy?';
    case CheckInWindow.evening:
      return 'Good evening — how was your day?';
  }
}

String _windowPrompt(CheckInWindow w) {
  switch (w) {
    case CheckInWindow.morning:
      return 'Log your sleep and stress to set your baseline for the day.';
    case CheckInWindow.afternoon:
      return 'How\'s your caffeine and focus holding up?';
    case CheckInWindow.evening:
      return 'Log any substances and your end-of-day mood.';
  }
}

Color _belowFiveColor(double rate) {
  if (rate < 0.3) return AppColors.eucalyptus;
  if (rate < 0.6) return AppColors.ochre;
  return AppColors.terracotta;
}

bool _isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.year == now.year && dt.month == now.month && dt.day == now.day;
}

bool _isYesterday(DateTime dt) {
  final y = DateTime.now().subtract(const Duration(days: 1));
  return dt.year == y.year && dt.month == y.month && dt.day == y.day;
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
