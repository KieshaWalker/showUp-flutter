import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import '../habits/habits_notifier.dart';
import '../nutrition/nutrition_notifier.dart';
import '../nutrition/nutrition_screen.dart';
import '../pantry/pantry_notifier.dart';
import '../profile/profile_notifier.dart';

const List<String> _months = [
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

const List<String> _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class PresentationScreen extends ConsumerWidget {
  const PresentationScreen({super.key});

  static String _greeting(int hour, String? name) {
    final suffix = name != null ? ', $name.' : '.';
    if (hour < 12) return 'Good morning$suffix';
    if (hour < 17) return 'Good afternoon$suffix';
    return 'Good evening$suffix';
  }

  static String _dateLabel(DateTime d) {
    return '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
  }

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final nutritionAsync = ref.watch(nutritionNotifierProvider);
    final habitsAsync = ref.watch(habitsNotifierProvider);
    final profile = ref.watch(profileProvider).value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Show Up'),
        titleTextStyle: AppTextStyles.displayLarge,
      ),
      body: ListView(
        padding: AppPaddings.all,
        children: [
          Text(
            _greeting(now.hour, profile?.displayName.isNotEmpty == true ? profile!.displayName : null),
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(_dateLabel(now), style: AppTextStyles.bodyMedium),
          Text(
            TimeOfDay.now().format(context),
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          // summary widgets only available once nutrition data has loaded
          nutritionAsync.when(
            data:
                (nutrition) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NutritionCalorieSummary(nutrition: nutrition),
                    const SizedBox(height: 12),
                    NutritionMacroRow(nutrition: nutrition),
                    const SizedBox(height: 12),
                  ],
                ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const _HabitsCard(),
          const SizedBox(height: AppSpacing.lg),
          const _QuickAddSection(),
          const SizedBox(height: 80),
          const _ShowFoodsToday(),
          habitsAsync.when(
            data:
                (habits) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    _IncompleteHabitsList(habits: habits),
                  ],
                ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _IncompleteHabitsList extends StatelessWidget {
  final List<HabitWithStatus> habits;
  const _IncompleteHabitsList({required this.habits});

  @override
  Widget build(BuildContext context) {
    final incomplete = habits.where((h) => !h.isDone).toList();
    if (incomplete.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Habits', style: AppTextStyles.labelSmall),
        const SizedBox(height: AppSpacing.sm),
        Column(
          children:
              incomplete
                  .map(
                    (h) => GestureDetector(
                      onTap:
                          () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => _QuickCompleteHabit(habit: h),
                          ),
                      child: AppGlass.card(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        borderRadius: AppRadius.lgAll,
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.terracotta.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: AppRadius.smAll,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                size: 14,
                                color: AppColors.terracotta,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm - 2),
                            Text(h.habit.name, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

}

// ---------------------------------------------------------------------------
// Habits at a Glance card
// ---------------------------------------------------------------------------

class _HabitsCard extends ConsumerWidget {
  const _HabitsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return AppGlass.card(
      padding: AppPaddings.card,
      borderRadius: AppRadius.xlAll,
      child: habitsAsync.when(
        loading:
            () => const SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.terracotta),
              ),
            ),
        error: (e, _) => Text('Error: $e', style: AppTextStyles.bodyMedium),
        data: (habits) {
          final total = habits.length;
          final done = habits.where((h) => h.isDone).length;
          final pct = total == 0 ? 0.0 : done / total;
          final allDone = total > 0 && done == total;

          return Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 7,
                      backgroundColor: AppColors.glassBorder,
                      color:
                          allDone ? AppColors.eucalyptus : AppColors.terracotta,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '${(pct * 100).round()}%',
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg - 4),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: AppColors.terracotta,
                        ),
                        const SizedBox(width: AppSpacing.sm - 2),
                        Text('Habits', style: AppTextStyles.labelSmall),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$done of $total done',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      total == 0
                          ? 'No habits tracked yet.'
                          : allDone
                          ? 'All done. Great work today!'
                          : '${total - done} remaining',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Add section
// ---------------------------------------------------------------------------

class _QuickAddSection extends ConsumerWidget {
  const _QuickAddSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryAsync = ref.watch(pantryNotifierProvider);

    return pantryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
      data: (foods) {
        if (foods.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 16,
                  color: AppColors.terracotta,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('Quick Add', style: AppTextStyles.titleMedium),
                const SizedBox(width: AppSpacing.xs),
                Text('from pantry', style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Horizontal food chips
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: foods.length,
                separatorBuilder:
                    (_, _) => const SizedBox(width: AppSpacing.sm),
                itemBuilder:
                    (ctx, i) => _QuickAddChip(
                      food: foods[i],
                      onTap: () => _showQuickAddSheet(context, ref, foods[i]),
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showQuickAddSheet(
    BuildContext context,
    WidgetRef ref,
    PantryFood food,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _QuickAddSheet(food: food),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual food chip in the horizontal scroll
// ---------------------------------------------------------------------------

class _QuickAddChip extends StatelessWidget {
  final PantryFood food;
  final VoidCallback onTap;

  const _QuickAddChip({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppGlass.card(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        borderRadius: AppRadius.lgAll,
        child: SizedBox(
          width: 110,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top: icon + add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.15),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: const Icon(
                      Icons.set_meal_outlined,
                      size: 14,
                      color: AppColors.terracotta,
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.terracotta,
                    ),
                  ),
                ],
              ),
              // Bottom: name + kcal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${food.calories.toInt()} kcal',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.terracotta,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick add bottom sheet
// ---------------------------------------------------------------------------

class _QuickAddSheet extends ConsumerStatefulWidget {
  final PantryFood food;
  const _QuickAddSheet({required this.food});

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  double _servings = 1.0;
  String? _selectedMealId; // null = auto (create/find "Quick Add")
  bool _adding = false;

  double get _cal => widget.food.calories * _servings;
  double get _pro => widget.food.protein * _servings;
  double get _carb => widget.food.carbs * _servings;
  double get _fat => widget.food.fat * _servings;

  Future<void> _add() async {
    setState(() => _adding = true);

    final nutrition = ref.read(nutritionNotifierProvider);
    final notifier = ref.read(nutritionNotifierProvider.notifier);

    // Resolve which meal to add to
    String mealId;
    if (_selectedMealId != null) {
      mealId = _selectedMealId!;
    } else {
      // Look for an existing "Quick Add" meal today
      final existing =
          nutrition.value?.meals
              .where((m) => m.meal.name == 'Quick Add')
              .firstOrNull;
      if (existing != null) {
        mealId = existing.meal.id;
      } else {
        mealId = await notifier.addMeal('Quick Add');
      }
    }

    await notifier.addFoodEntry(
      mealId: mealId,
      name: widget.food.name,
      calories: _cal,
      protein: _pro,
      carbs: _carb,
      fat: _fat,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final nutritionAsync = ref.watch(nutritionNotifierProvider);
    final meals = nutritionAsync.value?.meals ?? [];

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

          // Food name + serving label
          Text(widget.food.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: 2),
          Text(widget.food.servingLabel, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.lg),

          // Serving counter + live macro row
          Row(
            children: [
              // Counter
              _ServingCounter(
                value: _servings,
                onChanged: (v) => setState(() => _servings = v),
              ),
              const SizedBox(width: AppSpacing.md),
              // Live macros
              Expanded(
                child: AppGlass.card(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  borderRadius: AppRadius.mdAll,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MacroLabel(
                        value: _cal.toInt(),
                        unit: 'kcal',
                        color: AppColors.terracotta,
                      ),
                      _MacroLabel(
                        value: _pro.toInt(),
                        unit: 'P',
                        color: AppColors.proteinColor,
                      ),
                      _MacroLabel(
                        value: _carb.toInt(),
                        unit: 'C',
                        color: AppColors.carbColor,
                      ),
                      _MacroLabel(
                        value: _fat.toInt(),
                        unit: 'F',
                        color: AppColors.fatColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Meal selector (only shown when meals exist today)
          if (meals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Add to meal', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: meals.length + 1, // +1 for "Quick Add" option
                separatorBuilder:
                    (_, _) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (ctx, i) {
                  // First chip is always "Quick Add" (auto)
                  if (i == 0) {
                    final selected = _selectedMealId == null;
                    return _MealChip(
                      label: 'Quick Add',
                      selected: selected,
                      onTap: () => setState(() => _selectedMealId = null),
                    );
                  }
                  final meal = meals[i - 1];
                  final selected = _selectedMealId == meal.meal.id;
                  return _MealChip(
                    label: meal.meal.name,
                    selected: selected,
                    onTap: () => setState(() => _selectedMealId = meal.meal.id),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          FilledButton(
            onPressed: _adding ? null : _add,
            child:
                _adding
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Add to Today'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Serving counter
// ---------------------------------------------------------------------------

class _ServingCounter extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _ServingCounter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppGlass.card(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      borderRadius: AppRadius.mdAll,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: Icons.remove,
            enabled: value > 0.5,
            onTap: () => onChanged((value - 0.5).clamp(0.5, 99)),
          ),
          SizedBox(
            width: 44,
            child: Center(
              child: Text(
                value == value.truncateToDouble()
                    ? value.toInt().toString()
                    : value.toStringAsFixed(1),
                style: AppTextStyles.titleLarge,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add,
            enabled: value < 99,
            onTap: () => onChanged((value + 0.5).clamp(0.5, 99)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Circular +/- button used in the serving counter
// ---------------------------------------------------------------------------
class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  // A circular button with a +/- icon, used in the serving counter
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color:
              enabled
                  ? AppColors.terracotta.withValues(alpha: 0.15)
                  : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                enabled
                    ? AppColors.terracotta.withValues(alpha: 0.4)
                    : AppColors.glassBorder.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.terracotta : AppColors.textOnDarkTertiary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Macro label inside the live preview card
// ---------------------------------------------------------------------------

class _MacroLabel extends StatelessWidget {
  final int value;
  final String unit;
  final Color color;

  const _MacroLabel({
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: AppTextStyles.titleMedium.copyWith(color: color)),
        Text(unit, style: AppTextStyles.labelSmall.copyWith(color: color)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Meal selector chip
// ---------------------------------------------------------------------------

class _MealChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MealChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ), // duration of the color transition
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.terracotta : AppColors.glassBg,
          borderRadius: AppRadius.xlAll,
          border: Border.all(
            color: selected ? AppColors.terracotta : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? Colors.white : AppColors.textOnDark,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------------------
// quick show widget of Todays foods
//------------------------------------------------------------------------------------------

class _ShowFoodsToday extends ConsumerWidget {
  const _ShowFoodsToday();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(nutritionNotifierProvider);

    return nutritionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e', style: AppTextStyles.bodyMedium),
      data: (nutrition) {
        final foods = nutrition.meals.expand((m) => m.entries).toList();
        if (foods.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Foods Eaten Today', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            Column(
              children:
                  foods.map((food) {
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Delete Food Entry'),
                                content: Text(
                                  'Are you sure you want to delete "${food.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ref
                                          .read(
                                            nutritionNotifierProvider.notifier,
                                          )
                                          .deleteFoodEntry(food.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.terracotta.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: AppRadius.smAll,
                            ),
                            child: const Icon(
                              Icons.set_meal_outlined,
                              size: 14,
                              color: AppColors.terracotta,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm - 2),
                          Text(food.name, style: AppTextStyles.bodyMedium),
                          const SizedBox(width: AppSpacing.sm - 2),
                          Text(
                            '${food.calories.toInt()} kcal',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.terracotta,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Quick complete habit bottom sheet
// ---------------------------------------------------------------------------

class _QuickCompleteHabit extends ConsumerStatefulWidget {
  final HabitWithStatus habit;
  const _QuickCompleteHabit({required this.habit});

  @override
  ConsumerState<_QuickCompleteHabit> createState() =>
      _QuickCompleteHabitState();
}

class _QuickCompleteHabitState extends ConsumerState<_QuickCompleteHabit> {
  bool _completing = false;

  Future<void> _complete() async {
    setState(() => _completing = true);

    final notifier = ref.read(habitsNotifierProvider.notifier);
    await notifier.toggleCompletion(widget.habit.habit.id);

    if (mounted) Navigator.pop(context);
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
          // Habit name
          Text(widget.habit.habit.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          // Confirm button
          FilledButton(
            onPressed: _completing ? null : _complete,
            child:
                _completing
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Mark Complete'),
          ),
        ],
      ),
    );
  }
}
