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

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal(); // Health data types we want to read
  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED, // For Google Fit compatibility
    // Note: BASAL_ENERGY_BURNED requires special permission on Android
    // We'll handle this separately if available
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
  ];
  // Health permissions for reading data
  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ, // Permission for TOTAL_CALORIES_BURNED
    // Removed BASAL_ENERGY_BURNED permission
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  bool _isConnected = false;
  DateTime? _lastSyncDate;
  Timer? _autoSyncTimer;
  static const Duration _autoSyncInterval = Duration(
    hours: 2,
  ); // Auto-sync every 2 hours

  // Stream controller for connection status changes
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Check if health data is supported on this platform
  Future<bool> isHealthDataAvailable() async {
    try {
      // Check if the platform supports health data (Android Health Connect or iOS HealthKit)
      return Health().isDataTypeAvailable(HealthDataType.STEPS);
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

  /// Request permissions and connect to health data
  Future<bool> connectToHealth() async {
    try {
      // Request authorization for health data
      bool authorized = await Health().requestAuthorization(
        _healthDataTypes,
        permissions: _permissions,
      );

      if (authorized) {
        _isConnected = true;
        await _saveConnectionStatus(true);
        developer.log(
          'Successfully connected to health data',
          name: 'HealthService',
        );
        _connectionStatusController.add(true); // Emit connection status
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
      // First check if health data is available on this platform
      bool available = await isHealthDataAvailable();

      if (!available) {
        return HealthConnectionResult(
          success: false,
          error: HealthConnectionError.platformNotSupported,
          message: 'Health data is not available on this device',
        );
      }

      // Request authorization for health data
      bool authorized = await Health().requestAuthorization(
        _healthDataTypes,
        permissions: _permissions,
      );

      if (authorized) {
        _isConnected = true;
        await _saveConnectionStatus(true);
        _connectionStatusController.add(true);
        _startAutoSync(); // Start auto-sync when connected
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
    _stopAutoSync(); // Stop auto-sync when disconnected
    developer.log('Disconnected from health data', name: 'HealthService');
  }

  /// Start automatic health data synchronization
  void _startAutoSync() {
    _stopAutoSync(); // Cancel any existing timer

    if (_isConnected) {
      _autoSyncTimer = Timer.periodic(_autoSyncInterval, (timer) {
        _performAutoSync();
      });

      developer.log(
        'Started auto-sync with interval: ${_autoSyncInterval.inHours} hours',
        name: 'HealthService',
      );
    }
  }

  /// Stop automatic health data synchronization
  void _stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    developer.log('Stopped auto-sync', name: 'HealthService');
  }

  /// Perform automatic sync in the background
  Future<void> _performAutoSync() async {
    if (!_isConnected) {
      _stopAutoSync();
      return;
    }

    try {
      developer.log('Performing auto-sync...', name: 'HealthService');
      await syncHealthData(); // Also sync calories burned data using smart method
      await syncCaloriesBurnedDataSmart();

      developer.log('Auto-sync completed successfully', name: 'HealthService');
    } catch (e) {
      developer.log('Auto-sync failed: $e', name: 'HealthService');
    }
  }

  /// Sync health data and return user health metrics
  Future<Map<String, dynamic>?> syncHealthData() async {
    if (!_isConnected) {
      developer.log('Not connected to health data', name: 'HealthService');
      return null;
    }

    try {
      final now = DateTime.now();
      final startDate = now.subtract(
        const Duration(days: 30),
      ); // Get last 30 days of data      // Fetch health data
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: _healthDataTypes,
        startTime: startDate,
        endTime: now,
      );

      if (healthData.isEmpty) {
        developer.log('No health data found', name: 'HealthService');
        return null;
      }

      // Process and organize the health data
      Map<String, dynamic> processedData = _processHealthData(healthData);

      // Update last sync date
      _lastSyncDate = now;
      await _saveLastSyncDate(now);

      developer.log(
        'Successfully synced health data: ${processedData.keys}',
        name: 'HealthService',
      );
      return processedData;
    } catch (e) {
      developer.log('Error syncing health data: $e', name: 'HealthService');
      return null;
    }
  }

  /// Process raw health data into organized metrics
  Map<String, dynamic> _processHealthData(List<HealthDataPoint> healthData) {
    Map<String, dynamic> processedData = {};

    // Group data by type and get most recent values
    for (HealthDataPoint point in healthData) {
      // Extract numeric value from HealthValue
      double? numericValue = _extractNumericValue(point.value);
      if (numericValue == null) {
        continue; // Skip if we can't extract a numeric value
      }

      switch (point.type) {
        case HealthDataType.WEIGHT:
          if (!processedData.containsKey('weight') ||
              point.dateFrom.isAfter(processedData['weight']['date'])) {
            processedData['weight'] = {
              'value': numericValue,
              'unit': 'kg',
              'date': point.dateFrom,
            };
          }
          break;

        case HealthDataType.HEIGHT:
          if (!processedData.containsKey('height') ||
              point.dateFrom.isAfter(processedData['height']['date'])) {
            processedData['height'] = {
              'value': numericValue,
              'unit': 'cm',
              'date': point.dateFrom,
            };
          }
          break;

        case HealthDataType.BODY_FAT_PERCENTAGE:
          if (!processedData.containsKey('bodyFat') ||
              point.dateFrom.isAfter(processedData['bodyFat']['date'])) {
            processedData['bodyFat'] = {
              'value': numericValue,
              'unit': '%',
              'date': point.dateFrom,
            };
          }
          break;

        case HealthDataType.ACTIVE_ENERGY_BURNED:
          // Sum up daily active calories
          String dateKey = point.dateFrom.toIso8601String().split('T')[0];
          if (!processedData.containsKey('activeCalories')) {
            processedData['activeCalories'] = <String, double>{};
          }
          processedData['activeCalories'][dateKey] =
              (processedData['activeCalories'][dateKey] ?? 0.0) + numericValue;
          break;

        case HealthDataType.STEPS:
          // Sum up daily steps
          String dateKey = point.dateFrom.toIso8601String().split('T')[0];
          if (!processedData.containsKey('steps')) {
            processedData['steps'] = <String, int>{};
          }
          processedData['steps'][dateKey] =
              (processedData['steps'][dateKey] ?? 0) + numericValue.toInt();
          break;

        case HealthDataType.HEART_RATE:
          if (!processedData.containsKey('heartRate') ||
              point.dateFrom.isAfter(processedData['heartRate']['date'])) {
            processedData['heartRate'] = {
              'value': numericValue,
              'unit': 'bpm',
              'date': point.dateFrom,
            };
          }
          break;

        case HealthDataType.TOTAL_CALORIES_BURNED:
          // Sum up daily total calories
          String dateKey = point.dateFrom.toIso8601String().split('T')[0];
          if (!processedData.containsKey('totalCalories')) {
            processedData['totalCalories'] = <String, double>{};
          }
          processedData['totalCalories'][dateKey] =
              (processedData['totalCalories'][dateKey] ?? 0.0) + numericValue;
          break;

        default:
          // Handle other data types if needed
          break;
      }
    }

    return processedData;
  }

  /// Extract numeric value from HealthValue
  double? _extractNumericValue(HealthValue value) {
    try {
      if (value is NumericHealthValue) {
        return value.numericValue.toDouble();
      }
      // Handle other HealthValue types if needed in the future
      return null;
    } catch (e) {
      developer.log(
        'Error extracting numeric value from HealthValue: $e',
        name: 'HealthService',
      );
      return null;
    }
  }

  /// Get today's burned calories (active energy only)
  Future<double?> getTodaysBurnedCalories() async {
    if (!_isConnected) return null;

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED, // Also try total calories
          // Note: Removed BASAL_ENERGY_BURNED due to permission requirements on Android
        ],
        startTime: startOfDay,
        endTime: now,
      );

      double totalCalories = 0.0;
      for (HealthDataPoint point in healthData) {
        final numericValue = _extractNumericValue(point.value);
        if (numericValue != null) {
          totalCalories += numericValue;
        }
      }

      return totalCalories > 0 ? totalCalories : null;
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
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED, // Also try total calories
          // Note: Removed BASAL_ENERGY_BURNED due to permission requirements on Android
        ],
        startTime: startOfDay,
        endTime: endOfDay,
      );

      double totalCalories = 0.0;
      for (HealthDataPoint point in healthData) {
        final numericValue = _extractNumericValue(point.value);
        if (numericValue != null) {
          totalCalories += numericValue;
        }
      }

      return totalCalories > 0 ? totalCalories : null;
    } catch (e) {
      developer.log(
        'Error getting calories burned for date ${date.toIso8601String()}: $e',
        name: 'HealthService',
      );
      return null;
    }
  }

  /// Get calories burned for multiple dates (last X days)
  Future<Map<String, double>> getCaloriesBurnedForDates(int days) async {
    if (!_isConnected) return {};

    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED, // Also try total calories
          // Note: Removed BASAL_ENERGY_BURNED due to permission requirements on Android
        ],
        startTime: startDate,
        endTime: now,
      );

      Map<String, double> dailyCalories = {};

      for (HealthDataPoint point in healthData) {
        final numericValue = _extractNumericValue(point.value);
        if (numericValue != null) {
          String dateKey = point.dateFrom.toIso8601String().split('T')[0];
          dailyCalories[dateKey] =
              (dailyCalories[dateKey] ?? 0.0) + numericValue;
        }
      }

      return dailyCalories;
    } catch (e) {
      developer.log(
        'Error getting calories burned for last $days days: $e',
        name: 'HealthService',
      );
      return {};
    }
  }

  /// Store calories burned data locally for persistence
  Future<void> storeCaloriesBurnedData(Map<String, double> caloriesData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, String> stringData = {};

      caloriesData.forEach((date, calories) {
        stringData[date] = calories.toString();
      });

      await prefs.setString(
        'health_calories_burned',
        stringData.entries.map((e) => '${e.key}:${e.value}').join(','),
      );

      developer.log(
        'Stored calories burned data for ${caloriesData.length} days',
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

  /// Sync calories burned data for the last 30 days
  Future<Map<String, double>> syncCaloriesBurnedData({int days = 30}) async {
    final caloriesData = await getCaloriesBurnedForDates(days);
    if (caloriesData.isNotEmpty) {
      await storeCaloriesBurnedData(caloriesData);
    }
    return caloriesData;
  }

  /// Sync calories burned data from health service (smart version)
  Future<void> syncCaloriesBurnedDataSmart() async {
    if (!_isConnected) return;

    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.TOTAL_CALORIES_BURNED,
        ],
        startTime: weekAgo,
        endTime: now,
      );

      Map<String, double> dailyCalories = {};

      // Process both active and total calories
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

      // Combine data, preferring total calories if available
      Set<String> allDates = {...activeCalories.keys, ...totalCalories.keys};
      for (String dateKey in allDates) {
        double totalForDate = totalCalories[dateKey] ?? 0.0;
        double activeForDate = activeCalories[dateKey] ?? 0.0;

        // Use total calories if available, otherwise active calories
        dailyCalories[dateKey] =
            totalForDate > 0 ? totalForDate : activeForDate;
      }

      // Store the data
      await storeCaloriesBurnedData(dailyCalories);

      developer.log(
        'Synced calories burned data for ${dailyCalories.length} days: $dailyCalories',
        name: 'HealthService',
      );
    } catch (e) {
      developer.log(
        'Error syncing calories burned data: $e',
        name: 'HealthService',
      );
    }
  }

  /// Debug method to check what health data types are available
  Future<Map<String, dynamic>> debugAvailableHealthData() async {
    try {
      final Map<String, dynamic> debugInfo =
          {}; // Check availability of different data types
      final energyTypes = [
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.TOTAL_CALORIES_BURNED,
        // Note: BASAL_ENERGY_BURNED requires special permission - skipping
      ];

      debugInfo['available_types'] = {};
      for (final type in energyTypes) {
        try {
          final available = Health().isDataTypeAvailable(type);
          debugInfo['available_types'][type.toString()] = available;
          developer.log(
            'Data type $type available: $available',
            name: 'HealthService',
          );
        } catch (e) {
          debugInfo['available_types'][type.toString()] = 'Error: $e';
          developer.log('Error checking $type: $e', name: 'HealthService');
        }
      }

      // Check permissions for energy types
      debugInfo['permissions'] = {};
      for (final type in energyTypes) {
        try {
          final hasPermission = await Health().hasPermissions([type]);
          debugInfo['permissions'][type.toString()] = hasPermission;
          developer.log(
            'Permission for $type: $hasPermission',
            name: 'HealthService',
          );
        } catch (e) {
          debugInfo['permissions'][type.toString()] = 'Error: $e';
          developer.log(
            'Error checking permission for $type: $e',
            name: 'HealthService',
          );
        }
      }

      // Try to fetch data from all energy types for the last week
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      debugInfo['recent_data'] = {};
      for (final type in energyTypes) {
        try {
          final data = await Health().getHealthDataFromTypes(
            types: [type],
            startTime: weekAgo,
            endTime: now,
          );
          debugInfo['recent_data'][type.toString()] = {
            'count': data.length,
            'data_points':
                data
                    .take(5)
                    .map(
                      (point) => {
                        'value': point.value.toString(),
                        'date': point.dateFrom.toString(),
                        'source': point.sourceName,
                      },
                    )
                    .toList(),
          };
          developer.log(
            'Found ${data.length} data points for $type',
            name: 'HealthService',
          );
        } catch (e) {
          debugInfo['recent_data'][type.toString()] = 'Error: $e';
          developer.log('Error fetching $type data: $e', name: 'HealthService');
        }
      }

      return debugInfo;
    } catch (e) {
      developer.log(
        'Error in debugAvailableHealthData: $e',
        name: 'HealthService',
      );
      return {'error': e.toString()};
    }
  }

  /// Check if currently connected to health data
  bool get isConnected => _isConnected;

  /// Get last sync date
  DateTime? get lastSyncDate => _lastSyncDate;

  /// Load connection status from shared preferences
  Future<void> loadConnectionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isConnected = prefs.getBool('health_connected') ?? false;

      final lastSyncTimestamp = prefs.getInt('health_last_sync');
      if (lastSyncTimestamp != null) {
        _lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp);
      }

      // Start auto-sync if connected
      if (_isConnected) {
        _startAutoSync();
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

  /// Save connection status to shared preferences
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

  /// Save last sync date to shared preferences
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

  /// Clear last sync date from shared preferences
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
    _stopAutoSync();
    _connectionStatusController.close();
  }

  /// Get stored calories burned data or fetch from health service
  Future<double?> getCaloriesBurnedForDateSmart(DateTime date) async {
    if (!_isConnected) return null;

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Try to get both active and total calories
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
        'Smart calories for ${date.toIso8601String().split('T')[0]}: Active=$activeCalories, Total=$totalCalories',
        name: 'HealthService',
      );

      // Prefer total calories if available (Google Fit typically uses this)
      // Otherwise use active calories
      if (totalCalories > 0) {
        return totalCalories;
      } else if (activeCalories > 0) {
        return activeCalories;
      }

      return null;
    } catch (e) {
      developer.log(
        'Error getting smart calories burned for date ${date.toIso8601String()}: $e',
        name: 'HealthService',
      );
      return null;
    }
  }
}
