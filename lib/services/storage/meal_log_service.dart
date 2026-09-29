import '../../models/dish.dart';
import 'database_service.dart';
import 'dish_service.dart';

/// Meal-log API used by statistics and chat context.
///
/// Backed by the canonical `dish_logs` ledger (the legacy `meal_logs` table is
/// no longer read or written). The ledger is single-user, so `userId`
/// arguments are accepted for compatibility but do not filter.
class MealLogService {
  final DatabaseService _databaseService = DatabaseService.instance;
  final DishService _dishService = DishService();

  // Log a meal; returns the dish_logs rowid.
  Future<int> logMeal({
    required String userId,
    required String dishId,
    required double servingSize,
    required String mealType, // breakfast, lunch, dinner, snack
    DateTime? loggedAt,
  }) async {
    final logId = await _dishService.logDish(
      dishId: dishId,
      loggedAt: loggedAt ?? DateTime.now(),
      mealType: mealType,
      servingSize: servingSize,
    );
    final db = await _databaseService.database;
    final rows = await db.rawQuery(
      'SELECT rowid AS row_id FROM dish_logs WHERE id = ?',
      [logId],
    );
    return rows.first['row_id'] as int;
  }

  /// Logs with `startDate <= logged_at < endDate` (local time), newest first.
  Future<List<MealLog>> getMealsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final rows = await _queryRange(startDate, endDate);
    return rows.map((row) => _mealLogFromRow(row, userId)).toList();
  }

  Future<List<Map<String, dynamic>>> _queryRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    return db.rawQuery(
      '''
      SELECT rowid AS row_id, * FROM dish_logs
      WHERE logged_at >= ? AND logged_at < ?
      ORDER BY logged_at DESC
      ''',
      [
        startDate.toLocal().toIso8601String(),
        endDate.toLocal().toIso8601String(),
      ],
    );
  }

  /// Builds a [MealLog] purely from the snapshot; the dish may be gone.
  MealLog _mealLogFromRow(Map<String, dynamic> row, String userId) {
    final servingSize = (row['serving_size'] as num).toDouble();
    // Snapshot is stored per log; MealLog consumers multiply by servingSize.
    double perServing(String column) {
      final total = (row[column] as num?)?.toDouble() ?? 0.0;
      return servingSize > 0 ? total / servingSize : total;
    }

    final loggedAt = DateTime.parse(row['logged_at'] as String);
    return MealLog(
      id: row['row_id'] as int,
      userId: userId,
      dish: Dish(
        id: row['dish_id'] as String,
        name: (row['dish_name'] as String?) ?? 'Unknown dish',
        ingredients: const [],
        nutrition: NutritionInfo(
          calories: perServing('calories'),
          protein: perServing('protein'),
          carbs: perServing('carbs'),
          fat: perServing('fat'),
          fiber: perServing('fiber'),
        ),
        createdAt: loggedAt,
        updatedAt: loggedAt,
      ),
      servingSize: servingSize,
      mealType: row['meal_type'] as String,
      loggedAt: loggedAt,
    );
  }

  // Get meals by date
  Future<List<MealLog>> getMealsByDate({
    required String userId,
    required DateTime date,
  }) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day + 1);

    return getMealsByDateRange(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Delete meal log by the rowid exposed as MealLog.id
  Future<void> deleteMealLog(int id) async {
    final db = await _databaseService.database;

    await db.delete('dish_logs', where: 'rowid = ?', whereArgs: [id]);
  }

  // Get nutrition summary for a date range (half-open, see getMealsByDateRange)
  Future<NutritionSummary> getNutritionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final rows = await _queryRange(startDate, endDate);

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    final List<MealLog> mealLogs = [];
    final Map<String, List<MealLog>> mealsByType = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };

    for (final row in rows) {
      totalCalories += (row['calories'] as num?)?.toDouble() ?? 0;
      totalProtein += (row['protein'] as num?)?.toDouble() ?? 0;
      totalCarbs += (row['carbs'] as num?)?.toDouble() ?? 0;
      totalFat += (row['fat'] as num?)?.toDouble() ?? 0;
      totalFiber += (row['fiber'] as num?)?.toDouble() ?? 0;

      final mealLog = _mealLogFromRow(row, userId);
      mealLogs.add(mealLog);
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
