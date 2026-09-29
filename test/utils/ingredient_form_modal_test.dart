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
}
