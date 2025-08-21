import 'package:flutter/foundation.dart';
import '../../../models/chat_types.dart';
import 'verification_types.dart';

/// Tracks the complete history of pipeline steps and verification decisions
/// to prevent loops and provide context for retries
class PipelineHistoryTracker {
  final List<PipelineAttempt> _attempts = [];
  final List<VerificationDecisionRecord> _verificationDecisions = [];

  /// Record a step execution
  void recordStepExecution(
    String stepName,
    ChatStepResult result, {
    int attemptNumber = 1,
    String? reasoning,
  }) {
    final attempt = PipelineAttempt(
      stepName: stepName,
      attemptNumber: attemptNumber,
      success: result.success,
      timestamp: DateTime.now(),
      errorMessage: result.error?.message,
      reasoning: reasoning,
      resultData: _sanitizeResultData(result.data),
    );

    _attempts.add(attempt);
  }

  /// Record a verification decision
  void recordVerificationDecision(
    VerificationCheckpoint checkpoint,
    VerificationDecision decision,
    String reasoning, {
    double? confidence,
    List<String>? contextGaps,
    List<String>? selectedDishIds,
  }) {
    final record = VerificationDecisionRecord(
      checkpoint: checkpoint,
      decision: decision,
      reasoning: reasoning,
      confidence: confidence ?? 0.0,
      contextGaps: contextGaps ?? [],
      selectedDishIds: selectedDishIds ?? [],
      timestamp: DateTime.now(),
      attemptCount: _getAttemptCount(),
    );

    _verificationDecisions.add(record);
  }

