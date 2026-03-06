import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import '../agent/agent_notifier.dart';
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
    final profile = ref.watch(profileProvider).value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Padding(
  padding: const EdgeInsets.only(top: 50.0, left: 0, right: 20.0, bottom: 20.0), // Adjust this value as needed
  child: SvgPicture.asset(
    'assets/images/logo.svg',
    height: 100,
    width: 150,
    colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          )
  ),
),
        
        titleTextStyle: AppTextStyles.displayLarge,
      ),
      body: ListView(
        padding: AppPaddings.all,
        children: [
          // greeting section
          Text(
            _greeting(
              now.hour,
              profile?.displayName.isNotEmpty == true
                  ? profile!.displayName
                  : null,
            ),
            style: AppTextStyles.headlineMedium,
          ),

          // date label
          Text(_dateLabel(now), style: AppTextStyles.bodyMedium),

          // time label
          Text(
            TimeOfDay.now().format(context),
            style: AppTextStyles.bodyMedium,
          ),

          const Divider(height: AppSpacing.lg),

// nutrition widget 
          nutritionAsync.when(
            data:
                (nutrition) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NutritionCalorieSummary(nutrition: nutrition),
                    const SizedBox(height: AppSpacing.md),
                    NutritionMacroRow(nutrition: nutrition),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const _HabitsCard(),
          const SizedBox(height: AppSpacing.lg),

          const Divider(height: AppSpacing.lg),

          const _QuickAddSection(),
          const SizedBox(height: 80),

          const Divider(height: AppSpacing.lg),

          const _ShowFoodsToday(),

          const _HabitsCompletedToday(),

          // Watches habitsNotifierProvider directly so it reacts to toggles
          const Divider(height: AppSpacing.lg),

          const _IncompleteHabitsListForDay(),
          const SizedBox(height: AppSpacing.lg),

          const _AgentSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _HabitsCard — circular progress summary card
// ---------------------------------------------------------------------------
//
// Shows a circular progress indicator + "X of Y done" text.
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │  WHAT IS COUNTED                                                     │
// │  done  = habits where completedToday == true                        │
// │  total = all habits (daily + weekly)                                 │
// │                                                                      │
// │  This intentionally uses completedToday so the ring resets to 0     │
// │  every morning (daily habits) and ticks up as you check things off. │
// │  A weekly habit at 3/3 that was last completed yesterday shows as   │
// │  "not done today" — it contributes 0 to this ring.                  │
// │                                                                      │
// │  To count "fully done for the period" instead (i.e. weekly habits   │
// │  that met their target contribute 1 even if not completed today),   │
// │  change the done line to:                                            │
// │    final done = habits.where((h) => h.isDone).length;               │
// └──────────────────────────────────────────────────────────────────────┘

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
          // Counts habits completed today (resets daily).
          // See comment block above to switch to isDone-based counting.
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
                        const SizedBox(width: AppSpacing.xs),
                        Text('Habits', style: AppTextStyles.labelSmall),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
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

class _QuickAddSection extends ConsumerStatefulWidget {
  const _QuickAddSection();

  @override
  ConsumerState<_QuickAddSection> createState() => _QuickAddSectionState();
}

class _QuickAddSectionState extends ConsumerState<_QuickAddSection> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showQuickAddSheet(PantryFood food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _QuickAddSheet(food: food),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pantryAsync = ref.watch(pantryNotifierProvider);

    return pantryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
      data: (foods) {
        if (foods.isEmpty) return const SizedBox.shrink();

        final filtered =
            _query.isEmpty
                ? foods
                : foods
                    .where(
                      (f) =>
                          f.name.toLowerCase().contains(_query.toLowerCase()),
                    )
                    .toList();

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
            const SizedBox(height: AppSpacing.lg),

            // Search bar
            AppGlass.card(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppRadius.lgAll,
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 16,
                    color: AppColors.textOnDarkTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search pantry…',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnDarkTertiary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.textOnDarkTertiary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Horizontal food chips
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'No foods match "$_query"',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnDarkTertiary,
                  ),
                ),
              )
            else
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: filtered.length,
                  separatorBuilder:
                      (_, _) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder:
                      (ctx, i) => _QuickAddChip(
                        food: filtered[i],
                        onTap: () => _showQuickAddSheet(filtered[i]),
                      ),
                ),
              ),
          ],
        );
      },
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
          const SizedBox(height: AppSpacing.xs),
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
            const SizedBox(height: AppSpacing.xl),
            Text('Add to meal', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: meals.length + 1, // +1 for "Quick Add" option
                separatorBuilder:
                    (_, _) => const SizedBox(width: AppSpacing.md),
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
          horizontal: AppSpacing.md,
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
            const SizedBox(height: AppSpacing.lg),
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
                          const SizedBox(width: AppSpacing.xs),
                          Text(food.name, style: AppTextStyles.bodyMedium),
                          const SizedBox(width: AppSpacing.xs),
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

//------------------------------------------------------------------------------------------
// show habits completed today
//------------------------------------------------------------------------------------------
class _HabitsCompletedToday extends ConsumerWidget {
  const _HabitsCompletedToday();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsNotifierProvider);

    return habitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e', style: AppTextStyles.bodyMedium),
      data: (habits) {
        final completedToday =
            habits.where((h) => h.completedToday).toList();
        if (completedToday.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Completed Today', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
                 
            Column(
              children: 
                  completedToday.map((h) => Text(h.habit.name)).toList(),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _IncompleteHabitsListForDay — "Remaining Today" reactive habit list
// ---------------------------------------------------------------------------
//
// Watches habitsNotifierProvider so the list instantly reflects any toggle.
//
// ┌──────────────────────────────────────────────────────────────────────┐
// │  FILTER LOGIC — "show this habit if…"                               │
// │                                                                      │
// │  !completedToday  — not done yet today (hides it once toggled)      │
// │  && !isDone       — goal for this period not yet fully met           │
// │                                                                      │
// │  Combined effect:                                                    │
// │  DAILY habit, not done today          → shown ✓                     │
// │  DAILY habit, done today              → hidden (completedToday)     │
// │                                                                      │
// │  WEEKLY habit, 0/3, not done today    → shown ✓                     │
// │  WEEKLY habit, 1/3, done today        → hidden until tomorrow       │
// │  WEEKLY habit, 2/3, done today        → hidden until tomorrow       │
// │  WEEKLY habit, 3/3 (target met)       → hidden all week (isDone)    │
// │                                                                      │
// │  The "come back tomorrow" behaviour is automatic: completedToday     │
// │  resets to false at local midnight, so the habit reappears tomorrow  │
// │  if the weekly target still hasn't been reached.                     │
// │                                                                      │
// │  To change what appears here, edit the `remaining` filter below.    │
// └──────────────────────────────────────────────────────────────────────┘

class _IncompleteHabitsListForDay extends ConsumerStatefulWidget {
  const _IncompleteHabitsListForDay();

  @override
  ConsumerState<_IncompleteHabitsListForDay> createState() =>
      _IncompleteHabitsListForDayState();
}

class _IncompleteHabitsListForDayState
    extends ConsumerState<_IncompleteHabitsListForDay> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(habitsNotifierProvider)
        .when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
          data: (habits) {
            // !completedToday → hasn't been done yet today
            // !isDone         → period goal (daily: today, weekly: week) not met
            final remaining =
                habits.where((h) => !h.completedToday && !h.isDone).toList();
            if (remaining.isEmpty) return const SizedBox.shrink();

            // Filter by search query (case-insensitive name match)
            final filtered =
                _query.isEmpty
                    ? remaining
                    : remaining
                        .where(
                          (h) => h.habit.name.toLowerCase().contains(
                            _query.toLowerCase(),
                          ),
                        )
                        .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remaining Today', style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.lg),

                // Search bar — only shown when there's more than one habit
                if (remaining.length > 1) ...[
                  AppGlass.card(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    borderRadius: AppRadius.lgAll,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          size: 16,
                          color: AppColors.textOnDarkTertiary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _query = v),
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Search habits…',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textOnDarkTertiary,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.textOnDarkTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      'No habits match "$_query"',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnDarkTertiary,
                      ),
                    ),
                  )
                else
                  ...filtered.map((h) => _HabitTodayChip(h: h)),
              ],
            );
          },
        );
  }
}

