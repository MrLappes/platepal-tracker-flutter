// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('creates a fresh, readable screenshot database and preferences', () async {
    final databaseFile = File(
      Platform.environment['DEMO_DB_OUT'] ?? '/tmp/platepal_demo/platepal.db',
    );
    final preferencesFile = File(
      '/tmp/platepal_demo/FlutterSharedPreferences.xml',
    );

    await seedDemoData(databaseFile, preferencesFile);

    expect(await databaseFile.exists(), isTrue);
    expect(await preferencesFile.exists(), isTrue);

    final database = await databaseFactoryFfiNoIsolate.openDatabase(
      databaseFile.path,
    );
    addTearDown(database.close);
    expect(await database.getVersion(), 4);

    Future<int> count(String table) async {
      final rows = await database.rawQuery(
        'SELECT COUNT(*) AS count FROM $table',
      );
      return rows.single['count'] as int;
    }

    expect(await count('user_profiles'), 1);
    expect(await count('fitness_goals'), 1);
    expect(await count('dishes'), 12);
    expect(await count('dish_nutrition'), 12);
    expect(await count('dish_logs'), 82);
    expect(await count('user_metrics_history'), 9);

    final favorites = await database.query(
      'dishes',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );
    expect(favorites, hasLength(4));
    expect(
      (await database.query('dishes', where: 'image_url IS NOT NULL')),
      isEmpty,
    );

    final days = await database.rawQuery('''
      SELECT substr(logged_at, 1, 10) AS day, COUNT(*) AS meals,
             SUM(calories) AS calories
      FROM dish_logs GROUP BY day ORDER BY day
    ''');
    expect(days, hasLength(21));
    for (final day in days.take(20)) {
      expect(day['meals'], 4);
      expect(
        (day['calories'] as num).toDouble(),
        inInclusiveRange(1827.5, 2472.5),
      );
    }
    expect(days.last['day'], DateTime.now().toIso8601String().substring(0, 10));
    expect(days.last['meals'], 2);
    final todayTypes = await database.query(
      'dish_logs',
      columns: ['meal_type'],
      where: 'substr(logged_at, 1, 10) = ?',
      whereArgs: [days.last['day']],
      orderBy: 'logged_at',
    );
    expect(todayTypes.map((row) => row['meal_type']), ['breakfast', 'lunch']);

    final metrics = await database.query(
      'user_metrics_history',
      orderBy: 'recorded_date',
    );
    expect(metrics.first['weight'], greaterThan(metrics.last['weight'] as num));
    expect(metrics.last['weight'], 76.0);
    expect(
      DateTime.now()
          .difference(DateTime.parse(metrics.first['recorded_date'] as String))
          .inDays,
      inInclusiveRange(55, 57),
    );

    final preferences = await preferencesFile.readAsString();
    expect(
      preferences,
      contains('name="flutter.current_user_id">alex-demo</string>'),
    );
    expect(
      preferences,
      contains('name="flutter.theme_preference">dark</string>'),
    );
    expect(preferences, contains('name="flutter.theme_name">Dark</string>'));
    expect(
      preferences,
      contains(
        'name="flutter.app_locale">${Platform.environment['DEMO_LOCALE'] ?? 'en'}</string>',
      ),
    );
  });
}

