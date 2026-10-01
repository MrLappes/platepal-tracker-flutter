import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:platepal_tracker/components/calendar/macro_summary.dart';
import 'package:platepal_tracker/components/modals/dish_log_modal.dart';
import 'package:platepal_tracker/components/modals/log_food_sheet.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/screens/calendar_screen.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Dish _dish(
  String id,
  String name, {
  bool favorite = false,
  DateTime? updatedAt,
}) {
  final at = updatedAt ?? DateTime(2026, 1, 1);
  return Dish(
    id: id,
    name: name,
    ingredients: const [],
    nutrition: const NutritionInfo(
      calories: 120,
      protein: 4,
      carbs: 15,
      fat: 5,
    ),
    createdAt: at,
    updatedAt: at,
    isFavorite: favorite,
  );
}

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

Future<void> _log(
  DishService service,
  String name,
  DateTime at, {
  String mealType = 'lunch',
  double calories = 200,
}) => service.insertDishLogSnapshot(
  dishId: 'gone-$name',
  dishName: name,
  loggedAt: at,
  mealType: mealType,
  servingSize: 1,
  calories: calories,
  protein: 10,
  carbs: 20,
  fat: 5,
);

Future<void> _pumpCalendar(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CalendarScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late DishService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    service = DishService();
  });

  group('buildLogFoodSections', () {
    test('lists favorites, then up to ten recent dishes, then the rest', () {
      final dishes = [
        _dish('fav-old', 'Fav old', favorite: true),
        _dish('fav-new', 'Fav new', favorite: true, updatedAt: DateTime(2026, 5)),
        for (var i = 0; i < 12; i++) _dish('logged-$i', 'Logged $i'),
        _dish('never', 'Never logged', updatedAt: DateTime(2026, 3)),
      ];
      final lastLogged = {
        'fav-old': DateTime(2026, 6),
        for (var i = 0; i < 12; i++) 'logged-$i': DateTime(2026, 9, 1 + i),
        'quick_add:x': DateTime(2026, 9, 30),
      };

      final sections = buildLogFoodSections(dishes, lastLogged);

      expect(sections.favorites.map((d) => d.id), ['fav-old', 'fav-new']);
      expect(sections.recent.map((d) => d.id), [
        for (var i = 11; i >= 2; i--) 'logged-$i',
      ]);
      expect(sections.others.map((d) => d.id), [
        'logged-1',
        'logged-0',
        'never',
      ]);
    });
  });

  testWidgets('log food sheet groups favorites, recent and all dishes', (
    tester,
  ) async {
    await service.saveDish(_dish('fav', 'Favorite Soup', favorite: true));
    await service.saveDish(_dish('recent', 'Logged Soup'));
    await service.saveDish(_dish('other', 'Other Soup'));
    await service.insertDishLogSnapshot(
      dishId: 'recent',
      loggedAt: DateTime(2026, 9, 1, 12),
      mealType: 'lunch',
      servingSize: 1,
      calories: 120,
      protein: 4,
      carbs: 15,
      fat: 5,
    );

    await _pumpCalendar(tester);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Log food'));
    await tester.pumpAndSettle();

    final sheet = find.byType(LogFoodSheet);
    for (final text in [
      'FAVORITES',
      'RECENT',
      'ALL DISHES',
      'Quick add',
      'Scan barcode',
      'Search Open Food Facts',
    ]) {
      expect(
        find.descendant(of: sheet, matching: find.text(text)),
        findsOneWidget,
        reason: text,
      );
    }
    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('FAVORITES'), lessThan(top('Favorite Soup')));
    expect(top('Favorite Soup'), lessThan(top('RECENT')));
    expect(top('RECENT'), lessThan(top('Logged Soup')));
    expect(top('Logged Soup'), lessThan(top('ALL DISHES')));
    expect(top('ALL DISHES'), lessThan(top('Other Soup')));
  });

  testWidgets('a recent dish is logged in three taps', (tester) async {
    await service.saveDish(_dish('soup', 'Soup'));
    await _log(service, 'Old', DateTime(2026, 1, 1, 12));
    await service.insertDishLogSnapshot(
      dishId: 'soup',
      loggedAt: DateTime(2026, 1, 2, 12),
      mealType: 'lunch',
      servingSize: 1,
      calories: 120,
      protein: 4,
      carbs: 15,
      fat: 5,
    );
    await _pumpCalendar(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soup'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    final logs = await service.getDishLogsForDate(_today());
    expect(logs.single.dishName, 'Soup');
    expect(logs.single.servingSize, 1);
    expect(find.text('SOUP'), findsOneWidget);
  });

  testWidgets('quick add logs calories without creating a dish', (
    tester,
  ) async {
    await _pumpCalendar(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quick add'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pump();
    expect(find.text('Enter the calories'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Calories (kcal)'),
      '350',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Fat (g)'),
      '18,5',
    );
    await tester.tap(find.text('Snack'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    final log = (await service.getDishLogsForDate(_today())).single;
    expect(log.isQuickAdd, isTrue);
    expect(log.dishName, 'Quick add');
    expect(log.calories, 350);
    expect(log.fat, 18.5);
    expect(log.mealType, 'snack');
    expect(await service.getAllDishes(), isEmpty);
    expect(find.text('QUICK ADD'), findsOneWidget);
    expect(
      tester.widget<MacroSummary>(find.byType(MacroSummary)).calories,
      350,
    );
  });

  testWidgets('diary groups entries by localized meal type', (tester) async {
    await _log(service, 'Potaje', _today().add(const Duration(hours: 13)));

    await _pumpCalendar(tester, locale: const Locale('de'));

    for (final meal in ['FRÜHSTÜCK', 'MITTAGESSEN', 'ABENDESSEN', 'SNACK']) {
      expect(find.textContaining(meal), findsOneWidget, reason: meal);
    }
    expect(find.text('MITTAGESSEN  200 KCAL'), findsOneWidget);
    expect(find.text('Mittagessen'), findsOneWidget);
    expect(find.text('LUNCH'), findsNothing);
    expect(
      tester.getTopLeft(find.text('POTAJE')).dy,
      greaterThan(tester.getTopLeft(find.text('MITTAGESSEN  200 KCAL')).dy),
    );
    expect(
      tester.getTopLeft(find.text('POTAJE')).dy,
      lessThan(tester.getTopLeft(find.textContaining('ABENDESSEN')).dy),
    );
  });

  testWidgets('a meal is copied from the previous day', (tester) async {
    final yesterday = DateTime(
      _today().year,
      _today().month,
      _today().day - 1,
    );
    await _log(service, 'Porridge', yesterday.add(const Duration(hours: 8)),
        mealType: 'breakfast', calories: 300);
    await _log(service, 'Toast', yesterday.add(const Duration(hours: 9)),
        mealType: 'breakfast', calories: 150);
    await _log(service, 'Pasta', yesterday.add(const Duration(hours: 13)));
    await _pumpCalendar(tester);

    await tester.tap(find.byTooltip('Copy Dinner from the previous day'));
    await tester.pumpAndSettle();
    expect(find.text('The previous day has no Dinner entries'), findsOneWidget);

    await tester.tap(find.byTooltip('Copy Breakfast from the previous day'));
    await tester.pumpAndSettle();

    expect(find.text('2 entries copied'), findsOneWidget);
    expect(find.text('PORRIDGE'), findsOneWidget);
    expect(find.text('TOAST'), findsOneWidget);
    expect(find.text('PASTA'), findsNothing);
    expect(
      tester.widget<MacroSummary>(find.byType(MacroSummary)).calories,
      450,
    );
  });

  testWidgets('tapping an entry edits it and updates the totals', (
    tester,
  ) async {
    await _log(service, 'Stew', _today().add(const Duration(hours: 19)),
        mealType: 'dinner');
    await _pumpCalendar(tester);

    await tester.tap(find.text('STEW'));
    await tester.pumpAndSettle();
    expect(find.byType(DishLogModal), findsOneWidget);
    expect(find.text('Edit entry'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('dish-log-servings')),
      '1.5',
    );
    await tester.tap(find.text('Lunch'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    final log = (await service.getDishLogsForDate(_today())).single;
    expect(log.calories, 300);
    expect(log.mealType, 'lunch');
    expect(
      tester.widget<MacroSummary>(find.byType(MacroSummary)).calories,
      300,
    );
    expect(find.text('LUNCH  300 KCAL'), findsOneWidget);
  });

  testWidgets('an entry is copied to today from its menu', (tester) async {
    final lastWeek = DateTime(_today().year, _today().month, _today().day - 7);
    await _log(service, 'Curry', lastWeek.add(const Duration(hours: 20)),
        mealType: 'dinner');
    await _pumpCalendar(tester);
    expect(await service.getDishLogsForDate(_today()), isEmpty);

    final semantics = tester.ensureSemantics();
    await tester.tap(find.byTooltip('Previous page'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.bySemanticsLabel(
        RegExp(DateFormat.yMMMMEEEEd('en').format(lastWeek)),
      ),
    );
    await tester.pumpAndSettle();
    semantics.dispose();
    expect(find.text('CURRY'), findsOneWidget);

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy to today'));
    await tester.pumpAndSettle();

    expect(find.text('1 entry copied'), findsOneWidget);
    final copy = (await service.getDishLogsForDate(_today())).single;
    expect(copy.dishName, 'Curry');
    expect(copy.loggedAt, _today().add(const Duration(hours: 20)));
    expect(
      await service.getDishLogsForDate(lastWeek),
      hasLength(1),
    );
  });
}
