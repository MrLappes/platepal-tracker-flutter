import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:platepal_tracker/models/user_ingredient.dart';
import '../../../models/chat_types.dart';
import '../../../models/dish.dart';
import '../openai_service.dart';
import '../../chat/system_prompts.dart';
import '../../../utils/image_utils.dart';

/// Generates the main AI response based on gathered context and user message
class ResponseGenerationStep extends AgentStep {
  final OpenAIService _openaiService;

  ResponseGenerationStep({required OpenAIService openaiService})
    : _openaiService = openaiService;

  @override
  String get stepName => 'response_generation';
  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      debugPrint('🤖 ResponseGenerationStep: Starting response generation');

      // Check for verification feedback from retry attempts
      final verificationFeedback =
          input.metadata?['verificationFeedback'] as Map<String, dynamic>?;
      final missingRequirements =
          input.metadata?['missingRequirements'] as List<dynamic>?;
      final responseIssues =
          input.metadata?['responseIssues'] as List<dynamic>?;
      final isRetryAttempt = input.metadata?['retryAttempt'] == true;

      if (isRetryAttempt) {
        debugPrint('🔄 ResponseGenerationStep: This is a retry attempt');
        debugPrint(
          '   Missing requirements: ${missingRequirements?.join(", ") ?? "none"}',
        );
        debugPrint(
          '   Response issues: ${responseIssues?.join(", ") ?? "none"}',
        );
      }

