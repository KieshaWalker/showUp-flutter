// nutrition_screen.dart — Nutrition tab: meal logging, food entries, water, goals.
//
// The Nutrition tab shows today's full food log — not just goals. Users can:
//   • See calorie + macro progress at a glance (ring + macro pills)
//   • Track water intake with quick-add buttons
//   • Add meals (Breakfast, Lunch, Dinner, Snack, or custom name)
//   • Add food entries from the pantry (with serving picker) or manually
//   • Swipe a food entry left to delete it
//   • Long-press a meal to delete it and all its entries
//   • Edit daily goals via the tune icon in the app bar
//
// Exported widgets (used by presentation_screen.dart):
//   NutritionCalorieSummary — calorie ring progress card
//   NutritionMacroRow       — row of macro progress pills
//   NutritionMacroPill      — individual macro pill (P / C / F)
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
            onPressed: () =>
                _showGoalsSheet(context, ref, nutritionAsync.value),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMealSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Meal'),
      ),
      body: nutritionAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.terracotta)),
        error: (_, _) => const Center(
            child: Text("Couldn't load nutrition. Pull down to retry.")),
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
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
      children: [
        // ── Calorie ring + macros ────────────────────────────────────────────
        NutritionCalorieSummary(nutrition: nutrition),
        const SizedBox(height: AppSpacing.sm),
        NutritionMacroRow(nutrition: nutrition),
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
          Icon(Icons.restaurant_menu_outlined,
              size: 48, color: AppColors.glassBorder),
          const SizedBox(height: AppSpacing.md),
          Text('No meals logged yet', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text('Tap + Add Meal to get started',
              style: AppTextStyles.bodyMedium),
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
                  const Icon(Icons.water_drop_outlined,
                      color: AppColors.waterColor, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Water', style: AppTextStyles.titleMedium),
                ],
              ),
              Text(
                '${_mlLabel(current)} / ${_mlLabel(goal)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isOver
                      ? AppColors.eucalyptus
                      : AppColors.textOnDarkSecondary,
                  fontWeight:
                      isOver ? FontWeight.w600 : FontWeight.normal,
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
              _WaterChip(
                  label: '+250ml',
                  onTap: () => notifier.logWater(250)),
              const SizedBox(width: AppSpacing.sm),
              _WaterChip(
                  label: '+500ml',
                  onTap: () => notifier.logWater(500)),
              const SizedBox(width: AppSpacing.sm),
              _WaterChip(
                  label: '+1L',
                  onTap: () => notifier.logWater(1000)),
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

  String _mlLabel(double ml) => ml >= 1000
      ? '${(ml / 1000).toStringAsFixed(1)}L'
      : '${ml.toInt()}ml';

  void _showWaterDialog(
      BuildContext context, NutritionNotifier notifier) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
              child: const Text('Cancel')),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.waterColor.withValues(alpha: 0.15),
          borderRadius: AppRadius.mdAll,
          border: Border.all(
              color: AppColors.waterColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.waterColor, fontWeight: FontWeight.w700),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text('Custom',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textOnDark)),
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
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.meal.name,
                            style: AppTextStyles.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${m.calories.toInt()} kcal'
                          '  ·  P ${m.protein.toInt()}g'
                          '  C ${m.carbs.toInt()}g'
                          '  F ${m.fat.toInt()}g',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more,
                        color: AppColors.textOnDarkSecondary),
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
                child: Text('No food added yet',
                    style: AppTextStyles.bodyMedium),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Delete meal?'),
        content: Text(
            'Remove "${widget.mealWithEntries.meal.name}" and all its food entries?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(nutritionNotifierProvider.notifier)
                  .deleteMeal(widget.mealWithEntries.meal.id);
            },
            child: Text('Delete',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Food entry tile — swipe left to delete
// =============================================================================

class _FoodEntryTile extends ConsumerWidget {
  const _FoodEntryTile({required this.entry});
  final FoodEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: AppColors.terracotta.withValues(alpha: 0.2),
        child:
            const Icon(Icons.delete_outline, color: AppColors.terracotta),
      ),
      onDismissed: (_) => ref
          .read(nutritionNotifierProvider.notifier)
          .deleteFoodEntry(entry.id),
      child: ListTile(
        dense: true,
        title: Text(entry.name, style: AppTextStyles.bodyLarge),
        subtitle: Text(
          'P ${entry.protein.toInt()}g  C ${entry.carbs.toInt()}g  F ${entry.fat.toInt()}g',
          style: AppTextStyles.bodyMedium,
        ),
        trailing: Text(
          '${entry.calories.toInt()} kcal',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.khaki, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
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
  static const _presets = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Brunch'
  ];
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
              ..._presets.map((p) => SelectableChip(
                    label: p,
                    selected: _selected == p && !_custom,
                    onTap: () => setState(() {
                      _selected = p;
                      _custom = false;
                    }),
                  )),
              SelectableChip(
                label: 'Custom',
                selected: _custom,
                onTap: () => setState(() {
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
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.toLowerCase()));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: AppGlass.modal(),
        child: Column(
          children: [
            const AppDragHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Food', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  TabBar(
                    controller: _tab,
                    tabs: const [
                      Tab(text: 'Pantry'),
                      Tab(text: 'Manual'),
                    ],
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
    final results = query.isEmpty
        ? pantry
        : pantry
            .where((f) => f.name.toLowerCase().contains(query))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
          child: TextField(
            controller: searchCtrl,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search foods...',
              prefixIcon: const Icon(Icons.search_outlined,
                  color: AppColors.textOnDarkTertiary),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          color: AppColors.textOnDarkTertiary),
                      onPressed: searchCtrl.clear,
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: results.isEmpty
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
                  itemBuilder: (_, i) => _PantryFoodTile(
                    food: results[i],
                    mealId: mealId,
                  ),
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
      builder: (dialogCtx) => StatefulBuilder(
        builder: (_, setSt) => AlertDialog(
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
                    onPressed: servings > 0.5
                        ? () => setSt(() => servings = double.parse(
                            (servings - 0.5).toStringAsFixed(1)))
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
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
                    onPressed: () => setSt(() => servings = double.parse(
                        (servings + 0.5).toStringAsFixed(1))),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              Text(
                '${(food.calories * servings).toInt()} kcal',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.khaki),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                ref.read(nutritionNotifierProvider.notifier).addFoodEntry(
                      mealId: mealId,
                      name: food.name,
                      calories: food.calories * servings,
                      protein: food.protein * servings,
                      carbs: food.carbs * servings,
                      fat: food.fat * servings,
                    );
                Navigator.pop(dialogCtx); // close dialog
                sheetNavigator.pop();     // close food sheet
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
  });
  final String mealId;
  final TextEditingController nameCtrl;
  final TextEditingController calCtrl;
  final TextEditingController proCtrl;
  final TextEditingController carbCtrl;
  final TextEditingController fatCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        children: [
          _FormField(ctrl: nameCtrl, label: 'Food name'),
          _FormField(ctrl: calCtrl, label: 'Calories', unit: 'kcal'),
          _FormField(ctrl: proCtrl, label: 'Protein', unit: 'g'),
          _FormField(ctrl: carbCtrl, label: 'Carbs', unit: 'g'),
          _FormField(ctrl: fatCtrl, label: 'Fat', unit: 'g'),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              ref.read(nutritionNotifierProvider.notifier).addFoodEntry(
                    mealId: mealId,
                    name: name,
                    calories: double.tryParse(calCtrl.text) ?? 0,
                    protein: double.tryParse(proCtrl.text) ?? 0,
                    carbs: double.tryParse(carbCtrl.text) ?? 0,
                    fat: double.tryParse(fatCtrl.text) ?? 0,
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
    BuildContext context, WidgetRef ref, TodayNutrition? nutrition) {
  final goals = nutrition?.goals;
  final calCtrl =
      TextEditingController(text: '${goals?.calories.toInt() ?? 2000}');
  final proCtrl =
      TextEditingController(text: '${goals?.protein.toInt() ?? 150}');
  final carbCtrl =
      TextEditingController(text: '${goals?.carbs.toInt() ?? 250}');
  final fatCtrl =
      TextEditingController(text: '${goals?.fat.toInt() ?? 65}');
  final waterCtrl =
      TextEditingController(text: '${goals?.waterMl.toInt() ?? 2500}');
  final curWeightCtrl = TextEditingController(
      text: goals?.currentWeightKg?.toStringAsFixed(1) ?? '');
  final tgtWeightCtrl = TextEditingController(
      text: goals?.targetWeightKg?.toStringAsFixed(1) ?? '');

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
            const AppDragHandle(),
            Text('Daily Goals', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('Set your daily nutrition targets',
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            _FormField(ctrl: calCtrl, label: 'Calories', unit: 'kcal'),
            _FormField(ctrl: proCtrl, label: 'Protein', unit: 'g'),
            _FormField(ctrl: carbCtrl, label: 'Carbs', unit: 'g'),
            _FormField(ctrl: fatCtrl, label: 'Fat', unit: 'g'),
            _FormField(ctrl: waterCtrl, label: 'Water', unit: 'ml'),
            _FormField(
                ctrl: curWeightCtrl,
                label: 'Current Weight',
                unit: 'kg',
                decimal: true),
            _FormField(
                ctrl: tgtWeightCtrl,
                label: 'Target Weight',
                unit: 'kg',
                decimal: true),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () {
                ref.read(nutritionNotifierProvider.notifier).updateGoals(
                      calories:
                          double.tryParse(calCtrl.text) ?? 2000,
                      protein: double.tryParse(proCtrl.text) ?? 150,
                      carbs: double.tryParse(carbCtrl.text) ?? 250,
                      fat: double.tryParse(fatCtrl.text) ?? 65,
                      waterMl:
                          double.tryParse(waterCtrl.text) ?? 2500,
                      currentWeightKg:
                          double.tryParse(curWeightCtrl.text),
                      targetWeightKg:
                          double.tryParse(tgtWeightCtrl.text),
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
  });
  final TextEditingController ctrl;
  final String label;
  final String? unit;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: AppTextStyles.bodyLarge,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        decoration: InputDecoration(
          labelText: unit != null ? '$label ($unit)' : label,
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
    final barColor =
        isOver ? AppColors.terracotta : AppColors.eucalyptus;

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
                    style: AppTextStyles.titleMedium
                        .copyWith(fontSize: 14, color: barColor),
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
                  style: AppTextStyles.displayLarge
                      .copyWith(fontSize: 28),
                ),
                Text('of ${goal.toInt()} kcal',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm - 2),
                Text(
                  isOver
                      ? '${(current - goal).toInt()} kcal over'
                      : '${remaining.toInt()} kcal remaining',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isOver
                        ? AppColors.terracotta
                        : AppColors.eucalyptus,
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
              color: isOver
                  ? AppColors.terracotta
                  : AppColors.textOnDark,
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
