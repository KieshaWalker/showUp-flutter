// recipes_notifier.dart — Recipes: named dishes with an ordered list of
// cooking steps, each carrying its own ingredient list. Separate from meal
// templates (pantry_notifier.dart's MealTemplatesNotifier) — a template is a
// snapshot of a meal you already logged; a recipe is authored up front with
// steps/instructions/photo and can be re-logged as "1 serving" any time.
//
// Nutrition model: a recipe's macros are kept as a DERIVED PERSONAL
// PantryFood (see Recipe.pantryFoodId), recomputed by
// _recomputeDerivedPantryFood() as (sum of ingredient macros × their
// servings) ÷ servingsYield, whenever the recipe is saved or updated.
// Logging "1 serving" (logRecipeServing) is then just a normal addFoodEntry
// call against that derived food at servings=1.0 — reuses all of the
// existing FoodEntry/Quick Add machinery instead of a parallel logging path.
// A recipe with no ingredients yet has pantryFoodId == null and is not
// loggable (a draft — steps/instructions can still be authored and saved).
//
// No unit-conversion system: RecipeStepIngredient.servings is a multiplier
// against the linked PantryFood's own per-serving macros, exactly like
// FoodEntries.servings/MealTemplateItems.servings elsewhere in this app.
// amountLabel (e.g. "1/4 cup") is purely descriptive, never used in macro
// math — see db.dart's RecipeStepIngredients doc comment.
//
// Sync: local-first, fire-and-forget Supabase sync wrapped in try/catch,
// same shape as MealTemplatesNotifier. The derived PantryFood row is pushed
// to Supabase BEFORE the recipe row on every sync, since recipes.pantry_food_id
// has a Postgres FK to pantry_foods — it must exist remotely first. Pulling
// the derived PantryFood back down on another device rides the existing
// PantryNotifier.syncFromRemote() (it pulls all of the user's personal
// pantry foods already, recipe-derived or not) — no extra pull code needed.
//
// Connections:
//   database_provider.dart  — ref.watch(databaseProvider) for SQLite access
//   pantry_notifier.dart    — PantryFood model/table, PantryNotifier.addFood
//                             (used by the ingredient picker's "add new
//                             ingredient" quick-create)
//   nutrition_notifier.dart — addFoodEntry/addMeal, used by logRecipeServing
//   nutrition_screen.dart   — resolveMealNameForTime()
//   recipe_editor_screen.dart, ingredient_picker_sheet.dart — UI callers

import 'package:collection/collection.dart';
import 'package:async/async.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../database/database_provider.dart';
import '../../database/db.dart';
import '../nutrition/nutrition_notifier.dart';
import '../nutrition/nutrition_screen.dart' show resolveMealNameForTime;

const _uuid = Uuid();

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class RecipeWithSteps {
  final Recipe recipe;
  final List<RecipeStepWithIngredients> steps;

  const RecipeWithSteps({required this.recipe, required this.steps});
}

class RecipeStepWithIngredients {
  final RecipeStep step;
  final List<RecipeStepIngredient> ingredients;

  const RecipeStepWithIngredients({
    required this.step,
    required this.ingredients,
  });
}

/// One step to save/update a recipe with — see [RecipesNotifier.saveRecipe]/
/// [RecipesNotifier.updateRecipe].
class RecipeStepInput {
  final String actionVerb;
  final String? instructions;
  final List<RecipeIngredientInput> ingredients;

  const RecipeStepInput({
    required this.actionVerb,
    this.instructions,
    required this.ingredients,
  });
}

class RecipeIngredientInput {
  final String pantryFoodId;
  final double servings;
  final String? amountLabel;

