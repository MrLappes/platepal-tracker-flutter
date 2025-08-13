import 'dart:convert'; // Added for jsonDecode
import '../../../models/chat_types.dart';
import '../openai_service.dart';
import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart'
    as agent_types; // Added for ChatMessage type
import '../../chat/system_prompts.dart';

// Helper class for structuring OpenAI analysis results
class _OpenAIAnalysisResult {
  final String userIntent;
  final ContextRequirements contextRequirements;
  final List<String> responseRequirements;
  final String analysisSource;

  _OpenAIAnalysisResult({
    required this.userIntent,
    required this.contextRequirements,
    required this.responseRequirements,
    required this.analysisSource,
  });
}

/// First thinking step - determines context requirements, user intent, and response needs.
/// Attempts to use OpenAI for this analysis, with a rule-based fallback.
class ThinkingStep extends AgentStep {
  final OpenAIService _openAIService;

  ThinkingStep({required OpenAIService openaiService})
    : _openAIService = openaiService;

  @override
  String get stepName => 'thinking';

  /// Normalizes OpenAI JSON to match our expected schema, filling missing fields and ignoring extras.
  Map<String, dynamic> _normalizeOpenAIAnalysisJson(Map<String, dynamic> json) {
    // Normalize contextRequirements
    final ctx =
        (json['contextRequirements'] is Map<String, dynamic>)
            ? Map<String, dynamic>.from(json['contextRequirements'])
            : <String, dynamic>{};
    const boolKeys = [
      'needsUserProfile',
      'needsTodaysNutrition',
      'needsWeeklyNutritionSummary',
      'needsListOfCreatedDishes',
      'needsExistingDishes',
      'needsInfoOnDishCreation',
      'needsNutritionAdvice',
      'needsHistoricalMealLookup',
      'needsConversationHistory',
    ];
    for (final key in boolKeys) {
      ctx[key] = ctx[key] is bool ? ctx[key] : false;
    }

    if (!ctx.containsKey('needsConversationHistory') ||
        ctx['needsConversationHistory'] == null) {
      ctx['needsConversationHistory'] = false;
    }
    // Patch historicalMealPeriod to always be a string (never null)
    if (!ctx.containsKey('historicalMealPeriod') ||
        ctx['historicalMealPeriod'] == null) {
      ctx['historicalMealPeriod'] = '';
    } else if (ctx['historicalMealPeriod'] is! String) {
      ctx['historicalMealPeriod'] = ctx['historicalMealPeriod'].toString();
    }

    // Handle search terms arrays
    if (!ctx.containsKey('dishSearchTerms') ||
        ctx['dishSearchTerms'] is! List) {
      ctx['dishSearchTerms'] = <String>[];
    } else {
      ctx['dishSearchTerms'] = List<String>.from(
        (ctx['dishSearchTerms'] as List).map((e) => e.toString()),
      );
    }

    if (!ctx.containsKey('ingredientSearchTerms') ||
        ctx['ingredientSearchTerms'] is! List) {
      ctx['ingredientSearchTerms'] = <String>[];
    } else {
      ctx['ingredientSearchTerms'] = List<String>.from(
        (ctx['ingredientSearchTerms'] as List).map((e) => e.toString()),
      );
    }
    // Build normalized responseRequirements
    final responseReqList =
        (json['responseRequirements'] is List)
            ? List<String>.from(
              (json['responseRequirements'] as List).map((e) => e.toString()),
            )
            : <String>[];
    // Build normalized userIntent
    final userIntent =
        json['userIntent'] is String ? json['userIntent'] as String : '';
    return {
      'userIntent': userIntent,
      'contextRequirements': ctx,
      'responseRequirements': responseReqList,
    };
  }

  Future<_OpenAIAnalysisResult> _fetchOpenAIAnalysis(
    String userMessage,
    bool hasImage,
    bool hasIngredients,
    List<agent_types.ChatMessage> conversationHistory,
    String historyContext,
  ) async {
    // Compose the prompt with history context
    final prompt = SystemPrompts.analysisPrompt
        .replaceAll('{userMessage}', userMessage)
        .replaceAll('{hasImage}', hasImage ? 'yes' : 'no')
        .replaceAll('{hasIngredients}', hasIngredients ? 'yes' : 'no')
        .replaceAll(
          '{historyContext}',
          historyContext.isNotEmpty
              ? 'IMPORTANT - Previous Processing Context:\n$historyContext\n\nBased on this previous processing history, adjust your analysis to address any identified gaps or issues.\n'
              : '',
        );

    final messages = [
      {'role': 'system', 'content': prompt},
    ];
    debugPrint('🧠 ThinkingStep: Asking OpenAI for comprehensive analysis...');
    final response = await _openAIService.sendChatRequest(
      messages: messages,
      temperature: 0.2,
      responseFormat: {'type': 'json_object'},
    );
    final content = response.choices.first.message.content?.trim() ?? '{}';
    debugPrint('🧠 ThinkingStep: OpenAI analysis response: $content');
    // Parse and validate JSON
    Map<String, dynamic> jsonResponse;
    try {
      jsonResponse = jsonDecode(content) as Map<String, dynamic>;
      // Normalize the JSON to match our schema
      jsonResponse = _normalizeOpenAIAnalysisJson(jsonResponse);
      debugPrint(
        '🧠 ThinkingStep: Normalized OpenAI JSON for use: ${jsonEncode(jsonResponse)}',
      );
    } catch (e) {
      throw Exception('Failed to parse OpenAI JSON: $e');
    }
    // No strict schema validation needed, just use normalized
    final intent =
        jsonResponse['userIntent'] as String? ??
        'User query analysis failed to extract intent.';
    final contextReqJson =
        jsonResponse['contextRequirements'] as Map<String, dynamic>? ?? {};
    final contextRequirements = ContextRequirements.fromJson(contextReqJson);
    final responseReqList =
        jsonResponse['responseRequirements'] as List<dynamic>? ?? [];
    final responseRequirements =
        responseReqList.map((e) => e.toString()).toList();
    return _OpenAIAnalysisResult(
      userIntent: intent,
      contextRequirements: contextRequirements,
      responseRequirements: responseRequirements,
      analysisSource: 'openai',
    );
  }

