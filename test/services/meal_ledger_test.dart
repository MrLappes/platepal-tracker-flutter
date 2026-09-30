import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:platepal_tracker/services/storage/meal_log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Dish _dish({String id = 'oats', String name = 'Oats', bool favorite = false}) {
  final now = DateTime(2026, 1, 1);
  return Dish(
    id: id,
    name: name,
    ingredients: const [
      Ingredient(id: 'ing-oat', name: 'Oat flakes', amount: 50, unit: 'g'),
      Ingredient(id: 'ing-milk', name: 'Milk', amount: 200, unit: 'ml'),
    ],
    nutrition: const NutritionInfo(
      calories: 200,
      protein: 10,
      carbs: 30,
      fat: 5,
      fiber: 4,
    ),
    createdAt: now,
    updatedAt: now,
    isFavorite: favorite,
  );
}

Future<int> _count(Database db, String table, [String? dishId]) async {
  final rows = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM $table'
    '${dishId == null ? '' : ' WHERE dish_id = ?'}',
    dishId == null ? const [] : [dishId],
  );
  return rows.first['c'] as int;
}

/// Local days in [year] that are not 24 hours long (DST changes).
List<DateTime> _dstDays(int year) => [
  for (
    var d = DateTime(year, 1, 1);
    d.year == year;
    d = DateTime(d.year, d.month, d.day + 1)
  )
    if (DateTime(d.year, d.month, d.day + 1).difference(d) !=
        const Duration(days: 1))
      d,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late DishService dishService;
  late MealLogService mealLogService;

  setUp(() async {
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    dishService = DishService();
    mealLogService = MealLogService();
  });

  group('dish_logs is the single meal ledger', () {
    test('dish debug output omits dish and ingredient names', () async {
      final messages = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) messages.add(message);
      };
      addTearDown(() => debugPrint = originalDebugPrint);

      await dishService.saveDish(_dish());
      await dishService.getDishById('oats');

      expect(messages, isNotEmpty);
      final output = messages.join('\n');
      expect(output, isNot(contains('Oats')));
      expect(output, isNot(contains('Oat flakes')));
      expect(output, isNot(contains('Milk')));
      expect(output, isNot(contains('amount:')));
    });

    test('a dish logged via logDish appears in the day summary', () async {
      await dishService.saveDish(_dish());
      final day = DateTime(2026, 9, 20);
      await dishService.logDish(
        dishId: 'oats',
        loggedAt: DateTime(2026, 9, 20, 12, 30),
        mealType: 'lunch',
        servingSize: 1.5,
        notes: '  with honey ',
      );
      // Exactly at the next midnight: belongs to the next day only.
      await dishService.logDish(
        dishId: 'oats',
        loggedAt: DateTime(2026, 9, 21),
        mealType: 'breakfast',
        servingSize: 1,
      );

      final summary = await mealLogService.getNutritionSummary(
        userId: 'any',
        startDate: day,
        endDate: day.add(const Duration(days: 1)),
      );

      expect(summary.mealLogs, hasLength(1));
      expect(summary.totalCalories, closeTo(300, 1e-9));
      expect(summary.totalProtein, closeTo(15, 1e-9));
      expect(summary.totalFiber, closeTo(6, 1e-9));
      expect(summary.mealsByType['lunch'], hasLength(1));
      final meal = summary.mealLogs.single;
      expect(meal.dish.name, 'Oats');
      expect(
        meal.dish.nutrition.calories * meal.servingSize,
        closeTo(300, 1e-9),
      );

      final logs = await dishService.getDishLogsForDate(day);
      expect(logs.single.dishName, 'Oats');
      expect(logs.single.notes, 'with honey');
    });

    test('recent dish log times use the newest log for each dish', () async {
      await dishService.saveDish(_dish());
      await dishService.saveDish(_dish(id: 'eggs', name: 'Eggs'));
      for (final (dishId, day) in [('oats', 19), ('oats', 21), ('eggs', 20)]) {
        await dishService.insertDishLogSnapshot(
          dishId: dishId,
          loggedAt: DateTime(2026, 9, day, 12),
          mealType: 'lunch',
          servingSize: 1,
          calories: 200,
          protein: 10,
          carbs: 30,
          fat: 5,
        );
      }

      final recent = await dishService.getLastLoggedAtByDish();
      expect(recent, {
        'oats': DateTime(2026, 9, 21, 12),
        'eggs': DateTime(2026, 9, 20, 12),
      });
    });

    test(
      'daily nutrition totals group local ledger days in a half-open range',
      () async {
        for (final (date, calories, protein) in [
          (DateTime(2025, 12, 31, 23, 30), 90.0, 9.0),
          (DateTime(2026, 1, 1), 100.0, 10.0),
          (DateTime(2026, 1, 1, 20), 200.0, 20.0),
          (DateTime(2026, 1, 2), 400.0, 40.0),
        ]) {
          await dishService.insertDishLogSnapshot(
            dishId: 'deleted-dish',
            loggedAt: date,
            mealType: 'lunch',
            servingSize: 1,
            calories: calories,
            protein: protein,
            carbs: calories / 10,
            fat: calories / 20,
            fiber: calories / 50,
          );
        }

        final acrossYears = await dishService.getDailyNutritionTotals(
          DateTime(2025, 12, 31),
          DateTime(2026, 1, 2),
        );
        expect(acrossYears.keys, ['2025-12-31', '2026-01-01']);
        expect(acrossYears['2025-12-31']!.calories, 90);
        expect(acrossYears['2026-01-01']!.calories, 300);

        final totals = await dishService.getDailyNutritionTotals(
          DateTime(2026, 1, 1, 12),
          DateTime(2026, 1, 2),
        );

        expect(totals.keys, ['2026-01-01']);
        expect(totals['2026-01-01']!.calories, 300);
        expect(totals['2026-01-01']!.protein, 30);
        expect(totals['2026-01-01']!.carbs, 30);
        expect(totals['2026-01-01']!.fat, 15);
        expect(totals['2026-01-01']!.fiber, 6);
      },
    );

    test('logMeal writes one ledger row and returns its rowid', () async {
      await dishService.saveDish(_dish());
      final at = DateTime.utc(2026, 9, 20, 10);

      final rowId = await mealLogService.logMeal(
        userId: 'u',
        dishId: 'oats',
        servingSize: 1,
        mealType: 'lunch',
        loggedAt: at,
      );

      final db = await DatabaseService.instance.database;
      expect(await _count(db, 'dish_logs'), 1);
      expect(await _count(db, 'meal_logs'), 0);

      await mealLogService.deleteMealLog(rowId);
      expect(await _count(db, 'dish_logs'), 0);
    });

    test('deleting a dish keeps its logs and removes child rows', () async {
      await dishService.saveDish(_dish());
      final day = DateTime(2026, 9, 20);
      await dishService.logDish(
        dishId: 'oats',
        loggedAt: DateTime(2026, 9, 20, 8),
        mealType: 'breakfast',
        servingSize: 2,
      );

      await dishService.deleteDish('oats');

      final db = await DatabaseService.instance.database;
      expect(await _count(db, 'dishes'), 0);
      expect(await _count(db, 'dish_nutrition', 'oats'), 0);
      expect(await _count(db, 'dish_ingredients', 'oats'), 0);

      final meals = await mealLogService.getMealsByDate(userId: 'u', date: day);
      expect(meals, hasLength(1));
      expect(meals.single.dish.name, 'Oats');
      expect(
        meals.single.dish.nutrition.calories * meals.single.servingSize,
        closeTo(400, 1e-9),
      );
      final summary = await mealLogService.getNutritionSummary(
        userId: 'u',
        startDate: day,
        endDate: day.add(const Duration(days: 1)),
      );
      expect(summary.totalCalories, closeTo(400, 1e-9));
    });

    test('toggling favorite never duplicates ingredient links', () async {
      await dishService.saveDish(_dish());
      for (var i = 0; i < 5; i++) {
        await dishService.setFavorite('oats', i.isEven);
      }
      // saveDish itself is idempotent too (old favorite path, re-saves).
      await dishService.saveDish(_dish(favorite: true));
      await dishService.saveDish(_dish(favorite: true));

      final db = await DatabaseService.instance.database;
      expect(await _count(db, 'dish_ingredients', 'oats'), 2);
      final dish = await dishService.getDishById('oats');
      expect(dish!.isFavorite, isTrue);
      expect(dish.ingredients, hasLength(2));
    });

    final dstDays = _dstDays(2026);
    test('day queries end at the next local midnight on DST days', () async {
      SharedPreferences.setMockInitialValues({});
      await dishService.saveDish(_dish());
      for (final day in dstDays) {
        await dishService.logDish(
          dishId: 'oats',
          loggedAt: DateTime(day.year, day.month, day.day, 23, 30),
          mealType: 'dinner',
          servingSize: 1,
        );
        await dishService.logDish(
          dishId: 'oats',
          loggedAt: DateTime(day.year, day.month, day.day + 1, 0, 30),
          mealType: 'breakfast',
          servingSize: 1,
        );
      }

      for (final day in dstDays) {
        final logs = await dishService.getDishLogsForDate(day);
        expect(logs.map((l) => l.mealType), ['dinner'], reason: '$day');
        final meals = await mealLogService.getMealsByDate(
          userId: 'u',
          date: day,
        );
        expect(meals.map((m) => m.mealType), ['dinner'], reason: '$day');
        final macros = await dishService.getMacroSummaryForDate(day);
        expect(macros.calories, closeTo(200, 1e-9), reason: '$day');
      }
    }, skip: dstDays.isEmpty ? 'local time zone has no DST' : false);
  });

  group('v3 -> v4 migration', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('platepal_migration');
    });

    tearDown(() async {
      await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
      await tempDir.delete(recursive: true);
    });

    test('backfills meal_logs into dish_logs and dedupes links', () async {
      final path = p.join(tempDir.path, 'v3.db');
      final v3 = await databaseFactoryFfiNoIsolate.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: (db, _) async {
            for (final sql in _v3Schema) {
              await db.execute(sql);
            }
          },
        ),
      );
      await _seedV3(v3);
      await v3.close();

      await DatabaseService.useFactoryForTesting(
        databaseFactoryFfiNoIsolate,
        path: path,
      );
      final db = await DatabaseService.instance.database;
      expect(await db.getVersion(), 4);

      final logs = {
        for (final row in await db.query('dish_logs')) row['id'] as String: row,
      };
      // 2 pre-existing + meal_log_1 + meal_log_4; 2 is an import duplicate,
      // 3 references a deleted dish.
      expect(
        logs.keys,
        unorderedEquals(['111', '222', 'meal_log_1', 'meal_log_4']),
      );
      expect(logs['111']!['dish_name'], 'Soup');
      expect(logs['222']!['dish_name'], isNull);
      expect(logs['meal_log_1']!['dish_name'], 'Oats');
      expect(logs['meal_log_1']!['calories'], 400);
      expect(logs['meal_log_1']!['protein'], 20);
      expect(logs['meal_log_1']!['fiber'], 8);
      expect(logs['meal_log_1']!['serving_size'], 2);
      expect(
        logs['meal_log_4']!['logged_at'],
        DateTime.parse('2026-09-21T08:00:00.000Z').toLocal().toIso8601String(),
      );
      expect(await _count(db, 'meal_logs'), 4, reason: 'kept for rollback');

      final links = await db.query(
        'dish_ingredients',
        where: 'dish_id = ?',
        whereArgs: ['oats'],
        orderBy: 'id',
      );
      expect(links.map((r) => r['id']), [1, 4, 5]);

      final summary = await mealLogService.getNutritionSummary(
        userId: 'default_user',
        startDate: DateTime(2026, 9, 20),
        endDate: DateTime(2026, 9, 21),
      );
      expect(summary.totalCalories, closeTo(400 + 100, 1e-9));

      final migratedSchema = await _schema(db);
      await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
      final fresh = await DatabaseService.instance.database;
      expect(migratedSchema, await _schema(fresh));
      expect(
        await fresh.rawQuery('PRAGMA foreign_key_list(dish_logs)'),
        isEmpty,
      );
    });

    for (final (version, schema) in [(1, _v1Schema), (2, _v2Schema)]) {
      test('upgrades a v$version database to the fresh v4 shape', () async {
        final path = p.join(tempDir.path, 'v$version.db');
        final old = await databaseFactoryFfiNoIsolate.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: version,
            onCreate: (db, _) async {
              for (final sql in schema) {
                await db.execute(sql);
              }
            },
          ),
        );
        await old.insert('dishes', {
          'id': 'oats',
          'name': 'Oats',
          'is_favorite': 0,
          'created_at': '2026-01-01T00:00:00.000',
          'updated_at': '2026-01-01T00:00:00.000',
        });
        await old.insert('dish_nutrition', {
          'dish_id': 'oats',
          'calories': 200,
          'protein': 10,
          'carbs': 30,
          'fat': 5,
          'fiber': 4,
        });
        await old.insert('meal_logs', {
          'user_id': 'default_user',
          'dish_id': 'oats',
          'serving_size': 2,
          'meal_type': 'lunch',
          'logged_at': '2026-09-20T12:00:00.000',
        });
        await old.close();

        await DatabaseService.useFactoryForTesting(
          databaseFactoryFfiNoIsolate,
          path: path,
        );
        final db = await DatabaseService.instance.database;
        expect(await db.getVersion(), 4);
        final ledger = await db.query('dish_logs');
        expect(ledger.single['calories'], 400);
        expect(ledger.single['dish_name'], 'Oats');

        final migrated = await _shape(db);
        await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
        expect(migrated, await _shape(await DatabaseService.instance.database));
      });
    }
  });
}

