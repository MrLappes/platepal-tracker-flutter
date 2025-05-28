import '../services/storage/meal_log_service.dart';
import '../services/user_session_service.dart';

/// Repository for meal-related operations
class MealRepository {
  final MealLogService _mealLogService;
  final UserSessionService _userSessionService;

  MealRepository({
    MealLogService? mealLogService,
    required UserSessionService userSessionService,
  }) : _mealLogService = mealLogService ?? MealLogService(),
       _userSessionService = userSessionService;

  /// Log a meal
  Future<int> logMeal({
    required String userId,
    required String dishId,
    required double servingSize,
    required String mealType,
    DateTime? loggedAt,
  }) async {
    try {
      return await _mealLogService.logMeal(
        userId: userId,
        dishId: dishId,
        servingSize: servingSize,
        mealType: mealType,
        loggedAt: loggedAt,
      );
    } catch (e) {
      throw Exception('Failed to log meal: $e');
    }
  }

  /// Get current user's meals by date range
  Future<List<MealLog>> getCurrentUserMealsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _userSessionService.getCurrentUserId();
      return await _mealLogService.getMealsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get current user meals: $e');
    }
  }

  /// Get current user's meals by date
  Future<List<MealLog>> getCurrentUserMealsByDate({
    required DateTime date,
  }) async {
    try {
      final userId = _userSessionService.getCurrentUserId();
      return await _mealLogService.getMealsByDate(userId: userId, date: date);
    } catch (e) {
      throw Exception('Failed to get current user meals for date: $e');
    }
  }

  /// Get meals by date range
  Future<List<MealLog>> getMealsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _mealLogService.getMealsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get meals: $e');
    }
  }

  /// Get meals by date
  Future<List<MealLog>> getMealsByDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      return await _mealLogService.getMealsByDate(userId: userId, date: date);
    } catch (e) {
      throw Exception('Failed to get meals for date: $e');
    }
  }

  /// Get nutrition summary
  Future<dynamic> getNutritionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _mealLogService.getNutritionSummary(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get nutrition summary: $e');
    }
  }

  /// Delete meal log
  Future<void> deleteMealLog(int id) async {
    try {
      await _mealLogService.deleteMealLog(id);
    } catch (e) {
      throw Exception('Failed to delete meal log: $e');
    }
  }
}