      // Check if we should include conversation history based on thinking step analysis
      bool includeConversationHistory = true; // Default to true for safety
      if (input.thinkingResult?.contextRequirements.needsConversationHistory !=
          null) {
        includeConversationHistory =
            input.thinkingResult!.contextRequirements.needsConversationHistory;
        debugPrint(
          '🤖 ResponseGenerationStep: Using thinking step decision for conversation history: $includeConversationHistory',
        );
      } else {
        debugPrint(
          '🤖 ResponseGenerationStep: No thinking result found, defaulting to include conversation history',
        );
      }
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
      );
      debugPrint('🤖 ResponseGenerationStep: Sending request to OpenAI');
      debugPrint(
        '🤖 ResponseGenerationStep: Messages count: ${messages.length}',
      );
      debugPrint('🤖 ResponseGenerationStep: Prompt/messages:');
      for (int i = 0; i < messages.length; i++) {
        final msg = messages[i];
        final role = msg['role'];
        final content = msg['content'];

        if (content is String) {
          // Text-only message
          final preview =
              content.length > 200
                  ? '${content.substring(0, 200)}...'
                  : content;
          debugPrint('  [$i] [$role] (text): $preview');
        } else if (content is List) {
          // Vision API message with text and image
          debugPrint(
            '  [$i] [$role] (vision): ${content.length} content items',
          );
          for (int j = 0; j < content.length; j++) {
            final item = content[j];
            // Only log type if item is a map (plain data)
            if (item is Map<String, dynamic> && item.containsKey('type')) {
              if (item['type'] == 'text') {
                final text = item['text'] as String;
                final preview =
                    text.length > 100 ? '${text.substring(0, 100)}...' : text;
                debugPrint('    [$j] text: $preview');
              } else if (item['type'] == 'image_url') {
                String? url;
                if (item['url'] is String) {
                  url = item['url'] as String;
                } else if (item['image_url'] is Map &&
                    (item['image_url'] as Map)['url'] is String) {
                  url = (item['image_url'] as Map)['url'] as String;
                }
                if (url != null) {
                  final preview =
                      url.length > 100 ? '${url.substring(0, 100)}...' : url;
                  debugPrint('    [$j] image_url: $preview');
                } else {
                  debugPrint('    [$j] image_url: (no url found)');
                }
              }
            } else {
              // For SDK objects or unknown types, just log the type
              debugPrint('    [$j] item type: ${item.runtimeType}');
            }
          }
        } else {
          debugPrint('  [$i] [$role] (unknown): ${content.toString()}');
        }
      }

      debugPrint(
        '🤖 ResponseGenerationStep: Sending ${messages.length} messages to OpenAI',
      );

      // Use the properly constructed messages array with ingredients and context
      final chatCompletionResponse = await _openaiService.sendChatRequest(
        messages: messages,
        temperature: 0.7,
        maxTokens: 2000,
      );
      final openaiResponse =
          chatCompletionResponse.choices.first.message.content ?? '';
      debugPrint(
        '🤖 ResponseGenerationStep: Received response: ${openaiResponse.length} characters',
      );

      // Parse the JSON response from OpenAI
      String replyText;
      List<Dish>? dishes;
      String? recommendation;

      try {
        // Check if response looks like JSON (starts with { and ends with })
        final trimmed = openaiResponse.trim();
        if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
          debugPrint('🤖 ResponseGenerationStep: Parsing JSON response');
          final jsonResponse =
              jsonDecode(openaiResponse) as Map<String, dynamic>;

          replyText =
              jsonResponse['replyText'] as String? ?? 'No response text found.';
          recommendation = jsonResponse['recommendation'] as String?;

          // Parse dishes if present
          final dishesJson = jsonResponse['dishes'] as List<dynamic>?;
          if (dishesJson != null) {
            dishes =
                dishesJson
                    .map(
                      (dishData) =>
                          _createDishFromJson(dishData as Map<String, dynamic>),
                    )
                    .where((dish) => dish != null)
                    .cast<Dish>()
                    .toList();
          }

          debugPrint(
            '🤖 ResponseGenerationStep: Successfully parsed JSON response',
          );
          debugPrint('   Reply text length: ${replyText.length}');
          debugPrint('   Dishes count: ${dishes?.length ?? 0}');
          debugPrint('   Has recommendation: ${recommendation != null}');
        } else {
          debugPrint(
            '🤖 ResponseGenerationStep: Response is not JSON, using as plain text',
          );
          replyText = openaiResponse;
        }
      } catch (e) {
        debugPrint(
          '⚠️ ResponseGenerationStep: Failed to parse JSON response: $e',
        );
        debugPrint(
          '   Raw response: ${openaiResponse.substring(0, openaiResponse.length > 200 ? 200 : openaiResponse.length)}...',
        );

        // Try to extract replyText from malformed JSON
        replyText = _extractReplyTextFromMalformedJson(openaiResponse);
        debugPrint('   Extracted reply text: ${replyText.length} characters');
      }

      final chatResponse = ChatResponse(
        replyText: replyText,
        dishes: dishes,
        recommendation: recommendation,
        metadata: {
          'modelUsed': _openaiService.selectedModel,
          'tokensUsed': chatCompletionResponse.usage?.totalTokens,
        },
      );
      debugPrint('✅ ResponseGenerationStep: Successfully generated response');
      return ChatStepResult.success(
        stepName: stepName,
        data: {
          'chatResponse': chatResponse.toJson(),
          'parsedResponse': openaiResponse,
          'conversationHistoryIncluded': includeConversationHistory,
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
          "🤖 ResponseGenerationStep: Added verification summary to system prompt: $verificationSummary",
        );
      }
    }

    // Add additional system prompt
    if (systemPrompt.isNotEmpty) {
      fullSystemPrompt += '\n$systemPrompt';
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
      '🤖 ResponseGenerationStep: System prompt added: $fullSystemPrompt',
    );

    // Conditionally add conversation history based on needsConversationHistory flag
    if (includeConversationHistory) {
      debugPrint(
        '🤖 ResponseGenerationStep: Including full conversation history',
      ); // Add conversation history (simplified)
      for (final historyMessage in conversationHistory) {
        if (historyMessage.role == 'system' || historyMessage.isLoading) {
          continue;
        }

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
          '🤖 ResponseGenerationStep: Processing image with vision API',
        );
        debugPrint('🤖 ResponseGenerationStep: Image URI: $imageUri');
        debugPrint('🤖 ResponseGenerationStep: Using model: $currentModel');
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
            '🤖 ResponseGenerationStep: Successfully converted image to base64',
          );
          debugPrint(
            '🤖 ResponseGenerationStep: Data URL length: ${imageDataUrl.length}',
          );
          debugPrint(
            '🤖 ResponseGenerationStep: Data URL preview: ${imageDataUrl.length > 200 ? imageDataUrl.substring(0, 200) : imageDataUrl}...',
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
              id: DateTime.now().millisecondsSinceEpoch.toString(),
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

      debugPrint(
        '✅ Created dish: $name with ${ingredients.length} ingredients',
      );
      debugPrint(
        '   Total nutrition: ${totalCalories.round()}cal, ${totalProtein.round()}g protein',
      );

      return Dish(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        description: description?.trim() ?? '',
        ingredients: ingredients,
        nutrition: nutrition,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
        category: dishData['category'] as String?,
      );
    } catch (e) {
      debugPrint(
        '⚠️ ResponseGenerationStep: Error creating dish from JSON: $e',
      );
      debugPrint('   Dish data: $dishData');
      return null;
    }
  }

  /// Helper method to extract replyText from potentially malformed JSON
  String _extractReplyTextFromMalformedJson(String rawResponse) {
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
      return "I apologize, but I encountered a formatting issue with my response. Could you please try your question again?";
    } catch (e) {
      debugPrint('⚠️ Error extracting reply text from malformed JSON: $e');
      return "I apologize, but I encountered a formatting issue with my response. Could you please try your question again?";
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
