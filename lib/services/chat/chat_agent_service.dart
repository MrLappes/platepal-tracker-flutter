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
      dishProcessor: _dishProcessingStep,
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
      );

      // Patch: Always pass a valid ThinkingStepResponse object
      final thinkingResultObj = ThinkingStepResponse.safeFromDynamic(
        thinkingResult.data?['thinkingResult'],
      );
      final contextInput = initialInput.copyWith(
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
      }

      // Step 3: Image Processing (if image provided)
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
      } // Step 4: Dish Processing (if dishes detected or mentioned)
      ChatStepResult? dishResult;
      final hasDishContent = _hasDishRelatedContent(
        thinkingResult,
        imageResult,
      );
      if (hasDishContent) {
        debugPrint('🍽️ Step 4: Processing dishes...');
        final dishStepText = '🍽️ Processing and analyzing dishes...';
        thinkingSteps.add(dishStepText);
        _onThinkingStep?.call(
          dishStepText,
          'Calculating nutrition values, ingredients, and meal details',
        );

        final dishInput = contextInput.copyWith(
          metadata: {
            ...contextInput.metadata!,
            ...contextResult.data!,
            if (imageResult != null) ...imageResult.data!,
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
      } // Step 5: Response Generation - Create final response
      debugPrint('✍️ Step 5: Generating response...');
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
          if (dishResult != null) ...dishResult.data!,
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
      }

      // Step 6: Deep Search Verification (if enabled)
      ChatStepResult? verificationResult;
      if (_deepSearchEnabled) {
        debugPrint('🔍 Step 6: Deep search verification...');
        final verificationStepText =
            '🔍 Verifying information with deep search...';
        thinkingSteps.add(verificationStepText);
        _onThinkingStep?.call(
          verificationStepText,
          'Cross-referencing information with additional sources for accuracy',
        );

        final verificationInput = responseInput.copyWith(
          metadata: {...responseInput.metadata!, ...responseResult.data!},
        );
        verificationResult = await _deepSearchVerificationStep.execute(
          verificationInput,
        );
        stepResults.add(verificationResult);

        // Deep search verification failure is not critical
        if (!verificationResult.success) {
          debugPrint('⚠️ Deep search verification failed, continuing...');
        }
      }

      // Extract final response
      final finalResponse = responseResult.data!['response'] as String;
      final extractedDishes =
          dishResult?.data?['validatedDishes'] as List? ?? [];

      final duration = DateTime.now().difference(startTime);
      debugPrint(
        '🤖 ChatAgentService: Completed full pipeline in ${duration.inMilliseconds}ms',
      );

      // Return comprehensive ChatResponse with all step data
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
          'dishesProcessed': extractedDishes.length,
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
            ...initialInput.metadata!,
            'error': e.toString(),
            'stackTrace': stackTrace.toString(),
            'partialResults': stepResults.map((r) => r.toJson()).toList(),
          },
        ),
      );
      stepResults.add(errorResult);

      final duration = DateTime.now().difference(startTime);
      return ChatResponse(
        replyText:
            errorResult.success
                ? errorResult.data!['response'] as String
                : 'I apologize, but I encountered an error processing your request. Please try again.',
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

  /// Check if the request has dish-related content
  bool _hasDishRelatedContent(
    ChatStepResult thinkingResult,
    ChatStepResult? imageResult,
  ) {
    final thinkingData = thinkingResult.data ?? {};
    final imageData = imageResult?.data ?? {};

    // Check if thinking step identified dish-related intent
    final hasThinkingDishIntent =
        thinkingData['hasDishContent'] == true ||
        thinkingData['dishRelated'] == true ||
        (thinkingData['categories'] as List?)?.contains('dish_analysis') ==
            true;

    // Check if image processing detected dishes
    final hasImageDishes =
        imageData['detectedDishes'] != null &&
        (imageData['detectedDishes'] as List).isNotEmpty;

    return hasThinkingDishIntent || hasImageDishes;
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
}
