import 'package:sqflite/sqflite.dart';
import '../../models/dish.dart';
import 'database_service.dart';

class DishService {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Get all dishes
  Future<List<Dish>> getAllDishes() async {
    final db = await _databaseService.database;

    // Get all dishes
    final List<Map<String, dynamic>> dishMaps = await db.query('dishes');

    return Future.wait(
      dishMaps.map((dishMap) => _getDishWithRelations(dishMap)),
    );
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
        ingredientNutrition = NutritionInfo(
          calories: ingNutritionMaps.first['calories'] as double,
          protein: ingNutritionMaps.first['protein'] as double,
          carbs: ingNutritionMaps.first['carbs'] as double,
          fat: ingNutritionMaps.first['fat'] as double,
          fiber: ingNutritionMaps.first['fiber'] as double,
          sugar: ingNutritionMaps.first['sugar'] as double,
          sodium: ingNutritionMaps.first['sodium'] as double,
          // No micronutrients as per requirement
        );
      }

      ingredients.add(
        Ingredient(
          id: ingredientId,
          name: diMap['name'] as String,
          amount: diMap['amount'] as double,
          unit: diMap['unit'] as String,
          barcode: diMap['barcode'] as String?,
          nutrition: ingredientNutrition,
        ),
      );
    }

    // Construct dish nutrition info
    final NutritionInfo dishNutrition;
    if (nutritionMaps.isNotEmpty) {
      dishNutrition = NutritionInfo(
        calories: nutritionMaps.first['calories'] as double,
        protein: nutritionMaps.first['protein'] as double,
        carbs: nutritionMaps.first['carbs'] as double,
        fat: nutritionMaps.first['fat'] as double,
        fiber: nutritionMaps.first['fiber'] as double,
        sugar: nutritionMaps.first['sugar'] as double,
        sodium: nutritionMaps.first['sodium'] as double,
        // No micronutrients as per requirement
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

    // Return the complete dish
    return Dish(
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
  }

  // Save a new dish
  Future<Dish> saveDish(Dish dish) async {
    final db = await _databaseService.database;

    await db.transaction((txn) async {
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

      // Insert dish nutrition
      await txn.insert('dish_nutrition', {
        'dish_id': dish.id,
        'calories': dish.nutrition.calories,
        'protein': dish.nutrition.protein,
        'carbs': dish.nutrition.carbs,
        'fat': dish.nutrition.fat,
        'fiber': dish.nutrition.fiber,
        'sugar': dish.nutrition.sugar,
        'sodium': dish.nutrition.sodium,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Insert ingredients and their relationships
      for (final ingredient in dish.ingredients) {
        // Insert ingredient if not exists
        await txn.insert('ingredients', {
          'id': ingredient.id,
          'name': ingredient.name,
          'barcode': ingredient.barcode,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        // Insert ingredient nutrition if available
        if (ingredient.nutrition != null) {
          await txn.insert('ingredient_nutrition', {
            'ingredient_id': ingredient.id,
            'calories': ingredient.nutrition!.calories,
            'protein': ingredient.nutrition!.protein,
            'carbs': ingredient.nutrition!.carbs,
            'fat': ingredient.nutrition!.fat,
            'fiber': ingredient.nutrition!.fiber,
            'sugar': ingredient.nutrition!.sugar,
            'sodium': ingredient.nutrition!.sodium,
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
      );

      // Update dish nutrition
      await txn.update(
        'dish_nutrition',
        {
          'calories': dish.nutrition.calories,
          'protein': dish.nutrition.protein,
          'carbs': dish.nutrition.carbs,
          'fat': dish.nutrition.fat,
          'fiber': dish.nutrition.fiber,
          'sugar': dish.nutrition.sugar,
          'sodium': dish.nutrition.sodium,
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
        // Insert ingredient if not exists
        await txn.insert('ingredients', {
          'id': ingredient.id,
          'name': ingredient.name,
          'barcode': ingredient.barcode,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        // Insert or update ingredient nutrition if available
        if (ingredient.nutrition != null) {
          await txn.insert('ingredient_nutrition', {
            'ingredient_id': ingredient.id,
            'calories': ingredient.nutrition!.calories,
            'protein': ingredient.nutrition!.protein,
            'carbs': ingredient.nutrition!.carbs,
            'fat': ingredient.nutrition!.fat,
            'fiber': ingredient.nutrition!.fiber,
            'sugar': ingredient.nutrition!.sugar,
            'sodium': ingredient.nutrition!.sodium,
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

  // Delete a dish
  Future<void> deleteDish(String id) async {
    final db = await _databaseService.database;

    await db.delete('dishes', where: 'id = ?', whereArgs: [id]);
  }

  // Toggle dish favorite status
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await _databaseService.database;

    await db.update(
      'dishes',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
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
  Future<String> logDish({
    required String dishId,
    required DateTime loggedAt,
    required String mealType,
    required double servingSize,
  }) async {
    final db = await _databaseService.database;

    // Get the dish to calculate nutrition values
    final dish = await getDishById(dishId);
    if (dish == null) {
      throw Exception('Dish not found');
    }

    // Calculate nutrition values based on serving size
    final calories = dish.nutrition.calories * servingSize;
    final protein = dish.nutrition.protein * servingSize;
    final carbs = dish.nutrition.carbs * servingSize;
    final fat = dish.nutrition.fat * servingSize;
    final fiber = dish.nutrition.fiber * servingSize;

    final logId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert('dish_logs', {
      'id': logId,
      'dish_id': dishId,
      'logged_at': loggedAt.toIso8601String(),
      'meal_type': mealType,
      'serving_size': servingSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    });

    return logId;
  }

  Future<List<DishLog>> getDishLogsForDate(DateTime date) async {
    final db = await _databaseService.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

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

  Future<DailyMacroSummary> getMacroSummaryForDate(DateTime date) async {
    final db = await _databaseService.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

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
    return DailyMacroSummary(
      calories: (row['total_calories'] as num).toDouble(),
      protein: (row['total_protein'] as num).toDouble(),
      carbs: (row['total_carbs'] as num).toDouble(),
      fat: (row['total_fat'] as num).toDouble(),
      fiber: (row['total_fiber'] as num).toDouble(),
    );
  }

  Future<void> deleteDishLog(String logId) async {
    final db = await _databaseService.database;
    await db.delete('dish_logs', where: 'id = ?', whereArgs: [logId]);
  }
}
