import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart';
import '../openai_service.dart';

/// Handles image processing and analysis for chat messages
class ImageProcessingStep extends AgentStep {
  final OpenAIService _openaiService;

  ImageProcessingStep({required OpenAIService openaiService})
    : _openaiService = openaiService;

  @override
  String get stepName => 'image_processing';

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      debugPrint('📸 ImageProcessingStep: Starting image processing');

      final imageUri = input.imageUri;
      if (imageUri == null || imageUri.isEmpty) {
        debugPrint('ℹ️ ImageProcessingStep: No image to process');
        return ChatStepResult.success(
          stepName: stepName,
          data: {
            'hasImage': false,
            'imageDescription': null,
            'detectedDishes': <String>[],
            'detectedIngredients': <String>[],
          },
        );
      }

      debugPrint('📸 ImageProcessingStep: Processing image: $imageUri');

      // Create image analysis prompt
      final analysisPrompt = _buildImageAnalysisPrompt(input.userMessage);

      // For now, we'll prepare for future vision API support
      // TODO: Implement actual image analysis when OpenAI service supports vision
      debugPrint('📸 ImageProcessingStep: Vision API not yet implemented');

      // Return placeholder results for now
      final result = {
        'hasImage': true,
        'imageUri': imageUri,
        'imageDescription':
            'Image uploaded (analysis pending vision API implementation)',
        'detectedDishes': <String>[],
        'detectedIngredients': <String>[],
        'analysisPrompt': analysisPrompt,
      };

      debugPrint('📸 ImageProcessingStep: Completed image processing');
      return ChatStepResult.success(stepName: stepName, data: result);
    } catch (error) {
      debugPrint('❌ ImageProcessingStep: Error during execution: $error');

      return ChatStepResult.failure(
        stepName: stepName,
        error: ChatAgentError(
          type: ChatErrorType.imageProcessingError,
          message: 'Failed to process image',
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
        message: 'Image processing step failed',
        error: result.error,
      );
    }

    final hasImage = result.data!['hasImage'] as bool;
    final issues = <String>[];
    final suggestions = <String>[];

    if (hasImage) {
      final imageUri = result.data!['imageUri'] as String?;
      final imageDescription = result.data!['imageDescription'] as String?;

      if (imageUri == null || imageUri.isEmpty) {
        issues.add(
          'Image processing claimed image present but no URI provided',
        );
        suggestions.add('Ensure image URI is properly captured');
      }
      if (imageDescription == null || imageDescription.isEmpty) {
        issues.add('No image description generated');
        suggestions.add('Implement image description generation');
      }
      // Check for reasonable detected content
      final detectedDishes = result.data!['detectedDishes'] as List<String>?;
      final detectedIngredients =
          result.data!['detectedIngredients'] as List<String>?;
      if ((detectedDishes?.isEmpty ?? true) &&
          (detectedIngredients?.isEmpty ?? true)) {
        // This might be expected if vision API isn't implemented yet
        suggestions.add('Consider implementing vision-based content detection');
      }
    }

    if (issues.isEmpty) {
      return ChatStepVerificationResult.valid();
    } else {
      return ChatStepVerificationResult.invalid(
        message: 'Image processing verification found issues',
        error: null,
      );
    }
  }

  /// Builds prompt for image analysis (for future vision API integration)
  String _buildImageAnalysisPrompt(String userMessage) {
    final prompt = StringBuffer();

    prompt.writeln('You are a nutrition expert analyzing a food image. ');
    prompt.writeln('The user message is: "$userMessage"');
    prompt.writeln();
    prompt.writeln('Please analyze the image and provide:');
    prompt.writeln('1. A detailed description of what you see');
    prompt.writeln('2. Any dishes or food items visible');
    prompt.writeln('3. Individual ingredients you can identify');
    prompt.writeln('4. Estimated portion sizes if possible');
    prompt.writeln('5. Any nutritional observations');
    prompt.writeln();
    prompt.writeln('Respond in JSON format:');
    prompt.writeln('{');
    prompt.writeln('  "description": "detailed description of the image",');
    prompt.writeln('  "detectedDishes": ["list", "of", "dishes"],');
    prompt.writeln('  "detectedIngredients": ["list", "of", "ingredients"],');
    prompt.writeln(
      '  "portionEstimates": {"dish1": "estimate", "dish2": "estimate"},',
    );
    prompt.writeln('  "nutritionalNotes": "observations about nutrition"');
    prompt.writeln('}');

    return prompt.toString();
  }
}
