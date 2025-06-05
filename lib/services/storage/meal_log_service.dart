import 'package:sqflite/sqflite.dart';
import '../../models/dish.dart';
import 'database_service.dart';
import 'dish_service.dart';

class MealLogService {
  final DatabaseService _databaseService = DatabaseService.instance;
  final DishService _dishService = DishService();

  // Log a meal
  Future<int> logMeal({
    required String userId,
    required String dishId,
    required double servingSize,
    required String mealType, // breakfast, lunch, dinner, snack
    DateTime? loggedAt,
  }) async {
    final db = await _databaseService.database;

    final int id = await db.insert('meal_logs', {
      'user_id': userId,
      'dish_id': dishId,
      'serving_size': servingSize,
      'meal_type': mealType,
      'logged_at': (loggedAt ?? DateTime.now()).toIso8601String(),
    });

    return id;
  }

  // Get meals by date range
  Future<List<MealLog>> getMealsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _databaseService.database;

    final List<Map<String, dynamic>> mealMaps = await db.query(
      'meal_logs',
      where: 'user_id = ? AND logged_at >= ? AND logged_at <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'logged_at DESC',
    );

    return Future.wait(
      mealMaps.map((mealMap) async {
        final String dishId = mealMap['dish_id'] as String;
        final Dish? dish = await _dishService.getDishById(dishId);

        if (dish == null) {
          throw Exception('Dish not found for meal log');
        }

        return MealLog(
          id: mealMap['id'] as int,
          userId: mealMap['user_id'] as String,
          dish: dish,
          servingSize: mealMap['serving_size'] as double,
          mealType: mealMap['meal_type'] as String,
          loggedAt: DateTime.parse(mealMap['logged_at'] as String),
        );
      }),
    );
  }

  // Get meals by date
  Future<List<MealLog>> getMealsByDate({
    required String userId,
    required DateTime date,
  }) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    return getMealsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Delete meal log
  Future<void> deleteMealLog(int id) async {
    final db = await _databaseService.database;

    await db.delete('meal_logs', where: 'id = ?', whereArgs: [id]);
  }

  // Get nutrition summary for a date range
  Future<NutritionSummary> getNutritionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final mealLogs = await getMealsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    final Map<String, List<MealLog>> mealsByType = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };

    for (final mealLog in mealLogs) {
      final servingMultiplier = mealLog.servingSize;
      totalCalories += mealLog.dish.nutrition.calories * servingMultiplier;
      totalProtein += mealLog.dish.nutrition.protein * servingMultiplier;
      totalCarbs += mealLog.dish.nutrition.carbs * servingMultiplier;
      totalFat += mealLog.dish.nutrition.fat * servingMultiplier;
      totalFiber += mealLog.dish.nutrition.fiber * servingMultiplier;

      final type = mealLog.mealType.toLowerCase();
      if (mealsByType.containsKey(type)) {
        mealsByType[type]!.add(mealLog);
      } else {
        mealsByType['snack']!.add(mealLog);
      }
    }

    return NutritionSummary(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalFiber: totalFiber,
      mealLogs: mealLogs,
      mealsByType: mealsByType,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class MealLog {
  final int id;
  final String userId;
  final Dish dish;
  final double servingSize;
  final String mealType;
  final DateTime loggedAt;

  const MealLog({
    required this.id,
    required this.userId,
    required this.dish,
    required this.servingSize,
    required this.mealType,
    required this.loggedAt,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] as int,
      userId: json['userId'] as String,
      dish: Dish.fromJson(json['dish'] as Map<String, dynamic>),
      servingSize: (json['servingSize'] as num).toDouble(),
      mealType: json['mealType'] as String,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dish': dish.toJson(), // Assuming Dish has a toJson method
      'servingSize': servingSize,
      'mealType': mealType,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }
}

class NutritionSummary {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalFiber;
  final List<MealLog> mealLogs;
  final Map<String, List<MealLog>> mealsByType;
  final DateTime startDate;
  final DateTime endDate;

  const NutritionSummary({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalFiber,
    required this.mealLogs,
    required this.mealsByType,
    required this.startDate,
    required this.endDate,
  });
}
