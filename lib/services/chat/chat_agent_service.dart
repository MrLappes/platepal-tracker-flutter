import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/chat_types.dart';
import '../../models/user_ingredient.dart';
import '../../repositories/dish_repository.dart';
import '../../repositories/meal_repository.dart';
import '../../repositories/user_profile_repository.dart';
import 'openai_service.dart';
import '../storage/dish_service.dart';
import 'agent_steps/thinking_step.dart';
import 'agent_steps/context_gathering_step.dart';
import 'agent_steps/dish_processing_step.dart';
import 'agent_steps/dish_validation_step.dart';
import 'agent_steps/response_generation_step.dart';
import 'agent_steps/autonomous_verification_step.dart';
import 'agent_steps/error_handling_step.dart';
import 'agent_steps/agent_step_factory.dart';
import 'pipeline_history_tracker.dart';
import 'pipeline_modification_tracker.dart';

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
  late final DishProcessingStep _dishProcessingStep;
  late final DishValidationStep _dishValidationStep;
  late final ResponseGenerationStep _responseGenerationStep;
  late final AutonomousVerificationStep _autonomousVerificationStep;
  late final ErrorHandlingStep _errorHandlingStep;
  // Pipeline tracking for loop prevention and modifications
  final PipelineHistoryTracker _historyTracker = PipelineHistoryTracker();
  final PipelineModificationTracker _modificationTracker =
      PipelineModificationTracker();
  // Configuration
  bool _deepSearchEnabled = false; // Deep search verification enabled flag
  int _maxRetries =
      20; // Maximum number of steps/retries before forcing completion
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
    _dishProcessingStep = DishProcessingStep(
      dishRepository: _dishRepository,
      dishService: _dishService,
    );
    _dishValidationStep = DishValidationStep(
      openaiService: _openaiService,
      modificationTracker: _modificationTracker,
    );
    _responseGenerationStep = ResponseGenerationStep(
      openaiService: _openaiService,
    );
    _autonomousVerificationStep = AutonomousVerificationStep(
      openaiService: _openaiService,
    );
    _errorHandlingStep = ErrorHandlingStep();
  }

  /// Initialize deep search settings from SharedPreferences
  Future<void> initializeFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Load deep search setting
      _deepSearchEnabled = prefs.getBool('deep_search_enabled') ?? false;
      debugPrint('🤖 ChatAgentService: Loaded settings from preferences');
      debugPrint('   Deep search: $_deepSearchEnabled');
    } catch (e) {
      debugPrint('❌ ChatAgentService: Failed to load settings: $e');
    }
  }

  /// Enable or disable deep search verification
  void enableDeepSearch(bool enabled) async {
    _deepSearchEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('deep_search_enabled', enabled);
    debugPrint('🤖 ChatAgentService: Deep search verification set to $enabled');
  }

  /// Get deep search verification status
  bool get isDeepSearchEnabled => _deepSearchEnabled;

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

    // Clear pipeline history and modifications for new request to prevent cross-request contamination
    _historyTracker.clear();
    _modificationTracker.clear();

    // Ensure settings are loaded from preferences
    await initializeFromPreferences();

    debugPrint('🤖 ChatAgentService: Starting full agent processing pipeline');
    debugPrint('   Message length: ${userMessage.length}');
    debugPrint('   History length: ${conversationHistory.length}');
    debugPrint('   Bot type: ${botConfig.type}');
    debugPrint('   Has image: ${imageUri != null}');
    debugPrint('   User ingredients: ${userIngredients?.length ?? 0}');
    debugPrint('   Deep search enabled: $_deepSearchEnabled');

    // Get the appropriate pipeline configuration based on settings
    final pipelineConfig = getPipelineConfig();
    debugPrint(
      '📋 Pipeline config: Deep search ${pipelineConfig.deepSearchEnabled}',
    );
    debugPrint('   Steps: ${pipelineConfig.allSteps.join(" -> ")}');

    final startTime = DateTime.now();

    // Use autonomous verification pipeline if deep search is enabled
    if (_deepSearchEnabled && pipelineConfig.deepSearchEnabled) {
      return _processWithAutonomousVerification(
        userMessage: userMessage,
        conversationHistory: conversationHistory,
        botConfig: botConfig,
        imageUri: imageUri,
        userIngredients: userIngredients,
        startTime: startTime,
      );
    }

    // Fall back to original pipeline for non-deep search mode
    return _processWithOriginalPipeline(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      botConfig: botConfig,
      imageUri: imageUri,
      userIngredients: userIngredients,
      startTime: startTime,
      pipelineConfig: pipelineConfig,
    );
  }

  /// Process message with autonomous verification checkpoints
  Future<ChatResponse> _processWithAutonomousVerification({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
    required BotConfiguration botConfig,
    String? imageUri,
    List<UserIngredient>? userIngredients,
    required DateTime startTime,
    String? enhancedContext,
    int restartCount = 0,
    List<ChatStepResult>? previousStepResults,
    List<String>? previousThinkingSteps,
    List<String>? previousCompletedSteps,
    int previousTotalStepsExecuted = 0,
  }) async {
    // Preserve history from previous attempts for continuity and learning
    final List<ChatStepResult> stepResults =
        previousStepResults != null ? [...previousStepResults] : [];
    final List<String> thinkingSteps =
        previousThinkingSteps != null ? [...previousThinkingSteps] : [];
    final List<String> completedSteps =
        previousCompletedSteps != null ? [...previousCompletedSteps] : [];
    int totalStepsExecuted = previousTotalStepsExecuted;

    // Add restart markers to the thinking steps for user visibility
    if (restartCount > 0) {
      thinkingSteps.add(
        '🔄 Restarting with enhanced strategy (attempt ${restartCount + 1}/3)...',
      );
      debugPrint(
        '🔄 Restart $restartCount: Preserving ${previousStepResults?.length ?? 0} step results and ${previousThinkingSteps?.length ?? 0} thinking steps',
      );
    }

    // Prepare initial input for agent pipeline
    var currentInput = ChatStepInput(
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      imageUri: imageUri,
      userIngredients: userIngredients,
      metadata: {
        'startTime': startTime.toIso8601String(),
        'deepSearchEnabled': _deepSearchEnabled,
        'botConfig': botConfig.toJson(),
        'totalStepsExecuted': totalStepsExecuted,
        'restartCount': restartCount,
        'enhancedContext': enhancedContext,
        'previousAttempts': _buildPreviousAttemptsHistory(
          previousStepResults,
          previousThinkingSteps,
          restartCount,
        ),
      },
    );

    try {
      // Step 1: THINKING STEP - Analyze what to do
      debugPrint('🧠 Step 1: Running thinking step...');
      thinkingSteps.add('🧠 Analyzing your request and planning approach...');
      _onThinkingStep?.call(
        '🧠 Analyzing your request and planning approach...',
        'Breaking down your request and determining the best approach',
      );

      // Enhance input with previous attempts history for better decision making
      final thinkingInput = currentInput.copyWith(
        enhancedSystemPrompt: () {
          final basePrompt = currentInput.enhancedSystemPrompt ?? '';
          final previousHistory =
              currentInput.metadata?['previousAttempts'] as String? ?? '';
          final enhancedContext =
              currentInput.metadata?['enhancedContext'] as String? ?? '';

          if (previousHistory.isNotEmpty || enhancedContext.isNotEmpty) {
            return [
              if (previousHistory.isNotEmpty) previousHistory,
              if (enhancedContext.isNotEmpty) enhancedContext,
              basePrompt,
            ].where((s) => s.isNotEmpty).join('\n\n');
          }
          return basePrompt;
        },
      );

      final thinkingResult = await _thinkingStep.execute(thinkingInput);
      stepResults.add(thinkingResult);
      completedSteps.add('thinking');
      totalStepsExecuted++;

      // Update metadata with step count
      currentInput = currentInput.copyWith(
        metadata: {
          ...currentInput.metadata!,
          'totalStepsExecuted': totalStepsExecuted,
          'attemptCount': _historyTracker.getThinkingStepAttemptCount() + 1,
        },
      );

      if (!thinkingResult.success) {
        return _handleStepFailure(
          'thinking',
          thinkingResult,
          stepResults,
          thinkingSteps,
        );
      }

      // Extract thinking result
      final thinkingStepResponse = ThinkingStepResponse.safeFromDynamic(
        thinkingResult.data?['thinkingResult'],
      );
      currentInput = currentInput.copyWith(
        thinkingResult: () => thinkingStepResponse,
        metadata: {...currentInput.metadata!, ...thinkingResult.data ?? {}},
      );

      // Step 2: RUN WHAT THINKING STEP TOLD US TO RUN
      debugPrint('📚 Step 2: Running planned context gathering steps...');
      thinkingSteps.add('📚 Gathering relevant context and user data...');
      _onThinkingStep?.call(
        '📚 Gathering relevant context and user data...',
        'Collecting your profile, preferences, and relevant meal history',
      );

      final contextResult = await _contextGatheringStep.execute(currentInput);
      stepResults.add(contextResult);
      completedSteps.add('context_gathering');
      totalStepsExecuted++;

      // Update metadata with step count
      currentInput = currentInput.copyWith(
        metadata: {
          ...currentInput.metadata!,
          'totalStepsExecuted': totalStepsExecuted,
          'attemptCount': _historyTracker.getAttemptCount(),
          'stepResults': stepResults.map((r) => r.toJson()).toList(),
          'hasResponse': false,
          'hasDishes': false,
        },
      );

      if (!contextResult.success) {
        return _handleStepFailure(
          'context_gathering',
          contextResult,
          stepResults,
          thinkingSteps,
        );
      }

      // Update current input with context results
      currentInput = currentInput.copyWith(
        metadata: {...currentInput.metadata!, ...contextResult.data ?? {}},
      );

      // Step 3: DEEP VALIDATION (if active) - Run autonomous verification
      if (_deepSearchEnabled && totalStepsExecuted < 20) {
        debugPrint(
          '🔍 Step 3: Running autonomous verification (post-execution)...',
        );
        thinkingSteps.add(
          '🔍 Validating context sufficiency for optimal response...',
        );
        _onThinkingStep?.call(
          '🔍 Validating context sufficiency for optimal response...',
          'Analyzing gathered context to ensure we can provide the best possible answer',
        );

        final verificationResult = await _autonomousVerificationStep.execute(
          currentInput,
        );
        stepResults.add(verificationResult);
        completedSteps.add('deep_search_verification');
        totalStepsExecuted++;

        if (verificationResult.success) {
          final decision = verificationResult.data?['decision'] as String?;
          final reasoning = verificationResult.data?['reasoning'] as String?;
          final contextGaps = verificationResult.data?['contextGaps'] as List?;
          final additionalContext =
              verificationResult.data?['additionalContext'] as List?;

          debugPrint('🔍 Verification decision: $decision');
          debugPrint('🔍 Verification reasoning: $reasoning');

          // LOOP PROTECTION: Track restart attempts to prevent infinite loops
          final restartCount =
              currentInput.metadata?['restartCount'] as int? ?? 0;
          final maxRestarts = 2; // Maximum 2 restarts allowed

          // Handle verification decisions with strict loop protection
          if (decision == 'restartFresh' || decision == 'restartThinking') {
            if (restartCount >= maxRestarts) {
              debugPrint(
                '🚨 LOOP PROTECTION: Max restarts ($maxRestarts) reached, forcing continuation...',
              );
              // Force continuation with current context to break the loop
            } else if (totalStepsExecuted < 18) {
              // Leave room for final steps
              debugPrint(
                '🔄 Verification requested restart ($restartCount/$maxRestarts) - restarting thinking with enhanced context...',
              );

              // Record this restart for loop tracking
              _historyTracker.recordStepExecution(
                'thinking_restart',
                verificationResult,
              );

              // Build enhanced context for the new thinking step based on what was missing
              final enhancedContext = _buildEnhancedContextFromGaps(
                reasoning ?? '',
                contextGaps,
                additionalContext,
                currentInput,
              );

              return _processWithAutonomousVerification(
                userMessage: userMessage,
                conversationHistory: conversationHistory,
                botConfig: botConfig,
                imageUri: imageUri,
                userIngredients: userIngredients,
                startTime: startTime,
                enhancedContext: enhancedContext,
                restartCount: restartCount + 1,
                previousStepResults: stepResults,
                previousThinkingSteps: thinkingSteps,
                previousCompletedSteps: completedSteps,
                previousTotalStepsExecuted: totalStepsExecuted,
              );
            } else {
              debugPrint(
                '🔄 Near step limit (18/20), continuing despite verification recommendation...',
              );
            }
          } else if (decision == 'retryWithAdditions') {
            if (totalStepsExecuted < 19) {
              // Leave room for final step
              debugPrint(
                '🔄 Verification requested retry with additions - gathering more context...',
              );
              // Run context gathering again with additional requirements
              final retryContextResult = await _contextGatheringStep.execute(
                currentInput,
              );
              stepResults.add(retryContextResult);
              totalStepsExecuted++;
              if (retryContextResult.success) {
                currentInput = currentInput.copyWith(
                  metadata: {
                    ...currentInput.metadata!,
                    ...retryContextResult.data ?? {},
                  },
                );
              }
            } else {
              debugPrint(
                '🔄 Near step limit (19/20), continuing despite verification recommendation...',
              );
            }
          }
          // For 'continueNormally' or other decisions, proceed to response generation
        }
      }

      // Step 4: RESPONSE GENERATION
      debugPrint('✍️ Step 4: Generating response...');
      thinkingSteps.add('✍️ Crafting your personalized response...');
      _onThinkingStep?.call(
        '✍️ Crafting your personalized response...',
        'Combining all information to create a helpful and personalized answer',
      );

      final responseResult = await _responseGenerationStep.execute(
        currentInput,
      );
      stepResults.add(responseResult);
      completedSteps.add('response_generation');
      totalStepsExecuted++;

      if (!responseResult.success) {
        return _handleStepFailure(
          'response_generation',
          responseResult,
          stepResults,
          thinkingSteps,
        );
      }

      // Update metadata for dish processing
      currentInput = currentInput.copyWith(
        metadata: {
          ...currentInput.metadata!,
          'totalStepsExecuted': totalStepsExecuted,
          'hasResponse': true,
          'hasDishes': _responseHasDishes(
            responseResult.data?['chatResponse'] as Map<String, dynamic>? ?? {},
          ),
          'stepResults': stepResults.map((r) => r.toJson()).toList(),
        },
      );

      // Dish processing if needed
      if (_responseHasDishes(
        responseResult.data?['chatResponse'] as Map<String, dynamic>? ?? {},
      )) {
        debugPrint('🍽️ Running dish processing...');
        thinkingSteps.add('🍽️ Processing and analyzing dishes...');
        _onThinkingStep?.call(
          '🍽️ Processing and analyzing dishes...',
          'Calculating nutrition values, ingredients, and meal details',
        );

        // Extract dishes from the response for processing
        final chatResponse =
            responseResult.data?['chatResponse'] as Map<String, dynamic>? ?? {};
        final dishInput = currentInput.copyWith(
          metadata: {
            ...currentInput.metadata!,
            'dishes': chatResponse['dishes'],
          },
        );

        final dishResult = await _dishProcessingStep.execute(dishInput);
        stepResults.add(dishResult);
        completedSteps.add('dish_processing');
        totalStepsExecuted++;

        // Update metadata for dish validation
        currentInput = currentInput.copyWith(
          metadata: {
            ...currentInput.metadata!,
            'validatedDishes': dishResult.data?['validatedDishes'] ?? [],
          },
        );

        // Step 5: DISH VALIDATION (if dishes were processed)
        if (dishResult.success &&
            _deepSearchEnabled &&
            totalStepsExecuted < 20) {
          debugPrint('🔍 Step 5: Running dish validation...');
          thinkingSteps.add('🔍 Validating and refining dishes...');
          _onThinkingStep?.call(
            '🔍 Validating and refining dishes...',
            'Ensuring dishes have accurate nutrition and ingredient data',
          );

          final dishValidationResult = await _dishValidationStep.execute(
            currentInput,
          );
          stepResults.add(dishValidationResult);
          completedSteps.add('dish_validation');
          totalStepsExecuted++;

          // Update final dishes if validation succeeded
          if (dishValidationResult.success) {
            currentInput = currentInput.copyWith(
              metadata: {
                ...currentInput.metadata!,
                'finalDishes': dishValidationResult.data?['finalDishes'] ?? [],
              },
            );
          }
        }
      }

      // Step 6: Return final response
      return _buildFinalResponse(
        stepResults,
        thinkingSteps,
        startTime,
        botConfig,
      );
    } catch (e) {
      debugPrint('❌ Autonomous verification pipeline failed: $e');
      return _buildErrorResponse(
        Exception(e.toString()),
        thinkingSteps,
        startTime,
        botConfig,
      );
    }
  }

  /// Process message with original pipeline (when deep search is disabled)
  Future<ChatResponse> _processWithOriginalPipeline({
    required String userMessage,
    required List<ChatMessage> conversationHistory,
    required BotConfiguration botConfig,
    String? imageUri,
    List<UserIngredient>? userIngredients,
    required DateTime startTime,
    required AgentPipelineConfig pipelineConfig,
  }) async {
    final List<ChatStepResult> stepResults = [];
    final List<String> thinkingSteps = [];
    final List<String> completedSteps = [];

    // Prepare initial input for agent pipeline
    var currentInput = ChatStepInput(
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

    // Execute all steps in the pipeline based on the configuration
    for (int i = 0; i < pipelineConfig.allSteps.length; i++) {
      final stepName = pipelineConfig.allSteps[i];
      debugPrint('🔄 Executing step $i: $stepName');

      // EMERGENCY LOOP BREAKER - Force stop after too many steps
      if (stepResults.length > 15) {
        debugPrint(
          '🚨 EMERGENCY STOP: Too many steps executed (${stepResults.length}), breaking pipeline to prevent infinite loop!',
        );
        break;
      }

      // Skip verification step if deep search is not enabled
      if (stepName == 'deep_search_verification' && !_deepSearchEnabled) {
        debugPrint('⏭️ Skipping verification step (deep search disabled)');
        continue;
      }

      // Show appropriate thinking step message for UI
      final stepEmoji = _getStepEmoji(stepName);
      final stepDescription = _getStepDescription(stepName);
      final thinkingStepText = '$stepEmoji $stepDescription';

      thinkingSteps.add(thinkingStepText);
      _onThinkingStep?.call(thinkingStepText, _getStepDetail(stepName));

      // Special handling for verification steps
      if (stepName == 'deep_search_verification') {
        // Get the previous step that we're verifying
        final previousStep =
            completedSteps.isNotEmpty ? completedSteps.last : 'unknown';

        // Only run verification if we should
        final thinkingResultObj = ThinkingStepResponse.safeFromDynamic(
          currentInput.thinkingResult ??
              currentInput.metadata?['thinkingResult'] ??
              _findStepResult(stepResults, 'thinking')?.data?['thinkingResult'],
        );

        if (!_shouldRunDeepSearchVerification(thinkingResultObj)) {
          debugPrint(
            '⏭️ Deep search verification skipped (no contextual features required)',
          );

          // Add a skipped step result for tracking
          final skippedStepResult = ChatStepResult.success(
            stepName: 'deep_search_verification',
            data: {
              'skipped': true,
              'reason':
                  'No contextual features beyond conversation history needed',
              'contextRequirements':
                  thinkingResultObj?.contextRequirements.toJson(),
              'previousStep': previousStep,
            },
          );
          stepResults.add(skippedStepResult);
          completedSteps.add(stepName);
          continue;
        }

        // Prepare verification input with metadata about which step we're verifying
        final verificationInput = currentInput.copyWith(
          metadata: {
            ...currentInput.metadata!,
            'previousStep': previousStep,
            // Include previous step's results if available
            '${previousStep}Result':
                _findStepResult(stepResults, previousStep)?.data,
          },
        );

        // Execute verification
        debugPrint(
          '🔍 Running deep search verification after step: $previousStep',
        );
        final verificationResult = await _autonomousVerificationStep.execute(
          verificationInput,
        );
        stepResults.add(verificationResult);
        completedSteps.add(stepName);

        // Handle pipeline control decisions from verification
        if (verificationResult.success) {
          final controlResult = await _handlePipelineControl(
            verificationResult,
            currentInput,
            stepResults,
            thinkingSteps,
          );

          if (controlResult != null) {
            currentInput = controlResult;

            // Always retry thinking/context_gathering if stepsToRetry includes them and hasEnoughContext is false
            final pipelineControlData =
                verificationResult.data?['pipelineControl']
                    as Map<String, dynamic>?;
            if (pipelineControlData != null &&
                pipelineControlData['hasEnoughContext'] == false) {
              final stepsToRetry =
                  pipelineControlData['stepsToRetry'] as List<dynamic>?;
              if (stepsToRetry != null && stepsToRetry.isNotEmpty) {
                // Find the first step to retry (prefer thinking)
                String? retryStep;
                if (stepsToRetry.contains('thinking')) {
                  retryStep = 'thinking';
                } else if (stepsToRetry.contains('context_gathering')) {
                  retryStep = 'context_gathering';
                }
                if (retryStep != null) {
                  debugPrint(
                    '🔄 Forced retry: $retryStep due to failed verification',
                  );
                  // Pass reasoning/contextModifications to the thinking step
                  // Build a summary of previous steps and context changes
                  final summary = _buildStepSummary(
                    stepResults,
                    completedSteps,
                    pipelineControlData['reasoning'],
                    pipelineControlData['contextModifications'],
                  );
                  currentInput = currentInput.copyWith(
                    metadata: {
                      ...currentInput.metadata!,
                      'verificationReasoning': pipelineControlData['reasoning'],
                      'verificationContextModifications':
                          pipelineControlData['contextModifications'],
                      'stepsToRetry': stepsToRetry,
                      'stepSummaryForThinking': summary,
                    },
                  );
                  final retryIndex = pipelineConfig.allSteps.indexOf(retryStep);
                  if (retryIndex >= 0 && retryIndex < i) {
                    i = retryIndex - 1;
                    continue;
                  }
                }
              }
            }
            // Handle specific dish creation retry logic
            if (controlResult.metadata?['retryWithDishCreation'] == true ||
                controlResult.metadata?['createDishesFromScratch'] == true) {
              debugPrint(
                '🔄 Re-running context gathering with dish creation settings',
              );

              // Find context gathering in the pipeline
              final contextGatheringIndex = pipelineConfig.allSteps.indexOf(
                'context_gathering',
              );
              if (contextGatheringIndex >= 0) {
                // Execute context gathering with updated settings
                final updatedContextResult = await _contextGatheringStep
                    .execute(currentInput);

                // Update step results
                final existingIndex = stepResults.indexWhere(
                  (step) => step.stepName == 'context_gathering',
                );

                if (existingIndex >= 0) {
                  stepResults[existingIndex] = updatedContextResult;
                } else {
                  stepResults.add(updatedContextResult);
                }

                debugPrint(
                  '📚 Context gathering re-run completed with success: ${updatedContextResult.success}',
                );

                if (!updatedContextResult.success) {
                  return _handleStepFailure(
                    'context_gathering_retry',
                    updatedContextResult,
                    stepResults,
                    thinkingSteps,
                  );
                }

                // Update current input with updated context results
                currentInput = currentInput.copyWith(
                  metadata: {
                    ...currentInput.metadata!,
                    'contextGatheringResult': updatedContextResult.data,
                  },
                );
              }
            }
          }
        }
        // Defensive: If we exceed 20 steps, just return the last generated response
        if (stepResults.length > 20) {
          debugPrint(
            '⚠️ Exceeded 20 pipeline steps, returning last generated response',
          );
          final lastResponseStep = stepResults.lastWhere(
            (r) => r.stepName == 'response_generation',
            orElse: () => stepResults.last,
          );
          final chatResponseData =
              lastResponseStep.data?['chatResponse'] as Map<String, dynamic>?;
          final finalResponse =
              chatResponseData?['replyText'] as String? ??
              'I apologize, but I encountered an issue generating a response. Please try again.';
          final recommendation = chatResponseData?['recommendation'] as String?;
          final extractedDishes =
              lastResponseStep.data?['validatedDishes'] as List? ?? [];
          final duration = DateTime.now().difference(startTime);
          return ChatResponse(
            replyText: finalResponse,
            recommendation: recommendation,
            dishes: extractedDishes.cast(),
            metadata: {
              'processingTime': duration.inMilliseconds,
              'mode': 'full_agent_pipeline',
              'botType': botConfig.type,
              'deepSearchEnabled': _deepSearchEnabled,
              'stepResults': stepResults.map((r) => r.toJson()).toList(),
              'thinkingSteps': thinkingSteps,
              'stepsCompleted': _historyTracker.getTotalStepsExecuted(),
              'hasImage': imageUri != null,
              'dishesProcessed': {
                'validatedDishes': extractedDishes,
                'count': extractedDishes.length,
              },
            },
          );
        }

        // Continue to next step
        continue;
      }

      // Execute the regular step
      ChatStepResult? stepResult;
      switch (stepName) {
        case 'thinking':
          // If a step summary exists, inject it into the system prompt for the thinking step
          String? stepSummary =
              currentInput.metadata?['stepSummaryForThinking'] as String?;
          ChatStepInput inputForThinking;
          if (stepSummary != null && stepSummary.isNotEmpty) {
            // Prepend the summary to the enhancedSystemPrompt
            final basePrompt =
                currentInput.enhancedSystemPrompt ??
                currentInput.initialSystemPrompt ??
                '';
            inputForThinking = currentInput.copyWith(
              enhancedSystemPrompt: () => stepSummary + '\n' + basePrompt,
            );
          } else {
            inputForThinking = currentInput;
          }
          stepResult = await _thinkingStep.execute(inputForThinking);
          if (stepResult.success) {
            // Check for identical thinking step patterns and apply aggressive strategy switching
            if (_historyTracker.isThinkingStepRepeating()) {
              debugPrint(
                '🔄 IDENTICAL THINKING DETECTED - BREAKING LOOP AGGRESSIVELY!',
              );

              // Get strategy switch recommendation
              final strategySwitchData = _historyTracker
                  .generateStrategySwitchRecommendation(userMessage);
              final strategySwitch =
                  strategySwitchData['recommendation'] as String? ?? '';

              debugPrint('💡 Emergency strategy switch: $strategySwitch');

              if (strategySwitch.isNotEmpty) {
                // COMPLETELY OVERRIDE the thinking result instead of just modifying it
                final emergencyThinkingResult = _createEmergencyThinkingResult(
                  userMessage,
                  strategySwitch,
                );

                // Replace the step result entirely with emergency strategy
                stepResult = ChatStepResult.success(
                  stepName: 'thinking',
                  data: {
                    'thinkingResult': emergencyThinkingResult.toJson(),
                    'strategySwitch': strategySwitch,
                    'emergencyOverride': true,
                    'loopBreakerApplied': true,
                  },
                );

                debugPrint(
                  '🚨 EMERGENCY OVERRIDE APPLIED - FORCING NEW STRATEGY',
                );
              }
            }

            // Extract thinking result for future steps
            final thinkingResultObj = ThinkingStepResponse.safeFromDynamic(
              stepResult.data?['thinkingResult'],
            );
            currentInput = currentInput.copyWith(
              thinkingResult: () => thinkingResultObj,
              metadata: {...currentInput.metadata!, ...stepResult.data ?? {}},
            );
          }
          break;
        case 'context_gathering':
          stepResult = await _contextGatheringStep.execute(currentInput);
          // Keep the context gathering results for next steps
          if (stepResult.success) {
            currentInput = currentInput.copyWith(
              metadata: {
                ...currentInput.metadata!,
                'contextGatheringResult': stepResult.data,
              },
            );
          }
          break;
        case 'dish_processing':
          stepResult = await _dishProcessingStep.execute(currentInput);
          if (stepResult.success) {
            currentInput = currentInput.copyWith(
              metadata: {
                ...currentInput.metadata!,
                'dishProcessingResult': stepResult.data,
              },
            );
          }
          break;
        case 'response_generation':
          stepResult = await _responseGenerationStep.execute(currentInput);
          break;
        case 'error_handling':
          stepResult = await _errorHandlingStep.execute(currentInput);
          break;
        default:
          debugPrint('⚠️ Unknown step name: $stepName');
          continue;
      }

      // Store result and check for failure
      stepResults.add(stepResult);
      completedSteps.add(stepName);

      if (!stepResult.success) {
        return _handleStepFailure(
          stepName,
          stepResult,
          stepResults,
          thinkingSteps,
        );
      }
    }

    // Always finish with a final response generation step, regardless of pipeline retries or deep search verification
    debugPrint('✍️ Ensuring final response generation step is executed...');
    final responseStepText = '✍️ Crafting your personalized response...';
    thinkingSteps.add(responseStepText);
    _onThinkingStep?.call(
      responseStepText,
      'Combining all information to create a helpful and personalized answer',
    );

    // Extract enhanced system prompt from last context gathering result
    final lastContextResult = _findStepResult(stepResults, 'context_gathering');
    String? enhancedSystemPrompt;
    if (lastContextResult != null && lastContextResult.data != null) {
      try {
        final contextGatheringResultJson =
            lastContextResult.data?['contextGatheringResult']
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
    }
    final responseInput = currentInput.copyWith(
      enhancedSystemPrompt: () => enhancedSystemPrompt,
      metadata: <String, dynamic>{
        ...currentInput.metadata ?? {},
        ...?lastContextResult?.data,
      },
    );
    final responseResult = await _responseGenerationStep.execute(responseInput);
    stepResults.add(responseResult);

    // Always extract all relevant metadata and return a comprehensive ChatResponse
    ChatStepResult? dishResult;
    List extractedDishes = [];
    if (responseResult.success) {
      try {
        // Get the raw AI response that might contain dishes array in JSON format
        final parsedResponse =
            responseResult.data?['parsedResponse'] as String?;
        Map<String, dynamic>? aiResponse;

        // Try to parse the response as JSON to look for dishes
        if (parsedResponse != null && parsedResponse.trim().isNotEmpty) {
          try {
            // Check if response looks like JSON (starts with { and ends with })
            final trimmed = parsedResponse.trim();
            if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
              aiResponse = jsonDecode(parsedResponse) as Map<String, dynamic>?;
            }
          } catch (e) {
            debugPrint(
              '🔍 AI response is not JSON format, skipping dish processing: $e',
            );
            // Response is plain text, no dishes to process
          }
        }

        if (aiResponse != null && _responseHasDishes(aiResponse)) {
          debugPrint('🍽️ Step 5: Processing dishes from AI response...');
          final dishStepText = '🍽️ Processing and analyzing dishes...';
          thinkingSteps.add(dishStepText);
          _onThinkingStep?.call(
            dishStepText,
            'Calculating nutrition values, ingredients, and meal details',
          );

          final dishInput = currentInput.copyWith(
            metadata: <String, dynamic>{
              'dishes': aiResponse['dishes'],
              'uploadedImageUri': imageUri,
            },
          );
          dishResult = await _dishProcessingStep.execute(dishInput);
          stepResults.add(dishResult);

          if (dishResult.success) {
            extractedDishes =
                dishResult.data?['validatedDishes'] as List? ?? [];

            // Run dish validation if deep search is enabled
            if (_deepSearchEnabled) {
              debugPrint('🔍 Step 6: Running dish validation...');
              final dishValidationStepText =
                  '🔍 Validating and refining dishes...';
              thinkingSteps.add(dishValidationStepText);
              _onThinkingStep?.call(
                dishValidationStepText,
                'Ensuring dishes have accurate nutrition and ingredient data',
              );

              final dishValidationInput = currentInput.copyWith(
                metadata: {
                  ...currentInput.metadata!,
                  'validatedDishes': extractedDishes,
                },
              );

              final dishValidationResult = await _dishValidationStep.execute(
                dishValidationInput,
              );
              stepResults.add(dishValidationResult);

              // Use validated dishes if validation succeeded
              if (dishValidationResult.success) {
                final finalDishes =
                    dishValidationResult.data?['finalDishes'] as List? ?? [];
                if (finalDishes.isNotEmpty) {
                  extractedDishes = finalDishes;
                  debugPrint('✅ Using ${finalDishes.length} validated dishes');
                }
              }
            }
          } else {
            extractedDishes = [];
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error checking for dishes in response: $e');
      }
    }

    final chatResponseData =
        responseResult.data?['chatResponse'] as Map<String, dynamic>?;
    final finalResponse =
        chatResponseData?['replyText'] as String? ??
        'I apologize, but I encountered an issue generating a response. Please try again.';
    final recommendation = chatResponseData?['recommendation'] as String?;

    final duration = DateTime.now().difference(startTime);
    debugPrint(
      '🤖 ChatAgentService: Completed full pipeline in ${duration.inMilliseconds}ms',
    );
    return ChatResponse(
      replyText: finalResponse,
      recommendation: recommendation,
      dishes: extractedDishes.cast(),
      metadata: {
        'processingTime': duration.inMilliseconds,
        'mode': 'full_agent_pipeline',
        'botType': botConfig.type,
        'deepSearchEnabled': _deepSearchEnabled,
        'stepResults': stepResults.map((r) => r.toJson()).toList(),
        'thinkingSteps': thinkingSteps,
        'stepsCompleted': _historyTracker.getTotalStepsExecuted(),
        'hasImage': imageUri != null,
        'dishesProcessed': {
          'validatedDishes':
              extractedDishes.map((dish) => dish.toJson()).toList(),
          'count': extractedDishes.length,
        },
      },
    );
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
    // If deep search is disabled, don't run verification
    if (!_deepSearchEnabled) {
      return false;
    }

    if (thinkingResult == null) return false;

    final requirements = thinkingResult.contextRequirements;

    // Check for dish-related queries in the user intent to prioritize deep search
    final userIntent = thinkingResult.userIntent.toLowerCase();
    final isDishRelatedIntent =
        userIntent.contains('dish') ||
        userIntent.contains('recipe') ||
        userIntent.contains('food') ||
        userIntent.contains('meal') ||
        userIntent.contains('cook');

    // Always run deep search for dish-related queries
    if (isDishRelatedIntent) {
      debugPrint(
        '🍽️ Enabling deep search verification for dish-related query: $userIntent',
      );
      return true;
    }

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
  void setMaxRetries(int maxRetries) {
    _maxRetries = maxRetries;
    debugPrint('🤖 Max retries set to: $maxRetries');
  }

  void setMaxContextLength(int maxLength) {
    _maxContextLength = maxLength;
    debugPrint('🤖 Max context length set to: $maxLength');
  }

  int get maxRetries {
    return _maxRetries;
  }

  int get maxContextLength {
    return _maxContextLength;
  }

  /// Helper method to find a step result by name
  ChatStepResult? _findStepResult(
    List<ChatStepResult> results,
    String stepName,
  ) {
    for (final result in results) {
      if (result.stepName == stepName) {
        return result;
      }
    }
    return null;
  }

  /// Builds a summary of previous steps and context changes for the next thinking step
  String _buildStepSummary(
    List<ChatStepResult> stepResults,
    List<String> completedSteps,
    dynamic reasoning,
    dynamic contextModifications,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('--- Agent Pipeline Step Summary ---');
    buffer.writeln('Completed steps: ${completedSteps.join(", ")}');
    buffer.writeln('Key context changes:');
    if (contextModifications != null &&
        contextModifications is Map<String, dynamic>) {
      contextModifications.forEach((key, value) {
        buffer.writeln('  - $key: $value');
      });
    }
    buffer.writeln('Reasoning for retry:');
    if (reasoning != null) {
      buffer.writeln('  $reasoning');
    }
    // If dish creation is now enabled, clarify that in the summary
    if (contextModifications != null &&
        ((contextModifications['isDishCreationRequest'] == true) ||
            (contextModifications['createDishesFromScratch'] == true))) {
      buffer.writeln(
        'Action: Switching to dish creation mode (creating new dish from scratch, not searching local dishes).',
      );
    }
    buffer.writeln('-----------------------------------');
    return buffer.toString();
  }

  /// Gets appropriate emoji for each step type
  String _getStepEmoji(String stepName) {
    switch (stepName) {
      case 'thinking':
        return '🧠';
      case 'context_gathering':
        return '📚';
      case 'response_generation':
        return '✍️';
      case 'dish_processing':
        return '🍽️';
      case 'error_handling':
        return '⚠️';
      case 'deep_search_verification':
        return '🔍';
      case 'image_processing':
        return '🖼️';
      default:
        return '🔄';
    }
  }

  /// Gets user-friendly description for each step
  String _getStepDescription(String stepName) {
    switch (stepName) {
      case 'thinking':
        return 'Analyzing your request and planning approach...';
      case 'context_gathering':
        return 'Gathering relevant context and user data...';
      case 'response_generation':
        return 'Crafting your personalized response...';
      case 'dish_processing':
        return 'Processing and analyzing dishes...';
      case 'error_handling':
        return 'Handling unexpected error...';
      case 'deep_search_verification':
        return 'Validating context sufficiency for optimal response...';
      case 'image_processing':
        return 'Analyzing your uploaded image...';
      default:
        return 'Processing step: $stepName...';
    }
  }

  /// Gets detailed explanation for each step
  String _getStepDetail(String stepName) {
    switch (stepName) {
      case 'thinking':
        return 'Breaking down your request and determining the best approach';
      case 'context_gathering':
        return 'Collecting your profile, preferences, and relevant meal history';
      case 'response_generation':
        return 'Combining all information to create a helpful and personalized answer';
      case 'dish_processing':
        return 'Calculating nutrition values, ingredients, and meal details';
      case 'error_handling':
        return 'Attempting to recover from error and provide a helpful response';
      case 'deep_search_verification':
        return 'Analyzing gathered context to ensure we can provide the best possible answer';
      case 'image_processing':
        return 'Extracting food items, ingredients, and portion sizes from your image';
      default:
        return 'Processing information for step: $stepName';
    }
  }

  /// Get the appropriate pipeline configuration based on current settings
  AgentPipelineConfig getPipelineConfig() {
    if (!_deepSearchEnabled) {
      return AgentPipelineConfig.defaultConfig();
    }

    // When deep search is enabled, use the autonomous verification pipeline
    // which runs verification at strategic checkpoints
    return AgentPipelineConfig.withAutonomousVerification();
  }

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

      // Patch missing keys and normalize broken OpenAI output
      List<dynamic> rawActions =
          pipelineControlData['recommendedActions'] ?? [];
      // Map string actions to enum values, ignore unknowns
      List<PipelineControlAction> mappedActions =
          rawActions
              .map((action) {
                if (action is PipelineControlAction) return action;
                if (action is String) {
                  switch (action.trim().toLowerCase()) {
                    case 'retrywithmodifications':
                    case 'pipelinecontrolaction.retrywithmodifications':
                    case 'retry_with_modifications':
                    case 'retry':
                      return PipelineControlAction.retryWithModifications;
                    case 'continue':
                    case 'continue_normally':
                    case 'pipelinecontrolaction.continuenormally':
                      return PipelineControlAction.continueNormally;
                    case 'skipoptionalsteps':
                    case 'skip_optional_steps':
                    case 'pipelinecontrolaction.skipoptionalsteps':
                      return PipelineControlAction.skipOptionalSteps;
                    case 'gatheradditionalcontext':
                    case 'gather_additional_context':
                    case 'pipelinecontrolaction.gatheradditionalcontext':
                      return PipelineControlAction.gatherAdditionalContext;
                    case 'modifysearchparameters':
                    case 'modify_search_parameters':
                    case 'pipelinecontrolaction.modifysearchparameters':
                      return PipelineControlAction.modifySearchParameters;
                    case 'discardandretry':
                    case 'discard_and_retry':
                    case 'pipelinecontrolaction.discardandretry':
                      return PipelineControlAction.discardAndRetry;
                    default:
                      return null;
                  }
                }
                return null;
              })
              .whereType<PipelineControlAction>()
              .toList();

      // Ensure contextModifications is a Map<String, dynamic>
      dynamic rawContextMods =
          pipelineControlData['contextModifications'] ?? {};
      Map<String, dynamic> contextMods;
      if (rawContextMods is Map<String, dynamic>) {
        contextMods = rawContextMods;
      } else if (rawContextMods is Map) {
        contextMods = Map<String, dynamic>.from(rawContextMods);
      } else {
        contextMods = {};
      }

      final normalized = <String, dynamic>{
        'hasEnoughContext': pipelineControlData['hasEnoughContext'] ?? false,
        'confidence': pipelineControlData['confidence'] ?? 0.0,
        'recommendedActions': mappedActions,
        'reasoning': pipelineControlData['reasoning'] ?? '',
        'stepsToRetry': pipelineControlData['stepsToRetry'] ?? [],
        'contextModifications': contextMods,
        'identifiedGaps': pipelineControlData['identifiedGaps'] ?? [],
        'suggestions': pipelineControlData['suggestions'] ?? [],
        'stepsToSkip': pipelineControlData['stepsToSkip'] ?? [],
        'searchParameters': pipelineControlData['searchParameters'],
      };

      PipelineControlResult pipelineControl;
      try {
        pipelineControl = PipelineControlResult.fromJson(normalized);
      } catch (e) {
        debugPrint('❌ Failed to parse PipelineControlResult: $e');
        pipelineControl = PipelineControlResult(
          hasEnoughContext: normalized['hasEnoughContext'] as bool,
          confidence: normalized['confidence'] as double,
          recommendedActions: List<PipelineControlAction>.from(
            normalized['recommendedActions'],
          ),
          reasoning: normalized['reasoning'] as String,
          stepsToRetry: List.from(normalized['stepsToRetry']),
          contextModifications: Map<String, dynamic>.from(
            normalized['contextModifications'],
          ),
          identifiedGaps: List.from(normalized['identifiedGaps']),
          suggestions: List.from(normalized['suggestions']),
          stepsToSkip: List.from(normalized['stepsToSkip']),
          searchParameters: normalized['searchParameters'],
        );
      }

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
              final modifications = pipelineControl.contextModifications!;
              final isDishCreationRequest =
                  (modifications.containsKey('isDishCreationRequest') &&
                      modifications['isDishCreationRequest'] == true) ||
                  (modifications.containsKey('createDishesFromScratch') &&
                      modifications['createDishesFromScratch'] == true);

              if (isDishCreationRequest) {
                debugPrint(
                  '🍳 Detected dish creation request in pipeline control',
                );
                debugPrint('   Context modifications: ${modifications}');
                debugPrint('   Reasoning: ${pipelineControl.reasoning}');

                final thinkingResultObj = ThinkingStepResponse.safeFromDynamic(
                  currentInput.thinkingResult ??
                      currentInput.metadata?['thinkingResult'] ??
                      stepResults
                          .firstWhere(
                            (r) => r.stepName == 'thinking',
                            orElse:
                                () => ChatStepResult(
                                  stepName: '',
                                  success: false,
                                  data: {},
                                ),
                          )
                          .data?['thinkingResult'],
                );

                final userIntent =
                    thinkingResultObj?.userIntent.toLowerCase() ?? '';
                final isSpecificallyAskingForExistingDishes =
                    userIntent.contains('existing dishes') ||
                    userIntent.contains('my dishes') ||
                    userIntent.contains('dishes i have') ||
                    userIntent.contains('saved dish');

                if (!isSpecificallyAskingForExistingDishes) {
                  debugPrint(
                    '🔄 No helpful dishes found, but user didn\'t ask for only existing dishes. Retrying with dish creation focus.',
                  );
                  final updatedContextRequirements = thinkingResultObj
                      ?.contextRequirements
                      .copyWith(
                        needsExistingDishes: false,
                        needsInfoOnDishCreation: true,
                      );
                  return currentInput.copyWith(
                    metadata: {
                      ...currentInput.metadata!,
                      ...modifications,
                      'retryWithDishCreation': true,
                      'retryAttempt':
                          (currentInput.metadata?['retryAttempt'] as int? ??
                              0) +
                          1,
                      'updatedContextRequirements':
                          updatedContextRequirements?.toJson(),
                    },
                  );
                }
              }
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

  /// Execute a phase with optional checkpoint verification [DEPRECATED - UNUSED]
  // Future<PhaseResult> _executePhaseWithCheckpoint({

  /// Build final response from step results
  ChatResponse _buildFinalResponse(
    List<ChatStepResult> stepResults,
    List<String> thinkingSteps,
    DateTime startTime,
    BotConfiguration botConfig,
  ) {
    // Find the response generation result
    final responseResult =
        stepResults
            .where((r) => r.stepName == 'response_generation')
            .lastOrNull;

    String finalResponse =
        'I apologize, but I encountered an issue generating a response. Please try again.';
    String? recommendation;

    if (responseResult?.success == true) {
      final chatResponseData =
          responseResult!.data?['chatResponse'] as Map<String, dynamic>?;
      finalResponse =
          chatResponseData?['replyText'] as String? ?? finalResponse;
      recommendation = chatResponseData?['recommendation'] as String?;
    }

    // Find dishes from dish validation result first, fallback to dish processing
    final dishValidationResult =
        stepResults.where((r) => r.stepName == 'dish_validation').lastOrNull;
    final dishProcessingResult =
        stepResults.where((r) => r.stepName == 'dish_processing').lastOrNull;

    List extractedDishes = [];

    // Prioritize validated dishes if available
    if (dishValidationResult?.success == true) {
      extractedDishes =
          dishValidationResult!.data?['finalDishes'] as List? ?? [];
      debugPrint(
        '📋 Using ${extractedDishes.length} dishes from validation step',
      );
    } else if (dishProcessingResult?.success == true) {
      extractedDishes =
          dishProcessingResult!.data?['validatedDishes'] as List? ?? [];
      debugPrint(
        '📋 Using ${extractedDishes.length} dishes from processing step (validation skipped)',
      );
    }

    final duration = DateTime.now().difference(startTime);

    // Collect emergency override information for transparency
    final emergencyOverrides = <String>[];
    final loopBreakers = <String>[];
    final restartInformation = <String>[];
    int emergencyStepLimit = 0;
    int totalRestarts = 0;

    for (final result in stepResults) {
      if (result.data?['emergencyOverride'] == true) {
        emergencyOverrides.add(
          '${result.stepName}: ${result.data?['reasoning'] ?? 'Emergency override applied'}',
        );
      }
      if (result.data?['loopBreakerApplied'] == true) {
        loopBreakers.add('${result.stepName}: Strategy switching applied');
      }
    }

    // Count restart markers in thinking steps for transparency
    for (final step in thinkingSteps) {
      if (step.contains('🔄 Restarting with enhanced strategy')) {
        totalRestarts++;
        restartInformation.add(step);
      }
    }

    // Check if emergency step limit was hit
    if (stepResults.length > 15) {
      emergencyStepLimit = stepResults.length;
    }

    return ChatResponse(
      replyText: finalResponse,
      recommendation: recommendation,
      dishes: extractedDishes.cast(),
      metadata: {
        'processingTime': duration.inMilliseconds,
        'mode': 'autonomous_verification_pipeline',
        'botType': botConfig.type,
        'deepSearchEnabled': _deepSearchEnabled,
        'stepResults': stepResults.map((r) => r.toJson()).toList(),
        'thinkingSteps': thinkingSteps,
        'stepsCompleted': _historyTracker.getTotalStepsExecuted(),
        'dishesProcessed': {
          'validatedDishes':
              extractedDishes.map((dish) => dish.toJson()).toList(),
          'count': extractedDishes.length,
        },
        // Emergency override tracking for transparency
        'emergencyOverridesApplied': emergencyOverrides,
        'loopBreakersApplied': loopBreakers,
        'restartInformation': restartInformation,
        'totalRestarts': totalRestarts,
        'emergencyStepLimitHit':
            emergencyStepLimit > 0 ? emergencyStepLimit : null,
        'pipelineModificationsApplied':
            emergencyOverrides.isNotEmpty ||
            loopBreakers.isNotEmpty ||
            restartInformation.isNotEmpty ||
            emergencyStepLimit > 0,
        // Pipeline modifications tracking
        'pipelineModifications': _modificationTracker.toJson(),
        'modificationSummary':
            _modificationTracker.generateUserFriendlySummary(),
      },
    );
  }

  /// Build error response
  ChatResponse _buildErrorResponse(
    Exception error,
    List<String> thinkingSteps,
    DateTime startTime,
    BotConfiguration botConfig,
  ) {
    debugPrint('❌ Building error response: $error');

    final duration = DateTime.now().difference(startTime);

    return ChatResponse(
      replyText:
          'I apologize, but I encountered an issue processing your request. Please try again.',
      dishes: [],
      metadata: {
        'processingTime': duration.inMilliseconds,
        'mode': 'error_response',
        'botType': botConfig.type,
        'error': error.toString(),
        'thinkingSteps': thinkingSteps,
        'stepResults': [],
      },
    );
  }

  /// Create an emergency thinking result to break infinite loops
  ThinkingStepResponse _createEmergencyThinkingResult(
    String userMessage,
    String strategySwitch,
  ) {
    debugPrint(
      '🚨 Creating emergency thinking result with strategy: $strategySwitch',
    );

    // Analyze the strategy switch to determine the appropriate emergency approach
    if (strategySwitch.contains('create new dish') ||
        strategySwitch.contains('dish creation')) {
      return ThinkingStepResponse(
        userIntent: 'User needs a new dish created based on their request',
        contextRequirements: ContextRequirements(
          needsUserProfile: false,
          needsTodaysNutrition: false,
          needsWeeklyNutritionSummary: false,
          needsListOfCreatedDishes: false,
          needsExistingDishes:
              false, // Force skip existing dishes to break loop
          needsInfoOnDishCreation: true,
          needsNutritionAdvice: false,
          needsHistoricalMealLookup: false,
          needsConversationHistory: false,
        ),
        responseRequirements: [
          'dish_creation',
          'recipe_details',
          'nutrition_information',
        ],
        metadata: {
          'emergencyOverride': true,
          'originalStrategy': strategySwitch,
          'loopBreaker': 'force_dish_creation',
        },
      );
    } else if (strategySwitch.contains('nutrition advice') ||
        strategySwitch.contains('nutritional')) {
      return ThinkingStepResponse(
        userIntent: 'User needs general nutrition advice and guidance',
        contextRequirements: ContextRequirements(
          needsUserProfile: false,
          needsTodaysNutrition: false,
          needsWeeklyNutritionSummary: false,
          needsListOfCreatedDishes: false,
          needsExistingDishes:
              false, // Force skip existing dishes to break loop
          needsInfoOnDishCreation: false,
          needsNutritionAdvice: true,
          needsHistoricalMealLookup: false,
          needsConversationHistory: false,
        ),
        responseRequirements: [
          'nutrition_advice',
          'general_guidance',
          'healthy_recommendations',
        ],
        metadata: {
          'emergencyOverride': true,
          'originalStrategy': strategySwitch,
          'loopBreaker': 'force_nutrition_advice',
        },
      );
    } else if (strategySwitch.contains('comprehensive') ||
        strategySwitch.contains('detailed')) {
      return ThinkingStepResponse(
        userIntent: 'User needs comprehensive information and multiple options',
        contextRequirements: ContextRequirements(
          needsUserProfile: true,
          needsTodaysNutrition: true,
          needsWeeklyNutritionSummary: false,
          needsListOfCreatedDishes: false,
          needsExistingDishes:
              false, // Force skip existing dishes to break loop
          needsInfoOnDishCreation: true,
          needsNutritionAdvice: true,
          needsHistoricalMealLookup: false,
          needsConversationHistory: true,
        ),
        responseRequirements: [
          'comprehensive_analysis',
          'multiple_options',
          'personalized_recommendations',
          'dish_creation',
        ],
        metadata: {
          'emergencyOverride': true,
          'originalStrategy': strategySwitch,
          'loopBreaker': 'force_comprehensive_approach',
        },
      );
    } else {
      // Default emergency fallback - minimal requirements
      return ThinkingStepResponse(
        userIntent: 'User needs a simple, direct response',
        contextRequirements: ContextRequirements(
          needsUserProfile: false,
          needsTodaysNutrition: false,
          needsWeeklyNutritionSummary: false,
          needsListOfCreatedDishes: false,
          needsExistingDishes:
              false, // Force skip existing dishes to break loop
          needsInfoOnDishCreation: true,
          needsNutritionAdvice: false,
          needsHistoricalMealLookup: false,
          needsConversationHistory: false,
        ),
        responseRequirements: [
          'simple_response',
          'direct_answer',
          'basic_information',
        ],
        metadata: {
          'emergencyOverride': true,
          'originalStrategy': strategySwitch,
          'loopBreaker': 'force_simple_response',
        },
      );
    }
  }

  /// Build enhanced context from verification gaps to guide thinking restart
  String _buildEnhancedContextFromGaps(
    String reasoning,
    List<dynamic>? contextGaps,
    List<dynamic>? additionalContext,
    ChatStepInput currentInput,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('=== VERIFICATION FEEDBACK FOR NEW THINKING APPROACH ===');
    buffer.writeln('Previous attempt failed because: $reasoning');

    if (contextGaps != null && contextGaps.isNotEmpty) {
      buffer.writeln('Missing context identified: ${contextGaps.join(", ")}');
    }

    if (additionalContext != null && additionalContext.isNotEmpty) {
      buffer.writeln(
        'Additional context needed: ${additionalContext.join(", ")}',
      );
    }

    buffer.writeln(
      'IMPORTANT: Use a DIFFERENT approach than previous attempts.',
    );
    buffer.writeln(
      'Focus on: dish creation capabilities, recipe suggestions, ingredient analysis.',
    );
    buffer.writeln('========================================================');

    return buffer.toString();
  }

  /// Build history of previous attempts for learning and user transparency
  String _buildPreviousAttemptsHistory(
    List<ChatStepResult>? previousStepResults,
    List<String>? previousThinkingSteps,
    int restartCount,
  ) {
    if (restartCount == 0 ||
        previousStepResults == null ||
        previousThinkingSteps == null) {
      return '';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== PREVIOUS ATTEMPT HISTORY (for learning) ===');
    buffer.writeln('Restart attempt: $restartCount');
    buffer.writeln('Previous thinking steps executed:');

    for (int i = 0; i < previousThinkingSteps.length; i++) {
      buffer.writeln('  ${i + 1}. ${previousThinkingSteps[i]}');
    }

    buffer.writeln('Previous pipeline results:');
    final resultsSummary = previousStepResults
        .map((result) => '${result.stepName}: ${result.success ? "✅" : "❌"}')
        .join(', ');
    buffer.writeln('  $resultsSummary');

    // Extract key insights from previous attempts
    final failedSteps =
        previousStepResults
            .where((result) => !result.success)
            .map((result) => result.stepName)
            .toList();

    if (failedSteps.isNotEmpty) {
      buffer.writeln(
        'Failed steps in previous attempt: ${failedSteps.join(", ")}',
      );
    }

    buffer.writeln(
      'LEARN FROM PREVIOUS ATTEMPTS: Try a different strategy this time.',
    );
    buffer.writeln('===============================================');

    return buffer.toString();
  }
}