  const RecipeIngredientInput({
    required this.pantryFoodId,
    this.servings = 1.0,
    this.amountLabel,
  });
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

final recipesNotifierProvider =
    StreamNotifierProvider<RecipesNotifier, List<RecipeWithSteps>>(
      RecipesNotifier.new,
    );

class RecipesNotifier extends StreamNotifier<List<RecipeWithSteps>> {
  @override
  Stream<List<RecipeWithSteps>> build() {
    final db = ref.watch(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    // Same count-only-watch-as-trigger pattern as MealTemplatesNotifier.build().
    final recipesStream =
        (db.selectOnly(db.recipes)
              ..addColumns([db.recipes.id.count()])
              ..where(db.recipes.userId.equals(userId)))
            .watchSingle();
    final stepsStream =
        (db.selectOnly(db.recipeSteps)
              ..addColumns([db.recipeSteps.id.count()])
              ..where(db.recipeSteps.userId.equals(userId)))
            .watchSingle();
    final ingredientsStream =
        (db.selectOnly(db.recipeStepIngredients)
              ..addColumns([db.recipeStepIngredients.id.count()])
              ..where(db.recipeStepIngredients.userId.equals(userId)))
            .watchSingle();

    final trigger = StreamGroup.merge<List<dynamic>>([
      recipesStream.map((_) => []),
      stepsStream.map((_) => []),
      ingredientsStream.map((_) => []),
    ]).map((_) => null);

    return trigger.asyncMap((_) => _loadAll(db, userId));
  }

  Future<List<RecipeWithSteps>> _loadAll(AppDatabase db, String userId) async {
    final recipes =
        await (db.select(db.recipes)
              ..where((r) => r.userId.equals(userId))
              ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
            .get();
    final steps =
        await (db.select(db.recipeSteps)
              ..where((s) => s.userId.equals(userId))
              ..orderBy([(s) => OrderingTerm.asc(s.stepOrder)]))
            .get();
    final ingredients =
        await (db.select(db.recipeStepIngredients)
              ..where((i) => i.userId.equals(userId))
              ..orderBy([(i) => OrderingTerm.asc(i.sortOrder)]))
            .get();

    return [
      for (final r in recipes)
        RecipeWithSteps(
          recipe: r,
          steps: [
            for (final s in steps.where((s) => s.recipeId == r.id))
              RecipeStepWithIngredients(
                step: s,
                ingredients:
                    ingredients.where((i) => i.stepId == s.id).toList(),
              ),
          ],
        ),
    ];
  }

  /// Creates a new recipe with its steps/ingredients, recomputes its derived
  /// PantryFood, and returns the new recipe's id. Pass [id] when the caller
  /// already generated one (the editor screen needs a stable id up front so
  /// a photo can be uploaded to `$userId/$id.$ext` before the recipe row
  /// exists) — otherwise one is generated here.
  Future<String> saveRecipe({
    String? id,
    required String name,
    double? servingsYield,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String? photoUrl,
    required List<RecipeStepInput> steps,
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    final recipeId = id ?? _uuid.v4();

    await db.transaction(() async {
      await db
          .into(db.recipes)
          .insert(
            RecipesCompanion.insert(
              id: recipeId,
              userId: userId,
              name: name,
              servingsYield: Value(servingsYield),
              prepTimeMinutes: Value(prepTimeMinutes),
              cookTimeMinutes: Value(cookTimeMinutes),
              photoUrl: Value(photoUrl),
            ),
          );
      await _writeSteps(db, userId, recipeId, steps);
      await _recomputeDerivedPantryFood(db, userId, recipeId);
    });

    await _syncRecipeToRemote(recipeId);
    return recipeId;
  }

  /// Renames/updates a recipe and replaces its steps/ingredients wholesale
  /// (same delete-and-reinsert trade-off MealTemplatesNotifier.updateTemplate
  /// already makes — simplest correct approach for a small nested list).
  Future<void> updateRecipe({
    required String recipeId,
    required String name,
    double? servingsYield,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String? photoUrl,
    required List<RecipeStepInput> steps,
  }) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await db.transaction(() async {
      await (db.update(db.recipes)..where((r) => r.id.equals(recipeId))).write(
        RecipesCompanion(
          name: Value(name),
          servingsYield: Value(servingsYield),
          prepTimeMinutes: Value(prepTimeMinutes),
          cookTimeMinutes: Value(cookTimeMinutes),
          photoUrl: Value(photoUrl),
          synced: const Value(false),
        ),
      );
      await (db.delete(db.recipeStepIngredients)
        ..where((i) => i.recipeId.equals(recipeId))).go();
      await (db.delete(db.recipeSteps)
        ..where((s) => s.recipeId.equals(recipeId))).go();
      await _writeSteps(db, userId, recipeId, steps);
      await _recomputeDerivedPantryFood(db, userId, recipeId);
    });

    await _syncRecipeToRemote(recipeId);
  }

  Future<void> _writeSteps(
    AppDatabase db,
    String userId,
    String recipeId,
    List<RecipeStepInput> steps,
  ) async {
    final stepRows = <RecipeStepsCompanion>[];
    final ingredientRows = <RecipeStepIngredientsCompanion>[];

    for (var stepIndex = 0; stepIndex < steps.length; stepIndex++) {
      final step = steps[stepIndex];
      final stepId = _uuid.v4();
      stepRows.add(
        RecipeStepsCompanion.insert(
          id: stepId,
          recipeId: recipeId,
          userId: userId,
          stepOrder: stepIndex,
          actionVerb: step.actionVerb,
          instructions: Value(step.instructions),
        ),
      );
      for (var ingIndex = 0; ingIndex < step.ingredients.length; ingIndex++) {
        final ing = step.ingredients[ingIndex];
        ingredientRows.add(
          RecipeStepIngredientsCompanion.insert(
            id: _uuid.v4(),
            stepId: stepId,
            recipeId: recipeId,
            userId: userId,
            pantryFoodId: ing.pantryFoodId,
            servings: Value(ing.servings),
            amountLabel: Value(ing.amountLabel),
            sortOrder: Value(ingIndex),
          ),
        );
      }
    }

    if (stepRows.isEmpty) return;
    await db.batch((b) {
      b.insertAll(db.recipeSteps, stepRows);
      if (ingredientRows.isNotEmpty) {
        b.insertAll(db.recipeStepIngredients, ingredientRows);
      }
    });
  }

  /// Recomputes the recipe's derived PantryFood from its current ingredients
  /// (sum of each ingredient's linked PantryFood macros × its servings,
  /// divided by servingsYield), and writes the result's id back onto
  /// Recipes.pantryFoodId. Does nothing (leaves pantryFoodId as-is, usually
  /// null) if the recipe has no ingredients yet — a draft with just
  /// name/steps/instructions and no ingredients stays un-loggable rather than
  /// getting a phantom all-zero-macro derived food.
  Future<void> _recomputeDerivedPantryFood(
    AppDatabase db,
    String userId,
    String recipeId,
  ) async {
    final recipe =
        await (db.select(db.recipes)
          ..where((r) => r.id.equals(recipeId))).getSingle();
    final ingredients =
        await (db.select(db.recipeStepIngredients)
          ..where((i) => i.recipeId.equals(recipeId))).get();
    if (ingredients.isEmpty) return;

    var calories = 0.0, protein = 0.0, carbs = 0.0, fat = 0.0, sugar = 0.0;
    var fiber = 0.0, sodium = 0.0, cholesterol = 0.0, potassium = 0.0;
    var calcium = 0.0, iron = 0.0, vitaminA = 0.0, vitaminC = 0.0;

    for (final ing in ingredients) {
      final food =
          await (db.select(db.pantryFoods)
            ..where((f) => f.id.equals(ing.pantryFoodId))).getSingleOrNull();
      if (food == null) continue; // ingredient's food was deleted — skip it
      calories += food.calories * ing.servings;
      protein += food.protein * ing.servings;
      carbs += food.carbs * ing.servings;
      fat += food.fat * ing.servings;
      sugar += food.sugar * ing.servings;
      fiber += food.fiber * ing.servings;
      sodium += food.sodium * ing.servings;
      cholesterol += food.cholesterol * ing.servings;
      potassium += food.potassium * ing.servings;
      calcium += food.calcium * ing.servings;
      iron += food.iron * ing.servings;
      vitaminA += food.vitaminA * ing.servings;
      vitaminC += food.vitaminC * ing.servings;
    }

    // Documented simplification: an unset yield is treated as "1 serving =
    // the whole batch" rather than blocking the recompute.
    final yieldServings = recipe.servingsYield ?? 1.0;
    final pantryFoodId = recipe.pantryFoodId ?? _uuid.v4();

    await db
        .into(db.pantryFoods)
        .insertOnConflictUpdate(
          PantryFoodsCompanion.insert(
            id: pantryFoodId,
            userId: Value(userId),
            name: recipe.name,
            calories: Value(calories / yieldServings),
            protein: Value(protein / yieldServings),
            carbs: Value(carbs / yieldServings),
            fat: Value(fat / yieldServings),
            sugar: Value(sugar / yieldServings),
            fiber: Value(fiber / yieldServings),
            sodium: Value(sodium / yieldServings),
            cholesterol: Value(cholesterol / yieldServings),
            potassium: Value(potassium / yieldServings),
            calcium: Value(calcium / yieldServings),
            iron: Value(iron / yieldServings),
            vitaminA: Value(vitaminA / yieldServings),
            vitaminC: Value(vitaminC / yieldServings),
            servingLabel: Value('1 serving of "${recipe.name}"'),
            isPreset: const Value(false),
          ),
        );

    if (recipe.pantryFoodId != pantryFoodId) {
      await (db.update(db.recipes)..where(
        (r) => r.id.equals(recipeId),
      )).write(RecipesCompanion(pantryFoodId: Value(pantryFoodId)));
    }
  }

  /// Re-logs 1 serving of a recipe against its derived PantryFood, into
  /// today's resolved meal (same resolveMealNameForTime() Quick Add uses).
  /// Returns false if the recipe isn't loggable yet (no ingredients →
  /// no derived PantryFood, or that food has since been deleted).
  Future<bool> logRecipeServing(String recipeId) async {
    final db = ref.read(databaseProvider);
    final recipe =
        await (db.select(db.recipes)
          ..where((r) => r.id.equals(recipeId))).getSingleOrNull();
    final pantryFoodId = recipe?.pantryFoodId;
    if (pantryFoodId == null) return false;

    final food =
        await (db.select(db.pantryFoods)
          ..where((f) => f.id.equals(pantryFoodId))).getSingleOrNull();
    if (food == null) return false;

    final nutritionNotifier = ref.read(nutritionNotifierProvider.notifier);
    final resolvedMealName = resolveMealNameForTime(DateTime.now());
    final nutrition = ref.read(nutritionNotifierProvider);
    final existing =
        nutrition.value?.meals
            .where((m) => m.meal.name == resolvedMealName)
            .firstOrNull;
    final mealId =
        existing != null
            ? existing.meal.id
            : await nutritionNotifier.addMeal(resolvedMealName);

    await nutritionNotifier.addFoodEntry(
      mealId: mealId,
      name: food.name,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
      sugar: food.sugar,
      fiber: food.fiber,
      sodium: food.sodium,
      cholesterol: food.cholesterol,
      potassium: food.potassium,
      calcium: food.calcium,
      iron: food.iron,
      vitaminA: food.vitaminA,
      vitaminC: food.vitaminC,
      pantryFoodId: food.id,
      servings: 1.0,
    );
    return true;
  }

  /// Deletes a recipe, its steps/ingredients, and its derived PantryFood.
  Future<void> deleteRecipe(String recipeId) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final recipe =
        await (db.select(db.recipes)..where(
          (r) => r.id.equals(recipeId) & r.userId.equals(userId),
        )).getSingleOrNull();
    if (recipe == null) return; // not owned by this user

    await db.transaction(() async {
      await (db.delete(db.recipeStepIngredients)
        ..where((i) => i.recipeId.equals(recipeId))).go();
      await (db.delete(db.recipeSteps)
        ..where((s) => s.recipeId.equals(recipeId))).go();
      await (db.delete(db.recipes)..where((r) => r.id.equals(recipeId))).go();
      final pantryFoodId = recipe.pantryFoodId;
      if (pantryFoodId != null) {
        await (db.delete(db.pantryFoods)..where(
          (f) => f.id.equals(pantryFoodId) & f.userId.equals(userId),
        )).go();
      }
    });

    try {
      await Supabase.instance.client
          .from('recipe_step_ingredients')
          .delete()
          .eq('recipe_id', recipeId);
      await Supabase.instance.client
          .from('recipe_steps')
          .delete()
          .eq('recipe_id', recipeId);
      await Supabase.instance.client
          .from('recipes')
          .delete()
          .eq('id', recipeId)
          .eq('user_id', userId);
      final pantryFoodId = recipe.pantryFoodId;
      if (pantryFoodId != null) {
        await Supabase.instance.client
            .from('pantry_foods')
            .delete()
            .eq('id', pantryFoodId)
            .eq('user_id', userId);
      }
    } catch (_) {}
  }

  /// Pushes a recipe's current full local state to Supabase: the derived
  /// PantryFood first (recipes.pantry_food_id has a Postgres FK to
  /// pantry_foods, so it must exist remotely before the recipe row does),
  /// then the recipe row, then a delete-and-reinsert of its steps/ingredients
  /// (mirrors the local update's delete-and-reinsert semantics).
  Future<void> _syncRecipeToRemote(String recipeId) async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final recipe =
          await (db.select(db.recipes)
            ..where((r) => r.id.equals(recipeId))).getSingle();

      final pantryFoodId = recipe.pantryFoodId;
      if (pantryFoodId != null) {
        final food =
            await (db.select(db.pantryFoods)
              ..where((f) => f.id.equals(pantryFoodId))).getSingleOrNull();
        if (food != null) {
          await Supabase.instance.client.from('pantry_foods').upsert({
            'id': food.id,
            'user_id': userId,
            'name': food.name,
            'calories': food.calories,
            'protein': food.protein,
            'carbs': food.carbs,
            'fat': food.fat,
            'sugar': food.sugar,
            'fiber': food.fiber,
            'sodium': food.sodium,
            'cholesterol': food.cholesterol,
            'potassium': food.potassium,
            'calcium': food.calcium,
            'iron': food.iron,
            'vitamin_a': food.vitaminA,
            'vitamin_c': food.vitaminC,
            'serving_label': food.servingLabel,
            'is_preset': false,
            'category': food.category,
          });
          await (db.update(db.pantryFoods)..where(
            (f) => f.id.equals(food.id),
          )).write(const PantryFoodsCompanion(synced: Value(true)));
        }
      }

      await Supabase.instance.client.from('recipes').upsert({
        'id': recipe.id,
        'user_id': userId,
        'name': recipe.name,
        'servings_yield': recipe.servingsYield,
        'prep_time_minutes': recipe.prepTimeMinutes,
        'cook_time_minutes': recipe.cookTimeMinutes,
        'photo_url': recipe.photoUrl,
        'pantry_food_id': recipe.pantryFoodId,
      });

      final steps =
          await (db.select(db.recipeSteps)
            ..where((s) => s.recipeId.equals(recipeId))).get();
      final ingredients =
          await (db.select(db.recipeStepIngredients)
            ..where((i) => i.recipeId.equals(recipeId))).get();

      await Supabase.instance.client
          .from('recipe_step_ingredients')
          .delete()
          .eq('recipe_id', recipeId);
      await Supabase.instance.client
          .from('recipe_steps')
          .delete()
          .eq('recipe_id', recipeId);

      if (steps.isNotEmpty) {
        await Supabase.instance.client.from('recipe_steps').insert([
          for (final s in steps)
            {
              'id': s.id,
              'recipe_id': s.recipeId,
              'user_id': userId,
              'step_order': s.stepOrder,
              'action_verb': s.actionVerb,
              'instructions': s.instructions,
            },
        ]);
      }
      if (ingredients.isNotEmpty) {
        await Supabase.instance.client.from('recipe_step_ingredients').insert([
          for (final i in ingredients)
            {
              'id': i.id,
              'step_id': i.stepId,
              'recipe_id': i.recipeId,
              'user_id': userId,
              'pantry_food_id': i.pantryFoodId,
              'servings': i.servings,
              'amount_label': i.amountLabel,
              'sort_order': i.sortOrder,
            },
        ]);
      }

      await (db.update(db.recipes)..where(
        (r) => r.id.equals(recipeId),
      )).write(const RecipesCompanion(synced: Value(true)));
      await (db.update(db.recipeSteps)..where(
        (s) => s.recipeId.equals(recipeId),
      )).write(const RecipeStepsCompanion(synced: Value(true)));
      await (db.update(db.recipeStepIngredients)..where(
        (i) => i.recipeId.equals(recipeId),
      )).write(const RecipeStepIngredientsCompanion(synced: Value(true)));
    } catch (_) {}
  }

