import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/chat_types.dart';
import '../../models/user_ingredient.dart';
import '../../repositories/dish_repository.dart';
import '../../repositories/meal_repository.dart';
import '../../repositories/user_profile_repository.dart';
import 'openai_service.dart';
import '../storage/dish_service.dart';
import 'agent_steps/thinking_step.dart';
import 'agent_steps/context_gathering_step.dart';
import 'agent_steps/image_processing_step.dart';
import 'agent_steps/dish_processing_step.dart';
import 'agent_steps/response_generation_step.dart';
import 'agent_steps/deep_search_verification_step.dart';
import 'agent_steps/error_handling_step.dart';

/// Callback for real-time thinking step updates
typedef ThinkingStepCallback = void Function(String step, String? details);

/// Main orchestrator service for the chat agent system with full step-by-step processing
class ChatAgentService {
  final OpenAIService _openaiService;
  final DishRepository _dishRepository;
  final MealRepository _mealRepository;
  final UserProfileRepository _userProfileRepository;
  final DishService _dishService;

  // Agent steps
  late final ThinkingStep _thinkingStep;
  late final ContextGatheringStep _contextGatheringStep;
  late final ImageProcessingStep _imageProcessingStep;
  late final DishProcessingStep _dishProcessingStep;
  late final ResponseGenerationStep _responseGenerationStep;
  late final DeepSearchVerificationStep _deepSearchVerificationStep;
  late final ErrorHandlingStep _errorHandlingStep;
  // Configuration
  bool _deepSearchEnabled = false;
  int _maxRetries = 3;
  int _maxContextLength = 100000;

  // Callback for real-time step updates
  ThinkingStepCallback? _onThinkingStep;

  ChatAgentService({
    required OpenAIService openaiService,
    required DishRepository dishRepository,
    required MealRepository mealRepository,
    required UserProfileRepository userProfileRepository,
    required DishService dishService,
  }) : _openaiService = openaiService,
       _dishRepository = dishRepository,
       _mealRepository = mealRepository,
       _userProfileRepository = userProfileRepository,
       _dishService = dishService {
    _initializeSteps();
    debugPrint('🤖 ChatAgentService: Initialized with full agent steps');
  }

  /// Initialize all agent steps
  void _initializeSteps() {
    _thinkingStep = ThinkingStep(openaiService: _openaiService);
    _contextGatheringStep = ContextGatheringStep(
      dishRepository: _dishRepository,
      mealRepository: _mealRepository,
      userProfileRepository: _userProfileRepository,
    );
    _imageProcessingStep = ImageProcessingStep(openaiService: _openaiService);
    _dishProcessingStep = DishProcessingStep(
      dishRepository: _dishRepository,
      dishService: _dishService,
    );
    _responseGenerationStep = ResponseGenerationStep(
      openaiService: _openaiService,
    );
    _deepSearchVerificationStep = DeepSearchVerificationStep(
      openaiService: _openaiService,
    );
    _errorHandlingStep = ErrorHandlingStep();
  }

