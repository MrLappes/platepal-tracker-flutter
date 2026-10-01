import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/services/data/import_export_service.dart';
import 'package:platepal_tracker/services/health_service.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:platepal_tracker/services/storage/user_profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _RecordingHealthService implements HealthService {
  final List<String> writes = [];

  @override
  bool get isConnected => true;

  @override
  Future<bool> writeMealToHealth({
    required String name,
    required String mealType,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    double? fiber,
    double? sugar,
    double? sodium,
    required DateTime startTime,
    DateTime? endTime,
  }) async {
    writes.add(name);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Dish _dish(String id, String name, double calories) {
  final now = DateTime(2026, 1, 1);
  return Dish(
    id: id,
    name: name,
    ingredients: const [],
    nutrition: NutritionInfo(
      calories: calories,
      protein: 10,
      carbs: 30,
      fat: 5,
      fiber: 4,
    ),
    createdAt: now,
    updatedAt: now,
  );
}

Map<String, dynamic> _dishLogEntry(
  String id,
  String dishId,
  String mealType,
  String loggedAt, {
  double servingSize = 1,
  double calories = 100,
}) => {
  'id': id,
  'dishId': dishId,
  'servingSize': servingSize,
  'mealType': mealType,
  'loggedAt': loggedAt,
  'calories': calories,
  'protein': 5.0,
  'carbs': 10.0,
  'fat': 2.0,
  'fiber': 1.0,
  'source': 'dish_logs',
};

/// Meal logs as exported by the previous app version (meal_logs + dish_logs).
Map<String, dynamic> _oldFormatFile() {
  final lunch = DateTime(2026, 9, 20, 12);
  return {
    'mealLogs': [
      // Imported log, mirrored into both tables by the old import.
      {
        'id': '1',
        'userId': 'default',
        'dishId': 'oats',
        'servingSize': 2,
        'mealType': 'lunch',
        'loggedAt': lunch.toUtc().toIso8601String(),
        'source': 'meal_logs',
      },
      _dishLogEntry(
        '1700000000000',
        'oats',
        'lunch',
        lunch.toIso8601String(),
        servingSize: 2,
        calories: 380,
      ),
      // Logged in the UI: dish_logs only.
      _dishLogEntry('1700000000001', 'soup', 'dinner', '2026-09-20T19:00:00.000'),
      // Same snack logged twice on purpose: two logs.
      _dishLogEntry('1700000000002', 'oats', 'snack', '2026-09-20T15:00:00.000'),
      _dishLogEntry('1700000000003', 'oats', 'snack', '2026-09-20T15:00:00.000'),
    ],
  };
}

Future<List<Map<String, Object?>>> _ledger() async {
  final db = await DatabaseService.instance.database;
  return db.query('dish_logs', orderBy: 'logged_at, meal_type');
}

List<Map<String, Object?>> _withoutId(List<Map<String, Object?>> rows) =>
    rows.map((r) => Map.of(r)..remove('id')).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late _RecordingHealthService health;
  late DishService dishService;
  late ImportExportService service;
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    health = _RecordingHealthService();
    dishService = DishService(healthService: health);
    service = ImportExportService(dishService: dishService);
    await dishService.saveDish(_dish('oats', 'Oats', 200));
    await dishService.saveDish(_dish('soup', 'Soup', 100));

    tempDir = await Directory.systemTemp.createTemp('platepal_export');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => tempDir.path,
        );
  });

  tearDown(() => tempDir.delete(recursive: true));

  Future<ImportExportResult> import(Map<String, dynamic> data) =>
      service.importData(
        filePath: '',
        jsonData: data,
        dataTypes: [DataType.mealLogs],
        duplicateHandling: DuplicateHandling.overwrite,
      );

  test('old-format file: paired entries become one row each', () async {
    final result = await import(_oldFormatFile());

    expect(result.errors, isEmpty);
    expect(result.itemsProcessed, 4);
    expect(result.duplicatesFound, 1);

    final rows = await _ledger();
    expect(rows.map((r) => '${r['dish_id']}/${r['meal_type']}'), [
      'oats/lunch',
      'oats/snack',
      'oats/snack',
      'soup/dinner',
    ]);
    final lunch = rows.first;
    // Snapshot from the file wins over the dish's current values (2 x 200).
    expect(lunch['calories'], 380);
    expect(lunch['serving_size'], 2);
    expect(lunch['dish_name'], 'Oats');
  });

  test('re-importing the same file adds nothing', () async {
    await import(_oldFormatFile());
    final again = await import(_oldFormatFile());

    expect(again.itemsProcessed, 0);
    expect(again.duplicatesFound, 5);
    expect(await _ledger(), hasLength(4));
  });

  test('invalid entries are skipped and counted', () async {
    Map<String, dynamic> entry(Map<String, dynamic> overrides) => {
      ..._dishLogEntry('x', 'oats', 'lunch', '2026-09-20T12:00:00.000'),
      ...overrides,
    };
    final invalid = <dynamic>[
      'not an object',
      entry({'servingSize': 0}),
      entry({'servingSize': -1}),
      entry({'servingSize': 51}),
      entry({'servingSize': 'NaN'}),
      entry({'calories': -5}),
      entry({'protein': 'Infinity'}),
      entry({'loggedAt': 'yesterday'}),
      entry({'loggedAt': null}),
      entry({'dishId': 'd' * 300}),
      entry({'dishId': 42}),
      entry({'notes': 'n' * 2000}),
      entry({'loggedAt': '12026-09-20T12:00:00.000'}),
      entry({'loggedAt': '0999-09-20T12:00:00.000'}),
    ];

    final result = await import({
      'mealLogs': [
        ...invalid,
        entry({'servingSize': 50, 'notes': 'big day'}),
      ],
    });

    expect(result.errors, isEmpty);
    expect(result.itemsProcessed, 1);
    final details = result.detailedResults!;
    expect(details.validationErrors, hasLength(invalid.length));
    expect(details.summary['mealLogs']!.skipped, invalid.length);
    expect(details.summary['mealLogs']!.total, invalid.length + 1);
    final rows = await _ledger();
    expect(rows.single['serving_size'], 50);
    expect(rows.single['notes'], 'big day');
  });

  test('import does not write to Health, a new log does', () async {
    await import({
      'mealLogs': [
        {
          'dishId': 'oats',
          'mealType': 'lunch',
          'loggedAt': '2026-09-20T12:00:00.000',
        },
      ],
    });
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(await _ledger(), hasLength(1));
    expect(health.writes, isEmpty);

    await dishService.logDish(
      dishId: 'soup',
      loggedAt: DateTime(2026, 9, 21, 12),
      mealType: 'lunch',
      servingSize: 1,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(health.writes, ['Soup']);
  });

  test('export lists each ledger row once and round-trips', () async {
    await dishService.logDish(
      dishId: 'oats',
      loggedAt: DateTime(2026, 9, 20, 8),
      mealType: 'breakfast',
      servingSize: 1.5,
      notes: 'with honey',
    );
    await dishService.logDish(
      dishId: 'soup',
      loggedAt: DateTime(2026, 9, 20, 19),
      mealType: 'dinner',
      servingSize: 1,
    );
    await dishService.deleteDish('soup');
    // Legacy table is no longer part of the ledger.
    final db = await DatabaseService.instance.database;
    await db.insert('meal_logs', {
      'user_id': 'default',
      'dish_id': 'oats',
      'serving_size': 1,
      'meal_type': 'lunch',
      'logged_at': '2026-09-19T12:00:00.000',
    });

    final result = await service.exportData(
      dataTypes: [DataType.mealLogs],
      format: ExportFormat.json,
    );
    expect(result.success, isTrue, reason: result.message);

    final file = tempDir.listSync().whereType<File>().single;
    final exported = json.decode(await file.readAsString()) as Map;
    final logs = (exported['mealLogs'] as List).cast<Map<String, dynamic>>();
    expect(logs, hasLength(2));
    expect(logs.map((l) => l['source']).toSet(), {'dish_logs'});
    final byName = {for (final l in logs) l['dishName']: l};
    expect(byName.keys, unorderedEquals(['Oats', 'Soup']));
    expect(byName['Oats']!['notes'], 'with honey');
    expect(byName['Oats']!['calories'], 300);

    final before = await _ledger();
    await db.delete('dish_logs');
    final reimport = await service.importData(
      filePath: file.path,
      dataTypes: [DataType.mealLogs],
      duplicateHandling: DuplicateHandling.skip,
    );
    expect(reimport.errors, isEmpty);
    // The deleted dish's log comes back from its snapshot.
    expect(_withoutId(await _ledger()), _withoutId(before));
    expect(health.writes, hasLength(2), reason: 'only the two logDish calls');
  });

  test('quick adds round-trip through JSON and CSV exports', () async {
    await dishService.logQuickAdd(
      name: 'Office cake',
      loggedAt: DateTime(2026, 9, 20, 15, 30),
      mealType: 'snack',
      calories: 350,
      protein: 4,
      carbs: 40,
      fat: 18,
      fiber: 1,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final before = await _ledger();
    final db = await DatabaseService.instance.database;

    for (final format in [ExportFormat.json, ExportFormat.csv]) {
      final result = await service.exportData(
        dataTypes: [DataType.mealLogs],
        format: format,
      );
      expect(result.success, isTrue, reason: result.message);
      final file = tempDir.listSync().whereType<File>().single;

      await db.delete('dish_logs');
      final reimport = await service.importData(
        filePath: file.path,
        dataTypes: [DataType.mealLogs],
        duplicateHandling: DuplicateHandling.skip,
      );
      expect(reimport.errors, isEmpty, reason: format.name);
      expect(_withoutId(await _ledger()), _withoutId(before));
      expect(
        (await _ledger()).single['dish_id'],
        startsWith(DishLog.quickAddDishIdPrefix),
      );
      expect(await dishService.getAllDishes(), hasLength(2));
      file.deleteSync();
    }
    expect(health.writes, ['Office cake']);
  });

  test('a failed write rolls back the whole meal-log import', () async {
    final db = await DatabaseService.instance.database;
    await db.execute('''
      CREATE TRIGGER fail_boom BEFORE INSERT ON dish_logs
      WHEN NEW.dish_id = 'boom' BEGIN SELECT RAISE(ABORT, 'boom'); END
    ''');

    final result = await import({
      'mealLogs': [
        _dishLogEntry('a', 'oats', 'lunch', '2026-09-20T12:00:00.000'),
        _dishLogEntry('b', 'boom', 'lunch', '2026-09-20T13:00:00.000'),
        _dishLogEntry('c', 'soup', 'dinner', '2026-09-20T19:00:00.000'),
      ],
    });

    expect(result.success, isFalse);
    expect(result.itemsProcessed, 0);
    expect(await _ledger(), isEmpty);
  });

  test('a file without dishes imports with dishes selected', () async {
    final result = await service.importData(
      filePath: '',
      jsonData: {
        'mealLogs': [
          _dishLogEntry('a', 'oats', 'lunch', '2026-09-20T12:00:00.000'),
        ],
      },
      dataTypes: [DataType.dishes, DataType.mealLogs],
      duplicateHandling: DuplicateHandling.skip,
    );

    expect(result.errors, isEmpty, reason: result.message);
    expect(await _ledger(), hasLength(1));
  });

  test('"all data" imports every section of the file', () async {
    final result = await service.importData(
      filePath: '',
      jsonData: {
        'dishes': [_dish('rice', 'Rice', 150).toJson()],
        'mealLogs': [
          {
            'dishId': 'rice',
            'mealType': 'lunch',
            'loggedAt': '2026-09-20T12:00:00.000',
          },
        ],
      },
      dataTypes: [DataType.allData],
      duplicateHandling: DuplicateHandling.overwrite,
    );

    expect(result.errors, isEmpty, reason: result.message);
    expect((await dishService.getDishById('rice'))?.name, 'Rice');
    final rows = await _ledger();
    expect(rows.single['dish_name'], 'Rice');
    expect(rows.single['calories'], 150);
  });

  group('restoreFromLastBackup', () {
    Future<void> logTwo() async {
      await dishService.logDish(
        dishId: 'oats',
        loggedAt: DateTime(2026, 9, 20, 8),
        mealType: 'breakfast',
        servingSize: 1.5,
        notes: 'with honey',
      );
      await dishService.logDish(
        dishId: 'soup',
        loggedAt: DateTime(2026, 9, 20, 19),
        mealType: 'dinner',
        servingSize: 1,
      );
    }

    test('brings back dishes and the ledger', () async {
      await logTwo();
      final before = await _ledger();
      expect(await service.createBackupBeforeImport(), isTrue);

      final result = await service.restoreFromLastBackup();

      expect(result.errors, isEmpty, reason: result.message);
      expect(_withoutId(await _ledger()), _withoutId(before));
      final dishes = await dishService.getAllDishes();
      expect(dishes.map((d) => d.id), unorderedEquals(['oats', 'soup']));
    });

    test('leaves current data alone when the backup is unreadable', () async {
      await logTwo();
      expect(await service.createBackupBeforeImport(), isTrue);
      final prefs = await SharedPreferences.getInstance();
      await File(prefs.getString('last_backup_path')!).writeAsString('{bro');

      final result = await service.restoreFromLastBackup();

      expect(result.success, isFalse);
      expect(await _ledger(), hasLength(2));
      expect(await dishService.getAllDishes(), hasLength(2));
    });

    test('a failed restore puts the current data back', () async {
      await logTwo();
      expect(await service.createBackupBeforeImport(), isTrue);
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('last_backup_path')!;
      final backup =
          json.decode(await File(path).readAsString()) as Map<String, dynamic>;
      (backup['mealLogs'] as List).add(
        _dishLogEntry('b', 'boom', 'lunch', '2026-09-21T12:00:00.000'),
      );
      await File(path).writeAsString(json.encode(backup));
      // Made after the backup: a failed restore must not lose it.
      await dishService.saveDish(_dish('rice', 'Rice', 150));
      await dishService.logDish(
        dishId: 'rice',
        loggedAt: DateTime(2026, 9, 22, 12),
        mealType: 'lunch',
        servingSize: 1,
      );
      final before = await _ledger();
      final db = await DatabaseService.instance.database;
      await db.execute('''
        CREATE TRIGGER fail_boom BEFORE INSERT ON dish_logs
        WHEN NEW.dish_id = 'boom' BEGIN SELECT RAISE(ABORT, 'boom'); END
      ''');

      final result = await service.restoreFromLastBackup();

      expect(result.success, isFalse);
      expect(_withoutId(await _ledger()), _withoutId(before));
      final dishes = await dishService.getAllDishes();
      expect(dishes.map((d) => d.id), unorderedEquals(['oats', 'soup', 'rice']));
      expect(prefs.getString('last_backup_path'), path);
    });

    test('a successful restore leaves no safety snapshot behind', () async {
      await logTwo();
      expect(await service.createBackupBeforeImport(), isTrue);

      final result = await service.restoreFromLastBackup();

      expect(result.success, isTrue, reason: result.message);
      final backups = Directory('${tempDir.path}/backups').listSync();
      expect(backups, hasLength(1));
    });
  });

  group('backups', () {
    test('only the newest 5 app backups are kept', () async {
      final dir = Directory('${tempDir.path}/backups')..createSync();
      for (var i = 1; i <= 6; i++) {
        File('${dir.path}/platepal_backup_$i.json').writeAsStringSync('{}');
      }
      File('${dir.path}/notes.json').writeAsStringSync('{}');
      File('${dir.path}/platepal_backup_old.json').writeAsStringSync('{}');

      expect(await service.createBackupBeforeImport(), isTrue);

      final names = dir.listSync().map((f) => f.uri.pathSegments.last).toSet();
      final prefs = await SharedPreferences.getInstance();
      final newest = File(prefs.getString('last_backup_path')!);
      expect(names, {
        newest.uri.pathSegments.last,
        'platepal_backup_6.json',
        'platepal_backup_5.json',
        'platepal_backup_4.json',
        'platepal_backup_3.json',
        'notes.json',
        'platepal_backup_old.json',
      });
    });
  });

  group('legacy profiles', () {
    Future<UserProfile?> importLegacy(Map<String, dynamic> profile) async {
      final result = await service.importData(
        filePath: '',
        jsonData: {'userProfile': profile},
        dataTypes: [DataType.userProfiles],
        duplicateHandling: DuplicateHandling.overwrite,
      );
      expect(result.errors, isEmpty, reason: result.message);
      expect(result.itemsProcessed, 1);
      return UserProfileService().getUserProfile(profile['id'].toString());
    }

    test('imports with its targets and an age from dateOfBirth', () async {
      final now = DateTime.now();
      final profile = await importLegacy({
        'id': 7,
        'name': 'Legacy',
        'email': 'legacy@example.com',
        'dateOfBirth': DateTime(now.year - 30, 1, 1).toIso8601String(),
        'gender': 'female',
        'height': 165,
        'weight': 60,
        'targetWeight': 55,
        'activityLevel': 'moderatelyActive',
        'fitnessGoal': 'loseWeight',
        'useMetricSystem': true,
        'dailyCalorieTarget': 1800,
        'dailyProteinTarget': 120,
        'dailyCarbsTarget': 180,
        'dailyFatTarget': 60,
        'dailyFiberTarget': 30,
        'createdAt': '2024-01-01T00:00:00.000Z',
      });

      expect(profile, isNotNull);
      expect(profile!.age, 30);
      expect(profile.activityLevel, 'moderately_active');
      expect(profile.preferredUnit, 'metric');
      expect(profile.goals.goal, 'lose_weight');
      expect(profile.goals.targetWeight, 55);
      expect(profile.goals.targetCalories, 1800);
      expect(profile.goals.targetProtein, 120);
      expect(profile.goals.targetCarbs, 180);
      expect(profile.goals.targetFat, 60);
      expect(profile.goals.targetFiber, 30);
    });

    test('still accepts an integer age', () async {
      final profile = await importLegacy({'id': 'p1', 'dateOfBirth': 41});
      expect(profile!.age, 41);
      expect(profile.goals.targetCalories, 2000);
    });
  });

  group('import validation', () {
    Map<String, dynamic> rice() => _dish('rice', 'Rice', 150).toJson();

    Future<ImportExportResult> importAll(Map<String, dynamic> data) =>
        service.importData(
          filePath: '',
          jsonData: data,
          dataTypes: [DataType.allData],
          duplicateHandling: DuplicateHandling.overwrite,
        );

    test('a section with more than 100000 items is not rejected', () async {
      final result = await importAll({
        'dishes': [rice()],
        'mealLogs': List.filled(100001, const <String, dynamic>{}),
      });

      expect(result.errorCode, isNot(ImportExportErrorCode.importInvalidData));
      expect(await dishService.getDishById('rice'), isNotNull);
      expect(result.detailedResults!.summary['mealLogs']!.total, 100001);
      expect(result.detailedResults!.validationErrors, hasLength(50));
      expect(result.detailedResults!.omittedErrors, 100001 - 50);
    });

    Future<ImportExportResult> importIngredients(
      List<Map<String, dynamic>> ingredients, {
      DuplicateHandling duplicateHandling = DuplicateHandling.overwrite,
    }) => service.importData(
      filePath: '',
      jsonData: {'ingredients': ingredients},
      dataTypes: [DataType.ingredients],
      duplicateHandling: duplicateHandling,
    );

    Future<int> countRows(String table) async {
      final db = await DatabaseService.instance.database;
      final rows = await db.rawQuery('SELECT COUNT(*) AS n FROM $table');
      return rows.single['n'] as int;
    }

    Map<String, dynamic> nutrition(num calories) => {
      'calories': calories,
      'protein': 1,
      'carbs': 2,
      'fat': 3,
    };

    test('a large ingredients section with half stored skips the rest', () async {
      const count = 1002;
      final db = await DatabaseService.instance.database;
      final batch = db.batch();
      for (var i = 0; i < count; i += 2) {
        batch.insert('ingredients', {'id': 'ing$i', 'name': 'Stored $i'});
        batch.insert('ingredient_nutrition', {
          'ingredient_id': 'ing$i',
          ...nutrition(0),
        });
      }
      await batch.commit(noResult: true);

      final result = await importIngredients([
        for (var i = 0; i < count; i++)
          {'id': 'ing$i', 'name': 'Ingredient $i', 'nutrition': nutrition(i)},
      ], duplicateHandling: DuplicateHandling.skip);

      expect(result.success, isTrue, reason: result.message);
      expect(result.itemsProcessed, count ~/ 2);
      expect(result.duplicatesFound, count ~/ 2);
      final summary = result.detailedResults!.summary['ingredients']!;
      expect(
        (summary.total, summary.processed, summary.duplicates, summary.skipped),
        (count, count ~/ 2, count ~/ 2, 0),
      );
      expect(await countRows('ingredients'), count);
      expect(await countRows('ingredient_nutrition'), count);
      final stored = await db.query(
        'ingredients',
        where: 'id IN (?, ?)',
        whereArgs: ['ing0', 'ing1'],
        orderBy: 'id',
      );
      expect(stored.map((r) => r['name']), ['Stored 0', 'Ingredient 1']);
    });

    test('an ingredient with invalid nutrition is skipped before writing', () async {
      final result = await importIngredients([
        {
          'id': 'text',
          'name': 'Text',
          'nutrition': {...nutrition(1), 'calories': 'lots'},
        },
        {
          'id': 'missing',
          'name': 'Missing',
          'nutrition': nutrition(1)..remove('fat'),
        },
        {'id': 'list', 'name': 'List', 'nutrition': [1, 2]},
        {'id': '', 'name': 'Empty id'},
        {'id': 'ok', 'name': 'Ok', 'nutrition': nutrition(5)},
      ]);

      final db = await DatabaseService.instance.database;
      final rows = await db.query('ingredients');
      expect(rows.map((r) => r['id']), ['ok']);
      expect(await countRows('ingredient_nutrition'), 1);
      expect(result.itemsProcessed, 1);
      expect(result.itemsSkipped, 4);
      expect(
        result.detailedResults!.validationErrors.map((e) => e.field),
        ['nutrition.calories', 'nutrition.fat', 'nutrition', 'id'],
      );
    });

    test('a fatal database error rolls back the whole ingredients section', () async {
      final db = await DatabaseService.instance.database;
      await db.execute('DROP TABLE ingredient_nutrition');

      final result = await importIngredients([
        {'id': 'i1', 'name': 'Salt', 'nutrition': nutrition(0)},
        {'id': 'i2', 'name': 'Flour'},
      ]);

      expect(await countRows('ingredients'), 0);
      expect(result.success, isFalse);
      expect(result.itemsProcessed, 0);
      expect(result.errors, hasLength(1));
      expect(result.failedSections, ['ingredients']);
    });

    test('detailed errors are capped per section with a total count', () async {
      final result = await importAll({
        'ingredients': [
          for (var i = 0; i < 120; i++) {'id': 'x$i'},
        ],
        'mealLogs': List.filled(60, const <String, dynamic>{}),
      });

      final details = result.detailedResults!;
      expect(details.validationErrors, hasLength(100));
      expect(
        details.validationErrors.where((e) => e.field == 'name'),
        hasLength(ImportDetailedResults.maxErrorsPerSection),
      );
      expect(details.omittedErrors, 70 + 10);
      expect(result.itemsSkipped, 180);
    });

    test('processing errors and messages are capped per section', () async {
      final result = await importAll({
        'mealLogs': [
          for (var i = 0; i < 55; i++)
            {
              'id': '$i',
              'dishId': 'unknown',
              'servingSize': 1,
              'mealType': 'lunch',
              'loggedAt': DateTime(2026, 9, 20, 12, i).toIso8601String(),
              'source': 'meal_logs',
            },
        ],
      });

      final details = result.detailedResults!;
      expect(details.processingErrors, hasLength(50));
      expect(result.errors, hasLength(50));
      expect(details.summary['mealLogs']!.errors, 55);
      expect(details.omittedErrors, 5);
    });

    test('a write error is reported after the detail cap is reached', () async {
      final result = await importAll({
        'mealLogs': [
          ...List.filled(60, const <String, dynamic>{}),
          {
            'dishId': 'unknown',
            'servingSize': 1,
            'mealType': 'lunch',
            'loggedAt': '2026-09-20T12:00:00.000',
            'source': 'meal_logs',
          },
        ],
      });

      expect(result.success, isFalse);
      expect(result.errors, hasLength(1));
      expect(result.failedSections, ['mealLogs']);
      expect(result.detailedResults!.omittedErrors, 11);
    });

    test('an ingredients section writes valid rows and reports bad ones', () async {
      final result = await service.importData(
        filePath: '',
        jsonData: {
          'ingredients': [
            {
              'id': 'i1',
              'name': 'Salt',
              'nutrition': {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0},
            },
            {'id': 'i2', 'name': 'Flour'},
            {'name': 'No id'},
          ],
        },
        dataTypes: [DataType.ingredients],
        duplicateHandling: DuplicateHandling.overwrite,
      );

      final db = await DatabaseService.instance.database;
      final rows = await db.query('ingredients', orderBy: 'id');
      expect(rows.map((r) => r['id']), ['i1', 'i2']);
      expect(result.itemsProcessed, 2);
      expect(result.itemsSkipped, 1);
      expect(
        result.detailedResults!.validationErrors.map((e) => e.field),
        ['id'],
      );
      expect(result.detailedResults!.processedItems, hasLength(2));
    });

    test('a section of the wrong type fails without writing', () async {
      final result = await importAll({
        'dishes': [rice()],
        'mealLogs': 'nope',
      });

      expect(result.success, isFalse);
      expect(await dishService.getDishById('rice'), isNull);
    });

    test('a file that is not a JSON object fails', () async {
      final file = File('${tempDir.path}/list.json')..writeAsStringSync('[1]');
      final result = await service.importData(
        filePath: file.path,
        dataTypes: [DataType.allData],
        duplicateHandling: DuplicateHandling.skip,
      );
      expect(result.success, isFalse);
      expect(result.message, contains('JSON object'));
      expect(result.errorCode, ImportExportErrorCode.importInvalidJson);
    });

    test('a missing import file returns a stable error code', () async {
      final result = await service.importData(
        filePath: '${tempDir.path}/missing.json',
        dataTypes: [DataType.allData],
        duplicateHandling: DuplicateHandling.skip,
      );

      expect(result.success, isFalse);
      expect(result.errorCode, ImportExportErrorCode.importFileMissing);
    });

    test('an oversized file is rejected before reading', () async {
      final file = File('${tempDir.path}/big.json');
      file.openSync(mode: FileMode.write)
        ..truncateSync(ImportExportService.maxImportBytes + 1)
        ..closeSync();
      final result = await service.importData(
        filePath: file.path,
        dataTypes: [DataType.allData],
        duplicateHandling: DuplicateHandling.skip,
      );
      expect(result.success, isFalse);
      expect(result.message, contains('too large'));
      expect(result.errorCode, ImportExportErrorCode.importFileTooLarge);
    });

    test('skipped rows are reported as a partial import', () async {
      final result = await importAll({
        'dishes': [
          rice(),
          {'id': 'x', 'name': ''},
        ],
      });

      expect(result.success, isTrue, reason: result.message);
      expect(result.itemsProcessed, 1);
      expect(result.itemsSkipped, 1);
      expect(result.isPartial, isTrue);
      expect(result.message, contains('skipped 1'));
    });
  });

  test('a legacy dish without ID overwrites the same-named dish', () async {
    final result = await service.importData(
      filePath: '',
      jsonData: {'name': 'Oats', 'calories': 250, 'protein': 8},
      dataTypes: [DataType.dishes],
      duplicateHandling: DuplicateHandling.overwrite,
    );

    expect(result.errors, isEmpty, reason: result.message);
    final oats = (await dishService.getAllDishes()).where(
      (d) => d.name.toLowerCase() == 'oats',
    );
    expect(oats.map((d) => d.id), ['oats']);
    expect(oats.single.nutrition.calories, 250);
  });

  test('all-data export fails when a section cannot be read', () async {
    final db = await DatabaseService.instance.database;
    await db.execute('DROP TABLE fitness_goals');

    final result = await service.exportData(
      dataTypes: [DataType.allData],
      format: ExportFormat.json,
    );

    expect(result.success, isFalse);
    expect(result.failedSections, ['fitnessGoals']);
    expect(result.errorCode, ImportExportErrorCode.exportSectionFailed);
    expect(tempDir.listSync().whereType<File>(), isEmpty);
    expect(await service.createBackupBeforeImport(), isFalse);
  });

  test('successful export returns its file path separately from the message', () async {
    final result = await service.exportData(
      dataTypes: [DataType.dishes],
      format: ExportFormat.json,
    );

    expect(result.success, isTrue);
    expect(result.filePath, isA<String>());
    expect(await File(result.filePath!).exists(), isTrue);
  });

  test('missing restore backup returns a stable error code', () async {
    final result = await service.restoreFromLastBackup();

    expect(result.success, isFalse);
    expect(result.errorCode, ImportExportErrorCode.restoreBackupMissing);
  });

  test('logs never contain imported personal data', () async {
    final logs = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
    addTearDown(() => debugPrint = original);

    await service.importData(
      filePath: '',
      jsonData: {
        'dishes': [
          // Fails conversion; a saved dish would hit DishService's own logs.
          {'id': 'd2', 'name': 'Secret Stew', 'ingredients': 'Secret'},
        ],
        'userProfiles': [
          {
            'id': 'u',
            'name': 'Jane Secret',
            'email': 'jane@secret.test',
            'age': 30,
            'gender': 'female',
            'height': 165,
            'weight': 60,
            'activityLevel': 'sedentary',
            'goals': {
              'goal': 'maintain_weight',
              'targetWeight': 60,
              'targetCalories': 2000,
              'targetProtein': 100,
              'targetCarbs': 200,
              'targetFat': 60,
            },
            'createdAt': 'Secret date',
            'updatedAt': 'Secret date',
          },
        ],
      },
      dataTypes: [DataType.dishes, DataType.userProfiles],
      duplicateHandling: DuplicateHandling.overwrite,
    );

    expect(logs, isNotEmpty);
    expect(logs.where((l) => l.toLowerCase().contains('secret')), isEmpty);
  });

  group('deleteUserProfile', () {
    UserProfile profile(String id) => UserProfile(
      id: id,
      name: id,
      email: '',
      age: 30,
      gender: 'other',
      height: 170,
      weight: 70,
      activityLevel: 'moderately_active',
      goals: FitnessGoals(
        goal: 'maintain_weight',
        targetWeight: 70,
        targetCalories: 2000,
        targetProtein: 150,
        targetCarbs: 250,
        targetFat: 67,
        targetFiber: 25,
      ),
      preferences: DietaryPreferences(
        dietType: 'omnivore',
        allergies: [],
        dislikes: [],
        cuisinePreferences: [],
      ),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('clears the ledger with the last profile only', () async {
      final profiles = UserProfileService();
      await profiles.saveUserProfile(profile('default'));
      await profiles.saveUserProfile(profile('other'));
      await dishService.logDish(
        dishId: 'oats',
        loggedAt: DateTime(2026, 9, 20, 8),
        mealType: 'breakfast',
        servingSize: 1,
      );

      await profiles.deleteUserProfile('other');
      expect(await _ledger(), hasLength(1));

      await profiles.deleteUserProfile('default');
      expect(await _ledger(), isEmpty);
    });
  });

  group('full backup zip', () {
    Future<String> exportWithPhoto() async {
      final photo = File('${tempDir.path}/dish_images/photo.jpg');
      await photo.create(recursive: true);
      await photo.writeAsBytes([1, 2, 3, 4]);
      await dishService.saveDish(
        _dish('pic', 'Pancakes', 300).copyWith(imageUrl: photo.path),
      );
      final result = await service.exportData(
        dataTypes: [DataType.dishes],
        format: ExportFormat.zip,
      );
      expect(result.success, isTrue);
      expect(result.filePath, endsWith('.zip'));
      return result.filePath!;
    }

    test('restores dish photos and points dishes at the copies', () async {
      final zipPath = await exportWithPhoto();
      await dishService.deleteDish('pic');
      await File('${tempDir.path}/dish_images/photo.jpg').delete();

      final result = await service.importData(
        filePath: zipPath,
        dataTypes: [DataType.dishes],
        duplicateHandling: DuplicateHandling.skip,
      );

      expect(result.success, isTrue);
      final dish = await dishService.getDishById('pic');
      expect(dish, isNotNull);
      final imageUrl = dish!.imageUrl!;
      expect(imageUrl, startsWith('${tempDir.path}/dish_images/'));
      expect(imageUrl, endsWith('.jpg'));
      expect(await File(imageUrl).readAsBytes(), [1, 2, 3, 4]);
      expect((await dishService.getDishById('oats'))!.imageUrl, isNull);
    });

    test('import can be undone with the pre-import backup', () async {
      final zipPath = await exportWithPhoto();
      await dishService.deleteDish('pic');

      expect(await service.createBackupBeforeImport(), isTrue);
      await service.importData(
        filePath: zipPath,
        dataTypes: [DataType.dishes],
        duplicateHandling: DuplicateHandling.skip,
      );
      expect(await dishService.getDishById('pic'), isNotNull);

      final restored = await service.restoreFromLastBackup();
      expect(restored.success, isTrue);
      expect(await dishService.getDishById('pic'), isNull);
      expect(await dishService.getDishById('oats'), isNotNull);
    });

    test('a zip that is not a backup fails with its own code', () async {
      final bogus = File('${tempDir.path}/bogus.zip');
      await bogus.writeAsString('not a zip');

      final result = await service.importData(
        filePath: bogus.path,
        dataTypes: [DataType.dishes],
        duplicateHandling: DuplicateHandling.skip,
      );

      expect(result.success, isFalse);
      expect(result.errorCode, ImportExportErrorCode.importInvalidArchive);
    });

    test('zip files get the larger size limit', () {
      expect(
        ImportExportService.maxImportBytesFor('backup.ZIP'),
        ImportExportService.maxArchiveImportBytes,
      );
      expect(
        ImportExportService.maxImportBytesFor('backup.json'),
        ImportExportService.maxImportBytes,
      );
    });
  });
}
