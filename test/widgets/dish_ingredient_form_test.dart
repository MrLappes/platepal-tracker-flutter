import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/dishes/dish_form/ingredient_form_modal.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/dish.dart';

void main() {
  testWidgets('zero quantity keeps ingredient form open and does not save', (
    tester,
  ) async {
    final saved = <Ingredient>[];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () =>
                          IngredientFormModal.show(context, onSave: saved.add),
                  child: const Text('Open'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Tomato');
    await tester.enterText(find.byType(TextFormField).at(1), '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved, isEmpty);
    expect(find.byType(IngredientFormModal), findsOneWidget);
  });
}
