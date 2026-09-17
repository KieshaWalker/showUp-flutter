// nutrition_screen.dart — Nutrition tab: meal logging, food entries, water, goals.
//
// The Nutrition tab shows today's full food log — not just goals. Users can:
//   • See calorie + macro + micronutrient progress at a glance (ring + pills)
//   • Track water intake with quick-add buttons
//   • Add meals (Breakfast, Lunch, Dinner, Snack, or custom name)
//   • Add food entries from the pantry (with serving picker) or manually
//   • Tap a food entry to see its full nutrition breakdown, long-press to
//     delete it — the same tap/long-press pattern as the Overview tab's
//     "Eaten Today" list (see showFoodNutritionDialog/confirmDeleteFoodEntry)
//   • Long-press a meal to delete it and all its entries
//   • Edit daily goals — including micronutrient targets — via the tune icon
//
// Exported widgets/functions (used by presentation_screen.dart):
//   NutritionCalorieSummary   — calorie ring progress card
//   NutritionMacroRow         — row of macro progress pills
//   NutritionMacroPill        — individual macro/micro pill
//   showFoodNutritionDialog() — tap-to-view nutrition breakdown dialog
//   confirmDeleteFoodEntry()  — long-press-to-delete confirmation dialog
//
// Connections:
//   nutrition_notifier.dart — all state + mutations
//   pantry_notifier.dart    — powers the pantry food search in _AddFoodSheet
//   app_theme.dart          — AppGlass, AppColors, AppTextStyles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import '../../shared/widgets.dart';
import '../pantry/pantry_notifier.dart';
import 'nutrition_notifier.dart';

// =============================================================================
// Recommended daily values — shown as reference in the goals editor and used
// as fallback goals when the user hasn't set one yet. Mirrors the defaults
// baked into DailyNutritionGoals in db.dart (FDA general adult Daily Values
// for the micronutrients).
// =============================================================================

class NutritionRDA {
  NutritionRDA._();

  static const calories = 2000.0;
  static const protein = 150.0;
  static const carbs = 250.0;
  static const fat = 65.0;
  static const sugar = 50.0;
  static const waterMl = 2500.0;
  static const fiber = 28.0;
  static const sodium = 2300.0;
  static const cholesterol = 300.0;
  static const potassium = 4700.0;
  static const calcium = 1300.0;
  static const iron = 18.0;
  static const vitaminA = 900.0;
  static const vitaminC = 90.0;
}

// =============================================================================
// Main screen
// =============================================================================

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutritionAsync = ref.watch(nutritionNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const AppLogoTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Copy yesterday\'s meals',
            onPressed: () => _copyYesterday(context, ref),
          ),
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
        icon: const Icon(Icons.add),
        label: const Text('Add Meal'),
      ),
      body: nutritionAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.terracotta),
            ),
        error:
            (_, _) => const Center(
              child: Text("Couldn't load nutrition. Pull down to retry."),
            ),
        data: (nutrition) => _NutritionBody(nutrition: nutrition),
      ),
    );
  }
}

// =============================================================================
// Body
// =============================================================================

class _NutritionBody extends StatelessWidget {
  const _NutritionBody({required this.nutrition});
  final TodayNutrition nutrition;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        // ── Calorie ring + macros ────────────────────────────────────────────
        NutritionCalorieSummary(nutrition: nutrition),
        const SizedBox(height: AppSpacing.sm),
        NutritionMacroRow(nutrition: nutrition),
        const SizedBox(height: AppSpacing.lg),

