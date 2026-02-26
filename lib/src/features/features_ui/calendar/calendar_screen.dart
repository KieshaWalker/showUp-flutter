import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../habits/habits_notifier.dart';
import '../../nutrition/nutrition_notifier.dart';
import '../../../database/db.dart' show Habit;

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _WeekSummary {
  final int habitsDone;
  final int habitsTotal;
  final double protein;
  final double carbs;
  final double fat;
  final double? proteinGoal;
  final double? carbsGoal;
  final double? fatGoal;

  const _WeekSummary({
    required this.habitsDone,
    required this.habitsTotal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.proteinGoal,
    this.carbsGoal,
    this.fatGoal,
  });
}

class _DayData {
  final TodayNutrition nutrition;
  final List<({Habit habit, bool completed})> habits;
  const _DayData({required this.nutrition, required this.habits});
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _displayMonth;
  List<_WeekSummary?> _weekSummaries = [];
  bool _loadingMonth = false;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
    _loadMonthSummaries();
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
      _weekSummaries = [];
    });
    _loadMonthSummaries();
  }

  void _nextMonth() {
    if (!_canGoNext()) return;
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      _weekSummaries = [];
    });
    _loadMonthSummaries();
  }

  bool _canGoNext() {
    final now = DateTime.now();
    return !(_displayMonth.year == now.year &&
        _displayMonth.month == now.month);
  }

  Future<void> _loadMonthSummaries() async {
    setState(() => _loadingMonth = true);

    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final offset = (firstDay.weekday - 1) % 7;
    final rows = ((offset + daysInMonth) / 7).ceil();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final summaries = <_WeekSummary?>[];

    for (var rowIdx = 0; rowIdx < rows; rowIdx++) {
      final firstDayNum = rowIdx * 7 - offset + 1;
      final startDay = firstDayNum.clamp(1, daysInMonth);
      final endDay = (firstDayNum + 6).clamp(1, daysInMonth);

      final weekStart =
          DateTime(_displayMonth.year, _displayMonth.month, startDay);
      final weekEnd = DateTime(_displayMonth.year, _displayMonth.month, endDay)
          .add(const Duration(days: 1));

      if (weekStart.isAfter(today)) {
        summaries.add(null);
        continue;
      }

      final effectiveEnd =
          weekEnd.isAfter(today) ? today.add(const Duration(days: 1)) : weekEnd;
      final elapsedDays =
          effectiveEnd.difference(weekStart).inDays.clamp(0, 7);

      final habitStats = await ref
          .read(habitsNotifierProvider.notifier)
          .getWeekHabitStats(weekStart, weekEnd);

      final nutrition = await ref
          .read(nutritionNotifierProvider.notifier)
          .getNutritionForDateRange(weekStart, weekEnd);

      final goals = nutrition.goals;
      summaries.add(_WeekSummary(
        habitsDone: habitStats.done,
        habitsTotal: habitStats.total,
        protein: nutrition.totalProtein,
        carbs: nutrition.totalCarbs,
        fat: nutrition.totalFat,
        proteinGoal: goals != null ? goals.protein * elapsedDays : null,
        carbsGoal: goals != null ? goals.carbs * elapsedDays : null,
        fatGoal: goals != null ? goals.fat * elapsedDays : null,
      ));
    }

    if (mounted) {
      setState(() {
        _weekSummaries = summaries;
        _loadingMonth = false;
      });
    }
  }

  void _onDayTap(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DayDetailSheet(date: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Month navigation header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs, AppSpacing.sm, AppSpacing.xs, AppSpacing.xs),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _prevMonth,
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.white),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _canGoNext() ? _nextMonth : null,
                    icon: Icon(
                      Icons.chevron_right,
                      color: _canGoNext()
                          ? Colors.white
                          : AppColors.glassBorder,
                    ),
                  ),
                ],
              ),
            ),

            // Weekday labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((l) {
                  return Expanded(
                    child: Center(
                      child: Text(l,
                          style: AppTextStyles.labelSmall
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.sm - 2),
            const Divider(height: 1),

            // Calendar body
            Expanded(
              child: _loadingMonth && _weekSummaries.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.terracotta),
                    )
                  : _buildCalendar(),
            ),
          ],
        ),
      ),
    );
  }

  static double _weekOverallPct(_WeekSummary s) {
    final metrics = <double>[];
    if (s.habitsTotal > 0) {
      metrics.add((s.habitsDone / s.habitsTotal).clamp(0.0, 1.0));
    }
    if (s.proteinGoal != null && s.proteinGoal! > 0) {
      metrics.add((s.protein / s.proteinGoal!).clamp(0.0, 1.0));
    }
    if (s.carbsGoal != null && s.carbsGoal! > 0) {
      metrics.add((s.carbs / s.carbsGoal!).clamp(0.0, 1.0));
    }
    if (s.fatGoal != null && s.fatGoal! > 0) {
      metrics.add((s.fat / s.fatGoal!).clamp(0.0, 1.0));
    }
    if (metrics.isEmpty) return 0;
    return metrics.reduce((a, b) => a + b) / metrics.length;
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final offset = (firstDay.weekday - 1) % 7;
    final rows = ((offset + daysInMonth) / 7).ceil();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 32),
      itemCount: rows,
      itemBuilder: (ctx, rowIdx) {
        final summary =
            rowIdx < _weekSummaries.length ? _weekSummaries[rowIdx] : null;
        final weekNum = rowIdx + 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: AppRadius.circular(18),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: AppShadows.glass,
            ),
            child: ClipRRect(
              borderRadius: AppRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Week header ──────────────────────────────────────────
                  _WeekHeader(
                    weekNum: weekNum,
                    summary: summary,
                    loading: _loadingMonth,
                    overallPct:
                        summary != null ? _weekOverallPct(summary) : null,
                  ),

                  // ── Day cells ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm, 10, AppSpacing.sm, AppSpacing.xs),
                    child: Row(
                      children: List.generate(7, (colIdx) {
                        final dayNum = rowIdx * 7 + colIdx - offset + 1;
                        if (dayNum < 1 || dayNum > daysInMonth) {
                          return const Expanded(child: SizedBox(height: 38));
                        }
                        final date = DateTime(
                            _displayMonth.year, _displayMonth.month, dayNum);
                        final isToday = date.year == today.year &&
                            date.month == today.month &&
                            date.day == today.day;
                        final isFuture = date.isAfter(today);

                        return Expanded(
                          child: _DayCell(
                            dayNum: dayNum,
                            isToday: isToday,
                            isFuture: isFuture,
                            onTap:
                                isFuture ? null : () => _onDayTap(date),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Summary bars ─────────────────────────────────────────
                  if (summary != null) ...[
                    const Divider(height: 1, indent: 12, endIndent: 12),
                    const SizedBox(height: 10),
                    _WeekSummaryStrip(summary: summary),
                    const SizedBox(height: 12),
                  ] else if (_loadingMonth) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: LinearProgressIndicator(
                        color: AppColors.terracotta,
                        backgroundColor: Colors.transparent,
                        minHeight: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else
                    const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Week header
// ---------------------------------------------------------------------------

class _WeekHeader extends StatelessWidget {
  final int weekNum;
  final _WeekSummary? summary;
  final bool loading;
  final double? overallPct;

  const _WeekHeader({
    required this.weekNum,
    required this.summary,
    required this.loading,
    required this.overallPct,
  });

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    String pctLabel;

    if (overallPct == null) {
      accentColor = AppColors.glassBorder;
      pctLabel = '—';
    } else if (overallPct! >= 0.8) {
      accentColor = AppColors.eucalyptus;
      pctLabel = '${(overallPct! * 100).round()}%';
    } else if (overallPct! >= 0.5) {
      accentColor = AppColors.ochre;
      pctLabel = '${(overallPct! * 100).round()}%';
    } else {
      accentColor = AppColors.terracotta;
      pctLabel = '${(overallPct! * 100).round()}%';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
              color: accentColor.withValues(alpha: 0.2), width: 0.75),
        ),
      ),
      child: Row(
        children: [
          Text(
            'WEEK $weekNum',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              fontSize: 11,
            ),
          ),
          const Spacer(),

          // Performance badge
          if (loading && overallPct == null)
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: AppColors.khaki),
            )
          else if (overallPct != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: AppRadius.xlAll,
                border: Border.all(
                    color: accentColor.withValues(alpha: 0.35), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    overallPct! >= 0.8
                        ? Icons.star_rounded
                        : overallPct! >= 0.5
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                    size: 11,
                    color: accentColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    pctLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day cell
// ---------------------------------------------------------------------------

class _DayCell extends StatelessWidget {
  final int dayNum;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  const _DayCell({
    required this.dayNum,
    required this.isToday,
    required this.isFuture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isToday ? AppColors.terracotta : Colors.transparent;
    final Color fg = isToday
        ? Colors.white
        : isFuture
            ? AppColors.glassBorder
            : AppColors.textOnDark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 38,
        child: Center(
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$dayNum',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: fg,
                  fontSize: 14,
                  fontWeight:
                      isToday ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week summary strip
// ---------------------------------------------------------------------------

class _WeekSummaryStrip extends StatelessWidget {
  final _WeekSummary summary;
  const _WeekSummaryStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    final habitPct = summary.habitsTotal > 0
        ? (summary.habitsDone / summary.habitsTotal).clamp(0.0, 1.0)
        : 0.0;
    final allHabitsDone = summary.habitsTotal > 0 && habitPct >= 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          // Habits bar
          Row(
            children: [
              Icon(
                allHabitsDone
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                size: 11,
                color: AppColors.eucalyptus,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${summary.habitsDone}/${summary.habitsTotal}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.eucalyptus,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: AppSpacing.sm - 2),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: habitPct,
                    minHeight: 5,
                    color: AppColors.eucalyptus,
                    backgroundColor:
                        AppColors.eucalyptus.withValues(alpha: 0.15),
                  ),
                ),
              ),
              if (allHabitsDone) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.star_rounded,
                    size: 12, color: AppColors.ochre),
              ],
            ],
          ),
          const SizedBox(height: 5),

          // Macro mini-bars
          Row(
            children: [
              _MiniMacroBar(
                  label: 'P',
                  value: summary.protein,
                  goal: summary.proteinGoal,
                  color: AppColors.proteinColor),
              const SizedBox(width: AppSpacing.sm),
              _MiniMacroBar(
                  label: 'C',
                  value: summary.carbs,
                  goal: summary.carbsGoal,
                  color: AppColors.carbColor),
              const SizedBox(width: AppSpacing.sm),
              _MiniMacroBar(
                  label: 'F',
                  value: summary.fat,
                  goal: summary.fatGoal,
                  color: AppColors.fatColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMacroBar extends StatelessWidget {
  final String label;
  final double value;
  final double? goal;
  final Color color;

  const _MiniMacroBar({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct =
        goal != null && goal! > 0 ? (value / goal!).clamp(0.0, 1.0) : 0.0;

    return Expanded(
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 4,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '${value.round()}g',
            style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day detail bottom sheet
// ---------------------------------------------------------------------------

class _DayDetailSheet extends ConsumerStatefulWidget {
  final DateTime date;
  const _DayDetailSheet({required this.date});

  @override
  ConsumerState<_DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends ConsumerState<_DayDetailSheet> {
  bool _loading = true;
  _DayData? _data;

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final habits = await ref
        .read(habitsNotifierProvider.notifier)
        .getHabitsForDate(widget.date);
    final nutrition = await ref
        .read(nutritionNotifierProvider.notifier)
        .getNutritionForDate(widget.date);
    if (mounted) {
      setState(() {
        _data = _DayData(nutrition: nutrition, habits: habits);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_weekdays[widget.date.weekday - 1]}, ${_months[widget.date.month - 1]} ${widget.date.day}';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.glassModal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: AppSpacing.xs),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg - 4, AppSpacing.xs, AppSpacing.sm, AppSpacing.xs),
              child: Row(
                children: [
                  Text(dateLabel, style: AppTextStyles.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.khaki),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.terracotta))
                  : _buildContent(scrollCtrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ScrollController ctrl) {
    final data = _data!;
    final nutrition = data.nutrition;
    final habits = data.habits;
    final hasNutrition = nutrition.totalCalories > 0 ||
        nutrition.totalProtein > 0 ||
        nutrition.totalCarbs > 0 ||
        nutrition.totalFat > 0;
    final hasData =
        hasNutrition || habits.isNotEmpty || nutrition.totalWaterMl > 0;

    if (!hasData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_neutral_outlined,
                size: 48, color: AppColors.khaki.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('Nothing logged for this day.',
                style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return ListView(
      controller: ctrl,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg - 4, AppSpacing.md, AppSpacing.lg - 4, 40),
      children: [
        // Nutrition
        if (hasNutrition) ...[
          _SectionLabel(label: 'Nutrition'),
          const SizedBox(height: 10),
          Row(
            children: [
              _MacroBox(
                  label: 'Cal',
                  value: nutrition.totalCalories.round(),
                  unit: 'kcal',
                  color: AppColors.calColor),
              const SizedBox(width: AppSpacing.sm),
              _MacroBox(
                  label: 'Protein',
                  value: nutrition.totalProtein.round(),
                  unit: 'g',
                  color: AppColors.proteinColor),
              const SizedBox(width: AppSpacing.sm),
              _MacroBox(
                  label: 'Carbs',
                  value: nutrition.totalCarbs.round(),
                  unit: 'g',
                  color: AppColors.carbColor),
              const SizedBox(width: AppSpacing.sm),
              _MacroBox(
                  label: 'Fat',
                  value: nutrition.totalFat.round(),
                  unit: 'g',
                  color: AppColors.fatColor),
            ],
          ),
          if (nutrition.totalWaterMl > 0) ...[
            const SizedBox(height: 10),
            Text(
              '💧 ${(nutrition.totalWaterMl / 1000).toStringAsFixed(1)} L water',
              style: AppTextStyles.bodyMedium,
            ),
          ],
          if (nutrition.meals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _SectionLabel(label: 'Meals'),
            const SizedBox(height: AppSpacing.sm),
            ...nutrition.meals.map((m) => _MealCard(meal: m)),
          ],
        ],

        // Habits
        if (habits.isNotEmpty) ...[
          if (hasNutrition) const SizedBox(height: AppSpacing.lg - 4),
          Row(
            children: [
              _SectionLabel(label: 'Habits'),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${habits.where((h) => h.completed).length} / ${habits.length}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...habits.map((h) => _HabitRow(
              name: h.habit.name, completed: h.completed)),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Detail sub-widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.titleMedium);
  }
}

class _MacroBox extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color color;

  const _MacroBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(color: color)),
            const SizedBox(height: 2),
            Text('$value',
                style: AppTextStyles.titleLarge.copyWith(color: color)),
            Text(unit, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  final String name;
  final bool completed;
  const _HabitRow({required this.name, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: completed ? AppColors.eucalyptus : AppColors.khaki,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: AppTextStyles.bodyLarge)),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealWithEntries meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal.meal.name, style: AppTextStyles.titleMedium),
              Text('${meal.calories.round()} kcal',
                  style: AppTextStyles.bodyMedium),
            ],
          ),
          if (meal.entries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm - 2),
            ...meal.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(e.name,
                            style: AppTextStyles.bodyMedium)),
                    Text('${e.calories.round()} kcal',
                        style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
