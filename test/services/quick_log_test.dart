import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/services/health_service.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:platepal_tracker/services/storage/meal_log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _RecordingHealthService implements HealthService {
  final List<({String name, double calories, DateTime startTime})> writes = [];

  @override
  bool get isConnected => true;

  @override
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
    writes.add((name: name, calories: calories, startTime: startTime));
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late _RecordingHealthService health;
  late DishService service;
  final day = DateTime(2026, 9, 20);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
    health = _RecordingHealthService();
    service = DishService(healthService: health);
  });

  Future<String> logOats({
    required DateTime at,
    String mealType = 'breakfast',
    double servings = 1,
  }) => service.insertDishLogSnapshot(
    dishId: 'oats',
    dishName: 'Oats',
    loggedAt: at,
    mealType: mealType,
    servingSize: servings,
    calories: 200 * servings,
    protein: 10 * servings,
    carbs: 30 * servings,
    fat: 5 * servings,
    fiber: 4 * servings,
    notes: 'with milk',
  );

  group('quick add', () {
    test('is a ledger row that counts everywhere but the catalog', () async {
      await service.logQuickAdd(
        name: 'Office cake',
        loggedAt: DateTime(2026, 9, 20, 15, 30),
        mealType: 'snack',
        calories: 350,
        protein: 4,
        carbs: 40,
        fat: 18,
        fiber: 1,
      );
      await _settle();

      final log = (await service.getDishLogsForDate(day)).single;
      expect(log.isQuickAdd, isTrue);
      expect(log.dishId, startsWith(DishLog.quickAddDishIdPrefix));
      expect(log.dishName, 'Office cake');
      expect(log.servingSize, 1);
      expect(log.mealType, 'snack');
      expect(log.loggedAt, DateTime(2026, 9, 20, 15, 30));

      final summary = await service.getMacroSummaryForDate(day);
      expect(summary.calories, 350);
      expect(summary.fat, 18);
      final totals = await service.getDailyNutritionTotals(
        day,
        DateTime(2026, 9, 21),
      );
      expect(totals['2026-09-20']!.calories, 350);
      final stats = await MealLogService().getNutritionSummary(
        userId: 'default',
        startDate: day,
        endDate: DateTime(2026, 9, 21),
      );
      expect(stats.totalCalories, 350);
      expect(stats.mealsByType['snack']!.single.dish.name, 'Office cake');

      expect(await service.getAllDishes(), isEmpty);
      expect(health.writes.single.name, 'Office cake');
      expect(health.writes.single.calories, 350);
    });

    test('every quick add gets its own id', () async {
      for (var i = 0; i < 2; i++) {
        await service.logQuickAdd(
          name: 'Coffee',
          loggedAt: DateTime(2026, 9, 20, 9),
          mealType: 'breakfast',
          calories: 20,
        );
      }
      final logs = await service.getDishLogsForDate(day);
      expect(logs.map((l) => l.dishId).toSet(), hasLength(2));
    });
  });

  group('editing a log', () {
    test('rescales its snapshot and moves it, without touching Health', () async {
      await logOats(at: DateTime(2026, 9, 20, 8), servings: 2);
      final log = (await service.getDishLogsForDate(day)).single;

      await service.updateDishLog(
        log,
        servingSize: 0.5,
        loggedAt: DateTime(2026, 9, 21, 12, 15),
        mealType: 'lunch',
        notes: '  ',
      );
      await _settle();

      expect(await service.getDishLogsForDate(day), isEmpty);
      final edited =
          (await service.getDishLogsForDate(DateTime(2026, 9, 21))).single;
      expect(edited.id, log.id);
      expect(edited.servingSize, 0.5);
      expect(edited.calories, 100);
      expect(edited.protein, 5);
      expect(edited.carbs, 15);
      expect(edited.fat, 2.5);
      expect(edited.fiber, 2);
      expect(edited.mealType, 'lunch');
      expect(edited.loggedAt, DateTime(2026, 9, 21, 12, 15));
      expect(edited.notes, isNull);
      expect(edited.dishName, 'Oats');
      expect(
        (await service.getMacroSummaryForDate(DateTime(2026, 9, 21))).calories,
        100,
      );
      expect(health.writes, isEmpty);
    });

    test('works for a quick add', () async {
      await service.logQuickAdd(
        name: 'Soup',
        loggedAt: DateTime(2026, 9, 20, 19),
        mealType: 'dinner',
        calories: 300,
      );
      final log = (await service.getDishLogsForDate(day)).single;
      await service.updateDishLog(
        log,
        servingSize: 1.5,
        loggedAt: log.loggedAt,
        mealType: 'dinner',
        notes: 'big bowl',
      );
      final edited = (await service.getDishLogsForDate(day)).single;
      expect(edited.calories, 450);
      expect(edited.notes, 'big bowl');
      expect(edited.isQuickAdd, isTrue);
    });
  });

  group('copying', () {
    test('a single log keeps its snapshot and time of day', () async {
      await logOats(at: DateTime(2026, 9, 19, 7, 45, 30), servings: 1.5);
      final log =
          (await service.getDishLogsForDate(DateTime(2026, 9, 19))).single;

      final id = await service.copyDishLog(log, DateTime(2026, 9, 25, 23));
      await _settle();

      final copy =
          (await service.getDishLogsForDate(DateTime(2026, 9, 25))).single;
      expect(copy.id, id);
      expect(copy.id, isNot(log.id));
      expect(copy.loggedAt, DateTime(2026, 9, 25, 7, 45, 30));
      expect(copy.dishId, 'oats');
      expect(copy.dishName, 'Oats');
      expect(copy.servingSize, 1.5);
      expect(copy.calories, 300);
      expect(copy.notes, 'with milk');
      expect(
        await service.getDishLogsForDate(DateTime(2026, 9, 19)),
        hasLength(1),
      );
      expect(health.writes.single.startTime, DateTime(2026, 9, 25, 7, 45, 30));
    });

    test('a meal from the previous day copies only that meal type', () async {
      await logOats(at: DateTime(2026, 9, 19, 7));
      await service.logQuickAdd(
        name: 'Juice',
        loggedAt: DateTime(2026, 9, 19, 7, 5),
        mealType: 'breakfast',
        calories: 90,
      );
      await logOats(at: DateTime(2026, 9, 19, 12), mealType: 'lunch');
      // Two days back: not copied.
      await logOats(at: DateTime(2026, 9, 18, 7));
      health.writes.clear();

      final copied = await service.copyMealFromPreviousDay(
        day: day,
        mealType: 'breakfast',
      );
      await _settle();

      expect(copied, 2);
      final logs = await service.getDishLogsForDate(day);
      expect(logs.map((l) => l.dishName), ['Oats', 'Juice']);
      expect(logs.every((l) => l.mealType == 'breakfast'), isTrue);
      expect(logs.last.isQuickAdd, isTrue);
      expect((await service.getMacroSummaryForDate(day)).calories, 290);
      expect(health.writes.map((w) => w.name), ['Oats', 'Juice']);
    });

    test('nothing to copy returns 0 and writes nothing', () async {
      await logOats(at: DateTime(2026, 9, 19, 12), mealType: 'lunch');
      final copied = await service.copyMealFromPreviousDay(
        day: day,
        mealType: 'dinner',
      );
      expect(copied, 0);
      expect(await service.getDishLogsForDate(day), isEmpty);
    });

    test('previous day is the calendar day before across DST', () async {
      // 2026-03-29 is 23 hours long in Europe; any zone works the same.
      await logOats(at: DateTime(2026, 3, 28, 23, 30), mealType: 'snack');
      final copied = await service.copyMealFromPreviousDay(
        day: DateTime(2026, 3, 29),
        mealType: 'snack',
      );
      expect(copied, 1);
      final copy =
          (await service.getDishLogsForDate(DateTime(2026, 3, 29))).single;
      expect(copy.loggedAt, DateTime(2026, 3, 29, 23, 30));
    });
  });
}
