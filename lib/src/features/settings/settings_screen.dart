import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_theme.dart';
import '../habits/habits_notifier.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings'),
        titleTextStyle: AppTextStyles.displayLarge,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
            ),
            onPressed:
                () => _showCalendarSheet(context, ref, habitsAsync.value ?? []),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
      body: habitsAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.terracotta),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (habits) {
          final active = habits.where((h) => !h.isDone).toList();
          final done = habits.where((h) => h.isDone).toList();

          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.khaki.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No habits yet',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.khaki,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm - 2),
                  Text(
                    'Tap "Add Habit" to get started',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: AppPaddings.all,
            children: [
              _WeekStrip(habits: habits),
              const SizedBox(height: AppSpacing.lg - 4),

              if (active.isNotEmpty) ...[
                Text(
                  'Today',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: 10),
                ...active.map((h) => _HabitTile(item: h)),
                const SizedBox(height: AppSpacing.lg - 4),
              ],

              if (done.isNotEmpty) ...[
                Text(
                  'Completed',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.khaki,
                  ),
                ),
                const SizedBox(height: 10),
                ...done.map((h) => _HabitTile(item: h)),
              ],

              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log out?', style: AppTextStyles.titleMedium),
        content: Text(
          'You will be returned to the login screen.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.terracotta,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await Supabase.instance.client.auth.signOut();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String frequencyType = 'daily';
    int targetDays = 7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
            ),
            child: StatefulBuilder(
              builder:
                  (ctx, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('New Habit', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: AppSpacing.lg - 4),
                      TextField(
                        controller: nameController,
                        style: AppTextStyles.bodyLarge,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Habit name',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _FreqChip(
                            label: 'Daily',
                            selected: frequencyType == 'daily',
                            onTap:
                                () => setState(() {
                                  frequencyType = 'daily';
                                  targetDays = 7;
                                }),
                          ),
                          const SizedBox(width: 10),
                          _FreqChip(
                            label: 'Weekly',
                            selected: frequencyType == 'weekly',
                            onTap:
                                () => setState(() {
                                  frequencyType = 'weekly';
                                  targetDays = 3;
                                }),
                          ),
                        ],
                      ),
                      if (frequencyType == 'weekly') ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Target: $targetDays× per week',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Slider(
                          value: targetDays.toDouble(),
                          min: 1,
                          max: 6,
                          divisions: 5,
                          activeColor: AppColors.terracotta,
                          inactiveColor: AppColors.glassBorder,
                          label: '$targetDays',
                          onChanged:
                              (v) => setState(() => targetDays = v.round()),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg - 4),
                      FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;
                          ref
                              .read(habitsNotifierProvider.notifier)
                              .addHabit(
                                name,
                                frequencyType: frequencyType,
                                targetDaysPerWeek: targetDays,
                              );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Add Habit'),
                      ),
                    ],
                  ),
            ),
          ),
    );
  }

  void _showCalendarSheet(
    BuildContext context,
    WidgetRef ref,
    List<HabitWithStatus> habits,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (ctx) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (ctx, scrollCtrl) => _CalendarSheet(
                  habits: habits,
                  scrollController: scrollCtrl,
                  notifier: ref.read(habitsNotifierProvider.notifier),
                ),
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Week progress strip
// ---------------------------------------------------------------------------

class _WeekStrip extends StatelessWidget {
  final List<HabitWithStatus> habits;
  const _WeekStrip({required this.habits});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime(now.year, now.month, now.day);

    return AppGlass.card(
      padding: AppPaddings.section,
      borderRadius: AppRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Week', style: AppTextStyles.labelSmall),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = DateTime(days[i].year, days[i].month, days[i].day);
              final isToday = day == today;
              final isPast = day.isBefore(today);

              return Column(
                children: [
                  Text(labels[i], style: AppTextStyles.labelSmall),
                  const SizedBox(height: AppSpacing.sm - 2),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isToday
                              ? AppColors.terracotta
                              : isPast
                              ? AppColors.glassBorder
                              : Colors.transparent,
                      border:
                          isToday ? null : Border.all(color: AppColors.glassBorder),
                    ),
                    child: Center(
                      child: Text(
                        '${days[i].day}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isToday ? Colors.white : AppColors.textOnDark,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Habit tile
// ---------------------------------------------------------------------------

class _HabitTile extends ConsumerWidget {
  final HabitWithStatus item;
  const _HabitTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = item.habit;
    final isDone = item.isDone;
    final isWeekly = habit.frequencyType == 'weekly';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: isDone ? 0.55 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(habitsNotifierProvider.notifier).toggleCompletion(habit.id);
            },
            onLongPress:
                () => _confirmDelete(context, ref, habit.id, habit.name),
            borderRadius: AppRadius.lgAll,
            child: Container(
              padding: AppPaddings.section,
              decoration: BoxDecoration(
                color:
                    isDone
                        ? AppColors.eucalyptus.withValues(alpha: 0.15)
                        : AppColors.glassBg,
                borderRadius: AppRadius.lgAll,
                border: Border.all(
                  color:
                      isDone
                          ? AppColors.eucalyptus.withValues(alpha: 0.4)
                          : AppColors.glassBorder,
                ),
                boxShadow: AppShadows.glass,
              ),
              child: Row(
                children: [
                  // Completion button
                  GestureDetector(
                    onTap:
                        () => ref
                            .read(habitsNotifierProvider.notifier)
                            .toggleCompletion(habit.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isDone ? AppColors.eucalyptus : Colors.transparent,
                        border:
                            isDone
                                ? null
                                : Border.all(color: AppColors.khaki, width: 2),
                        boxShadow:
                            isDone
                                ? [
                                  BoxShadow(
                                    color: AppColors.eucalyptus.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                  ),
                                ]
                                : null,
                      ),
                      child:
                          isDone
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.khaki,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isWeekly
                              ? '${item.completionsThisWeek} / ${habit.targetDaysPerWeek}× this week'
                              : 'Daily',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // Streak badge
                  if (item.streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ochre.withValues(alpha: 0.15),
                        borderRadius: AppRadius.xlAll,
                        border: Border.all(
                          color: AppColors.ochre.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 3),
                          Text(
                            '${item.streak}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.ochre,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete habit?', style: AppTextStyles.titleMedium),
            content: Text(
              'Delete "$name"? All history will be lost.',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                ),
                onPressed: () {
                  ref.read(habitsNotifierProvider.notifier).deleteHabit(id);
                  Navigator.pop(ctx);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Frequency chip
// ---------------------------------------------------------------------------

class _FreqChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FreqChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.terracotta : Colors.transparent,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: selected ? AppColors.terracotta : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: selected ? Colors.white : AppColors.textOnDark,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar sheet
// ---------------------------------------------------------------------------

class _CalendarSheet extends StatefulWidget {
  final List<HabitWithStatus> habits;
  final ScrollController scrollController;
  final HabitsNotifier notifier;

  const _CalendarSheet({
    required this.habits,
    required this.scrollController,
    required this.notifier,
  });

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _displayMonth;
  String? _selectedHabitId;
  Set<DateTime> _completedDates = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
    if (widget.habits.isNotEmpty) {
      _selectedHabitId = widget.habits.first.habit.id;
      _loadDates();
    }
  }

  Future<void> _loadDates() async {
    if (_selectedHabitId == null) return;
    final dates = await widget.notifier.getCompletedDatesForMonth(
      _selectedHabitId!,
      _displayMonth.year,
      _displayMonth.month,
    );
    if (mounted) setState(() => _completedDates = dates);
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
    });
    _loadDates();
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_displayMonth.year == now.year && _displayMonth.month == now.month) {
      return;
    }
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
    });
    _loadDates();
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Container(
      color: AppColors.glassModal,
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg - 4),
              children: [
                Text('Progress Calendar', style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.md),

                // Habit selector
                if (widget.habits.isNotEmpty) ...[
                  Text('Habit', style: AppTextStyles.labelSmall),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.habits.length,
                      separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (ctx, i) {
                        final h = widget.habits[i];
                        final sel = h.habit.id == _selectedHabitId;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedHabitId = h.habit.id);
                            _loadDates();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  sel
                                      ? AppColors.terracotta
                                      : AppColors.glassBg,
                              borderRadius: AppRadius.xlAll,
                            ),
                            child: Text(
                              h.habit.name,
                              style: AppTextStyles.labelSmall.copyWith(
                                color:
                                    sel ? Colors.white : AppColors.textOnDark,
                                fontWeight:
                                    sel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg - 4),
                ],

                // Month nav
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${months[_displayMonth.month - 1]} ${_displayMonth.year}',
                      style: AppTextStyles.titleMedium,
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Day labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:
                      ['M', 'T', 'W', 'T', 'F', 'S', 'S']
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
                const SizedBox(height: AppSpacing.sm),

                // Calendar grid
                _buildCalendarGrid(),

                const SizedBox(height: AppSpacing.lg),

                // Legend
                Row(
                  children: [
                    _LegendDot(color: AppColors.eucalyptus, label: 'Completed'),
                    const SizedBox(width: AppSpacing.md),
                    _LegendDot(color: AppColors.glassBorder, label: 'Missed'),
                    const SizedBox(width: AppSpacing.md),
                    _LegendDot(color: AppColors.terracotta, label: 'Today'),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
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
              return const SizedBox(width: 36, height: 36);
            }

            final date = DateTime.utc(
              _displayMonth.year,
              _displayMonth.month,
              dayNum,
            );
            final isToday = date == today;
            final isCompleted = _completedDates.contains(date);
            final isFuture = date.isAfter(today);

            Color bgColor;
            Color textColor;
            if (isToday) {
              bgColor = AppColors.terracotta;
              textColor = Colors.white;
            } else if (isCompleted) {
              bgColor = AppColors.eucalyptus;
              textColor = Colors.white;
            } else if (isFuture) {
              bgColor = Colors.transparent;
              textColor = AppColors.glassBorder;
            } else {
              bgColor = AppColors.glassBg;
              textColor = AppColors.textOnDark;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
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
            );
          }),
        );
      }),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
