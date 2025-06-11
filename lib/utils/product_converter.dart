import '../models/product.dart';
import '../models/dish.dart';

class ProductToIngredientConverter {
  /// Convert a Product from Open Food Facts to an Ingredient
  static Ingredient convertProductToIngredient(
    Product product, {
    double amount = 100.0,
    String unit = 'g',
  }) {
    // Generate a unique ID for the ingredient
    final id =
        'ingredient_${DateTime.now().millisecondsSinceEpoch}_${product.barcode ?? product.name?.hashCode}';

    // Use product name, fallback to brand if no name
    final name = product.name ?? product.brand ?? 'Unknown Product';

    // Convert product nutrition to ingredient nutrition
    NutritionInfo? nutrition;
    if (product.hasNutrition) {
      final productNutrition = product.nutrition!;
      nutrition = NutritionInfo(
        calories: productNutrition.calories,
        protein: productNutrition.protein,
        carbs: productNutrition.carbs,
        fat: productNutrition.fat,
        fiber: productNutrition.fiber,
        sugar: productNutrition.sugar,
        sodium: productNutrition.sodium,
      );
    }

    return Ingredient(
      id: id,
      name: name,
      amount: amount,
      unit: unit,
      nutrition: nutrition,
      barcode: product.barcode,
    );
  }

  /// Create a default ingredient with common nutrition values if product has no nutrition data
  static Ingredient createDefaultIngredient(
    Product product, {
    double amount = 100.0,
    String unit = 'g',
  }) {
    final id =
        'ingredient_${DateTime.now().millisecondsSinceEpoch}_${product.barcode ?? product.name?.hashCode}';
    final name = product.name ?? product.brand ?? 'Unknown Product';

    // If product has no nutrition, create ingredient without nutrition
    // User can manually add nutrition values later
    return Ingredient(
      id: id,
      name: name,
      amount: amount,
      unit: unit,
      nutrition: null,
      barcode: product.barcode,
    );
  }

  /// Get suggested serving amounts based on product type/name
  static List<ServingSuggestion> getSuggestedServings(Product product) {
    final suggestions = <ServingSuggestion>[];
    final name = product.name?.toLowerCase() ?? '';
    final quantity = product.quantity?.toLowerCase() ?? '';

    // Default 100g serving
    suggestions.add(
      const ServingSuggestion(
        amount: 100,
        unit: 'g',
        description: '100g (standard)',
      ),
    );

    // Add specific suggestions based on product type
    if (name.contains('milk') ||
        name.contains('juice') ||
        name.contains('water')) {
      suggestions.addAll([
        const ServingSuggestion(
          amount: 250,
          unit: 'ml',
          description: '1 cup (250ml)',
        ),
        const ServingSuggestion(
          amount: 500,
          unit: 'ml',
          description: '1 bottle (500ml)',
        ),
        const ServingSuggestion(
          amount: 1000,
          unit: 'ml',
          description: '1 liter',
        ),
      ]);
    } else if (name.contains('bread') || name.contains('slice')) {
      suggestions.addAll([
        const ServingSuggestion(
          amount: 25,
          unit: 'g',
          description: '1 thin slice (~25g)',
        ),
        const ServingSuggestion(
          amount: 35,
          unit: 'g',
          description: '1 slice (~35g)',
        ),
        const ServingSuggestion(
          amount: 50,
          unit: 'g',
          description: '1 thick slice (~50g)',
        ),
      ]);
    } else if (name.contains('egg')) {
      suggestions.addAll([
        const ServingSuggestion(
          amount: 50,
          unit: 'g',
          description: '1 medium egg (~50g)',
        ),
        const ServingSuggestion(
          amount: 60,
          unit: 'g',
          description: '1 large egg (~60g)',
        ),
      ]);
    } else if (name.contains('banana') || name.contains('apple')) {
      suggestions.addAll([
        const ServingSuggestion(
          amount: 150,
          unit: 'g',
          description: '1 medium fruit (~150g)',
        ),
        const ServingSuggestion(
          amount: 200,
          unit: 'g',
          description: '1 large fruit (~200g)',
        ),
      ]);
    } else if (name.contains('yogurt') || name.contains('yoghurt')) {
      suggestions.addAll([
        const ServingSuggestion(
          amount: 125,
          unit: 'g',
          description: '1 small container (~125g)',
        ),
        const ServingSuggestion(
          amount: 175,
          unit: 'g',
          description: '1 container (~175g)',
        ),
      ]);
    } else if (name.contains('cheese')) {
      suggestions.addAll([
        const ServingSuggestion(
          amount: 30,
          unit: 'g',
          description: '1 slice (~30g)',
        ),
        const ServingSuggestion(
          amount: 50,
          unit: 'g',
          description: '1 serving (~50g)',
        ),
      ]);
    } else if (name.contains('rice') || name.contains('pasta')) {
      suggestions.addAll([
        const ServingSuggestion(
          amount: 75,
          unit: 'g',
          description: '1 serving dry (~75g)',
        ),
        const ServingSuggestion(
          amount: 150,
          unit: 'g',
          description: '2 servings dry (~150g)',
        ),
      ]);
    }

    // Try to extract serving size from quantity field
    if (quantity.isNotEmpty) {
      final weightMatch = RegExp(r'(\d+\.?\d*)\s*g').firstMatch(quantity);
      if (weightMatch != null) {
        final weight = double.tryParse(weightMatch.group(1) ?? '');
        if (weight != null && weight > 0 && weight <= 1000) {
          suggestions.add(
            ServingSuggestion(
              amount: weight,
              unit: 'g',
              description: 'Package size (${weight}g)',
            ),
          );
        }
      }

      final volumeMatch = RegExp(r'(\d+\.?\d*)\s*ml').firstMatch(quantity);
      if (volumeMatch != null) {
        final volume = double.tryParse(volumeMatch.group(1) ?? '');
        if (volume != null && volume > 0 && volume <= 2000) {
          suggestions.add(
            ServingSuggestion(
              amount: volume,
              unit: 'ml',
              description: 'Package size (${volume}ml)',
            ),
          );
        }
      }
    }

    // Remove duplicates and sort by amount
    final uniqueSuggestions = <ServingSuggestion>{};
    for (final suggestion in suggestions) {
      uniqueSuggestions.add(suggestion);
    }

    final sortedSuggestions = uniqueSuggestions.toList();
    sortedSuggestions.sort((a, b) => a.amount.compareTo(b.amount));

    return sortedSuggestions;
  }
}

class ServingSuggestion {
  final double amount;
  final String unit;
  final String description;

  const ServingSuggestion({
    required this.amount,
    required this.unit,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServingSuggestion &&
        other.amount == amount &&
        other.unit == unit;
  }

  @override
  int get hashCode => amount.hashCode ^ unit.hashCode;
}
