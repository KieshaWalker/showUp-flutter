// recipe_constants.dart — small hardcoded reference lists for the Recipe
// feature, same spirit as NutritionRDA/the _months list elsewhere in the app.

/// Fixed ingredient categories. Stored on PantryFoods.category (nullable —
/// foods added before this existed, or never categorized, are null and
/// simply don't show up in a category-filtered picker).
const List<String> kIngredientCategories = [
  'Starch',
  'Protein',
  'Vegetable',
  'Fruit',
  'Dairy',
  'Spice',
  'Sauce & Condiment',
  'Other',
];

/// Cooking-action verbs a recipe step is tagged with, chosen before
/// ingredients are added to that step — makes the cooking method explicit
/// rather than something inferred from the ingredient list.
const List<String> kStepActionVerbs = [
  'Boil',
  'Sauté',
  'Bake',
  'Roast',
  'Grill',
  'Mix',
  'Chop',
  'Season',
  'Simmer',
  'Fry',
  'Steam',
  'Marinate',
  'Rest',
  'Serve',
  'Other',
];
