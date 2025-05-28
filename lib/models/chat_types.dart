import 'package:flutter/foundation.dart';
import 'dish.dart';
import 'user_ingredient.dart';

/// Message role enumeration
enum ChatMessageRole { user, assistant, system }

/// Chat error types for proper error handling
enum ChatErrorType {
  networkError,
  apiError,
  parseError,
  contextLength,
  processingError,
  verificationError,
  imageProcessingError,
  criticalError,
  missingPrerequisite, // Added
  unknown,
}

/// Error recovery types
enum ErrorRecoveryType {
  retry,
  contextReduction,
  fallback,
  skipStep,
  continueWithWarning,
  none,
}

/// Bot configuration for personality types
class BotConfiguration {
  final String type;
  final String name;
  final String behaviorType;
  final Map<String, dynamic>? additionalConfig;

  const BotConfiguration({
    required this.type,
    required this.name,
    required this.behaviorType,
    this.additionalConfig,
  });

  factory BotConfiguration.fromJson(Map<String, dynamic> json) {
    return BotConfiguration(
      type: json['type'] as String,
      name: json['name'] as String,
      behaviorType: json['behaviorType'] as String,
      additionalConfig: json['additionalConfig'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'behaviorType': behaviorType,
      'additionalConfig': additionalConfig,
    };
  }
}

/// Chat agent error class
class ChatAgentError {
  final ChatErrorType type;
  final String message;
  final String? details;
  final bool retryable;

  const ChatAgentError({
    required this.type,
    required this.message,
    this.details,
    required this.retryable,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'message': message,
      'details': details,
      'retryable': retryable,
    };
  }
}

/// Error recovery strategy
class ErrorRecoveryStrategy {
  final ErrorRecoveryType type;
  final bool retryable;
  final Map<String, dynamic> parameters;

  const ErrorRecoveryStrategy({
    required this.type,
    required this.retryable,
    this.parameters = const {},
  });
}

/// Error recovery result
class ErrorRecoveryResult {
  final bool success;
  final ErrorRecoveryStrategy strategy;
  final String message;
  final bool shouldRetry;
  final bool shouldSkipStep;
  final bool shouldContinue;
  final ChatResponse? fallbackResponse;
  final ChatStepInput? modifiedInput;

  const ErrorRecoveryResult({
    required this.success,
    required this.strategy,
    required this.message,
    this.shouldRetry = false,
    this.shouldSkipStep = false,
    this.shouldContinue = false,
    this.fallbackResponse,
    this.modifiedInput,
  });
}

/// Pipeline control actions that deep search verification can recommend
enum PipelineControlAction {
  continueNormally,
  retryWithModifications,
  skipOptionalSteps,
  gatherAdditionalContext,
  modifySearchParameters,
  discardAndRetry,
}

/// Pipeline control result for deep search verification step
class PipelineControlResult {
  final bool hasEnoughContext;
  final double confidence;
  final List<PipelineControlAction> recommendedActions;
  final Map<String, dynamic>? contextModifications;
  final List<String>? stepsToRetry;
  final List<String>? stepsToSkip;
  final Map<String, dynamic>? searchParameters;
  final String reasoning;
  final List<String> identifiedGaps;
  final List<String> suggestions;

  const PipelineControlResult({
    required this.hasEnoughContext,
    required this.confidence,
    required this.recommendedActions,
    required this.reasoning,
    this.contextModifications,
    this.stepsToRetry,
    this.stepsToSkip,
    this.searchParameters,
    this.identifiedGaps = const [],
    this.suggestions = const [],
  });

