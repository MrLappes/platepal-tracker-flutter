import '../../../models/chat_types.dart';
import '../../../repositories/dish_repository.dart';
import '../../../repositories/meal_repository.dart';
import '../../../repositories/user_profile_repository.dart';
import 'package:flutter/foundation.dart';
import '../../../models/user_profile.dart'; // Added
import '../../../models/dish.dart'; // Added
import '../../../services/storage/meal_log_service.dart'; // Added for MealLog

/// Context gathering step - collects required data based on thinking step
class ContextGatheringStep extends AgentStep {
  final DishRepository _dishRepository;
  final MealRepository _mealRepository;
  final UserProfileRepository _userProfileRepository;

  ContextGatheringStep({
    required DishRepository dishRepository,
    required MealRepository mealRepository,
    required UserProfileRepository userProfileRepository,
  }) : _dishRepository = dishRepository,
       _mealRepository = mealRepository,
       _userProfileRepository = userProfileRepository;

  @override
  String get stepName => 'context_gathering';

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    final contextSections = <String, String>{};
    final gatheredContextData = <String, dynamic>{};
    try {
      debugPrint('📊 ContextGatheringStep: Starting context gathering');
      final thinkingResult = input.thinkingResult;
      if (thinkingResult == null) {
        debugPrint(
          '❌ ContextGatheringStep: Critical error - ThinkingStepResponse not found in input.',
        );
        return ChatStepResult.failure(
          stepName: stepName,
          error: ChatAgentError(
            type: ChatErrorType.missingPrerequisite,
            message:
                'ThinkingStepResponse not found. Cannot proceed with context gathering.',
            retryable: false,
          ),
        );
      }
      final contextRequirements = thinkingResult.contextRequirements;
      // Gather user profile if needed
      if (contextRequirements.needsUserProfile) {
        try {
          final userProfile =
              await _userProfileRepository.getCurrentUserProfile();
          if (userProfile != null) {
            contextSections['userProfile'] = _formatUserProfile(userProfile);
            gatheredContextData['userProfile'] = userProfile.toJson();
            debugPrint(
              '📊 Added user profile context based on OpenAI analysis',
            );
          } else {
            debugPrint('⚠️ User profile requested by AI, but not found.');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to get user profile: $e');
        }
      }
      // Gather existing dishes if needed
      if (contextRequirements.needsExistingDishes ||
          contextRequirements.needsListOfCreatedDishes) {
        try {
          final dishes = await _dishRepository.getAllDishes();
          if (dishes.isNotEmpty) {
            contextSections['existingDishes'] = _formatDishes(dishes);
            gatheredContextData['existingDishes'] =
                dishes.map((d) => d.toJson()).toList();
            debugPrint('📊 Added ${dishes.length} existing dishes to context');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to get dishes: $e');
        }
      }
      // Gather today's nutrition if needed
      if (contextRequirements.needsTodaysNutrition) {
        try {
          final today = DateTime.now();
          final List<MealLog> todayMeals = await _mealRepository
              .getCurrentUserMealsByDate(date: today);
          if (todayMeals.isNotEmpty) {
            contextSections['todayNutrition'] = _formatTodayNutrition(
              todayMeals,
            );
            gatheredContextData['todayNutrition'] =
                todayMeals.map((m) => m.toJson()).toList();
            debugPrint('📊 Added today\'s nutrition context');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to get today\'s meals: $e');
        }
      }
      // Gather weekly summary if needed
      if (contextRequirements.needsWeeklyNutritionSummary) {
        try {
          final weekStart = DateTime.now().subtract(const Duration(days: 7));
          final List<MealLog> weeklyMeals = await _mealRepository
              .getCurrentUserMealsByDateRange(
                startDate: weekStart,
                endDate: DateTime.now(),
              );
          if (weeklyMeals.isNotEmpty) {
            contextSections['weeklyNutrition'] = _formatWeeklyNutrition(
              weeklyMeals,
            );
            gatheredContextData['weeklyNutrition'] =
                weeklyMeals.map((m) => m.toJson()).toList();
            debugPrint('📊 Added weekly nutrition context');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to get weekly meals: $e');
        }
      }
      // Gather historical data if needed
      if (contextRequirements.historicalMealPeriod != null &&
          contextRequirements.historicalMealPeriod!.isNotEmpty) {
        try {
          final period = contextRequirements.historicalMealPeriod!;
          final daysBack = _getDaysBackForPeriod(period);
          final startDate = DateTime.now().subtract(Duration(days: daysBack));
          final List<MealLog> historicalMeals = await _mealRepository
              .getCurrentUserMealsByDateRange(
                startDate: startDate,
                endDate: DateTime.now(),
              );
          if (historicalMeals.isNotEmpty) {
            contextSections['historicalMeals'] = _formatHistoricalMeals(
              historicalMeals,
              period,
            );
            gatheredContextData['historicalMeals'] =
                historicalMeals.map((m) => m.toJson()).toList();
            debugPrint('📊 Added historical meals for $period');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to get historical meals: $e');
        }
      }
      // Add dish creation info if needed
      if (contextRequirements.needsInfoOnDishCreation) {
        contextSections['dishCreationInfo'] = _getDishCreationInfo();
        debugPrint('📊 Added dish creation info to context');
      }
      // Add nutrition advice placeholder if needed
      if (contextRequirements.needsNutritionAdvice) {
        contextSections['nutritionAdvice'] =
            'General nutrition advice may be relevant to this user request.';
        debugPrint('📊 Added nutrition advice placeholder to context');
      }
      // Construct the enhanced system prompt
      final initialPrompt = input.initialSystemPrompt ?? '';
      final enhancedSystemPromptBuffer = StringBuffer(initialPrompt);
      contextSections.forEach((section, content) {
        enhancedSystemPromptBuffer.writeln('\n---\n### $section\n$content');
      });
      final enhancedSystemPrompt = enhancedSystemPromptBuffer.toString();
      final response = ContextGatheringStepResponse(
        enhancedSystemPrompt: enhancedSystemPrompt,
        gatheredContextData: gatheredContextData,
        metadata: {'contextSections': contextSections.keys.toList()},
      );
      return ChatStepResult.success(
        stepName: stepName,
        data: {'contextGatheringResult': response.toJson()},
      );
    } catch (error, stackTrace) {
      debugPrint(
        '❌ ContextGatheringStep: Error during execution: $error\n$stackTrace',
      );
      return ChatStepResult.failure(
        stepName: stepName,
        error: ChatAgentError(
          type: ChatErrorType.processingError,
          message: 'Error during context gathering: $error',
          retryable: true,
        ),
      );
    }
  }

  @override
  Future<ChatStepVerificationResult> verify(
    ChatStepResult result,
    ChatStepInput input,
  ) async {
    if (!result.success) {
      return ChatStepVerificationResult.invalid(
        message: 'Context gathering failed',
        error: result.error,
      );
    }
    final responseJson =
        result.data?['contextGatheringResult'] as Map<String, dynamic>?;
    if (responseJson == null) {
      return ChatStepVerificationResult.invalid(
        message: 'No contextGatheringResult in step result',
      );
    }
    final ContextGatheringStepResponse gatheredContext =
        ContextGatheringStepResponse.fromJson(responseJson);
    if (gatheredContext.enhancedSystemPrompt == null ||
        gatheredContext.enhancedSystemPrompt!.isEmpty) {
      return ChatStepVerificationResult.invalid(
        message: 'Enhanced system prompt missing after context gathering',
      );
    }
    // Optionally, check that required context was gathered
    // (e.g., if needsUserProfile was true, userProfile should be present)
    return ChatStepVerificationResult.valid();
  }

  // --- Formatting and helper methods ---

  String _formatUserProfile(UserProfile userProfile) {
    final buffer = StringBuffer();
    buffer.writeln('**Age:** ${userProfile.age}');
    buffer.writeln('**Gender:** ${userProfile.gender}');
    buffer.writeln('**Height:** ${userProfile.height} cm');
    buffer.writeln('**Weight:** ${userProfile.weight} kg');
    buffer.writeln(
      '**Activity Level:** ${_formatActivityLevelString(userProfile.activityLevel)}',
    );
    buffer.writeln(
      '**Fitness Goal:** ${_formatFitnessGoalString(userProfile.goals.goal)}',
    );
    buffer.writeln(
      '**Dietary Preferences:** ${userProfile.preferences.dietType}',
    );
    if (userProfile.preferences.allergies.isNotEmpty) {
      buffer.writeln(
        '**Allergies:** ${userProfile.preferences.allergies.join(", ")}',
      );
    }
    if (userProfile.preferences.dislikes.isNotEmpty) {
      buffer.writeln(
        '**Dislikes:** ${userProfile.preferences.dislikes.join(", ")}',
      );
    }
    if (userProfile.preferences.cuisinePreferences.isNotEmpty) {
      buffer.writeln(
        '**Cuisine Preferences:** ${userProfile.preferences.cuisinePreferences.join(", ")}',
      );
    }
    return buffer.toString();
  }

  String _formatActivityLevelString(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return 'Sedentary (little or no exercise)';
      case 'lightly_active':
        return 'Lightly Active (light exercise/sports 1-3 days/week)';
      case 'moderately_active':
        return 'Moderately Active (moderate exercise/sports 3-5 days/week)';
      case 'very_active':
        return 'Very Active (hard exercise/sports 6-7 days/week)';
      case 'extra_active':
        return 'Extra Active (very hard exercise & physical job)';
      default:
        return activityLevel;
    }
  }

  String _formatFitnessGoalString(String goal) {
    switch (goal.toLowerCase()) {
      case 'lose_weight':
        return 'Lose Weight';
      case 'maintain_weight':
        return 'Maintain Weight';
      case 'gain_weight':
        return 'Gain Weight';
      case 'build_muscle':
        return 'Build Muscle';
      default:
        return goal;
    }
  }

  String _formatDishes(List<Dish> dishes) {
    if (dishes.isEmpty) return 'No dishes available.';
    final shown = dishes.take(10).map((d) => '- ${d.name}').join('\n');
    return 'Available dishes (up to 10 shown):\n$shown${dishes.length > 10 ? '\n...and ${dishes.length - 10} more' : ''}';
  }

  String _formatTodayNutrition(List<MealLog> meals) {
    if (meals.isEmpty) return 'No meals logged for today yet.';
    final mealSummaries = meals
        .take(5)
        .map((m) => '- ${m.toJson()}')
        .join('\n');
    return 'Today\'s logged meals (up to 5 shown):\n$mealSummaries${meals.length > 5 ? '\n...and ${meals.length - 5} more' : ''}';
  }

  String _formatWeeklyNutrition(List<MealLog> meals) {
    if (meals.isEmpty) return 'No meals logged for this week.';
    return 'Weekly nutrition summary: ${meals.length} meals logged this week.';
  }

  String _formatHistoricalMeals(List<MealLog> meals, String period) {
    if (meals.isEmpty) return 'No meals found for the period: $period.';
    final mealSummaries = meals
        .take(5)
        .map((m) => '- ${m.toJson()}')
        .join('\n');
    return 'Historical meals for $period (up to 5 shown):\n$mealSummaries${meals.length > 5 ? '\n...and ${meals.length - 5} more' : ''}';
  }

  int _getDaysBackForPeriod(String period) {
    switch (period.toLowerCase()) {
      case 'yesterday':
        return 1;
      case 'last week':
        return 7;
      case 'last month':
        return 30;
      default:
        return 7;
    }
  }

  String _getDishCreationInfo() {
    return 'To create a new dish, provide a name, list of ingredients, and nutrition info. You can also add a photo.';
  }
}
