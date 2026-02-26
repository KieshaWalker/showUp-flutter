import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: const Text('Pantry'),
        titleTextStyle: AppTextStyles.displayLarge,
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_outlined),
            tooltip: 'Create meal',
            onPressed: () {
              final foods = foodsAsync.value;
              if (foods != null && foods.isNotEmpty) {
                _showCreateMealSheet(context, foods);
              }
            },
          ),
        ],
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
        error: (e, _) => Center(child: Text('Error: $e')),
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

  void _showCreateMealSheet(BuildContext context, List<PantryFood> foods) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _CreateMealSheet(
        foods: foods,
        onCreate: (mealName, selections) async {
          await ref.read(pantryNotifierProvider.notifier).createMealFromPantry(
                mealName: mealName,
                selections: selections,
              );
          if (ctx.mounted) Navigator.pop(ctx);
        },
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

// ---------------------------------------------------------------------------
// Create meal sheet
// ---------------------------------------------------------------------------

class _CreateMealSheet extends StatefulWidget {
  final List<PantryFood> foods;
  final Future<void> Function(
      String mealName, List<({PantryFood food, double servings})> selections) onCreate;

  const _CreateMealSheet({required this.foods, required this.onCreate});

  @override
  State<_CreateMealSheet> createState() => _CreateMealSheetState();
}

class _CreateMealSheetState extends State<_CreateMealSheet> {
  final _mealNameCtrl = TextEditingController(text: 'Meal');
  // food id → servings count
  final Map<String, double> _servings = {};
  bool _creating = false;
  String _query = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _mealNameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<PantryFood> get _filtered {
    if (_query.isEmpty) return widget.foods;
    return widget.foods
        .where((f) => f.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  List<({PantryFood food, double servings})> get _selections => _servings.entries
      .where((e) => e.value > 0)
      .map((e) => (
            food: widget.foods.firstWhere((f) => f.id == e.key),
            servings: e.value,
          ))
      .toList();

  double get _totalCal => _selections.fold(
      0, (s, e) => s + e.food.calories * e.servings);

  Future<void> _create() async {
    final name = _mealNameCtrl.text.trim();
    if (name.isEmpty || _selections.isEmpty) return;
    setState(() => _creating = true);
    await widget.onCreate(name, _selections);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text('Create Meal',
                      style: AppTextStyles.headlineMedium),
                ),
                if (_selections.isNotEmpty)
                  Text(
                    '${_totalCal.toInt()} kcal',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.terracotta),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Meal name input
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              controller: _mealNameCtrl,
              style: AppTextStyles.bodyLarge,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Meal name',
                prefixIcon: Icon(Icons.restaurant_outlined,
                    color: AppColors.terracotta),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Search
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              controller: _searchCtrl,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Search pantry…',
                prefixIcon: Icon(Icons.search,
                    color: AppColors.textOnDarkTertiary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Selection count chip
          if (_selections.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.15),
                      borderRadius: AppRadius.xlAll,
                      border: Border.all(
                          color:
                              AppColors.terracotta.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${_selections.length} food${_selections.length == 1 ? '' : 's'} selected',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.terracotta),
                    ),
                  ),
                ],
              ),
            ),

          // Food list
          Expanded(
            child: ListView.separated(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, 100),
              itemCount: _filtered.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (ctx, i) {
                final food = _filtered[i];
                final servings = _servings[food.id] ?? 0.0;
                final isSelected = servings > 0;

                return AppGlass.card(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 12),
                  borderRadius: AppRadius.lgAll,
                  bg: isSelected
                      ? AppColors.terracotta.withValues(alpha: 0.12)
                      : AppColors.glassBg,
                  child: Row(
                    children: [
                      // Food info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(food.name,
                                style: AppTextStyles.titleMedium),
                            Text(
                              '${food.calories.toInt()} kcal · ${food.servingLabel}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      // Serving counter
                      _ServingCounter(
                        value: servings,
                        onChanged: (v) =>
                            setState(() => _servings[food.id] = v),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Create button
          Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm,
                AppSpacing.lg,
                MediaQuery.of(context).padding.bottom + AppSpacing.lg),
            child: FilledButton(
              onPressed: _creating || _selections.isEmpty ? null : _create,
              child: _creating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_selections.isEmpty
                      ? 'Select foods to continue'
                      : 'Add to Today\'s Nutrition'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Serving counter (+/-)
// ---------------------------------------------------------------------------

class _ServingCounter extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _ServingCounter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Btn(
          icon: Icons.remove,
          enabled: value > 0,
          onTap: () => onChanged((value - 0.5).clamp(0, 99)),
        ),
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              value == 0
                  ? '0'
                  : value == value.truncateToDouble()
                      ? value.toInt().toString()
                      : value.toStringAsFixed(1),
              style: AppTextStyles.titleMedium,
            ),
          ),
        ),
        _Btn(
          icon: Icons.add,
          enabled: value < 99,
          onTap: () => onChanged((value + 0.5).clamp(0, 99)),
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _Btn({required this.icon, required this.enabled, required this.onTap});

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