  Future<_OpenAIAnalysisResult> _fetchOpenAIAnalysisWithRetry(
    String userMessage,
    bool hasImage,
    bool hasIngredients,
    List<agent_types.ChatMessage> conversationHistory,
    String historyContext, {
    int maxRetries = 2,
  }) async {
    int attempt = 0;
    Exception? lastError;
    while (attempt <= maxRetries) {
      try {
        final result = await _fetchOpenAIAnalysis(
          userMessage,
          hasImage,
          hasIngredients,
          conversationHistory,
          historyContext,
        );
        return result;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint(
          '🧠 ThinkingStep: OpenAI analysis attempt \\${attempt + 1} failed: \\${e.toString()}',
        );
        await Future.delayed(const Duration(milliseconds: 400));
      }
      attempt++;
    }
    throw lastError ?? Exception('Unknown error during OpenAI analysis');
  }

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      final userMessage = input.userMessage;
      final hasImage = input.imageUri != null && input.imageUri!.isNotEmpty;
      final hasIngredients =
          input.userIngredients != null && input.userIngredients!.isNotEmpty;

      // Extract history context for feedback from previous processing attempts
      final historyContext = input.historyContext ?? '';

      // Try OpenAI-driven analysis with retry and patching
      _OpenAIAnalysisResult? analysis;
      Exception? lastError;
      try {
        analysis = await _fetchOpenAIAnalysisWithRetry(
          userMessage,
          hasImage,
          hasIngredients,
          input.conversationHistory,
          historyContext,
        );
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint(
          '🧠 ThinkingStep: All OpenAI analysis attempts failed: \\${e.toString()}',
        );
      }
      if (analysis != null) {
        // Use the static helper to ensure a valid ThinkingStepResponse
        final thinkingResultRaw = {
          'userIntent': analysis.userIntent,
          'contextRequirements': analysis.contextRequirements.toJson(),
          'responseRequirements': analysis.responseRequirements,
        };
        final thinkingResult = ThinkingStepResponse.safeFromDynamic(
          thinkingResultRaw,
        );
        if (thinkingResult == null) {
          debugPrint(
            '❌ ThinkingStep: Failed to convert OpenAI result to ThinkingStepResponse. Falling back.',
          );
        }
        return ChatStepResult.success(
          stepName: stepName,
          data: {
            'thinkingResult': thinkingResult?.toJson() ?? thinkingResultRaw,
          },
        );
      } else {
        // Fallback: rule-based
        debugPrint(
          '🧠 ThinkingStep: Falling back to rule-based due to OpenAI failure: \\${lastError?.toString()}',
        );
        final fallbackIntent = _fallbackAnalyzeUserIntent(hasIngredients);
        final fallbackContext = _fallbackDetermineContextRequirements(
          hasIngredients,
        );
        final fallbackResponseReqs = _fallbackDetermineResponseRequirements(
          hasIngredients,
        );
        final thinkingResult = ThinkingStepResponse(
          userIntent: fallbackIntent,
          contextRequirements: fallbackContext,
          responseRequirements: fallbackResponseReqs,
        );
        return ChatStepResult.success(
          stepName: stepName,
          data: {'thinkingResult': thinkingResult.toJson()},
        );
      }
    } catch (error) {
      debugPrint(
        '❌ ThinkingStep: Error during execution: \\${error.toString()}',
      );
      // Always return a failure result, but with retryable true
      return ChatStepResult.failure(
        stepName: stepName,
        error: ChatAgentError(
          type: ChatErrorType.processingError,
          message: 'Thinking step failed: \\${error.toString()}',
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
        message: 'Thinking step failed',
        error: result.error,
      );
    }
    final thinkingResultJson =
        result.data?['thinkingResult'] as Map<String, dynamic>?;
    if (thinkingResultJson == null) {
      return ChatStepVerificationResult.invalid(
        message: 'No thinkingResult in step result',
      );
    }
    // Validate required fields
    final valid = AgentStepSchemaValidator.validateJson(thinkingResultJson, [
      'userIntent',
      'contextRequirements',
      'responseRequirements',
    ]);
    if (!valid) {
      return ChatStepVerificationResult.invalid(
        message: 'thinkingResult failed schema validation',
      );
    }
    return ChatStepVerificationResult.valid();
  }

  // --- Fallbacks ---
  String _fallbackAnalyzeUserIntent(bool hasIngredients) {
    return hasIngredients
        ? 'User is asking about ingredients or a recipe.'
        : 'User is asking a general nutrition question.';
  }

  ContextRequirements _fallbackDetermineContextRequirements(
    bool hasIngredients,
  ) {
    return hasIngredients
        ? ContextRequirements(
          needsExistingDishes: true,
          needsConversationHistory: false,
        )
        : ContextRequirements(
          needsNutritionAdvice: true,
          needsConversationHistory: true,
        );
  }

  List<String> _fallbackDetermineResponseRequirements(bool hasIngredients) {
    return hasIngredients
        ? ['recipe_suggestions']
        : ['general_nutrition_advice'];
  }
}
