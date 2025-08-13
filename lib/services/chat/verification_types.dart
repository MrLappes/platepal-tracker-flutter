import '../../models/chat_types.dart';

/// Verification checkpoint types for the deep search verification system
enum VerificationCheckpoint {
  postExecution, // After all thinking-planned steps execute
  postResponse, // After response generation and dish processing
}

/// Verification decisions that can be made at each checkpoint
enum VerificationDecision {
  continueNormally, // Proceed normally
  retryWithAdditions, // Keep existing data, gather more context
  restartFresh, // Start over with different approach
  approve, // Output is good, finish
  fixDishes, // Fix dish ingredients/IDs only
  retryResponse, // Regenerate response with same context
  restartThinking, // Start over with instructions
  selectExistingDishes, // Select specific existing dishes instead of creating new ones
}

/// Result of a verification checkpoint
class VerificationResult {
  final VerificationDecision decision;
  final double confidence;
  final String reasoning;
  final List<String> contextGaps;
  final List<String> responseIssues;
  final List<String> dishIssues;
  final String? summary;
  final List<String> additionalContext;
  final Map<String, dynamic> dishFixes;
  final List<String> missingRequirements;
  final List<String> selectedDishIds;

  VerificationResult({
    required this.decision,
    required this.confidence,
    required this.reasoning,
    this.contextGaps = const [],
    this.responseIssues = const [],
    this.dishIssues = const [],
    this.summary,
    this.additionalContext = const [],
    this.dishFixes = const {},
    this.missingRequirements = const [],
    this.selectedDishIds = const [],
  });

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      decision: _parseDecision(json['decision']),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      reasoning: json['reasoning'] as String? ?? '',
      contextGaps: List<String>.from(json['contextGaps'] ?? []),
      responseIssues: List<String>.from(json['responseIssues'] ?? []),
      dishIssues: List<String>.from(json['dishIssues'] ?? []),
      summary: json['summary'] as String?,
      additionalContext: List<String>.from(json['additionalContext'] ?? []),
      dishFixes: Map<String, dynamic>.from(json['dishFixes'] ?? {}),
      missingRequirements: List<String>.from(json['missingRequirements'] ?? []),
      selectedDishIds: List<String>.from(json['selectedDishIds'] ?? []),
    );
  }

  static VerificationDecision _parseDecision(dynamic decision) {
    if (decision is VerificationDecision) return decision;
    if (decision is String) {
      switch (decision.trim().toLowerCase()) {
        case 'continue':
        case 'continuenormally':
        case 'continue_normally':
          return VerificationDecision.continueNormally;
        case 'retrywithadditions':
        case 'retry_with_additions':
          return VerificationDecision.retryWithAdditions;
        case 'restartfresh':
        case 'restart_fresh':
          return VerificationDecision.restartFresh;
        case 'approve':
          return VerificationDecision.approve;
        case 'fixdishes':
        case 'fix_dishes':
          return VerificationDecision.fixDishes;
        case 'retryresponse':
        case 'retry_response':
          return VerificationDecision.retryResponse;
        case 'restartthinking':
        case 'restart_thinking':
          return VerificationDecision.restartThinking;
        case 'selectexistingdishes':
        case 'select_existing_dishes':
          return VerificationDecision.selectExistingDishes;
        default:
          return VerificationDecision.continueNormally;
      }
    }
    return VerificationDecision.continueNormally;
  }

  Map<String, dynamic> toJson() {
    return {
      'decision': decision.name,
      'confidence': confidence,
      'reasoning': reasoning,
      'contextGaps': contextGaps,
      'responseIssues': responseIssues,
      'dishIssues': dishIssues,
      'summary': summary,
      'additionalContext': additionalContext,
      'dishFixes': dishFixes,
      'missingRequirements': missingRequirements,
      'selectedDishIds': selectedDishIds,
    };
  }
}

/// Helper class for building verification summaries
class VerificationSummaryBuilder {
  static String buildFreshRestart(String reasoning, List<String> contextGaps) {
    return '''
CONTEXT GATHERING FAILED:
- Reason: $reasoning
- Gaps: ${contextGaps.join(', ')}

NEW STRATEGY REQUIRED:
Completely rethink the approach and focus on gathering the missing information through different methods.
''';
  }

  static String buildThinkingRestart(String reasoning, List<String> issues) {
    return '''
RESPONSE/PROCESSING ISSUES:
- Reason: $reasoning
- Problems: ${issues.join(', ')}

INSTRUCTIONS FOR NEW APPROACH:
Rethink the entire approach and create a better strategy to address these fundamental issues.
''';
  }

  static String buildAdditionsNeeded(
    String reasoning,
    List<String> additionalContext,
  ) {
    return '''
ADDITIONAL CONTEXT NEEDED:
- Current Issue: $reasoning
- Required: ${additionalContext.join(', ')}

INSTRUCTIONS:
Keep existing good data but gather the additional context listed above to complete the response.
''';
  }
}

/// Result of executing a phase with optional verification
class PhaseResult {
  final bool success;
  final bool shouldRetry;
  final String? error;
  final VerificationResult? verificationResult;
  final ChatStepInput? updatedInput;

  PhaseResult({
    required this.success,
    required this.shouldRetry,
    this.error,
    this.verificationResult,
    this.updatedInput,
  });
}