Future<void> seedDemoData(File databaseFile, File preferencesFile) async {
  final locale = Platform.environment['DEMO_LOCALE'] ?? 'en';
  if (!{'en', 'de', 'es'}.contains(locale)) {
    throw ArgumentError.value(locale, 'DEMO_LOCALE', 'Must be en, de, or es');
  }

  await databaseFile.parent.create(recursive: true);
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final oldFile = File('${databaseFile.path}$suffix');
    if (await oldFile.exists()) await oldFile.delete();
  }

  await DatabaseService.useFactoryForTesting(
    databaseFactoryFfiNoIsolate,
    path: databaseFile.path,
  );
  try {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const userId = 'alex-demo';
    final profileService = UserProfileService();
    await profileService.saveUserProfile(
      UserProfile(
        id: userId,
        name: 'Alex',
        email: 'alex@example.com',
        age: 30,
        gender: 'male',
        height: 178,
        weight: 76,
        activityLevel: 'moderately_active',
        goals: const FitnessGoals(
          goal: 'maintain_weight',
          targetWeight: 76,
          targetCalories: 2150,
          targetProtein: 140,
          targetCarbs: 235,
          targetFat: 72,
          targetFiber: 28,
        ),
        preferences: const DietaryPreferences(),
        createdAt: DateTime(today.year, today.month, today.day - 56),
        updatedAt: now,
      ),
    );

    final dishService = DishService();
    final dishes = <Dish>[
      _dish(
        'oats',
        'Overnight oats with berries',
        'breakfast',
        520,
        30,
        65,
        17,
        10,
        today,
        favorite: true,
        ingredients: const [
          ('Rolled oats', 65, 'g'),
          ('Greek yogurt', 120, 'g'),
          ('Blueberries', 80, 'g'),
          ('Chia seeds', 12, 'g'),
        ],
      ),
      _dish(
        'yogurt',
        'Greek yogurt bowl',
        'breakfast',
        410,
        32,
        48,
        12,
        7,
        today,
        ingredients: const [
          ('Greek yogurt', 250, 'g'),
          ('Banana', 80, 'g'),
          ('Granola', 40, 'g'),
          ('Strawberries', 70, 'g'),
        ],
      ),
      _dish(
        'burrito',
        'Chicken burrito bowl',
        'lunch',
        690,
        49,
        79,
        20,
        12,
        today,
        favorite: true,
        ingredients: const [
          ('Chicken breast', 140, 'g'),
          ('Brown rice', 160, 'g'),
          ('Black beans', 110, 'g'),
          ('Avocado', 60, 'g'),
          ('Salsa', 40, 'g'),
        ],
      ),
      _dish(
        'salmon',
        'Salmon with quinoa & greens',
        'dinner',
        735,
        48,
        65,
        32,
        10,
        today,
        favorite: true,
        ingredients: const [
          ('Salmon fillet', 160, 'g'),
          ('Quinoa', 170, 'g'),
          ('Broccoli', 120, 'g'),
          ('Spinach', 60, 'g'),
        ],
      ),
      _dish(
        'curry',
        'Lentil curry',
        'dinner',
        650,
        28,
        92,
        17,
        19,
        today,
        ingredients: const [
          ('Red lentils', 180, 'g'),
          ('Basmati rice', 130, 'g'),
          ('Tomatoes', 110, 'g'),
          ('Coconut milk', 70, 'ml'),
        ],
      ),
      _dish(
        'omelette',
        'Veggie omelette',
        'breakfast',
        440,
        31,
        15,
        29,
        5,
        today,
        ingredients: const [
          ('Eggs', 3, 'pcs'),
          ('Spinach', 60, 'g'),
          ('Mushrooms', 80, 'g'),
          ('Feta', 35, 'g'),
        ],
      ),
      _dish(
        'pancakes',
        'Protein pancakes',
        'breakfast',
        500,
        34,
        61,
        14,
        7,
        today,
        favorite: true,
        ingredients: const [
          ('Oat flour', 70, 'g'),
          ('Eggs', 2, 'pcs'),
          ('Cottage cheese', 90, 'g'),
          ('Raspberries', 80, 'g'),
        ],
      ),
      _dish(
        'caesar',
        'Caesar salad with chicken',
        'lunch',
        590,
        47,
        30,
        31,
        7,
        today,
        ingredients: const [
          ('Chicken breast', 140, 'g'),
          ('Romaine lettuce', 130, 'g'),
          ('Parmesan', 25, 'g'),
          ('Croutons', 35, 'g'),
        ],
      ),
      _dish(
        'bolognese',
        'Spaghetti bolognese',
        'dinner',
        740,
        47,
        86,
        23,
        9,
        today,
        ingredients: const [
          ('Whole-wheat spaghetti', 100, 'g'),
          ('Lean ground beef', 120, 'g'),
          ('Tomato sauce', 140, 'g'),
          ('Parmesan', 20, 'g'),
        ],
      ),
      _dish(
        'wrap',
        'Hummus & veggie wrap',
        'lunch',
        530,
        20,
        65,
        21,
        11,
        today,
        ingredients: const [
          ('Whole-wheat tortilla', 1, 'pcs'),
          ('Hummus', 90, 'g'),
          ('Cucumber', 80, 'g'),
          ('Carrot', 65, 'g'),
          ('Baby spinach', 45, 'g'),
        ],
      ),
      _dish(
        'tofu',
        'Tofu stir-fry',
        'dinner',
        660,
        34,
        78,
        24,
        12,
        today,
        ingredients: const [
          ('Firm tofu', 180, 'g'),
          ('Brown rice', 160, 'g'),
          ('Bell pepper', 100, 'g'),
          ('Broccoli', 110, 'g'),
        ],
      ),
      _dish(
        'smoothie',
        'Banana peanut butter smoothie',
        'snack',
        375,
        22,
        42,
        15,
        6,
        today,
        ingredients: const [
          ('Banana', 110, 'g'),
          ('Peanut butter', 25, 'g'),
          ('Milk', 230, 'ml'),
          ('Whey protein', 20, 'g'),
        ],
      ),
    ];
    for (final dish in dishes) {
      await dishService.saveDish(dish);
    }

    final breakfasts = [dishes[0], dishes[1], dishes[5], dishes[6]];
    final lunches = [dishes[2], dishes[7], dishes[9], dishes[10]];
    final dinners = [dishes[3], dishes[4], dishes[8], dishes[10]];
    final snack = dishes[11];
    for (var offset = 20; offset >= 0; offset--) {
      final day = DateTime(today.year, today.month, today.day - offset);
      final index = 20 - offset;
      final meals = <(Dish, String, int, int)>[
        (breakfasts[index % breakfasts.length], 'breakfast', 8, 10),
        (lunches[(index + 1) % lunches.length], 'lunch', 12, 35),
        if (offset != 0) ...[
          (dinners[(index + 2) % dinners.length], 'dinner', 19, 15),
          (snack, 'snack', 16, 10),
        ],
      ];
      for (final (dish, type, hour, minute) in meals) {
        final nutrition = dish.nutrition;
        await dishService.insertDishLogSnapshot(
          dishId: dish.id,
          dishName: dish.name,
          loggedAt: DateTime(day.year, day.month, day.day, hour, minute),
          mealType: type,
          servingSize: 1,
          calories: nutrition.calories,
          protein: nutrition.protein,
          carbs: nutrition.carbs,
          fat: nutrition.fat,
          fiber: nutrition.fiber,
        );
      }
    }

    final database = await DatabaseService.instance.database;
    for (var week = 8; week > 0; week--) {
      final date = DateTime(
        today.year,
        today.month,
        today.day - week * 7,
        7,
        30,
      );
      await database.insert('user_metrics_history', {
        'user_id': userId,
        'weight': 76.0 + week * 0.18 + (week.isEven ? 0.04 : -0.04),
        'height': 178.0,
        'body_fat': null,
        'recorded_date': date.toIso8601String(),
      });
    }

    await preferencesFile.parent.create(recursive: true);
    await preferencesFile.writeAsString(
      '''<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<map>
    <string name="flutter.current_user_id">$userId</string>
    <string name="flutter.theme_preference">dark</string>
    <string name="flutter.theme_name">Dark</string>
    <string name="flutter.app_locale">$locale</string>
</map>
''',
    );
    final logCount =
        (await database.rawQuery(
          'SELECT COUNT(*) AS count FROM dish_logs',
        )).single['count'];
    final metricCount =
        (await database.rawQuery(
          'SELECT COUNT(*) AS count FROM user_metrics_history',
        )).single['count'];
    stdout.writeln(
      'Demo data: ${dishes.length} dishes, $logCount logs over 21 days, $metricCount metrics',
    );
    stdout.writeln('Database: ${databaseFile.path}');
    stdout.writeln('Preferences: ${preferencesFile.path} ($locale)');
  } finally {
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
  }
}

Dish _dish(
  String id,
  String name,
  String category,
  double calories,
  double protein,
  double carbs,
  double fat,
  double fiber,
  DateTime today, {
  bool favorite = false,
  required List<(String, num, String)> ingredients,
}) => Dish(
  id: 'demo-$id',
  name: name,
  category: category,
  isFavorite: favorite,
  ingredients: [
    for (var index = 0; index < ingredients.length; index++)
      Ingredient(
        id: 'demo-$id-$index',
        name: ingredients[index].$1,
        amount: ingredients[index].$2.toDouble(),
        unit: ingredients[index].$3,
      ),
  ],
  nutrition: NutritionInfo(
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    fiber: fiber,
  ),
  createdAt: DateTime(today.year, today.month, today.day - 21),
  updatedAt: today,
);