  /// Generate a comprehensive summary for step context
  String generateStepContextSummary({
    String? excludeStep,
    bool includeFailures = true,
    bool includeVerificationDecisions = true,
  }) {
    if (_attempts.isEmpty && _verificationDecisions.isEmpty) {
      return 'This is the first attempt at processing this request.';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== PIPELINE EXECUTION HISTORY ===');
    buffer.writeln('Total attempts: ${_getAttemptCount()}');
    buffer.writeln('');

    // Group attempts by step name
    final groupedAttempts = <String, List<PipelineAttempt>>{};
    for (final attempt in _attempts) {
      if (excludeStep != null && attempt.stepName == excludeStep) continue;

      groupedAttempts.putIfAbsent(attempt.stepName, () => []).add(attempt);
    }

    // Report step execution history
    if (groupedAttempts.isNotEmpty) {
      buffer.writeln('STEP EXECUTION HISTORY:');
      groupedAttempts.forEach((stepName, attempts) {
        buffer.writeln('');
        buffer.writeln('📝 $stepName (${attempts.length} attempts):');

        for (int i = 0; i < attempts.length; i++) {
          final attempt = attempts[i];
          final status = attempt.success ? '✅ SUCCESS' : '❌ FAILED';
          buffer.writeln('   Attempt ${attempt.attemptNumber}: $status');

          if (attempt.reasoning?.isNotEmpty == true) {
            buffer.writeln('   Reasoning: ${attempt.reasoning}');
          }

          if (!attempt.success && attempt.errorMessage?.isNotEmpty == true) {
            buffer.writeln('   Error: ${attempt.errorMessage}');
          }

          if (attempt.resultData.isNotEmpty) {
            buffer.writeln(
              '   Key results: ${_summarizeResultData(attempt.resultData)}',
            );
          }
        }
      });
      buffer.writeln('');
    }

    // Report verification decisions
    if (includeVerificationDecisions && _verificationDecisions.isNotEmpty) {
      buffer.writeln('VERIFICATION DECISIONS:');
      for (int i = 0; i < _verificationDecisions.length; i++) {
        final decision = _verificationDecisions[i];
        buffer.writeln('');
        buffer.writeln('🔍 Decision ${i + 1} (${decision.checkpoint.name}):');
        buffer.writeln('   Action: ${decision.decision.name}');
        buffer.writeln(
          '   Confidence: ${(decision.confidence * 100).toStringAsFixed(1)}%',
        );
        buffer.writeln('   Reasoning: ${decision.reasoning}');

        if (decision.contextGaps.isNotEmpty) {
          buffer.writeln('   Context gaps: ${decision.contextGaps.join(", ")}');
        }

        if (decision.selectedDishIds.isNotEmpty) {
          buffer.writeln(
            '   Selected dishes: ${decision.selectedDishIds.join(", ")}',
          );
        }

        buffer.writeln(
          '   Attempt count at decision: ${decision.attemptCount}',
        );
      }
      buffer.writeln('');
    }

    // Provide recommendations based on history
    buffer.writeln('RECOMMENDATIONS BASED ON HISTORY:');
    buffer.writeln(_generateRecommendations());
    buffer.writeln('');

    buffer.writeln('=== END PIPELINE HISTORY ===');
    buffer.writeln('');

    return buffer.toString();
  }

  /// Check if we're in a potential loop scenario
  bool isLikelyInLoop() {
    if (_attempts.length < 6) {
      return false; // Need at least 6 steps to detect loops
    }

    // Check for repeated step patterns
    final recentSteps =
        _attempts.length >= 6
            ? _attempts
                .sublist(_attempts.length - 6)
                .map((a) => a.stepName)
                .toList()
            : _attempts.map((a) => a.stepName).toList();

    // Look for repeating patterns
    for (int patternLength = 2; patternLength <= 3; patternLength++) {
      if (recentSteps.length >= patternLength * 2) {
        final pattern1 = recentSteps.sublist(0, patternLength);
        final pattern2 = recentSteps.sublist(patternLength, patternLength * 2);

        if (_listsEqual(pattern1, pattern2)) {
          return true; // Found repeating pattern
        }
      }
    }

    // Check for excessive retries of the same step
    final stepCounts = <String, int>{};
    for (final attempt in _attempts) {
      stepCounts[attempt.stepName] = (stepCounts[attempt.stepName] ?? 0) + 1;
    }

    return stepCounts.values.any((count) => count > 20);
  }

  /// Check if thinking step is producing identical results
  bool isThinkingStepRepeating() {
    final thinkingAttempts =
        _attempts.where((a) => a.stepName == 'thinking' && a.success).toList();

    // Only detect loops after 20+ attempts - be very permissive
    if (thinkingAttempts.length >= 20) {
      debugPrint(
        '🚨 LOOP DETECTION: ${thinkingAttempts.length} thinking attempts detected - very high threshold reached!',
      );
      return true; // Force strategy switch only after 20+ attempts
    }

    if (thinkingAttempts.length < 2) return false;

    // Compare the last two thinking results
    final lastThinking = thinkingAttempts.last;
    final secondLastThinking = thinkingAttempts[thinkingAttempts.length - 2];

    final lastResult =
        lastThinking.resultData['thinkingResult'] as Map<String, dynamic>?;
    final secondLastResult =
        secondLastThinking.resultData['thinkingResult']
            as Map<String, dynamic>?;

    if (lastResult == null || secondLastResult == null) return false;

    // Compare critical thinking elements
    final lastIntent = lastResult['userIntent'] as String? ?? '';
    final secondLastIntent = secondLastResult['userIntent'] as String? ?? '';

    final lastRequirements = lastResult['responseRequirements'] as List? ?? [];
    final secondLastRequirements =
        secondLastResult['responseRequirements'] as List? ?? [];

    final lastContextReqs = lastResult['contextRequirements'] as Map? ?? {};
    final secondLastContextReqs =
        secondLastResult['contextRequirements'] as Map? ?? {};

    // Check if thinking results are essentially identical
    final isIdentical =
        lastIntent == secondLastIntent &&
        _listsEqual(
          lastRequirements.cast<String>(),
          secondLastRequirements.cast<String>(),
        ) &&
        _mapsEqual(
          lastContextReqs.cast<String, dynamic>(),
          secondLastContextReqs.cast<String, dynamic>(),
        );

    if (isIdentical) {
      debugPrint(
        '🔄 IDENTICAL THINKING DETECTED: Same intent, requirements, and context',
      );
    }

    return isIdentical;
  }

  /// Generate a strategy switch recommendation when thinking is repeating
  Map<String, dynamic> generateStrategySwitchRecommendation(
    String userMessage,
  ) {
    final thinkingAttempts =
        _attempts.where((a) => a.stepName == 'thinking' && a.success).toList();

    if (thinkingAttempts.isEmpty) {
      return {
        'shouldSwitch': false,
        'reasoning': 'No previous thinking attempts found',
      };
    }

    final lastThinking = thinkingAttempts.last;
    final lastResult =
        lastThinking.resultData['thinkingResult'] as Map<String, dynamic>?;

    if (lastResult == null) {
      return {
        'shouldSwitch': false,
        'reasoning': 'Could not extract thinking result',
      };
    }

    final currentContextReqs =
        lastResult['contextRequirements'] as Map<String, dynamic>? ?? {};
    final currentResponseReqs =
        lastResult['responseRequirements'] as List<dynamic>? ?? [];
    final currentIntent = lastResult['userIntent'] as String? ?? '';

    // Analyze the strategy switch based on what was tried before
    final switchRecommendation = _analyzeStrategySwitchNeeded(
      userMessage,
      currentContextReqs,
      currentResponseReqs.cast<String>(),
      currentIntent,
    );

    return {
      'shouldSwitch': true,
      'originalStrategy': {
        'userIntent': currentIntent,
        'contextRequirements': currentContextReqs,
        'responseRequirements': currentResponseReqs,
      },
      'newStrategy': switchRecommendation,
      'reasoning': switchRecommendation['reasoning'],
    };
  }

  /// Analyze what strategy switch is needed based on previous attempts
  Map<String, dynamic> _analyzeStrategySwitchNeeded(
    String userMessage,
    Map<String, dynamic> currentContextReqs,
    List<String> currentResponseReqs,
    String currentIntent,
  ) {
    final userMessageLower = userMessage.toLowerCase();
    final dishRelatedKeywords = [
      'dish',
      'recipe',
      'food',
      'meal',
      'cook',
      'eat',
      'schnitzel',
      'pasta',
      'salad',
    ];
    final isDishRequest = dishRelatedKeywords.any(
      (keyword) => userMessageLower.contains(keyword),
    );

    // Strategy 1: If currently searching existing dishes, switch to creation
    if (currentContextReqs['needsExistingDishes'] == true &&
        !currentContextReqs['needsInfoOnDishCreation']) {
      return {
        'userIntent':
            'User wants to create a new $userMessage dish since existing dishes may not match their specific needs',
        'contextRequirements': {
          ...currentContextReqs,
          'needsExistingDishes': false,
          'needsInfoOnDishCreation': true,
        },
        'responseRequirements': ['dish_creation', 'recipe_suggestions'],
        'reasoning':
            'Previous attempts searched existing dishes without success. Switching to dish creation mode.',
      };
    }

    // Strategy 2: If currently creating dishes, try to find related existing ones
    if (currentContextReqs['needsInfoOnDishCreation'] == true &&
        !currentContextReqs['needsExistingDishes']) {
      return {
        'userIntent':
            'User wants suggestions for $userMessage from existing dishes or similar alternatives',
        'contextRequirements': {
          ...currentContextReqs,
          'needsExistingDishes': true,
          'needsInfoOnDishCreation': false,
        },
        'responseRequirements': ['recipe_suggestions', 'meal_planning'],
        'reasoning':
            'Previous attempts focused on dish creation. Switching to search existing dishes for inspiration.',
      };
    }

    // Strategy 3: If both dish strategies tried, switch to nutrition advice
    if ((currentContextReqs['needsExistingDishes'] == true ||
            currentContextReqs['needsInfoOnDishCreation'] == true) &&
        isDishRequest) {
      return {
        'userIntent':
            'User wants nutritional guidance and healthy eating advice related to $userMessage',
        'contextRequirements': {
          'needsNutritionAdvice': true,
          'needsUserProfile': true,
          'needsTodaysNutrition': true,
          'needsConversationHistory': true,
        },
        'responseRequirements': ['general_nutrition_advice', 'meal_planning'],
        'reasoning':
            'Previous attempts tried dish-focused strategies. Switching to nutrition advice approach.',
      };
    }

    // Strategy 4: If nutrition advice was tried, go back to comprehensive dish approach
    if (currentContextReqs['needsNutritionAdvice'] == true) {
      return {
        'userIntent':
            'User wants comprehensive help with $userMessage including both existing options and new creation possibilities',
        'contextRequirements': {
          'needsExistingDishes': true,
          'needsInfoOnDishCreation': true,
          'needsUserProfile': true,
          'needsConversationHistory': true,
        },
        'responseRequirements': [
          'dish_creation',
          'recipe_suggestions',
          'nutrition_information',
        ],
        'reasoning':
            'Previous attempts tried specific strategies. Switching to comprehensive approach with all dish options.',
      };
    }

    // Strategy 5: If it's not clearly a dish request, try broader interpretation
    if (!isDishRequest) {
      return {
        'userIntent':
            'User has a general nutrition or food-related question about $userMessage',
        'contextRequirements': {
          'needsNutritionAdvice': true,
          'needsConversationHistory': true,
          'needsUserProfile': false,
        },
        'responseRequirements': ['general_nutrition_advice'],
        'reasoning':
            'Request may not be dish-specific. Switching to general nutrition advice approach.',
      };
    }

    // Default fallback strategy
    return {
      'userIntent':
          'User needs flexible assistance with $userMessage - trying comprehensive approach',
      'contextRequirements': {
        'needsExistingDishes': true,
        'needsInfoOnDishCreation': true,
        'needsNutritionAdvice': true,
        'needsConversationHistory': true,
      },
      'responseRequirements': [
        'dish_creation',
        'recipe_suggestions',
        'general_nutrition_advice',
      ],
      'reasoning':
          'Previous strategies did not work. Trying comprehensive approach with all available options.',
    };
  }

  /// Get the current attempt count
  int getAttemptCount() {
    return _attempts.isEmpty
        ? 1
        : _attempts.map((a) => a.attemptNumber).reduce((a, b) => a > b ? a : b);
  }

  /// Get the number of times thinking step was executed specifically
  int getThinkingStepAttemptCount() {
    return _attempts.where((attempt) => attempt.stepName == 'thinking').length;
  }

  /// Get the total number of steps executed (including all attempts and retries)
  int getTotalStepsExecuted() {
    return _attempts.length;
  }

  /// Get the current attempt count (legacy method name for internal use)
  int _getAttemptCount() => getAttemptCount();

  /// Sanitize result data for storage (remove sensitive/large data)
  Map<String, dynamic> _sanitizeResultData(Map<String, dynamic>? data) {
    if (data == null) return {};

    final sanitized = <String, dynamic>{};

    data.forEach((key, value) {
      if (key == 'thinkingResult' && value is Map) {
        // Keep thinkingResult as a proper map to avoid casting issues
        sanitized[key] = {
          'userIntent': value['userIntent'],
          'responseRequirements': value['responseRequirements'],
          'contextRequirements':
              value['contextRequirements'], // Keep as Map, don't convert to string
        };
      } else if (key == 'contextData' && value is Map) {
        sanitized[key] = {
          'dishCount': (value['existingDishes'] as List?)?.length ?? 0,
          'userProfileAvailable': value['userProfile'] != null,
          'nutritionDataAvailable': value['nutritionSummary'] != null,
        };
      } else if (key == 'dishes' && value is List) {
        sanitized[key] = {'count': value.length};
      } else if (value is String && value.length < 200) {
        sanitized[key] = value;
      } else if (value is num || value is bool) {
        sanitized[key] = value;
      }
    });

    return sanitized;
  }

  /// Summarize result data for display
  String _summarizeResultData(Map<String, dynamic> data) {
    final summaries = <String>[];

    data.forEach((key, value) {
      if (key == 'thinkingResult' && value is Map) {
        summaries.add('Intent: ${value['userIntent']}');
      } else if (key == 'contextData' && value is Map) {
        summaries.add('Dishes: ${value['dishCount'] ?? 0}');
      } else if (key == 'dishes' && value is Map) {
        summaries.add('Created ${value['count']} dishes');
      } else if (value is String && value.length < 50) {
        summaries.add('$key: $value');
      }
    });

    return summaries.isEmpty ? 'No key results' : summaries.join(', ');
  }

  /// Generate recommendations based on execution history
  String _generateRecommendations() {
    final recommendations = <String>[];

    // Check for repeated failures
    final failedSteps =
        _attempts.where((a) => !a.success).map((a) => a.stepName).toSet();
    if (failedSteps.isNotEmpty) {
      recommendations.add(
        '• Steps that have failed before: ${failedSteps.join(", ")} - consider alternative approaches',
      );
    }

    // Check for excessive verification decisions
    final restartDecisions =
        _verificationDecisions
            .where(
              (d) =>
                  d.decision == VerificationDecision.restartFresh ||
                  d.decision == VerificationDecision.restartThinking,
            )
            .length;
    if (restartDecisions > 2) {
      recommendations.add(
        '• Multiple restart decisions made - consider if the user request is fundamentally unclear',
      );
    }

    // Check for dish selection patterns
    final dishSelections = _verificationDecisions.where(
      (d) => d.decision == VerificationDecision.selectExistingDishes,
    );
    if (dishSelections.isNotEmpty) {
      recommendations.add(
        '• Previous attempts selected existing dishes - current approach should consider this precedent',
      );
    }

    // Check for context gathering issues
    final contextAttempts =
        _attempts.where((a) => a.stepName == 'context_gathering').length;
    if (contextAttempts > 2) {
      recommendations.add(
        '• Context gathering attempted multiple times - may need to accept limited context',
      );
    }

    // Loop detection recommendation
    if (isLikelyInLoop()) {
      recommendations.add(
        '• LOOP DETECTED: Consider approving current response or selecting existing dishes instead of retrying',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('• No specific issues detected in previous attempts');
    }

    return recommendations.join('\n');
  }

  /// Helper method to compare lists
  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  /// Clear all history (for new requests)
  void clear() {
    _attempts.clear();
    _verificationDecisions.clear();
  }

  /// Get summary of what was tried before for a specific step
  String getStepSpecificHistory(String stepName) {
    final stepAttempts =
        _attempts.where((a) => a.stepName == stepName).toList();
    if (stepAttempts.isEmpty) {
      return 'This is the first attempt at the $stepName step.';
    }

    final buffer = StringBuffer();
    buffer.writeln('PREVIOUS $stepName ATTEMPTS:');

    for (final attempt in stepAttempts) {
      final status = attempt.success ? 'succeeded' : 'failed';
      buffer.writeln('• Attempt ${attempt.attemptNumber}: $status');
      if (attempt.reasoning?.isNotEmpty == true) {
        buffer.writeln('  Reasoning: ${attempt.reasoning}');
      }
      if (!attempt.success && attempt.errorMessage?.isNotEmpty == true) {
        buffer.writeln('  Error: ${attempt.errorMessage}');
      }
    }

    return buffer.toString();
  }

  /// Helper method to compare two maps for equality
  bool _mapsEqual<K, V>(Map<K, V>? map1, Map<K, V>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      final value1 = map1[key];
      final value2 = map2[key];

      if (value1 is List && value2 is List) {
        // Handle lists comparison - both values are non-null lists
        if (value1.length != value2.length) return false;
        for (int i = 0; i < value1.length; i++) {
          if (value1[i] != value2[i]) return false;
        }
      } else if (value1 != value2) {
        return false;
      }
    }

    return true;
  }
}

/// Record of a single pipeline step attempt
class PipelineAttempt {
  final String stepName;
  final int attemptNumber;
  final bool success;
  final DateTime timestamp;
  final String? errorMessage;
  final String? reasoning;
  final Map<String, dynamic> resultData;

  const PipelineAttempt({
    required this.stepName,
    required this.attemptNumber,
    required this.success,
    required this.timestamp,
    this.errorMessage,
    this.reasoning,
    this.resultData = const {},
  });
}

/// Record of a verification decision
class VerificationDecisionRecord {
  final VerificationCheckpoint checkpoint;
  final VerificationDecision decision;
  final String reasoning;
  final double confidence;
  final List<String> contextGaps;
  final List<String> selectedDishIds;
  final DateTime timestamp;
  final int attemptCount;

  const VerificationDecisionRecord({
    required this.checkpoint,
    required this.decision,
    required this.reasoning,
    required this.confidence,
    required this.contextGaps,
    required this.selectedDishIds,
    required this.timestamp,
    required this.attemptCount,
  });
}