/// Tables with their columns (order-independent, since ALTER TABLE appends)
/// plus indexes.
Future<Map<String, Object>> _shape(Database db) async {
  final schema = await _schema(db);
  return {
    for (final MapEntry(:key, :value) in schema.entries)
      key:
          key == 'indexes'
              ? value
              : ((value as List<String>)
                  .map((c) => c.replaceFirst(RegExp(r'cid: \d+, '), ''))
                  .toList()
                ..sort()),
  };
}

Future<Map<String, Object>> _schema(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' "
    "AND name NOT LIKE 'sqlite_%' ORDER BY name",
  );
  final indexes = await db.rawQuery(
    "SELECT name, tbl_name FROM sqlite_master WHERE type = 'index' "
    "AND name NOT LIKE 'sqlite_%' ORDER BY name",
  );
  return {
    for (final t in tables)
      t['name'] as String:
          (await db.rawQuery(
            'PRAGMA table_info(${t['name']})',
          )).map((c) => c.toString()).toList(),
    'indexes': indexes.map((i) => i.toString()).toList(),
  };
}

Future<void> _seedV3(Database db) async {
  const ts = '2026-01-01T00:00:00.000';
  for (final (id, name) in [('oats', 'Oats'), ('soup', 'Soup')]) {
    await db.insert('dishes', {
      'id': id,
      'name': name,
      'is_favorite': 0,
      'created_at': ts,
      'updated_at': ts,
    });
  }
  await db.insert('dish_nutrition', {
    'dish_id': 'oats',
    'calories': 200,
    'protein': 10,
    'carbs': 30,
    'fat': 5,
    'fiber': 4,
  });
  await db.insert('dish_nutrition', {
    'dish_id': 'soup',
    'calories': 100,
    'protein': 5,
    'carbs': 10,
    'fat': 2,
    'fiber': 1,
  });
  await db.insert('ingredients', {'id': 'ing-oat', 'name': 'Oat flakes'});
  await db.insert('ingredients', {'id': 'ing-milk', 'name': 'Milk'});
  // ids 1-3 duplicate, 4 differs in amount, 5 is another ingredient.
  for (final (ingredient, amount) in [
    ('ing-oat', 50.0),
    ('ing-oat', 50.0),
    ('ing-oat', 50.0),
    ('ing-oat', 60.0),
    ('ing-milk', 200.0),
  ]) {
    await db.insert('dish_ingredients', {
      'dish_id': 'oats',
      'ingredient_id': ingredient,
      'amount': amount,
      'unit': 'g',
    });
  }

  Future<void> mealLog(String dishId, double serving, String type, String at) =>
      db.insert('meal_logs', {
        'user_id': 'default_user',
        'dish_id': dishId,
        'serving_size': serving,
        'meal_type': type,
        'logged_at': at,
      });
  await mealLog('oats', 2, 'lunch', '2026-09-20T12:00:00.000');
  await mealLog('soup', 1, 'dinner', '2026-09-20T19:00:00.000');
  await mealLog('gone', 1, 'snack', '2026-09-20T15:00:00.000');
  await mealLog('oats', 1, 'breakfast', '2026-09-21T08:00:00.000Z');

  Future<void> dishLog(String id, String dishId, String type, String at) =>
      db.insert('dish_logs', {
        'id': id,
        'dish_id': dishId,
        'logged_at': at,
        'meal_type': type,
        'serving_size': 1,
        'calories': 100,
        'protein': 5,
        'carbs': 10,
        'fat': 2,
        'fiber': 1,
      });
  // Written by import alongside meal_log 2.
  await dishLog('111', 'soup', 'dinner', '2026-09-20T19:00:00.000');
  await dishLog('222', 'deleted-dish', 'snack', '2026-09-19T10:00:00.000');
}

