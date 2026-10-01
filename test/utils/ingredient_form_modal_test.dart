import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/dishes/dish_form/ingredient_form_modal.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/dish.dart';

void main() {
  testWidgets('saving an ingredient preserves its product barcode', (
    tester,
  ) async {
    Ingredient? saved;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => IngredientFormModal.show(
                        context,
                        ingredient: const Ingredient(
                          id: 'ingredient',
                          name: 'Oats',
                          amount: 100,
                          unit: 'g',
                          barcode: '0123456789012',
                        ),
                        onSave: (ingredient) => saved = ingredient,
                      ),
                  child: const Text('Edit'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(saved?.barcode, '0123456789012');
  });

  testWidgets('German ingredient edit prefills commas and preserves values', (
    tester,
  ) async {
    Ingredient? saved;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => IngredientFormModal.show(
                        context,
                        ingredient: const Ingredient(
                          id: 'ingredient',
                          name: 'Oats',
                          amount: 125.5,
                          unit: 'g',
                          nutrition: NutritionInfo(
                            calories: 120.75,
                            protein: 30.25,
                            carbs: 10.5,
                            fat: 2,
                            fiber: 0.75,
                          ),
                        ),
                        onSave: (ingredient) => saved = ingredient,
                      ),
                  child: const Text('Edit'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    final fields =
        tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();
    expect(fields[1].controller?.text, '125,5');
    expect(fields[2].controller?.text, '120,75');
    expect(fields[3].controller?.text, '0,75');
    expect(fields[4].controller?.text, '30,25');
    expect(fields[5].controller?.text, '10,5');
    expect(fields[6].controller?.text, '2,0');

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    expect(saved?.amount, 125.5);
    expect(saved?.nutrition?.calories, 120.75);
    expect(saved?.nutrition?.protein, 30.25);
    expect(saved?.nutrition?.carbs, 10.5);
    expect(saved?.nutrition?.fat, 2);
    expect(saved?.nutrition?.fiber, 0.75);
  });
}
