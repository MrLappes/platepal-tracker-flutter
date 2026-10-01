import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/utils/unit_conversion.dart';

void main() {
  test('ounces convert to grams before scaling per-100g nutrition', () {
    expect(nutritionMultiplier(2, 'oz'), closeTo(0.56699, 0.000001));
  });

  test('gram and volume units scale per-100g nutrition', () {
    for (final entry
        in {
          'g': (150.0, 1.5),
          'ml': (120.0, 1.2),
          'kg': (0.25, 2.5),
          'l': (0.5, 5.0),
          'cup': (1.0, 2.4),
          'tbsp': (2.0, 0.3),
          'tsp': (3.0, 0.15),
        }.entries) {
      expect(
        nutritionMultiplier(entry.value.$1, entry.key),
        closeTo(entry.value.$2, 0.000001),
        reason: entry.key,
      );
    }
  });

  test('piece and slice nutrition is already per item', () {
    expect(nutritionMultiplier(2, 'piece'), 2);
    expect(nutritionMultiplier(3, 'slice'), 3);
  });

  group('totalDishWeight', () {
    test('sums weight units in grams', () {
      final weight = totalDishWeight([
        (amount: 50, unit: 'g'),
        (amount: 0.2, unit: 'KG '),
        (amount: 1, unit: 'oz'),
      ]);
      expect(weight!.amount, closeTo(278.3495, 1e-9));
      expect(weight.unit, 'g');
    });

    test('all-liquid dishes are measured in ml', () {
      final weight = totalDishWeight([
        (amount: 0.5, unit: 'l'),
        (amount: 200, unit: 'ml'),
      ]);
      expect(weight, (amount: 700.0, unit: 'ml'));
    });

    test('mixed weight and volume counts ml as g', () {
      expect(
        totalDishWeight([(amount: 50, unit: 'g'), (amount: 200, unit: 'ml')]),
        (amount: 250.0, unit: 'g'),
      );
    });

    test('is unknown for pieces, spoons, cups or no ingredients', () {
      for (final unit in ['piece', 'slice', 'tbsp', 'tsp', 'cup']) {
        expect(
          totalDishWeight([(amount: 50, unit: 'g'), (amount: 1, unit: unit)]),
          isNull,
          reason: unit,
        );
      }
      expect(totalDishWeight(const []), isNull);
      expect(totalDishWeight([(amount: 0, unit: 'g')]), isNull);
    });
  });
}