/// v2 differs from v3 only by the missing fitness_goals.target_fiber.
final _v2Schema = [
  for (final sql in _v3Schema)
    sql.replaceFirst(
      RegExp(r'\s*target_fiber REAL NOT NULL DEFAULT 25\.0,'),
      '',
    ),
];

/// v1 differs from v2 only by the missing dish_logs table and its indexes.
final _v1Schema = [
  for (final sql in _v2Schema)
    if (!sql.contains('dish_logs')) sql,
];

/// Schema created by DatabaseService._onCreate at version 3.
const _v3Schema = [
  '''
  CREATE TABLE user_profiles (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    age INTEGER NOT NULL,
    gender TEXT NOT NULL,
    height REAL NOT NULL,
    weight REAL NOT NULL,
    activity_level TEXT NOT NULL,
    preferred_unit TEXT DEFAULT 'metric',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''
  CREATE TABLE user_metrics_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    weight REAL,
    height REAL,
    body_fat REAL,
    daily_calories REAL,
    recorded_date TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user_profiles (id)
  )''',
  '''
  CREATE TABLE fitness_goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    goal TEXT NOT NULL,
    target_weight REAL NOT NULL,
    target_calories REAL NOT NULL,
    target_protein REAL NOT NULL,
    target_carbs REAL NOT NULL,
    target_fat REAL NOT NULL,
    target_fiber REAL NOT NULL DEFAULT 25.0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user_profiles (id)
  )''',
  '''
  CREATE TABLE dietary_preferences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    diet_type TEXT NOT NULL,
    prefer_organic INTEGER NOT NULL,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user_profiles (id)
  )''',
  '''
  CREATE TABLE allergies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    preference_id INTEGER NOT NULL,
    allergy TEXT NOT NULL,
    FOREIGN KEY (preference_id) REFERENCES dietary_preferences (id) ON DELETE CASCADE
  )''',
  '''
  CREATE TABLE dislikes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    preference_id INTEGER NOT NULL,
    dislike TEXT NOT NULL,
    FOREIGN KEY (preference_id) REFERENCES dietary_preferences (id) ON DELETE CASCADE
  )''',
  '''
  CREATE TABLE cuisine_preferences (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    preference_id INTEGER NOT NULL,
    cuisine TEXT NOT NULL,
    FOREIGN KEY (preference_id) REFERENCES dietary_preferences (id) ON DELETE CASCADE
  )''',
  '''
  CREATE TABLE dishes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    category TEXT,
    is_favorite INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )''',
  '''
  CREATE TABLE ingredients (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    barcode TEXT
  )''',
  '''
  CREATE TABLE dish_ingredients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dish_id TEXT NOT NULL,
    ingredient_id TEXT NOT NULL,
    amount REAL NOT NULL,
    unit TEXT NOT NULL,
    FOREIGN KEY (dish_id) REFERENCES dishes (id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
  )''',
  '''
  CREATE TABLE dish_nutrition (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dish_id TEXT UNIQUE NOT NULL,
    calories REAL NOT NULL,
    protein REAL NOT NULL,
    carbs REAL NOT NULL,
    fat REAL NOT NULL,
    fiber REAL NOT NULL DEFAULT 0,
    FOREIGN KEY (dish_id) REFERENCES dishes (id) ON DELETE CASCADE
  )''',
  '''
  CREATE TABLE ingredient_nutrition (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ingredient_id TEXT UNIQUE NOT NULL,
    calories REAL NOT NULL,
    protein REAL NOT NULL,
    carbs REAL NOT NULL,
    fat REAL NOT NULL,
    fiber REAL NOT NULL DEFAULT 0,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
  )''',
  '''
  CREATE TABLE meal_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    dish_id TEXT NOT NULL,
    serving_size REAL NOT NULL DEFAULT 1,
    meal_type TEXT NOT NULL,
    logged_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user_profiles (id),
    FOREIGN KEY (dish_id) REFERENCES dishes (id)
  )''',
  '''
  CREATE TABLE dish_logs (
    id TEXT PRIMARY KEY,
    dish_id TEXT NOT NULL,
    logged_at TEXT NOT NULL,
    meal_type TEXT NOT NULL,
    serving_size REAL NOT NULL,
    calories REAL NOT NULL,
    protein REAL NOT NULL,
    carbs REAL NOT NULL,
    fat REAL NOT NULL,
    fiber REAL NOT NULL DEFAULT 0,
    FOREIGN KEY (dish_id) REFERENCES dishes (id)
  )''',
  'CREATE INDEX idx_user_metrics_user_id ON user_metrics_history (user_id)',
  'CREATE INDEX idx_dish_ingredients_dish_id ON dish_ingredients (dish_id)',
  'CREATE INDEX idx_meal_logs_user_id ON meal_logs (user_id)',
  'CREATE INDEX idx_meal_logs_logged_at ON meal_logs (logged_at)',
  'CREATE INDEX idx_dish_logs_logged_at ON dish_logs (logged_at)',
  'CREATE INDEX idx_dish_logs_dish_id ON dish_logs (dish_id)',
];
