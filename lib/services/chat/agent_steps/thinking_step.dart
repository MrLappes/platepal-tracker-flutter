import 'dart:convert'; // Added for jsonDecode
import '../../../models/chat_types.dart';
import '../openai_service.dart';
import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart'
    as agent_types; // Added for ChatMessage type

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

  static const String _comprehensiveAnalysisSystemPrompt = '''\
You are an AI assistant helping another AI, PlatePal (a nutrition tracking app), to understand a user's query and prepare for a response.
Based on the user's message and conversation history, analyze the query.

{historyContext}

Respond with a SINGLE JSON object containing the following fields:
1.  "userIntent": A concise string (max 15 words) describing the user's primary goal or question.
2.  "contextRequirements": An object with boolean flags for data PlatePal might need to gather:
    - "needsUserProfile": true/false (if personal data like goals, weight, height, activity level, dietary preferences, allergies, health conditions is relevant for personalization)
    - "needsTodaysNutrition": true/false (if a summary of today's logged meals and nutrition is relevant)
    - "needsWeeklyNutritionSummary": true/false (if a summary of the past week's nutrition is relevant)
    - "needsListOfCreatedDishes": true/false (if a list of dishes the user has previously created/saved is relevant, e.g., when user says "my dishes")
    - "needsExistingDishes": true/false (if general knowledge about existing dishes/recipes is relevant, e.g., for suggestions, or if user mentions ingredients)
    - "needsInfoOnDishCreation": true/false (if the user is asking the bot to create a new dish or recipe, e.g., "create a recipe for chicken curry" or "make a dish with these ingredients". IMPORTANT: Also set to true if user asks for a specific dish/recipe that might not exist in the database, like "Schnitzel mit Pommes" or "Pizza Margherita" - it's better to be prepared to create dishes than to tell users "no dishes found")
    - "needsNutritionAdvice": true/false (if the user is seeking general nutrition advice, or asking about healthiness of foods)
    - "needsHistoricalMealLookup": true/false (if the user is asking about meals from a specific past day/period like "yesterday" or "last Tuesday")
    - "needsConversationHistory": true/false (if the full conversation history is needed for context, or false if just the current message and system prompt are sufficient for an appropriate response, set to false only if the question is completely off topic or unrelated to previous messages)
    - "historicalMealPeriod": string (e.g., "yesterday", "last week", "tuesday", if needsHistoricalMealLookup is true and a period is identifiable, otherwise null)
    - "dishSearchTerms": array of strings - when needsExistingDishes is true, provide specific dish names to search for (e.g., ["chicken curry", "pasta", "salad"]). Maximum 5 terms. Use empty array if no specific dishes mentioned.
    - "ingredientSearchTerms": array of strings - when needsExistingDishes is true, provide specific ingredients to search for (e.g., ["chicken", "tomato", "cheese"]). Maximum 5 terms. Use empty array if no ingredients mentioned.
3.  "responseRequirements": A list of strings indicating key elements the AI's final response should include (e.g., ["recipe_suggestions", "nutrition_information", "meal_planning", "image_analysis", "dish_identification", "nutrition_estimation", "general_nutrition_advice"]). Choose from these examples or create specific ones if needed.

SEARCH TERM GENERATION (when needsExistingDishes is true):
- Extract specific food names, dishes, or ingredients mentioned by user
- Include synonyms and variations (e.g., if user says "bread", include "toast", "sandwich")  
- Keep terms simple and specific (avoid generic words like "food" or "meal")
- Consider user's likely intent (if asking about breakfast, include breakfast foods)
- Use common food terminology, not scientific names

SEARCH EXAMPLES:
User: "Show me chicken dishes" → dishSearchTerms: ["chicken", "poultry"], ingredientSearchTerms: ["chicken"]
User: "I want something with tomatoes" → dishSearchTerms: [], ingredientSearchTerms: ["tomato", "tomatoes"]
User: "Any pasta recipes?" → dishSearchTerms: ["pasta", "spaghetti", "linguine"], ingredientSearchTerms: ["pasta"]
User: "What can I make for breakfast?" → dishSearchTerms: ["breakfast", "cereal", "oatmeal", "eggs"], ingredientSearchTerms: ["eggs", "oats"]

Consider the conversation history for recurring themes or implicit needs.
User's current message: "{userMessage}"
Does the message include an image? {hasImage}
Does the message include a list of ingredients provided by the user? {hasIngredients}

Return ONLY the JSON object.
Example for "User wants a recipe for chicken and rice":
{
  "userIntent": "User is looking for a recipe using chicken and rice.",
  "contextRequirements": {
    "needsUserProfile": false,
    "needsTodaysNutrition": false,
    "needsWeeklyNutritionSummary": false,
    "needsListOfCreatedDishes": false,
    "needsExistingDishes": true,
    "needsInfoOnDishCreation": true,
    "needsNutritionAdvice": false,
    "needsHistoricalMealLookup": false,
    "needsConversationHistory": false,
    "historicalMealPeriod": null,
    "dishSearchTerms": ["chicken rice", "rice bowl"],
    "ingredientSearchTerms": ["chicken", "rice"]
  },
  "responseRequirements": ["recipe_suggestions", "dish_creation"]
}

IMPORTANT: 
- When user asks for specific dishes/recipes (like "Schnitzel mit Pommes", "Pizza Margherita", "Pasta Carbonara"), ALWAYS set both "needsExistingDishes": true AND "needsInfoOnDishCreation": true. This ensures we can either find existing recipes OR create new ones if none exist.
- ALWAYS include dishSearchTerms and ingredientSearchTerms arrays (empty arrays if no search needed).
- The system will search for dishes matching these terms and limit results to 10 dishes maximum for performance.
''';

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
    final prompt = _comprehensiveAnalysisSystemPrompt
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
