import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

enum HealthConnectionError {
  platformNotSupported,
  healthConnectNotInstalled,
  permissionDenied,
  unknown,
}

/// Whether the platform health store can be used right now.
enum HealthAvailability { available, needsInstall, needsUpdate, unsupported }

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

/// Energy burned on one local day as read from Health, in kcal.
class DailyEnergyBurned {
  /// Android TOTAL_CALORIES_BURNED; already includes basal energy.
  final double total;
  final double active;

  /// iOS BASAL_ENERGY_BURNED.
  final double basal;

  const DailyEnergyBurned({this.total = 0, this.active = 0, this.basal = 0});

  /// Total daily expenditure as (kcal, isEstimated), or null without usable
  /// data. Active energy alone only counts when [estimatedBasal] is given.
  (double, bool)? totalExpenditure({double? estimatedBasal}) {
    if (total > 0) return (total, false);
    if (basal > 0) return (basal + active, false);
    if (active > 0 && estimatedBasal != null && estimatedBasal > 0) {
      return (estimatedBasal + active, true);
    }
    return null;
  }

  Map<String, double> toJson() => {
    'total': total,
    'active': active,
    'basal': basal,
  };

  factory DailyEnergyBurned.fromJson(Map<String, dynamic> json) {
    double read(String key) => (json[key] as num?)?.toDouble() ?? 0;
    return DailyEnergyBurned(
      total: read('total'),
      active: read('active'),
      basal: read('basal'),
    );
  }
}

/// Overhauled HealthService – focused on:
///  • READ  energy burned (Android: total + active, iOS: active + basal)
///  • WRITE nutrition records via [writeMealToHealth]
///
/// Auto-sync timer removed – callers trigger syncs on-demand
/// (app launch, screen visits).
class HealthService {
  static final HealthService _instance = HealthService._internal(Health());
  factory HealthService() => _instance;
  HealthService._internal(this._health);

  /// A service backed by [health] instead of the app-wide singleton.
  @visibleForTesting
  HealthService.withHealth(Health health) : this._internal(health);

  final Health _health;

  static const _energyCacheKey = 'health_energy_burned';
  // Old cache stored active energy as if it were total expenditure.
  static const _legacyCacheKey = 'health_calories_burned';

  /// Local-day key (`yyyy-MM-dd`) used by the energy cache.
  static String dayKey(DateTime date) {
    final local = date.toLocal();
    return DateTime(
      local.year,
      local.month,
      local.day,
    ).toIso8601String().split('T')[0];
  }

  // ── Data types & permissions ────────────────────────────────────────
  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  // iOS has no TOTAL_CALORIES_BURNED; Android's basal type is a BMR rate.
  List<HealthDataType> get _energyTypes =>
      (_isIOS
              ? const [
                HealthDataType.ACTIVE_ENERGY_BURNED,
                HealthDataType.BASAL_ENERGY_BURNED,
              ]
              : const [
                HealthDataType.TOTAL_CALORIES_BURNED,
                HealthDataType.ACTIVE_ENERGY_BURNED,
              ])
          .where(_health.isDataTypeAvailable)
          .toList();

  List<HealthDataType> get _healthDataTypes => [
    ..._energyTypes,
    HealthDataType.NUTRITION,
  ];

  List<HealthDataAccess> get _permissions => [
    for (final _ in _energyTypes) HealthDataAccess.READ,
    HealthDataAccess.WRITE, // NUTRITION: meals are only written
  ];

  // ── State ───────────────────────────────────────────────────────────
  bool _isConnected = false;
  DateTime? _lastSyncDate;

  // Stream controller for connection status changes
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  // ── Platform availability ───────────────────────────────────────────

  /// Whether Health can be used, or Health Connect must be installed/updated.
  Future<HealthAvailability> getHealthAvailability() async {
    try {
      if (_isIOS) {
        return _health.isDataTypeAvailable(HealthDataType.ACTIVE_ENERGY_BURNED)
            ? HealthAvailability.available
            : HealthAvailability.unsupported;
      }
      switch (await _health.getHealthConnectSdkStatus()) {
        case HealthConnectSdkStatus.sdkAvailable:
          return HealthAvailability.available;
        case HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired:
          return HealthAvailability.needsUpdate;
        case HealthConnectSdkStatus.sdkUnavailable:
          return HealthAvailability.needsInstall;
        case null:
          return HealthAvailability.unsupported;
      }
    } catch (e) {
      developer.log(
        'Error checking health data availability: $e',
        name: 'HealthService',
      );
      return HealthAvailability.unsupported;
    }
  }

  /// Check if health data is supported on this platform
  Future<bool> isHealthDataAvailable() async =>
      await getHealthAvailability() == HealthAvailability.available;

