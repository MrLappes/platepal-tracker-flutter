import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'dish_service.dart';
import 'user_profile_service.dart';
import 'meal_log_service.dart';

class StorageServiceProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  // Change from late final to late - allowing reassignment during reset
  late UserProfileService userProfileService;
  late DishService dishService;
  late MealLogService mealLogService;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String? _initializationError;
  String? get initializationError => _initializationError;

  // Initialize all services
  Future<void> initialize() async {
    try {
      // Initialize services
      userProfileService = UserProfileService();
      dishService = DishService();
      mealLogService = MealLogService();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _initializationError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Clean up resources
  Future<void> closeDatabase() async {
    await _databaseService.close();
  }

  /// Completely resets all application data including database and SharedPreferences
  Future<void> resetAllData() async {
    try {
      // Close existing database connections
      await closeDatabase();

      // Reset the database
      await _databaseService.resetDatabase();

      // Clear all SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset initialization state
      _isInitialized = false;
      _initializationError = null;

      // Re-initialize services
      await initialize();
    } catch (e) {
      throw Exception('Failed to reset application data: $e');
    }
  }

  @override
  void dispose() {
    // Close database connections asynchronously
    closeDatabase();
    super.dispose();
  }
}
