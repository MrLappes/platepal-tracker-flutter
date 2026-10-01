import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/models/chat_types.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/models/user_profile.dart';
import 'package:platepal_tracker/repositories/dish_repository.dart';
import 'package:platepal_tracker/repositories/meal_repository.dart';
import 'package:platepal_tracker/repositories/user_profile_repository.dart';
import 'package:platepal_tracker/services/chat/agent_steps/context_gathering_step.dart';
import 'package:platepal_tracker/services/storage/meal_log_service.dart';

class _FailingDishes extends Fake implements DishRepository {
  @override
  Future<List<Dish>> getAllDishes() async => throw StateError('db closed');
}

class _FailingMeals extends Fake implements MealRepository {
  @override
  Future<List<MealLog>> getCurrentUserMealsByDate({
    required DateTime date,
  }) async => throw StateError('db closed');

  @override
  Future<List<MealLog>> getCurrentUserMealsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async => [];
}

class _FailingProfiles extends Fake implements UserProfileRepository {
  @override
  Future<UserProfile?> getCurrentUserProfile() async =>
      throw StateError('db closed');
}

void main() {
  ChatStepInput input(ContextRequirements requirements) => ChatStepInput(
    userMessage: 'What should I eat?',
    thinkingResult: ThinkingStepResponse(
      userIntent: 'meal advice',
      contextRequirements: requirements,
      responseRequirements: const [],
    ),
  );

  final step = ContextGatheringStep(
    dishRepository: _FailingDishes(),
    mealRepository: _FailingMeals(),
    userProfileRepository: _FailingProfiles(),
  );

  test('records which requested context parts failed to load', () async {
    final result = await step.execute(
      input(
        const ContextRequirements(
          needsUserProfile: true,
          needsExistingDishes: true,
          needsTodaysNutrition: true,
          needsWeeklyNutritionSummary: true,
        ),
      ),
    );

    expect(result.success, isTrue);
    expect(result.data['failedContextParts'], [
      'userProfile',
      'existingDishes',
      'todayNutrition',
    ]);
  });

  test('no failure marker when nothing failed', () async {
    final result = await step.execute(
      input(const ContextRequirements(needsWeeklyNutritionSummary: true)),
    );

    expect(result.success, isTrue);
    expect((result.data as Map).containsKey('failedContextParts'), isFalse);
  });
}
