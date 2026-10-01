import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/modals/dish_log_modal.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:platepal_tracker/themes/app_theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Dish _soup({List<Ingredient> ingredients = const []}) {
  final now = DateTime(2026, 1, 1);
  return Dish(
    id: 'soup',
    name: 'Soup',
    ingredients: ingredients,
    nutrition: const NutritionInfo(
      calories: 100,
      protein: 5,
      carbs: 10,
      fat: 3,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

Finder _richText(String text) => find.byWidgetPredicate(
  (widget) => widget is RichText && widget.text.toPlainText() == text,
);

Widget _app(Widget body, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: body),
);

void main() {
  sqfliteFfiInit();

  group('stepServings', () {
    test('moves to the next quarter in each direction', () {
      expect(stepServings(1, 1), 1.25);
      expect(stepServings(1, -1), 0.75);
      expect(stepServings(1.1, 1), 1.25);
      expect(stepServings(1.1, -1), 1.0);
      expect(stepServings(0.5000000001, -1), 0.25);
    });

    test('stays within a quarter and twenty servings', () {
      expect(stepServings(0.25, -1), 0.25);
      expect(stepServings(0.1, -1), 0.25);
      expect(stepServings(0.1, 1), 0.25);
      expect(stepServings(20, 1), 20);
    });
  });

  test('dishForLog rebuilds per-serving nutrition from the snapshot', () {
    final log = DishLog(
      id: 'l',
      dishId: 'soup',
      dishName: 'Old soup',
      loggedAt: DateTime(2026, 9, 20, 12),
      mealType: 'lunch',
      servingSize: 2,
      calories: 300,
      protein: 10,
      carbs: 20,
      fat: 6,
      fiber: 4,
    );
    final current = _soup(
      ingredients: const [
        Ingredient(id: 'i', name: 'Water', amount: 300, unit: 'ml'),
      ],
    );
    final dish = dishForLog(log, current: current, fallbackName: 'x');
    expect(dish.name, 'Old soup');
    expect(dish.nutrition.calories, 150);
    expect(dish.nutrition.fiber, 2);
    // The soup now has 100 kcal per serving, not 150: no weight input.
    expect(dish.ingredients, isEmpty);
    expect(servingWeight(dish), isNull);

    final unchanged = log.copyWith(calories: 201);
    expect(
      dishForLog(unchanged, current: current, fallbackName: 'x').ingredients,
      current.ingredients,
    );
    expect(
      dishForLog(
        log.copyWith(calories: 204),
        current: current,
        fallbackName: 'x',
      ).ingredients,
      isEmpty,
    );
    expect(
      dishForLog(unchanged.copyWith(), fallbackName: 'x').ingredients,
      isEmpty,
    );
  });

  testWidgets('editing an entry of a changed dish hides the weight input', (
    tester,
  ) async {
    final log = DishLog(
      id: 'l',
      dishId: 'soup',
      dishName: 'Soup',
      loggedAt: DateTime(2026, 9, 20, 12),
      mealType: 'lunch',
      servingSize: 1,
      calories: 150,
      protein: 5,
      carbs: 10,
      fat: 3,
      fiber: 0,
    );
    final current = _soup(
      ingredients: const [
        Ingredient(id: 'i', name: 'Water', amount: 300, unit: 'ml'),
      ],
    );

    await tester.pumpWidget(
      _app(
        DishLogModal(
          dish: dishForLog(log, current: current, fallbackName: 'x'),
          existingLog: log,
        ),
      ),
    );
    expect(find.text('Weight'), findsNothing);

    await tester.pumpWidget(
      _app(
        DishLogModal(
          key: const ValueKey('same'),
          dish: dishForLog(
            log.copyWith(calories: 100),
            current: current,
            fallbackName: 'x',
          ),
          existingLog: log.copyWith(calories: 100),
        ),
      ),
    );
    expect(find.text('Weight'), findsOneWidget);
  });

  testWidgets('servings stepper moves in quarters and updates nutrition', (
    tester,
  ) async {
    await tester.pumpWidget(_app(DishLogModal(dish: _soup())));

    final servings = find.byKey(const ValueKey('dish-log-servings'));
    expect(tester.widget<TextField>(servings).controller!.text, '1');
    expect(_richText('100 kcal'), findsOneWidget);
    expect(find.text('Weight'), findsNothing);

    await tester.ensureVisible(find.byTooltip('More servings'));
    await tester.tap(find.byTooltip('More servings'));
    await tester.pump();
    expect(tester.widget<TextField>(servings).controller!.text, '1.25');
    expect(_richText('125 kcal'), findsOneWidget);

    await tester.tap(find.byTooltip('Fewer servings'));
    await tester.tap(find.byTooltip('Fewer servings'));
    await tester.tap(find.byTooltip('Fewer servings'));
    await tester.pump();
    expect(tester.widget<TextField>(servings).controller!.text, '0.5');
    expect(_richText('50 kcal'), findsOneWidget);

    await tester.enterText(servings, '2,5');
    await tester.pump();
    expect(_richText('250 kcal'), findsOneWidget);
  });

  testWidgets('servings outside 0.01 to 20 block saving', (tester) async {
    await tester.pumpWidget(_app(DishLogModal(dish: _soup())));

    await tester.enterText(
      find.byKey(const ValueKey('dish-log-servings')),
      '25',
    );
    await tester.pump();

    expect(find.text('Enter a value from 0.01 to 20'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    // The last valid portion stays in effect.
    expect(_richText('100 kcal'), findsOneWidget);
  });

  testWidgets('known dish weight allows entering grams', (tester) async {
    await tester.pumpWidget(
      _app(
        DishLogModal(
          dish: _soup(
            ingredients: const [
              Ingredient(id: 'a', name: 'Broth', amount: 300, unit: 'ml'),
              Ingredient(id: 'b', name: 'Noodles', amount: 100, unit: 'g'),
            ],
          ),
        ),
        locale: const Locale('de'),
      ),
    );

    await tester.ensureVisible(find.text('Gewicht'));
    await tester.tap(find.text('Gewicht'));
    await tester.pump();
    expect(find.text('1 Portion = 400 g'), findsOneWidget);
    final weight = find.byKey(const ValueKey('dish-log-weight'));
    expect(tester.widget<TextField>(weight).controller!.text, '400');

    await tester.enterText(weight, '100');
    await tester.pump();
    expect(_richText('25 kcal'), findsOneWidget);
    expect(_richText('2,5 g'), findsOneWidget);

    await tester.tap(find.text('Portionen'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('dish-log-servings')))
          .controller!
          .text,
      '0,25',
    );
  });

  testWidgets('editing an entry prefills it and saves the new portion', (
    tester,
  ) async {
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final service = DishService();
    await service.insertDishLogSnapshot(
      dishId: 'soup',
      dishName: 'Soup',
      loggedAt: DateTime(2026, 9, 20, 12, 30),
      mealType: 'lunch',
      servingSize: 2,
      calories: 200,
      protein: 10,
      carbs: 20,
      fat: 6,
      notes: 'spicy',
    );
    final log =
        (await service.getDishLogsForDate(DateTime(2026, 9, 20))).single;

    await tester.pumpWidget(
      _app(
        Builder(
          builder:
              (context) => TextButton(
                onPressed:
                    () => showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder:
                          (_) => DishLogModal(
                            dish: dishForLog(log, fallbackName: 'x'),
                            existingLog: log,
                            dishService: service,
                          ),
                    ),
                child: const Text('open'),
              ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Edit entry'), findsOneWidget);
    expect(find.text('spicy'), findsOneWidget);
    expect(_richText('200 kcal'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Fewer servings'));
    await tester.tap(find.byTooltip('Fewer servings'));
    await tester.pump();
    expect(_richText('175 kcal'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    final edited =
        (await service.getDishLogsForDate(DateTime(2026, 9, 20))).single;
    expect(edited.id, log.id);
    expect(edited.servingSize, 1.75);
    expect(edited.calories, 175);
    expect(edited.loggedAt, DateTime(2026, 9, 20, 12, 30));
    expect(edited.notes, 'spicy');
    expect(find.text('Entry updated'), findsOneWidget);
  });
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

  testWidgets('log sheet shows German decimal separators for nutrition', (
    tester,
  ) async {
    final now = DateTime.now();
    final dish = Dish(
      id: 'test-dish',
      name: 'Soup',
      ingredients: const [],
      nutrition: const NutritionInfo(
        calories: 100,
        protein: 30,
        carbs: 12.5,
        fat: 4.2,
      ),
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: DishLogModal(dish: dish)),
      ),
    );

    for (final value in ['30,0 g', '12,5 g', '4,2 g']) {
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText() == value,
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets(
    'unselected meal types remain readable and selectable in dark mode',
    (tester) async {
      final now = DateTime.now();
      final theme = ThemeData.dark();
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
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: DishLogModal(dish: dish)),
        ),
      );
      await tester.tap(find.text('Breakfast'));
      await tester.pump();

      expect(
        tester.widget<Icon>(find.byIcon(Icons.wb_sunny_outlined)).color,
        theme.colorScheme.onSurfaceVariant,
      );
      expect(
        tester.widget<Text>(find.text('Lunch')).style?.color,
        theme.colorScheme.onSurfaceVariant,
      );
      final lunchTile = tester.widget<Container>(
        find
            .ancestor(of: find.text('Lunch'), matching: find.byType(Container))
            .first,
      );
      expect(
        ((lunchTile.decoration as BoxDecoration).border as Border).top.color,
        theme.colorScheme.outline,
      );
      final lunchSemantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.text('Lunch'),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.selected != null,
          ),
        ),
      );
      expect(lunchSemantics.properties.button, isTrue);
      expect(lunchSemantics.properties.selected, isFalse);
      final breakfastSemantics = tester.widget<Semantics>(
        find.ancestor(
          of: find.text('Breakfast'),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.selected != null,
          ),
        ),
      );
      expect(breakfastSemantics.properties.selected, isTrue);
    },
  );

  testWidgets('calculated nutrition fills the sheet at large text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
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
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: DishLogModal(dish: dish)),
      ),
    );

    final nutritionBox =
        find
            .ancestor(
              of: find.text('Calories'),
              matching: find.byType(Container),
            )
            .first;
    expect(tester.getSize(nutritionBox).width, 280);
    final nutritionRow = tester.widget<Row>(
      find.descendant(of: nutritionBox, matching: find.byType(Row)),
    );
    expect(nutritionRow.children, hasLength(4));
    expect(nutritionRow.children, everyElement(isA<Expanded>()));
    expect(
      find.descendant(of: nutritionBox, matching: find.byType(FittedBox)),
      findsNWidgets(8),
    );
    expect(tester.takeException(), isNull);
  });
}
