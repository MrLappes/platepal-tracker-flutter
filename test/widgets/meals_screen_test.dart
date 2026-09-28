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

void main() {
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
    expect(find.byType(FloatingActionButton), findsOneWidget);
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
}
