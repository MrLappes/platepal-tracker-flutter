import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  HealthService._internal();

  // Health data types we want to read
  static const List<HealthDataType> _healthDataTypes = [
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
  ];

  // Health permissions for reading data
  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  bool _isConnected = false;
  DateTime? _lastSyncDate;

  /// Check if health data is supported on this platform
  Future<bool> isHealthDataAvailable() async {
    try {
      // Check if the platform supports health data (Android Health Connect or iOS HealthKit)
      return await Health().isDataTypeAvailable(HealthDataType.STEPS);
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
    developer.log('Disconnected from health data', name: 'HealthService');
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
    Map<String, dynamic> processedData =
        {}; // Group data by type and get most recent values
    for (HealthDataPoint point in healthData) {
      switch (point.type) {
        case HealthDataType.WEIGHT:
          if (!processedData.containsKey('weight') ||
              point.dateFrom.isAfter(processedData['weight']['date'])) {
            processedData['weight'] = {
              'value': point.value,
              'unit': 'kg',
              'date': point.dateFrom,
            };
          }
          break;

        case HealthDataType.HEIGHT:
          if (!processedData.containsKey('height') ||
              point.dateFrom.isAfter(processedData['height']['date'])) {
            processedData['height'] = {
              'value': point.value,
              'unit': 'cm',
              'date': point.dateFrom,
            };
          }
          break;

        case HealthDataType.BODY_FAT_PERCENTAGE:
          if (!processedData.containsKey('bodyFat') ||
              point.dateFrom.isAfter(processedData['bodyFat']['date'])) {
            processedData['bodyFat'] = {
              'value': point.value,
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
              (processedData['activeCalories'][dateKey] ?? 0.0) +
              (point.value as num).toDouble();
          break;

        case HealthDataType.BASAL_ENERGY_BURNED:
          // Sum up daily basal calories
          String dateKey = point.dateFrom.toIso8601String().split('T')[0];
          if (!processedData.containsKey('basalCalories')) {
            processedData['basalCalories'] = <String, double>{};
          }
          processedData['basalCalories'][dateKey] =
              (processedData['basalCalories'][dateKey] ?? 0.0) +
              (point.value as num).toDouble();
          break;

        case HealthDataType.STEPS:
          // Sum up daily steps
          String dateKey = point.dateFrom.toIso8601String().split('T')[0];
          if (!processedData.containsKey('steps')) {
            processedData['steps'] = <String, int>{};
          }
          processedData['steps'][dateKey] =
              (processedData['steps'][dateKey] ?? 0) +
              (point.value as num).toInt();
          break;

        case HealthDataType.HEART_RATE:
          if (!processedData.containsKey('heartRate') ||
              point.dateFrom.isAfter(processedData['heartRate']['date'])) {
            processedData['heartRate'] = {
              'value': point.value,
              'unit': 'bpm',
              'date': point.dateFrom,
            };
          }
          break;

        default:
          // Handle other data types if needed
          break;
      }
    }

    return processedData;
  }

  /// Get today's burned calories (active + basal)
  Future<double?> getTodaysBurnedCalories() async {
    if (!_isConnected) return null;

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: [
          HealthDataType.ACTIVE_ENERGY_BURNED,
          HealthDataType.BASAL_ENERGY_BURNED,
        ],
        startTime: startOfDay,
        endTime: now,
      );

      double totalCalories = 0.0;
      for (HealthDataPoint point in healthData) {
        totalCalories += (point.value as num).toDouble();
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
}
