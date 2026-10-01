import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../models/dish.dart';
import '../calorie_expenditure_service.dart';
import '../health_service.dart';
import 'database_service.dart';

class DishService {
  DishService({HealthService? healthService})
    : _healthService = healthService ?? HealthService();

  final DatabaseService _databaseService = DatabaseService.instance;
  final CalorieExpenditureService _calorieExpenditureService =
      CalorieExpenditureService();
  final HealthService _healthService;
  // Get all dishes
  Future<List<Dish>> getAllDishes() async {
    debugPrint('🔍 DishService: Getting all dishes from database...');
    final db = await _databaseService.database;

    // Get all dishes, newest first
    final List<Map<String, dynamic>> dishMaps = await db.query(
      'dishes',
      orderBy: 'created_at DESC',
    );
    debugPrint('🔍 DishService: Found ${dishMaps.length} dishes in database');

    final dishes = await Future.wait(
      dishMaps.map((dishMap) => _getDishWithRelations(dishMap)),
    );

    debugPrint('🔍 DishService: Returning ${dishes.length} dishes');

    return dishes;
  }

  /// Most recent local log time for each dish in the meal ledger.
  Future<Map<String, DateTime>> getLastLoggedAtByDish() async {
    final db = await _databaseService.database;
    final rows = await db.rawQuery('''
      SELECT dish_id, MAX(logged_at) AS last_logged_at
      FROM dish_logs
      GROUP BY dish_id
    ''');
    return {
      for (final row in rows)
        row['dish_id'] as String: DateTime.parse(
          row['last_logged_at'] as String,
        ),
    };
  }

  // Get dish by ID
  Future<Dish?> getDishById(String id) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> dishMaps = await db.query(
      'dishes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (dishMaps.isEmpty) {
      return null;
    }

