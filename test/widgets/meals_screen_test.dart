import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/screens/meals_screen.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';

class _StubDishService extends DishService {
  _StubDishService(this.dishes);

  final List<Dish> dishes;
  int loadCount = 0;

  @override
  Future<List<Dish>> getAllDishes() async {
    loadCount++;
    return dishes;
  }
}

class _FailingDishService extends DishService {
  @override
  Future<List<Dish>> getAllDishes() async =>
      throw StateError('Private dish data');
}

void main() {
  testWidgets('meals load once and do not reload on locale changes', (
    tester,
  ) async {
    final service = _StubDishService([]);
    Widget screen(Locale locale) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MealsScreen(dishService: service),
    );

    await tester.pumpWidget(screen(const Locale('en')));
    await tester.pumpAndSettle();
    expect(service.loadCount, 1);

    await tester.pumpWidget(screen(const Locale('es')));
    await tester.pumpAndSettle();
    expect(service.loadCount, 1);
  });

  testWidgets('meal load failure shows localized guidance, not exception', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MealsScreen(dishService: _FailingDishService()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudieron cargar tus platos. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.textContaining('Private dish data'), findsNothing);
  });

  testWidgets('meals page has one primary create action and pullable content', (
    tester,
  ) async {
    final service = _StubDishService([]);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MealsScreen(dishService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No dishes created yet'), findsOneWidget);
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.actions, anyOf(isNull, isEmpty));
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Create Dish'), findsWidgets);

    final scrollViews = tester.widgetList<CustomScrollView>(
      find.byType(CustomScrollView),
    );
    expect(scrollViews, isNotEmpty);
    expect(
      scrollViews.every(
        (scrollView) => scrollView.physics is AlwaysScrollableScrollPhysics,
      ),
      isTrue,
    );

    final previousLoads = service.loadCount;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(service.loadCount, greaterThan(previousLoads));
  });

  testWidgets('first-run empty state offers scan and search too', (
    tester,
  ) async {
    for (final (locale, labels) in [
      (const Locale('en'), ['Create Dish', 'Scan barcode', 'Search food']),
      (
        const Locale('de'),
        ['Barcode scannen', 'Lebensmittel suchen'],
      ),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MealsScreen(dishService: _StubDishService([])),
        ),
      );
      await tester.pumpAndSettle();

      for (final label in labels) {
        expect(find.text(label), findsWidgets);
      }
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('short dish list stays refreshable and labels are localized', (
    tester,
  ) async {
    final now = DateTime.now();
    final service = _StubDishService([
      Dish(
        id: 'dish-1',
        name: 'Sopa',
        ingredients: const [],
        nutrition: const NutritionInfo(
          calories: 100,
          protein: 5,
          carbs: 8,
          fat: 2,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MealsScreen(dishService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SOPA'), findsOneWidget);
    expect(find.text('OTROS'), findsOneWidget);
    expect(find.text('Proteína'), findsOneWidget);

    final previousLoads = service.loadCount;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(service.loadCount, greaterThan(previousLoads));
  });

  testWidgets('dish card shows kcal for an English US locale', (tester) async {
    final now = DateTime.now();
    final service = _StubDishService([
      Dish(
        id: 'dish-1',
        name: 'Soup',
        ingredients: const [],
        nutrition: const NutritionInfo(
          calories: 100,
          protein: 5,
          carbs: 8,
          fat: 2,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MealsScreen(dishService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SOUP'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('kcal'), findsOneWidget);
    expect(find.text('Cal'), findsNothing);
  });
}
