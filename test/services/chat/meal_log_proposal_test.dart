import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/providers/chat_provider.dart';
import 'package:platepal_tracker/services/chat/meal_log_proposal.dart';
import 'package:platepal_tracker/services/health_service.dart';
import 'package:platepal_tracker/services/storage/database_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _RecordingHealthService implements HealthService {
  final List<({String name, double calories})> writes = [];

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
    writes.add((name: name, calories: calories));
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MealLogProposalError? _errorOf(Map<String, dynamic> args, DateTime now) {
  try {
    MealLogProposal.fromToolArguments(args, now: now);
    return null;
  } on MealLogProposalException catch (e) {
    return e.error;
  }
}

void main() {
  final now = DateTime(2026, 9, 20, 12, 40);

  group('log_meal arguments', () {
    test('a dish reference defaults to 1 serving, now and the meal of the '
        'time of day', () {
      final proposal = MealLogProposal.fromToolArguments({
        'dish_id': ' pasta ',
        'name': 'Pasta',
        'calories': 999,
      }, now: now);

      expect(proposal.dishId, 'pasta');
      expect(proposal.isQuickAdd, isFalse);
      expect(proposal.nutritionPerServing, isNull);
      expect(proposal.servings, 1);
      expect(proposal.loggedAt, DateTime(2026, 9, 20, 12, 40));
      expect(proposal.mealType, 'lunch');
    });

    test('quick-add values, date, time and meal type are read', () {
      final proposal = MealLogProposal.fromToolArguments({
        'name': 'Banana bread',
        'calories': 320,
        'protein': '6',
        'carbs': 48.5,
        'fat': 11,
        'servings': '2',
        'meal_type': 'Snack',
        'date': '2026-09-19',
        'time': '7:05',
      }, now: now);

      expect(proposal.isQuickAdd, isTrue);
      expect(proposal.name, 'Banana bread');
      expect(proposal.nutritionPerServing!.calories, 320);
      expect(proposal.nutritionPerServing!.protein, 6);
      expect(proposal.nutritionPerServing!.carbs, 48.5);
      expect(proposal.nutritionPerServing!.fiber, 0);
      expect(proposal.servings, 2);
      expect(proposal.mealType, 'snack');
      expect(proposal.loggedAt, DateTime(2026, 9, 19, 7, 5));
    });

    test('invalid arguments are rejected with a reason', () {
      const apple = {'name': 'Apple', 'calories': 95};
      final cases = <Map<String, dynamic>, MealLogProposalError>{
        {}: MealLogProposalError.missingFood,
        {'name': 'Apple'}: MealLogProposalError.missingFood,
        {'calories': 95}: MealLogProposalError.missingFood,
        {'name': '   ', 'calories': 95}: MealLogProposalError.missingFood,
        {'dish_id': 42}: MealLogProposalError.invalidDishId,
        {'dish_id': 'x' * 129}: MealLogProposalError.invalidDishId,
        {'name': 'n' * 101, 'calories': 95}: MealLogProposalError.invalidName,
        {...apple, 'calories': -1}: MealLogProposalError.invalidNutrition,
        {...apple, 'calories': 10001}: MealLogProposalError.invalidNutrition,
        {...apple, 'fat': 'lots'}: MealLogProposalError.invalidNutrition,
        {...apple, 'protein': double.nan}:
            MealLogProposalError.invalidNutrition,
        {...apple, 'servings': 0}: MealLogProposalError.invalidServings,
        {...apple, 'servings': 21}: MealLogProposalError.invalidServings,
        {...apple, 'servings': 'two'}: MealLogProposalError.invalidServings,
        {...apple, 'meal_type': 'brunch'}: MealLogProposalError.invalidMealType,
        {...apple, 'meal_type': 3}: MealLogProposalError.invalidMealType,
        {...apple, 'date': '20.09.2026'}: MealLogProposalError.invalidDate,
        {...apple, 'date': '2026-02-30'}: MealLogProposalError.invalidDate,
        {...apple, 'date': 20260920}: MealLogProposalError.invalidDate,
        {...apple, 'time': '25:00'}: MealLogProposalError.invalidTime,
        {...apple, 'time': '12:60'}: MealLogProposalError.invalidTime,
        {...apple, 'time': 'noon'}: MealLogProposalError.invalidTime,
        {...apple, 'date': '2025-09-01'}: MealLogProposalError.dateOutOfRange,
        {...apple, 'date': '2026-11-30'}: MealLogProposalError.dateOutOfRange,
      };
      for (final MapEntry(key: args, value: error) in cases.entries) {
        expect(_errorOf(args, now), error, reason: '$args');
      }
      expect(_errorOf({...apple, 'meal_type': '', 'date': ''}, now), isNull);
    });

    test('round-trips through the stored JSON', () {
      for (final args in [
        {'dish_id': 'pasta', 'servings': 1.5, 'meal_type': 'dinner'},
        {'name': 'Apple', 'calories': 95, 'carbs': 25, 'time': '16:00'},
      ]) {
        final proposal = MealLogProposal.fromToolArguments(args, now: now);
        final copy = MealLogProposal.fromJson(proposal.toJson());
        expect(copy.toJson(), proposal.toJson());
      }
      expect(
        () => MealLogProposal.fromJson({'error': 'missingFood'}),
        throwsA(isA<MealLogProposalException>()),
      );
    });

    test('the chat provider reads proposals of the last response step', () {
      expect(ChatProvider.mealLogProposals(null), isEmpty);
      expect(
        ChatProvider.mealLogProposals({
          'stepResults': [
            {
              'stepName': 'response_generation',
              'data': {
                'mealLogProposals': [
                  {'dishId': 'old'},
                ],
              },
            },
            {
              'stepName': 'response_generation',
              'data': {
                'mealLogProposals': [
                  {'dishId': 'new'},
                  'junk',
                ],
              },
            },
          ],
        }),
        [
          {'dishId': 'new'},
        ],
      );
    });
  });

  group('MealLogProposalLogger', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    late _RecordingHealthService health;
    late DishService dishService;
    late MealLogProposalLogger logger;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await DatabaseService.useFactoryForTesting(databaseFactoryFfiNoIsolate);
      health = _RecordingHealthService();
      dishService = DishService(healthService: health);
      logger = MealLogProposalLogger(dishService: dishService);
      await dishService.saveDish(
        Dish(
          id: 'pasta',
          name: 'Pasta',
          ingredients: const [],
          nutrition: const NutritionInfo(
            calories: 1280,
            protein: 48,
            carbs: 200,
            fat: 32,
          ),
          createdAt: now,
          updatedAt: now,
          servings: 3,
        ),
      );
    });

    Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

    test('previews and confirms a dish reference per serving of the yield',
        () async {
      final proposal = MealLogProposal.fromToolArguments({
        'dish_id': 'pasta',
        'servings': 1.5,
        'meal_type': 'lunch',
      }, now: now);

      final preview = await logger.preview(proposal);
      expect(preview.name, 'Pasta');
      expect(preview.totalNutrition.calories, closeTo(640, 1e-9));
      expect(await dishService.getDishLogsForDate(now), isEmpty);

      await logger.confirm(proposal);
      await settle();
      final log = (await dishService.getDishLogsForDate(now)).single;
      expect(log.dishId, 'pasta');
      expect(log.dishName, 'Pasta');
      expect(log.servingSize, 1.5);
      expect(log.calories, closeTo(640, 1e-9));
      expect(log.protein, closeTo(24, 1e-9));
      expect(log.mealType, 'lunch');
      expect(log.loggedAt, DateTime(2026, 9, 20, 12, 40));
      expect(health.writes.single.name, 'Pasta');
    });

    test('confirms quick-add values as a quick add entry', () async {
      final proposal = MealLogProposal.fromToolArguments({
        'name': 'Croissant',
        'calories': 230,
        'fat': 12,
        'servings': 2,
        'time': '08:15',
      }, now: now);

      await logger.confirm(proposal);
      await settle();
      final log = (await dishService.getDishLogsForDate(now)).single;
      expect(log.isQuickAdd, isTrue);
      expect(log.dishName, 'Croissant');
      expect(log.calories, 460);
      expect(log.fat, 24);
      expect(log.mealType, 'breakfast');
      expect(log.loggedAt, DateTime(2026, 9, 20, 8, 15));
      expect(health.writes.single.calories, 460);
      expect(await dishService.getAllDishes(), hasLength(1));
    });

    test('a deleted dish cannot be logged', () async {
      final proposal = MealLogProposal.fromToolArguments({
        'dish_id': 'pasta',
      }, now: now);
      await dishService.deleteDish('pasta');

      await expectLater(
        logger.preview(proposal),
        throwsA(
          isA<MealLogProposalException>().having(
            (e) => e.error,
            'error',
            MealLogProposalError.dishNotFound,
          ),
        ),
      );
      await expectLater(
        logger.confirm(proposal),
        throwsA(isA<MealLogProposalException>()),
      );
      expect(await dishService.getDishLogsForDate(now), isEmpty);
      expect(health.writes, isEmpty);
    });
  });
}

