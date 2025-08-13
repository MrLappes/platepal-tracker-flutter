import 'package:flutter/foundation.dart';

/// Types of modifications that can happen during pipeline processing
enum PipelineModificationType {
  /// Quick automatic fixes to data
  automaticFix,

  /// AI-powered validation and corrections
  aiValidation,

  /// Manual corrections or fallbacks
  manualCorrection,

  /// Data enrichment or enhancement
  dataEnrichment,

  /// Error recovery actions
  errorRecovery,

  /// Loop prevention measures
  loopPrevention,

  /// Context gathering modifications
  contextModification,

  /// Nutrition data fixes
  nutritionFix,

  /// Ingredient data modifications
  ingredientModification,

  /// Dish metadata updates
  dishMetadataUpdate,

  /// Emergency overrides
  emergencyOverride,
}

/// Severity levels for modifications
enum ModificationSeverity {
  /// Minor cosmetic changes
  low,

  /// Important but non-critical fixes
  medium,

  /// Critical fixes that prevent errors
  high,

  /// Emergency interventions
  critical,
}

/// A single modification record
class PipelineModification {
  final String id;
  final PipelineModificationType type;
  final ModificationSeverity severity;
  final String stepName;
  final String description;
  final String? technicalDetails;
  final Map<String, dynamic>? beforeData;
  final Map<String, dynamic>? afterData;
  final DateTime timestamp;
  final bool wasSuccessful;
  final String? errorMessage;

  const PipelineModification({
    required this.id,
    required this.type,
    required this.severity,
    required this.stepName,
    required this.description,
    this.technicalDetails,
    this.beforeData,
    this.afterData,
    required this.timestamp,
    this.wasSuccessful = true,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'stepName': stepName,
      'description': description,
      'technicalDetails': technicalDetails,
      'beforeData': beforeData,
      'afterData': afterData,
      'timestamp': timestamp.toIso8601String(),
      'wasSuccessful': wasSuccessful,
      'errorMessage': errorMessage,
    };
  }