        // ── Micronutrients ───────────────────────────────────────────────────
        Text('Micronutrients', style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        NutritionMicroGrid(nutrition: nutrition),
        const SizedBox(height: AppSpacing.lg),

        // ── Water ────────────────────────────────────────────────────────────
        _WaterSection(nutrition: nutrition),
        const SizedBox(height: AppSpacing.lg),

        // ── Meals ────────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Meals", style: AppTextStyles.titleLarge),
            if (nutrition.meals.isNotEmpty)
              Text(
                '${nutrition.totalCalories.toInt()} kcal',
                style: AppTextStyles.bodyMedium,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (nutrition.meals.isEmpty)
          _EmptyMeals()
        else
          ...nutrition.meals.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _MealCard(mealWithEntries: m),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Empty state
// =============================================================================

class _EmptyMeals extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppGlass.card(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 48,
            color: AppColors.glassBorder,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('No meals logged yet', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap + Add Meal to get started',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            icon: const Icon(Icons.history, size: 18),
            label: const Text('Copy yesterday\'s meals'),
            onPressed: () => _copyYesterday(context, ref),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Water section
// =============================================================================

class _WaterSection extends ConsumerWidget {
  const _WaterSection({required this.nutrition});
  final TodayNutrition nutrition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = nutrition.goals?.waterMl ?? 2500;
    final current = nutrition.totalWaterMl;
    final progress = (current / goal).clamp(0.0, 1.0);
    final isOver = current >= goal;
    final notifier = ref.read(nutritionNotifierProvider.notifier);

    return AppGlass.card(
      padding: AppPaddings.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.water_drop_outlined,
                    color: AppColors.waterColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Water', style: AppTextStyles.titleMedium),
                ],
              ),
              Text(
                '${formatWaterMl(current)} / ${formatWaterMl(goal)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      isOver
                          ? AppColors.eucalyptus
                          : AppColors.textOnDarkSecondary,
                  fontWeight: isOver ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: isOver ? AppColors.eucalyptus : AppColors.waterColor,
              backgroundColor: AppColors.waterColor.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _WaterChip(label: '+250ml', onTap: () => notifier.logWater(250)),
              const SizedBox(width: AppSpacing.sm),
              _WaterChip(label: '+500ml', onTap: () => notifier.logWater(500)),
              const SizedBox(width: AppSpacing.sm),
              _WaterChip(label: '+1L', onTap: () => notifier.logWater(1000)),
              const SizedBox(width: AppSpacing.sm),
              _WaterCustomChip(
                onTap: () => _showWaterDialog(context, notifier),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWaterDialog(BuildContext context, NutritionNotifier notifier) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Log Water'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(labelText: 'Amount (ml)'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final ml = double.tryParse(ctrl.text);
                  if (ml != null && ml > 0) notifier.logWater(ml);
                  Navigator.pop(ctx);
                },
                child: const Text('Log'),
              ),
            ],
          ),
    );
  }
}

class _WaterChip extends StatelessWidget {
  const _WaterChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.waterColor.withValues(alpha: 0.15),
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: AppColors.waterColor.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.waterColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _WaterCustomChip extends StatelessWidget {
  const _WaterCustomChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          'Custom',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textOnDark),
        ),
      ),
    );
  }
}

// =============================================================================
// Meal card
// =============================================================================

class _MealCard extends ConsumerStatefulWidget {
  const _MealCard({required this.mealWithEntries});
  final MealWithEntries mealWithEntries;

