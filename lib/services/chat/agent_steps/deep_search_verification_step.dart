import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart';
import '../openai_service.dart';

/// Performs deep verification of agent step results using secondary AI calls
class DeepSearchVerificationStep extends AgentStep {
  final OpenAIService _openaiService;

  DeepSearchVerificationStep({required OpenAIService openaiService})
    : _openaiService = openaiService;

  @override
  String get stepName => 'deep_search_verification';

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      debugPrint('🔍 DeepSearchVerificationStep: Starting verification');

      final stepToVerify = input.metadata!['stepToVerify'] as String;
      final stepResult = input.metadata!['stepResult'] as ChatStepResult;
      final originalUserMessage =
          input.metadata!['originalUserMessage'] as String;

      debugPrint('🔍 Verifying step: $stepToVerify');

      // Create verification prompt
      final verificationPrompt = _buildVerificationPrompt(
        stepToVerify,
        stepResult,
        originalUserMessage,
      );

      // Send verification request to AI
      final messages = [
        {'role': 'system', 'content': verificationPrompt},
        {
          'role': 'user',
          'content': 'Please verify the step result and provide your analysis.',
        },
      ];

      final response = await _openaiService.sendChatRequest(
        messages: messages,
        temperature: 0.1, // Low temperature for consistent verification
        responseFormat: {'type': 'json_object'},
      );

      final content = response.choices.first.message.content ?? '{}';
      final verificationResult = json.decode(content) as Map<String, dynamic>;

      // Parse verification result
      final verification = ChatStepVerificationResult(
        valid: verificationResult['isValid'] as bool? ?? false,
        message: verificationResult['details'] as String? ?? '',
        error: null,
      );

      debugPrint('🔍 DeepSearchVerificationStep: Verification completed');
      debugPrint('   Valid: ${verification.valid}');
      // Optionally log more details if needed