    return _getDishWithRelations(dishMaps.first);
  }

  // Helper method to get dish with all its relations
  Future<Dish> _getDishWithRelations(Map<String, dynamic> dishMap) async {
    final db = await _databaseService.database;
    final String dishId = dishMap['id'] as String;
    debugPrint('🔍 _getDishWithRelations: Building dish with id: $dishId');
    // Get nutrition info
    final List<Map<String, dynamic>> nutritionMaps = await db.query(
      'dish_nutrition',
      where: 'dish_id = ?',
      whereArgs: [dishId],
    );

    // Get dish ingredients with join
    final List<Map<String, dynamic>> dishIngredientsMaps = await db.rawQuery(
      '''
      SELECT di.*, i.name, i.barcode
      FROM dish_ingredients di
      JOIN ingredients i ON di.ingredient_id = i.id
      WHERE di.dish_id = ?
    ''',
      [dishId],
    );
    debugPrint(
      '🔍 _getDishWithRelations: Found ${dishIngredientsMaps.length} ingredient rows for dish $dishId',
    );

    // Construct ingredients list
    final List<Ingredient> ingredients = [];

    for (final diMap in dishIngredientsMaps) {
      final String ingredientId = diMap['ingredient_id'] as String;

      // Get ingredient nutrition if available
      final List<Map<String, dynamic>> ingNutritionMaps = await db.query(
        'ingredient_nutrition',
        where: 'ingredient_id = ?',
        whereArgs: [ingredientId],
      );
      NutritionInfo? ingredientNutrition;
      if (ingNutritionMaps.isNotEmpty) {
        final nm = ingNutritionMaps.first;
        ingredientNutrition = NutritionInfo(
          calories: (nm['calories'] as num?)?.toDouble() ?? 0.0,
          protein: (nm['protein'] as num?)?.toDouble() ?? 0.0,
          carbs: (nm['carbs'] as num?)?.toDouble() ?? 0.0,
          fat: (nm['fat'] as num?)?.toDouble() ?? 0.0,
          fiber: (nm['fiber'] as num?)?.toDouble() ?? 0.0,
          // Note: sugar and sodium default to 0.0 since they're not in current database schema
          sugar: 0.0,
          sodium: 0.0,
        );
      }

      ingredients.add(
        Ingredient(
          id: ingredientId,
          name: diMap['name'] as String,
          amount: (diMap['amount'] as num?)?.toDouble() ?? 0.0,
          unit: (diMap['unit'] as String?) ?? 'g',
          barcode: diMap['barcode'] as String?,
          nutrition: ingredientNutrition,
        ),
      );
    } // Construct dish nutrition info
    final NutritionInfo dishNutrition;
    if (nutritionMaps.isNotEmpty) {
      final nm = nutritionMaps.first;
      dishNutrition = NutritionInfo(
        calories: (nm['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (nm['protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (nm['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (nm['fat'] as num?)?.toDouble() ?? 0.0,
        fiber: (nm['fiber'] as num?)?.toDouble() ?? 0.0,
        sugar: 0.0,
        sodium: 0.0,
      );
    } else {
      // Default empty nutrition if not found
      dishNutrition = const NutritionInfo(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
      );
    }

    debugPrint(
      '🔍 _getDishWithRelations: Constructed ${ingredients.length} ingredients for dish $dishId',
    );
    // Return the complete dish
    final result = Dish(
      id: dishId,
      name: dishMap['name'] as String,
      description: dishMap['description'] as String?,
      imageUrl: dishMap['image_url'] as String?,
      ingredients: ingredients,
      nutrition: dishNutrition,
      createdAt: DateTime.parse(dishMap['created_at'] as String),
      updatedAt: DateTime.parse(dishMap['updated_at'] as String),
      isFavorite: (dishMap['is_favorite'] as int) == 1,
      category: dishMap['category'] as String?,
    );
    debugPrint(
      '🔍 _getDishWithRelations: Returning dish $dishId with ${result.ingredients.length} ingredients',
    );
    return result;
  }

  // Save a new dish
  Future<Dish> saveDish(Dish dish) async {
    debugPrint('🍽️ DishService: Starting to save dish ID: ${dish.id}');
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      debugPrint('🍽️ DishService: Inserting dish into database...');
      // Insert dish
      await txn.insert('dishes', {
        'id': dish.id,
        'name': dish.name,
        'description': dish.description,
        'image_url': dish.imageUrl,
        'category': dish.category,
        'is_favorite': dish.isFavorite ? 1 : 0,
        'created_at': dish.createdAt.toIso8601String(),
        'updated_at': dish.updatedAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      debugPrint('🍽️ DishService: Inserting dish nutrition...');
      // Insert dish nutrition (only columns that exist in current schema)
      await txn.insert('dish_nutrition', {
        'dish_id': dish.id,
        'calories': dish.nutrition.calories,
        'protein': dish.nutrition.protein,
        'carbs': dish.nutrition.carbs,
        'fat': dish.nutrition.fat,
        'fiber': dish.nutrition.fiber,
        // Note: sugar and sodium are not stored in current database schema
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      debugPrint(
        '🍽️ DishService: Inserting ${dish.ingredients.length} ingredients...',
      );
      // Replace (not append) the ingredient links so saving twice is a no-op.
      await txn.delete(
        'dish_ingredients',
        where: 'dish_id = ?',
        whereArgs: [dish.id],
      );
      // Insert ingredients and their relationships
      for (final ingredient in dish.ingredients) {
        // Insert or replace ingredient record. With UUID-based IDs a collision
        // is practically impossible, but using replace (not ignore) ensures the
        // correct name/data wins if it ever does happen.
        await txn.insert(
          'ingredients',
          {
            'id': ingredient.id,
            'name': ingredient.name,
            'barcode': ingredient.barcode,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        ); // Insert ingredient nutrition if available
        if (ingredient.nutrition != null) {
          await txn.insert('ingredient_nutrition', {
            'ingredient_id': ingredient.id,
            'calories': ingredient.nutrition!.calories,
            'protein': ingredient.nutrition!.protein,
            'carbs': ingredient.nutrition!.carbs,
            'fat': ingredient.nutrition!.fat,
            'fiber': ingredient.nutrition!.fiber,
            // Note: sugar and sodium are not stored in current database schema
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // Insert dish-ingredient relationship
        await txn.insert('dish_ingredients', {
          'dish_id': dish.id,
          'ingredient_id': ingredient.id,
          'amount': ingredient.amount,
          'unit': ingredient.unit,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });

    debugPrint('🍽️ DishService: Dish saved successfully: ${dish.id}');
    return dish;
  }

  // Update an existing dish
  Future<Dish> updateDish(Dish dish) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      // Update dish
      await txn.update(
        'dishes',
        {
          'name': dish.name,
          'description': dish.description,
          'image_url': dish.imageUrl,
          'category': dish.category,
          'is_favorite': dish.isFavorite ? 1 : 0,
          'updated_at': dish.updatedAt.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [dish.id],
      ); // Update dish nutrition (only columns that exist in current schema)
      await txn.update(
        'dish_nutrition',
        {
          'calories': dish.nutrition.calories,
          'protein': dish.nutrition.protein,
          'carbs': dish.nutrition.carbs,
          'fat': dish.nutrition.fat,
          'fiber': dish.nutrition.fiber,
          // Note: sugar and sodium are not stored in current database schema
        },
        where: 'dish_id = ?',
        whereArgs: [dish.id],
      );

      // Delete existing dish ingredients relationships
      await txn.delete(
        'dish_ingredients',
        where: 'dish_id = ?',
        whereArgs: [dish.id],
      );

      // Insert updated ingredients and relationships
      for (final ingredient in dish.ingredients) {
        // Insert or replace ingredient record (same fix as saveDish path).
        await txn.insert(
          'ingredients',
          {
            'id': ingredient.id,
            'name': ingredient.name,
            'barcode': ingredient.barcode,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        ); // Insert or update ingredient nutrition if available
        if (ingredient.nutrition != null) {
          await txn.insert('ingredient_nutrition', {
            'ingredient_id': ingredient.id,
            'calories': ingredient.nutrition!.calories,
            'protein': ingredient.nutrition!.protein,
            'carbs': ingredient.nutrition!.carbs,
            'fat': ingredient.nutrition!.fat,
            'fiber': ingredient.nutrition!.fiber,
            // Note: sugar and sodium are not stored in current database schema
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }

        // Insert dish-ingredient relationship
        await txn.insert('dish_ingredients', {
          'dish_id': dish.id,
          'ingredient_id': ingredient.id,
          'amount': ingredient.amount,
          'unit': ingredient.unit,
        });
      }
    });

    return dish;
  }

  // Delete a dish. Its logs in dish_logs are kept (they carry a snapshot).
  Future<void> deleteDish(String id) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
      await txn.delete('dish_nutrition', where: 'dish_id = ?', whereArgs: [id]);
      await txn.delete(
        'dish_ingredients',
        where: 'dish_id = ?',
        whereArgs: [id],
      );
      await txn.delete('dishes', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Updates only the favorite flag of a dish.
  Future<void> setFavorite(String dishId, bool isFavorite) async {
    final db = await _databaseService.database;

    await db.update(
      'dishes',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [dishId],
    );
  }

  // Get all favorite dishes
  Future<List<Dish>> getFavoriteDishes() async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> dishMaps = await db.query(
      'dishes',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );

    return Future.wait(
      dishMaps.map((dishMap) => _getDishWithRelations(dishMap)),
    );
  }

  // Get dishes by category
  Future<List<Dish>> getDishesByCategory(String category) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> dishMaps = await db.query(
      'dishes',
      where: 'category = ?',
      whereArgs: [category],
    );

    return Future.wait(
      dishMaps.map((dishMap) => _getDishWithRelations(dishMap)),
    );
  }

  // Search dishes by name or ingredients
  Future<List<Dish>> searchDishes(String query) async {
    final db = await _databaseService.database;

    // Search by dish name
    final List<Map<String, dynamic>> dishNameMaps = await db.query(
      'dishes',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    // Search by ingredient name
    final List<Map<String, dynamic>> ingredientDishMaps = await db.rawQuery(
      '''
      SELECT d.*
      FROM dishes d
      JOIN dish_ingredients di ON d.id = di.dish_id
      JOIN ingredients i ON di.ingredient_id = i.id
      WHERE i.name LIKE ?
      GROUP BY d.id
    ''',
      ['%$query%'],
    );

    // Combine and deduplicate results
    final Map<String, Map<String, dynamic>> uniqueDishes = {};

    for (final dishMap in dishNameMaps) {
      uniqueDishes[dishMap['id'] as String] = dishMap;
    }

    for (final dishMap in ingredientDishMaps) {
      uniqueDishes[dishMap['id'] as String] = dishMap;
    }

    return Future.wait(
      uniqueDishes.values.map((dishMap) => _getDishWithRelations(dishMap)),
    );
  }

  // Get dishes by ingredient
  Future<List<Dish>> getDishesByIngredient(String ingredientId) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> dishMaps = await db.rawQuery(
      '''
      SELECT d.*
      FROM dishes d
      JOIN dish_ingredients di ON d.id = di.dish_id
      WHERE di.ingredient_id = ?
    ''',
      [ingredientId],
    );

    return Future.wait(
      dishMaps.map((dishMap) => _getDishWithRelations(dishMap)),
    );
  }

  // Meal logging methods
  static int _logSequence = 0;

  /// Logs [servingSize] servings of a dish into `dish_logs`, storing a
  /// snapshot of its name and scaled nutrition, and mirrors the meal to
  /// Health Connect. Returns the log id.
  Future<String> logDish({
    required String dishId,
    required DateTime loggedAt,
    required String mealType,
    required double servingSize,
    String? notes,
  }) async {
    final dish = await getDishById(dishId);
    if (dish == null) {
      throw Exception('Dish not found');
    }

    final nutrition = dish.nutrition;
    final logId = await insertDishLogSnapshot(
      dishId: dishId,
      dishName: dish.name,
      loggedAt: loggedAt,
      mealType: mealType,
      servingSize: servingSize,
      calories: nutrition.calories * servingSize,
      protein: nutrition.protein * servingSize,
      carbs: nutrition.carbs * servingSize,
      fat: nutrition.fat * servingSize,
      fiber: nutrition.fiber * servingSize,
      notes: notes,
    );

    // Write nutrition to Health Connect (fire-and-forget)
    _writeLogToHealth(
      name: dish.name,
      mealType: mealType,
      calories: nutrition.calories * servingSize,
      protein: nutrition.protein * servingSize,
      carbs: nutrition.carbs * servingSize,
      fat: nutrition.fat * servingSize,
      fiber: nutrition.fiber * servingSize,
      sugar: nutrition.sugar * servingSize,
      sodium: nutrition.sodium * servingSize,
      loggedAt: loggedAt,
    );

    return logId;
  }

  /// Logs nutrition without a catalog dish. The row gets its own
  /// [DishLog.quickAddDishIdPrefix] id, so it never shows up as a dish.
  Future<String> logQuickAdd({
    required String name,
    required DateTime loggedAt,
    required String mealType,
    required double calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    double fiber = 0,
    String? notes,
  }) async {
    final logId = await insertDishLogSnapshot(
      dishId: '${DishLog.quickAddDishIdPrefix}${const Uuid().v4()}',
      dishName: name,
      loggedAt: loggedAt,
      mealType: mealType,
      servingSize: 1,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      notes: notes,
    );
    _writeLogToHealth(
      name: name,
      mealType: mealType,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      loggedAt: loggedAt,
    );
    return logId;
  }

  /// Changes servings, time, meal type and notes of a ledger row. Nutrition
  /// is rescaled from the row's own snapshot, so this also works for quick
  /// adds and deleted dishes. Health Connect is not touched: the app can
  /// only insert records there.
  Future<void> updateDishLog(
    DishLog log, {
    required double servingSize,
    required DateTime loggedAt,
    required String mealType,
    String? notes,
  }) async {
    final db = await _databaseService.database;
    final factor = log.servingSize > 0 ? servingSize / log.servingSize : 1.0;
    final trimmedNotes = notes?.trim();
    await db.update(
      'dish_logs',
      {
        'logged_at': loggedAt.toLocal().toIso8601String(),
        'meal_type': mealType,
        'serving_size': servingSize,
        'calories': log.calories * factor,
        'protein': log.protein * factor,
        'carbs': log.carbs * factor,
        'fat': log.fat * factor,
        'fiber': log.fiber * factor,
        'notes':
            trimmedNotes == null || trimmedNotes.isEmpty ? null : trimmedNotes,
      },
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  /// Copies [log] (its snapshot, at the same time of day) to [day] and
  /// mirrors the copy to Health Connect. Returns the new log id.
  Future<String> copyDishLog(DishLog log, DateTime day) async {
    final ids = await _copyLogs([log], day);
    return ids.single;
  }

  /// Copies every [mealType] entry of the day before [day] to [day].
  /// Returns the number of copied entries.
  Future<int> copyMealFromPreviousDay({
    required DateTime day,
    required String mealType,
  }) async {
    final previous = await getDishLogsForDate(
      DateTime(day.year, day.month, day.day - 1),
    );
    final type = mealType.toLowerCase();
    final logs =
        previous.where((log) => log.mealType.toLowerCase() == type).toList();
    if (logs.isEmpty) return 0;
    return (await _copyLogs(logs, day)).length;
  }

  Future<List<String>> _copyLogs(List<DishLog> logs, DateTime day) async {
    final db = await _databaseService.database;
    final copies = <(DishLog, DateTime)>[
      for (final log in logs)
        (
          log,
          DateTime(
            day.year,
            day.month,
            day.day,
            log.loggedAt.hour,
            log.loggedAt.minute,
            log.loggedAt.second,
          ),
        ),
    ];
    final ids = <String>[];
    await db.transaction((txn) async {
      for (final (log, loggedAt) in copies) {
        ids.add(
          await insertDishLogSnapshot(
            dishId: log.dishId,
            dishName: log.dishName,
            loggedAt: loggedAt,
            mealType: log.mealType,
            servingSize: log.servingSize,
            calories: log.calories,
            protein: log.protein,
            carbs: log.carbs,
            fat: log.fat,
            fiber: log.fiber,
            notes: log.notes,
            executor: txn,
          ),
        );
      }
    });
    for (final (log, loggedAt) in copies) {
      _writeLogToHealth(
        name: log.dishName ?? '',
        mealType: log.mealType,
        calories: log.calories,
        protein: log.protein,
        carbs: log.carbs,
        fat: log.fat,
        fiber: log.fiber,
        loggedAt: loggedAt,
      );
    }
    return ids;
  }

  /// Inserts a `dish_logs` row with an explicit snapshot (values already
  /// scaled by [servingSize]). Never writes to Health Connect, so restoring
  /// historical logs (import/backup) does not re-publish them. Pass
  /// [executor] to write inside a caller's transaction.
  Future<String> insertDishLogSnapshot({
    required String dishId,
    String? dishName,
    required DateTime loggedAt,
    required String mealType,
    required double servingSize,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    double fiber = 0.0,
    String? notes,
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await _databaseService.database;
    final logId = '${DateTime.now().microsecondsSinceEpoch}-${_logSequence++}';
    final trimmedNotes = notes?.trim();

    await db.insert('dish_logs', {
      'id': logId,
      'dish_id': dishId,
      'dish_name': dishName,
      // Local time, matching the local day bounds used by every range query.
      'logged_at': loggedAt.toLocal().toIso8601String(),
      'meal_type': mealType,
      'serving_size': servingSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'notes':
          trimmedNotes == null || trimmedNotes.isEmpty ? null : trimmedNotes,
    });

    return logId;
  }

  /// Writes one logged meal (already scaled values) to Health Connect /
  /// Apple Health. Non-blocking – errors are logged but never block logging.
  Future<void> _writeLogToHealth({
    required String name,
    required String mealType,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double fiber,
    double sugar = 0,
    double sodium = 0,
    required DateTime loggedAt,
  }) async {
    try {
      if (!_healthService.isConnected) return;

      // Check if write-meals preference is enabled
      final prefs = await SharedPreferences.getInstance();
      final writeMealsEnabled =
          prefs.getBool('health_write_meals_enabled') ?? true;
      if (!writeMealsEnabled) return;

      await _healthService.writeMealToHealth(
        name: name,
        mealType: mealType,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        fiber: fiber > 0 ? fiber : null,
        sugar: sugar > 0 ? sugar : null,
        sodium: sodium > 0 ? sodium : null,
        startTime: loggedAt,
      );
    } catch (e) {
      debugPrint('HealthService nutrition write failed: $e');
    }
  }

  Future<List<DishLog>> getDishLogsForDate(DateTime date) async {
    final db = await _databaseService.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    // Next local midnight; a DST day is 23 or 25 hours long.
    final endOfDay = DateTime(date.year, date.month, date.day + 1);

    final List<Map<String, dynamic>> logMaps = await db.query(
      'dish_logs',
      where: 'logged_at >= ? AND logged_at < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'logged_at ASC',
    );

    return logMaps.map((map) => DishLog.fromJson(map)).toList();
  }

  Future<Dish?> getDish(String id) => getDishById(id);

  Future<List<int>> getDatesWithLogsInMonth(int year, int month) async {
    final db = await _databaseService.database;
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT DISTINCT strftime('%d', logged_at) as day
      FROM dish_logs
      WHERE logged_at >= ? AND logged_at < ?
      ORDER BY day
      ''',
      [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
    );

    return result.map((row) => int.parse(row['day'] as String)).toList();
  }

  /// Returns ledger nutrition totals keyed by local day in the half-open range.
  Future<Map<String, NutritionInfo>> getDailyNutritionTotals(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = startDate.toLocal();
    final end = endDate.toLocal();
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day);
    if (!startOfDay.isBefore(endOfDay)) return {};

    final db = await _databaseService.database;
    final rows = await db.rawQuery(
      '''
      SELECT substr(logged_at, 1, 10) AS day,
        SUM(calories) AS calories, SUM(protein) AS protein,
        SUM(carbs) AS carbs, SUM(fat) AS fat, SUM(fiber) AS fiber
      FROM dish_logs
      WHERE logged_at >= ? AND logged_at < ?
      GROUP BY substr(logged_at, 1, 10)
      ORDER BY day
      ''',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return {
      for (final row in rows)
        row['day'] as String: NutritionInfo(
          calories: (row['calories'] as num).toDouble(),
          protein: (row['protein'] as num).toDouble(),
          carbs: (row['carbs'] as num).toDouble(),
          fat: (row['fat'] as num).toDouble(),
          fiber: (row['fiber'] as num).toDouble(),
        ),
    };
  }

  Future<DailyMacroSummary> getMacroSummaryForDate(DateTime date) async {
    final db = await _databaseService.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day + 1);

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT 
        COALESCE(SUM(calories), 0) as total_calories,
        COALESCE(SUM(protein), 0) as total_protein,
        COALESCE(SUM(carbs), 0) as total_carbs,
        COALESCE(SUM(fat), 0) as total_fat,
        COALESCE(SUM(fiber), 0) as total_fiber
      FROM dish_logs
      WHERE logged_at >= ? AND logged_at < ?
      ''',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    final row = result.first;
    final baseSummary = DailyMacroSummary(
      calories: (row['total_calories'] as num).toDouble(),
      protein: (row['total_protein'] as num).toDouble(),
      carbs: (row['total_carbs'] as num).toDouble(),
      fat: (row['total_fat'] as num).toDouble(),
      fiber: (row['total_fiber'] as num).toDouble(),
      isHealthConnected: _healthService.isConnected,
    ); // Try to get calories burned for this date
    final (caloriesBurned, isEstimated) = await _calorieExpenditureService
        .getCaloriesBurnedForDateWithStatus(date);

    return baseSummary.copyWithCaloriesBurned(
      caloriesBurned,
      isEstimated: isEstimated,
      isHealthConnected: _healthService.isConnected,
    );
  }

  Future<void> deleteDishLog(String logId) async {
    final db = await _databaseService.database;
    await db.delete('dish_logs', where: 'id = ?', whereArgs: [logId]);
  }

  Future<bool> saveDishFromImport(Map<String, dynamic> dishData) async {
    try {
      final db = await _databaseService.database;

      // Parse category with fallback
      String category =
          dishData['category'] ?? dishData['defaultMealType'] ?? 'lunch';

      // Ensure category is one of the valid meal types
      if (![
        'breakfast',
        'lunch',
        'dinner',
        'snack',
      ].contains(category.toLowerCase())) {
        category = 'lunch';
      }

      // Start transaction
      await db.transaction((txn) async {
        // Insert dish with safe null handling
        await txn.insert('dishes', {
          'id': dishData['id'] ?? _generateId(),
          'name': dishData['name'] ?? 'Unknown Dish',
          'description': dishData['description'] ?? '',
          'image_url': dishData['imageUrl'] ?? dishData['imageUri'] ?? '',
          'category': category,
          'is_favorite': (dishData['isFavorite'] == true) ? 1 : 0,
          'created_at':
              dishData['createdAt'] ?? DateTime.now().toIso8601String(),
          'updated_at':
              dishData['updatedAt'] ?? DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // Insert nutrition with safe parsing
        final nutrition = dishData['nutrition'] as Map<String, dynamic>? ?? {};
        await txn.insert('dish_nutrition', {
          'dish_id': dishData['id'],
          'calories':
              _safeParseDouble(nutrition['calories'] ?? dishData['calories']) ??
              0.0,
          'protein':
              _safeParseDouble(nutrition['protein'] ?? dishData['protein']) ??
              0.0,
          'carbs':
              _safeParseDouble(nutrition['carbs'] ?? dishData['carbs']) ?? 0.0,
          'fat': _safeParseDouble(nutrition['fat'] ?? dishData['fat']) ?? 0.0,
          'fiber':
              _safeParseDouble(nutrition['fiber'] ?? dishData['fiber']) ?? 0.0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        // Insert ingredients with safe parsing
        final ingredients = dishData['ingredients'] as List<dynamic>? ?? [];
        // Re-importing a dish replaces its links instead of duplicating them.
        await txn.delete(
          'dish_ingredients',
          where: 'dish_id = ?',
          whereArgs: [dishData['id']],
        );
        for (final ingredientData in ingredients) {
          if (ingredientData is Map<String, dynamic>) {
            final ingredientId = ingredientData['id'] ?? _generateId();

            // Insert or replace ingredient record
            await txn.insert('ingredients', {
              'id': ingredientId,
              'name': ingredientData['name'] ?? 'Unknown Ingredient',
              'barcode': ingredientData['barcode'],
            }, conflictAlgorithm: ConflictAlgorithm.replace);

            // Insert ingredient nutrition
            await txn.insert('ingredient_nutrition', {
              'ingredient_id': ingredientId,
              'calories':
                  _safeParseDouble(
                    ingredientData['caloriesPer100'] ??
                        ingredientData['calories'],
                  ) ??
                  0.0,
              'protein':
                  _safeParseDouble(
                    ingredientData['proteinPer100'] ??
                        ingredientData['protein'],
                  ) ??
                  0.0,
              'carbs':
                  _safeParseDouble(
                    ingredientData['carbsPer100'] ?? ingredientData['carbs'],
                  ) ??
                  0.0,
              'fat':
                  _safeParseDouble(
                    ingredientData['fatPer100'] ?? ingredientData['fat'],
                  ) ??
                  0.0,
              'fiber':
                  _safeParseDouble(
                    ingredientData['fiberPer100'] ?? ingredientData['fiber'],
                  ) ??
                  0.0,
            }, conflictAlgorithm: ConflictAlgorithm.replace);

            // Insert dish-ingredient relationship
            await txn.insert('dish_ingredients', {
              'dish_id': dishData['id'],
              'ingredient_id': ingredientId,
              'amount':
                  _safeParseDouble(
                    ingredientData['quantity'] ?? ingredientData['amount'],
                  ) ??
                  0.0,
              'unit': ingredientData['unit'] ?? 'g',
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      });

      return true;
    } catch (e) {
      debugPrint('Error saving dish from import: $e');
      return false;
    }
  }

  /// Safely parses a value to double, handling null and various types
  double? _safeParseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    if (value is String) {
      if (value.isEmpty) return null;
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
