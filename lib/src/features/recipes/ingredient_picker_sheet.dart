// ingredient_picker_sheet.dart — category-filtered pantry food picker used
// by the recipe step editor (step_card.dart) to add an ingredient to a step.
// Returns a PickedIngredient (the chosen PantryFood + a servings multiplier
// + an optional descriptive amount label) via showIngredientPickerSheet(),
// or null if cancelled.
//
// A persistent "Add new <category>" row lets the user create a personal
// PantryFood on the spot (reuses PantryNotifier.addFood with `category`
// set) — from then on it's just a normal pantry food, so it reappears as a
// one-tap pick in that category forever after (sorted most-recent-first,
// same as the Nutrition tab's Add Food sheet).

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import '../../shared/widgets.dart' show AppDragHandle, SelectableChip;
import '../nutrition/nutrition_screen.dart' show NutritionFormField;
import '../pantry/pantry_notifier.dart';
import 'recipe_constants.dart';

class PickedIngredient {
  final PantryFood food;
  final double servings;
  final String? amountLabel;

  const PickedIngredient({
    required this.food,
    required this.servings,
    this.amountLabel,
  });
}

Future<PickedIngredient?> showIngredientPickerSheet(
  BuildContext context, {
  String? initialCategory,
}) {
  return showModalBottomSheet<PickedIngredient>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _IngredientPickerSheet(initialCategory: initialCategory),
  );
}

class _IngredientPickerSheet extends ConsumerStatefulWidget {
  final String? initialCategory;

  const _IngredientPickerSheet({this.initialCategory});

  @override
  ConsumerState<_IngredientPickerSheet> createState() =>
      _IngredientPickerSheetState();
}

class _IngredientPickerSheetState
    extends ConsumerState<_IngredientPickerSheet> {
  late String _category = widget.initialCategory ?? kIngredientCategories.first;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickFood(PantryFood food) async {
    final amountCtrl = TextEditingController();
    double servings = 1.0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (_, setSt) => AlertDialog(
                  title: Text(food.name),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: amountCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Amount (optional)',
                          hintText: 'e.g. 1/4 cup',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
    if (confirmed != true || !mounted) return;

    Navigator.pop(
      context,
      PickedIngredient(
        food: food,
        servings: servings,
        amountLabel:
            amountCtrl.text.trim().isEmpty ? null : amountCtrl.text.trim(),
      ),
    );
  }

  Future<void> _addNewIngredient() async {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom:
                  MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppDragHandle(),
                Text('New $_category', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.md),
                NutritionFormField(ctrl: nameCtrl, label: 'Name', isText: true),
                NutritionFormField(
                  ctrl: calCtrl,
                  label: 'Calories',
                  unit: 'kcal',
                ),
                NutritionFormField(ctrl: proCtrl, label: 'Protein', unit: 'g'),
                NutritionFormField(ctrl: carbCtrl, label: 'Carbs', unit: 'g'),
                NutritionFormField(ctrl: fatCtrl, label: 'Fat', unit: 'g'),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      Navigator.pop(sheetContext, true);
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
    );
    if (created != true || !mounted) return;

    final name = nameCtrl.text.trim();
    await ref
        .read(pantryNotifierProvider.notifier)
        .addFood(
          name: name,
          calories: double.tryParse(calCtrl.text) ?? 0,
          protein: double.tryParse(proCtrl.text) ?? 0,
          carbs: double.tryParse(carbCtrl.text) ?? 0,
          fat: double.tryParse(fatCtrl.text) ?? 0,
          servingLabel: '1 serving',
          category: _category,
        );
    if (!mounted) return;

    // The new food streams in via pantryNotifierProvider shortly after —
    // find it by name+category to auto-select it straight into this step.
    final foods = ref.read(pantryNotifierProvider).value ?? [];
    final match =
        foods
            .where((f) => f.name == name && f.category == _category)
            .firstOrNull;
    if (match != null && mounted) {
      await _pickFood(match);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allFoods = ref.watch(pantryNotifierProvider).value ?? [];
    final categoryFoods =
        allFoods.where((f) => f.category == _category).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final results =
        _query.isEmpty
            ? categoryFoods
            : categoryFoods
                .where((f) => f.name.toLowerCase().contains(_query))
                .toList();

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Add Ingredient',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: kIngredientCategories.length,
                    separatorBuilder:
                        (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final cat = kIngredientCategories[i];
                      return SelectableChip(
                        label: cat,
                        selected: cat == _category,
                        onTap: () => setState(() => _category = cat),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search $_category...',
                      prefixIcon: const Icon(Icons.search_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.terracotta,
                        ),
                        title: Text('Add new $_category'),
                        onTap: _addNewIngredient,
                      ),
                      const Divider(height: 1),
                      if (results.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            _query.isEmpty
                                ? 'No $_category ingredients yet'
                                : 'No matches for "$_query"',
                            style: AppTextStyles.bodyMedium,
                          ),
                        )
                      else
                        for (final food in results)
                          ListTile(
                            title: Text(food.name),
                            subtitle: Text(
                              '${food.calories.toInt()} kcal · ${food.servingLabel}',
                            ),
                            onTap: () => _pickFood(food),
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
