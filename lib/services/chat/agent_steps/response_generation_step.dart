import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/user_ingredient.dart';
import 'package:uuid/uuid.dart';
import '../../../models/chat_types.dart';
import '../../../models/dish.dart';
import '../openai_service.dart';
import '../../chat/system_prompts.dart';
import '../../chat/agent_tools.dart';
import '../../chat/pipeline_modification_tracker.dart';
import '../../../utils/image_utils.dart';

const _uuid = Uuid();

/// Generates the main AI response based on gathered context and user message
class ResponseGenerationStep extends AgentStep {
  final OpenAIService _openaiService;
  final PipelineModificationTracker? _modificationTracker;

  /// Most recent history messages sent with a request.
  static const int maxHistoryMessages = 20;

  /// Character budget for those history messages.
  static const int maxHistoryChars = 24000;

  /// Set while building messages when the uploaded image had to be dropped.
  bool _imageProcessingFailed = false;

  ResponseGenerationStep({
    required OpenAIService openaiService,
    PipelineModificationTracker? modificationTracker,
  }) : _openaiService = openaiService,
       _modificationTracker = modificationTracker;

  @override
  String get stepName => 'response_generation';
  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    _imageProcessingFailed = false;
    try {
      debugPrint('🤖 ResponseGenerationStep: Starting response generation');
      final localizations = lookupAppLocalizations(
        Locale(input.metadata?['languageCode'] as String? ?? 'en'),
      );

      // Check for verification feedback from retry attempts
      final verificationFeedback =
          input.metadata?['verificationFeedback'] as Map<String, dynamic>?;
      final missingRequirements =
          input.metadata?['missingRequirements'] as List<dynamic>?;
      final responseIssues =
          input.metadata?['responseIssues'] as List<dynamic>?;
      final isRetryAttempt = input.metadata?['retryAttempt'] == true;

      if (isRetryAttempt) {
        debugPrint(
          '🔄 ResponseGenerationStep: Retry attempt '
          '(missing requirements: ${missingRequirements?.length ?? 0}, '
          'response issues: ${responseIssues?.length ?? 0})',
        );
      }

      // Use the thinking step's explicit decision on conversation history.
      // The normalizer in ThinkingStep now defaults to `true` (not false), so
      // this value is safe to trust directly.
      bool includeConversationHistory =
          input.thinkingResult?.contextRequirements.needsConversationHistory ??
          true; // Default true when no thinking result is available
      debugPrint(
        '🤖 ResponseGenerationStep: includeConversationHistory=$includeConversationHistory',
      );

      // Custom OpenAI-compatible endpoints (Ollama, LM Studio, ...) often
      // reject the `tools` field, so they get the JSON-output prompt instead.
      final isCompatMode = await _openaiService.getIsCompatibilityMode();

      final messages = await _buildConversationMessages(
        input.enhancedSystemPrompt ?? '',
        input.conversationHistory,
        input.userMessage,
        input.imageUri,
        input.userIngredients,
        contextSummary:
            input.metadata != null &&
                    input.metadata!['contextSummary'] is String
                ? input.metadata!['contextSummary'] as String
                : (input.metadata != null &&
                        input.metadata!['enhancedSystemPrompt'] is String
                    ? input.metadata!['enhancedSystemPrompt'] as String
                    : null),
        includeConversationHistory: includeConversationHistory,
        verificationFeedback: verificationFeedback,
        missingRequirements: missingRequirements?.cast<String>(),
        responseIssues: responseIssues?.cast<String>(),
        isRetryAttempt: isRetryAttempt,
        thinkingResult: input.thinkingResult,
        input: input,
        useToolCalling: !isCompatMode,
      );
      debugPrint(
        '🤖 ResponseGenerationStep: Sending ${messages.length} messages to OpenAI',
      );
      for (int i = 0; i < messages.length; i++) {
        final content = messages[i]['content'];
        final size =
            content is String
                ? '${content.length} chars'
                : content is List
                ? '${content.length} parts'
                : content.runtimeType.toString();
        debugPrint('  [$i] ${messages[i]['role']}: $size');
      }

      final uploadedImageUri =
          input.imageUri ?? input.metadata?['uploadedImageUri'] as String?;

      final tools =
          isCompatMode
              ? null
              : AgentTools.toolsForContext(input.thinkingResult);
      final toolChoice =
          isCompatMode
              ? null
              : AgentTools.toolChoiceForContext(input.thinkingResult);

      debugPrint(
        '🤖 ResponseGenerationStep: isCompatMode=$isCompatMode, '
        'tools=${tools?.length ?? 0}, toolChoice=$toolChoice',
      );

      final chatCompletionResponse = await _openaiService.sendChatRequest(
        messages: messages,
        temperature: 0.7,
        maxTokens: 2000,
        imageUri: uploadedImageUri,
        tools: tools,
        toolChoice: toolChoice,
      );

      final choice = chatCompletionResponse.choices.first;

      String replyText;
      List<Dish>? dishes;
      String? recommendation;

      if (choice.isToolCall) {
        // ── Tool-call path (preferred) ────────────────────────────────────
        debugPrint('🤖 ResponseGenerationStep: Received tool_calls response');
        final result = _dispatchToolCalls(
          choice.message.toolCalls ?? [],
          uploadedImageUri,
          dishInfoFallback:
              (input.metadata?['localizedFallbacks']
                      as Map<String, dynamic>?)?['dishInfo']
                as String? ??
              localizations.servicesChatAgentFallbackDishInfo,
        );
        replyText = result['replyText'] as String? ?? '';
        recommendation = result['recommendation'] as String?;
        dishes = result['dishes'] as List<Dish>?;
      } else {
        // ── Fallback: plain-text / JSON content path ──────────────────────
        // Some OpenAI-compatible endpoints may not support tool calling.
        // We keep the original JSON parsing as a graceful fallback.
        debugPrint(
          '🤖 ResponseGenerationStep: Tool calls not used, falling back to JSON content parsing',
        );
        final openaiResponse = choice.message.content ?? '';
        debugPrint(
          '🤖 ResponseGenerationStep: Received response: ${openaiResponse.length} characters',
        );

        try {
          final trimmed = openaiResponse.trim();
          if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
            final jsonResponse =
                jsonDecode(openaiResponse) as Map<String, dynamic>;
            replyText =
                jsonResponse['replyText'] as String? ??
              localizations.servicesChatAgentFallbackNoResponse;
            recommendation = jsonResponse['recommendation'] as String?;

            final dishesJson = jsonResponse['dishes'] as List<dynamic>?;
            if (dishesJson != null) {
              final parsed = <Dish>[];
              for (final dishData in dishesJson) {
                final dishMap = dishData as Map<String, dynamic>;
                final parsedDish = _createDishFromJson(dishMap);
                if (parsedDish == null) continue;
                if (uploadedImageUri != null && parsedDish.imageUrl == null) {
                  parsed.add(parsedDish.copyWith(imageUrl: uploadedImageUri));
                } else {
                  parsed.add(parsedDish);
                }
              }
              dishes = parsed;
            }
          } else {
            replyText = openaiResponse;
          }
        } catch (e) {
          debugPrint(
            '⚠️ ResponseGenerationStep: Failed to parse JSON response (${e.runtimeType})',
          );
          replyText = _extractReplyTextFromMalformedJson(
            openaiResponse,
            localizations.servicesChatAgentFallbackFormatting,
          );
        }
      }

