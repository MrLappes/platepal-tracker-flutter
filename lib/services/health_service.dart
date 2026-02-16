import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:developer' as developer;

enum HealthConnectionError { platformNotSupported, permissionDenied, unknown }

class HealthConnectionResult {
  final bool success;
  final HealthConnectionError? error;
  final String message;

  HealthConnectionResult({
    required this.success,
    this.error,
    required this.message,
  });
}

/// Overhauled HealthService – focused on:
///  • READ  calories burned (ACTIVE_ENERGY_BURNED + TOTAL_CALORIES_BURNED)
///  • WRITE nutrition records via [writeMealToHealth]
///
/// Auto-sync timer removed – callers trigger syncs on-demand
/// (app launch, screen visits).
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  // ── Data types & permissions ────────────────────────────────────────
  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.NUTRITION,
  ];

  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ, // ACTIVE_ENERGY_BURNED
    HealthDataAccess.READ, // TOTAL_CALORIES_BURNED
    HealthDataAccess.READ_WRITE, // NUTRITION
  ];

  // ── State ───────────────────────────────────────────────────────────
  bool _isConnected = false;
  DateTime? _lastSyncDate;

  // Stream controller for connection status changes
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  // ── Platform availability ───────────────────────────────────────────

  /// Check if health data is supported on this platform
  Future<bool> isHealthDataAvailable() async {
    try {
      return Health().isDataTypeAvailable(HealthDataType.ACTIVE_ENERGY_BURNED);
    } catch (e) {
      developer.log(
        'Error checking health data availability: $e',
        name: 'HealthService',
      );
      return false;
    }
  }

  /// Check if we have permissions for health data
  Future<bool> hasHealthPermissions() async {
    try {
      return await Health().hasPermissions(
            _healthDataTypes,
            permissions: _permissions,
          ) ??
          false;
    } catch (e) {
      developer.log(
        'Error checking health permissions: $e',
        name: 'HealthService',
      );
      return false;
    }
  }

  // ── Connection management ───────────────────────────────────────────

  /// Request permissions and connect to health data
  Future<bool> connectToHealth() async {
    try {
      bool authorized = await Health().requestAuthorization(
        _healthDataTypes,
        permissions: _permissions,
      );

      if (authorized) {
        _isConnected = true;
        await _saveConnectionStatus(true);
        _connectionStatusController.add(true);
        developer.log(
          'Successfully connected to health data',
          name: 'HealthService',
        );
        return true;
      } else {
        developer.log(
          'Health data authorization denied',
          name: 'HealthService',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        'Error connecting to health data: $e',
        name: 'HealthService',
      );
      return false;
    }
  }

  /// Request permissions and connect to health data with detailed error info
  Future<HealthConnectionResult> connectToHealthWithDetails() async {
    try {
      bool available = await isHealthDataAvailable();

      if (!available) {
        return HealthConnectionResult(
          success: false,
          error: HealthConnectionError.platformNotSupported,
          message: 'Health data is not available on this device',
        );
      }

      bool authorized = await Health().requestAuthorization(
        _healthDataTypes,
        permissions: _permissions,
      );

      if (authorized) {
        _isConnected = true;
        await _saveConnectionStatus(true);
        _connectionStatusController.add(true);
        developer.log(
          'Successfully connected to health data',
          name: 'HealthService',
        );
        return HealthConnectionResult(
          success: true,
          error: null,
          message: 'Successfully connected to health data',
        );
      } else {
        developer.log(
          'Health data authorization denied',
          name: 'HealthService',
        );
        return HealthConnectionResult(
          success: false,
          error: HealthConnectionError.permissionDenied,
          message: 'Health data authorization was denied by the user',
        );
      }
    } catch (e) {
      developer.log(
        'Error connecting to health data: $e',
        name: 'HealthService',
      );
      return HealthConnectionResult(
        success: false,
        error: HealthConnectionError.unknown,
        message: 'An error occurred while connecting to health data: $e',
      );
    }
  }

  /// Disconnect from health data
  Future<void> disconnectFromHealth() async {
    _isConnected = false;
    _lastSyncDate = null;
    await _saveConnectionStatus(false);
    await _clearLastSyncDate();
    _connectionStatusController.add(false);
    developer.log('Disconnected from health data', name: 'HealthService');
  }

  // ── Calories burned (READ) ──────────────────────────────────────────

  /// Get today's burned calories
  Future<double?> getTodaysBurnedCalories() async {
    if (!_isConnected) return null;

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      return await _fetchCaloriesBurnedBetween(startOfDay, now);
    } catch (e) {
      developer.log(
        'Error getting today\'s burned calories: $e',
        name: 'HealthService',
      );
      return null;
    }
  }

  /// Get calories burned for a specific date
  Future<double?> getCaloriesBurnedForDate(DateTime date) async {
    if (!_isConnected) return null;

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      return await _fetchCaloriesBurnedBetween(startOfDay, endOfDay);
    } catch (e) {
      developer.log(
        'Error getting calories burned for date ${date.toIso8601String()}: $e',
        name: 'HealthService',
      );
      return null;
    }
  }

  /// Smart calorie-burn fetch: prefers TOTAL_CALORIES_BURNED,
  /// falls back to ACTIVE_ENERGY_BURNED.
  Future<double?> getCaloriesBurnedForDateSmart(DateTime date) async {
    if (!_isConnected) return null;

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED,
        ],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      double activeCalories = 0.0;
      double totalCalories = 0.0;

      for (HealthDataPoint point in healthData) {
        final numericValue = _extractNumericValue(point.value);
        if (numericValue != null) {
          if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            activeCalories += numericValue;
          } else if (point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
            totalCalories += numericValue;
          }
        }
      }

      developer.log(
        'Smart calories for ${date.toIso8601String().split('T')[0]}: '
        'Active=$activeCalories, Total=$totalCalories',
        name: 'HealthService',
      );

      if (totalCalories > 0) return totalCalories;
      if (activeCalories > 0) return activeCalories;
      return null;
    } catch (e) {
      developer.log(
        'Error getting smart calories for ${date.toIso8601String()}: $e',
        name: 'HealthService',
      );
      return null;
    }
  }

  /// Refresh the locally-cached calorie-burn data for the last [days] days.
  /// Call on app launch & screen visits.
  Future<Map<String, double>> refreshCaloriesBurnedCache({int days = 7}) async {
    if (!_isConnected) return {};

    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED,
        ],
        startTime: startDate,
        endTime: now,
      );

      // Bucket active vs total per day
      Map<String, double> activeCalories = {};
      Map<String, double> totalCalories = {};

      for (HealthDataPoint point in healthData) {
        final numericValue = _extractNumericValue(point.value);
        if (numericValue != null) {
          String dateKey = point.dateFrom.toIso8601String().split('T')[0];
          if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            activeCalories[dateKey] =
                (activeCalories[dateKey] ?? 0.0) + numericValue;
          } else if (point.type == HealthDataType.TOTAL_CALORIES_BURNED) {
            totalCalories[dateKey] =
                (totalCalories[dateKey] ?? 0.0) + numericValue;
          }
        }
      }

      // Prefer total, fall back to active
      Map<String, double> dailyCalories = {};
      Set<String> allDates = {...activeCalories.keys, ...totalCalories.keys};
      for (String dateKey in allDates) {
        double total = totalCalories[dateKey] ?? 0.0;
        double active = activeCalories[dateKey] ?? 0.0;
        dailyCalories[dateKey] = total > 0 ? total : active;
      }

      // Persist
      await storeCaloriesBurnedData(dailyCalories);

      // Update last sync date
      _lastSyncDate = now;
      await _saveLastSyncDate(now);

      developer.log(
        'Refreshed calorie cache for ${dailyCalories.length} days',
        name: 'HealthService',
      );
      return dailyCalories;
    } catch (e) {
      developer.log(
        'Error refreshing calorie cache: $e',
        name: 'HealthService',
      );
      return {};
    }
  }

  // ── Nutrition records (WRITE) ───────────────────────────────────────

  /// Write a nutrition / meal record to Health Connect / Apple Health.
  ///
  /// Maps the PlatePal meal type string (breakfast, lunch, dinner, snack)
  /// to the health package's [MealType] enum.
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
    if (!_isConnected) {
      developer.log(
        'Not connected – skipping nutrition write',
        name: 'HealthService',
      );
      return false;
    }

    try {
      final healthMealType = _toHealthMealType(mealType);
      final effectiveEndTime =
          endTime ?? startTime.add(const Duration(minutes: 15));

      final success = await Health().writeMeal(
        mealType: healthMealType,
        startTime: startTime,
        endTime: effectiveEndTime,
        name: name,
        caloriesConsumed: calories,
        protein: protein,
        carbohydrates: carbs,
        fatTotal: fat,
        fiber: fiber,
        sugar: sugar,
        sodium: sodium,
      );

      developer.log(
        'writeMealToHealth "$name" ($mealType) – success=$success',
        name: 'HealthService',
      );
      return success;
    } catch (e) {
      developer.log('Error writing meal to health: $e', name: 'HealthService');
      return false;
    }
  }

  // ── Local cache for calories burned ─────────────────────────────────

  /// Store calories burned data locally for persistence
  Future<void> storeCaloriesBurnedData(Map<String, double> caloriesData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Merge with existing stored data so we don't lose older entries
      final existing = await getStoredCaloriesBurnedData();
      existing.addAll(caloriesData);

      await prefs.setString(
        'health_calories_burned',
        existing.entries.map((e) => '${e.key}:${e.value}').join(','),
      );

      developer.log(
        'Stored calories burned data for ${existing.length} days',
        name: 'HealthService',
      );
    } catch (e) {
      developer.log(
        'Error storing calories burned data: $e',
        name: 'HealthService',
      );
    }
  }

  /// Get stored calories burned data
  Future<Map<String, double>> getStoredCaloriesBurnedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('health_calories_burned');

      if (storedData == null || storedData.isEmpty) return {};

      Map<String, double> caloriesData = {};
      final entries = storedData.split(',');

      for (String entry in entries) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          caloriesData[parts[0]] = double.tryParse(parts[1]) ?? 0.0;
        }
      }

      return caloriesData;
    } catch (e) {
      developer.log(
        'Error getting stored calories burned data: $e',
        name: 'HealthService',
      );
      return {};
    }
  }

  // ── Getters ─────────────────────────────────────────────────────────

  /// Check if currently connected to health data
  bool get isConnected => _isConnected;

  /// Get last sync date
  DateTime? get lastSyncDate => _lastSyncDate;

  // ── Persistence helpers ─────────────────────────────────────────────

  /// Load connection status from shared preferences
  Future<void> loadConnectionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isConnected = prefs.getBool('health_connected') ?? false;

      final lastSyncTimestamp = prefs.getInt('health_last_sync');
      if (lastSyncTimestamp != null) {
        _lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
      }

      developer.log(
        'Loaded health connection status: $_isConnected',
        name: 'HealthService',
      );
    } catch (e) {
      developer.log(
        'Error loading health connection status: $e',
        name: 'HealthService',
      );
    }
  }

  Future<void> _saveConnectionStatus(bool connected) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('health_connected', connected);
    } catch (e) {
      developer.log(
        'Error saving health connection status: $e',
        name: 'HealthService',
      );
    }
  }

  Future<void> _saveLastSyncDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('health_last_sync', date.millisecondsSinceEpoch);
    } catch (e) {
      developer.log(
        'Error saving health last sync date: $e',
        name: 'HealthService',
      );
    }
  }

  Future<void> _clearLastSyncDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('health_last_sync');
    } catch (e) {
      developer.log(
        'Error clearing health last sync date: $e',
        name: 'HealthService',
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _connectionStatusController.close();
  }

  // ── Private helpers ─────────────────────────────────────────────────

  /// Fetch and sum calorie-burn data between two timestamps.
  Future<double?> _fetchCaloriesBurnedBetween(
    DateTime start,
    DateTime end,
  ) async {
    List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
      types: [
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.TOTAL_CALORIES_BURNED,
      ],
      startTime: start,
      endTime: end,
    );

    double totalCalories = 0.0;
    for (HealthDataPoint point in healthData) {
      final numericValue = _extractNumericValue(point.value);
      if (numericValue != null) {
        totalCalories += numericValue;
      }
    }

    return totalCalories > 0 ? totalCalories : null;
  }

  /// Extract numeric value from HealthValue
  double? _extractNumericValue(HealthValue value) {
    try {
      if (value is NumericHealthValue) {
        return value.numericValue.toDouble();
      }
      return null;
    } catch (e) {
      developer.log(
        'Error extracting numeric value from HealthValue: $e',
        name: 'HealthService',
      );
      return null;
    }
  }

  /// Map PlatePal meal type string to health package MealType
  MealType _toHealthMealType(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return MealType.BREAKFAST;
      case 'lunch':
        return MealType.LUNCH;
      case 'dinner':
        return MealType.DINNER;
      case 'snack':
        return MealType.SNACK;
      default:
        return MealType.UNKNOWN;
    }
  }
}
