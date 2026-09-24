// pantry_screen.dart — The Pantry tab: browse and manage the food library.
//
// Shows:
//   • A searchable 2-column grid of all pantry foods (global presets +
//     personal foods) — same card language as the Overview tab's Quick Add
//     chips (icon badge, name, calories), just full-width-per-column
//   • Each card shows the food name, serving size, and calorie count
//   • FAB to add a personal food (opens a form bottom sheet)
//   • Second FAB to scan a barcode (Open Food Facts lookup) prefills the
//     same form — see barcode_scanner_screen.dart and
//     open_food_facts_service.dart
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
//   app_tour.dart           — stage two of the app tour switches here and
//                             points out the Scan Barcode FAB
//   app_theme.dart          — AppGlass, AppColors, AppTextStyles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../shared/widgets.dart';
import '../../database/db.dart';
import '../onboarding/app_tour.dart';
import '../onboarding/app_tour_keys.dart';
import '../recipes/recipe_editor_screen.dart';
import '../settings/settings_screen.dart';
import 'barcode_scanner_screen.dart';
import 'open_food_facts_service.dart';
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
        title: const AppLogoTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => openSettingsScreen(context),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          appTourTarget(
            key: pantryScanFabKey,
            title: 'Scan a Barcode',
            description:
                'Point your camera at a package barcode to pull its '
                'nutrition info in automatically.',
            tooltipActions: finalTourStepTooltipActions,
            child: FloatingActionButton(
              heroTag: 'pantry-scan-fab',
              tooltip: 'Scan Barcode',
              onPressed: () => _scanBarcode(context),
              child: const Icon(Icons.qr_code_scanner),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          FloatingActionButton.extended(
            heroTag: 'pantry-add-fab',
            onPressed: () => _showFoodForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Food'),
          ),
          const SizedBox(height: AppSpacing.sm),
          FloatingActionButton.extended(
            heroTag: 'pantry-add-recipe-fab',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecipeEditorScreen()),
                ),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('Add Recipe'),
          ),
        ],
      ),
      body: foodsAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.terracotta),
            ),
        error:
            (e, _) => const Center(
              child: Text("Couldn't load your pantry. Pull down to try again."),
            ),
        data: (foods) {
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
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search foods…',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textOnDarkTertiary,
                    ),
                    suffixIcon:
                        _query.isNotEmpty
                            ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textOnDarkTertiary,
                              ),
                              tooltip: 'Clear search',
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
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
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
                child:
                    filtered.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.kitchen_outlined,
                                size: 56,
                                color: AppColors.textOnDarkTertiary,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _query.isEmpty
                                    ? 'No foods yet'
                                    : 'No results for "$_query"',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.textOnDarkSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                        : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.sm,
                            AppSpacing.md,
                            120,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                mainAxisExtent: 158,
                              ),
                          itemCount: filtered.length,
                          itemBuilder:
                              (ctx, i) => _FoodCard(
                                food: filtered[i],
                                onEdit:
                                    () => _showFoodForm(
                                      context,
                                      food: filtered[i],
                                    ),
                                onDelete:
                                    () => _confirmDelete(context, filtered[i]),
                              ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Pushes the full-screen scanner, looks up the resulting barcode against
  /// Open Food Facts, and opens the add-food form prefilled with whatever it
  /// found (or empty, with a heads-up, if the barcode isn't in the database).
  Future<void> _scanBarcode(BuildContext context) async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (barcode == null || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(color: AppColors.terracotta),
          ),
    );
    final info = await lookupBarcode(barcode);
    if (!context.mounted) return;
    Navigator.pop(context); // close the loading dialog

    if (info == null) {
      _showFoodForm(context, notFoundBarcode: barcode);
      return;
    }
    _showFoodForm(context, prefill: info);
  }

  void _showFoodForm(
    BuildContext context, {
    PantryFood? food,
    ScannedFoodInfo? prefill,
    String? notFoundBarcode,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (ctx) => _FoodFormSheet(
            food: food,
            prefill: prefill,
            notFoundBarcode: notFoundBarcode,
            onSave: ({
              required String name,
              required double calories,
              required double protein,
              required double carbs,
              required double fat,
              required String servingLabel,
              required double sugar,
              required double fiber,
              required double sodium,
              required double cholesterol,
              required double potassium,
              required double calcium,
              required double iron,
              required double vitaminA,
              required double vitaminC,
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
                  sugar: sugar,
                  fiber: fiber,
                  sodium: sodium,
                  cholesterol: cholesterol,
                  potassium: potassium,
                  calcium: calcium,
                  iron: iron,
                  vitaminA: vitaminA,
                  vitaminC: vitaminC,
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
                  sugar: sugar,
                  fiber: fiber,
                  sodium: sodium,
                  cholesterol: cholesterol,
                  potassium: potassium,
                  calcium: calcium,
                  iron: iron,
                  vitaminA: vitaminA,
                  vitaminC: vitaminC,
                );
              }
            },
          ),
    );
  }

  void _confirmDelete(BuildContext context, PantryFood food) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              'Delete "${food.name}"?',
              style: AppTextStyles.titleMedium,
            ),
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
    // Global presets are read-only — no edit/delete affordance for them.
    final editable = !food.isPreset;
    return Semantics(
      button: editable,
      label:
          editable
              ? '${food.name}, ${food.servingLabel}. Double tap to edit, double tap and hold to delete.'
              : '${food.name}, ${food.servingLabel}. Preset, read-only.',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: editable ? onEdit : null,
          onLongPress: editable ? onDelete : null,
          borderRadius: AppRadius.lgAll,
          child: AppGlass.card(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            borderRadius: AppRadius.lgAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon badge + edit/lock indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.terracotta.withValues(alpha: 0.15),
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: const Icon(
                        Icons.set_meal_outlined,
                        size: 14,
                        color: AppColors.terracotta,
                      ),
                    ),
                    Icon(
                      editable ? Icons.chevron_right : Icons.lock_outline,
                      size: 14,
                      color: AppColors.textOnDarkTertiary,
                    ),
                  ],
                ),

                // Name + serving
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: AppTextStyles.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      food.servingLabel,
                      style: AppTextStyles.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // Calories
                Text(
                  '${food.calories.toInt()} kcal',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.terracotta,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Food form sheet (add + edit)
// ---------------------------------------------------------------------------

typedef _SaveCallback =
    Future<void> Function({
      required String name,
      required double calories,
      required double protein,
      required double carbs,
      required double fat,
      required String servingLabel,
      required double sugar,
      required double fiber,
      required double sodium,
      required double cholesterol,
      required double potassium,
      required double calcium,
      required double iron,
      required double vitaminA,
      required double vitaminC,
    });

class _FoodFormSheet extends StatefulWidget {
  final PantryFood? food;
  final ScannedFoodInfo? prefill;
  final String? notFoundBarcode;
  final _SaveCallback onSave;

  const _FoodFormSheet({
    required this.food,
    this.prefill,
    this.notFoundBarcode,
    required this.onSave,
  });

  @override
  State<_FoodFormSheet> createState() => _FoodFormSheetState();
}

class _FoodFormSheetState extends State<_FoodFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _calCtrl;
  late final TextEditingController _proCtrl;
  late final TextEditingController _carbCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _sugarCtrl;
  late final TextEditingController _servingCtrl;
  late final TextEditingController _fiberCtrl;
  late final TextEditingController _sodiumCtrl;
  late final TextEditingController _cholesterolCtrl;
  late final TextEditingController _potassiumCtrl;
  late final TextEditingController _calciumCtrl;
  late final TextEditingController _ironCtrl;
  late final TextEditingController _vitaminACtrl;
  late final TextEditingController _vitaminCCtrl;
  bool _saving = false;

  bool get _isEditing => widget.food != null;

  @override
  void initState() {
    super.initState();
    final f = widget.food;
    // A scanned-barcode prefill only applies to a brand-new food (widget.food
    // is null) — editing an existing food always shows its own saved values.
    final p = f == null ? widget.prefill : null;

    String num0(double? v) => v == null ? '' : v.toStringAsFixed(0);
    String num1(double? v) => v == null ? '' : v.toStringAsFixed(1);

    _nameCtrl = TextEditingController(text: f?.name ?? p?.name ?? '');
    _calCtrl = TextEditingController(text: num0(f?.calories ?? p?.calories));
    _proCtrl = TextEditingController(text: num1(f?.protein ?? p?.protein));
    _carbCtrl = TextEditingController(text: num1(f?.carbs ?? p?.carbs));
    _fatCtrl = TextEditingController(text: num1(f?.fat ?? p?.fat));
    _sugarCtrl = TextEditingController(text: num1(f?.sugar ?? p?.sugar));
    _servingCtrl = TextEditingController(
      text: f?.servingLabel ?? p?.servingLabel ?? '1 serving',
    );
    _fiberCtrl = TextEditingController(text: num1(f?.fiber ?? p?.fiber));
    _sodiumCtrl = TextEditingController(text: num0(f?.sodium ?? p?.sodium));
    _cholesterolCtrl = TextEditingController(
      text: num0(f?.cholesterol ?? p?.cholesterol),
    );
    _potassiumCtrl = TextEditingController(
      text: num0(f?.potassium ?? p?.potassium),
    );
    _calciumCtrl = TextEditingController(text: num0(f?.calcium ?? p?.calcium));
    _ironCtrl = TextEditingController(text: num1(f?.iron ?? p?.iron));
    _vitaminACtrl = TextEditingController(
      text: num0(f?.vitaminA ?? p?.vitaminA),
    );
    _vitaminCCtrl = TextEditingController(
      text: num0(f?.vitaminC ?? p?.vitaminC),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _proCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    _sugarCtrl.dispose();
    _servingCtrl.dispose();
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
      sugar: double.tryParse(_sugarCtrl.text) ?? 0,
      fiber: double.tryParse(_fiberCtrl.text) ?? 0,
      sodium: double.tryParse(_sodiumCtrl.text) ?? 0,
      cholesterol: double.tryParse(_cholesterolCtrl.text) ?? 0,
      potassium: double.tryParse(_potassiumCtrl.text) ?? 0,
      calcium: double.tryParse(_calciumCtrl.text) ?? 0,
      iron: double.tryParse(_ironCtrl.text) ?? 0,
      vitaminA: double.tryParse(_vitaminACtrl.text) ?? 0,
      vitaminC: double.tryParse(_vitaminCCtrl.text) ?? 0,
      servingLabel:
          _servingCtrl.text.trim().isEmpty
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

            if (widget.notFoundBarcode != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.overLimit.withValues(alpha: 0.15),
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: AppColors.overLimit.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 18,
                      color: AppColors.overLimit,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'No match for barcode ${widget.notFoundBarcode} — enter the details manually below.',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.overLimit,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg - 4),

            _Field(ctrl: _nameCtrl, label: 'Food name', autofocus: !_isEditing),
            _Field(
              ctrl: _servingCtrl,
              label: 'Serving size',
              hint: 'e.g. 1 slice (28 g)',
            ),
            const SizedBox(height: AppSpacing.sm),

            Text('Macros per serving', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _Field(
                    ctrl: _calCtrl,
                    label: 'Calories',
                    unit: 'kcal',
                    numeric: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Field(
                    ctrl: _proCtrl,
                    label: 'Protein',
                    unit: 'g',
                    numeric: true,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    ctrl: _carbCtrl,
                    label: 'Carbs',
                    unit: 'g',
                    numeric: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Field(
                    ctrl: _fatCtrl,
                    label: 'Fat',
                    unit: 'g',
                    numeric: true,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    ctrl: _sugarCtrl,
                    label: 'Sugar',
                    unit: 'g',
                    numeric: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Field(
                    ctrl: _fiberCtrl,
                    label: 'Fiber',
                    unit: 'g',
                    numeric: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Micronutrients (optional)',
                  style: AppTextStyles.labelSmall,
                ),
                childrenPadding: const EdgeInsets.only(top: AppSpacing.sm),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          ctrl: _sodiumCtrl,
                          label: 'Sodium',
                          unit: 'mg',
                          numeric: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _Field(
                          ctrl: _cholesterolCtrl,
                          label: 'Cholesterol',
                          unit: 'mg',
                          numeric: true,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          ctrl: _potassiumCtrl,
                          label: 'Potassium',
                          unit: 'mg',
                          numeric: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _Field(
                          ctrl: _calciumCtrl,
                          label: 'Calcium',
                          unit: 'mg',
                          numeric: true,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          ctrl: _ironCtrl,
                          label: 'Iron',
                          unit: 'mg',
                          numeric: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _Field(
                          ctrl: _vitaminACtrl,
                          label: 'Vitamin A',
                          unit: 'mcg',
                          numeric: true,
                        ),
                      ),
                    ],
                  ),
                  _Field(
                    ctrl: _vitaminCCtrl,
                    label: 'Vitamin C',
                    unit: 'mg',
                    numeric: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg - 4),

            FilledButton(
              onPressed: _saving ? null : _save,
              child:
                  _saving
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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
        keyboardType:
            numeric
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
