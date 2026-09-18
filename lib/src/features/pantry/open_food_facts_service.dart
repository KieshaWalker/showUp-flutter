// open_food_facts_service.dart — Barcode → nutrition lookup via Open Food
// Facts (https://world.openfoodfacts.org), a free, open, crowdsourced product
// database. No API key required.
//
// Connections:
//   barcode_scanner_screen.dart — scans a barcode, hands it to lookupBarcode()
//   pantry_screen.dart          — prefills the add-food form with the result

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Nutrition data resolved from a barcode lookup, in the same per-serving
/// shape as [PantryFood] so it can prefill the add-food form directly.
class ScannedFoodInfo {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double sugar;
  final double fiber;
  final double sodium;
  final double cholesterol;
  final double potassium;
  final double calcium;
  final double iron;
  final double vitaminA;
  final double vitaminC;
  final String servingLabel;

  const ScannedFoodInfo({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.sodium,
    required this.cholesterol,
    required this.potassium,
    required this.calcium,
    required this.iron,
    required this.vitaminA,
    required this.vitaminC,
    required this.servingLabel,
  });
}

/// Looks up [barcode] (UPC/EAN) against Open Food Facts and returns nutrition
/// info scaled to a single serving, or null if the product isn't in the
/// database or has no usable nutrition facts.
///
/// Open Food Facts normalizes mass-based nutrients to grams internally, so
/// milligram/microgram fields (sodium, cholesterol, potassium, calcium, iron,
/// vitamin A, vitamin C) are converted up from the raw gram values it returns.
Future<ScannedFoodInfo?> lookupBarcode(String barcode) async {
  final uri = Uri.parse(
    'https://world.openfoodfacts.org/api/v2/product/$barcode.json'
    '?fields=product_name,brands,serving_size,nutriments',
  );

  final http.Response response;
  try {
    response = await http.get(uri).timeout(const Duration(seconds: 10));
  } catch (_) {
    return null;
  }
  if (response.statusCode != 200) return null;

  final Map<String, dynamic> body;
  try {
    body = jsonDecode(response.body) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
  if (body['status'] != 1) return null; // product not found

  final product = body['product'] as Map<String, dynamic>?;
  if (product == null) return null;
  final nutriments = product['nutriments'] as Map<String, dynamic>?;
  if (nutriments == null) return null;

  // Prefer per-serving values when Open Food Facts has them (i.e. the
  // product defines a serving_size), otherwise fall back to per-100g.
  final hasServingData = nutriments.containsKey('energy-kcal_serving');
  final suffix = hasServingData ? '_serving' : '_100g';

  double gramsField(String key) =>
      ((nutriments['$key$suffix'] as num?) ?? 0).toDouble();

  final calories = ((nutriments['energy-kcal$suffix'] as num?) ?? 0)
      .toDouble();
  if (calories == 0 &&
      gramsField('proteins') == 0 &&
      gramsField('carbohydrates') == 0 &&
      gramsField('fat') == 0) {
    return null; // nothing usable
  }

  final name = (product['product_name'] as String?)?.trim();
  final brand = (product['brands'] as String?)?.split(',').first.trim();
  final resolvedName = [
    if (brand != null && brand.isNotEmpty) brand,
    if (name != null && name.isNotEmpty) name,
  ].join(' ');

  final servingSize = (product['serving_size'] as String?)?.trim();
  final servingLabel = hasServingData && servingSize != null && servingSize.isNotEmpty
      ? servingSize
      : '100 g';

  return ScannedFoodInfo(
    name: resolvedName.isEmpty ? 'Scanned food' : resolvedName,
    calories: calories,
    protein: gramsField('proteins'),
    carbs: gramsField('carbohydrates'),
    fat: gramsField('fat'),
    sugar: gramsField('sugars'),
    fiber: gramsField('fiber'),
    sodium: gramsField('sodium') * 1000, // g -> mg
    cholesterol: gramsField('cholesterol') * 1000, // g -> mg
    potassium: gramsField('potassium') * 1000, // g -> mg
    calcium: gramsField('calcium') * 1000, // g -> mg
    iron: gramsField('iron') * 1000, // g -> mg
    vitaminA: gramsField('vitamin-a') * 1000000, // g -> mcg
    vitaminC: gramsField('vitamin-c') * 1000, // g -> mg
    servingLabel: servingLabel,
  );
}