  @override
  ConsumerState<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends ConsumerState<_MealCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final m = widget.mealWithEntries;
    return AppGlass.card(
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          InkWell(
            borderRadius: AppRadius.lgAll,
            onTap: () => setState(() => _expanded = !_expanded),
            onLongPress: () => _confirmDelete(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.meal.name, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${m.calories.toInt()} kcal'
                          '  ·  P ${m.protein.toInt()}g'
                          '  C ${m.carbs.toInt()}g'
                          '  F ${m.fat.toInt()}g'
                          '  S ${m.sugar.toInt()}g',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      color: AppColors.textOnDarkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Entries ───────────────────────────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1),
            if (m.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'No food added yet',
                  style: AppTextStyles.bodyMedium,
                ),
              )
            else
              ...m.entries.map((e) => _FoodEntryTile(entry: e)),
            const Divider(height: 1),
            TextButton.icon(
              onPressed: () => _showAddFoodSheet(context, m.meal.id),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Food'),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete meal?'),
            content: Text(
              'Remove "${widget.mealWithEntries.meal.name}" and all its food entries?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref
                      .read(nutritionNotifierProvider.notifier)
                      .deleteMeal(widget.mealWithEntries.meal.id);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }
}

// =============================================================================
// Food entry tile — tap to view its nutrition breakdown, long-press to
// delete. Same interaction pattern as the Overview tab's "Eaten Today" list
// (see showFoodNutritionDialog/confirmDeleteFoodEntry below, shared by both).
// =============================================================================

class _FoodEntryTile extends ConsumerWidget {
  const _FoodEntryTile({required this.entry});
  final FoodEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => showFoodNutritionDialog(context, entry),
      onLongPress: () => confirmDeleteFoodEntry(context, ref, entry),
      child: ListTile(
        dense: true,
        title: Text(entry.name, style: AppTextStyles.bodyLarge),
        subtitle: Text(
          'P ${entry.protein.toInt()}g  C ${entry.carbs.toInt()}g  F ${entry.fat.toInt()}g  S ${entry.sugar.toInt()}g',
          style: AppTextStyles.bodyMedium,
        ),
        trailing: Text(
          '${entry.calories.toInt()} kcal',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.khaki,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Shared food-entry dialogs — tap to view, long-press to delete. Used by both
// the Nutrition tab's meal cards and the Overview tab's "Eaten Today" list so
// the two stay in sync.
// =============================================================================

void showFoodNutritionDialog(BuildContext context, FoodEntry food) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(food.name, style: AppTextStyles.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${food.calories.toInt()} kcal',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.terracotta,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: NutritionMacroPill(
                          label: 'Protein',
                          current: food.protein,
                          goal: null,
                          unit: 'g',
                          color: AppColors.proteinColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: NutritionMacroPill(
                          label: 'Carbs',
                          current: food.carbs,
                          goal: null,
                          unit: 'g',
                          color: AppColors.carbColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: NutritionMacroPill(
                          label: 'Fat',
                          current: food.fat,
                          goal: null,
                          unit: 'g',
                          color: AppColors.fatColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: NutritionMacroPill(
                          label: 'Sugar',
                          current: food.sugar,
                          goal: null,
                          unit: 'g',
                          color: AppColors.sugarColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Micronutrients',
                    style: AppTextStyles.labelSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final row in [
                  [
                    ('Fiber', food.fiber, 'g', AppColors.fiberColor),
                    ('Sodium', food.sodium, 'mg', AppColors.sodiumColor),
                  ],
                  [
                    (
                      'Cholesterol',
                      food.cholesterol,
                      'mg',
                      AppColors.cholesterolColor,
                    ),
                    (
                      'Potassium',
                      food.potassium,
                      'mg',
                      AppColors.potassiumColor,
                    ),
                  ],
                  [
                    ('Calcium', food.calcium, 'mg', AppColors.calciumColor),
                    ('Iron', food.iron, 'mg', AppColors.ironColor),
                  ],
                  [
                    (
                      'Vitamin A',
                      food.vitaminA,
                      'mcg',
                      AppColors.vitaminAColor,
                    ),
                    (
                      'Vitamin C',
                      food.vitaminC,
                      'mg',
                      AppColors.vitaminCColor,
                    ),
                  ],
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (label, value, unit, color) in row) ...[
                            Expanded(
                              child: NutritionMacroPill(
                                label: label,
                                current: value,
                                goal: null,
                                unit: unit,
                                color: color,
                              ),
                            ),
                            if (row.last != (label, value, unit, color))
                              const SizedBox(width: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
  );
}

void confirmDeleteFoodEntry(
  BuildContext context,
  WidgetRef ref,
  FoodEntry food,
) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Delete Food Entry'),
          content: Text('Remove "${food.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(nutritionNotifierProvider.notifier)
                    .deleteFoodEntry(food.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        ),
  );
}

// =============================================================================
// Add meal sheet
// =============================================================================

Future<void> _copyYesterday(BuildContext context, WidgetRef ref) async {
  final copied =
      await ref.read(nutritionNotifierProvider.notifier).copyYesterdaysMeals();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        copied ? 'Yesterday\'s meals copied' : 'No meals logged yesterday',
      ),
    ),
  );
}

void _showAddMealSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddMealSheet(),
  );
}

class _AddMealSheet extends ConsumerStatefulWidget {
  const _AddMealSheet();

  @override
  ConsumerState<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<_AddMealSheet> {
  static const _presets = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Brunch'];
  String? _selected;
  final _ctrl = TextEditingController();
  bool _custom = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      (!_custom && _selected != null) ||
      (_custom && _ctrl.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppDragHandle(),
          Text('Add Meal', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ..._presets.map(
                (p) => SelectableChip(
                  label: p,
                  selected: _selected == p && !_custom,
                  onTap:
                      () => setState(() {
                        _selected = p;
                        _custom = false;
                      }),
                ),
              ),
              SelectableChip(
                label: 'Custom',
                selected: _custom,
                onTap:
                    () => setState(() {
                      _selected = null;
                      _custom = true;
                    }),
              ),
            ],
          ),
          if (_custom) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _ctrl,
              autofocus: true,
              style: AppTextStyles.bodyLarge,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Meal name'),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: const Text('Add Meal'),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _custom ? _ctrl.text.trim() : _selected!;
    ref.read(nutritionNotifierProvider.notifier).addMeal(name);
    Navigator.pop(context);
  }
}

// =============================================================================
// Add food sheet — pantry search + manual entry
// =============================================================================

void _showAddFoodSheet(BuildContext context, String mealId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddFoodSheet(mealId: mealId),
  );
}

class _AddFoodSheet extends ConsumerStatefulWidget {
  const _AddFoodSheet({required this.mealId});
  final String mealId;

