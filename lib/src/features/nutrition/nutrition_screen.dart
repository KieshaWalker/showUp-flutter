import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import 'nutrition_notifier.dart';

/// Main nutrition tracking screen displayed in the AppShell.
///
/// Widget hierarchy:
/// NutritionScreen (ConsumerWidget)
///   ↓
/// Scaffold (main container)
///   ├─ AppBar (title + goals settings action)
///   ├─ body: _NutritionBody
///   │   └─ Shows today's meals, macros, and water intake
///   └─ FloatingActionButton (add new meal)
///
/// Data flow:
/// 1. Watches nutritionNotifierProvider (provided by NutritionNotifier)
/// 2. Receives AsyncValue<TodayNutrition> containing:
///    - List<MealWithEntries> (today's meals with food items)
///    - Macro and calorie totals
///    - Water intake
///    - Daily nutrition goals
/// 3. Renders macro progress bars and meal list
/// 4. User can tap meal to add food items
/// 5. User can edit daily nutrition goals
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(nutritionNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Your Nutrition'),
        titleTextStyle: AppTextStyles.displayLarge,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Edit goals',
            onPressed:
                () => _showGoalsSheet(context, ref, nutritionAsync.value),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMealSheet(context, ref),
        icon: const Icon(Icons.restaurant_outlined),
        label: const Text('Add Meal'),
      ),
      body: nutritionAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.terracotta),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (nutrition) => _NutritionBody(nutrition: nutrition),
      ),
    );
  }

  void _showAddMealSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New Meal', style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.lg - 4),
                TextField(
                  controller: nameController,
                  style: AppTextStyles.bodyLarge,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'e.g. Breakfast, Lunch, Snack',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg - 4),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    Navigator.pop(ctx);
                    await ref
                        .read(nutritionNotifierProvider.notifier)
                        .addMeal(name);
                        print('Added meal: $name');
                  },
                  child: const Text('Create Meal'),
                ),
              ],
            ),
          ),
    );
  }

  void _showGoalsSheet(
    BuildContext context,
    WidgetRef ref,
    TodayNutrition? nutrition,
  ) {
    final goals = nutrition?.goals;
    final calCtrl = TextEditingController(
      text: '${goals?.calories.toInt() ?? 2000}',
    );
    final proCtrl = TextEditingController(
      text: '${goals?.protein.toInt() ?? 150}',
    );
    final carbCtrl = TextEditingController(
      text: '${goals?.carbs.toInt() ?? 250}',
    );
    final fatCtrl = TextEditingController(text: '${goals?.fat.toInt() ?? 65}');
    final waterCtrl = TextEditingController(
      text: '${goals?.waterMl.toInt() ?? 2500}',
    );

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Daily Goals', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.sm - 2),
                  Text(
                    'Set your daily nutrition targets',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg - 4),
                  _FormField(ctrl: calCtrl, label: 'Calories', unit: 'kcal'),
                  _FormField(ctrl: proCtrl, label: 'Protein', unit: 'g'),
                  _FormField(ctrl: carbCtrl, label: 'Carbs', unit: 'g'),
                  _FormField(ctrl: fatCtrl, label: 'Fat', unit: 'g'),
                  _FormField(ctrl: waterCtrl, label: 'Water', unit: 'ml'),
                  const SizedBox(height: AppSpacing.lg - 4),
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(nutritionNotifierProvider.notifier)
                          .updateGoals(
                            calories: double.tryParse(calCtrl.text) ?? 2000,
                            protein: double.tryParse(proCtrl.text) ?? 150,
                            carbs: double.tryParse(carbCtrl.text) ?? 250,
                            fat: double.tryParse(fatCtrl.text) ?? 65,
                            waterMl: double.tryParse(waterCtrl.text) ?? 2500,
                          );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Goals'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _NutritionBody extends ConsumerWidget {
  final TodayNutrition nutrition;
  const _NutritionBody({required this.nutrition});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: AppPaddings.all,
      children: [
        _CalorieSummary(nutrition: nutrition),
        const SizedBox(height: 12),
        _MacroRow(nutrition: nutrition),
        const SizedBox(height: 12),
        _WaterCard(nutrition: nutrition, ref: ref),
        const SizedBox(height: AppSpacing.lg),
        Text('Today\'s Meals', style: AppTextStyles.titleMedium),
        const SizedBox(height: 10),
        if (nutrition.meals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_outlined,
                    size: 48,
                    color: AppColors.khaki.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No meals yet',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.khaki,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tap "Add Meal" to log your first meal',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ...nutrition.meals.map((m) => _MealCard(meal: m)),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Calorie summary ring-style card
// ---------------------------------------------------------------------------

class _CalorieSummary extends StatelessWidget {
  final TodayNutrition nutrition;
  const _CalorieSummary({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final goal = nutrition.goals?.calories ?? 2000;
    final current = nutrition.totalCalories;
    final remaining = (goal - current).clamp(0, double.infinity);
    final progress = (current / goal).clamp(0.0, 1.0);

    final isOver = current > goal;
    final barColor = isOver ? AppColors.terracotta : AppColors.eucalyptus;

    return AppGlass.card(
      padding: AppPaddings.card,
      borderRadius: AppRadius.xlAll,
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.glassBorder,
                  color: barColor,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 14,
                      color: barColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg - 4),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calories', style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${current.toInt()}',
                  style: AppTextStyles.displayLarge.copyWith(fontSize: 28),
                ),
                Text(
                  'of ${goal.toInt()} kcal',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm - 2),
                Text(
                  isOver
                      ? '${(current - goal).toInt()} kcal over'
                      : '${remaining.toInt()} kcal remaining',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isOver ? AppColors.terracotta : AppColors.eucalyptus,
                    fontWeight: FontWeight.w600,
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
// Macro row (protein / carbs / fat pills)
// ---------------------------------------------------------------------------

class _MacroRow extends StatelessWidget {
  final TodayNutrition nutrition;
  const _MacroRow({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final goals = nutrition.goals;
    return Row(
      children: [
        Expanded(
          child: _MacroPill(
            label: 'Protein',
            current: nutrition.totalProtein,
            goal: goals?.protein ?? 150,
            unit: 'g',
            color: AppColors.proteinColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MacroPill(
            label: 'Carbs',
            current: nutrition.totalCarbs,
            goal: goals?.carbs ?? 250,
            unit: 'g',
            color: AppColors.carbColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MacroPill(
            label: 'Fat',
            current: nutrition.totalFat,
            goal: goals?.fat ?? 65,
            unit: 'g',
            color: AppColors.fatColor,
          ),
        ),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final String unit;
  final Color color;

  const _MacroPill({
    required this.label,
    required this.current,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final isOver = current > goal;

    return AppGlass.card(
      padding: const EdgeInsets.all(12),
      borderRadius: AppRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: AppSpacing.sm - 2),
          Text(
            '${current.toInt()}$unit',
            style: AppTextStyles.titleMedium.copyWith(
              color: isOver ? AppColors.terracotta : AppColors.textOnDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm - 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              color: isOver ? AppColors.terracotta : color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('/ ${goal.toInt()}$unit', style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Water card
// ---------------------------------------------------------------------------

class _WaterCard extends StatelessWidget {
  final TodayNutrition nutrition;
  final WidgetRef ref;
  const _WaterCard({required this.nutrition, required this.ref});

  @override
  Widget build(BuildContext context) {
    final goal = nutrition.goals?.waterMl ?? 2500;
    final current = nutrition.totalWaterMl;
    final progress = (current / goal).clamp(0.0, 1.0);
    final glasses = (current / 250).floor();

    return AppGlass.card(
      padding: AppPaddings.all,
      borderRadius: AppRadius.lgAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_outlined,
                color: AppColors.waterColor,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm - 2),
              Text('Water', style: AppTextStyles.titleMedium),
              const Spacer(),
              Text(
                '${(current / 1000).toStringAsFixed(1)} / ${(goal / 1000).toStringAsFixed(1)} L',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: AppColors.waterColor,
              backgroundColor: AppColors.waterColor.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('$glasses glasses', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              _WaterBtn(
                label: '+250ml',
                onTap:
                    () => ref
                        .read(nutritionNotifierProvider.notifier)
                        .logWater(250),
              ),
              const SizedBox(width: AppSpacing.sm),
              _WaterBtn(
                label: '+500ml',
                onTap:
                    () => ref
                        .read(nutritionNotifierProvider.notifier)
                        .logWater(500),
              ),
              const SizedBox(width: AppSpacing.sm),
              _WaterBtn(
                label: '+1L',
                onTap:
                    () => ref
                        .read(nutritionNotifierProvider.notifier)
                        .logWater(1000),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _WaterBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.waterColor.withValues(alpha: 0.1),
          borderRadius: AppRadius.circular(10),
          border: Border.all(color: AppColors.waterColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.waterColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Meal card
// ---------------------------------------------------------------------------

class _MealCard extends ConsumerWidget {
  final MealWithEntries meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppGlass.card(
        borderRadius: AppRadius.lgAll,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            childrenPadding: EdgeInsets.zero,
            title: Text(meal.meal.name, style: AppTextStyles.titleMedium),
            subtitle: Text(
              '${meal.calories.toInt()} kcal  ·  P ${meal.protein.toInt()}g  C ${meal.carbs.toInt()}g  F ${meal.fat.toInt()}g',
              style: AppTextStyles.bodyMedium,
            ),
            children: [
              if (meal.entries.isNotEmpty)
                const Divider(height: 1, indent: 16, endIndent: 16),
              ...meal.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.name, style: AppTextStyles.bodyLarge),
                            Text(
                              'P ${e.protein.toInt()}g  C ${e.carbs.toInt()}g  F ${e.fat.toInt()}g',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${e.calories.toInt()} kcal',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textOnDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        () => _showAddFoodSheet(context, ref, meal.meal.id),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add food'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFoodSheet(BuildContext context, WidgetRef ref, String mealId) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add Food', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.lg - 4),
                  _FormField(ctrl: nameCtrl, label: 'Food name'),
                  _FormField(
                    ctrl: calCtrl,
                    label: 'Calories',
                    unit: 'kcal',
                    numeric: true,
                  ),
                  _FormField(
                    ctrl: proCtrl,
                    label: 'Protein',
                    unit: 'g',
                    numeric: true,
                  ),
                  _FormField(
                    ctrl: carbCtrl,
                    label: 'Carbs',
                    unit: 'g',
                    numeric: true,
                  ),
                  _FormField(
                    ctrl: fatCtrl,
                    label: 'Fat',
                    unit: 'g',
                    numeric: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      ref
                          .read(nutritionNotifierProvider.notifier)
                          .addFoodEntry(
                            mealId: mealId,
                            name: name,
                            calories: double.tryParse(calCtrl.text) ?? 0,
                            protein: double.tryParse(proCtrl.text) ?? 0,
                            carbs: double.tryParse(carbCtrl.text) ?? 0,
                            fat: double.tryParse(fatCtrl.text) ?? 0,
                          );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Add Food'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared form field
// ---------------------------------------------------------------------------

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String? unit;
  final bool numeric;

  const _FormField({
    required this.ctrl,
    required this.label,
    this.unit,
    this.numeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: AppTextStyles.bodyLarge,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: unit != null ? '$label ($unit)' : label,
        ),
      ),
    );
  }
}
