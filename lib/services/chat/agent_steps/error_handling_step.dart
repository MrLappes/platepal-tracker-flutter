import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart';

/// Handles graceful error recovery and fallback strategies for chat agent
class ErrorHandlingStep extends AgentStep {
  ErrorHandlingStep();

  @override
  String get stepName => 'error_handling';

  @override
  Future<ChatStepResult> execute(ChatStepInput input) async {
    try {
      debugPrint('🔧 ErrorHandlingStep: Starting error handling');

      final failedStep = input.metadata!['failedStep'] as String;
      final originalError = input.metadata!['originalError'] as ChatAgentError;
      final retryCount = input.metadata!['retryCount'] as int? ?? 0;
      final contextSize = input.metadata!['contextSize'] as int? ?? 0;

      debugPrint('🔧 Handling error from step: $failedStep');
      debugPrint('   Error type: ${originalError.type}');
      debugPrint('   Retry count: $retryCount');
      debugPrint('   Context size: $contextSize');

      // Determine recovery strategy
      final recoveryStrategy = _determineRecoveryStrategy(
        originalError,
        failedStep,
        retryCount,
        contextSize,
      );

      debugPrint('🔧 Using recovery strategy: ${recoveryStrategy.type}');

      // Execute recovery
      final recoveryResult = await _executeRecoveryStrategy(
        recoveryStrategy,
        input,
        originalError,
      );

      debugPrint('🔧 ErrorHandlingStep: Completed error handling');
      return ChatStepResult.success(
        stepName: stepName,
        data: {
          'recoveryStrategy': recoveryStrategy,
          'recoveryResult': recoveryResult,
          'originalError': originalError,
          'failedStep': failedStep,
        },
      );
    } catch (error) {
      debugPrint(
        '❌ ErrorHandlingStep: Critical error during error handling: $error',
      );

      return ChatStepResult.failure(
        stepName: stepName,
        error: ChatAgentError(
          type: ChatErrorType.criticalError,
          message: 'Error handling failed',
          details: error.toString(),
          retryable: false,
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
        message: 'Error handling step failed catastrophically',
        error: result.error,
      );
    }

    final recoveryStrategy =
        result.data!['recoveryStrategy'] as ErrorRecoveryStrategy;
    final recoveryResult =
        result.data!['recoveryResult'] as ErrorRecoveryResult;

    final issues = <String>[];
    final suggestions = <String>[];

    // Verify recovery strategy was appropriate
    if (recoveryStrategy.type == ErrorRecoveryType.none &&
        recoveryResult.success == false) {
      issues.add('No recovery strategy applied to recoverable error');
      suggestions.add('Implement recovery strategies for common error types');
    }

    // Check if recovery was successful
    if (!recoveryResult.success && recoveryStrategy.retryable) {
      suggestions.add('Consider alternative recovery strategies');
    }

    // Verify fallback response quality
    if (recoveryResult.fallbackResponse != null) {
      if (recoveryResult.fallbackResponse!.replyText.trim().isEmpty) {
        issues.add('Fallback response has empty reply text');
        suggestions.add('Ensure fallback responses are meaningful');
      }
    }

    if (issues.isEmpty) {
      return ChatStepVerificationResult.valid();
    } else {
      return ChatStepVerificationResult.invalid(
        message: 'Error handling verification found issues',
        error: null,
      );
    }
  }

  /// Determines the appropriate recovery strategy for an error
  ErrorRecoveryStrategy _determineRecoveryStrategy(
    ChatAgentError error,
    String failedStep,
    int retryCount,
    int contextSize,
  ) {
    switch (error.type) {
      case ChatErrorType.contextLength:
        return ErrorRecoveryStrategy(
          type: ErrorRecoveryType.contextReduction,
          retryable: true,
          parameters: {
            'reductionFactor': _calculateReductionFactor(contextSize),
            'maxRetries': 2,
          },
        );

      case ChatErrorType.networkError:
        return ErrorRecoveryStrategy(
          type: ErrorRecoveryType.retry,
          retryable: retryCount < 3,
          parameters: {
            'delayMs': _calculateBackoffDelay(retryCount),
            'maxRetries': 3,
          },
        );

      case ChatErrorType.apiError:
        if (retryCount < 2) {
          return ErrorRecoveryStrategy(
            type: ErrorRecoveryType.retry,
            retryable: true,
            parameters: {
              'delayMs': _calculateBackoffDelay(retryCount),
              'maxRetries': 2,
            },
          );
        } else {
          return ErrorRecoveryStrategy(
            type: ErrorRecoveryType.fallback,
            retryable: false,
            parameters: {'fallbackType': 'generic'},
          );
        }

      case ChatErrorType.parseError:
        if (retryCount < 1) {
          return ErrorRecoveryStrategy(
            type: ErrorRecoveryType.retry,
            retryable: true,
            parameters: {
              'delayMs': 1000,
              'maxRetries': 1,
              'adjustTemperature': true,
            },
          );
        } else {
          return ErrorRecoveryStrategy(
            type: ErrorRecoveryType.fallback,
            retryable: false,
            parameters: {'fallbackType': 'parsing'},
          );
        }

      case ChatErrorType.processingError:
        return ErrorRecoveryStrategy(
          type: ErrorRecoveryType.skipStep,
          retryable: true,
          parameters: {'skipReason': 'processing_error'},
        );

      case ChatErrorType.verificationError:
        return ErrorRecoveryStrategy(
          type: ErrorRecoveryType.continueWithWarning,
          retryable: false,
          parameters: {'warningMessage': 'Verification failed but continuing'},
        );

      case ChatErrorType.imageProcessingError:
        return ErrorRecoveryStrategy(
          type: ErrorRecoveryType.skipStep,
          retryable: true,
          parameters: {'skipReason': 'image_processing_failed'},
        );

      case ChatErrorType.criticalError:
        return ErrorRecoveryStrategy(
          type: ErrorRecoveryType.fallback,
          retryable: false,
          parameters: {'fallbackType': 'critical'},
        );

      case ChatErrorType.unknown:
        if (retryCount < 1) {
          return ErrorRecoveryStrategy(
            type: ErrorRecoveryType.retry,
            retryable: true,
            parameters: {'delayMs': 2000, 'maxRetries': 1},
          );
        } else {
          return ErrorRecoveryStrategy(
            type: ErrorRecoveryType.fallback,
            retryable: false,
            parameters: {'fallbackType': 'unknown'},
          );
        }

      case ChatErrorType.missingPrerequisite:
        return ErrorRecoveryStrategy(
          type: ErrorRecoveryType.fallback,
          retryable: false,
          parameters: {'fallbackType': 'missing_prerequisite'},
        );
    }
  }

  /// Executes the determined recovery strategy
  Future<ErrorRecoveryResult> _executeRecoveryStrategy(
    ErrorRecoveryStrategy strategy,
    ChatStepInput input,
    ChatAgentError originalError,
  ) async {
    try {
      switch (strategy.type) {
        case ErrorRecoveryType.retry:
          return await _executeRetryStrategy(strategy, input);

        case ErrorRecoveryType.contextReduction:
          return await _executeContextReductionStrategy(strategy, input);

        case ErrorRecoveryType.fallback:
          return await _executeFallbackStrategy(strategy, input, originalError);

        case ErrorRecoveryType.skipStep:
          return await _executeSkipStepStrategy(strategy, input);

        case ErrorRecoveryType.continueWithWarning:
          return await _executeContinueWithWarningStrategy(strategy, input);

        case ErrorRecoveryType.none:
          return ErrorRecoveryResult(
            success: false,
            strategy: strategy,
            message: 'No recovery strategy available',
          );
      }
    } catch (error) {
      debugPrint('❌ Error executing recovery strategy: $error');
      return ErrorRecoveryResult(
        success: false,
        strategy: strategy,
        message: 'Recovery strategy execution failed: $error',
      );
    }
  }

  Future<ErrorRecoveryResult> _executeRetryStrategy(
    ErrorRecoveryStrategy strategy,
    ChatStepInput input,
  ) async {
    final delayMs = strategy.parameters['delayMs'] as int? ?? 1000;

    debugPrint('🔧 Executing retry strategy with ${delayMs}ms delay');
    await Future.delayed(Duration(milliseconds: delayMs));

    return ErrorRecoveryResult(
      success: true,
      strategy: strategy,
      message: 'Retry strategy applied',
      shouldRetry: true,
    );
  }

  Future<ErrorRecoveryResult> _executeContextReductionStrategy(
    ErrorRecoveryStrategy strategy,
    ChatStepInput input,
  ) async {
    final reductionFactor =
        strategy.parameters['reductionFactor'] as double? ?? 0.5;

    debugPrint(
      '🔧 Executing context reduction strategy with factor: $reductionFactor',
    );

    return ErrorRecoveryResult(
      success: true,
      strategy: strategy,
      message: 'Context reduction applied',
      shouldRetry: true,
      modifiedInput: input.copyWith(
        metadata: {
          ...input.metadata ?? {},
          'contextReductionFactor': reductionFactor,
        },
      ),
    );
  }

  Future<ErrorRecoveryResult> _executeFallbackStrategy(
    ErrorRecoveryStrategy strategy,
    ChatStepInput input,
    ChatAgentError originalError,
  ) async {
    final fallbackType =
        strategy.parameters['fallbackType'] as String? ?? 'generic';

    debugPrint('🔧 Executing fallback strategy: $fallbackType');

    final fallbackResponse = _createFallbackResponse(
      fallbackType,
      originalError,
      localizedFallbacks:
          input.metadata?['localizedFallbacks'] as Map<String, dynamic>?,
    );

    return ErrorRecoveryResult(
      success: true,
      strategy: strategy,
      message: 'Fallback response generated',
      fallbackResponse: fallbackResponse,
    );
  }

  Future<ErrorRecoveryResult> _executeSkipStepStrategy(
    ErrorRecoveryStrategy strategy,
    ChatStepInput input,
  ) async {
    final skipReason = strategy.parameters['skipReason'] as String? ?? 'error';

    debugPrint('🔧 Executing skip step strategy: $skipReason');

    return ErrorRecoveryResult(
      success: true,
      strategy: strategy,
      message: 'Step skipped due to: $skipReason',
      shouldSkipStep: true,
    );
  }

  Future<ErrorRecoveryResult> _executeContinueWithWarningStrategy(
    ErrorRecoveryStrategy strategy,
    ChatStepInput input,
  ) async {
    final warningMessage =
        strategy.parameters['warningMessage'] as String? ?? 'Warning occurred';

    debugPrint('🔧 Executing continue with warning strategy: $warningMessage');

    return ErrorRecoveryResult(
      success: true,
      strategy: strategy,
      message: warningMessage,
      shouldContinue: true,
    );
  }

  /// Creates a fallback response based on error type
  ChatResponse _createFallbackResponse(
    String fallbackType,
    ChatAgentError originalError, {
    Map<String, dynamic>? localizedFallbacks,
  }) {
    String? loc(String key) => localizedFallbacks?[key] as String?;
    switch (fallbackType) {
      case 'parsing':
        return ChatResponse(
          replyText:
              loc('parsing') ??
              "I apologize, but I'm having trouble processing your request right now. Could you please try rephrasing your question?",
          metadata: {'fallbackReason': 'parsing_error'},
        );

      case 'critical':
        return ChatResponse(
          replyText:
              loc('critical') ??
              "I'm experiencing some technical difficulties at the moment. Please try again in a few moments.",
          metadata: {'fallbackReason': 'critical_error'},
        );

      case 'network':
        return ChatResponse(
          replyText:
              loc('network') ??
              "I'm having trouble connecting to my knowledge base right now. Please check your internet connection and try again.",
          metadata: {'fallbackReason': 'network_error'},
        );

      case 'context':
        return ChatResponse(
          replyText:
              loc('context') ??
              'Your request contains a lot of information. Could you please break it down into smaller, more specific questions?',
          metadata: {'fallbackReason': 'context_length'},
        );

      case 'generic':
      default:
        return ChatResponse(
          replyText:
              loc('generic') ??
              'I apologize, but I encountered an unexpected issue. Please try again.',
          metadata: {'fallbackReason': 'generic_error'},
        );
    }
  }

  /// Calculates exponential backoff delay for retries
  int _calculateBackoffDelay(int retryCount) {
    final baseDelay = 1000; // 1 second
    final maxDelay = 30000; // 30 seconds

    final delay = baseDelay * pow(2, retryCount).toInt();
    return min(delay, maxDelay);
  }

  /// Calculates context reduction factor based on current size
  double _calculateReductionFactor(int contextSize) {
    if (contextSize > 100000) {
      return 0.3; // Aggressive reduction
    } else if (contextSize > 50000) {
      return 0.5; // Moderate reduction
    } else if (contextSize > 20000) {
      return 0.7; // Light reduction
    } else {
      return 0.8; // Minimal reduction
    }
  }
}
