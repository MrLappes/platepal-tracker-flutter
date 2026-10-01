import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:platepal_tracker/components/chat/message_bubble.dart';
import 'package:platepal_tracker/components/modals/dish_log_modal.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/chat_message.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/models/dish_models.dart';
import 'package:platepal_tracker/screens/dish_create_screen.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  testWidgets('failed message retry is a full-size button', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MessageBubble(
            message: ChatMessage(
              id: 'failed',
              content: 'Try again',
              sender: MessageSender.user,
              status: MessageStatus.failed,
              timestamp: DateTime(2026, 9, 1),
            ),
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    final retry = find.widgetWithText(TextButton, 'Retry');
    expect(retry, findsOneWidget);
    expect(tester.getSize(retry).height, greaterThanOrEqualTo(48));
    await tester.tap(retry);
    expect(retries, 1);
  });

  ChatMessage failedWith(String kind) => ChatMessage(
    id: 'failed-$kind',
    content: 'Hi',
    sender: MessageSender.user,
    status: MessageStatus.failed,
    timestamp: DateTime(2026, 9, 1),
    metadata: {'errorKind': kind},
  );

  testWidgets('rejected key explains the problem and opens key settings', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) => Scaffold(
                body: MessageBubble(message: failedWith('auth'), onRetry: () {}),
              ),
        ),
        GoRoute(
          path: '/settings/api-key',
          builder: (context, state) => const Text('KEY SETTINGS'),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    expect(
      find.text('Your API key was rejected. Check it in the API key settings.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Retry'), findsOneWidget);
    final settings = find.widgetWithText(TextButton, 'API key settings');
    expect(tester.getSize(settings).height, greaterThanOrEqualTo(48));
    await tester.tap(settings);
    await tester.pumpAndSettle();
    expect(find.text('KEY SETTINGS'), findsOneWidget);
  });

  testWidgets('each error kind shows its own localized guidance', (
    tester,
  ) async {
    Future<void> pump(String kind, Locale locale) => tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MessageBubble(message: failedWith(kind), onRetry: () {}),
        ),
      ),
    );

    await pump('rateLimit', const Locale('en'));
    expect(find.textContaining('rate limit or quota'), findsOneWidget);
    expect(find.text('API key settings'), findsNothing);

    await pump('network', const Locale('de'));
    expect(find.textContaining('Internetverbindung'), findsOneWidget);

    await pump('server', const Locale('es'));
    expect(find.textContaining('no está disponible'), findsOneWidget);

    await pump('keyUnreadable', const Locale('en'));
    expect(find.text('API key settings'), findsOneWidget);
  });

  testWidgets('answers built from incomplete data carry a note', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MessageBubble(
            message: ChatMessage(
              id: 'answer',
              content: 'Eat oats.',
              sender: MessageSender.assistant,
              timestamp: DateTime(2026, 9, 1),
              metadata: {
                'responseNotes': ['contextIncomplete', 'imageNotAnalyzed'],
              },
            ),
          ),
        ),
      ),
    );

    expect(
      find.text(
        "Some of your data couldn't be loaded; the answer may be less personal.",
      ),
      findsOneWidget,
    );
    expect(find.text("The image couldn't be analyzed."), findsOneWidget);
  });

  testWidgets('invalid suggested dish shows an error and retry action', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MessageBubble(
            message: ChatMessage(
              id: 'malformed',
              content: 'Suggestion',
              sender: MessageSender.assistant,
              timestamp: DateTime(2026, 9, 1),
              metadata: {
                'dishesProcessed': {
                  'validatedDishes': [
                    {'id': 'incomplete'},
                  ],
                },
              },
            ),
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(find.text('Error loading dishes'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Retry'));
    expect(retries, 1);
  });

  testWidgets('failed suggestion lookup blocks create navigation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final db = await DatabaseService.instance.database;
    await db.execute('DROP TABLE dishes');
    final createdAt = DateTime(2026, 9, 1);
    final suggestion = ProcessedDish(
      id: 'not-verified',
      name: 'Salad',
      ingredients: const [],
      totalNutrition: const BasicNutrition(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
      ),
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MessageBubble(
              message: ChatMessage(
                id: 'suggestion',
                content: 'Try this',
                sender: MessageSender.assistant,
                timestamp: createdAt,
                metadata: {
                  'dishesProcessed': {
                    'validatedDishes': [suggestion.toJson()],
                  },
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Dish'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(DishCreateScreenAdvanced), findsNothing);
    expect(find.text('Error loading dishes'), findsOneWidget);
  });

  testWidgets('logging a suggested dish saves its ID before opening the log', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final dishService = DishService();
    final createdAt = DateTime(2026, 9, 1);
    await dishService.saveDish(
      Dish(
        id: 'existing-rice',
        name: 'Rice bowl',
        ingredients: const [],
        nutrition: const NutritionInfo(
          calories: 150,
          protein: 4,
          carbs: 30,
          fat: 2,
        ),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
    final suggestion = ProcessedDish(
      id: 'ai-rice',
      name: 'Rice bowl',
      ingredients: const [],
      totalNutrition: const BasicNutrition(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
      ),
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MessageBubble(
              message: ChatMessage(
                id: 'suggestion',
                content: 'Try this dish',
                sender: MessageSender.assistant,
                timestamp: createdAt,
                metadata: {
                  'dishesProcessed': {
                    'validatedDishes': [suggestion.toJson()],
                  },
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(await dishService.getDishById('ai-rice'), isNull);

    await tester.tap(find.text('Log Dish'));
    await tester.pumpAndSettle();

    expect(find.byType(DishLogModal), findsOneWidget);
    expect((await dishService.getDishById('ai-rice'))?.name, 'Rice bowl');
    expect((await dishService.getDishById('existing-rice'))?.name, 'Rice bowl');
  });

  testWidgets('failed suggested dish save shows a localized error, not a log', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final dishService = DishService();
    final createdAt = DateTime(2026, 9, 1);
    await dishService.saveDish(
      Dish(
        id: 'existing-rice',
        name: 'Rice bowl',
        ingredients: const [],
        nutrition: const NutritionInfo(
          calories: 150,
          protein: 4,
          carbs: 30,
          fat: 2,
        ),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
    final db = await DatabaseService.instance.database;
    await db.execute('''
      CREATE TRIGGER reject_ai_dish BEFORE INSERT ON dishes
      WHEN NEW.id = 'ai-fail'
      BEGIN SELECT RAISE(ABORT, 'storage full'); END
    ''');
    final suggestion = ProcessedDish(
      id: 'ai-fail',
      name: 'Rice bowl',
      ingredients: const [],
      totalNutrition: const BasicNutrition(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
      ),
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MessageBubble(
              message: ChatMessage(
                id: 'suggestion',
                content: 'Prueba este plato',
                sender: MessageSender.assistant,
                timestamp: createdAt,
                metadata: {
                  'dishesProcessed': {
                    'validatedDishes': [suggestion.toJson()],
                  },
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Registrar Plato'));
    await tester.pumpAndSettle();

    expect(find.byType(DishLogModal), findsNothing);
    expect(find.text('Error al guardar el plato'), findsOneWidget);
    expect(await dishService.getDishById('ai-fail'), isNull);
  });

  testWidgets('logging an existing ID displays its stored nutrition', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    final dishService = DishService();
    final createdAt = DateTime(2026, 9, 1);
    await dishService.saveDish(
      Dish(
        id: 'ai-rice',
        name: 'Rice bowl',
        ingredients: const [],
        nutrition: const NutritionInfo(
          calories: 150,
          protein: 4,
          carbs: 30,
          fat: 2,
        ),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
    final suggestion = ProcessedDish(
      id: 'ai-rice',
      name: 'Rice bowl',
      ingredients: const [],
      totalNutrition: const BasicNutrition(
        calories: 200,
        protein: 5,
        carbs: 35,
        fat: 3,
      ),
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MessageBubble(
              message: ChatMessage(
                id: 'suggestion',
                content: 'Try this dish',
                sender: MessageSender.assistant,
                timestamp: createdAt,
                metadata: {
                  'dishesProcessed': {
                    'validatedDishes': [suggestion.toJson()],
                  },
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Log Dish'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<DishLogModal>(find.byType(DishLogModal))
          .dish
          .nutrition
          .calories,
      150,
    );
    expect((await dishService.getDishById('ai-rice'))?.nutrition.calories, 150);
  });

  testWidgets('message time and date follow the German locale', (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(alwaysUse24HourFormat: true),
            child: Column(
              children: [
                MessageBubble(
                  message: ChatMessage(
                    id: 'today',
                    content: 'Heute',
                    sender: MessageSender.user,
                    timestamp: DateTime(now.year, now.month, now.day, 13, 5),
                  ),
                ),
                MessageBubble(
                  message: ChatMessage(
                    id: 'past',
                    content: 'Früher',
                    sender: MessageSender.user,
                    timestamp: DateTime(2020, 3, 24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('13:05'), findsOneWidget);
    expect(find.text('24. März'), findsOneWidget);
  });
}