      final chatResponse = ChatResponse(
        replyText: replyText,
        dishes: dishes,
        recommendation: recommendation,
        metadata: {
          'modelUsed': _openaiService.selectedModel,
          'tokensUsed': chatCompletionResponse.usage?.totalTokens,
          'usedToolCalling': choice.isToolCall,
        },
      );
      debugPrint('✅ ResponseGenerationStep: Successfully generated response');
      debugPrint('   Reply text length: ${replyText.length}');
      debugPrint('   Dishes count: ${dishes?.length ?? 0}');
      return ChatStepResult.success(
        stepName: stepName,
        data: {
          'chatResponse': chatResponse.toJson(),
          'parsedResponse': choice.message.content ?? '[tool_calls]',
          'conversationHistoryIncluded': includeConversationHistory,
          'usedToolCalling': choice.isToolCall,
          if (_imageProcessingFailed) 'imageAnalysisFailed': true,
          if (choice.isToolCall &&
              (choice.message.toolCalls?.isNotEmpty ?? false))
            'toolCallDetails':
                choice.message.toolCalls!
                    .map(
                      (tc) => {
                        'id': tc.id,
                        'tool': tc.functionName,
                        'arguments': tc.functionArguments,
                      },
                    )
                    .toList(),
        },
      );
    } catch (error) {
      debugPrint('❌ ResponseGenerationStep: Error during execution: $error');
      return ChatStepResult.failure(
        stepName: stepName,
        error: ChatAgentError(
          type: _classifyError(error),
          message: 'Failed to generate response',
          details: error.toString(),
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
        message: 'Response generation step failed',
        error: result.error,
      );
    }
    final chatResponseJson =
        result.data?['chatResponse'] as Map<String, dynamic>?;
    if (chatResponseJson == null) {
      return ChatStepVerificationResult.invalid(
        message: 'No chatResponse in step result',
      );
    }
    // Validate required fields
    final valid = AgentStepSchemaValidator.validateJson(
      chatResponseJson,
      ['replyText'],
      typeMap: {'replyText': String},
    );
    if (!valid) {
      return ChatStepVerificationResult.invalid(
        message: 'chatResponse failed schema validation',
      );
    }
    // Optionally: check for suspicious values, empty reply, etc.
    final replyText = chatResponseJson['replyText'];
    if (replyText == null ||
        (replyText is String && replyText.trim().isEmpty)) {
      return ChatStepVerificationResult.invalid(
        message: 'Empty or missing reply text in chatResponse',
      );
    }
    return ChatStepVerificationResult.valid();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tool call dispatcher
  // ─────────────────────────────────────────────────────────────────────────

  /// Parses an ordered list of OpenAI tool calls and builds the unified
  /// [ChatResponse] fields. Handles multiple calls in a single response
  /// (e.g. one `provide_chat_response` + one `create_new_dish`).
  Map<String, dynamic> _dispatchToolCalls(
    List<ToolCall> toolCalls,
    String? uploadedImageUri, {
    required String dishInfoFallback,
  }) {
    String replyText = '';
    String? recommendation;
    final dishes = <Dish>[];
    final toolCallLog = <Map<String, dynamic>>[];

    for (final call in toolCalls) {
      final args = call.parseArguments();
      debugPrint(
        '\ud83e\udd16 Tool call: ${call.functionName} '
        '(${call.functionArguments.length} chars of arguments)',
      );
      toolCallLog.add({'tool': call.functionName, 'args': args});

      switch (call.functionName) {
        case 'provide_chat_response':
          replyText = args['reply_text'] as String? ?? replyText;
          recommendation = args['recommendation'] as String? ?? recommendation;

        case 'ask_clarification':
          final q = args['question'] as String? ?? '';
          final ctx = args['context'] as String?;
          replyText = ctx != null && ctx.isNotEmpty ? '$q\n\n($ctx)' : q;

        case 'reference_existing_dish':
          replyText = args['reply_text'] as String? ?? replyText;
          recommendation = args['recommendation'] as String? ?? recommendation;
          // Pass a minimal dish map downstream for DishProcessingStep to
          // resolve from DB. The id comes from the AI's tool argument.
          final dishId = args['dish_id'] as String?;
          if (dishId != null && dishId.isNotEmpty) {
            final refDish = Dish(
              id: dishId,
              name: args['dish_name'] as String? ?? dishId,
              description: null,
              ingredients: const [],
              nutrition: const NutritionInfo(
                calories: 0,
                protein: 0,
                carbs: 0,
                fat: 0,
              ),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isFavorite: false,
            );
            dishes.add(refDish);
            _modificationTracker?.recordModification(
              type: PipelineModificationType.contextModification,
              severity: ModificationSeverity.medium,
              stepName: stepName,
              description: 'AI referenced an existing dish',
              technicalDetails:
                  'Tool: reference_existing_dish | DB ID: $dishId',
              afterData: {'dishId': dishId, 'dishName': args['dish_name']},
            );
          }

        case 'create_new_dish':
          replyText = args['reply_text'] as String? ?? replyText;
          recommendation = args['recommendation'] as String? ?? recommendation;
          // Map tool args -> Dish for downstream DishProcessingStep
          final newDish = _createDishFromToolArgs(args, uploadedImageUri);
          if (newDish != null) {
            dishes.add(newDish);
            _modificationTracker?.recordModification(
              type: PipelineModificationType.dataEnrichment,
              severity: ModificationSeverity.high,
              stepName: stepName,
              description: 'AI created a new dish',
              technicalDetails:
                  'Tool: create_new_dish | Ingredients: ${(args["ingredients"] as List?)?.length ?? 0} | '
                  'ID: ${newDish.id}',
              afterData: {
                'dishId': newDish.id,
                'dishName': newDish.name,
                'ingredientCount': newDish.ingredients.length,
                'toolArgs': args,
              },
            );
          }

        default:
          debugPrint('\u26a0\ufe0f Unknown tool call: ${call.functionName}');
      }
    }

    // Record the full tool-call summary to the modification tracker
    if (toolCallLog.isNotEmpty) {
      _modificationTracker?.recordModification(
        type: PipelineModificationType.aiValidation,
        severity: ModificationSeverity.low,
        stepName: stepName,
        description:
            'AI used tool calling (${toolCallLog.length} call${toolCallLog.length == 1 ? "" : "s"}): '
            '${toolCallLog.map((t) => t["tool"]).join(", ")}',
        technicalDetails: toolCallLog
            .map((t) => '${t["tool"]} (${(t["args"] as Map).length} args)')
            .join('\n'),
        afterData: {'toolCalls': toolCallLog},
      );
    }

    if (replyText.isEmpty && dishes.isNotEmpty) {
      replyText = dishInfoFallback;
    }

    return {
      'replyText': replyText,
      'recommendation': recommendation,
      'dishes': dishes.isEmpty ? null : dishes,
    };
  }

  /// Converts `create_new_dish` tool call arguments to a [Dish] object.
  Dish? _createDishFromToolArgs(
    Map<String, dynamic> args,
    String? uploadedImageUri,
  ) {
    try {
      final name = args['name'] as String?;
      if (name == null || name.trim().isEmpty) return null;

      final rawIngredients =
          (args['ingredients'] as List<dynamic>?) ?? const [];
      final ingredients = <Ingredient>[];
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalFiber = 0;

      for (final raw in rawIngredients) {
        if (raw is! Map<String, dynamic>) continue;
        final ingName = raw['name'] as String? ?? 'Unknown';
        final qty = _parseDouble(raw['quantity'] ?? raw['amount']);
        final unit = raw['unit'] as String? ?? 'g';
        final cal100 = _parseDouble(
          raw['calories_per_100'] ?? raw['caloriesPer100'],
        );
        final pro100 = _parseDouble(
          raw['protein_per_100'] ?? raw['proteinPer100'],
        );
        final carb100 = _parseDouble(
          raw['carbs_per_100'] ?? raw['carbsPer100'],
        );
        final fat100 = _parseDouble(raw['fat_per_100'] ?? raw['fatPer100']);
        final fib100 = _parseDouble(raw['fiber_per_100'] ?? raw['fiberPer100']);

        final nutrition = NutritionInfo(
          calories: cal100,
          protein: pro100,
          carbs: carb100,
          fat: fat100,
          fiber: fib100,
        );

        ingredients.add(
          Ingredient(
            id: _uuid.v4(),
            name: ingName.trim(),
            amount: qty,
            unit: unit,
            nutrition: nutrition,
          ),
        );

        // Calculate totals from per-100g values × amount in grams
        double inGrams;
        switch (unit.toLowerCase()) {
          case 'g':
          case 'gram':
          case 'grams':
            inGrams = qty;
          case 'kg':
            inGrams = qty * 1000;
          case 'ml':
          case 'milliliter':
          case 'milliliters':
            inGrams = qty;
          case 'l':
          case 'liter':
            inGrams = qty * 1000;
          case 'oz':
            inGrams = qty * 28.35;
          case 'lb':
            inGrams = qty * 453.592;
          case 'cup':
          case 'cups':
            inGrams = qty * 240;
          case 'tbsp':
          case 'tablespoon':
            inGrams = qty * 15;
          case 'tsp':
          case 'teaspoon':
            inGrams = qty * 5;
          default:
            inGrams = qty * 100; // items/pieces
        }
        final mult = inGrams / 100;
        totalCalories += cal100 * mult;
        totalProtein += pro100 * mult;
        totalCarbs += carb100 * mult;
        totalFat += fat100 * mult;
        totalFiber += fib100 * mult;
      }

      return Dish(
        id: _uuid.v4(),
        name: name.trim(),
        description: args['description'] as String?,
        ingredients: ingredients,
        nutrition: NutritionInfo(
          calories: totalCalories,
          protein: totalProtein,
          carbs: totalCarbs,
          fat: totalFat,
          fiber: totalFiber,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
        imageUrl: uploadedImageUri,
      );
    } catch (e) {
      debugPrint('\u26a0\ufe0f _createDishFromToolArgs failed: $e');
      return null;
    }
  }

  /// Builds the conversation messages for the OpenAI request
  Future<List<Map<String, dynamic>>> _buildConversationMessages(
    String systemPrompt,
    List<ChatMessage> conversationHistory,
    String userMessage,
    String? imageUri,
    List<UserIngredient>? userIngredients, {
    String? contextSummary,
    bool includeConversationHistory = true,
    Map<String, dynamic>? verificationFeedback,
    List<String>? missingRequirements,
    List<String>? responseIssues,
    bool isRetryAttempt = false,
    ThinkingStepResponse? thinkingResult,
    required ChatStepInput input,
    bool useToolCalling = true,
  }) async {
    final messages = <Map<String, dynamic>>[];

    // Build the enhanced system prompt based on thinking step requirements
    final thinkingResult = input.thinkingResult;
    final needsExistingDishes =
        thinkingResult?.contextRequirements.needsExistingDishes ?? false;
    final needsInfoOnDishCreation =
        thinkingResult?.contextRequirements.needsInfoOnDishCreation ?? false;

    // Build prompt with all required sections
    String fullSystemPrompt = SystemPrompts.buildEnhancedPrompt(
      botPersonality: input.metadata?['botPersonality'] as String?,
      needsExistingDishes: needsExistingDishes,
      needsInfoOnDishCreation: needsInfoOnDishCreation,
      useToolCalling: useToolCalling,
      contextSections: {if (contextSummary != null) 'Context': contextSummary},
    );

    // Add verification summary if available
    final isDeepValidationEnabled = input.metadata?['deepValidation'] == true;
    final wasVerificationSkipped = input.metadata?['skipVerification'] == true;

    if (isDeepValidationEnabled && !wasVerificationSkipped) {
      final verificationSummary =
          input.metadata?['modificationSummary'] as String?;

      if (verificationSummary != null) {
        fullSystemPrompt += SystemPrompts.verificationSummaryTemplate
            .replaceAll('{verificationSummary}', verificationSummary);
        debugPrint(
          '🤖 ResponseGenerationStep: Added verification summary '
          '(${verificationSummary.length} chars)',
        );
      }
    }

    // ContextGatheringStep builds its prompt for tool calling; without tools
    // those instructions would contradict the JSON format above.
    final additionalPrompt =
        useToolCalling
            ? systemPrompt
            : systemPrompt.replaceAll(SystemPrompts.toolCallingBasePrompt, '');
    if (additionalPrompt.trim().isNotEmpty) {
      fullSystemPrompt += '\n$additionalPrompt';
    }
    if (contextSummary != null && contextSummary.trim().isNotEmpty) {
      fullSystemPrompt += '\n\n[Context Information]\n${contextSummary.trim()}';
    }

    // Add verification feedback if this is a retry attempt
    if (isRetryAttempt &&
        (missingRequirements?.isNotEmpty == true ||
            responseIssues?.isNotEmpty == true)) {
      fullSystemPrompt += '\n\n${SystemPrompts.retryInstructionsTemplate}';

      if (missingRequirements?.isNotEmpty == true) {
        fullSystemPrompt += '\n\n${SystemPrompts.missingRequirementsTemplate}';
        for (final requirement in missingRequirements!) {
          fullSystemPrompt += '\n- $requirement';
        }
      }

      if (responseIssues?.isNotEmpty == true) {
        fullSystemPrompt += '\n\n${SystemPrompts.responseIssuesTemplate}';
        for (final issue in responseIssues!) {
          fullSystemPrompt += '\n- $issue';
        }
      }

      fullSystemPrompt +=
          '\n\nMake sure to address all missing requirements and avoid the previous issues in your response.';
    }

    // Add system prompt
    messages.insert(0, {'role': 'system', 'content': fullSystemPrompt});
    debugPrint(
      '🤖 ResponseGenerationStep: System prompt added '
      '(${fullSystemPrompt.length} chars, toolCalling=$useToolCalling)',
    );

    // Conditionally add conversation history based on needsConversationHistory flag
    if (includeConversationHistory) {
      final history = _recentHistory(conversationHistory, userMessage);
      debugPrint(
        '🤖 ResponseGenerationStep: Including ${history.length} of '
        '${conversationHistory.length} history messages',
      );
      messages.addAll(history);
    } else {
      debugPrint(
        '🤖 ResponseGenerationStep: Skipping conversation history per thinking step analysis',
      );
    } // Add current user message with enhancements
    String enhancedUserMessage =
        userMessage.trim().isEmpty
            ? "The user didn't add text, work with the attachments by themselves"
            : userMessage;

    // Add user ingredients if provided
    if (userIngredients != null && userIngredients.isNotEmpty) {
      final ingredientsList = userIngredients
          .map(
            (ing) => '${ing.name} (${ing.quantity}${ing.unit}, ID: ${ing.id})',
          )
          .join(', ');
      enhancedUserMessage += '\n\nIngredients I want to use: $ingredientsList';
    } // Handle image if present
    if (imageUri != null) {
      // Check if the current model supports vision
      final currentModel = _openaiService.selectedModel;
      if (!ImageUtils.isImageCapableModel(currentModel)) {
        debugPrint(
          '⚠️ ResponseGenerationStep: Model $currentModel does not support vision, skipping image',
        );
        enhancedUserMessage +=
            '\n\n[Note: User uploaded an image, but the current model does not support vision]';
        messages.add({'role': 'user', 'content': enhancedUserMessage});
      } else {
        // Use OpenAI Vision API format for images (plain map, not SDK)
        debugPrint(
          '🤖 ResponseGenerationStep: Processing image with vision API ($currentModel)',
        );
        try {
          final base64Image = await ImageUtils.resizeAndEncodeImage(
            imageUri,
            isHighDetail: false,
          );
          final imageDataUrl = ImageUtils.createImageDataUrl(
            base64Image,
            imagePath: imageUri,
          );

          debugPrint(
            '🤖 ResponseGenerationStep: Encoded image (${imageDataUrl.length} chars)',
          );

          // Use OpenAI Vision API format for images (plain map, not SDK)
          final contentItems = [
            {'type': 'text', 'text': enhancedUserMessage},
            {
              'type': 'image_url',
              'image_url': {'url': imageDataUrl},
            },
          ];
          messages.add({'role': 'user', 'content': contentItems});
        } catch (imageError) {
          debugPrint(
            '❌ ResponseGenerationStep: Error processing image: $imageError',
          );
          _imageProcessingFailed = true;
          // Fallback to text-only message with note about image
          enhancedUserMessage +=
              '\n\n[Note: User uploaded an image, but it could not be processed]';
          messages.add({'role': 'user', 'content': enhancedUserMessage});
        }
      }
    } else {
      messages.add({'role': 'user', 'content': enhancedUserMessage});
    }

    return messages;
  }

  /// The newest history messages that fit [maxHistoryMessages] and
  /// [maxHistoryChars], oldest first, without the current user message.
  List<Map<String, dynamic>> _recentHistory(
    List<ChatMessage> conversationHistory,
    String userMessage,
  ) {
    final usable =
        conversationHistory
            .where((m) => m.role != 'system' && !m.isLoading)
            .toList();
    // The caller's history already ends with the message being answered.
    if (usable.isNotEmpty &&
        usable.last.role == 'user' &&
        usable.last.content.trim() == userMessage.trim()) {
      usable.removeLast();
    }

    final selected = <Map<String, dynamic>>[];
    var chars = 0;
    for (final historyMessage in usable.reversed) {
      if (selected.length >= maxHistoryMessages) break;
      final content = _historyContent(historyMessage);
      chars += content.length;
      if (chars > maxHistoryChars) break;
      selected.add({'role': historyMessage.role, 'content': content});
    }
    return selected.reversed.toList();
  }

  String _historyContent(ChatMessage historyMessage) {
    String enhancedContent = historyMessage.content;

    if (historyMessage.role == 'user' &&
        historyMessage.ingredients != null &&
        historyMessage.ingredients!.isNotEmpty) {
      final ingredientsList = historyMessage.ingredients!
          .map(
            (ing) => '${ing.name} (${ing.quantity}${ing.unit}, ID: ${ing.id})',
          )
          .join(', ');
      enhancedContent +=
          '\n\n[User has the following ingredients ready: $ingredientsList]';
    }

    if (historyMessage.imageUri != null) {
      enhancedContent += '\n\n[This message includes an image]';
    }
    return enhancedContent;
  }

  /// Helper method to create a Dish object from JSON data
  Dish? _createDishFromJson(Map<String, dynamic> dishData) {
    try {
      // Extract basic dish information
      final name = dishData['name'] as String?;
      final description = dishData['description'] as String?;

      if (name == null || name.trim().isEmpty) {
        debugPrint(
          '⚠️ ResponseGenerationStep: Dish missing required name field',
        );
        return null;
      }

      // Parse ingredients list with proper nutrition data
      final ingredientsData = dishData['ingredients'] as List<dynamic>? ?? [];
      final ingredients = <Ingredient>[];

      double totalCalories = 0.0;
      double totalProtein = 0.0;
      double totalCarbs = 0.0;
      double totalFat = 0.0;
      double totalFiber = 0.0;
      double totalSugar = 0.0;
      double totalSodium = 0.0;

      for (final ingData in ingredientsData) {
        if (ingData is Map<String, dynamic>) {
          final ingredientName = ingData['name'] as String?;
          final quantity = _parseDouble(ingData['quantity']);
          final unit = ingData['unit'] as String? ?? 'g';
          final inGrams =
              _parseDouble(ingData['inGrams']) > 0
                  ? _parseDouble(ingData['inGrams'])
                  : quantity;

          if (ingredientName != null && ingredientName.trim().isNotEmpty) {
            // Extract per-100g nutrition values
            final caloriesPer100 = _parseDouble(ingData['caloriesPer100']);
            final proteinPer100 = _parseDouble(ingData['proteinPer100']);
            final carbsPer100 = _parseDouble(ingData['carbsPer100']);
            final fatPer100 = _parseDouble(ingData['fatPer100']);
            final fiberPer100 = _parseDouble(ingData['fiberPer100']);
            final sugarPer100 = _parseDouble(ingData['sugarPer100']);
            final sodiumPer100 = _parseDouble(ingData['sodiumPer100']);

            // Create nutrition info for this ingredient
            final ingredientNutrition = NutritionInfo(
              calories: caloriesPer100,
              protein: proteinPer100,
              carbs: carbsPer100,
              fat: fatPer100,
              fiber: fiberPer100,
              sugar: sugarPer100,
              sodium: sodiumPer100,
            );

            final ingredient = Ingredient(
              id: _uuid.v4(),
              name: ingredientName.trim(),
              amount: quantity,
              unit: unit,
              nutrition: ingredientNutrition,
            );

            ingredients.add(ingredient);

            // Calculate total nutrition based on actual amount
            final multiplier =
                inGrams / 100.0; // Convert per-100g to actual amount
            totalCalories += caloriesPer100 * multiplier;
            totalProtein += proteinPer100 * multiplier;
            totalCarbs += carbsPer100 * multiplier;
            totalFat += fatPer100 * multiplier;
            totalFiber += fiberPer100 * multiplier;
            totalSugar += sugarPer100 * multiplier;
            totalSodium += sodiumPer100 * multiplier;
          }
        }
      }

      // Create overall dish nutrition from calculated totals
      final nutrition = NutritionInfo(
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        fiber: totalFiber,
        sugar: totalSugar,
        sodium: totalSodium,
      );

      debugPrint('✅ Created dish with ${ingredients.length} ingredients');

      // Legacy JSON references an existing dish by its database id.
      final referenceId = dishData['id'];
      final isReference =
          dishData['reference'] == true &&
          referenceId is String &&
          referenceId.isNotEmpty;

      return Dish(
        id: isReference ? referenceId : _uuid.v4(),
        name: name.trim(),
        description: description?.trim() ?? '',
        ingredients: ingredients,
        nutrition: nutrition,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
        category: dishData['category'] as String?,
        imageUrl: dishData['imageUrl'] as String?,
      );
    } catch (e) {
      debugPrint(
        '⚠️ ResponseGenerationStep: Error creating dish from JSON (${e.runtimeType})',
      );
      return null;
    }
  }

  /// Helper method to extract replyText from potentially malformed JSON
  String _extractReplyTextFromMalformedJson(
    String rawResponse,
    String formattingFallback,
  ) {
    try {
      // First try to find replyText using regex pattern matching
      final replyTextPattern = RegExp(
        r'"replyText"\s*:\s*"([^"]*(?:\\.[^"]*)*)"',
      );
      final match = replyTextPattern.firstMatch(rawResponse);
      if (match != null) {
        final extractedText = match.group(1);
        if (extractedText != null && extractedText.trim().isNotEmpty) {
          // Unescape JSON string
          return extractedText
              .replaceAll('\\"', '"')
              .replaceAll('\\n', '\n')
              .replaceAll('\\\\', '\\');
        }
      }

      // If regex fails, try to find text between replyText quotes manually
      final startPattern = '"replyText"';
      final startIndex = rawResponse.indexOf(startPattern);
      if (startIndex != -1) {
        final afterStart = rawResponse.substring(
          startIndex + startPattern.length,
        );
        final colonIndex = afterStart.indexOf(':');
        if (colonIndex != -1) {
          final afterColon = afterStart.substring(colonIndex + 1).trim();
          if (afterColon.startsWith('"')) {
            final quoteEnd = _findClosingQuote(afterColon, 1);
            if (quoteEnd != -1) {
              final extractedText = afterColon.substring(1, quoteEnd);
              if (extractedText.trim().isNotEmpty) {
                return extractedText
                    .replaceAll('\\"', '"')
                    .replaceAll('\\n', '\n')
                    .replaceAll('\\\\', '\\');
              }
            }
          }
        }
      }

      // Last resort: look for any reasonable text in the response
      if (rawResponse.length > 100) {
        // Try to find anything that looks like conversational text
        final lines = rawResponse.split('\n');
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty &&
              !trimmed.startsWith('{') &&
              !trimmed.startsWith('}') &&
              !trimmed.startsWith('"dishes"') &&
              !trimmed.startsWith('"recommendation"') &&
              trimmed.length > 10) {
            return trimmed;
          }
        }
      }

      // If all else fails, provide a helpful error message instead of raw JSON
      return formattingFallback;
    } catch (e) {
      debugPrint('⚠️ Error extracting reply text from malformed JSON: $e');
      return formattingFallback;
    }
  }

  /// Helper to find the closing quote in a string, accounting for escaped quotes
  int _findClosingQuote(String text, int startIndex) {
    for (int i = startIndex; i < text.length; i++) {
      if (text[i] == '"') {
        // Check if this quote is escaped
        int backslashCount = 0;
        int j = i - 1;
        while (j >= 0 && text[j] == '\\') {
          backslashCount++;
          j--;
        }
        // If even number of backslashes (including 0), the quote is not escaped
        if (backslashCount % 2 == 0) {
          return i;
        }
      }
    }
    return -1;
  }

  /// Helper method to safely parse double values from JSON
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  ChatErrorType _classifyError(dynamic error) {
    if (error is TimeoutException) return ChatErrorType.networkError;
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('context length') ||
        errorMessage.contains('token limit')) {
      return ChatErrorType.contextLength;
    } else if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return ChatErrorType.networkError;
    } else if (errorMessage.contains('api') ||
        errorMessage.contains('unauthorized')) {
      return ChatErrorType.apiError;
    } else {
      return ChatErrorType.unknown;
    }
  }
}
