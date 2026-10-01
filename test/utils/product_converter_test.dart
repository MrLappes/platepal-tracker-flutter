import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/models/product.dart';
import 'package:platepal_tracker/utils/product_converter.dart';
import 'package:platepal_tracker/utils/unit_conversion.dart';

void main() {
  test('local dish contributes its totals once per selected piece', () {
    final dish = Dish(
      id: 'oats',
      name: 'Oats',
      ingredients: const [
        Ingredient(id: 'grain', name: 'Grain', amount: 250, unit: 'g'),
      ],
      nutrition: const NutritionInfo(
        calories: 400,
        protein: 20,
        carbs: 50,
        fat: 10,
      ),
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final product = ProductToIngredientConverter.productFromDish(dish);
    final ingredient = ProductToIngredientConverter.convertProductToIngredient(
      product,
      amount: 100,
      unit: 'g',
    );

    expect(product.nutrition, isNull);
    expect(ingredient.unit, 'piece');
    expect(ingredient.amount, 1);
    expect(ingredient.nutrition?.calories, 400);
    expect(
      ingredient.nutrition!.calories * nutritionMultiplier(2, ingredient.unit),
      800,
    );
    expect(
      ingredient.nutrition!.protein * nutritionMultiplier(2, ingredient.unit),
      40,
    );
  });

  test('unnamed products use the localized fallback in both conversions', () {
    for (final entry
        in {
          'es': 'Producto desconocido',
          'de': 'Unbekanntes Produkt',
        }.entries) {
      final ingredient = intl.Intl.withLocale(
        entry.key,
        () => ProductToIngredientConverter.convertProductToIngredient(
          const Product(),
        ),
      );
      final defaultIngredient = intl.Intl.withLocale(
        entry.key,
        () => ProductToIngredientConverter.createDefaultIngredient(
          const Product(),
        ),
      );

      expect(ingredient.name, entry.value);
      expect(defaultIngredient.name, entry.value);
    }
  });
}
