import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart';
import '../../../models/dish_models.dart';
import '../openai_service.dart';
import '../pipeline_modification_tracker.dart';

/// Validates and edits newly created dishes with AI-powered corrections
/// Skips validation for dishes retrieved from database by ID
class DishValidationStep extends AgentStep {
  final OpenAIService _openaiService;
  final PipelineModificationTracker _modificationTracker;

  DishValidationStep({
    required OpenAIService openaiService,
    PipelineModificationTracker? modificationTracker,
  }) : _openaiService = openaiService,
       _modificationTracker =
           modificationTracker ?? PipelineModificationTracker();

  @override
  String get stepName => 'dish_validation';

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      debugPrint('🔍 DishValidationStep: Starting dish validation');

      final validatedDishes =
          input.metadata?['validatedDishes'] as List<dynamic>? ?? [];

      if (validatedDishes.isEmpty) {
        debugPrint('ℹ️ DishValidationStep: No dishes to validate');
        return ChatStepResult.success(
          stepName: stepName,
          data: {
            'finalDishes': <ProcessedDish>[],
            'validationResults': <Map<String, dynamic>>[],
            'skipped': true,
            'reason': 'No dishes provided for validation',
          },
        );
      }

      final finalDishes = <ProcessedDish>[];
      final validationResults = <Map<String, dynamic>>[];
      int validatedCount = 0;
      int skippedCount = 0;

      for (int i = 0; i < validatedDishes.length; i++) {
        final dishData = validatedDishes[i];
        ProcessedDish dish;

        // Convert to ProcessedDish if needed
        if (dishData is ProcessedDish) {
          dish = dishData;
        } else if (dishData is Map<String, dynamic>) {
          try {
            dish = ProcessedDish.fromJson(dishData);
          } catch (e) {
            debugPrint('❌ Failed to parse dish data: $e');
            validationResults.add({
              'index': i,
              'status': 'error',
              'error': 'Failed to parse dish data: $e',
            });
            continue;
          }
        } else {
          debugPrint('❌ Invalid dish data type: ${dishData.runtimeType}');
          validationResults.add({
            'index': i,
            'status': 'error',
            'error': 'Invalid dish data type',
          });
          continue;
        }

        // Skip validation for dishes retrieved from database (they have established IDs)
        if (_isExistingDish(dish)) {
          debugPrint(
            '⏭️ Skipping validation for existing dish: ${dish.name} (ID: ${dish.id})',
          );
          finalDishes.add(dish);
          validationResults.add({
            'index': i,
            'dishName': dish.name,
            'status': 'skipped',
            'reason': 'Existing dish from database',
            'dishId': dish.id,
          });
          skippedCount++;
          continue;
        }

        // Validate and potentially edit newly created dish
        debugPrint('🔍 Validating newly created dish: ${dish.name}');

        // First, check for obvious nutrition issues and fix them automatically
        dish = _performQuickFixes(dish);

        final validationResult = await _validateAndEditDish(dish, input);

        if (validationResult['success'] == true) {
          final editedDish = validationResult['dish'] as ProcessedDish;
          finalDishes.add(editedDish);
          validationResults.add({
            'index': i,
            'dishName': editedDish.name,
            'status': 'validated',
            'edits': validationResult['edits'] ?? [],
            'confidence': validationResult['confidence'] ?? 1.0,
          });
          validatedCount++;
        } else {
          // If validation fails, use original dish
          finalDishes.add(dish);
          validationResults.add({
            'index': i,
            'dishName': dish.name,
            'status': 'failed',
            'error': validationResult['error'],
            'usedOriginal': true,
          });
        }
      }

      debugPrint('🔍 DishValidationStep: Completed validation');
      debugPrint('   Validated: $validatedCount dishes');
      debugPrint('   Skipped: $skippedCount dishes');
      debugPrint('   Total: ${finalDishes.length} dishes');

