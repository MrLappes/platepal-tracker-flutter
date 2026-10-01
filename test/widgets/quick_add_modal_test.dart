import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/modals/quick_add_modal.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';

class _RecordingDishService extends DishService {
  final List<double> calories = [];
  final List<double> protein = [];

  @override
  Future<String> logQuickAdd({
    required String name,
    required DateTime loggedAt,
    required String mealType,
    required double calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    double fiber = 0,
    String? notes,
  }) async {
    this.calories.add(calories);
    this.protein.add(protein);
    return 'id';
  }
}

void main() {
  testWidgets('quick add rejects values above the chat proposal limits', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);
    final service = _RecordingDishService();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder:
              (context) => Scaffold(
                body: TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<bool>(
                          builder:
                              (_) => Scaffold(
                                body: QuickAddModal(dishService: service),
                              ),
                        ),
                      ),
                  child: const Text('open'),
                ),
              ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final calories = find.widgetWithText(TextFormField, 'Calories (kcal)');
    final protein = find.widgetWithText(TextFormField, 'Protein (g)');
    Future<void> save() async {
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    await tester.enterText(calories, '10001');
    await tester.enterText(protein, '1001');
    await save();
    expect(find.textContaining('Enter at most'), findsNWidgets(2));
    expect(service.calories, isEmpty);

    await tester.enterText(calories, '10000');
    await tester.enterText(protein, '1000');
    await save();
    expect(find.textContaining('Enter at most'), findsNothing);
    expect(service.calories, [10000]);
    expect(service.protein, [1000]);
  });
}
