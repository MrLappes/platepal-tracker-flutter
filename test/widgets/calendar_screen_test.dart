import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:platepal_tracker/components/calendar/calendar_dish_picker.dart';
import 'package:platepal_tracker/components/calendar/macro_summary.dart';
import 'package:platepal_tracker/components/modals/dish_log_modal.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/screens/calendar_screen.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  testWidgets('calendar offers profile setup above summary without a profile', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final prompt = find.text('Set up your profile to get daily targets');
    expect(prompt, findsOneWidget);
    expect(find.text('Set up profile'), findsOneWidget);
    expect(
      tester.getTopLeft(prompt).dy,
      lessThan(tester.getTopLeft(find.byType(MacroSummary)).dy),
    );
  });

  testWidgets('profile load failure shows an error instead of the setup nudge', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final db = await DatabaseService.instance.database;
    await db.execute('DROP TABLE user_profiles');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("Your profile couldn't be loaded, so daily targets aren't shown."),
      findsOneWidget,
    );
    expect(find.text('Set up your profile to get daily targets'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
  });

  testWidgets('calendar navigation exposes localized button actions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in [
      'Previous month',
      'Next month',
      'Previous page',
      'Next page',
    ]) {
      expect(find.byTooltip(label), findsOneWidget);
      expect(
        tester.getSize(find.byTooltip(label)).height,
        greaterThanOrEqualTo(48),
      );
    }
    final today = find.bySemanticsLabel('Today');
    expect(today, findsOneWidget);
    expect(tester.getSemantics(today).flagsCollection.isButton, isTrue);
    expect(
      tester.getSemantics(today).getSemanticsData().hasAction(
        SemanticsAction.tap,
      ),
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('calendar prompts when saved profile has no calorie target', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final now = DateTime.now();
    await UserProfileService().saveUserProfile(
      UserProfile(
        id: 'default',
        name: 'Test',
        email: 'test@example.com',
        age: 30,
        gender: 'other',
        height: 170,
        weight: 70,
        activityLevel: 'moderately_active',
        goals: const FitnessGoals(
          goal: 'maintain_weight',
          targetWeight: 70,
          targetCalories: 0,
          targetProtein: 100,
          targetCarbs: 200,
          targetFat: 60,
          targetFiber: 25,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Set up your profile to get daily targets'),
      findsOneWidget,
    );
    expect(
      tester.widget<MacroSummary>(find.byType(MacroSummary)).calorieTarget,
      isNull,
    );
  });

  testWidgets('calendar refreshes profile targets after returning from setup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const CalendarScreen()),
        GoRoute(
          path: '/settings/profile',
          builder:
              (context, state) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    await UserProfileService().saveUserProfile(
                      UserProfile(
                        id: 'default',
                        name: 'Test',
                        email: 'test@example.com',
                        age: 30,
                        gender: 'other',
                        height: 170,
                        weight: 70,
                        activityLevel: 'moderately_active',
                        goals: const FitnessGoals(
                          goal: 'maintain_weight',
                          targetWeight: 70,
                          targetCalories: 1800,
                          targetProtein: 100,
                          targetCarbs: 200,
                          targetFat: 60,
                          targetFiber: 25,
                        ),
                        createdAt: now,
                        updatedAt: now,
                      ),
                    );
                    if (context.mounted) context.pop();
                  },
                  child: const Text('Save test profile'),
                ),
              ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Set up your profile to get daily targets'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Set up profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save test profile'));
    await tester.pumpAndSettle();

    expect(find.text('Set up your profile to get daily targets'), findsNothing);
    expect(
      tester.widget<MacroSummary>(find.byType(MacroSummary)).calorieTarget,
      1800,
    );
  });

  testWidgets('calendar picker filters dish names case insensitively', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final now = DateTime.now();
    final service = DishService();
    for (final (id, name) in [('soup', 'Tomato Soup'), ('salad', 'Salad')]) {
      await service.saveDish(
        Dish(
          id: id,
          name: name,
          ingredients: const [],
          nutrition: const NutritionInfo(
            calories: 120,
            protein: 4,
            carbs: 15,
            fat: 5,
          ),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Tomato Soup'), findsOneWidget);
    expect(find.text('Salad'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'sOuP');
    await tester.pumpAndSettle();
    expect(find.text('Tomato Soup'), findsOneWidget);
    expect(find.text('Salad'), findsNothing);
  });

  testWidgets('calendar picker lists favorites then recently logged dishes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final service = DishService();
    for (final (id, name, updatedAt, favorite) in [
      ('older', 'Updated Soup', DateTime(2026, 9, 15), false),
      ('recent', 'Logged Soup', DateTime(2026, 9, 1), false),
      ('favorite', 'Favorite Soup', DateTime(2026, 8, 1), true),
    ]) {
      await service.saveDish(
        Dish(
          id: id,
          name: name,
          ingredients: const [],
          nutrition: const NutritionInfo(
            calories: 120,
            protein: 4,
            carbs: 15,
            fat: 5,
          ),
          createdAt: DateTime(2026, 7, 1),
          updatedAt: updatedAt,
          isFavorite: favorite,
        ),
      );
    }
    await service.insertDishLogSnapshot(
      dishId: 'recent',
      loggedAt: DateTime(2026, 9, 20, 12),
      mealType: 'lunch',
      servingSize: 1,
      calories: 120,
      protein: 4,
      carbs: 15,
      fat: 5,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final tiles = tester.widgetList<ListTile>(
      find.descendant(
        of: find.byType(CalendarDishPicker),
        matching: find.byType(ListTile),
      ),
    );
    expect(tiles.map((tile) => (tile.title! as Text).data).toList(), [
      'Favorite Soup',
      'Logged Soup',
      'Updated Soup',
    ]);
    expect(find.text('120 kcal per serving'), findsNWidgets(3));
  });

  testWidgets('empty calendar day offers the same quick-log picker', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final quickLog = find.widgetWithText(TextButton, 'Log meal');
    expect(quickLog, findsOneWidget);
    await tester.ensureVisible(quickLog);
    await tester.tap(quickLog);
    await tester.pumpAndSettle();
    expect(find.text('No dishes created yet'), findsOneWidget);
    expect(find.text('Create Dish'), findsOneWidget);
  });

  testWidgets('empty picker create action opens dish creation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const CalendarScreen()),
        GoRoute(
          path: '/dishes/create',
          builder:
              (context, state) =>
                  const Scaffold(body: Text('Dish editor route')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Create Dish'));
    await tester.pumpAndSettle();

    expect(find.text('Dish editor route'), findsOneWidget);
  });

  testWidgets('quick log preselects the selected calendar day', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day - 1,
    );
    final now = DateTime.now();
    await DishService().saveDish(
      Dish(
        id: 'soup',
        name: 'Soup',
        ingredients: const [],
        nutrition: const NutritionInfo(
          calories: 120,
          protein: 4,
          carbs: 15,
          fat: 5,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final semantics = tester.ensureSemantics();
    await tester.tap(
      find.bySemanticsLabel(
        RegExp(DateFormat.yMMMMEEEEd('en').format(selectedDate)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soup'));
    await tester.pumpAndSettle();

    expect(find.byType(DishLogModal), findsOneWidget);
    expect(
      find.text(
        MaterialLocalizations.of(
          tester.element(find.byType(DishLogModal)),
        ).formatCompactDate(selectedDate),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('quick log refreshes calendar totals and day marker after save', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day - 1,
    );
    final now = DateTime.now();
    final service = DishService();
    await service.saveDish(
      Dish(
        id: 'soup',
        name: 'Soup',
        ingredients: const [],
        nutrition: const NutritionInfo(
          calories: 120,
          protein: 4,
          carbs: 15,
          fat: 5,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final semantics = tester.ensureSemantics();
    await tester.tap(
      find.bySemanticsLabel(
        RegExp(DateFormat.yMMMMEEEEd('en').format(selectedDate)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Soup'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await tester.pumpAndSettle();

    final logs = await service.getDishLogsForDate(selectedDate);
    expect(logs.single.dishName, 'Soup');
    expect(find.text('SOUP'), findsOneWidget);
    expect(
      tester.widget<MacroSummary>(find.byType(MacroSummary)).calories,
      120,
    );
    expect(find.bySemanticsLabel(RegExp('has meals logged')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('adjacent-month logs appear in a Monday-first week', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final now = DateTime.now();
    var monthsAhead = 1;
    var firstOfMonth = DateTime(now.year, now.month + monthsAhead);
    while (firstOfMonth.weekday != DateTime.sunday) {
      monthsAhead++;
      firstOfMonth = DateTime(now.year, now.month + monthsAhead);
    }
    final previousMonthDay = DateTime(firstOfMonth.year, firstOfMonth.month, 0);
    final db = await DatabaseService.instance.database;
    await db.insert('dish_logs', {
      'id': 'boundary-log',
      'dish_id': 'deleted-dish',
      'dish_name': 'Potaje',
      'logged_at':
          DateTime(
            previousMonthDay.year,
            previousMonthDay.month,
            previousMonthDay.day,
            12,
          ).toIso8601String(),
      'meal_type': 'lunch',
      'serving_size': 1.0,
      'calories': 200.0,
      'protein': 10.0,
      'carbs': 25.0,
      'fat': 5.0,
    });

    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CalendarScreen(),
      ),
    );
    await tester.pumpAndSettle();
    for (var month = 0; month < monthsAhead; month++) {
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
    }

    expect(
      find.bySemanticsLabel(RegExp('Mahlzeiten eingetragen')),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel(RegExp('Mahlzeiten eingetragen')));
    await tester.pumpAndSettle();
    expect(find.text('POTAJE'), findsOneWidget);
    expect(
      tester.getSize(find.byTooltip('Protokoll löschen')).width,
      greaterThanOrEqualTo(48),
    );
    semantics.dispose();
  });

  testWidgets('health data info has a full-size localized button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: MacroSummary(
            calories: 200,
            protein: 10,
            carbs: 25,
            fat: 5,
            caloriesBurned: 100,
            isCaloriesBurnedEstimated: false,
            isCollapsible: true,
          ),
        ),
      ),
    );

    final infoButton = find.byIcon(Icons.info_outline);
    expect(tester.getSize(infoButton).width, 16);
    expect(
      tester
          .getSize(
            find
                .ancestor(of: infoButton, matching: find.byType(IconButton))
                .first,
          )
          .width,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(infoButton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('calorie progress compares intake with its target, not burn', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: MacroSummary(
            calories: 800,
            protein: 10,
            carbs: 25,
            fat: 5,
            calorieTarget: 2000,
            caloriesBurned: 300,
            isCollapsible: true,
          ),
        ),
      ),
    );

    expect(find.text('800 / 2000'), findsOneWidget);
    final calorieBar = tester.widget<FractionallySizedBox>(
      find
          .descendant(
            of: find.byType(MacroSummary),
            matching: find.byType(FractionallySizedBox),
          )
          .first,
    );
    expect(calorieBar.widthFactor, closeTo(0.4, 0.001));
  });
}