// Tappable row for one remaining habit.
// Shows habit name + weekly progress subtitle for weekly habits.
// Tap  → quick-complete sheet.
// Long press → edit this week's day completions (weekly habits only).
class _HabitTodayChip extends StatelessWidget {
  final HabitWithStatus h;
  const _HabitTodayChip({required this.h});

  @override
  Widget build(BuildContext context) {
    final isWeekly = h.habit.frequencyType == 'weekly';
    return GestureDetector(
      onTap:
          () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => _QuickCompleteHabitForDay(habit: h.habit),
          ),
      onLongPress:
          isWeekly
              ? () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => _EditWeekCompletionsSheet(h: h),
              )
              : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: AppGlass.card(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          borderRadius: AppRadius.lgAll,
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.15),
                  borderRadius: AppRadius.smAll,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: AppColors.terracotta,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.habit.name, style: AppTextStyles.bodyMedium),
                    if (isWeekly)
                      Text(
                        '${h.completionsThisWeek}/${h.habit.targetDaysPerWeek}× this week',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.khaki,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _EditWeekCompletionsSheet — long-press sheet to edit weekly day completions
// ---------------------------------------------------------------------------
//
// Shows Mon–Sun as toggleable day pills. Tapping a past/today pill calls
// toggleCompletionForDate so the user can backfill or remove completions.
// Future days are shown disabled.

class _EditWeekCompletionsSheet extends ConsumerStatefulWidget {
  final HabitWithStatus h;
  const _EditWeekCompletionsSheet({required this.h});

  @override
  ConsumerState<_EditWeekCompletionsSheet> createState() =>
      _EditWeekCompletionsSheetState();
}

class _EditWeekCompletionsSheetState
    extends ConsumerState<_EditWeekCompletionsSheet> {
  Set<DateTime> _completedDates = {};
  bool _loading = true;

  DateTime get _weekStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Monday = weekday 1
    return today.subtract(Duration(days: today.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dates = await ref
        .read(habitsNotifierProvider.notifier)
        .getCompletionDatesForWeek(widget.h.habit.id, _weekStart);
    if (mounted) {
      setState(() {
        _completedDates = dates;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(DateTime day) async {
    await ref
        .read(habitsNotifierProvider.notifier)
        .toggleCompletionForDate(widget.h.habit.id, day);
    // Optimistically update local set so the UI reacts immediately.
    setState(() {
      if (_completedDates.contains(day)) {
        _completedDates = {..._completedDates}..remove(day);
      } else {
        _completedDates = {..._completedDates, day};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final count = _completedDates.length;
    final target = widget.h.habit.targetDaysPerWeek;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
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
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(widget.h.habit.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$count / $target days this week',
            style: AppTextStyles.bodyMedium.copyWith(
              color: count >= target ? AppColors.eucalyptus : AppColors.khaki,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = days[i];
                final isFuture = day.isAfter(today);
                final done = _completedDates.contains(day);
                return GestureDetector(
                  onTap: isFuture ? null : () => _toggle(day),
                  child: Column(
                    children: [
                      Text(
                        labels[i],
                        style: AppTextStyles.labelSmall.copyWith(
                          color:
                              isFuture
                                  ? AppColors.textOnDarkTertiary
                                  : AppColors.textOnDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              done
                                  ? AppColors.terracotta
                                  : isFuture
                                  ? Colors.transparent
                                  : AppColors.glassBg,
                          border: Border.all(
                            color:
                                done
                                    ? AppColors.terracotta
                                    : isFuture
                                    ? AppColors.glassBorder.withValues(
                                      alpha: 0.3,
                                    )
                                    : AppColors.glassBorder,
                          ),
                        ),
                        child:
                            done
                                ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${day.day}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color:
                              isFuture
                                  ? AppColors.textOnDarkTertiary
                                  : AppColors.textOnDark,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

// Bottom sheet: confirm completion of a single habit for today.
// Calls toggleCompletion which is idempotent (safe to call twice → undo).
class _QuickCompleteHabitForDay extends ConsumerStatefulWidget {
  final Habit habit;
  const _QuickCompleteHabitForDay({required this.habit});

  @override
  ConsumerState<_QuickCompleteHabitForDay> createState() =>
      _QuickCompleteHabitForDayState();
}

class _QuickCompleteHabitForDayState
    extends ConsumerState<_QuickCompleteHabitForDay> {
  bool _completing = false;

  Future<void> _complete() async {
    setState(() => _completing = true);
    final notifier = ref.read(habitsNotifierProvider.notifier);
    await notifier.toggleCompletion(widget.habit.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: const Color.fromARGB(9, 255, 255, 255),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(widget.habit.name, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.xl),
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

// ---------------------------------------------------------------------------
// _AgentSection — coach chat panel at the bottom of the overview screen
// ---------------------------------------------------------------------------

class _AgentSection extends ConsumerStatefulWidget {
  const _AgentSection();

  @override
  ConsumerState<_AgentSection> createState() => _AgentSectionState();
}

class _AgentSectionState extends ConsumerState<_AgentSection> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(agentProvider.notifier).sendMessage(text);
    // Scroll to bottom after the new messages are rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agentProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 16,
              color: AppColors.terracotta,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('Coach', style: AppTextStyles.titleMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Message history
        if (state.messages.isNotEmpty)
          AppGlass.card(
            padding: AppPaddings.card,
            borderRadius: AppRadius.xlAll,
            child: SizedBox(
              height: 240,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.messages.length,
                itemBuilder:
                    (ctx, i) => _ChatBubble(message: state.messages[i]),
              ),
            ),
          ),

        // Thinking indicator
        if (state.loading)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.terracotta,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Thinking…',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnDarkTertiary,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: AppSpacing.md),

        // Input row
        AppGlass.card(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          borderRadius: AppRadius.lgAll,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _send(),
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Ask your coach…',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDarkTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    size: 14,
                    color: AppColors.terracotta,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// _ChatBubble
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  final AgentMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 12,
                color: AppColors.terracotta,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? AppColors.terracotta.withValues(alpha: 0.2)
                        : AppColors.glassBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isUser ? 12 : 2),
                  bottomRight: Radius.circular(isUser ? 2 : 12),
                ),
                border: Border.all(
                  color:
                      isUser
                          ? AppColors.terracotta.withValues(alpha: 0.3)
                          : AppColors.glassBorder,
                ),
              ),
              child: Text(message.text, style: AppTextStyles.bodyMedium),
            ),
          ),
          if (isUser) const SizedBox(width: AppSpacing.xl),
        ],
      ),
    );
  }
}
