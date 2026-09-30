import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/modals/dish_log_modal.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/themes/app_theme.dart';

void main() {
  test('combines a selected past date with the chosen meal time', () {
    expect(
      combineMealDateAndTime(
        DateTime(2026, 9, 20),
        const TimeOfDay(hour: 18, minute: 45),
      ),
      DateTime(2026, 9, 20, 18, 45),
    );
    expect(
      combineMealDateAndTime(
        DateTime(2026, 9, 20, 18, 45),
        const TimeOfDay(hour: 7, minute: 15),
      ),
      DateTime(2026, 9, 20, 7, 15),
    );
  });

  testWidgets('log sheet offers a time picker next to the date', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final dish = Dish(
      id: 'test-dish',
      name: 'Soup',
      ingredients: const [],
      nutrition: const NutritionInfo(
        calories: 100,
        protein: 5,
        carbs: 10,
        fat: 3,
      ),
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: DishLogModal(dish: dish)),
      ),
    );

    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    await tester.tap(find.byIcon(Icons.access_time));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  testWidgets('log sheet uses the theme macro color for protein values', (
    tester,
  ) async {
    const proteinColor = Color(0xFF123456);
    final now = DateTime.now();
    final dish = Dish(
      id: 'test-dish',
      name: 'Soup',
      ingredients: const [],
      nutrition: const NutritionInfo(
        calories: 100,
        protein: 5,
        carbs: 10,
        fat: 3,
      ),
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.light.materialTheme.copyWith(
          extensions: [MacroColors.light.copyWith(protein: proteinColor)],
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: DishLogModal(dish: dish)),
      ),
    );

    final proteinValue = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) => widget is RichText && widget.text.toPlainText() == '5.0 g',
      ),
    );
    final proteinText = proteinValue.text as TextSpan;
    expect(
      (proteinText.children!.first as TextSpan).style?.color,
      proteinColor,
    );
  });
}
