import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:platepal_tracker/services/health_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeHealth implements Health {
  HealthConnectSdkStatus? sdkStatus = HealthConnectSdkStatus.sdkAvailable;
  List<HealthDataPoint> points = [];
  Object? readError;
  bool installRequested = false;
  final List<List<HealthDataType>> authorizedTypes = [];
  final List<List<HealthDataAccess>?> authorizedAccess = [];
  final List<(List<HealthDataType>, DateTime, DateTime)> reads = [];

  @override
  bool isDataTypeAvailable(HealthDataType dataType) => true;

  @override
  Future<HealthConnectSdkStatus?> getHealthConnectSdkStatus() async =>
      sdkStatus;

  @override
  Future<void> installHealthConnect() async => installRequested = true;

  @override
  Future<bool> requestAuthorization(
    List<HealthDataType> types, {
    List<HealthDataAccess>? permissions,
  }) async {
    authorizedTypes.add(types);
    authorizedAccess.add(permissions);
    return true;
  }

  @override
  Future<List<HealthDataPoint>> getHealthDataFromTypes({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
    List<RecordingMethod> recordingMethodsToFilter = const [],
  }) async {
    reads.add((types, startTime, endTime));
    if (readError != null) throw readError!;
    return points;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

HealthDataPoint _point(HealthDataType type, double kcal, DateTime from) =>
    HealthDataPoint(
      uuid: '$type-$from',
      value: NumericHealthValue(numericValue: kcal),
      type: type,
      unit: HealthDataUnit.KILOCALORIE,
      dateFrom: from,
      dateTo: from.add(const Duration(minutes: 30)),
      sourcePlatform: HealthPlatformType.googleHealthConnect,
      sourceDeviceId: 'device',
      sourceId: 'source',
      sourceName: 'source',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeHealth health;
  late HealthService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    health = _FakeHealth();
    service = HealthService.withHealth(health);
  });

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  Future<void> connect() async {
    final result = await service.connectToHealthWithDetails();
    expect(result.success, isTrue);
  }

  group('platform energy types', () {
    test('iOS requests active + basal, never TOTAL_CALORIES_BURNED', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await connect();
      await service.readEnergyBurnedByDay(DateTime(2026, 3, 1), DateTime(2026, 3, 2));

      expect(health.authorizedTypes.single, [
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.BASAL_ENERGY_BURNED,
        HealthDataType.NUTRITION,
      ]);
      expect(health.authorizedAccess.single, [
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.WRITE,
      ]);
      expect(health.reads.single.$1, [
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.BASAL_ENERGY_BURNED,
      ]);
    });

    test('Android reads total + active energy', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await connect();
      await service.readEnergyBurnedByDay(DateTime(2026, 3, 1), DateTime(2026, 3, 2));

      expect(health.authorizedTypes.single, [
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.NUTRITION,
      ]);
      expect(health.reads.single.$1, [
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ]);
    });
  });

  test('readEnergyBurnedByDay buckets each type per local day', () async {
    health.points = [
      _point(HealthDataType.ACTIVE_ENERGY_BURNED, 200, DateTime(2026, 3, 1, 8)),
      _point(HealthDataType.ACTIVE_ENERGY_BURNED, 100, DateTime(2026, 3, 1, 18)),
      _point(HealthDataType.BASAL_ENERGY_BURNED, 1600, DateTime(2026, 3, 1, 12)),
      _point(HealthDataType.TOTAL_CALORIES_BURNED, 2500, DateTime(2026, 3, 2, 9)),
    ];

    final days = await service.readEnergyBurnedByDay(
      DateTime(2026, 3, 1),
      DateTime(2026, 3, 3),
    );

    expect(days.keys, unorderedEquals(['2026-03-01', '2026-03-02']));
    expect(days['2026-03-01']!.active, 300);
    expect(days['2026-03-01']!.basal, 1600);
    expect(days['2026-03-01']!.total, 0);
    expect(days['2026-03-02']!.total, 2500);
    expect(health.reads, hasLength(1));
  });

  group('DailyEnergyBurned.totalExpenditure', () {
    test('prefers the total record', () {
      expect(
        const DailyEnergyBurned(total: 2400, active: 500).totalExpenditure(
          estimatedBasal: 1700,
        ),
        (2400.0, false),
      );
    });

    test('adds measured basal to active energy', () {
      expect(
        const DailyEnergyBurned(active: 500, basal: 1650).totalExpenditure(),
        (2150.0, false),
      );
    });

    test('active energy alone is never returned as the total', () {
      const day = DailyEnergyBurned(active: 500);
      expect(day.totalExpenditure(), isNull);
      expect(day.totalExpenditure(estimatedBasal: 1700), (2200.0, true));
    });

    test('no data gives no expenditure', () {
      expect(
        const DailyEnergyBurned().totalExpenditure(estimatedBasal: 1700),
        isNull,
      );
    });
  });

  test('getEnergyBurnedForDate reads exactly one local calendar day', () async {
    await connect();
    for (var day = DateTime(2026, 1, 1);
        day.year == 2026;
        day = DateTime(day.year, day.month, day.day + 1)) {
      await service.getEnergyBurnedForDate(day.add(const Duration(hours: 13)));
      final (_, start, end) = health.reads.last;
      expect(start, day);
      expect(end, DateTime(day.year, day.month, day.day + 1));
    }
  });

  group('refreshCaloriesBurnedCache', () {
    test('returns null and keeps the last sync date when Health fails', () async {
      await connect();
      health.readError = Exception('boom');

      expect(await service.refreshCaloriesBurnedCache(), isNull);
      expect(service.lastSyncDate, isNull);
    });

    test('stores per-day components in the cache', () async {
      await connect();
      final now = DateTime.now();
      health.points = [
        _point(HealthDataType.ACTIVE_ENERGY_BURNED, 420, now),
      ];

      final synced = await service.refreshCaloriesBurnedCache();

      expect(synced, isNotNull);
      final stored = await service.getStoredEnergyBurned();
      expect(stored[HealthService.dayKey(now)]!.active, 420);
      expect(service.lastSyncDate, isNotNull);
    });
  });

  group('availability', () {
    test('maps Health Connect SDK status on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final expected = {
        HealthConnectSdkStatus.sdkAvailable: HealthAvailability.available,
        HealthConnectSdkStatus.sdkUnavailable: HealthAvailability.needsInstall,
        HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired:
            HealthAvailability.needsUpdate,
        null: HealthAvailability.unsupported,
      };
      for (final entry in expected.entries) {
        health.sdkStatus = entry.key;
        expect(await service.getHealthAvailability(), entry.value);
      }
    });

    test('connect reports a missing Health Connect without requesting '
        'permissions', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      health.sdkStatus = HealthConnectSdkStatus.sdkUnavailable;

      final result = await service.connectToHealthWithDetails();

      expect(result.success, isFalse);
      expect(result.error, HealthConnectionError.healthConnectNotInstalled);
      expect(health.authorizedTypes, isEmpty);
    });

    test('installHealthConnect delegates to the plugin', () async {
      await service.installHealthConnect();
      expect(health.installRequested, isTrue);
    });
  });
}
