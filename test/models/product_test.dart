import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/product.dart';

void main() {
  group('ProductNutrition.fromOpenFoodFacts', () {
    test('converts energy-kj_100g to kcal when kcal is missing', () {
      final nutrition = ProductNutrition.fromOpenFoodFacts({
        'nutriments': {'energy-kj_100g': 418.4},
      });

      expect(nutrition.energyKcal100g, closeTo(100, 0.0001));
    });

    test('converts energy_100g when other energy values are missing', () {
      final nutrition = ProductNutrition.fromOpenFoodFacts({
        'nutriments': {'energy_100g': 836.8},
      });

      expect(nutrition.energyKcal100g, closeTo(200, 0.0001));
    });

    test('prefers explicit kcal to kilojoules', () {
      final nutrition = ProductNutrition.fromOpenFoodFacts({
        'nutriments': {'energy-kcal_100g': 80, 'energy-kj_100g': 418.4},
      });

      expect(nutrition.energyKcal100g, 80);
    });

    test('derives sodium from salt when sodium is missing', () {
      final nutrition = ProductNutrition.fromOpenFoodFacts({
        'nutriments': {'salt_100g': 1.25},
      });

      expect(nutrition.sodium100g, closeTo(0.5, 0.0001));
    });

    test('prefers explicit sodium to salt-derived sodium', () {
      final nutrition = ProductNutrition.fromOpenFoodFacts({
        'nutriments': {'sodium_100g': 0.12, 'salt_100g': 1.25},
      });

      expect(nutrition.sodium100g, 0.12);
    });
  });
}