  /// Retry recipe writes whose Supabase sync previously failed. Call before
  /// [syncFromRemote] on app launch, same as every other feature's bootstrap.
  Future<void> pushUnsyncedChanges() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final unsynced =
        await (db.select(db.recipes)..where(
          (r) => r.userId.equals(userId) & r.synced.equals(false),
        )).get();
    for (final r in unsynced) {
      await _syncRecipeToRemote(r.id);
    }
  }

  /// Pulls the current user's recipes from Supabase into local Drift. Called
  /// once on login. Does NOT need to separately pull each recipe's derived
  /// PantryFood — PantryNotifier.syncFromRemote() already pulls every
  /// personal pantry food for this user, recipe-derived or not.
  Future<void> syncFromRemote() async {
    final db = ref.read(databaseProvider);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final recipes = await Supabase.instance.client
          .from('recipes')
          .select()
          .eq('user_id', userId);
      for (final row in recipes as List) {
        await db
            .into(db.recipes)
            .insertOnConflictUpdate(
              RecipesCompanion.insert(
                id: row['id'] as String,
                userId: userId,
                name: row['name'] as String,
                servingsYield: Value(
                  (row['servings_yield'] as num?)?.toDouble(),
                ),
                prepTimeMinutes: Value(row['prep_time_minutes'] as int?),
                cookTimeMinutes: Value(row['cook_time_minutes'] as int?),
                photoUrl: Value(row['photo_url'] as String?),
                pantryFoodId: Value(row['pantry_food_id'] as String?),
                createdAt: Value(DateTime.parse(row['created_at'] as String)),
                synced: const Value(true),
              ),
            );
      }

      final steps = await Supabase.instance.client
          .from('recipe_steps')
          .select()
          .eq('user_id', userId);
      for (final row in steps as List) {
        await db
            .into(db.recipeSteps)
            .insertOnConflictUpdate(
              RecipeStepsCompanion.insert(
                id: row['id'] as String,
                recipeId: row['recipe_id'] as String,
                userId: userId,
                stepOrder: row['step_order'] as int,
                actionVerb: row['action_verb'] as String,
                instructions: Value(row['instructions'] as String?),
                synced: const Value(true),
              ),
            );
      }

      final ingredients = await Supabase.instance.client
          .from('recipe_step_ingredients')
          .select()
          .eq('user_id', userId);
      for (final row in ingredients as List) {
        await db
            .into(db.recipeStepIngredients)
            .insertOnConflictUpdate(
              RecipeStepIngredientsCompanion.insert(
                id: row['id'] as String,
                stepId: row['step_id'] as String,
                recipeId: row['recipe_id'] as String,
                userId: userId,
                pantryFoodId: row['pantry_food_id'] as String,
                servings: Value(((row['servings'] as num?) ?? 1.0).toDouble()),
                amountLabel: Value(row['amount_label'] as String?),
                sortOrder: Value(row['sort_order'] as int? ?? 0),
                synced: const Value(true),
              ),
            );
      }
    } catch (_) {}
  }

  /// Uploads a recipe photo to Supabase Storage and returns its public URL.
  /// Mirrors ProfileNotifier.uploadAvatar exactly, targeting the
  /// `recipe-photos` bucket at `$userId/$recipeId.$ext` instead of
  /// `avatars`'s `$userId/avatar.$ext`.
  Future<String> uploadRecipePhoto({
    required String recipeId,
    required XFile file,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in');

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) throw Exception('Selected file is empty');

    // On web, file.path is a blob URL — use mimeType instead.
    final mime = file.mimeType ?? 'image/jpeg';
    final ext = mime.split('/').last.replaceAll('jpeg', 'jpg');
    final path = '$userId/$recipeId.$ext';

    final storageResponse = await Supabase.instance.client.storage
        .from('recipe-photos')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: mime),
        );
    if (storageResponse.isEmpty) {
      throw Exception('Storage upload returned empty path');
    }

    try {
      final baseUrl = Supabase.instance.client.storage
          .from('recipe-photos')
          .getPublicUrl(path);
      return '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (_) {
      return await Supabase.instance.client.storage
          .from('recipe-photos')
          .createSignedUrl(path, 60 * 60 * 24 * 365);
    }
  }
}