  factory PipelineModification.fromJson(Map<String, dynamic> json) {
    return PipelineModification(
      id: json['id'] as String,
      type: PipelineModificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PipelineModificationType.manualCorrection,
      ),
      severity: ModificationSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => ModificationSeverity.medium,
      ),
      stepName: json['stepName'] as String,
      description: json['description'] as String,
      technicalDetails: json['technicalDetails'] as String?,
      beforeData: json['beforeData'] as Map<String, dynamic>?,
      afterData: json['afterData'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      wasSuccessful: json['wasSuccessful'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

/// Tracks all modifications that happen during pipeline processing
class PipelineModificationTracker {
  final List<PipelineModification> _modifications = [];
  static int _idCounter = 0;

  /// Record a modification
  void recordModification({
    required PipelineModificationType type,
    required ModificationSeverity severity,
    required String stepName,
    required String description,
    String? technicalDetails,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    bool wasSuccessful = true,
    String? errorMessage,
  }) {
    final modification = PipelineModification(
      id: 'mod_${++_idCounter}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      severity: severity,
      stepName: stepName,
      description: description,
      technicalDetails: technicalDetails,
      beforeData: beforeData,
      afterData: afterData,
      timestamp: DateTime.now(),
      wasSuccessful: wasSuccessful,
      errorMessage: errorMessage,
    );

    _modifications.add(modification);

    // Log to console for debugging
    final emoji = _getTypeEmoji(type);
    final severityEmoji = _getSeverityEmoji(severity);
    debugPrint('$emoji$severityEmoji [$stepName] $description');
    if (technicalDetails != null) {
      debugPrint('   Technical: $technicalDetails');
    }
  }

  /// Record an automatic fix
  void recordAutomaticFix({
    required String stepName,
    required String description,
    String? technicalDetails,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    ModificationSeverity severity = ModificationSeverity.medium,
  }) {
    recordModification(
      type: PipelineModificationType.automaticFix,
      severity: severity,
      stepName: stepName,
      description: description,
      technicalDetails: technicalDetails,
      beforeData: beforeData,
      afterData: afterData,
    );
  }

  /// Record an AI validation change
  void recordAiValidation({
    required String stepName,
    required String description,
    String? technicalDetails,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    ModificationSeverity severity = ModificationSeverity.high,
  }) {
    recordModification(
      type: PipelineModificationType.aiValidation,
      severity: severity,
      stepName: stepName,
      description: description,
      technicalDetails: technicalDetails,
      beforeData: beforeData,
      afterData: afterData,
    );
  }

  /// Record nutrition fix
  void recordNutritionFix({
    required String stepName,
    required String description,
    String? technicalDetails,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
    ModificationSeverity severity = ModificationSeverity.medium,
  }) {
    recordModification(
      type: PipelineModificationType.nutritionFix,
      severity: severity,
      stepName: stepName,
      description: description,
      technicalDetails: technicalDetails,
      beforeData: beforeData,
      afterData: afterData,
    );
  }

  /// Record emergency override
  void recordEmergencyOverride({
    required String stepName,
    required String description,
    String? technicalDetails,
    Map<String, dynamic>? beforeData,
    Map<String, dynamic>? afterData,
  }) {
    recordModification(
      type: PipelineModificationType.emergencyOverride,
      severity: ModificationSeverity.critical,
      stepName: stepName,
      description: description,
      technicalDetails: technicalDetails,
      beforeData: beforeData,
      afterData: afterData,
    );
  }

  /// Get all modifications
  List<PipelineModification> get modifications =>
      List.unmodifiable(_modifications);

  /// Get modifications for a specific step
  List<PipelineModification> getModificationsForStep(String stepName) {
    return _modifications.where((m) => m.stepName == stepName).toList();
  }

  /// Get modifications by type
  List<PipelineModification> getModificationsByType(
    PipelineModificationType type,
  ) {
    return _modifications.where((m) => m.type == type).toList();
  }

  /// Get modifications by severity
  List<PipelineModification> getModificationsBySeverity(
    ModificationSeverity severity,
  ) {
    return _modifications.where((m) => m.severity == severity).toList();
  }

  /// Get summary statistics
  Map<String, dynamic> getSummaryStats() {
    final typeStats = <String, int>{};
    final severityStats = <String, int>{};
    final stepStats = <String, int>{};

    for (final mod in _modifications) {
      typeStats[mod.type.name] = (typeStats[mod.type.name] ?? 0) + 1;
      severityStats[mod.severity.name] =
          (severityStats[mod.severity.name] ?? 0) + 1;
      stepStats[mod.stepName] = (stepStats[mod.stepName] ?? 0) + 1;
    }

    return {
      'totalModifications': _modifications.length,
      'byType': typeStats,
      'bySeverity': severityStats,
      'byStep': stepStats,
      'hasEmergencyOverrides': _modifications.any(
        (m) => m.type == PipelineModificationType.emergencyOverride,
      ),
      'hasAiValidations': _modifications.any(
        (m) => m.type == PipelineModificationType.aiValidation,
      ),
      'hasAutomaticFixes': _modifications.any(
        (m) => m.type == PipelineModificationType.automaticFix,
      ),
    };
  }

  /// Generate user-friendly summary
  String generateUserFriendlySummary() {
    if (_modifications.isEmpty) {
      return 'No modifications were needed - your request was processed smoothly! ✨';
    }

    final stats = getSummaryStats();
    final buffer = StringBuffer();

    buffer.writeln('🔧 Processing Summary:');
    buffer.writeln('• Total improvements made: ${stats['totalModifications']}');

    if (stats['hasEmergencyOverrides'] == true) {
      buffer.writeln('• Emergency safeguards activated 🚨');
    }

    if (stats['hasAiValidations'] == true) {
      buffer.writeln('• AI validation enhanced your request 🤖');
    }

    if (stats['hasAutomaticFixes'] == true) {
      buffer.writeln('• Automatic quality improvements applied ✅');
    }

    return buffer.toString();
  }

  /// Convert to JSON for metadata
  Map<String, dynamic> toJson() {
    return {
      'modifications': _modifications.map((m) => m.toJson()).toList(),
      'summary': getSummaryStats(),
    };
  }

  /// Clear all modifications (for new requests)
  void clear() {
    _modifications.clear();
  }

  String _getTypeEmoji(PipelineModificationType type) {
    switch (type) {
      case PipelineModificationType.automaticFix:
        return '🔧';
      case PipelineModificationType.aiValidation:
        return '🤖';
      case PipelineModificationType.manualCorrection:
        return '✏️';
      case PipelineModificationType.dataEnrichment:
        return '📈';
      case PipelineModificationType.errorRecovery:
        return '🩹';
      case PipelineModificationType.loopPrevention:
        return '🔄';
      case PipelineModificationType.contextModification:
        return '📝';
      case PipelineModificationType.nutritionFix:
        return '🥗';
      case PipelineModificationType.ingredientModification:
        return '🥕';
      case PipelineModificationType.dishMetadataUpdate:
        return '🍽️';
      case PipelineModificationType.emergencyOverride:
        return '🚨';
    }
  }

  String _getSeverityEmoji(ModificationSeverity severity) {
    switch (severity) {
      case ModificationSeverity.low:
        return '💡';
      case ModificationSeverity.medium:
        return '⚡';
      case ModificationSeverity.high:
        return '🔥';
      case ModificationSeverity.critical:
        return '💥';
    }
  }
}