      // NEW: Intelligent dish filtering for context optimization
      final filteredDishes = await _filterDishesForContext(finalDishes, input);

      return ChatStepResult.success(
        stepName: stepName,
        data: {
          'finalDishes': filteredDishes['dishes'],
          'originalDishCount': finalDishes.length,
          'filteredDishCount': (filteredDishes['dishes'] as List).length,
          'dishesFilteredOut': filteredDishes['filteredOut'],
          'filteringApplied': filteredDishes['filteringApplied'],
          'validationResults': validationResults,
          'summary': {
            'validatedCount': validatedCount,
            'skippedCount': skippedCount,
            'totalCount': finalDishes.length,
            'filteredCount': (filteredDishes['dishes'] as List).length,
          },
          'modifications': _modificationTracker.toJson(),
          'modificationSummary':
              _modificationTracker.generateUserFriendlySummary(),
        },
      );
    } catch (error) {
      debugPrint('❌ DishValidationStep: Error during execution: $error');

      // Return original dishes if validation fails
      final originalDishes =
          input.metadata?['validatedDishes'] as List<dynamic>? ?? [];

      return ChatStepResult.success(
        stepName: stepName,
        data: {
          'finalDishes': originalDishes,
          'validationResults': [],
          'error': error.toString(),
          'fallbackUsed': true,
        },
      );
    }
  }

  /// Checks if a dish is from the database (has established ID pattern)
  bool _isExistingDish(ProcessedDish dish) {
    // Assume dishes from database have UUIDs or specific ID patterns
    // New dishes typically have generated IDs that are shorter or different format
    final id = dish.id;

    // Skip validation if:
    // 1. ID looks like a UUID (36 chars with dashes)
    // 2. ID starts with 'db_' (database prefix)
    // 3. ID is numeric (database auto-increment)
    if (id.length == 36 && id.contains('-')) {
      return true; // UUID from database
    }
    if (id.startsWith('db_') || id.startsWith('dish_')) {
      return true; // Database prefix
    }
    if (int.tryParse(id) != null) {
      return true; // Numeric database ID
    }

    return false; // Likely a newly generated dish
  }

  /// Validates and edits a newly created dish using AI
  Future<Map<String, dynamic>> _validateAndEditDish(
    ProcessedDish dish,
    ChatStepInput input,
  ) async {
    try {
      final prompt = _buildValidationPrompt(dish, input);

      final messages = [
        {
          'role': 'system',
          'content':
              'You are a nutrition expert validating dish data. Respond only in JSON format.',
        },
        {'role': 'user', 'content': prompt},
      ];

      final response = await _openaiService.sendChatRequest(
        messages: messages,
        temperature: 0.1, // Low temperature for consistent validation
        responseFormat: {'type': 'json_object'},
      );

      final content = response.choices.first.message.content?.trim() ?? '{}';
      if (content.isEmpty || content == '{}') {
        return {'success': false, 'error': 'Empty validation response'};
      }

      // Parse the JSON response
      Map<String, dynamic> validationData;
      try {
        validationData = jsonDecode(content) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('❌ Failed to parse validation JSON: $e');
        return {
          'success': false,
          'error': 'Invalid JSON response from validation',
        };
      }

      final needsEdits = validationData['needsEdits'] as bool? ?? false;
      final confidence =
          (validationData['confidence'] as num?)?.toDouble() ?? 1.0;

      if (!needsEdits) {
        return {
          'success': true,
          'dish': dish,
          'edits': [],
          'confidence': confidence,
        };
      }

      // Apply edits to create corrected dish
      final edits = validationData['edits'] as List<dynamic>? ?? [];
      final editedDish = _applyEdits(dish, edits);

      return {
        'success': true,
        'dish': editedDish,
        'edits': edits,
        'confidence': confidence,
      };
    } catch (error) {
      debugPrint('❌ Dish validation error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  /// Builds validation prompt for AI
  String _buildValidationPrompt(ProcessedDish dish, ChatStepInput input) {
    return '''
You are a nutrition expert validating a newly created dish. Analyze the dish and provide corrections if needed.

DISH TO VALIDATE:
Name: ${dish.name}
Description: ${dish.description ?? 'None'}
Servings: ${dish.servings}
Meal Type: ${dish.mealType?.name ?? 'Not specified'}

INGREDIENTS (${dish.ingredients.length}):
${dish.ingredients.map((ing) => '- ${ing.name}: ${ing.amount} ${ing.unit} (${ing.nutrition?.calories ?? 0} cal/100g)').join('\n')}

TOTAL NUTRITION:
- Calories: ${dish.totalNutrition.calories}
- Protein: ${dish.totalNutrition.protein}g
- Carbs: ${dish.totalNutrition.carbs}g  
- Fat: ${dish.totalNutrition.fat}g
- Fiber: ${dish.totalNutrition.fiber}g

VALIDATION CRITERIA:
1. Name should be clear and appetizing
2. Nutrition values should be reasonable for the ingredients and serving size
3. Ingredients should have realistic amounts and units
4. Total calories should roughly match macronutrient breakdown: (protein*4 + carbs*4 + fat*9)
5. Serving size should be realistic (typically 1-8 servings)

INSTRUCTIONS:
- If the dish is valid, respond with needsEdits: false
- If edits are needed, provide specific corrections
- Only suggest edits for actual errors, not preferences
- Be conservative - only fix clear mistakes

Respond in JSON format:
{
  "needsEdits": boolean,
  "confidence": 0.0-1.0,
  "reasoning": "explanation of validation",
  "edits": [
    {
      "field": "name|description|servings|ingredients|nutrition",
      "action": "update|fix",
      "currentValue": "current value",
      "newValue": "corrected value",
      "reason": "why this edit is needed"
    }
  ]
}
''';
  }

  /// Applies edits to create a corrected dish
  ProcessedDish _applyEdits(ProcessedDish dish, List<dynamic> edits) {
    var editedDish = dish;
    final originalData = dish.toJson();

    for (final edit in edits) {
      if (edit is! Map<String, dynamic>) continue;

      final field = edit['field'] as String?;
      final newValue = edit['newValue'];
      final reason = edit['reason'] as String? ?? 'AI validation edit';

      switch (field) {
        case 'name':
          if (newValue is String && newValue.trim().isNotEmpty) {
            editedDish = editedDish.copyWith(name: newValue.trim());
            debugPrint(
              '✏️ Edited dish name: ${dish.name} → ${newValue.trim()}',
            );

            _modificationTracker.recordAiValidation(
              stepName: stepName,
              description: 'AI updated dish name',
              technicalDetails: reason,
              beforeData: {'name': dish.name},
              afterData: {'name': newValue.trim()},
            );
          }
          break;

        case 'description':
          if (newValue is String) {
            editedDish = editedDish.copyWith(description: newValue.trim());
            debugPrint('✏️ Edited dish description');

            _modificationTracker.recordAiValidation(
              stepName: stepName,
              description: 'AI updated dish description',
              technicalDetails: reason,
              beforeData: {'description': dish.description},
              afterData: {'description': newValue.trim()},
            );
          }
          break;

        case 'servings':
          if (newValue is num && newValue > 0) {
            editedDish = editedDish.copyWith(servings: newValue.toDouble());
            debugPrint('✏️ Edited servings: ${dish.servings} → ${newValue}');

            _modificationTracker.recordAiValidation(
              stepName: stepName,
              description: 'AI corrected serving size',
              technicalDetails: reason,
              beforeData: {'servings': dish.servings},
              afterData: {'servings': newValue.toDouble()},
            );
          }
          break;

        case 'nutrition':
          // Handle nutrition edits (more complex, could edit individual values)
          if (newValue is Map<String, dynamic>) {
            final currentNutrition = editedDish.totalNutrition;
            final originalNutritionData = currentNutrition.toJson();

            final newNutrition = BasicNutrition(
              calories:
                  (newValue['calories'] as num?)?.toDouble() ??
                  currentNutrition.calories,
              protein:
                  (newValue['protein'] as num?)?.toDouble() ??
                  currentNutrition.protein,
              carbs:
                  (newValue['carbs'] as num?)?.toDouble() ??
                  currentNutrition.carbs,
              fat:
                  (newValue['fat'] as num?)?.toDouble() ?? currentNutrition.fat,
              fiber:
                  (newValue['fiber'] as num?)?.toDouble() ??
                  currentNutrition.fiber,
            );
            editedDish = editedDish.copyWith(totalNutrition: newNutrition);
            debugPrint('✏️ Edited nutrition values');

            _modificationTracker.recordNutritionFix(
              stepName: stepName,
              description: 'AI corrected nutrition values',
              technicalDetails: reason,
              beforeData: originalNutritionData,
              afterData: newNutrition.toJson(),
              severity: ModificationSeverity.high,
            );
          }
          break;
      }
    }

    // Update timestamp for edited dish
    editedDish = editedDish.copyWith(updatedAt: DateTime.now());

    // Record overall edit summary if any changes were made
    if (edits.isNotEmpty) {
      _modificationTracker.recordAiValidation(
        stepName: stepName,
        description: 'AI validation completed with ${edits.length} edits',
        technicalDetails:
            'Applied ${edits.length} corrections to improve dish quality',
        beforeData: {'editCount': 0, 'originalDish': originalData},
        afterData: {
          'editCount': edits.length,
          'editedDish': editedDish.toJson(),
        },
        severity: ModificationSeverity.high,
      );
    }

    return editedDish;
  }

  /// Performs quick automatic fixes for common nutrition data issues
  ProcessedDish _performQuickFixes(ProcessedDish dish) {
    try {
      // Check if ingredients have nutrition data
      bool hasIngredientNutrition = false;
      bool hasValidTotalNutrition = false;

      for (final ingredient in dish.ingredients) {
        if (ingredient.nutrition != null &&
            (ingredient.nutrition!.calories > 0 ||
                ingredient.nutrition!.protein > 0 ||
                ingredient.nutrition!.carbs > 0 ||
                ingredient.nutrition!.fat > 0)) {
          hasIngredientNutrition = true;
          break;
        }
      }

      // Check if total nutrition is valid
      if (dish.totalNutrition.calories > 0 ||
          dish.totalNutrition.protein > 0 ||
          dish.totalNutrition.carbs > 0 ||
          dish.totalNutrition.fat > 0) {
        hasValidTotalNutrition = true;
      }

      debugPrint(
        '🔧 Quick nutrition check: hasIngredientNutrition=$hasIngredientNutrition, hasValidTotalNutrition=$hasValidTotalNutrition',
      );

      // Track the nutrition assessment
      _modificationTracker.recordModification(
        type: PipelineModificationType.automaticFix,
        severity: ModificationSeverity.low,
        stepName: stepName,
        description: 'Nutrition data quality assessment completed',
        technicalDetails:
            'Ingredient nutrition: $hasIngredientNutrition, Total nutrition: $hasValidTotalNutrition',
        beforeData: {
          'dishName': dish.name,
          'hasIngredientNutrition': hasIngredientNutrition,
          'hasValidTotalNutrition': hasValidTotalNutrition,
        },
      );

      // If we have valid total nutrition but missing ingredient nutrition, that's okay for now
      if (hasValidTotalNutrition) {
        debugPrint('✅ Dish has valid total nutrition, keeping as-is');

        _modificationTracker.recordModification(
          type: PipelineModificationType.automaticFix,
          severity: ModificationSeverity.low,
          stepName: stepName,
          description: 'Dish nutrition validated - no fixes needed',
          technicalDetails: 'Total nutrition is present and valid',
        );

        return dish;
      }

      // If both are missing, this dish needs serious help - mark for AI validation
      if (!hasIngredientNutrition && !hasValidTotalNutrition) {
        debugPrint(
          '⚠️ Dish missing all nutrition data - will require AI validation',
        );

        _modificationTracker.recordModification(
          type: PipelineModificationType.automaticFix,
          severity: ModificationSeverity.high,
          stepName: stepName,
          description:
              'Critical nutrition data missing - flagged for AI validation',
          technicalDetails:
              'Both ingredient and total nutrition data are missing or invalid',
          wasSuccessful: false,
        );

        return dish;
      }

      debugPrint(
        '🔧 Nutrition data looks reasonable, proceeding to validation',
      );

      _modificationTracker.recordModification(
        type: PipelineModificationType.automaticFix,
        severity: ModificationSeverity.medium,
        stepName: stepName,
        description:
            'Nutrition data assessment passed - proceeding with validation',
        technicalDetails: 'Some nutrition data present, validation can proceed',
      );

      return dish;
    } catch (e) {
      debugPrint('❌ Error in quick fixes: $e');

      _modificationTracker.recordModification(
        type: PipelineModificationType.automaticFix,
        severity: ModificationSeverity.medium,
        stepName: stepName,
        description: 'Quick fixes failed with error',
        technicalDetails: 'Error during automatic fixes: $e',
        wasSuccessful: false,
        errorMessage: e.toString(),
      );

      return dish;
    }
  }

  /// Intelligently filters dishes based on relevance to user query and context optimization
  Future<Map<String, dynamic>> _filterDishesForContext(
    List<ProcessedDish> dishes,
    ChatStepInput input,
  ) async {
    if (dishes.isEmpty) {
      return {
        'dishes': dishes,
        'filteredOut': <ProcessedDish>[],
        'filteringApplied': false,
      };
    }

    try {
      debugPrint('🎯 Evaluating ${dishes.length} dishes for context relevance');

      // Get user's query from input
      final userQuery = input.userMessage;

      // Build evaluation prompt
      final prompt = _buildDishFilteringPrompt(dishes, userQuery);

      final messages = [
        {
          'role': 'system',
          'content':
              'You are an expert at determining dish relevance for user queries. Respond only in JSON format.',
        },
        {'role': 'user', 'content': prompt},
      ];

      final response = await _openaiService.sendChatRequest(
        messages: messages,
        temperature: 0.2, // Low temperature for consistent filtering decisions
        responseFormat: {'type': 'json_object'},
      );

      final content = response.choices.first.message.content?.trim() ?? '{}';
      if (content.isEmpty || content == '{}') {
        debugPrint('❌ Empty filtering response, keeping all dishes');
        return {
          'dishes': dishes,
          'filteredOut': <ProcessedDish>[],
          'filteringApplied': false,
        };
      }

      // Parse the JSON response
      Map<String, dynamic> filteringData;
      try {
        filteringData = jsonDecode(content) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('❌ Failed to parse filtering JSON: $e');
        return {
          'dishes': dishes,
          'filteredOut': <ProcessedDish>[],
          'filteringApplied': false,
        };
      }

      final shouldFilter = filteringData['shouldFilter'] as bool? ?? false;
      final relevantDishIds =
          (filteringData['relevantDishIds'] as List?)?.cast<String>() ?? [];
      final reasoning =
          filteringData['reasoning'] as String? ?? 'No reasoning provided';

      if (!shouldFilter || relevantDishIds.isEmpty) {
        debugPrint('🎯 AI determined no filtering needed: $reasoning');
        return {
          'dishes': dishes,
          'filteredOut': <ProcessedDish>[],
          'filteringApplied': false,
        };
      }

      // Filter dishes based on AI recommendation
      final filteredDishes = <ProcessedDish>[];
      final filteredOutDishes = <ProcessedDish>[];

      for (final dish in dishes) {
        if (relevantDishIds.contains(dish.id)) {
          filteredDishes.add(dish);
        } else {
          filteredOutDishes.add(dish);
        }
      }

      // Only apply filtering if we found relevant dishes (avoid filtering everything out)
      if (filteredDishes.isNotEmpty && filteredOutDishes.isNotEmpty) {
        debugPrint('🎯 Context filtering applied:');
        debugPrint('   Kept: ${filteredDishes.length} relevant dishes');
        debugPrint(
          '   Filtered out: ${filteredOutDishes.length} less relevant dishes',
        );
        debugPrint('   Reasoning: $reasoning');

        // Track this as a pipeline modification
        _modificationTracker.recordModification(
          type: PipelineModificationType.contextModification,
          severity: ModificationSeverity.medium,
          stepName: stepName,
          description: 'AI filtered dishes for context optimization',
          technicalDetails:
              'Kept ${filteredDishes.length}/${dishes.length} dishes. Reasoning: $reasoning',
          beforeData: {
            'dishCount': dishes.length,
            'dishNames': dishes.map((d) => d.name).toList(),
          },
          afterData: {
            'dishCount': filteredDishes.length,
            'dishNames': filteredDishes.map((d) => d.name).toList(),
            'filteredOutNames': filteredOutDishes.map((d) => d.name).toList(),
          },
        );

        return {
          'dishes': filteredDishes,
          'filteredOut': filteredOutDishes,
          'filteringApplied': true,
          'reasoning': reasoning,
        };
      } else {
        debugPrint(
          '🎯 Filtering would remove all dishes, keeping original set',
        );
        return {
          'dishes': dishes,
          'filteredOut': <ProcessedDish>[],
          'filteringApplied': false,
        };
      }
    } catch (error) {
      debugPrint('❌ Error during dish filtering: $error');
      return {
        'dishes': dishes,
        'filteredOut': <ProcessedDish>[],
        'filteringApplied': false,
      };
    }
  }

  /// Builds prompt for AI dish filtering evaluation
  String _buildDishFilteringPrompt(
    List<ProcessedDish> dishes,
    String userQuery,
  ) {
    final dishSummaries = dishes
        .map(
          (dish) => '''
ID: ${dish.id}
Name: ${dish.name}
Description: ${dish.description ?? 'No description'}
Meal Type: ${dish.mealType?.name ?? 'Unknown'}
Calories: ${dish.totalNutrition.calories} kcal
Servings: ${dish.servings}
Ingredients: ${dish.ingredients.map((i) => i.name).take(5).join(', ')}${dish.ingredients.length > 5 ? '...' : ''}
''',
        )
        .join('\n---\n');

    return '''
TASK: Determine if these dishes should be filtered to optimize context for the user's query.

USER QUERY: "$userQuery"

AVAILABLE DISHES (${dishes.length} total):
$dishSummaries

FILTERING CRITERIA:
1. If the user asks about specific dishes, recipes, or meal types - keep only those that match
2. If the user asks general nutrition questions - keep all dishes (they provide context)
3. If the user wants cooking instructions - keep dishes that match the cooking style/cuisine
4. If too many dishes (>10) - prioritize most relevant ones
5. If dishes seem unrelated to query - filter to most relevant ones

IMPORTANT RULES:
- Only filter if there are clear irrelevant dishes AND we can keep useful ones
- Never filter ALL dishes (always keep at least 1-2 relevant ones)
- When in doubt, keep more rather than less
- General queries (like "help with meal planning") should keep all dishes

Respond in JSON format:
{
  "shouldFilter": boolean,
  "relevantDishIds": ["id1", "id2", ...],
  "reasoning": "brief explanation of filtering decision",
  "confidence": 0.0-1.0
}
''';
  }
}
