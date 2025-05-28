import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:platepal_tracker/models/user_ingredient.dart';
import '../../../models/chat_types.dart';
import '../../../models/dish.dart';
import '../openai_service.dart';
import 'dish_processing_step.dart';
import '../../chat/system_prompts.dart';

/// Generates the main AI response based on gathered context and user message
class ResponseGenerationStep extends AgentStep {
  final OpenAIService _openaiService;
  final DishProcessingStep _dishProcessor;

  ResponseGenerationStep({
    required OpenAIService openaiService,
    required DishProcessingStep dishProcessor,
  }) : _openaiService = openaiService,
       _dishProcessor = dishProcessor;

  @override
  String get stepName => 'response_generation';

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      debugPrint('🤖 ResponseGenerationStep: Starting response generation');
      final messages = _buildConversationMessages(
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
      );
      debugPrint('🤖 ResponseGenerationStep: Sending request to OpenAI');
      debugPrint('🤖 ResponseGenerationStep: Prompt/messages:');
      for (final msg in messages) {
        debugPrint('  [${msg['role']}] ${msg['content']}');
      }
      final response = await _openaiService.sendChatRequest(
        messages: messages,
        temperature: 0.7,
        responseFormat: {'type': 'json_object'},
      );
      final content = response.choices.first.message.content ?? '{}';
      debugPrint(
        '🤖 ResponseGenerationStep: Raw API response received: $content',
      );

      // --- Robust JSON or plain text handling ---
      Map<String, dynamic>? parsedResponse;
      String? fallbackText;
      try {
        // Try to extract JSON from the content, even if text is before/after
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          parsedResponse =
              json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
        } else {
          // Not a JSON object, treat as plain text
          fallbackText = content.trim();
        }
      } catch (parseError) {
        debugPrint(
          '❌ ResponseGenerationStep: Failed to parse response as JSON: $parseError',
        );
        fallbackText = content.trim();
      }
      if (parsedResponse == null) {
        // Fallback: treat as plain text response
        parsedResponse = {
          'replyText': fallbackText ?? "I'm not sure how to respond to that.",
          'dishes': [],
          'recommendation': null,
        };
      }
      // Validate required keys and types
      final valid = AgentStepSchemaValidator.validateJson(
        parsedResponse,
        ['replyText'],
        typeMap: {'replyText': String},
      );
      if (!valid) {
        debugPrint(
          '❌ ResponseGenerationStep: AI response failed schema validation',
        );
        return ChatStepResult.failure(
          stepName: stepName,
          error: ChatAgentError(
            type: ChatErrorType.verificationError,
            message: 'AI response failed schema validation',
            details: parsedResponse.toString(),
            retryable: true,
          ),
        );
      }

      // --- Dish processing (if present) ---
      List<Dish> validatedDishes = [];
      if (parsedResponse['dishes'] != null &&
          parsedResponse['dishes'] is List) {
        final dishProcessingResult = await _dishProcessor.execute(
          ChatStepInput(
            userMessage: input.userMessage,
            imageUri: input.imageUri,
            userIngredients: input.userIngredients,
            metadata: {
              'dishes': parsedResponse['dishes'],
              'uploadedImageUri': input.imageUri,
            },
          ),
        );
        if (dishProcessingResult.success) {
          // Map ProcessedDish to Dish if necessary
          final processed = dishProcessingResult.data?['validatedDishes'];
          if (processed != null && processed is List) {
            validatedDishes =
                processed.where((e) => e is Dish).cast<Dish>().toList();
          }
        } else {
          debugPrint(
            '⚠️ ResponseGenerationStep: Dish processing failed, continuing without dishes',
          );
        }
      }

      // --- Build ChatResponse ---
      final chatResponse = ChatResponse(
        replyText:
            parsedResponse['replyText'] as String? ??
            "I'm not sure how to respond to that.",
        dishes: validatedDishes.isNotEmpty ? validatedDishes : null,
        recommendation: parsedResponse['recommendation'] as String?,
        metadata: {
          'modelUsed': _openaiService.selectedModel,
          'tokensUsed': response.usage?.totalTokens,
          'dishesProcessed': validatedDishes.length,
        },
      );
      debugPrint('✅ ResponseGenerationStep: Successfully generated response');
      return ChatStepResult.success(
        stepName: stepName,
        data: {'chatResponse': chatResponse.toJson()},
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
    if ((chatResponseJson['replyText'] as String).trim().isEmpty) {
      return ChatStepVerificationResult.invalid(
        message: 'Empty reply text in chatResponse',
      );
    }
    return ChatStepVerificationResult.valid();
  }

  /// Builds the conversation messages for the OpenAI request
  List<Map<String, dynamic>> _buildConversationMessages(
    String systemPrompt,
    List<ChatMessage> conversationHistory,
    String userMessage,
    String? imageUri,
    List<UserIngredient>? userIngredients, {
    String? contextSummary,
  }) {
    final messages = <Map<String, dynamic>>[];

    // Always start with baseChatPrompt, then append any additional systemPrompt and contextSummary
    String fullSystemPrompt = SystemPrompts.baseChatPrompt;
    if (systemPrompt.isNotEmpty) {
      fullSystemPrompt += '\n$systemPrompt';
    }
    if (contextSummary != null && contextSummary.trim().isNotEmpty) {
      fullSystemPrompt += '\n\n[Context Information]\n${contextSummary.trim()}';
    }

    // Add system prompt
    messages.insert(0, {'role': 'system', 'content': fullSystemPrompt});
    debugPrint(
      '🤖 ResponseGenerationStep: System prompt added: ' + fullSystemPrompt,
    );
    // Add conversation history (simplified)
    for (final historyMessage in conversationHistory) {
      if (historyMessage.role == 'system' || historyMessage.isLoading) continue;

      String enhancedContent = historyMessage.content;

      // Add ingredients info if present
      if (historyMessage.role == 'user' &&
          historyMessage.ingredients != null &&
          historyMessage.ingredients!.isNotEmpty) {
        final ingredientsList = historyMessage.ingredients!
            .map(
              (ing) =>
                  '${ing.name} (${ing.quantity}${ing.unit}, ID: ${ing.id})',
            )
            .join(', ');
        enhancedContent +=
            '\n\n[User has the following ingredients ready: $ingredientsList]';
      }

      // Note if message has image
      if (historyMessage.imageUri != null) {
        enhancedContent += '\n\n[This message includes an image]';
      }

      messages.add({'role': historyMessage.role, 'content': enhancedContent});
    }

    // Add current user message with enhancements
    String enhancedUserMessage = userMessage;

    // Add user ingredients if provided
    if (userIngredients != null && userIngredients.isNotEmpty) {
      final ingredientsList = userIngredients
          .map(
            (ing) => '${ing.name} (${ing.quantity}${ing.unit}, ID: ${ing.id})',
          )
          .join(', ');
      enhancedUserMessage += '\n\nIngredients I want to use: $ingredientsList';
    }

    // Handle image if present
    if (imageUri != null) {
      // For now, just note the image presence
      // TODO: Implement image processing when OpenAI service supports it
      enhancedUserMessage += '\n\n[User uploaded an image with this message]';
    }

    messages.add({'role': 'user', 'content': enhancedUserMessage});

    return messages;
  }

  ChatErrorType _classifyError(dynamic error) {
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
