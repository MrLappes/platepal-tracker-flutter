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
}
