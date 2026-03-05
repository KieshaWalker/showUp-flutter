import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import 'habits_notifier.dart';

// =============================================================================
// HabitsScreen
// =============================================================================
//
// Pure CRUD management screen for habits.
// Lists all habits; tap to edit, long-press to delete.
// FAB opens _HabitFormSheet to add a new habit.
//
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 0, right: 20.0, bottom: 20.0),
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            height: 100,
            width: 150,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.glassBorder),
                  const SizedBox(height: AppSpacing.md),
                  Text('No habits yet', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Tap + to add your first habit', style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: AppPaddings.all,
            itemCount: habits.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) => _HabitManageCard(item: habits[i]),
          );
        },
      ),
    );
  }
}

void _showAddHabitSheet(BuildContext context, WidgetRef ref, {Habit? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _HabitFormSheet(
      initialName: existing?.name,
      initialFrequencyType: existing?.frequencyType,
      initialTargetDaysPerWeek: existing?.targetDaysPerWeek,
      initialSkipsAllowedPerWeek: existing?.skipsAllowedPerWeek,
      onSave: ({
        required String name,
        required String frequencyType,
        required int targetDaysPerWeek,
        required int skipsAllowedPerWeek,
      }) {
        if (existing != null) {
          ref.read(habitsNotifierProvider.notifier).updateHabit(
                existing.id,
                name: name,
                frequencyType: frequencyType,
                targetDaysPerWeek: targetDaysPerWeek,
                skipsAllowedPerWeek: skipsAllowedPerWeek,
              );
        } else {
          ref.read(habitsNotifierProvider.notifier).addHabit(
                name,
                frequencyType: frequencyType,
                targetDaysPerWeek: targetDaysPerWeek,
                skipsAllowedPerWeek: skipsAllowedPerWeek,
              );
        }
      },
      onDelete: existing != null
          ? () => ref.read(habitsNotifierProvider.notifier).deleteHabit(existing.id)
          : null,
    ),
  );
}

// ---------------------------------------------------------------------------
// _HabitManageCard — simple list tile for CRUD management
// ---------------------------------------------------------------------------

class _HabitManageCard extends ConsumerWidget {
  const _HabitManageCard({required this.item});
  final HabitWithStatus item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppGlass.card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(item.habit.name, style: AppTextStyles.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: HabitFreqChip(habit: item.habit),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textOnDarkSecondary),
        onTap: () => _showAddHabitSheet(context, ref, existing: item.habit),
        onLongPress: () => _confirmDelete(context, ref, item.habit),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text('This will permanently delete "${habit.name}" and all its history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(habitsNotifierProvider.notifier).deleteHabit(habit.id);
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HabitFormSheet — add or edit a habit
// ---------------------------------------------------------------------------
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │  CONFIGURABLE DEFAULTS (change here to change new-habit defaults)    │
// │                                                                      │
// │  frequencyType       'daily'  (see initState)                       │
// │  targetDaysPerWeek   3 for weekly habits (slider shows 1–6)         │
// │                      7 for daily (forced, not shown to user)        │
// │  skipsAllowedPerWeek 0 (counter shows 0–7)                          │
// │                                                                      │
// │  To change slider range for weekly target: edit the Slider below.   │
// │  To change max skips counter: edit _Counter's max: parameter.       │
// └──────────────────────────────────────────────────────────────────────┘

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
  final String? label;
  final bool? selected;
  final VoidCallback? onTap;
  final Habit? habit;
  const HabitFreqChip({
    super.key,
    this.label,
    this.selected,
    this.onTap,
    this.habit,
  });

  @override
  Widget build(BuildContext context) {
    // When used as a display chip (passed a habit), derive label/selected from it.
    final effectiveLabel = label ?? (habit!.frequencyType == 'weekly'
        ? '${habit!.targetDaysPerWeek}× / week'
        : 'Daily');
    final effectiveSelected = selected ?? false;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: effectiveSelected ? AppColors.terracotta : AppColors.glassBg,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: effectiveSelected ? AppColors.terracotta : AppColors.glassBorder,
          ),
        ),
        child: Text(
          effectiveLabel,
          style: AppTextStyles.bodyMedium.copyWith(
            color: effectiveSelected ? Colors.white : AppColors.textOnDark,
            fontWeight: effectiveSelected ? FontWeight.w600 : FontWeight.normal,
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