  /// Opens the store page to install or update Health Connect (Android).
  Future<void> installHealthConnect() => _health.installHealthConnect();

  /// Check if we have permissions for health data
  Future<bool> hasHealthPermissions() async {
    try {
      return await _health.hasPermissions(
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
      bool authorized = await _health.requestAuthorization(
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
      final availability = await getHealthAvailability();

      if (availability == HealthAvailability.needsInstall ||
          availability == HealthAvailability.needsUpdate) {
        return HealthConnectionResult(
          success: false,
          error: HealthConnectionError.healthConnectNotInstalled,
          message: 'Health Connect must be installed or updated',
        );
      }

      if (availability != HealthAvailability.available) {
        return HealthConnectionResult(
          success: false,
          error: HealthConnectionError.platformNotSupported,
          message: 'Health data is not available on this device',
        );
      }

      bool authorized = await _health.requestAuthorization(
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

  // ── Energy burned (READ) ────────────────────────────────────────────

  /// Energy burned per local day between [start] and [end] in one Health
  /// read. Throws if the read fails.
  Future<Map<String, DailyEnergyBurned>> readEnergyBurnedByDay(
    DateTime start,
    DateTime end,
  ) async {
    final points = await _health.getHealthDataFromTypes(
      types: _energyTypes,
      startTime: start,
      endTime: end,
    );

    final total = <String, double>{};
    final active = <String, double>{};
    final basal = <String, double>{};
    for (final point in points) {
      final kcal = _extractNumericValue(point.value);
      if (kcal == null) continue;
      final bucket = switch (point.type) {
        HealthDataType.TOTAL_CALORIES_BURNED => total,
        HealthDataType.ACTIVE_ENERGY_BURNED => active,
        HealthDataType.BASAL_ENERGY_BURNED => basal,
        _ => null,
      };
      if (bucket == null) continue;
      final key = dayKey(point.dateFrom);
      bucket[key] = (bucket[key] ?? 0) + kcal;
    }

    return {
      for (final key in {...total.keys, ...active.keys, ...basal.keys})
        key: DailyEnergyBurned(
          total: total[key] ?? 0,
          active: active[key] ?? 0,
          basal: basal[key] ?? 0,
        ),
    };
  }

  /// Energy burned on [date]'s local day; null if not connected, without
  /// data, or if the read fails.
  Future<DailyEnergyBurned?> getEnergyBurnedForDate(DateTime date) async {
    if (!_isConnected) return null;

    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day + 1);
      final days = await readEnergyBurnedByDay(startOfDay, endOfDay);
      return days[dayKey(startOfDay)];
    } catch (e) {
      developer.log('Error reading energy burned: $e', name: 'HealthService');
      return null;
    }
  }

  /// Refresh the locally-cached energy data for the last [days] days and
  /// today. Returns null if the Health read failed.
  Future<Map<String, DailyEnergyBurned>?> refreshCaloriesBurnedCache({
    int days = 7,
  }) async {
    if (!_isConnected) return {};

    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day - days);
      final daily = await readEnergyBurnedByDay(startDate, now);

      await storeEnergyBurned(daily);

      _lastSyncDate = now;
      await _saveLastSyncDate(now);

      developer.log(
        'Refreshed energy cache for ${daily.length} days',
        name: 'HealthService',
      );
      return daily;
    } catch (e) {
      developer.log(
        'Error refreshing calorie cache: $e',
        name: 'HealthService',
      );
      return null;
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

      final success = await _health.writeMeal(
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
        'writeMealToHealth ($mealType) – success=$success',
        name: 'HealthService',
      );
      return success;
    } catch (e) {
      developer.log('Error writing meal to health: $e', name: 'HealthService');
      return false;
    }
  }

  // ── Local cache for energy burned ───────────────────────────────────

  /// Merge [days] into the locally persisted energy cache.
  Future<void> storeEnergyBurned(Map<String, DailyEnergyBurned> days) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getStoredEnergyBurned();
      existing.addAll(days);

      await prefs.setString(
        _energyCacheKey,
        jsonEncode({
          for (final entry in existing.entries)
            entry.key: entry.value.toJson(),
        }),
      );
      await prefs.remove(_legacyCacheKey);
    } catch (e) {
      developer.log(
        'Error storing calories burned data: $e',
        name: 'HealthService',
      );
    }
  }

  /// Locally cached energy burned per day key (see [dayKey]).
  Future<Map<String, DailyEnergyBurned>> getStoredEnergyBurned() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_energyCacheKey);
      if (storedData == null || storedData.isEmpty) return {};

      final decoded = jsonDecode(storedData) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          DailyEnergyBurned.fromJson(value as Map<String, dynamic>),
        ),
      );
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