  @override
  ConsumerState<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<_AddFoodSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _sugarCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final _sodiumCtrl = TextEditingController();
  final _cholesterolCtrl = TextEditingController();
  final _potassiumCtrl = TextEditingController();
  final _calciumCtrl = TextEditingController();
  final _ironCtrl = TextEditingController();
  final _vitaminACtrl = TextEditingController();
  final _vitaminCCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(
      () => setState(() => _query = _searchCtrl.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _sugarCtrl.dispose();
    _fiberCtrl.dispose();
    _sodiumCtrl.dispose();
    _cholesterolCtrl.dispose();
    _potassiumCtrl.dispose();
    _calciumCtrl.dispose();
    _ironCtrl.dispose();
    _vitaminACtrl.dispose();
    _vitaminCCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder:
          (_, scrollCtrl) => Container(
            decoration: AppGlass.modal(),
            child: Column(
              children: [
                const AppDragHandle(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Food', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: AppSpacing.sm),
                      TabBar(
                        controller: _tab,
                        tabs: const [Tab(text: 'Pantry'), Tab(text: 'Manual')],
                        labelColor: AppColors.terracotta,
                        unselectedLabelColor: AppColors.textOnDarkTertiary,
                        indicatorColor: AppColors.terracotta,
                        dividerColor: AppColors.glassBorder,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _PantrySearchTab(
                        mealId: widget.mealId,
                        searchCtrl: _searchCtrl,
                        query: _query,
                        scrollCtrl: scrollCtrl,
                      ),
                      _ManualEntryTab(
                        mealId: widget.mealId,
                        nameCtrl: _nameCtrl,
                        calCtrl: _calCtrl,
                        proCtrl: _proCtrl,
                        carbCtrl: _carbCtrl,
                        fatCtrl: _fatCtrl,
                        sugarCtrl: _sugarCtrl,
                        fiberCtrl: _fiberCtrl,
                        sodiumCtrl: _sodiumCtrl,
                        cholesterolCtrl: _cholesterolCtrl,
                        potassiumCtrl: _potassiumCtrl,
                        calciumCtrl: _calciumCtrl,
                        ironCtrl: _ironCtrl,
                        vitaminACtrl: _vitaminACtrl,
                        vitaminCCtrl: _vitaminCCtrl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

// ── Pantry search tab ─────────────────────────────────────────────────────────

class _PantrySearchTab extends ConsumerWidget {
  const _PantrySearchTab({
    required this.mealId,
    required this.searchCtrl,
    required this.query,
    required this.scrollCtrl,
  });
  final String mealId;
  final TextEditingController searchCtrl;
  final String query;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantry = ref.watch(pantryNotifierProvider).value ?? [];
    final results =
        query.isEmpty
            ? pantry
            : pantry
                .where((f) => f.name.toLowerCase().contains(query))
                .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: searchCtrl,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search foods...',
              prefixIcon: const Icon(
                Icons.search_outlined,
                color: AppColors.textOnDarkTertiary,
              ),
              suffixIcon:
                  query.isNotEmpty
                      ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textOnDarkTertiary,
                        ),
                        tooltip: 'Clear search',
                        onPressed: searchCtrl.clear,
                      )
                      : null,
            ),
          ),
        ),
        Expanded(
          child:
              results.isEmpty
                  ? Center(
                    child: Text(
                      query.isEmpty
                          ? 'Pantry is empty'
                          : 'No foods match "$query"',
                      style: AppTextStyles.bodyMedium,
                    ),
                  )
                  : ListView.builder(
                    controller: scrollCtrl,
                    itemCount: results.length,
                    itemBuilder:
                        (_, i) =>
                            _PantryFoodTile(food: results[i], mealId: mealId),
                  ),
        ),
      ],
    );
  }
}

class _PantryFoodTile extends ConsumerWidget {
  const _PantryFoodTile({required this.food, required this.mealId});
  final PantryFood food;
  final String mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(food.name, style: AppTextStyles.bodyLarge),
      subtitle: Text(
        '${food.calories.toInt()} kcal · ${food.servingLabel}',
        style: AppTextStyles.bodyMedium,
      ),
      trailing: Text(
        'P${food.protein.toInt()} C${food.carbs.toInt()} F${food.fat.toInt()}',
        style: AppTextStyles.labelSmall,
      ),
      onTap: () => _openServingPicker(context, ref),
    );
  }

