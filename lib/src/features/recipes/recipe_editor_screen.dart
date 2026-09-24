// recipe_editor_screen.dart — Create/edit a recipe: name, photo, optional
// servings yield + prep/cook time, and an ordered list of cooking steps
// (each with an action verb, optional instructions, and its own ingredient
// list). Full screen (not a sheet) via Navigator.push — this form has too
// much content for a bottom sheet, following the same AppBackground +
// transparent Scaffold + AppBar pattern as admin_screen.dart/settings' sub-
// screens.
//
// Everything here (yield/prep/cook/steps/ingredients) is optional and
// editable at any point while the form is open — there's no wizard gating.
// Steps are reorderable at any time via ReorderableListView, which is the
// answer to "how does a non-organized user fix step order" — not a smart
// suggestion engine (explicitly out of scope, see recipes_notifier.dart).
//
// Photo uploads immediately on pick (mirrors ProfileNotifier.uploadAvatar's
// UX in profile_screen.dart) rather than being deferred to Save, since the
// upload path needs a stable recipe id — generated here up front, before
// the recipe row itself exists locally or remotely.
//
// Connections:
//   recipes_notifier.dart        — RecipesNotifier.saveRecipe/updateRecipe/
//                                   uploadRecipePhoto
//   ingredient_picker_sheet.dart — showIngredientPickerSheet()
//   pantry_notifier.dart         — pantryNotifierProvider, to resolve an
//                                   existing recipe's ingredient PantryFoods

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../database/db.dart';
import '../pantry/pantry_notifier.dart';
import 'ingredient_picker_sheet.dart';
import 'recipe_constants.dart';
import 'recipes_notifier.dart';

// ---------------------------------------------------------------------------
// In-memory editable models — not persisted directly; converted to
// RecipeStepInput/RecipeIngredientInput on Save.
// ---------------------------------------------------------------------------

class _EditableIngredient {
  final PantryFood food;
  double servings;
  String? amountLabel;

  _EditableIngredient({
    required this.food,
    this.servings = 1.0,
    this.amountLabel,
  });
}

class _EditableStep {
  final Key key = UniqueKey();
  String actionVerb;
  final TextEditingController instructionsCtrl;
  final List<_EditableIngredient> ingredients = [];

  _EditableStep({required this.actionVerb, String? instructions})
    : instructionsCtrl = TextEditingController(text: instructions);
}

