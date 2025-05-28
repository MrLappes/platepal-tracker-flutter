import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart';
import '../openai_service.dart';

/// Performs pre-response context validation and pipeline control decisions
/// This step acts as a "second thinking step" that analyzes whether the gathered
/// context is sufficient to properly answer the user's question and provides
/// pipeline control instructions for dynamic execution flow.
class DeepSearchVerificationStep extends AgentStep {
  final OpenAIService _openaiService;

  DeepSearchVerificationStep({required OpenAIService openaiService})
    : _openaiService = openaiService;

  @override
  String get stepName => 'deep_search_verification';

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      debugPrint('🔍 DeepSearchVerificationStep: Starting context validation');

      // Extract gathered context and thinking results
      final thinkingResult = input.thinkingResult;
      final contextData =
          input.metadata?['contextGatheringResult'] as Map<String, dynamic>?;
      final imageData = input.metadata?['imageResult'] as Map<String, dynamic>?;
      final dishData = input.metadata?['dishResult'] as Map<String, dynamic>?;

      // Build context validation prompt
      final validationPrompt = _buildContextValidationPrompt(
        input.userMessage,
        input.enhancedSystemPrompt ?? input.initialSystemPrompt ?? '',
        thinkingResult,
        contextData,
        imageData,
        dishData,
      );

      debugPrint(
        '🔍 Analyzing context sufficiency for proper response generation',
      );

      // Send validation request to AI
      final messages = [
        {'role': 'system', 'content': validationPrompt},
        {
          'role': 'user',
          'content':
              'Analyze the context and determine if there is enough information to properly answer the user\'s question. Provide pipeline control recommendations.',
        },
      ];

      final response = await _openaiService.sendChatRequest(
        messages: messages,
        temperature: 0.1, // Low temperature for consistent validation
        responseFormat: {'type': 'json_object'},
      );

      final content = response.choices.first.message.content ?? '{}';
      final validationResult = json.decode(content) as Map<String, dynamic>;

      // Parse pipeline control result
      final pipelineControl = PipelineControlResult.fromJson(validationResult);

      debugPrint('🔍 Context validation completed');
      debugPrint('   Has enough context: ${pipelineControl.hasEnoughContext}');
      debugPrint('   Confidence: ${pipelineControl.confidence}');
      debugPrint(
        '   Recommended actions: ${pipelineControl.recommendedActions}',
      );