      return ChatStepResult.success(
        stepName: stepName,
        data: {'verification': verification, 'stepVerified': stepToVerify},
      );
    } catch (error) {
      debugPrint(
        '❌ DeepSearchVerificationStep: Error during execution: $error',
      );
      return ChatStepResult.failure(
        stepName: stepName,
        error: ChatAgentError(
          type: ChatErrorType.verificationError,
          message: 'Failed to perform deep verification',
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
        message: 'Verification step failed to execute',
        error: result.error,
      );
    }
    // Optionally, add more meta-verification logic here if needed
    return ChatStepVerificationResult.valid();
  }

  /// Builds the verification prompt for a specific step
  String _buildVerificationPrompt(
    String stepName,
    ChatStepResult stepResult,
    String originalUserMessage,
  ) {
    final prompt = StringBuffer();

    prompt.writeln(
      'You are an expert verification agent tasked with validating the results of a chat agent step.',
    );
    prompt.writeln();
    prompt.writeln('STEP BEING VERIFIED: $stepName');
    prompt.writeln('ORIGINAL USER MESSAGE: "$originalUserMessage"');
    prompt.writeln();
    prompt.writeln('STEP EXECUTION RESULT:');
    prompt.writeln('- Success: ${stepResult.success}');

    if (stepResult.success) {
      prompt.writeln(
        '- Data keys: ${stepResult.data?.keys.join(', ') ?? 'none'}',
      );

      // Add specific verification logic based on step type
      switch (stepName) {
        case 'thinking':
          _addThinkingVerificationGuidelines(prompt, stepResult);
          break;
        case 'context_gathering':
          _addContextVerificationGuidelines(prompt, stepResult);
          break;
        case 'response_generation':
          _addResponseVerificationGuidelines(prompt, stepResult);
          break;
        case 'dish_processing':
          _addDishProcessingVerificationGuidelines(prompt, stepResult);
          break;
        default:
          _addGenericVerificationGuidelines(prompt, stepResult);
      }
    } else {
      prompt.writeln('- Error: ${stepResult.error?.message}');
      prompt.writeln('- Error Type: ${stepResult.error?.type}');
    }

    prompt.writeln();
    prompt.writeln(
      'Please analyze the step result and provide verification in this JSON format:',
    );
    prompt.writeln('{');
    prompt.writeln('  "isValid": boolean,');
    prompt.writeln('  "issues": ["list", "of", "specific", "issues"],');
    prompt.writeln(
      '  "suggestions": ["list", "of", "improvement", "suggestions"],',
    );
    prompt.writeln('  "confidence": number_between_0_and_1,');
    prompt.writeln('  "details": "detailed_explanation_of_verification"');
    prompt.writeln('}');

    return prompt.toString();
  }

  void _addThinkingVerificationGuidelines(
    StringBuffer prompt,
    ChatStepResult result,
  ) {
    prompt.writeln();
    prompt.writeln('THINKING STEP VERIFICATION GUIDELINES:');
    prompt.writeln('- Check if analysis correctly identifies user intent');
    prompt.writeln(
      '- Verify context requirements are appropriate for the request',
    );
    prompt.writeln('- Ensure response requirements align with user needs');
    prompt.writeln(
      '- Validate that the thinking step provides clear guidance for subsequent steps',
    );

    if (result.data != null && result.data!.containsKey('thinkingResponse')) {
      final thinking = result.data!['thinkingResponse'];
      prompt.writeln('- Thinking result: $thinking');
    }
  }

  void _addContextVerificationGuidelines(
    StringBuffer prompt,
    ChatStepResult result,
  ) {
    prompt.writeln();
    prompt.writeln('CONTEXT GATHERING VERIFICATION GUIDELINES:');
    prompt.writeln(
      '- Check if all required context was successfully retrieved',
    );
    prompt.writeln('- Verify context is relevant to the user request');
    prompt.writeln('- Ensure context data is properly formatted');
    prompt.writeln(
      '- Validate that context gathering aligns with thinking step requirements',
    );

    if (result.data != null) {
      prompt.writeln(
        '- Available context keys: ${result.data!.keys.join(', ')}',
      );
    }
  }

  void _addResponseVerificationGuidelines(
    StringBuffer prompt,
    ChatStepResult result,
  ) {
    prompt.writeln();
    prompt.writeln('RESPONSE GENERATION VERIFICATION GUIDELINES:');
    prompt.writeln(
      '- Check if response text is helpful and addresses user query',
    );
    prompt.writeln(
      '- Verify dishes (if any) are properly structured and nutritionally reasonable',
    );
    prompt.writeln('- Ensure recommendations are actionable and relevant');
    prompt.writeln(
      '- Validate that response tone matches expected bot personality',
    );

    if (result.data != null && result.data!.containsKey('chatResponse')) {
      final response = result.data!['chatResponse'];
      prompt.writeln('- Response generated: $response');
    }
  }

  void _addDishProcessingVerificationGuidelines(
    StringBuffer prompt,
    ChatStepResult result,
  ) {
    prompt.writeln();
    prompt.writeln('DISH PROCESSING VERIFICATION GUIDELINES:');
    prompt.writeln('- Check if dishes were correctly parsed and validated');
    prompt.writeln(
      '- Verify nutritional information is reasonable and consistent',
    );
    prompt.writeln(
      '- Ensure ingredient lists are complete and properly formatted',
    );
    prompt.writeln(
      '- Validate that new dishes have unique IDs and proper metadata',
    );

    if (result.data != null) {
      final dishCount = (result.data!['validatedDishes'] as List?)?.length ?? 0;
      final errorCount =
          (result.data!['processingErrors'] as List?)?.length ?? 0;
      prompt.writeln('- Dishes processed: $dishCount');
      prompt.writeln('- Processing errors: $errorCount');
    }
  }

  void _addGenericVerificationGuidelines(
    StringBuffer prompt,
    ChatStepResult result,
  ) {
    prompt.writeln();
    prompt.writeln('GENERIC VERIFICATION GUIDELINES:');
    prompt.writeln('- Check if the step completed successfully');
    prompt.writeln('- Verify output data is properly structured');
    prompt.writeln('- Ensure step result aligns with expected outcomes');
    prompt.writeln('- Validate that any errors are properly handled');
  }
}