String _trimNum(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class RecipeEditorScreen extends ConsumerStatefulWidget {
  final RecipeWithSteps? existing;

  const RecipeEditorScreen({super.key, this.existing});

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  late final String _recipeId;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _servingsYieldCtrl;
  late final TextEditingController _prepCtrl;
  late final TextEditingController _cookCtrl;
  final List<_EditableStep> _steps = [];
  String? _photoUrl;
  bool _uploadingPhoto = false;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _recipeId = existing?.recipe.id ?? const Uuid().v4();
    _nameCtrl = TextEditingController(text: existing?.recipe.name ?? '');
    _servingsYieldCtrl = TextEditingController(
      text:
          existing?.recipe.servingsYield == null
              ? ''
              : _trimNum(existing!.recipe.servingsYield!),
    );
    _prepCtrl = TextEditingController(
      text: existing?.recipe.prepTimeMinutes?.toString() ?? '',
    );
    _cookCtrl = TextEditingController(
      text: existing?.recipe.cookTimeMinutes?.toString() ?? '',
    );
    _photoUrl = existing?.recipe.photoUrl;

    if (existing != null) {
      final pantryFoods = ref.read(pantryNotifierProvider).value ?? [];
      for (final s in existing.steps) {
        final step = _EditableStep(
          actionVerb: s.step.actionVerb,
          instructions: s.step.instructions,
        );
        for (final i in s.ingredients) {
          final food = pantryFoods.firstWhereOrNull(
            (f) => f.id == i.pantryFoodId,
          );
          if (food == null) continue; // deleted since the recipe was saved
          step.ingredients.add(
            _EditableIngredient(
              food: food,
              servings: i.servings,
              amountLabel: i.amountLabel,
            ),
          );
        }
        _steps.add(step);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _servingsYieldCtrl.dispose();
    _prepCtrl.dispose();
    _cookCtrl.dispose();
    for (final s in _steps) {
      s.instructionsCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Photo Library'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
    );
    if (choice == null) return;

    final file = await ImagePicker().pickImage(
      source: choice,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final url = await ref
          .read(recipesNotifierProvider.notifier)
          .uploadRecipePhoto(recipeId: _recipeId, file: file);
      if (mounted) setState(() => _photoUrl = url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't upload photo. Check your connection and try again.",
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<String?> _pickActionVerb({String? current}) {
    return showModalBottomSheet<String>(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final verb in kStepActionVerbs)
                  ListTile(
                    title: Text(verb),
                    trailing:
                        verb == current
                            ? const Icon(
                              Icons.check,
                              color: AppColors.terracotta,
                            )
                            : null,
                    onTap: () => Navigator.pop(ctx, verb),
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _addStep() async {
    final verb = await _pickActionVerb();
    if (verb == null) return;
    setState(() => _steps.add(_EditableStep(actionVerb: verb)));
  }

  void _onReorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final step = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, step);
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);

    final stepInputs = [
      for (final s in _steps)
        RecipeStepInput(
          actionVerb: s.actionVerb,
          instructions:
              s.instructionsCtrl.text.trim().isEmpty
                  ? null
                  : s.instructionsCtrl.text.trim(),
          ingredients: [
            for (final i in s.ingredients)
              RecipeIngredientInput(
                pantryFoodId: i.food.id,
                servings: i.servings,
                amountLabel: i.amountLabel,
              ),
          ],
        ),
    ];

    final notifier = ref.read(recipesNotifierProvider.notifier);
    final servingsYield = double.tryParse(_servingsYieldCtrl.text);
    final prepTimeMinutes = int.tryParse(_prepCtrl.text);
    final cookTimeMinutes = int.tryParse(_cookCtrl.text);

    if (_isEditing) {
      await notifier.updateRecipe(
        recipeId: _recipeId,
        name: name,
        servingsYield: servingsYield,
        prepTimeMinutes: prepTimeMinutes,
        cookTimeMinutes: cookTimeMinutes,
        photoUrl: _photoUrl,
        steps: stepInputs,
      );
    } else {
      await notifier.saveRecipe(
        id: _recipeId,
        name: name,
        servingsYield: servingsYield,
        prepTimeMinutes: prepTimeMinutes,
        cookTimeMinutes: cookTimeMinutes,
        photoUrl: _photoUrl,
        steps: stepInputs,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _uploadingPhoto ? null : _pickPhoto,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.glassBg,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.glassBorder),
          image:
              _photoUrl != null
                  ? DecorationImage(
                    image: NetworkImage(_photoUrl!),
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child:
            _uploadingPhoto
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.terracotta),
                )
                : _photoUrl == null
                ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.textOnDarkTertiary,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text('Add a photo (optional)'),
                    ],
                  ),
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Recipe' : 'New Recipe'),
          actions: [
            IconButton(
              icon:
                  _saving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.check),
              tooltip: 'Save',
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: AppPaddings.all,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhotoPicker(),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _nameCtrl,
                autofocus: !_isEditing,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Recipe name'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _servingsYieldCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Servings'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _prepCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prep (min)',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _cookCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cook (min)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Steps', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              if (_steps.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    'No steps yet — add one below.',
                    style: AppTextStyles.bodyMedium,
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _steps.length,
                  onReorder: _onReorderSteps,
                  itemBuilder: (ctx, i) {
                    final index = i;
                    return _StepCard(
                      key: _steps[index].key,
                      index: index,
                      step: _steps[index],
                      onRemove: () => setState(() => _steps.removeAt(index)),
                      onChangeVerb: () async {
                        final verb = await _pickActionVerb(
                          current: _steps[index].actionVerb,
                        );
                        if (verb != null) {
                          setState(() => _steps[index].actionVerb = verb);
                        }
                      },
                      onAddIngredient: () async {
                        final picked = await showIngredientPickerSheet(context);
                        if (picked != null) {
                          setState(
                            () => _steps[index].ingredients.add(
                              _EditableIngredient(
                                food: picked.food,
                                servings: picked.servings,
                                amountLabel: picked.amountLabel,
                              ),
                            ),
                          );
                        }
                      },
                      onRemoveIngredient:
                          (ingIndex) => setState(
                            () => _steps[index].ingredients.removeAt(ingIndex),
                          ),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add step'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step card — drag handle, action-verb badge, instructions, ingredient list.
// ---------------------------------------------------------------------------

class _StepCard extends StatelessWidget {
  const _StepCard({
    required super.key,
    required this.index,
    required this.step,
    required this.onRemove,
    required this.onChangeVerb,
    required this.onAddIngredient,
    required this.onRemoveIngredient,
  });

  final int index;
  final _EditableStep step;
  final VoidCallback onRemove;
  final VoidCallback onChangeVerb;
  final VoidCallback onAddIngredient;
  final void Function(int) onRemoveIngredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppGlass.card(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.lgAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: Icon(
                      Icons.drag_handle,
                      color: AppColors.textOnDarkTertiary,
                    ),
                  ),
                ),
                Text('Step ${index + 1}', style: AppTextStyles.labelSmall),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: onChangeVerb,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.15),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      step.actionVerb,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.terracotta,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onRemove,
                  tooltip: 'Remove step',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: step.instructionsCtrl,
              decoration: const InputDecoration(
                hintText: 'Instructions (optional)',
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
            if (step.ingredients.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < step.ingredients.length; i++)
                _IngredientRow(
                  ingredient: step.ingredients[i],
                  onRemove: () => onRemoveIngredient(i),
                ),
            ],
            TextButton.icon(
              onPressed: onAddIngredient,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add ingredient'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient, required this.onRemove});

  final _EditableIngredient ingredient;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final servingsLabel = _trimNum(ingredient.servings);
    final amountLabel = ingredient.amountLabel;
    final subtitle = [
      if (amountLabel != null && amountLabel.isNotEmpty) amountLabel,
      '$servingsLabel× ${ingredient.food.servingLabel}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ingredient.food.name,
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextSpan(
                    text: '  $subtitle',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textOnDarkTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onRemove,
            tooltip: 'Remove ingredient',
          ),
        ],
      ),
    );
  }
}