      return ChatStepResult.success(
        stepName: stepName,
        data: {
          'pipelineControl': pipelineControl.toJson(),
          'validationDetails': validationResult,
        },
      );
    } catch (error) {
      debugPrint(
        '❌ DeepSearchVerificationStep: Error during execution: $error',
      );
      return ChatStepResult.failure(
        stepName: stepName,
        error: ChatAgentError(
          type: ChatErrorType.verificationError,
          message: 'Failed to perform context validation',
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
        message: 'Context validation step failed to execute',
        error: result.error,
      );
    }

    // Validate the pipeline control result structure
    final pipelineControlData =
        result.data?['pipelineControl'] as Map<String, dynamic>?;
    if (pipelineControlData == null) {
      return ChatStepVerificationResult.invalid(
        message: 'No pipeline control result in validation step output',
      );
    }

    // Validate required fields
    final valid = AgentStepSchemaValidator.validateJson(pipelineControlData, [
      'hasEnoughContext',
      'confidence',
      'recommendedActions',
      'reasoning',
    ]);

    if (!valid) {
      return ChatStepVerificationResult.invalid(
        message: 'Pipeline control result failed schema validation',
      );
    }

    return ChatStepVerificationResult.valid();
  }

  /// Builds the context validation prompt for analyzing whether gathered context is sufficient
  String _buildContextValidationPrompt(
    String userMessage,
    String systemPrompt,
    ThinkingStepResponse? thinkingResult,
    Map<String, dynamic>? contextData,
    Map<String, dynamic>? imageData,
    Map<String, dynamic>? dishData,
  ) {
    final prompt = StringBuffer();

    prompt.writeln(
      'You are an expert context validation agent that determines whether there is enough context to properly answer a user\'s question.',
    );
    prompt.writeln();
    prompt.writeln('Your job is to:');
    prompt.writeln(
      '1. Analyze the user\'s question against the gathered context',
    );
    prompt.writeln(
      '2. Determine if there\'s sufficient information for a proper response',
    );
    prompt.writeln(
      '3. Provide pipeline control recommendations for optimization',
    );
    prompt.writeln();

    prompt.writeln(
      'IMPORTANT: Conversation history will be appended during the final response generation step and is not visible here for validation. Focus only on validating the contextual data sources shown below.',
    );
    prompt.writeln();

    prompt.writeln('USER QUESTION: "$userMessage"');
    prompt.writeln();

    prompt.writeln('SYSTEM CONTEXT:');
    prompt.writeln(systemPrompt);
    prompt.writeln();

    if (thinkingResult != null) {
      prompt.writeln('THINKING STEP ANALYSIS:');
      prompt.writeln('- User Intent: ${thinkingResult.userIntent}');
      prompt.writeln(
        '- Context Requirements: ${thinkingResult.contextRequirements.toJson()}',
      );
      prompt.writeln(
        '- Response Requirements: ${thinkingResult.responseRequirements}',
      );
      prompt.writeln();
    }

    if (contextData != null) {
      prompt.writeln('GATHERED CONTEXT DATA:');
      contextData.forEach((key, value) {
        prompt.writeln(
          '- $key: ${value.toString().length > 100 ? "${value.toString().substring(0, 100)}..." : value}',
        );
      });
      prompt.writeln();
    }

    if (imageData != null) {
      prompt.writeln('IMAGE PROCESSING RESULTS:');
      imageData.forEach((key, value) {
        prompt.writeln('- $key: Available');
      });
      prompt.writeln();
    }

    if (dishData != null) {
      prompt.writeln('DISH PROCESSING RESULTS:');
      dishData.forEach((key, value) {
        prompt.writeln('- $key: Available');
      });
      prompt.writeln();
    }

    prompt.writeln('VALIDATION GUIDELINES:');
    prompt.writeln(
      '- Assess if the gathered context addresses the user\'s specific question',
    );
    prompt.writeln('- Consider if there are any critical information gaps');
    prompt.writeln('- Evaluate the quality and relevance of available context');
    prompt.writeln(
      '- Determine if additional context gathering would significantly improve the response',
    );
    prompt.writeln(
      '- Consider token efficiency - don\'t recommend gathering unnecessary context',
    );
    prompt.writeln();

    prompt.writeln('PIPELINE CONTROL OPTIONS:');
    prompt.writeln(
      '- continueNormally: Context is sufficient, proceed to response generation',
    );
    prompt.writeln(
      '- retryWithModifications: Retry context gathering with modified parameters',
    );
    prompt.writeln(
      '- skipOptionalSteps: Skip non-essential steps to optimize token usage',
    );
    prompt.writeln(
      '- gatherAdditionalContext: Specific additional context is needed',
    );
    prompt.writeln(
      '- modifySearchParameters: Adjust search/filtering parameters for better results',
    );
    prompt.writeln(
      '- discardAndRetry: Current context is poor quality, start over with different approach',
    );
    prompt.writeln();

    prompt.writeln('Respond with this JSON format:');
    prompt.writeln('{');
    prompt.writeln('  "hasEnoughContext": boolean,');
    prompt.writeln('  "confidence": number_between_0_and_1,');
    prompt.writeln(
      '  "recommendedActions": ["list", "of", "pipeline", "actions"],',
    );
    prompt.writeln('  "reasoning": "detailed_explanation_of_assessment",');
    prompt.writeln('  "contextModifications": {"key": "value"}, // optional');
    prompt.writeln('  "stepsToRetry": ["step1", "step2"], // optional');
    prompt.writeln('  "stepsToSkip": ["step1", "step2"], // optional');
    prompt.writeln('  "searchParameters": {"param": "value"}, // optional');
    prompt.writeln('  "identifiedGaps": ["gap1", "gap2"], // optional');
    prompt.writeln(
      '  "suggestions": ["suggestion1", "suggestion2"] // optional',
    );
    prompt.writeln('}');
    return prompt.toString();
  }
}
