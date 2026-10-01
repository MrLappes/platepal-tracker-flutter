import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/dishes/dish_form/smart_nutrition_card.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/screens/dish_create_screen.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';

void main() {
  testWidgets('edit dish offers one save action in the FAB', (tester) async {
    final now = DateTime(2025);
    final dish = Dish(
      id: 'dish-save',
      name: 'Salad',
      ingredients: const [],
      nutrition: const NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0),
      createdAt: now,
      updatedAt: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DishCreateScreenAdvanced(dish: dish),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.widgetWithText(TextButton, 'Save'),
      ),
      findsNothing,
    );
    expect(
      find.widgetWithText(FloatingActionButton, 'Save Dish'),
      findsOneWidget,
    );
  });

  testWidgets('dish form reserves scroll padding above the FAB', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DishCreateScreenAdvanced(),
      ),
    );

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView).first,
    );
    expect(
      scrollView.padding!.resolve(TextDirection.ltr).bottom,
      greaterThanOrEqualTo(112),
    );
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -2000),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getBottomLeft(find.byType(SwitchListTile)).dy,
      lessThan(tester.getTopLeft(find.byType(FloatingActionButton)).dy),
    );
  });

  testWidgets('nutrition card is flat and has no decorative question icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DishCreateScreenAdvanced(),
      ),
    );

    final card = find.byType(SmartNutritionCard);
    expect(
      find.descendant(
        of: card,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).gradient != null,
        ),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: card, matching: find.byType(Card)),
      findsNothing,
    );
    expect(
      find.descendant(of: card, matching: find.byIcon(Icons.help_outline)),
      findsNothing,
    );
  });

  testWidgets('calculator action has a localized tooltip', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DishCreateScreenAdvanced(),
      ),
    );

    final card = find.byType(SmartNutritionCard);
    expect(
      find.descendant(
        of: card,
        matching: find.byTooltip('Recalculate from ingredients'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('deleting the last ingredient clears recalculated totals', (
    tester,
  ) async {
    final now = DateTime(2025);
    final dish = Dish(
      id: 'dish-1',
      name: 'Salad',
      ingredients: const [
        Ingredient(
          id: 'tomato',
          name: 'Tomato',
          amount: 100,
          unit: 'g',
          nutrition: NutritionInfo(calories: 100, protein: 0, carbs: 0, fat: 0),
        ),
      ],
      nutrition: const NutritionInfo(
        calories: 100,
        protein: 0,
        carbs: 0,
        fat: 0,
      ),
      createdAt: now,
      updatedAt: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DishCreateScreenAdvanced(dish: dish),
      ),
    );

    await tester.ensureVisible(find.byIcon(Icons.more_vert));
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    final nutritionCard = tester.widget<SmartNutritionCard>(
      find.byType(SmartNutritionCard),
    );
    expect(nutritionCard.caloriesController.text, '0.0');
    expect(find.text('Tomato'), findsNothing);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('German dish ingredient and recalculated values use commas', (
    tester,
  ) async {
    final now = DateTime(2025);
    final dish = Dish(
      id: 'dish-ingredient-de',
      name: 'Salad',
      ingredients: const [
        Ingredient(
          id: 'tomato',
          name: 'Tomato',
          amount: 100,
          unit: 'g',
          nutrition: NutritionInfo(
            calories: 100,
            protein: 30,
            carbs: 8.5,
            fat: 2,
          ),
        ),
      ],
      nutrition: const NutritionInfo(
        calories: 100,
        protein: 30,
        carbs: 8.5,
        fat: 2,
      ),
      createdAt: now,
      updatedAt: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DishCreateScreenAdvanced(dish: dish),
      ),
    );

    expect(find.text('100,0 g'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data?.contains('30,0') == true,
      ),
      findsOneWidget,
    );
    tester
        .widget<SmartNutritionCard>(find.byType(SmartNutritionCard))
        .onRecalculate!();
    await tester.pump();
    expect(
      tester
          .widget<SmartNutritionCard>(find.byType(SmartNutritionCard))
          .proteinController
          .text,
      '30,0',
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('edited dish prompts before leaving and can be discarded', (
    tester,
  ) async {
    final now = DateTime(2025);
    final dish = Dish(
      id: 'dish-2',
      name: 'Salad',
      ingredients: const [],
      nutrition: const NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0),
      createdAt: now,
      updatedAt: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder:
                              (context) => DishCreateScreenAdvanced(dish: dish),
                        ),
                      ),
                  child: const Text('Open'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'New salad');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Unsaved Changes'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(DishCreateScreenAdvanced), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard Changes'));
    await tester.pumpAndSettle();
    expect(find.byType(DishCreateScreenAdvanced), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('changing favorite also prompts before leaving', (tester) async {
    final now = DateTime(2025);
    final dish = Dish(
      id: 'dish-3',
      name: 'Salad',
      ingredients: const [],
      nutrition: const NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0),
      createdAt: now,
      updatedAt: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder:
                              (context) => DishCreateScreenAdvanced(dish: dish),
                        ),
                      ),
                  child: const Text('Open'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Unsaved Changes'), findsOneWidget);
  });

  testWidgets('an existing dish image is shown and can be removed', (
    tester,
  ) async {
    final image = _createTestImage();
    final now = DateTime(2025);
    final dish = Dish(
      id: 'dish-image',
      name: 'Salad',
      imageUrl: image.path,
      ingredients: const [],
      nutrition: const NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0),
      createdAt: now,
      updatedAt: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DishCreateScreenAdvanced(dish: dish),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is FileImage &&
            (widget.image as FileImage).file.path == image.path,
      ),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.add_a_photo));
    await tester.pumpAndSettle();
    expect(find.text('Remove image'), findsOneWidget);
  });

  testWidgets('saving without a replacement keeps the existing image', (
    tester,
  ) async {
    final image = _createTestImage();
    final now = DateTime(2025);
    final dish = Dish(
      id: 'dish-saved-image',
      name: 'Salad',
      imageUrl: image.path,
      ingredients: const [],
      nutrition: const NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0),
      createdAt: now,
      updatedAt: now,
    );
    final service = _RecordingDishService(dish);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DishCreateScreenAdvanced(dish: dish, dishService: service),
      ),
    );

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Save Dish'));
    await tester.pumpAndSettle();
    expect(service.saved?.imageUrl, dish.imageUrl);
  });

  testWidgets('a comma decimal in dish nutrition is saved as a number', (
    tester,
  ) async {
    final now = DateTime(2025);
    final dish = Dish(
      id: 'dish-comma',
      name: 'Salad',
      ingredients: const [],
      nutrition: const NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0),
      createdAt: now,
      updatedAt: now,
    );
    final service = _RecordingDishService(dish);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DishCreateScreenAdvanced(dish: dish, dishService: service),
      ),
    );
    final calorieField =
        find
            .descendant(
              of: find.byType(SmartNutritionCard),
              matching: find.byType(TextFormField),
            )
            .first;
    await tester.enterText(calorieField, '1,5');
    await tester.pump();
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Save Dish'));
    await tester.pumpAndSettle();

    expect(service.saved?.nutrition.calories, 1.5);
  });

  testWidgets('German edit prefills decimals and preserves nutrition on save', (
    tester,
  ) async {
    final now = DateTime(2025);
    final dish = Dish(
      id: 'dish-german-edit',
      name: 'Salad',
      ingredients: const [],
      nutrition: const NutritionInfo(
        calories: 120.75,
        protein: 30.25,
        carbs: 8.5,
        fat: 2,
        fiber: 0.75,
      ),
      createdAt: now,
      updatedAt: now,
    );
    final service = _RecordingDishService(dish);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DishCreateScreenAdvanced(dish: dish, dishService: service),
      ),
    );

    final nutritionCard = tester.widget<SmartNutritionCard>(
      find.byType(SmartNutritionCard),
    );
    expect(nutritionCard.caloriesController.text, '120,75');
    expect(nutritionCard.proteinController.text, '30,25');
    expect(nutritionCard.carbsController.text, '8,5');
    expect(nutritionCard.fatController.text, '2,0');
    expect(nutritionCard.fiberController.text, '0,75');

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(service.saved?.nutrition.calories, 120.75);
    expect(service.saved?.nutrition.protein, 30.25);
    expect(service.saved?.nutrition.carbs, 8.5);
    expect(service.saved?.nutrition.fat, 2);
    expect(service.saved?.nutrition.fiber, 0.75);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('failed dish lookup stops save and shows an error', (
    tester,
  ) async {
    final now = DateTime(2026, 9, 1);
    final dish = Dish(
      id: 'existing-dish',
      name: 'Salad',
      ingredients: const [],
      nutrition: const NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0),
      createdAt: now,
      updatedAt: now,
    );
    final service = _FailingLookupDishService();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DishCreateScreenAdvanced(dish: dish, dishService: service),
      ),
    );

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Save Dish'));
    await tester.pumpAndSettle();

    expect(service.saveAttempts, 0);
    expect(find.byType(DishCreateScreenAdvanced), findsOneWidget);
    expect(find.text('Error saving dish'), findsOneWidget);
  });
}

File _createTestImage() {
  final directory = Directory.systemTemp.createTempSync('dish-image-test-');
  addTearDown(() => directory.deleteSync(recursive: true));
  final image = File('${directory.path}/existing.png');
  image.writeAsBytesSync(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLTTAAAAABJRU5ErkJggg==',
    ),
  );
  return image;
}

class _RecordingDishService extends DishService {
  final Dish original;
  Dish? saved;

  _RecordingDishService(this.original);

  @override
  Future<Dish?> getDishById(String id) async => original;

  @override
  Future<Dish> updateDish(Dish dish) async {
    saved = dish;
    return dish;
  }
}

class _FailingLookupDishService extends DishService {
  int saveAttempts = 0;

  @override
  Future<Dish?> getDishById(String id) async => throw StateError('unavailable');

  @override
  Future<Dish> saveDish(Dish dish) async {
    saveAttempts++;
    return dish;
  }
}
