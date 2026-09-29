import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/chat/message_bubble.dart';
import 'package:platepal_tracker/components/modals/dish_log_modal.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/chat_message.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/models/dish_models.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

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