  void _openServingPicker(BuildContext context, WidgetRef ref) {
    // Capture the sheet's navigator before showing the dialog so we can
    // close both the dialog and the sheet from within the dialog's callback.
    final sheetNavigator = Navigator.of(context);
    double servings = 1.0;

    showDialog(
      context: context,
      builder:
          (dialogCtx) => StatefulBuilder(
            builder:
                (_, setSt) => AlertDialog(
                  title: Text(food.name),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(food.servingLabel, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed:
                                servings > 0.5
                                    ? () => setSt(
                                      () =>
                                          servings = double.parse(
                                            (servings - 0.5).toStringAsFixed(1),
                                          ),
                                    )
                                    : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Fewer servings',
                          ),
                          SizedBox(
                            width: 56,
                            child: Center(
                              child: Text(
                                '${servings.toStringAsFixed(servings == servings.truncateToDouble() ? 0 : 1)}×',
                                style: AppTextStyles.titleLarge,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed:
                                () => setSt(
                                  () =>
                                      servings = double.parse(
                                        (servings + 0.5).toStringAsFixed(1),
                                      ),
                                ),
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'More servings',
                          ),
                        ],
                      ),
                      Text(
                        '${(food.calories * servings).toInt()} kcal',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.khaki,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        ref
                            .read(nutritionNotifierProvider.notifier)
                            .addFoodEntry(
                              mealId: mealId,
                              name: food.name,
                              calories: food.calories * servings,
                              protein: food.protein * servings,
                              carbs: food.carbs * servings,
                              fat: food.fat * servings,
                              sugar: food.sugar * servings,
                              fiber: food.fiber * servings,
                              sodium: food.sodium * servings,
                              cholesterol: food.cholesterol * servings,
                              potassium: food.potassium * servings,
                              calcium: food.calcium * servings,
                              iron: food.iron * servings,
                              vitaminA: food.vitaminA * servings,
                              vitaminC: food.vitaminC * servings,
                            );
                        Navigator.pop(dialogCtx); // close dialog
                        sheetNavigator.pop(); // close food sheet
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }
}

// ── Manual entry tab ──────────────────────────────────────────────────────────

class _ManualEntryTab extends ConsumerWidget {
  const _ManualEntryTab({
    required this.mealId,
    required this.nameCtrl,
    required this.calCtrl,
    required this.proCtrl,
    required this.carbCtrl,
    required this.fatCtrl,
    required this.sugarCtrl,
    required this.fiberCtrl,
    required this.sodiumCtrl,
    required this.cholesterolCtrl,
    required this.potassiumCtrl,
    required this.calciumCtrl,
    required this.ironCtrl,
    required this.vitaminACtrl,
    required this.vitaminCCtrl,
  });
  final String mealId;
  final TextEditingController nameCtrl;
  final TextEditingController calCtrl;
  final TextEditingController proCtrl;
  final TextEditingController carbCtrl;
  final TextEditingController fatCtrl;
  final TextEditingController sugarCtrl;
  final TextEditingController fiberCtrl;
  final TextEditingController sodiumCtrl;
  final TextEditingController cholesterolCtrl;
  final TextEditingController potassiumCtrl;
  final TextEditingController calciumCtrl;
  final TextEditingController ironCtrl;
  final TextEditingController vitaminACtrl;
  final TextEditingController vitaminCCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          _FormField(ctrl: nameCtrl, label: 'Food name'),
          _FormField(ctrl: calCtrl, label: 'Calories', unit: 'kcal'),
          _FormField(ctrl: proCtrl, label: 'Protein', unit: 'g'),
          _FormField(ctrl: carbCtrl, label: 'Carbs', unit: 'g'),
          _FormField(ctrl: fatCtrl, label: 'Fat', unit: 'g'),
          _FormField(ctrl: sugarCtrl, label: 'Sugar', unit: 'g'),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Micronutrients (optional)',
              style: AppTextStyles.labelSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _FormField(ctrl: fiberCtrl, label: 'Fiber', unit: 'g'),
          _FormField(ctrl: sodiumCtrl, label: 'Sodium', unit: 'mg'),
          _FormField(ctrl: cholesterolCtrl, label: 'Cholesterol', unit: 'mg'),
          _FormField(ctrl: potassiumCtrl, label: 'Potassium', unit: 'mg'),
          _FormField(ctrl: calciumCtrl, label: 'Calcium', unit: 'mg'),
          _FormField(ctrl: ironCtrl, label: 'Iron', unit: 'mg'),
          _FormField(ctrl: vitaminACtrl, label: 'Vitamin A', unit: 'mcg'),
          _FormField(ctrl: vitaminCCtrl, label: 'Vitamin C', unit: 'mg'),
          const SizedBox(height: AppSpacing.lg),
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
                    sugar: double.tryParse(sugarCtrl.text) ?? 0,
                    fiber: double.tryParse(fiberCtrl.text) ?? 0,
                    sodium: double.tryParse(sodiumCtrl.text) ?? 0,
                    cholesterol: double.tryParse(cholesterolCtrl.text) ?? 0,
                    potassium: double.tryParse(potassiumCtrl.text) ?? 0,
                    calcium: double.tryParse(calciumCtrl.text) ?? 0,
                    iron: double.tryParse(ironCtrl.text) ?? 0,
                    vitaminA: double.tryParse(vitaminACtrl.text) ?? 0,
                    vitaminC: double.tryParse(vitaminCCtrl.text) ?? 0,
                  );
              Navigator.pop(context);
            },
            child: const Text('Add to Meal'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Goals sheet
// =============================================================================

void _showGoalsSheet(
  BuildContext context,
  WidgetRef ref,
  TodayNutrition? nutrition,
) {
  final goals = nutrition?.goals;
  final calCtrl = TextEditingController(
    text: '${goals?.calories.toInt() ?? NutritionRDA.calories.toInt()}',
  );
  final proCtrl = TextEditingController(
    text: '${goals?.protein.toInt() ?? NutritionRDA.protein.toInt()}',
  );
  final carbCtrl = TextEditingController(
    text: '${goals?.carbs.toInt() ?? NutritionRDA.carbs.toInt()}',
  );
  final fatCtrl = TextEditingController(
    text: '${goals?.fat.toInt() ?? NutritionRDA.fat.toInt()}',
  );
  final waterCtrl = TextEditingController(
    text: '${goals?.waterMl.toInt() ?? NutritionRDA.waterMl.toInt()}',
  );
  final fiberCtrl = TextEditingController(
    text: '${goals?.fiber.toInt() ?? NutritionRDA.fiber.toInt()}',
  );
  final sodiumCtrl = TextEditingController(
    text: '${goals?.sodium.toInt() ?? NutritionRDA.sodium.toInt()}',
  );
  final cholesterolCtrl = TextEditingController(
    text: '${goals?.cholesterol.toInt() ?? NutritionRDA.cholesterol.toInt()}',
  );
  final potassiumCtrl = TextEditingController(
    text: '${goals?.potassium.toInt() ?? NutritionRDA.potassium.toInt()}',
  );
  final calciumCtrl = TextEditingController(
    text: '${goals?.calcium.toInt() ?? NutritionRDA.calcium.toInt()}',
  );
  final ironCtrl = TextEditingController(
    text: '${goals?.iron.toInt() ?? NutritionRDA.iron.toInt()}',
  );
  final vitaminACtrl = TextEditingController(
    text: '${goals?.vitaminA.toInt() ?? NutritionRDA.vitaminA.toInt()}',
  );
  final vitaminCCtrl = TextEditingController(
    text: '${goals?.vitaminC.toInt() ?? NutritionRDA.vitaminC.toInt()}',
  );
  final curWeightCtrl = TextEditingController(
    text: goals?.currentWeightKg?.toStringAsFixed(1) ?? '',
  );
  final tgtWeightCtrl = TextEditingController(
    text: goals?.targetWeightKg?.toStringAsFixed(1) ?? '',
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
                const AppDragHandle(),
                Text('Daily Goals', style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Set your daily nutrition targets. "Recommended" is the '
                  'general adult FDA Daily Value, shown for reference.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Macronutrients', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _FormField(
                  ctrl: calCtrl,
                  label: 'Calories',
                  unit: 'kcal',
                  recommended: NutritionRDA.calories,
                ),
                _FormField(
                  ctrl: proCtrl,
                  label: 'Protein',
                  unit: 'g',
                  recommended: NutritionRDA.protein,
                ),
                _FormField(
                  ctrl: carbCtrl,
                  label: 'Carbs',
                  unit: 'g',
                  recommended: NutritionRDA.carbs,
                ),
                _FormField(
                  ctrl: fatCtrl,
                  label: 'Fat',
                  unit: 'g',
                  recommended: NutritionRDA.fat,
                ),
                _FormField(
                  ctrl: waterCtrl,
                  label: 'Water',
                  unit: 'ml',
                  recommended: NutritionRDA.waterMl,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Micronutrients', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _FormField(
                  ctrl: fiberCtrl,
                  label: 'Fiber',
                  unit: 'g',
                  recommended: NutritionRDA.fiber,
                ),
                _FormField(
                  ctrl: sodiumCtrl,
                  label: 'Sodium',
                  unit: 'mg',
                  recommended: NutritionRDA.sodium,
                ),
                _FormField(
                  ctrl: cholesterolCtrl,
                  label: 'Cholesterol',
                  unit: 'mg',
                  recommended: NutritionRDA.cholesterol,
                ),
                _FormField(
                  ctrl: potassiumCtrl,
                  label: 'Potassium',
                  unit: 'mg',
                  recommended: NutritionRDA.potassium,
                ),
                _FormField(
                  ctrl: calciumCtrl,
                  label: 'Calcium',
                  unit: 'mg',
                  recommended: NutritionRDA.calcium,
                ),
                _FormField(
                  ctrl: ironCtrl,
                  label: 'Iron',
                  unit: 'mg',
                  recommended: NutritionRDA.iron,
                ),
                _FormField(
                  ctrl: vitaminACtrl,
                  label: 'Vitamin A',
                  unit: 'mcg',
                  recommended: NutritionRDA.vitaminA,
                ),
                _FormField(
                  ctrl: vitaminCCtrl,
                  label: 'Vitamin C',
                  unit: 'mg',
                  recommended: NutritionRDA.vitaminC,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Weight', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _FormField(
                  ctrl: curWeightCtrl,
                  label: 'Current Weight',
                  unit: 'kg',
                  decimal: true,
                ),
                _FormField(
                  ctrl: tgtWeightCtrl,
                  label: 'Target Weight',
                  unit: 'kg',
                  decimal: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(nutritionNotifierProvider.notifier)
                        .updateGoals(
                          calories:
                              double.tryParse(calCtrl.text) ??
                              NutritionRDA.calories,
                          protein:
                              double.tryParse(proCtrl.text) ??
                              NutritionRDA.protein,
                          carbs:
                              double.tryParse(carbCtrl.text) ??
                              NutritionRDA.carbs,
                          fat: double.tryParse(fatCtrl.text) ?? NutritionRDA.fat,
                          waterMl:
                              double.tryParse(waterCtrl.text) ??
                              NutritionRDA.waterMl,
                          fiber:
                              double.tryParse(fiberCtrl.text) ??
                              NutritionRDA.fiber,
                          sodium:
                              double.tryParse(sodiumCtrl.text) ??
                              NutritionRDA.sodium,
                          cholesterol:
                              double.tryParse(cholesterolCtrl.text) ??
                              NutritionRDA.cholesterol,
                          potassium:
                              double.tryParse(potassiumCtrl.text) ??
                              NutritionRDA.potassium,
                          calcium:
                              double.tryParse(calciumCtrl.text) ??
                              NutritionRDA.calcium,
                          iron:
                              double.tryParse(ironCtrl.text) ??
                              NutritionRDA.iron,
                          vitaminA:
                              double.tryParse(vitaminACtrl.text) ??
                              NutritionRDA.vitaminA,
                          vitaminC:
                              double.tryParse(vitaminCCtrl.text) ??
                              NutritionRDA.vitaminC,
                          currentWeightKg: double.tryParse(curWeightCtrl.text),
                          targetWeightKg: double.tryParse(tgtWeightCtrl.text),
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

// =============================================================================
// Shared helpers
// =============================================================================

class _FormField extends StatelessWidget {
  const _FormField({
    required this.ctrl,
    required this.label,
    this.unit,
    this.decimal = false,
    this.recommended,
  });
  final TextEditingController ctrl;
  final String label;
  final String? unit;
  final bool decimal;

  /// Reference daily value shown as helper text below the field, e.g.
  /// "Recommended: 28g" — the general adult RDA/FDA Daily Value used as
  /// this goal's fallback (see [NutritionRDA]).
  final double? recommended;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: AppTextStyles.bodyLarge,
        keyboardType:
            decimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
        decoration: InputDecoration(
          labelText: unit != null ? '$label ($unit)' : label,
          helperText:
              recommended != null
                  ? 'Recommended: ${recommended!.toInt()}${unit != null ? ' $unit' : ''}'
                  : null,
        ),
      ),
    );
  }
}

// =============================================================================
// Exported shared widgets — used by presentation_screen.dart
// =============================================================================

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

class NutritionMacroRow extends StatelessWidget {
  final TodayNutrition nutrition;
  const NutritionMacroRow({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final goals = nutrition.goals;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Expanded(
          child: NutritionMacroPill(
            label: 'Protein',
            current: nutrition.totalProtein,
            goal: goals?.protein ?? NutritionRDA.protein,
            unit: 'g',
            color: AppColors.proteinColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: NutritionMacroPill(
            label: 'Carbs',
            current: nutrition.totalCarbs,
            goal: goals?.carbs ?? NutritionRDA.carbs,
            unit: 'g',
            color: AppColors.carbColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: NutritionMacroPill(
            label: 'Fat',
            current: nutrition.totalFat,
            goal: goals?.fat ?? NutritionRDA.fat,
            unit: 'g',
            color: AppColors.fatColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: NutritionMacroPill(
            label: 'Sugar',
            current: nutrition.totalSugar,
            // No user-configurable goal for sugar yet — use the common
            // recommended daily added-sugar limit as the default target.
            goal: NutritionRDA.sugar,
            unit: 'g',
            color: AppColors.sugarColor,
          ),
        ),
        ],
      ),
    );
  }
}

/// A 2-column grid of micronutrient progress pills (fiber, sodium,
/// cholesterol, potassium, calcium, iron, vitamin A, vitamin C) — same
/// visual language as [NutritionMacroRow], one row of two pills at a time.
class NutritionMicroGrid extends StatelessWidget {
  final TodayNutrition nutrition;
  const NutritionMicroGrid({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final goals = nutrition.goals;
    final pairs = [
      (
        NutritionMacroPill(
          label: 'Fiber',
          current: nutrition.totalFiber,
          goal: goals?.fiber ?? NutritionRDA.fiber,
          unit: 'g',
          color: AppColors.fiberColor,
        ),
        NutritionMacroPill(
          label: 'Sodium',
          current: nutrition.totalSodium,
          goal: goals?.sodium ?? NutritionRDA.sodium,
          unit: 'mg',
          color: AppColors.sodiumColor,
        ),
      ),
      (
        NutritionMacroPill(
          label: 'Cholesterol',
          current: nutrition.totalCholesterol,
          goal: goals?.cholesterol ?? NutritionRDA.cholesterol,
          unit: 'mg',
          color: AppColors.cholesterolColor,
        ),
        NutritionMacroPill(
          label: 'Potassium',
          current: nutrition.totalPotassium,
          goal: goals?.potassium ?? NutritionRDA.potassium,
          unit: 'mg',
          color: AppColors.potassiumColor,
        ),
      ),
      (
        NutritionMacroPill(
          label: 'Calcium',
          current: nutrition.totalCalcium,
          goal: goals?.calcium ?? NutritionRDA.calcium,
          unit: 'mg',
          color: AppColors.calciumColor,
        ),
        NutritionMacroPill(
          label: 'Iron',
          current: nutrition.totalIron,
          goal: goals?.iron ?? NutritionRDA.iron,
          unit: 'mg',
          color: AppColors.ironColor,
        ),
      ),
      (
        NutritionMacroPill(
          label: 'Vitamin A',
          current: nutrition.totalVitaminA,
          goal: goals?.vitaminA ?? NutritionRDA.vitaminA,
          unit: 'mcg',
          color: AppColors.vitaminAColor,
        ),
        NutritionMacroPill(
          label: 'Vitamin C',
          current: nutrition.totalVitaminC,
          goal: goals?.vitaminC ?? NutritionRDA.vitaminC,
          unit: 'mg',
          color: AppColors.vitaminCColor,
        ),
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < pairs.length; i++) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: pairs[i].$1),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: pairs[i].$2),
              ],
            ),
          ),
          if (i < pairs.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class NutritionMacroPill extends StatelessWidget {
  final String label;
  final double current;

  /// Target amount to show progress against. When null, the pill shows the
  /// current total only (no progress bar or "/ goal" line) — used for
  /// nutrients that are tracked but don't have a goal yet, like sugar.
  final double? goal;
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
    final goal = this.goal;
    final hasGoal = goal != null && goal > 0;
    final progress = hasGoal ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final isOver = hasGoal && current > goal;

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
          if (hasGoal) ...[
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
        ],
      ),
    );
  }
}
