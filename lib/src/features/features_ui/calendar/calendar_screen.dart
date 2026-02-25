import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_theme.dart';
import '../../habits/habits_notifier.dart';
import '../../nutrition/nutrition_notifier.dart';
import '../../../database/db.dart' show Habit;

// ---------------------------------------------------------------------------
// Data holder
// ---------------------------------------------------------------------------

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
  DateTime? _selectedDate;
  _DayData? _dayData;
  bool _loading = false;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (!_canGoNextMonth()) return;
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
  }

  bool _canGoNextMonth() {
    final now = DateTime.now();
    return !(_displayMonth.year == now.year &&
        _displayMonth.month == now.month);
  }

  Future<void> _loadDayData(DateTime date) async {
    setState(() => _loading = true);
    final habits = await ref
        .read(habitsNotifierProvider.notifier)
        .getHabitsForDate(date);
    final nutrition = await ref
        .read(nutritionNotifierProvider.notifier)
        .getNutritionForDate(date);
    if (mounted) {
      setState(() {
        _dayData = _DayData(nutrition: nutrition, habits: habits);
        _loading = false;
      });
    }
  }

  void _onDayTap(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date.isAfter(today)) return;

    final tapped = DateTime(date.year, date.month, date.day);

    if (_selectedDate != null &&
        _selectedDate!.year == tapped.year &&
        _selectedDate!.month == tapped.month &&
        _selectedDate!.day == tapped.day) {
      // Tap same day → deselect
      setState(() {
        _selectedDate = null;
        _dayData = null;
      });
    } else {
      setState(() {
        _selectedDate = tapped;
        _dayData = null;
      });
      _loadDayData(tapped);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        title: const Text('Calendar'),
        titleTextStyle: AppTextStyles.displayLarge,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _prevMonth,
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.mahogany,
                ),
              ),
              Text(
                '${_months[_displayMonth.month - 1]} ${_displayMonth.year}',
                style: AppTextStyles.titleMedium,
              ),
              IconButton(
                onPressed: _canGoNextMonth() ? _nextMonth : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: _canGoNextMonth()
                      ? AppColors.mahogany
                      : AppColors.divider,
                ),
              ),
            ],
          ),

          // Day-of-week labels
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (l) => SizedBox(
                    width: 36,
                    child: Center(
                      child: Text(l, style: AppTextStyles.labelSmall),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),

          // Calendar grid
          _buildCalendarGrid(),
          const SizedBox(height: 12),

          // Legend
          Row(
            children: [
              _LegendDot(color: AppColors.terracotta, label: 'Today'),
              const SizedBox(width: 12),
              _LegendDot(
                color: Colors.white,
                label: 'Selected',
                border: AppColors.mahogany,
              ),
              const SizedBox(width: 12),
              _LegendDot(
                color: AppColors.surface,
                label: 'Past',
                border: AppColors.divider,
              ),
            ],
          ),

          // Day snapshot (animated)
          if (_selectedDate != null) ...[
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _loading
                  ? const Padding(
                      key: ValueKey('loading'),
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.terracotta,
                        ),
                      ),
                    )
                  : _dayData != null
                      ? _DaySnapshot(
                          key: ValueKey(_selectedDate),
                          date: _selectedDate!,
                          dayData: _dayData!,
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;

    // Monday-based offset
    final offset = (firstDay.weekday - 1) % 7;
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIdx) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (colIdx) {
            final cellIdx = rowIdx * 7 + colIdx;
            final dayNum = cellIdx - offset + 1;

            if (dayNum < 1 || dayNum > daysInMonth) {
              return const SizedBox(width: 36, height: 42);
            }

            final date = DateTime(
              _displayMonth.year,
              _displayMonth.month,
              dayNum,
            );
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final isFuture = date.isAfter(today);
            final isSelected = _selectedDate != null &&
                _selectedDate!.year == date.year &&
                _selectedDate!.month == date.month &&
                _selectedDate!.day == date.day;

            return _DayCell(
              dayNum: dayNum,
              isToday: isToday,
              isFuture: isFuture,
              isSelected: isSelected,
              onTap: () => _onDayTap(date),
            );
          }),
        );
      }),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCell({
    required this.dayNum,
    required this.isToday,
    required this.isFuture,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final BoxBorder? border;

    if (isToday) {
      bgColor = AppColors.terracotta;
      textColor = Colors.white;
      border = null;
    } else if (isSelected) {
      bgColor = Colors.white;
      textColor = AppColors.mahogany;
      border = Border.all(color: AppColors.mahogany, width: 2);
    } else if (isFuture) {
      bgColor = Colors.transparent;
      textColor = AppColors.divider;
      border = null;
    } else {
      bgColor = AppColors.surface;
      textColor = AppColors.silhouette;
      border = null;
    }

    return GestureDetector(
      onTap: isFuture ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: border,
          ),
          child: Center(
            child: Text(
              '$dayNum',
              style: AppTextStyles.labelSmall.copyWith(
                color: textColor,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Day snapshot card
// ---------------------------------------------------------------------------

class _DaySnapshot extends StatelessWidget {
  final DateTime date;
  final _DayData dayData;

  const _DaySnapshot({
    super.key,
    required this.date,
    required this.dayData,
  });

  @override
  Widget build(BuildContext context) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final header =
        '${weekdays[date.weekday - 1]}, ${monthNames[date.month - 1]} ${date.day}';

    final nutrition = dayData.nutrition;
    final habits = dayData.habits;
    final hasData = habits.isNotEmpty ||
        nutrition.meals.isNotEmpty ||
        nutrition.totalCalories > 0 ||
        nutrition.totalWaterMl > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),

          if (!hasData)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No data logged for this day',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            )
          else ...[
            // Macros
            if (nutrition.totalCalories > 0) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MacroChip(
                    label: '${nutrition.totalCalories.round()} cal',
                    color: AppColors.calColor,
                  ),
                  _MacroChip(
                    label: '${nutrition.totalProtein.round()}g pro',
                    color: AppColors.proteinColor,
                  ),
                  _MacroChip(
                    label: '${nutrition.totalCarbs.round()}g carbs',
                    color: AppColors.carbColor,
                  ),
                  _MacroChip(
                    label: '${nutrition.totalFat.round()}g fat',
                    color: AppColors.fatColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Water
            if (nutrition.totalWaterMl > 0) ...[
              Text(
                '💧 ${(nutrition.totalWaterMl / 1000).toStringAsFixed(1)} L water',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],

            // Habits
            if (habits.isNotEmpty) ...[
              Row(
                children: [
                  Text('Habits', style: AppTextStyles.titleMedium),
                  const SizedBox(width: 6),
                  Text(
                    '(${habits.where((h) => h.completed).length} / ${habits.length})',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...habits.map(
                (h) => _HabitRow(name: h.habit.name, completed: h.completed),
              ),
            ],

            // Meals
            if (nutrition.meals.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Meals', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              ...nutrition.meals.map((m) => _MealRow(meal: m)),
            ],
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Macro chip
// ---------------------------------------------------------------------------

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Habit row
// ---------------------------------------------------------------------------

class _HabitRow extends StatelessWidget {
  final String name;
  final bool completed;

  const _HabitRow({required this.name, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.cancel_outlined,
            size: 16,
            color: completed ? AppColors.eucalyptus : AppColors.mutedRose,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Meal row
// ---------------------------------------------------------------------------

class _MealRow extends StatelessWidget {
  final MealWithEntries meal;

  const _MealRow({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal.meal.name, style: AppTextStyles.titleMedium),
              Text(
                '${meal.calories.round()} kcal',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          if (meal.entries.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...meal.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(e.name, style: AppTextStyles.bodyMedium),
                    ),
                    Text(
                      '${e.calories.round()}',
                      style: AppTextStyles.labelSmall,
                    ),
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

// ---------------------------------------------------------------------------
// Legend dot
// ---------------------------------------------------------------------------

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final Color? border;

  const _LegendDot({
    required this.color,
    required this.label,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border != null ? Border.all(color: border!) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
