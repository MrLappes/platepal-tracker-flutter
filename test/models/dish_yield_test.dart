import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/modals/dish_log_modal.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/services/health_service.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _RecordingHealthService implements HealthService {
  final List<double> calories = [];

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
    this.calories.add(calories);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Dish _stew({double servings = 4}) {
  final at = DateTime(2026, 9, 1);
  return Dish(
    id: 'stew',
    name: 'Stew',
    ingredients: const [
      Ingredient(id: 'beef', name: 'Beef', amount: 600, unit: 'g'),
      Ingredient(id: 'stock', name: 'Stock', amount: 1, unit: 'kg'),
    ],
    nutrition: const NutritionInfo(
      calories: 2000,
      protein: 160,
      carbs: 80,
      fat: 100,
      fiber: 12,
    ),
    createdAt: at,
    updatedAt: at,
    servings: servings,
  );
}

void main() {
  group('Dish yield', () {
    test('defaults to 1 and keeps nutrition as one serving', () {
      final dish = _stew().copyWith(servings: 1);
      expect(Dish.fromJson(dish.toJson()..remove('servings')).servings, 1);
      expect(identical(dish.nutritionPerServing, dish.nutrition), isTrue);
    });

    test('per-serving nutrition is the recipe total divided by the yield', () {
      final perServing = _stew().nutritionPerServing;
      expect(perServing.calories, 500);
      expect(perServing.protein, 40);
      expect(perServing.carbs, 20);
      expect(perServing.fat, 25);
      expect(perServing.fiber, 3);
    });

    test('round-trips through JSON', () {
      final copy = Dish.fromJson(_stew(servings: 2.5).toJson());
      expect(copy.servings, 2.5);
      expect(copy.nutrition.calories, 2000);
    });

    test('stored or imported yields are normalized', () {
      expect(Dish.normalizeServings(null), 1);
      expect(Dish.normalizeServings('abc'), 1);
      expect(Dish.normalizeServings(0), 1);
      expect(Dish.normalizeServings(-3), 1);
      expect(Dish.normalizeServings(double.nan), 1);
      expect(Dish.normalizeServings(double.infinity), 1);
      expect(Dish.normalizeServings(0.2), Dish.minServings);
      expect(Dish.normalizeServings(250), Dish.maxServings);
      expect(Dish.normalizeServings('6'), 6);
      expect(Dish.normalizeServings(3), 3);
    });
  });

  group('log sheet helpers', () {
    test('one serving weighs the total weight divided by the yield', () {
      expect(servingWeight(_stew()), (amount: 400.0, unit: 'g'));
      expect(servingWeight(_stew(servings: 1)), (amount: 1600.0, unit: 'g'));
      expect(
        servingWeight(_stew().copyWith(ingredients: const [])),
        isNull,
      );
    });

    test('editing a log keeps its per-serving snapshot and the yield', () {
      final log = DishLog(
        id: 'l',
        dishId: 'stew',
        dishName: 'Stew',
        loggedAt: DateTime(2026, 9, 2, 12),
        mealType: 'lunch',
        servingSize: 2,
        calories: 1000,
        protein: 80,
        carbs: 40,
        fat: 50,
        fiber: 6,
      );
      final dish = dishForLog(log, current: _stew(), fallbackName: '?');
      expect(dish.servings, 4);
      expect(dish.nutritionPerServing.calories, 500);
      expect(dish.nutritionPerServing.fiber, 3);
      expect(servingWeight(dish)!.amount, 400);

      final orphan = dishForLog(log, fallbackName: '?');
      expect(orphan.servings, 1);
      expect(orphan.nutritionPerServing.calories, 500);
    });
  });

  group('DishService', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    late _RecordingHealthService health;
    late DishService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
      health = _RecordingHealthService();
      service = DishService(healthService: health);
    });

    test('stores the yield and logs one serving as total / yield', () async {
      await service.saveDish(_stew());
      expect((await service.getDishById('stew'))!.servings, 4);

      await service.logDish(
        dishId: 'stew',
        loggedAt: DateTime(2026, 9, 2, 12),
        mealType: 'lunch',
        servingSize: 1.5,
      );
      final log = (await service.getDishLogsForDate(DateTime(2026, 9, 2)))
          .single;
      expect(log.servingSize, 1.5);
      expect(log.calories, 750);
      expect(log.protein, 60);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(health.calories, [750]);

      await service.updateDish(_stew(servings: 2));
      expect((await service.getDishById('stew'))!.servings, 2);
      expect(
        (await service.getDishLogsForDate(DateTime(2026, 9, 2))).single
            .calories,
        750,
        reason: 'logs keep their snapshot',
      );
    });

    test('a dish with yield 1 logs exactly as before', () async {
      await service.saveDish(_stew(servings: 1));
      await service.logDish(
        dishId: 'stew',
        loggedAt: DateTime(2026, 9, 2, 12),
        mealType: 'lunch',
        servingSize: 1,
      );
      final log = (await service.getDishLogsForDate(DateTime(2026, 9, 2)))
          .single;
      expect(log.calories, 2000);
    });
  });
}