  factory PipelineControlResult.fromJson(Map<String, dynamic> json) {
    return PipelineControlResult(
      hasEnoughContext: json['hasEnoughContext'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      recommendedActions:
          (json['recommendedActions'] as List)
              .map(
                (action) => PipelineControlAction.values.firstWhere(
                  (e) => e.toString().split('.').last == action,
                ),
              )
              .toList(),
      reasoning: json['reasoning'] as String,
      contextModifications:
          json['contextModifications'] as Map<String, dynamic>?,
      stepsToRetry: (json['stepsToRetry'] as List?)?.cast<String>(),
      stepsToSkip: (json['stepsToSkip'] as List?)?.cast<String>(),
      searchParameters: json['searchParameters'] as Map<String, dynamic>?,
      identifiedGaps: (json['identifiedGaps'] as List?)?.cast<String>() ?? [],
      suggestions: (json['suggestions'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasEnoughContext': hasEnoughContext,
      'confidence': confidence,
      'recommendedActions':
          recommendedActions
              .map((action) => action.toString().split('.').last)
              .toList(),
      'reasoning': reasoning,
      'contextModifications': contextModifications,
      'stepsToRetry': stepsToRetry,
      'stepsToSkip': stepsToSkip,
      'searchParameters': searchParameters,
      'identifiedGaps': identifiedGaps,
      'suggestions': suggestions,
    };
  }
}

/// Chat execution context
class ChatExecutionContext {
  final String userMessage;
  final List<ChatMessage> conversationHistory;
  final BotConfiguration botConfiguration;
  final String? imageUri;
  final List<UserIngredient>? userIngredients;
  final DateTime startTime;

  const ChatExecutionContext({
    required this.userMessage,
    required this.conversationHistory,
    required this.botConfiguration,
    this.imageUri,
    this.userIngredients,
    required this.startTime,
  });
}

/// Processing stage callback for UI updates
typedef ProcessingStageCallback = void Function(String stage);

/// Chat error for message-level errors
class ChatError {
  final String type;
  final String message;
  final String? details;

  const ChatError({required this.type, required this.message, this.details});

  factory ChatError.fromJson(Map<String, dynamic> json) {
    return ChatError(
      type: json['type'] as String,
      message: json['message'] as String,
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'message': message, 'details': details};
  }
}

/// Standard chat message structure
class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final String? imageUri;
  final List<UserIngredient>? ingredients;
  final List<Dish>? dishes;
  final String? recommendation;
  final bool isLoading;
  final String? loadingStep;
  final ChatError? error;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.imageUri,
    this.ingredients,
    this.dishes,
    this.recommendation,
    this.isLoading = false,
    this.loadingStep,
    this.error,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      timestamp: DateTime.parse(
        json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      imageUri: json['imageUri']?.toString(),
      ingredients:
          json['ingredients'] != null
              ? (json['ingredients'] as List)
                  .map(
                    (e) => UserIngredient.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      dishes:
          json['dishes'] != null
              ? (json['dishes'] as List)
                  .map((e) => Dish.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
      recommendation: json['recommendation']?.toString(),
      isLoading: json['isLoading'] as bool? ?? false,
      loadingStep: json['loadingStep']?.toString(),
      error:
          json['error'] != null
              ? ChatError.fromJson(json['error'] as Map<String, dynamic>)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'imageUri': imageUri,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
      'dishes': dishes?.map((e) => e.toJson()).toList(),
      'recommendation': recommendation,
      'isLoading': isLoading,
      'loadingStep': loadingStep,
      'error': error?.toJson(),
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    String? imageUri,
    List<UserIngredient>? ingredients,
    List<Dish>? dishes,
    String? recommendation,
    bool? isLoading,
    String? loadingStep,
    ChatError? error,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      imageUri: imageUri ?? this.imageUri,
      ingredients: ingredients ?? this.ingredients,
      dishes: dishes ?? this.dishes,
      recommendation: recommendation ?? this.recommendation,
      isLoading: isLoading ?? this.isLoading,
      loadingStep: loadingStep ?? this.loadingStep,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Enhanced chat message with all context
class EnhancedChatMessage {
  final String id;
  final ChatMessageRole role;
  final String content;
  final DateTime timestamp;
  final String? imageUri;
  final List<UserIngredient>? ingredients;
  final List<Dish>? dishes;
  final String? recommendation;
  final bool isLoading;
  final String? loadingStep;
  final ChatError? error;
  final Map<String, dynamic>? metadata;

  const EnhancedChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.imageUri,
    this.ingredients,
    this.dishes,
    this.recommendation,
    this.isLoading = false,
    this.loadingStep,
    this.error,
    this.metadata,
  });

  EnhancedChatMessage copyWith({
    String? id,
    ChatMessageRole? role,
    String? content,
    DateTime? timestamp,
    String? imageUri,
    List<UserIngredient>? ingredients,
    List<Dish>? dishes,
    String? recommendation,
    bool? isLoading,
    String? loadingStep,
    ChatError? error,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      imageUri: imageUri ?? this.imageUri,
      ingredients: ingredients ?? this.ingredients,
      dishes: dishes ?? this.dishes,
      recommendation: recommendation ?? this.recommendation,
      isLoading: isLoading ?? this.isLoading,
      loadingStep: loadingStep ?? this.loadingStep,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }

  factory EnhancedChatMessage.fromJson(Map<String, dynamic> json) {
    return EnhancedChatMessage(
      id: json['id'] as String,
      role: ChatMessageRole.values[json['role'] as int],
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      imageUri: json['imageUri'] as String?,
      ingredients:
          json['ingredients'] != null
              ? (json['ingredients'] as List)
                  .map(
                    (e) => UserIngredient.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      dishes:
          json['dishes'] != null
              ? (json['dishes'] as List)
                  .map((e) => Dish.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
      recommendation: json['recommendation'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
      loadingStep: json['loadingStep'] as String?,
      error:
          json['error'] != null
              ? ChatError.fromJson(json['error'] as Map<String, dynamic>)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.index,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'imageUri': imageUri,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
      'dishes': dishes?.map((e) => e.toJson()).toList(),
      'recommendation': recommendation,
      'isLoading': isLoading,
      'loadingStep': loadingStep,
      'error': error?.toJson(),
      'metadata': metadata,
    };
  }
}

/// Chat response structure
class ChatResponse {
  final String replyText;
  final List<Dish>? dishes;
  final String? recommendation;
  final ChatError? error;
  final Map<String, dynamic>? metadata;

  const ChatResponse({
    required this.replyText,
    this.dishes,
    this.recommendation,
    this.error,
    this.metadata,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      replyText: json['replyText']?.toString() ?? '',
      dishes:
          json['dishes'] != null
              ? (json['dishes'] as List)
                  .map((e) => Dish.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
      recommendation: json['recommendation']?.toString(),
      error:
          json['error'] != null
              ? ChatError.fromJson(json['error'] as Map<String, dynamic>)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'replyText': replyText,
      'dishes': dishes?.map((e) => e.toJson()).toList(),
      'recommendation': recommendation,
      'error': error?.toJson(),
      'metadata': metadata,
    };
  }

  ChatResponse copyWith({
    String? replyText,
    List<Dish>? dishes,
    String? recommendation,
    ChatError? error,
    Map<String, dynamic>? metadata,
  }) {
    return ChatResponse(
      replyText: replyText ?? this.replyText,
      dishes: dishes ?? this.dishes,
      recommendation: recommendation ?? this.recommendation,
      error: error ?? this.error,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Thinking step response for initial analysis
class ThinkingStepResponse {
  final String userIntent;
  final ContextRequirements contextRequirements;
  final List<String> responseRequirements;
  final Map<String, dynamic>? metadata;

  const ThinkingStepResponse({
    required this.userIntent,
    required this.contextRequirements,
    required this.responseRequirements,
    this.metadata,
  });

  factory ThinkingStepResponse.fromJson(Map<String, dynamic> json) {
    return ThinkingStepResponse(
      userIntent: json['userIntent'] as String,
      contextRequirements: ContextRequirements.fromJson(
        json['contextRequirements'] as Map<String, dynamic>,
      ),
      responseRequirements: List<String>.from(
        json['responseRequirements'] as List,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userIntent': userIntent,
      'contextRequirements': contextRequirements.toJson(),
      'responseRequirements': responseRequirements,
      'metadata': metadata,
    };
  }

  /// Utility to safely convert dynamic to ThinkingStepResponse with error handling
  static ThinkingStepResponse? safeFromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is ThinkingStepResponse) return value;
    if (value is Map<String, dynamic>) {
      try {
        return ThinkingStepResponse.fromJson(value);
      } catch (e, st) {
        debugPrint('❌ Failed to convert map to ThinkingStepResponse: $e\n$st');
        return null;
      }
    }
    debugPrint(
      '❌ Unexpected type for ThinkingStepResponse: \\${value.runtimeType}',
    );
    return null;
  }
}

/// Agent step input for processing
class ChatStepInput {
  final String userMessage;
  final List<ChatMessage> conversationHistory;
  final String? imageUri;
  final List<UserIngredient>? userIngredients;
  final String? enhancedSystemPrompt;
  final ThinkingStepResponse? thinkingResult; // Added
  final String? initialSystemPrompt; // Added
  final Map<String, dynamic>? metadata;

  const ChatStepInput({
    required this.userMessage,
    this.conversationHistory = const [],
    this.imageUri,
    this.userIngredients,
    this.enhancedSystemPrompt,
    this.thinkingResult, // Added
    this.initialSystemPrompt, // Added
    this.metadata,
  });

  ChatStepInput copyWith({
    String? userMessage,
    List<ChatMessage>? conversationHistory,
    String? imageUri,
    ValueGetter<List<UserIngredient>?>? userIngredients,
    ValueGetter<String?>? enhancedSystemPrompt,
    ValueGetter<ThinkingStepResponse?>? thinkingResult, // Added
    ValueGetter<String?>? initialSystemPrompt, // Added
    Map<String, dynamic>? metadata,
  }) {
    return ChatStepInput(
      userMessage: userMessage ?? this.userMessage,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      imageUri: imageUri ?? this.imageUri,
      userIngredients:
          userIngredients != null ? userIngredients() : this.userIngredients,
      enhancedSystemPrompt:
          enhancedSystemPrompt != null
              ? enhancedSystemPrompt()
              : this.enhancedSystemPrompt,
      thinkingResult:
          thinkingResult != null
              ? thinkingResult()
              : this.thinkingResult, // Added
      initialSystemPrompt:
          initialSystemPrompt != null
              ? initialSystemPrompt()
              : this.initialSystemPrompt, // Added
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Context requirements for gathering information
class ContextRequirements {
  final bool needsUserProfile;
  final bool needsTodaysNutrition;
  final bool needsWeeklyNutritionSummary;
  final bool needsListOfCreatedDishes;
  final bool needsExistingDishes; // For checking if a dish exists
  final bool needsInfoOnDishCreation; // For how-to questions
  final bool needsNutritionAdvice;
  final bool needsHistoricalMealLookup; // For historical meal data
  final bool
  needsConversationHistory; // Whether full conversation history is needed for context
  final String?
  historicalMealPeriod; // e.g., "yesterday", "last_3_days", "last_week"
  final Map<String, dynamic>? metadata;
  const ContextRequirements({
    this.needsUserProfile = false,
    this.needsTodaysNutrition = false,
    this.needsWeeklyNutritionSummary = false,
    this.needsListOfCreatedDishes = false,
    this.needsExistingDishes = false,
    this.needsInfoOnDishCreation = false,
    this.needsNutritionAdvice = false,
    this.needsHistoricalMealLookup = false,
    this.needsConversationHistory = true,
    this.historicalMealPeriod,
    this.metadata,
  });
  factory ContextRequirements.fromJson(Map<String, dynamic> json) {
    return ContextRequirements(
      needsUserProfile: json['needsUserProfile'] as bool? ?? false,
      needsTodaysNutrition: json['needsTodaysNutrition'] as bool? ?? false,
      needsWeeklyNutritionSummary:
          json['needsWeeklyNutritionSummary'] as bool? ?? false,
      needsListOfCreatedDishes:
          json['needsListOfCreatedDishes'] as bool? ?? false,
      needsExistingDishes: json['needsExistingDishes'] as bool? ?? false,
      needsInfoOnDishCreation:
          json['needsInfoOnDishCreation'] as bool? ?? false,
      needsNutritionAdvice: json['needsNutritionAdvice'] as bool? ?? false,
      needsHistoricalMealLookup:
          json['needsHistoricalMealLookup'] as bool? ?? false,
      needsConversationHistory:
          json['needsConversationHistory'] as bool? ?? true,
      historicalMealPeriod: json['historicalMealPeriod'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'needsUserProfile': needsUserProfile,
      'needsTodaysNutrition': needsTodaysNutrition,
      'needsWeeklyNutritionSummary': needsWeeklyNutritionSummary,
      'needsListOfCreatedDishes': needsListOfCreatedDishes,
      'needsExistingDishes': needsExistingDishes,
      'needsInfoOnDishCreation': needsInfoOnDishCreation,
      'needsNutritionAdvice': needsNutritionAdvice,
      'needsHistoricalMealLookup': needsHistoricalMealLookup,
      'needsConversationHistory': needsConversationHistory,
      'historicalMealPeriod': historicalMealPeriod,
      'metadata': metadata,
    };
  }

  ContextRequirements copyWith({
    bool? needsUserProfile,
    bool? needsTodaysNutrition,
    bool? needsWeeklyNutritionSummary,
    bool? needsListOfCreatedDishes,
    bool? needsExistingDishes,
    bool? needsInfoOnDishCreation,
    bool? needsNutritionAdvice,
    bool? needsHistoricalMealLookup,
    bool? needsConversationHistory,
    String? historicalMealPeriod,
    Map<String, dynamic>? metadata,
  }) {
    return ContextRequirements(
      needsUserProfile: needsUserProfile ?? this.needsUserProfile,
      needsTodaysNutrition: needsTodaysNutrition ?? this.needsTodaysNutrition,
      needsWeeklyNutritionSummary:
          needsWeeklyNutritionSummary ?? this.needsWeeklyNutritionSummary,
      needsListOfCreatedDishes:
          needsListOfCreatedDishes ?? this.needsListOfCreatedDishes,
      needsExistingDishes: needsExistingDishes ?? this.needsExistingDishes,
      needsInfoOnDishCreation:
          needsInfoOnDishCreation ?? this.needsInfoOnDishCreation,
      needsNutritionAdvice: needsNutritionAdvice ?? this.needsNutritionAdvice,
      needsHistoricalMealLookup:
          needsHistoricalMealLookup ?? this.needsHistoricalMealLookup,
      needsConversationHistory:
          needsConversationHistory ?? this.needsConversationHistory,
      historicalMealPeriod: historicalMealPeriod ?? this.historicalMealPeriod,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Context Gathering step response
class ContextGatheringStepResponse {
  final String? enhancedSystemPrompt;
  final Map<String, dynamic>?
  gatheredContextData; // For any other data needed by later steps
  final Map<String, dynamic>? metadata;

  const ContextGatheringStepResponse({
    this.enhancedSystemPrompt,
    this.gatheredContextData,
    this.metadata,
  });

  factory ContextGatheringStepResponse.fromJson(Map<String, dynamic> json) {
    return ContextGatheringStepResponse(
      enhancedSystemPrompt: json['enhancedSystemPrompt'] as String?,
      gatheredContextData: json['gatheredContextData'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enhancedSystemPrompt': enhancedSystemPrompt,
      'gatheredContextData': gatheredContextData,
      'metadata': metadata,
    };
  }
}

/// Base class for chat agent steps
abstract class AgentStep {
  /// The unique name of this step (e.g., 'ThinkingStep', 'ContextGatheringStep')
  String get stepName;

  /// Executes the step and returns a [ChatStepResult].
  Future<ChatStepResult> execute(ChatStepInput input);

  /// Optionally verifies the result of this step.
  Future<ChatStepVerificationResult> verify(
    ChatStepResult result,
    ChatStepInput input,
  ) async {
    // Default: always valid
    return ChatStepVerificationResult.valid();
  }
}

/// Result of a single agent step
class ChatStepResult {
  final String stepName;
  final bool success;
  final dynamic
  data; // Step-specific output (e.g., ThinkingStepResponse, ContextGatheringStepResponse, etc.)
  final ChatAgentError? error;
  final DateTime? timestamp;

  ChatStepResult({
    required this.stepName,
    required this.success,
    this.data,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatStepResult.success({required String stepName, dynamic data}) {
    return ChatStepResult(stepName: stepName, success: true, data: data);
  }

  factory ChatStepResult.failure({
    required String stepName,
    required ChatAgentError error,
    dynamic data,
  }) {
    return ChatStepResult(
      stepName: stepName,
      success: false,
      error: error,
      data: data,
    );
  }

  Map<String, dynamic> toJson() => {
    'stepName': stepName,
    'success': success,
    'data': data is Map<String, dynamic> ? data : data?.toString(),
    'error': error?.toJson(),
    'timestamp': timestamp?.toIso8601String(),
  };
}

/// Result of verifying a step's output
class ChatStepVerificationResult {
  final bool valid;
  final String? message;
  final ChatAgentError? error;

  const ChatStepVerificationResult({
    required this.valid,
    this.message,
    this.error,
  });

  factory ChatStepVerificationResult.valid([String? message]) =>
      ChatStepVerificationResult(valid: true, message: message);
  factory ChatStepVerificationResult.invalid({
    String? message,
    ChatAgentError? error,
  }) =>
      ChatStepVerificationResult(valid: false, message: message, error: error);

  Map<String, dynamic> toJson() => {
    'valid': valid,
    'message': message,
    'error': error?.toJson(),
  };
}

/// Utility for runtime schema validation of agent step JSON outputs
class AgentStepSchemaValidator {
  /// Validates that [json] contains all [requiredKeys] and optionally type checks values.
  static bool validateJson(
    Map<String, dynamic> json,
    List<String> requiredKeys, {
    Map<String, Type>? typeMap,
    List<String>? allowedKeys,
  }) {
    for (final key in requiredKeys) {
      if (!json.containsKey(key)) return false;
      if (typeMap != null && typeMap.containsKey(key)) {
        if (json[key] != null && json[key].runtimeType != typeMap[key]) {
          return false;
        }
      }
    }
    if (allowedKeys != null) {
      for (final key in json.keys) {
        if (!allowedKeys.contains(key)) return false;
      }
    }
    return true;
  }
}
