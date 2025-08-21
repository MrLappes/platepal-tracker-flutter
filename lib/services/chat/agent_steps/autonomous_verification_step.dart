import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart';
import '../openai_service.dart';
import '../verification_types.dart';
import '../pipeline_modification_tracker.dart';
import '../system_prompts.dart';

class AutonomousVerificationStep extends AgentStep {
  final PipelineModificationTracker _modificationTracker =
      PipelineModificationTracker();
  final OpenAIService _openaiService;

  AutonomousVerificationStep({required OpenAIService openaiService})
    : _openaiService = openaiService;

  @override
  String get stepName => 'autonomous_verification';

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      final checkpoint = _determineCheckpoint(input);
      debugPrint(
        '🔍 AutonomousVerificationStep: Running ${checkpoint.name} verification',
      );

      final result = await _runCheckpointVerification(checkpoint, input);

      return ChatStepResult.success(
        stepName: stepName,
        data: {
          'checkpoint': checkpoint.name,
          'verificationResult': result.toJson(),
          'decision': result.decision.name,
          'confidence': result.confidence,
          'reasoning': result.reasoning,
          'modifications': _modificationTracker.toJson(),
          'modificationSummary':
              _modificationTracker.generateUserFriendlySummary(),
        },
      );
    } catch (e) {
      debugPrint('❌ AutonomousVerificationStep failed: $e');
      // Always return a valid result to avoid pipeline failure
      return ChatStepResult.success(
        stepName: stepName,
        data: {
          'checkpoint': 'unknown',
          'verificationResult':
              VerificationResult(
                decision: VerificationDecision.continueNormally,
                confidence: 0.5,
                reasoning:
                    'Verification failed but proceeding to avoid pipeline breakdown: $e',
              ).toJson(),
          'decision': 'continueNormally',
          'confidence': 0.5,
          'reasoning': 'Verification failed but proceeding',
        },
      );
    }
  }

  /// Determine which checkpoint this verification is for
  VerificationCheckpoint _determineCheckpoint(ChatStepInput input) {
    // Only support post-execution verification now (context validation)
    // Post-response verification has been removed - use DishValidationStep for dish-specific validation
    return VerificationCheckpoint.postExecution;
  }

  /// Run verification for the specific checkpoint
  Future<VerificationResult> _runCheckpointVerification(
    VerificationCheckpoint checkpoint,
    ChatStepInput input,
  ) async {
    switch (checkpoint) {
      case VerificationCheckpoint.postExecution:
        return _verifyPostExecution(input);
      case VerificationCheckpoint.postResponse:
        // Post-response verification removed - return success to continue
        debugPrint(
          '⏭️ Post-response verification disabled - use DishValidationStep for dish validation',
        );
        return VerificationResult(
          decision: VerificationDecision.continueNormally,
          confidence: 1.0,
          reasoning:
              'Post-response verification disabled - dish validation handled by specialized step',
        );
    }
  }

  /// Verify that executed steps gathered sufficient context
  Future<VerificationResult> _verifyPostExecution(ChatStepInput input) async {
    final userMessage = input.userMessage;
    final stepResults = input.metadata?['stepResults'] as List<dynamic>? ?? [];
    final completedSteps =
        input.metadata?['completedSteps'] as List<String>? ?? [];

    // Extract loop detection information
    final isLikelyInLoop = input.metadata?['isLikelyInLoop'] as bool? ?? false;
    final pipelineHistorySummary =
        input.metadata?['pipelineHistorySummary'] as String? ?? '';
    final attemptCount = input.metadata?['attemptCount'] as int? ?? 1;

    // EMERGENCY LOOP BREAKER - Force continue after too many thinking attempts OR total steps
    final totalStepsExecuted =
        input.metadata?['totalStepsExecuted'] as int? ?? 0;
    if (attemptCount > 20 || totalStepsExecuted > 20) {
      debugPrint(
        '🚨 EMERGENCY VERIFICATION OVERRIDE: Forcing continue to break infinite loop!',
      );
      debugPrint('   Thinking attempts: $attemptCount (limit: 20)');
      debugPrint('   Total steps executed: $totalStepsExecuted (limit: 20)');
      return VerificationResult(
        decision: VerificationDecision.continueNormally,
        confidence: 0.8,
        reasoning:
            '🚨 EMERGENCY OVERRIDE: Forcing continue to prevent infinite loop after $attemptCount thinking attempts and $totalStepsExecuted total steps (automatic loop breaker activated)',
      );
    }

    // Extract thinking step result to understand what instructions were provided
    final thinkingResult =
        input.thinkingResult ??
        _extractThinkingResultFromStepResults(stepResults);

    // Extract available dishes from context gathering result to validate relevance
    final availableDishes = _extractAvailableDishes(stepResults, input);

    // Filter dishes based on relevance to user query to avoid sending unnecessary context
    final filteredDishes = await _filterRelevantDishes(
      availableDishes,
      userMessage,
      thinkingResult,
    );

    // Update metadata to use filtered dishes instead of all dishes
    if (filteredDishes.length < availableDishes.length) {
      debugPrint(
        '🔍 AutonomousVerificationStep: Filtered dishes from ${availableDishes.length} to ${filteredDishes.length}',
      );
      debugPrint(
        '   Original dishes: ${availableDishes.map((d) => d['name']).join(', ')}',
      );
      debugPrint(
        '   Kept dishes: ${filteredDishes.map((d) => d['name']).join(', ')}',
      );

      // Record this optimization
      _modificationTracker.recordModification(
        type: PipelineModificationType.contextModification,
        severity: ModificationSeverity.medium,
        stepName: stepName,
        description: 'Optimized context by filtering irrelevant dishes',
        technicalDetails:
            'Reduced dishes sent to response generation from ${availableDishes.length} to ${filteredDishes.length}',
        beforeData: {'dishCount': availableDishes.length},
        afterData: {'dishCount': filteredDishes.length},
      );

      // Update input metadata with filtered dishes
      if (input.metadata != null) {
        final updatedMetadata = Map<String, dynamic>.from(input.metadata!);

        // Update context gathering result with filtered dishes
        if (updatedMetadata.containsKey('contextGatheringResult')) {
          final contextGatheringResult = Map<String, dynamic>.from(
            updatedMetadata['contextGatheringResult'] as Map<String, dynamic>,
          );

          if (contextGatheringResult.containsKey('gatheredContextData')) {
            final gatheredContextData = Map<String, dynamic>.from(
              contextGatheringResult['gatheredContextData']
                  as Map<String, dynamic>,
            );

            // Replace existing dishes with filtered dishes
            gatheredContextData['existingDishes'] = filteredDishes;

            // Update the nested structures
            contextGatheringResult['gatheredContextData'] = gatheredContextData;
            updatedMetadata['contextGatheringResult'] = contextGatheringResult;

            // Create new input with updated metadata
            input = input.copyWith(metadata: updatedMetadata);
          }
        }
      }
    } else {
      debugPrint(
        '🔍 AutonomousVerificationStep: All ${availableDishes.length} dishes are relevant, no filtering needed',
      );
    }

    final prompt = _buildPostExecutionPrompt(
      userMessage,
      stepResults,
      completedSteps,
      thinkingResult,
      filteredDishes, // Use filtered dishes instead of all dishes
      isLikelyInLoop,
      pipelineHistorySummary,
      attemptCount,
    );

    try {
      final result = await _runVerification(prompt, userMessage);
      return result;
    } catch (e) {
      debugPrint('❌ Post-execution verification failed: $e');
      return VerificationResult(
        decision: VerificationDecision.continueNormally,
        confidence: 0.5,
        reasoning:
            'Verification failed but proceeding to avoid pipeline breakdown',
      );
    }
  }

  /// Verify response quality and dish data accuracy
  /// Post-response verification removed - use DishValidationStep for dish validation
  /* 
  Future<VerificationResult> _verifyPostResponse(ChatStepInput input) async {
    // This method has been deprecated and removed from the pipeline
    // Use DishValidationStep for dish-specific validation instead
    return VerificationResult(
      decision: VerificationDecision.continueNormally,
      confidence: 1.0,
      reasoning: 'Post-response verification disabled',
    );
  }
  */

  /// Build prompt for post-execution verification
  String _buildPostExecutionPrompt(
    String userMessage,
    List<dynamic> stepResults,
    List<String> completedSteps,
    ThinkingStepResponse? thinkingResult,
    List<dynamic> availableDishes,
    bool isLikelyInLoop,
    String pipelineHistorySummary,
    int attemptCount,
  ) {
    final stepSummary = _formatStepResults(stepResults, completedSteps);
    final thinkingInstructions = _formatThinkingInstructions(thinkingResult);
    final availableDishesText = _formatAvailableDishes(availableDishes);

    // Add loop detection warning if necessary
    final loopWarning =
        isLikelyInLoop
            ? '''
⚠️ LOOP DETECTION WARNING ⚠️
The pipeline appears to be in a repetitive loop (attempt #$attemptCount). 
This suggests the current approach may not be working. Consider:
- Continuing with available context instead of retrying
- Accepting that some context may be missing
- The user request may be fundamentally unclear or impossible to fulfill completely

PIPELINE HISTORY:
$pipelineHistorySummary

'''
            : attemptCount > 1
            ? '''
RETRY CONTEXT (Attempt #$attemptCount):
$pipelineHistorySummary

'''
            : '';

    final loopPreventionSection =
        isLikelyInLoop
            ? '''
🔄 LOOP PREVENTION PRIORITY:
- Break the cycle by continuing with available context
- Accept that some context may be missing rather than retrying endlessly
- Response generation can work with imperfect context
- Better to provide a reasonable answer than get stuck in loops

'''
            : '';

    return SystemPrompts.autonomousVerificationTemplate
        .replaceAll('{userMessage}', userMessage)
        .replaceAll('{loopWarning}', loopWarning)
        .replaceAll('{thinkingInstructions}', thinkingInstructions)
        .replaceAll('{stepSummary}', stepSummary)
        .replaceAll('{availableDishesText}', availableDishesText)
        .replaceAll(
          '{loopDetectedClause}',
          isLikelyInLoop
              ? 'ESPECIALLY if loop detected - break the cycle by proceeding with available context'
              : 'Available context enables quality response generation',
        )
        .replaceAll(
          '{retryLoopClause}',
          isLikelyInLoop
              ? 'BUT AVOID if loop detected - prefer to continue with available context'
              : 'More targeted search could find relevant dishes',
        )
        .replaceAll(
          '{restartLoopClause}',
          isLikelyInLoop
              ? 'RARELY use - prefer CONTINUE to break loops'
              : 'Thinking step categorized request completely wrong',
        )
        .replaceAll('{loopPreventionSection}', loopPreventionSection)
        .replaceAll(
          '{loopReasoningClause}',
          isLikelyInLoop ? ' AND considering loop prevention' : '',
        );
  }

  /// Extract thinking result from step results if not directly available
  ThinkingStepResponse? _extractThinkingResultFromStepResults(
    List<dynamic> stepResults,
  ) {
    try {
      for (final stepResult in stepResults) {
        if (stepResult is Map<String, dynamic> &&
            stepResult['stepName'] == 'thinking' &&
            stepResult['success'] == true) {
          final data = stepResult['data'] as Map<String, dynamic>?;
          final thinkingResultJson =
              data?['thinkingResult'] as Map<String, dynamic>?;
          if (thinkingResultJson != null) {
            return ThinkingStepResponse.fromJson(thinkingResultJson);
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to extract thinking result from step results: $e');
    }
    return null;
  }

  /// Format thinking step instructions for verification prompts
  String _formatThinkingInstructions(ThinkingStepResponse? thinkingResult) {
    if (thinkingResult == null) {
      return 'No thinking step analysis available.';
    }

    final buffer = StringBuffer();
    buffer.writeln('User Intent: ${thinkingResult.userIntent}');
    buffer.writeln(
      'Response Requirements: ${thinkingResult.responseRequirements.join(", ")}',
    );
    buffer.writeln('Context Requirements:');

    final context = thinkingResult.contextRequirements;
    final requirements = <String>[];

    if (context.needsUserProfile) requirements.add('User profile data');
    if (context.needsTodaysNutrition) {
      requirements.add('Today\'s nutrition summary');
    }
    if (context.needsWeeklyNutritionSummary) {
      requirements.add('Weekly nutrition summary');
    }
    if (context.needsListOfCreatedDishes) {
      requirements.add('User\'s created dishes');
    }
    if (context.needsExistingDishes) {
      requirements.add('Database of existing dishes');
      // Add search terms information
      if (context.dishSearchTerms?.isNotEmpty == true) {
        requirements.add(
          '  └ Dish search terms: ${context.dishSearchTerms!.join(", ")}',
        );
      }
      if (context.ingredientSearchTerms?.isNotEmpty == true) {
        requirements.add(
          '  └ Ingredient search terms: ${context.ingredientSearchTerms!.join(", ")}',
        );
      }
    }
    if (context.needsInfoOnDishCreation) {
      requirements.add('Dish creation capabilities');
    }
    if (context.needsNutritionAdvice) requirements.add('Nutrition advice');
    if (context.needsHistoricalMealLookup) {
      requirements.add('Historical meal data');
    }
    if (context.needsConversationHistory) {
      requirements.add('Conversation history');
    }

    if (requirements.isNotEmpty) {
      buffer.writeln('  - ${requirements.join("\n  - ")}');
    } else {
      buffer.writeln('  - No specific context requirements identified');
    }

    return buffer.toString();
  }

  /// Extract available dishes from context gathering step results or input metadata
  List<dynamic> _extractAvailableDishes(
    List<dynamic> stepResults, [
    ChatStepInput? input,
  ]) {
    try {
      // First try to get from input metadata (most recent)
      if (input?.metadata != null) {
        final contextGatheringResult =
            input!.metadata!['contextGatheringResult'] as Map<String, dynamic>?;
        if (contextGatheringResult != null) {
          final contextData =
              contextGatheringResult['gatheredContextData']
                  as Map<String, dynamic>?;
          if (contextData != null) {
            final existingDishes =
                contextData['existingDishes'] as List<dynamic>? ?? [];
            final userCreatedDishes =
                contextData['userCreatedDishes'] as List<dynamic>? ?? [];
            final allDishes = [...existingDishes, ...userCreatedDishes];
            debugPrint(
              '🔍 Found ${allDishes.length} dishes from input metadata: ${existingDishes.length} existing + ${userCreatedDishes.length} user-created',
            );
            return allDishes;
          }
        }
      }

      // Fallback to step results
      for (final stepResult in stepResults) {
        if (stepResult is Map<String, dynamic> &&
            stepResult['stepName'] == 'context_gathering' &&
            stepResult['success'] == true) {
          final data = stepResult['data'] as Map<String, dynamic>?;
          final contextGatheringResult =
              data?['contextGatheringResult'] as Map<String, dynamic>?;
          if (contextGatheringResult != null) {
            final contextData =
                contextGatheringResult['gatheredContextData']
                    as Map<String, dynamic>?;
            if (contextData != null) {
              // Look for existing dishes
              final existingDishes =
                  contextData['existingDishes'] as List<dynamic>? ?? [];
              final userCreatedDishes =
                  contextData['userCreatedDishes'] as List<dynamic>? ?? [];

              // Combine both lists
              final allDishes = [...existingDishes, ...userCreatedDishes];
              debugPrint(
                '🔍 Found ${allDishes.length} dishes from step results: ${existingDishes.length} existing + ${userCreatedDishes.length} user-created',
              );
              return allDishes;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to extract available dishes from step results: $e');
    }
    debugPrint('⚠️ No available dishes found in context data');
    return [];
  }

  /// Format available dishes for display in verification prompt
  String _formatAvailableDishes(List<dynamic> availableDishes) {
    if (availableDishes.isEmpty) {
      return 'No dishes found in database - this is normal for new users or when no dishes match the search criteria.';
    }

    final buffer = StringBuffer();
    buffer.writeln('Found ${availableDishes.length} available dishes:');

    for (int i = 0; i < availableDishes.length && i < 10; i++) {
      // Limit to first 10 for readability
      final dish = availableDishes[i];
      if (dish is Map<String, dynamic>) {
        final id = dish['id'] ?? 'unknown-id';
        final name = dish['name'] ?? 'Unknown Dish';
        final description = dish['description'] ?? '';
        final category = dish['category'] ?? '';
        final servingSize = dish['servingSize'] ?? 0;
        final calories = dish['calories'] ?? 0;
        final protein = dish['protein'] ?? 0;
        final carbs = dish['carbs'] ?? 0;
        final fat = dish['fat'] ?? 0;
        final fiber = dish['fiber'] ?? 0;

        buffer.writeln('${i + 1}. ID: $id, Name: "$name"');
        if (category.isNotEmpty) buffer.writeln('   Category: $category');
        if (description.isNotEmpty && description.length < 150) {
          buffer.writeln('   Description: $description');
        }

        // Add nutritional information
        buffer.writeln(
          '   Nutrition (per ${servingSize}g): ${calories}cal, ${protein}g protein, ${carbs}g carbs, ${fat}g fat, ${fiber}g fiber',
        );

        // Add ingredients information
        final ingredients = dish['ingredients'] as List<dynamic>?;
        if (ingredients != null && ingredients.isNotEmpty) {
          final ingredientNames = ingredients
              .take(5)
              .map((ing) {
                if (ing is Map<String, dynamic>) {
                  return ing['name'] ?? 'Unknown ingredient';
                }
                return ing.toString();
              })
              .join(', ');
          buffer.writeln(
            '   Key ingredients: $ingredientNames${ingredients.length > 5 ? ' and ${ingredients.length - 5} more...' : ''}',
          );
        }
      }
    }

    if (availableDishes.length > 10) {
      buffer.writeln('... and ${availableDishes.length - 10} more dishes');
    }

    buffer.writeln(
      '\nIMPORTANT: These are ALL the dishes available in the database. There are no additional hidden dishes.',
    );

    return buffer.toString();
  }

  /// Format step results for verification prompt
  String _formatStepResults(
    List<dynamic> stepResults,
    List<String> completedSteps,
  ) {
    final buffer = StringBuffer();

    for (int i = 0; i < completedSteps.length; i++) {
      final stepName = completedSteps[i];
      final stepData = i < stepResults.length ? stepResults[i] : null;

      buffer.writeln('\n$stepName:');
      if (stepData is Map<String, dynamic>) {
        if (stepData['success'] == true) {
          buffer.writeln('  ✅ Success');
          final data = stepData['data'] as Map<String, dynamic>?;
          if (data != null) {
            _formatStepData(buffer, data, '  ');
          }
        } else {
          buffer.writeln('  ❌ Failed: ${stepData['error'] ?? 'Unknown error'}');
        }
      }
    }

    return buffer.toString();
  }

  /// Format step data for display
  void _formatStepData(
    StringBuffer buffer,
    Map<String, dynamic> data,
    String indent,
  ) {
    data.forEach((key, value) {
      if (value is String && value.length < 100) {
        buffer.writeln('$indent$key: $value');
      } else if (value is num) {
        buffer.writeln('$indent$key: $value');
      } else if (value is List && value.isNotEmpty) {
        buffer.writeln('$indent$key: ${value.length} items');
      }
    });
  }

  /// Execute verification with OpenAI
  Future<VerificationResult> _runVerification(
    String prompt,
    String userMessage,
  ) async {
    final messages = [
      {'role': 'system', 'content': prompt},
      {'role': 'user', 'content': userMessage},
    ];

    final response = await _openaiService.sendChatRequest(
      messages: messages,
      temperature: 0.3,
      responseFormat: {'type': 'json_object'},
    );

    final content = response.choices.first.message.content?.trim() ?? '{}';

    try {
      // Parse JSON response
      final result = jsonDecode(content) as Map<String, dynamic>;

      // Extract decision
      final decision =
          result['decision']?.toString().toLowerCase() ?? 'continueNormally';
      final confidence = (result['confidence'] as num?)?.toDouble() ?? 0.5;
      final reasoning =
          result['reasoning']?.toString() ?? 'No reasoning provided';

      // Map decision strings to enum
      VerificationDecision verificationDecision;
      switch (decision) {
        case 'approve':
          verificationDecision = VerificationDecision.approve;
          break;
        case 'fixdishes':
          verificationDecision = VerificationDecision.fixDishes;
          break;
        case 'retryresponse':
          verificationDecision = VerificationDecision.retryResponse;
          break;
        case 'restartthinking':
          verificationDecision = VerificationDecision.restartThinking;
          break;
        case 'selectexistingdishes':
          verificationDecision = VerificationDecision.selectExistingDishes;
          break;
        default:
          verificationDecision = VerificationDecision.continueNormally;
      }

      return VerificationResult(
        decision: verificationDecision,
        confidence: confidence,
        reasoning: reasoning,
        responseIssues:
            (result['responseIssues'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        dishIssues:
            (result['dishIssues'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        summary: result['summary']?.toString(),
        dishFixes: (result['dishFixes'] as Map<String, dynamic>?) ?? {},
        missingRequirements:
            (result['missingRequirements'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        selectedDishIds:
            (result['selectedDishIds'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    } catch (e) {
      debugPrint('⚠️ Failed to parse verification result: $e');
      debugPrint('Raw response: $content');

      // Always return a valid result
      return VerificationResult(
        decision: VerificationDecision.continueNormally,
        confidence: 0.5,
        reasoning: 'Could not parse verification result, proceeding normally',
      );
    }
  }

  /// Filters dishes to only include those relevant to the user query
  /// Returns a filtered list of dishes to avoid sending unnecessary context
  Future<List<dynamic>> _filterRelevantDishes(
    List<dynamic> availableDishes,
    String userMessage,
    ThinkingStepResponse? thinkingResult,
  ) async {
    if (availableDishes.isEmpty) {
      return [];
    }

    debugPrint(
      '🔍 Filtering ${availableDishes.length} dishes for relevance to: "$userMessage"',
    );

    // If thinking result indicates specific dish search terms, use those for filtering
    final searchTerms =
        thinkingResult?.contextRequirements.dishSearchTerms ?? [];
    final ingredientTerms =
        thinkingResult?.contextRequirements.ingredientSearchTerms ?? [];

    // If we have no search terms or thinking result doesn't exist, keep all dishes
    if ((searchTerms.isEmpty && ingredientTerms.isEmpty) ||
        thinkingResult == null) {
      debugPrint('🔍 No specific search terms found, keeping all dishes');
      return availableDishes;
    }

    // See if this is likely a recipe request or dish creation scenario
    final isRecipeRequest = thinkingResult.responseRequirements.any(
      (req) =>
          req.contains('recipe') ||
          req.contains('dish_creation') ||
          req.contains('create_dish'),
    );

    // For recipe requests, we often don't need to send existing dishes
    // unless they exactly match what the user is looking for
    if (isRecipeRequest && !userMessage.toLowerCase().contains('similar')) {
      debugPrint('🔍 Recipe request detected, filtering dishes strictly');

      // For recipe requests, only include dishes that have very strong term matches
      final strongMatches =
          availableDishes.where((dish) {
            final dishName = dish['name']?.toString().toLowerCase() ?? '';

            // Check for strong matches with search terms
            for (final term in searchTerms) {
              final termLower = term.toLowerCase();
              if (dishName.contains(termLower)) {
                return true;
              }
            }

            return false;
          }).toList();

      // If we found strong matches, return only those
      if (strongMatches.isNotEmpty) {
        debugPrint(
          '🔍 Found ${strongMatches.length} strong matches for recipe request',
        );
        return strongMatches;
      }

      // For recipe requests without strong matches, don't send any dishes
      // to avoid cluttering context - the response generation will create a recipe
      debugPrint(
        '🔍 No strong matches found for recipe request, filtering out all dishes',
      );
      return [];
    }

    // For general queries, do more inclusive filtering
    final filteredDishes =
        availableDishes.where((dish) {
          final dishName = dish['name']?.toString().toLowerCase() ?? '';
          final dishDescription =
              dish['description']?.toString().toLowerCase() ?? '';
          final dishIngredients = (dish['ingredients'] as List<dynamic>? ?? []);

          // Check dish name and description against search terms
          for (final term in searchTerms) {
            final termLower = term.toLowerCase();
            if (dishName.contains(termLower) ||
                dishDescription.contains(termLower)) {
              return true;
            }
          }

          // Check ingredients against ingredient search terms
          for (final term in ingredientTerms) {
            final termLower = term.toLowerCase();
            for (final ingredient in dishIngredients) {
              final ingredientName =
                  ingredient['name']?.toString().toLowerCase() ?? '';
              if (ingredientName.contains(termLower)) {
                return true;
              }
            }
          }

          return false;
        }).toList();

    return filteredDishes;
  }
}
