import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/meal_type.dart';

void main() {
  test('defaults to the meal type for the local time of day', () {
    expect(
      defaultMealTypeForTime(DateTime(2026, 9, 28, 10, 29)),
      MealType.breakfast,
    );
    expect(
      defaultMealTypeForTime(DateTime(2026, 9, 28, 10, 30)),
      MealType.lunch,
    );
    expect(
      defaultMealTypeForTime(DateTime(2026, 9, 28, 14, 59)),
      MealType.lunch,
    );
    expect(defaultMealTypeForTime(DateTime(2026, 9, 28, 15)), MealType.dinner);
    expect(
      defaultMealTypeForTime(DateTime(2026, 9, 28, 20, 59)),
      MealType.dinner,
    );
    expect(defaultMealTypeForTime(DateTime(2026, 9, 28, 21)), MealType.snack);
    expect(
      defaultMealTypeForTime(DateTime(2026, 9, 28, 0)),
      MealType.breakfast,
    );
  });

  test('displayName uses localized meal names', () {
    expect(
      intl.Intl.withLocale('es', () => MealType.breakfast.displayName),
      'Desayuno',
    );
    expect(
      intl.Intl.withLocale('de', () => MealType.dinner.displayName),
      'Abendessen',
    );
    expect(
      MealType.snack.localizedDisplayName(
        lookupAppLocalizations(const Locale('es')),
      ),
      'Merienda',
    );
  });
}
