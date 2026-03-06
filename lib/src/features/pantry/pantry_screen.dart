// pantry_screen.dart — The Pantry tab: browse and manage the food library.
//
// Shows:
//   • A searchable list of all pantry foods (global presets + personal foods)
//   • Each row shows the food name, serving size, and calorie count
//   • FAB to add a personal food (opens a form bottom sheet)
//   • Long-press or swipe a personal food to edit or delete it
//   • Global preset foods (isPreset = true) are read-only — no edit/delete
//
// Search:
//   Filters the list client-side by name as the user types — no network call
//   needed since the full pantry is cached locally in SQLite.
//
// Connections:
//   pantry_notifier.dart    — pantryNotifierProvider drives the list;
//                             addFood, updateFood, deleteFood called from here
//   nutrition_screen.dart   — links to PantryScreen (or reuses the picker)
//                             when the user taps "add from pantry" in a meal
//   app_theme.dart          — AppGlass, AppColors, AppTextStyles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import 'pantry_notifier.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foodsAsync = ref.watch(pantryNotifierProvider);

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
        onPressed: () => _showFoodForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
      body: foodsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.terracotta),
        ),
        error: (e, _) => const Center(child: Text("Couldn't load your pantry. Pull down to try again.")),
        data: (foods) {
          final filtered = _query.isEmpty
              ? foods
              : foods
                  .where((f) =>
                      f.name.toLowerCase().contains(_query.toLowerCase()))
                  .toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
                child: TextField(
                  controller: _searchCtrl,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search foods…',
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textOnDarkTertiary),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textOnDarkTertiary),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Count label
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} item${filtered.length == 1 ? '' : 's'}',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),

              // Food list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.kitchen_outlined,
                                size: 56,
                                color: AppColors.textOnDarkTertiary),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _query.isEmpty
                                  ? 'No foods yet'
                                  : 'No results for "$_query"',
                              style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.textOnDarkSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.md,
                            120),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (ctx, i) => _FoodCard(
                          food: filtered[i],
                          onEdit: () => _showFoodForm(context, food: filtered[i]),
                          onDelete: () => _confirmDelete(context, filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFoodForm(BuildContext context, {PantryFood? food}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FoodFormSheet(
        food: food,
        onSave: ({
          required String name,
          required double calories,
          required double protein,
          required double carbs,
          required double fat,
          required String servingLabel,
        }) async {
          final notifier = ref.read(pantryNotifierProvider.notifier);
          if (food == null) {
            await notifier.addFood(
              name: name,
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fat,
              servingLabel: servingLabel,
            );
          } else {
            await notifier.updateFood(
              id: food.id,
              name: name,
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fat,
              servingLabel: servingLabel,
            );
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, PantryFood food) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${food.name}"?', style: AppTextStyles.titleMedium),
        content: Text(
          'This food will be removed from your pantry.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(pantryNotifierProvider.notifier).deleteFood(food.id);
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
// Food card
// ---------------------------------------------------------------------------

class _FoodCard extends StatelessWidget {
  final PantryFood food;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FoodCard({
    required this.food,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        onLongPress: onDelete,
        borderRadius: AppRadius.lgAll,
        child: AppGlass.card(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 14),
          borderRadius: AppRadius.lgAll,
          child: Row(
            children: [
              // Icon badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.15),
                  borderRadius: AppRadius.mdAll,
                ),
                child: const Icon(Icons.set_meal_outlined,
                    size: 20, color: AppColors.terracotta),
              ),
              const SizedBox(width: AppSpacing.md),

              // Name + serving
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(food.name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(food.servingLabel, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),

              // Macro summary
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${food.calories.toInt()} kcal',
                    style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.terracotta),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'P ${food.protein.toInt()}  C ${food.carbs.toInt()}  F ${food.fat.toInt()}',
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),

              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textOnDarkTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Food form sheet (add + edit)
// ---------------------------------------------------------------------------

typedef _SaveCallback = Future<void> Function({
  required String name,
  required double calories,
  required double protein,
  required double carbs,
  required double fat,
  required String servingLabel,
});

class _FoodFormSheet extends StatefulWidget {
  final PantryFood? food;
  final _SaveCallback onSave;

  const _FoodFormSheet({required this.food, required this.onSave});

  @override
  State<_FoodFormSheet> createState() => _FoodFormSheetState();
}

class _FoodFormSheetState extends State<_FoodFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _calCtrl;
  late final TextEditingController _proCtrl;
  late final TextEditingController _carbCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _servingCtrl;
  bool _saving = false;

  bool get _isEditing => widget.food != null;

  @override
  void initState() {
    super.initState();
    final f = widget.food;
    _nameCtrl = TextEditingController(text: f?.name ?? '');
    _calCtrl = TextEditingController(
        text: f != null ? f.calories.toStringAsFixed(0) : '');
    _proCtrl = TextEditingController(
        text: f != null ? f.protein.toStringAsFixed(1) : '');
    _carbCtrl = TextEditingController(
        text: f != null ? f.carbs.toStringAsFixed(1) : '');
    _fatCtrl = TextEditingController(
        text: f != null ? f.fat.toStringAsFixed(1) : '');
    _servingCtrl = TextEditingController(text: f?.servingLabel ?? '1 serving');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _servingCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await widget.onSave(
      name: name,
      calories: double.tryParse(_calCtrl.text) ?? 0,
      protein: double.tryParse(_proCtrl.text) ?? 0,
      carbs: double.tryParse(_carbCtrl.text) ?? 0,
      fat: double.tryParse(_fatCtrl.text) ?? 0,
      servingLabel: _servingCtrl.text.trim().isEmpty
          ? '1 serving'
          : _servingCtrl.text.trim(),
    );
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
      child: SingleChildScrollView(
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
              _isEditing ? 'Edit Food' : 'New Food',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg - 4),

            _Field(ctrl: _nameCtrl, label: 'Food name', autofocus: !_isEditing),
            _Field(ctrl: _servingCtrl, label: 'Serving size', hint: 'e.g. 1 slice (28 g)'),
            const SizedBox(height: AppSpacing.sm),

            Text('Macros per serving', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                    child: _Field(
                        ctrl: _calCtrl, label: 'Calories', unit: 'kcal', numeric: true)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: _Field(
                        ctrl: _proCtrl, label: 'Protein', unit: 'g', numeric: true)),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: _Field(
                        ctrl: _carbCtrl, label: 'Carbs', unit: 'g', numeric: true)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                    child: _Field(
                        ctrl: _fatCtrl, label: 'Fat', unit: 'g', numeric: true)),
              ],
            ),

            const SizedBox(height: AppSpacing.lg - 4),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Add to Pantry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String? unit;
  final String? hint;
  final bool numeric;
  final bool autofocus;

  const _Field({
    required this.ctrl,
    required this.label,
    this.unit,
    this.hint,
    this.numeric = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        style: AppTextStyles.bodyLarge,
        autofocus: autofocus,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: unit != null ? '$label ($unit)' : label,
          hintText: hint,
        ),
      ),
    );
  }
}