  /// Main entry point for processing chat messages with full agent pipeline
  Future<ChatResponse> processMessage({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
    required BotConfiguration botConfig,
    String? imageUri,
    List<UserIngredient>? userIngredients,
    ThinkingStepCallback? onThinkingStep,
  }) async {
    _onThinkingStep = onThinkingStep;

    debugPrint('🤖 ChatAgentService: Starting full agent processing pipeline');
    debugPrint('   Message length: ${userMessage.length}');
    debugPrint('   History length: ${conversationHistory.length}');
    debugPrint('   Bot type: ${botConfig.type}');
    debugPrint('   Has image: ${imageUri != null}');
    debugPrint('   User ingredients: ${userIngredients?.length ?? 0}');
    final startTime = DateTime.now();
    final List<ChatStepResult> stepResults = [];
    final List<String> thinkingSteps = [];

    // Prepare initial input for agent pipeline
    final initialInput = ChatStepInput(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      imageUri: imageUri,
      userIngredients: userIngredients,
      metadata: {
        'startTime': startTime.toIso8601String(),
        'deepSearchEnabled': _deepSearchEnabled,
        'botConfig': botConfig.toJson(),
      },
    );
    try {
      // Step 1: Thinking Step - Analyze user request and plan approach
      debugPrint('🧠 Step 1: Thinking...');
      final thinkingStepText =
          '🧠 Analyzing your request and planning approach...';
      thinkingSteps.add(thinkingStepText);
      _onThinkingStep?.call(
        thinkingStepText,
        'Breaking down your request and determining the best approach',
      );

      final thinkingResult = await _thinkingStep.execute(initialInput);
      stepResults.add(thinkingResult);

      if (!thinkingResult.success) {
        return _handleStepFailure(
          'thinking',
          thinkingResult,
          stepResults,
          thinkingSteps,
        );
      }

      // Step 2: Context Gathering - Collect relevant data
      debugPrint('📚 Step 2: Gathering context...');
      final contextStepText = '📚 Gathering relevant context and user data...';
      thinkingSteps.add(contextStepText);
      _onThinkingStep?.call(
        contextStepText,
        'Collecting your profile, preferences, and relevant meal history',
      ); // Patch: Always pass a valid ThinkingStepResponse object
      final thinkingResultObj = ThinkingStepResponse.safeFromDynamic(
        thinkingResult.data?['thinkingResult'],
      );
      var contextInput = initialInput.copyWith(
        thinkingResult: () => thinkingResultObj,
        metadata: {...initialInput.metadata!, ...thinkingResult.data!},
      );
      final contextResult = await _contextGatheringStep.execute(contextInput);
      stepResults.add(contextResult);
      debugPrint(
        '📚 Context gathering completed with success: ${contextResult.success} and data ${contextResult.data}',
      );
      if (!contextResult.success) {
        return _handleStepFailure(
          'context_gathering',
          contextResult,
          stepResults,
          thinkingSteps,
        );
      } // Step 3.5: Deep Search Verification (if enabled and has contextual features) - Pre-response validation
      ChatStepResult? verificationResult;
      if (_deepSearchEnabled) {
        if (_shouldRunDeepSearchVerification(thinkingResultObj)) {
          debugPrint('🔍 Step 3.5: Context validation...');
          final verificationStepText =
              '🔍 Validating context sufficiency for optimal response...';
          thinkingSteps.add(verificationStepText);
          _onThinkingStep?.call(
            verificationStepText,
            'Analyzing gathered context to ensure we can provide the best possible answer',
          );

          final verificationInput = contextInput.copyWith(
            metadata: {
              ...contextInput.metadata!,
              'contextGatheringResult': contextResult.data,
            },
          );

          verificationResult = await _deepSearchVerificationStep.execute(
            verificationInput,
          );
          stepResults.add(verificationResult);

          // Handle pipeline control decisions
          if (verificationResult.success) {
            final controlResult = await _handlePipelineControl(
              verificationResult,
              contextInput,
              stepResults,
              thinkingSteps,
            );

            if (controlResult != null) {
              // Pipeline control recommended changes, apply them
              contextInput = controlResult;
            }
          } else {
            debugPrint(
              '⚠️ Context validation failed, continuing with available context...',
            );
          }
        } else {
          // Deep search verification was skipped - track it
          debugPrint(
            '⏭️ Deep search verification skipped (no contextual features beyond conversation history)',
          );
          final skippedStepText = '⏭️ Deep search verification skipped';
          thinkingSteps.add(skippedStepText);
          _onThinkingStep?.call(
            skippedStepText,
            'No external data sources needed - only conversation history required for response',
          );

          // Add a skipped step result for the UI
          final skippedStepResult = ChatStepResult.success(
            stepName: 'deep_search_verification',
            data: {
              'skipped': true,
              'reason':
                  'No contextual features beyond conversation history needed',
              'contextRequirements':
                  thinkingResultObj?.contextRequirements.toJson(),
            },
          );
          stepResults.add(skippedStepResult);
        }
      }

      // Step 4: Image Processing (if image provided)
      ChatStepResult? imageResult;
      if (imageUri != null && imageUri.isNotEmpty) {
        debugPrint('📸 Step 3: Processing image...');
        final imageStepText = '📸 Analyzing uploaded image...';
        thinkingSteps.add(imageStepText);
        _onThinkingStep?.call(
          imageStepText,
          'Identifying food items, portions, and visual details from your image',
        );

        final imageInput = contextInput.copyWith(
          metadata: {...contextInput.metadata!, ...contextResult.data!},
        );
        imageResult = await _imageProcessingStep.execute(imageInput);
        stepResults.add(imageResult);

        if (!imageResult.success) {
          return _handleStepFailure(
            'image_processing',
            imageResult,
            stepResults,
            thinkingSteps,
          );
        }
      }

      // Step 4: Response Generation - Create final response
      debugPrint('✍️ Step 4: Generating response...');
      final responseStepText = '✍️ Crafting your personalized response...';
      thinkingSteps.add(responseStepText);
      _onThinkingStep?.call(
        responseStepText,
        'Combining all information to create a helpful and personalized answer',
      );

      // Extract enhanced system prompt from context gathering result
      String? enhancedSystemPrompt;
      try {
        final contextGatheringResultJson =
            contextResult.data?['contextGatheringResult']
                as Map<String, dynamic>?;
        if (contextGatheringResultJson != null) {
          final contextGatheringResponse =
              ContextGatheringStepResponse.fromJson(contextGatheringResultJson);
          enhancedSystemPrompt = contextGatheringResponse.enhancedSystemPrompt;
          debugPrint(
            '✅ Extracted enhanced system prompt: ${enhancedSystemPrompt?.length ?? 0} characters',
          );
        }
      } catch (e) {
        debugPrint('⚠️ Failed to extract enhanced system prompt: $e');
      }

      final responseInput = contextInput.copyWith(
        enhancedSystemPrompt: () => enhancedSystemPrompt,
        metadata: {
          ...contextInput.metadata!,
          ...contextResult.data!,
          if (imageResult != null) ...imageResult.data!,
        },
      );
      final responseResult = await _responseGenerationStep.execute(
        responseInput,
      );
      stepResults.add(responseResult);

      if (!responseResult.success) {
        return _handleStepFailure(
          'response_generation',
          responseResult,
          stepResults,
          thinkingSteps,
        );
      } // Step 5: Dish Processing (if AI response contains dishes)
      ChatStepResult? dishResult;
      try {
        // Get the raw AI response that contains potential dishes array
        final aiResponse =
            responseResult.data?['parsedResponse'] as Map<String, dynamic>?;

        if (aiResponse != null && _responseHasDishes(aiResponse)) {
          debugPrint('🍽️ Step 5: Processing dishes from AI response...');
          final dishStepText = '🍽️ Processing and analyzing dishes...';
          thinkingSteps.add(dishStepText);
          _onThinkingStep?.call(
            dishStepText,
            'Calculating nutrition values, ingredients, and meal details',
          );

          final dishInput = contextInput.copyWith(
            metadata: {
              'dishes': aiResponse['dishes'],
              'uploadedImageUri': imageUri,
            },
          );
          dishResult = await _dishProcessingStep.execute(dishInput);
          stepResults.add(dishResult);

          if (!dishResult.success && dishResult.error?.retryable == false) {
            return _handleStepFailure(
              'dish_processing',
              dishResult,
              stepResults,
              thinkingSteps,
            );
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error checking for dishes in response: $e');
      }

      // Step 6: Response Generation completed - Extract final response
      final chatResponseData =
          responseResult.data!['chatResponse'] as Map<String, dynamic>?;
      final finalResponse =
          chatResponseData?['replyText'] as String? ??
          'I apologize, but I encountered an issue generating a response. Please try again.';
      final extractedDishes =
          dishResult?.data?['validatedDishes'] as List? ?? [];

      final duration = DateTime.now().difference(startTime);
      debugPrint(
        '🤖 ChatAgentService: Completed full pipeline in ${duration.inMilliseconds}ms',
      ); // Return comprehensive ChatResponse with all step data
      return ChatResponse(
        replyText: finalResponse,
        dishes: extractedDishes.cast(),
        metadata: {
          'processingTime': duration.inMilliseconds,
          'mode': 'full_agent_pipeline',
          'botType': botConfig.type,
          'deepSearchEnabled': _deepSearchEnabled,
          'stepResults': stepResults.map((r) => r.toJson()).toList(),
          'thinkingSteps': thinkingSteps,
          'stepsCompleted': stepResults.length,
          'hasImage': imageUri != null,
          'dishesProcessed': {
            'validatedDishes':
                extractedDishes.map((dish) => dish.toJson()).toList(),
            'count': extractedDishes.length,
          },
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ChatAgentService: Critical error during processing: $e');
      debugPrint(
        'Stack trace: $stackTrace',
      ); // Use error handling step for recovery
      final errorStepText = '⚠️ Handling unexpected error...';
      thinkingSteps.add(errorStepText);
      _onThinkingStep?.call(
        errorStepText,
        'Attempting to recover from error and provide a helpful response',
      );
      final errorResult = await _errorHandlingStep.execute(
        initialInput.copyWith(
          metadata: {
            ...initialInput.metadata ?? {},
            'failedStep': 'chat_processing',
            'originalError': ChatAgentError(
              type: ChatErrorType.criticalError,
              message: e.toString(),
              details: stackTrace.toString(),
              retryable: false,
            ),
            'retryCount': 0,
            'contextSize': initialInput.userMessage.length,
            'partialResults': stepResults.map((r) => r.toJson()).toList(),
          },
        ),
      );
      stepResults.add(errorResult);
      final duration = DateTime.now().difference(startTime);

      // Extract response text from error handling result
      String responseText =
          'I apologize, but I encountered an error processing your request. Please try again.';
      if (errorResult.success && errorResult.data != null) {
        final recoveryResult =
            errorResult.data!['recoveryResult'] as ErrorRecoveryResult?;
        if (recoveryResult?.fallbackResponse != null) {
          responseText = recoveryResult!.fallbackResponse!.replyText;
        } else {
          responseText =
              'I encountered an issue but was able to recover. Please try your request again.';
        }
      }

      return ChatResponse(
        replyText: responseText,
        dishes: [],
        metadata: {
          'error': e.toString(),
          'mode': 'error_recovery',
          'processingTime': duration.inMilliseconds,
          'stepResults': stepResults.map((r) => r.toJson()).toList(),
          'thinkingSteps': thinkingSteps,
          'errorHandled': errorResult.success,
        },
      );
    }
  }

  /// Handle step failure with appropriate error response
  ChatResponse _handleStepFailure(
    String stepName,
    ChatStepResult failedResult,
    List<ChatStepResult> stepResults,
    List<String> thinkingSteps,
  ) {
    debugPrint('❌ Step "$stepName" failed: ${failedResult.error?.message}');
    thinkingSteps.add(
      '⚠️ Step "$stepName" encountered an issue, attempting recovery...',
    );

    return ChatResponse(
      replyText:
          failedResult.error?.retryable == true
              ? 'I encountered a temporary issue processing your request. Please try again.'
              : 'I apologize, but I\'m having trouble with that request. Could you try rephrasing it?',
      dishes: [],
      metadata: {
        'error': failedResult.error?.message ?? 'Unknown error',
        'failedStep': stepName,
        'mode': 'step_failure',
        'stepResults': stepResults.map((r) => r.toJson()).toList(),
        'thinkingSteps': thinkingSteps,
        'retryable': failedResult.error?.retryable ?? false,
      },
    );
  }

  /// Check if the AI response contains dishes to process
  bool _responseHasDishes(Map<String, dynamic> aiResponse) {
    final dishes = aiResponse['dishes'] as List<dynamic>?;
    final hasDishes = dishes != null && dishes.isNotEmpty;
    debugPrint(
      '🔍 AI response has dishes: $hasDishes (${dishes?.length ?? 0} dishes)',
    );
    return hasDishes;
  }

  /// Determines if deep search verification should run based on contextual features
  /// Only runs when there are actual data sources to validate (not just conversation history)
  bool _shouldRunDeepSearchVerification(ThinkingStepResponse? thinkingResult) {
    if (thinkingResult == null) return false;

    final requirements = thinkingResult.contextRequirements;

    // Check if any non-history contextual features are needed
    return requirements.needsUserProfile ||
        requirements.needsTodaysNutrition ||
        requirements.needsWeeklyNutritionSummary ||
        requirements.needsListOfCreatedDishes ||
        requirements.needsExistingDishes ||
        requirements.needsInfoOnDishCreation ||
        requirements.needsNutritionAdvice ||
        requirements.needsHistoricalMealLookup;
    // Note: needsConversationHistory is excluded as it doesn't require context validation
  }

  // Configuration methods
  void enableDeepSearch(bool enabled) {
    _deepSearchEnabled = enabled;
    debugPrint('🤖 Deep search ${enabled ? 'enabled' : 'disabled'}');
  }

  void setMaxRetries(int maxRetries) {
    _maxRetries = maxRetries;
    debugPrint('🤖 Max retries set to: $maxRetries');
  }

  void setMaxContextLength(int maxLength) {
    _maxContextLength = maxLength;
    debugPrint('🤖 Max context length set to: $maxLength');
  }

  bool get isDeepSearchEnabled => _deepSearchEnabled;
  int get maxRetries => _maxRetries;
  int get maxContextLength => _maxContextLength;

  /// Handles pipeline control decisions from deep search verification
  Future<ChatStepInput?> _handlePipelineControl(
    ChatStepResult verificationResult,
    ChatStepInput currentInput,
    List<ChatStepResult> stepResults,
    List<String> thinkingSteps,
  ) async {
    try {
      final pipelineControlData =
          verificationResult.data?['pipelineControl'] as Map<String, dynamic>?;
      if (pipelineControlData == null) {
        debugPrint('⚠️ No pipeline control data found in verification result');
        return null;
      }

      final pipelineControl = PipelineControlResult.fromJson(
        pipelineControlData,
      );
      debugPrint('🔄 Pipeline control analysis:');
      debugPrint('   Has enough context: ${pipelineControl.hasEnoughContext}');
      debugPrint('   Confidence: ${pipelineControl.confidence}');
      debugPrint('   Actions: ${pipelineControl.recommendedActions}');

      // If context is sufficient and confidence is high, continue normally
      if (pipelineControl.hasEnoughContext &&
          pipelineControl.confidence >= 0.8) {
        debugPrint(
          '✅ Context validation passed - proceeding with high confidence',
        );
        return null; // No changes needed
      }

      // Handle different pipeline control actions
      for (final action in pipelineControl.recommendedActions) {
        switch (action) {
          case PipelineControlAction.continueNormally:
            debugPrint('✅ Continuing normally despite lower confidence');
            return null;

          case PipelineControlAction.retryWithModifications:
            debugPrint('🔄 Retrying context gathering with modifications');
            if (pipelineControl.contextModifications != null) {
              // Apply context modifications to input
              return currentInput.copyWith(
                metadata: {
                  ...currentInput.metadata!,
                  ...pipelineControl.contextModifications!,
                  'retryAttempt':
                      (currentInput.metadata?['retryAttempt'] as int? ?? 0) + 1,
                },
              );
            }
            break;

          case PipelineControlAction.skipOptionalSteps:
            debugPrint('⏭️ Skipping optional steps for token optimization');
            return currentInput.copyWith(
              metadata: {
                ...currentInput.metadata!,
                'skipOptionalSteps': true,
                'stepsToSkip': pipelineControl.stepsToSkip ?? [],
              },
            );

          case PipelineControlAction.gatherAdditionalContext:
            debugPrint('📚 Additional context gathering recommended');
            if (pipelineControl.contextModifications != null) {
              return currentInput.copyWith(
                metadata: {
                  ...currentInput.metadata!,
                  'additionalContextNeeded': true,
                  ...pipelineControl.contextModifications!,
                },
              );
            }
            break;

          case PipelineControlAction.modifySearchParameters:
            debugPrint('🔧 Modifying search parameters');
            if (pipelineControl.searchParameters != null) {
              return currentInput.copyWith(
                metadata: {
                  ...currentInput.metadata!,
                  'searchParameters': pipelineControl.searchParameters,
                },
              );
            }
            break;

          case PipelineControlAction.discardAndRetry:
            debugPrint('🗑️ Discarding current context and retrying');
            // Reset to initial state but with retry metadata
            return currentInput.copyWith(
              metadata: {
                ...currentInput.metadata!,
                'discardPreviousContext': true,
                'retryAttempt':
                    (currentInput.metadata?['retryAttempt'] as int? ?? 0) + 1,
              },
            );
        }
      }

      // If no specific actions handled, log the recommendation and continue
      debugPrint('ℹ️ Pipeline control reasoning: ${pipelineControl.reasoning}');
      if (pipelineControl.identifiedGaps.isNotEmpty) {
        debugPrint('⚠️ Identified gaps: ${pipelineControl.identifiedGaps}');
      }
      if (pipelineControl.suggestions.isNotEmpty) {
        debugPrint('💡 Suggestions: ${pipelineControl.suggestions}');
      }

      return null; // Continue with current input if no modifications applied
    } catch (error) {
      debugPrint('❌ Error handling pipeline control: $error');
      return null; // Continue normally on error
    }
  }
}
