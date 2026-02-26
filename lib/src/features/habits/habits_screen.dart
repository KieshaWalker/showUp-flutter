import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import 'habits_notifier.dart';

// Main screen for the Habits feature, showing a list of habits with their status, a weekly progress strip, and options to add new habits or view the calendar history
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text('Habits', style: AppTextStyles.displayLarge),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
            ),
            onPressed: () =>
                _showCalendarSheet(context, ref, habitsAsync.value ?? []),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
      body: habitsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (habits) {
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
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.khaki),
                  ),
                  const SizedBox(height: AppSpacing.sm - 2),
                  Text('Tap "Add Habit" to get started', style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }

          final active = habits.where((h) => !h.isDone).toList();
          final done = habits.where((h) => h.isDone).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 28, AppSpacing.md, 28),
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: _WeekStrip(habits: habits),
                  ),
                ),
              ),
              if (active.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg - 4, AppSpacing.md, AppSpacing.sm),
                  sliver: SliverToBoxAdapter(
                    child: Text('Active', style: AppTextStyles.titleMedium),
                  ),
                ),
                SliverPadding(
                  padding: AppPaddings.horizontal,
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _HabitCard(item: active[i]),
                      childCount: active.length,
                    ),
                  ),
                ),
              ],
              if (done.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.lg - 4, AppSpacing.md, AppSpacing.sm),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Completed',
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.khaki),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: AppPaddings.horizontal,
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _HabitCard(item: done[i]),
                      childCount: done.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _HabitFormSheet(
        onSave: ({
          required String name,
          required String frequencyType,
          required int targetDaysPerWeek,
          required int skipsAllowedPerWeek,
        }) {
          ref.read(habitsNotifierProvider.notifier).addHabit(
                name,
                frequencyType: frequencyType,
                targetDaysPerWeek: targetDaysPerWeek,
                skipsAllowedPerWeek: skipsAllowedPerWeek,
              );
        },
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
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollCtrl) => HabitCalendarSheet(
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

    final totalHabits = habits.length;
    final doneToday = habits.where((h) => h.completedToday).length;
    final pct = totalHabits > 0 ? doneToday / totalHabits : 0.0;

    return AppGlass.card(
      padding: AppPaddings.section,
      borderRadius: AppRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('This Week', style: AppTextStyles.labelSmall),
              Text(
                '$doneToday / $totalHabits today',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: AppColors.glassBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.terracotta),
            ),
          ),
          const SizedBox(height: 12),
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
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? AppColors.terracotta
                          : isPast
                              ? AppColors.glassBorder
                              : Colors.transparent,
                      border: isToday
                          ? null
                          : Border.all(color: AppColors.glassBorder),
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
// Habit card (2-column grid)
// ---------------------------------------------------------------------------

class _HabitCard extends ConsumerWidget {
  final HabitWithStatus item;
  const _HabitCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = item.habit;
    final isDone = item.isDone;
    final isWeekly = habit.frequencyType == 'weekly';
    final hasSkipsAllowed = habit.skipsAllowedPerWeek > 0;
    final skipsLeft = item.skipsRemaining;
    final hasUsedSkip = item.skipsThisWeek > 0;

