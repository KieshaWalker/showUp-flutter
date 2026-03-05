import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_theme.dart';
import 'nutrition_notifier.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(nutritionNotifierProvider);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Edit goals',
            onPressed: () => _showGoalsSheet(context, ref, nutritionAsync.value),
          ),
        ],
      ),
      body: nutritionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (nutrition) {
          final goals = nutrition?.goals;
          return ListView(
            padding: AppPaddings.all,
            children: [
              Text('Daily Goals', style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppSpacing.md),
              _GoalCard(label: 'Calories', value: goals?.calories.toInt() ?? 2000, unit: 'kcal'),
              const SizedBox(height: AppSpacing.sm),
              _GoalCard(label: 'Protein',  value: goals?.protein.toInt()  ?? 150,  unit: 'g'),
              const SizedBox(height: AppSpacing.sm),
              _GoalCard(label: 'Carbs',    value: goals?.carbs.toInt()    ?? 250,  unit: 'g'),
              const SizedBox(height: AppSpacing.sm),
              _GoalCard(label: 'Fat',      value: goals?.fat.toInt()      ?? 65,   unit: 'g'),
              const SizedBox(height: AppSpacing.sm),
              _GoalCard(label: 'Water',    value: goals?.waterMl.toInt()  ?? 2500, unit: 'ml'),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => _showGoalsSheet(context, ref, nutrition),
                icon: const Icon(Icons.tune_outlined),
                label: const Text('Edit Goals'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showGoalsSheet(
    BuildContext context,
    WidgetRef ref,
    TodayNutrition? nutrition,
  ) {
    final goals = nutrition?.goals;
    final calCtrl   = TextEditingController(text: '${goals?.calories.toInt() ?? 2000}');
    final proCtrl   = TextEditingController(text: '${goals?.protein.toInt()  ?? 150}');
    final carbCtrl  = TextEditingController(text: '${goals?.carbs.toInt()    ?? 250}');
    final fatCtrl   = TextEditingController(text: '${goals?.fat.toInt()      ?? 65}');
    final waterCtrl = TextEditingController(text: '${goals?.waterMl.toInt()  ?? 2500}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
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
              Text('Set your daily nutrition targets', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.lg - 4),
              _FormField(ctrl: calCtrl,   label: 'Calories', unit: 'kcal'),
              _FormField(ctrl: proCtrl,   label: 'Protein',  unit: 'g'),
              _FormField(ctrl: carbCtrl,  label: 'Carbs',    unit: 'g'),
              _FormField(ctrl: fatCtrl,   label: 'Fat',      unit: 'g'),
              _FormField(ctrl: waterCtrl, label: 'Water',    unit: 'ml'),
              const SizedBox(height: AppSpacing.lg - 4),
              FilledButton(
                onPressed: () {
                  ref.read(nutritionNotifierProvider.notifier).updateGoals(
                    calories: double.tryParse(calCtrl.text)   ?? 2000,
                    protein:  double.tryParse(proCtrl.text)   ?? 150,
                    carbs:    double.tryParse(carbCtrl.text)  ?? 250,
                    fat:      double.tryParse(fatCtrl.text)   ?? 65,
                    waterMl:  double.tryParse(waterCtrl.text) ?? 2500,
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
// Goal card
// ---------------------------------------------------------------------------

class _GoalCard extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  const _GoalCard({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return AppGlass.card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.titleMedium),
            Text('$value $unit', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.khaki)),
          ],
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

  const _FormField({required this.ctrl, required this.label, this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: AppTextStyles.bodyLarge,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: unit != null ? '$label ($unit)' : label,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared display widgets — used by presentation_screen.dart
// ---------------------------------------------------------------------------

class NutritionCalorieSummary extends StatelessWidget {
  final TodayNutrition nutrition;
  const NutritionCalorieSummary({super.key, required this.nutrition});

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
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 14, color: barColor),
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
                Text('Calories', style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.xs),
                Text('${current.toInt()}', style: AppTextStyles.displayLarge.copyWith(fontSize: 28)),
                Text('of ${goal.toInt()} kcal', style: AppTextStyles.bodyMedium),
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

class NutritionMacroRow extends StatelessWidget {
  final TodayNutrition nutrition;
  const NutritionMacroRow({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final goals = nutrition.goals;
    return Row(
      children: [
        Expanded(
          child: NutritionMacroPill(
            label: 'Protein',
            current: nutrition.totalProtein,
            goal: goals?.protein ?? 150,
            unit: 'g',
            color: AppColors.proteinColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: NutritionMacroPill(
            label: 'Carbs',
            current: nutrition.totalCarbs,
            goal: goals?.carbs ?? 250,
            unit: 'g',
            color: AppColors.carbColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: NutritionMacroPill(
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

class NutritionMacroPill extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final String unit;
  final Color color;

  const NutritionMacroPill({
    super.key,
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