    return Opacity(
      opacity: isDone ? 0.6 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: () => _showEditSheet(context, ref),
          borderRadius: AppRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.eucalyptus.withValues(alpha: 0.15)
                  : AppColors.glassBg,
              borderRadius: AppRadius.circular(18),
              border: Border.all(
                color: isDone
                    ? AppColors.eucalyptus.withValues(alpha: 0.4)
                    : AppColors.glassBorder,
              ),
              boxShadow: AppShadows.glass,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: name + completion circle
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        habit.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.khaki,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => ref
                          .read(habitsNotifierProvider.notifier)
                          .toggleCompletion(habit.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.eucalyptus
                              : Colors.transparent,
                          border: isDone
                              ? null
                              : Border.all(color: AppColors.khaki, width: 2),
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: AppColors.eucalyptus
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm - 2),

                // Subtitle
                Text(
                  isWeekly
                      ? '${item.completionsThisWeek} / ${habit.targetDaysPerWeek}× this week'
                      : 'Daily',
                  style: AppTextStyles.bodyMedium,
                ),

                const Spacer(),

                // Bottom row: streak + skip button
                Row(
                  children: [
                    if (item.streak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.ochre.withValues(alpha: 0.15),
                          borderRadius: AppRadius.xlAll,
                          border: Border.all(
                              color: AppColors.ochre.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 3),
                            Text(
                              '${item.streak}',
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.ochre),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),

                    // Skip button
                    if (hasSkipsAllowed && !isDone) ...[
                      if (hasUsedSkip)
                        GestureDetector(
                          onTap: () => ref
                              .read(habitsNotifierProvider.notifier)
                              .unskipWeek(habit.id),
                          child: Text(
                            'Unskip',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.khaki,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.khaki,
                            ),
                          ),
                        )
                      else if (skipsLeft > 0)
                        GestureDetector(
                          onTap: () => ref
                              .read(habitsNotifierProvider.notifier)
                              .skipWeek(habit.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.glassBg,
                              borderRadius: AppRadius.xlAll,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Text(
                              'Skip ($skipsLeft)',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textOnDark,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _HabitFormSheet(
        initialName: item.habit.name,
        initialFrequencyType: item.habit.frequencyType,
        initialTargetDaysPerWeek: item.habit.targetDaysPerWeek,
        initialSkipsAllowedPerWeek: item.habit.skipsAllowedPerWeek,
        onSave: ({
          required String name,
          required String frequencyType,
          required int targetDaysPerWeek,
          required int skipsAllowedPerWeek,
        }) {
          ref.read(habitsNotifierProvider.notifier).updateHabit(
                item.habit.id,
                name: name,
                frequencyType: frequencyType,
                targetDaysPerWeek: targetDaysPerWeek,
                skipsAllowedPerWeek: skipsAllowedPerWeek,
              );
        },
        onDelete: () {
          ref
              .read(habitsNotifierProvider.notifier)
              .deleteHabit(item.habit.id);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Habit form sheet (add + edit)
// ---------------------------------------------------------------------------

class _HabitFormSheet extends StatefulWidget {
  final String? initialName;
  final String? initialFrequencyType;
  final int? initialTargetDaysPerWeek;
  final int? initialSkipsAllowedPerWeek;
  final void Function({
    required String name,
    required String frequencyType,
    required int targetDaysPerWeek,
    required int skipsAllowedPerWeek,
  }) onSave;
  final VoidCallback? onDelete;

  const _HabitFormSheet({
    this.initialName,
    this.initialFrequencyType,
    this.initialTargetDaysPerWeek,
    this.initialSkipsAllowedPerWeek,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends State<_HabitFormSheet> {
  late final TextEditingController _nameCtrl;
  late String _frequencyType;
  late int _targetDays;
  late int _skipsAllowed;

  bool get _isEditing => widget.initialName != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _frequencyType = widget.initialFrequencyType ?? 'daily';
    _targetDays = widget.initialTargetDaysPerWeek ?? 3;
    _skipsAllowed = widget.initialSkipsAllowedPerWeek ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg - 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            _isEditing ? 'Edit Habit' : 'New Habit',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg - 4),

          // Name
          TextField(
            controller: _nameCtrl,
            style: AppTextStyles.bodyLarge,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Habit name'),
          ),
          const SizedBox(height: AppSpacing.md),

          // Frequency chips
          Row(
            children: [
              HabitFreqChip(
                label: 'Daily',
                selected: _frequencyType == 'daily',
                onTap: () => setState(() {
                  _frequencyType = 'daily';
                  _targetDays = 7;
                }),
              ),
              const SizedBox(width: 10),
              HabitFreqChip(
                label: 'Weekly',
                selected: _frequencyType == 'weekly',
                onTap: () => setState(() {
                  _frequencyType = 'weekly';
                  if (_targetDays == 7) _targetDays = 3;
                }),
              ),
            ],
          ),

          if (_frequencyType == 'weekly') ...[
            const SizedBox(height: 14),
            Text(
              'Target: $_targetDays× per week',
              style: AppTextStyles.bodyMedium,
            ),
            Slider(
              value: _targetDays.toDouble(),
              min: 1,
              max: 6,
              divisions: 5,
              label: '$_targetDays',
              onChanged: (v) => setState(() => _targetDays = v.round()),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Skips allowed counter
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skip allowance / week', style: AppTextStyles.bodyMedium),
                    Text(
                      'How many times can you skip this habit each week?',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _Counter(
                value: _skipsAllowed,
                min: 0,
                max: 7,
                onChanged: (v) => setState(() => _skipsAllowed = v),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Save button
          FilledButton(
            onPressed: () {
              final name = _nameCtrl.text.trim();
              if (name.isEmpty) return;
              widget.onSave(
                name: name,
                frequencyType: _frequencyType,
                targetDaysPerWeek: _targetDays,
                skipsAllowedPerWeek: _skipsAllowed,
              );
              Navigator.pop(context);
            },
            child: Text(_isEditing ? 'Save Changes' : 'Add Habit'),
          ),

          if (_isEditing && widget.onDelete != null) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.terracotta,
                side: const BorderSide(color: AppColors.terracotta),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete!();
              },
              child: const Text('Delete Habit'),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Counter widget (+/-)
// ---------------------------------------------------------------------------

class _Counter extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Counter({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CounterBtn(
          icon: Icons.remove,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 32,
          child: Center(
            child: Text('$value', style: AppTextStyles.titleMedium),
          ),
        ),
        _CounterBtn(
          icon: Icons.add,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _CounterBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? AppColors.glassBg : Colors.transparent,
          border: Border.all(
            color: enabled
                ? AppColors.glassBorder
                : AppColors.glassBorder.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? AppColors.textOnDark
              : AppColors.textOnDarkTertiary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Frequency chip
// ---------------------------------------------------------------------------

class HabitFreqChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const HabitFreqChip({
    super.key,
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
          color: selected ? AppColors.terracotta : AppColors.glassBg,
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
// Calendar sheet (habit history)
// ---------------------------------------------------------------------------

class HabitCalendarSheet extends StatefulWidget {
  final List<HabitWithStatus> habits;
  final ScrollController scrollController;
  final HabitsNotifier notifier;

  const HabitCalendarSheet({
    super.key,
    required this.habits,
    required this.scrollController,
    required this.notifier,
  });

  @override
  State<HabitCalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<HabitCalendarSheet> {
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
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Container(
      color: AppColors.glassModal,
      child: Column(
        children: [
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
                                horizontal: 14, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.terracotta
                                  : AppColors.glassBg,
                              borderRadius: AppRadius.xlAll,
                            ),
                            child: Text(
                              h.habit.name,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: sel ? Colors.white : AppColors.textOnDark,
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _prevMonth,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      '${months[_displayMonth.month - 1]} ${_displayMonth.year}',
                      style: AppTextStyles.titleMedium,
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

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
                const SizedBox(height: AppSpacing.sm),

                _buildCalendarGrid(),
                const SizedBox(height: AppSpacing.lg),

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
                _displayMonth.year, _displayMonth.month, dayNum);
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
                decoration:
                    BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '$dayNum',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: textColor,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
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
