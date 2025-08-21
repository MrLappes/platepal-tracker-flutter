import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'dart:convert';

class AgentStepsModal extends StatelessWidget {
  final Map<String, dynamic> metadata;

  const AgentStepsModal({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final steps = metadata['stepResults'] as List? ?? [];
    final thinkingSteps = metadata['thinkingSteps'] as List? ?? [];
    final processingTime = metadata['processingTime'] as int? ?? 0;
    final botType = metadata['botType'] as String? ?? 'assistant';
    final deepSearchEnabled = metadata['deepSearchEnabled'] as bool? ?? false;
    return Dialog.fullscreen(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.agentProcessingSteps),
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  _buildSummaryCard(
                    context,
                    theme,
                    processingTime,
                    botType,
                    deepSearchEnabled,
                    steps.length,
                  ),
                  const SizedBox(height: 16), // Thinking Steps
                  if (thinkingSteps.isNotEmpty) ...[
                    _buildSectionCard(
                      context,
                      theme,
                      '🧠 Thinking Process',
                      'Real-time agent thinking steps',
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed:
                                    () => _copyToClipboard(
                                      context,
                                      thinkingSteps.join('\n'),
                                    ),
                                icon: const Icon(Icons.copy, size: 16),
                                label: Text(l10n.copyAll),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          ...thinkingSteps.map<Widget>(
                            (step) => _buildThinkingStepItem(
                              context,
                              theme,
                              step.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Detailed Steps
                  if (steps.isNotEmpty) ...[
                    _buildSectionCard(
                      context,
                      theme,
                      '⚙️ Processing Steps',
                      'Detailed step-by-step execution',
                      Column(
                        children:
                            steps.asMap().entries.map<Widget>((entry) {
                              final index = entry.key;
                              final step = entry.value;
                              return _buildDetailedStepItem(
                                context,
                                theme,
                                index + 1,
                                step,
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Pipeline Modifications Section
                  if (metadata.containsKey('pipelineModifications')) ...[
                    _buildModificationsSection(context, theme),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    ThemeData theme,
    int processingTime,
    String botType,
    bool deepSearchEnabled,
    int stepsCount,
  ) {
    // Calculate step statistics
    final steps = metadata['stepResults'] as List? ?? [];

    // Separate error handling steps from regular steps
    final errorHandlingSteps =
        steps.where((step) => step['stepName'] == 'error_handling').length;
    final errorHandlingSuccessful =
        steps
            .where(
              (step) =>
                  step['stepName'] == 'error_handling' &&
                  step['success'] == true,
            )
            .length;

    // Calculate regular step statistics (excluding error handling steps)
    final regularSteps = steps.where(
      (step) => step['stepName'] != 'error_handling',
    );
    final completedSteps =
        regularSteps
            .where(
              (step) =>
                  step['success'] == true && (step['data']?['skipped'] != true),
            )
            .length;
    final skippedSteps =
        regularSteps.where((step) => step['data']?['skipped'] == true).length;
    final failedSteps =
        regularSteps.where((step) => step['success'] == false).length;
    final summaryData = {
      'processingTime': '${processingTime}ms',
      'botType': botType,
      'totalSteps': stepsCount,
      'completedSteps': completedSteps,
      'skippedSteps': skippedSteps,
      'failedSteps': failedSteps,
      'errorHandlingSteps': errorHandlingSteps,
      'errorHandlingSuccessful': errorHandlingSuccessful,
      'deepSearchEnabled': deepSearchEnabled,
      'metadata': metadata,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Processing Summary',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed:
                      () => _copyToClipboard(
                        context,
                        const JsonEncoder.withIndent('  ').convert(summaryData),
                      ),
                  tooltip: 'Copy summary data',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(theme, 'Processing Time', '${processingTime}ms'),
            _buildInfoRow(theme, 'Bot Type', botType),
            _buildInfoRow(theme, 'Total Steps', '$stepsCount'),
            if (skippedSteps > 0)
              _buildInfoRow(
                theme,
                'Skipped Steps',
                '$skippedSteps',
                color: Colors.orange,
              ),
            if (failedSteps > 0)
              _buildInfoRow(
                theme,
                'Failed Steps',
                '$failedSteps',
                color: Colors.red,
              ),
            if (errorHandlingSteps > 0)
              _buildInfoRow(
                theme,
                'Error Recovery',
                '$errorHandlingSuccessful/$errorHandlingSteps',
                color: Colors.amber,
              ),
            _buildInfoRow(
              theme,
              'Completed Steps',
              '$completedSteps',
              color: Colors.green,
            ),
            _buildInfoRow(
              theme,
              'Deep Search',
              deepSearchEnabled ? 'Enabled' : 'Disabled',
            ),
            // Add modification summary
            if (metadata.containsKey('pipelineModifications')) ...[
              const SizedBox(height: 8),
              _buildModificationSummaryRow(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    ThemeData theme,
    String title,
    String subtitle,
    Widget content,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    color ?? theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModificationSummaryRow(ThemeData theme) {
    final modifications =
        metadata['pipelineModifications'] as Map<String, dynamic>? ?? {};
    final summary = modifications['summary'] as Map<String, dynamic>? ?? {};

    // Get all modifications including step-level ones
    int totalMods = summary['totalModifications'] as int? ?? 0;

    // Check steps for additional modifications
    final steps = metadata['stepResults'] as List? ?? [];
    for (final step in steps) {
      if (step is Map<String, dynamic> &&
          step['data'] != null &&
          step['data'] is Map<String, dynamic>) {
        final stepData = step['data'] as Map<String, dynamic>;

        // Check if this step has modifications
        if (stepData.containsKey('modifications') &&
            stepData['modifications'] is Map<String, dynamic>) {
          final stepMods = stepData['modifications'] as Map<String, dynamic>;

          if (stepMods.containsKey('modifications') &&
              stepMods['modifications'] is List) {
            final stepModsList = stepMods['modifications'] as List;
            totalMods += stepModsList.length;
          }
        }
      }
    }

    if (totalMods == 0) {
      return _buildInfoRow(
        theme,
        'Modifications',
        'None needed ✨',
        color: Colors.green,
      );
    }

    final hasEmergency = summary['hasEmergencyOverrides'] as bool? ?? false;
    final hasAi = summary['hasAiValidations'] as bool? ?? false;
    final hasAuto = summary['hasAutomaticFixes'] as bool? ?? false;

    String modText = '$totalMods applied';
    Color modColor = Colors.blue;

    if (hasEmergency) {
      modText += ' (🚨 Emergency)';
      modColor = Colors.red;
    } else if (hasAi) {
      modText += ' (🤖 AI Enhanced)';
      modColor = Colors.purple;
    } else if (hasAuto) {
      modText += ' (🔧 Auto Fixed)';
      modColor = Colors.green;
    }

    return _buildInfoRow(theme, 'Modifications', modText, color: modColor);
  }

  Widget _buildThinkingStepItem(
    BuildContext context,
    ThemeData theme,
    String step,
  ) {
    final isSubStep = step.startsWith('   ');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.only(
        left: isSubStep ? 24 : 0,
        top: 8,
        bottom: 8,
        right: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color:
                  isSubStep
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              step.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isSubStep
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurface,
                fontSize: isSubStep ? 13 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStepItem(
    BuildContext context,
    ThemeData theme,
    int stepNumber,
    Map<String, dynamic> step,
  ) {
    final stepName = step['stepName'] as String? ?? 'Unknown Step';
    final success = step['success'] as bool? ?? false;
    final data = step['data'] as Map<String, dynamic>? ?? {};
    final error = step['error'] as Map<String, dynamic>?;
    final timestamp = step['timestamp'] as String?;
    final executionTime = step['executionTime'] as int?;
    final isSkipped = data['skipped'] as bool? ?? false;
    final skipReason =
        data['reason'] as String?; // Determine the display status and colors
    Color statusColor;
    IconData statusIcon;
    String statusText;

    // Special handling for error_handling steps
    final isErrorHandlingStep = stepName == 'error_handling';

    if (isSkipped) {
      statusColor = Colors.orange;
      statusIcon = Icons.skip_next;
      statusText = 'Skipped';
    } else if (isErrorHandlingStep) {
      // Error handling steps should be shown as warning/error even if they succeeded
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
      statusText = success ? 'Error recovered' : 'Error handling failed';
    } else if (success) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Completed successfully';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = 'Failed';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: statusColor,
          child:
              isSkipped
                  ? Icon(Icons.skip_next, color: Colors.white, size: 16)
                  : Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
        ),
        title: Text(
          stepName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(statusIcon, size: 16, color: statusColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                isSkipped && skipReason != null
                    ? '$statusText: $skipReason'
                    : statusText,
                style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (executionTime != null) ...[
              const SizedBox(width: 8),
              Text(
                '• ${executionTime}ms',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skipped step explanation section
                if (isSkipped) ...[
                  _buildCopyableSection(context, theme, '⏭️ Skip Details', {
                    'reason': skipReason ?? 'No reason provided',
                    'stepName': stepName,
                    if (data.containsKey('contextRequirements'))
                      'contextRequirements': data['contextRequirements'],
                  }, isMetadata: true),
                  const SizedBox(height: 16),
                ],

                // Metadata section
                if (timestamp != null || executionTime != null) ...[
                  _buildCopyableSection(context, theme, '📊 Metadata', {
                    if (timestamp != null) 'timestamp': timestamp,
                    if (executionTime != null)
                      'executionTime': '${executionTime}ms',
                    'success': success,
                    'skipped': isSkipped,
                    'stepName': stepName,
                  }, isMetadata: true),
                  const SizedBox(height: 16),
                ],

                // Enhanced System Prompt (if available)
                if (data.containsKey('contextGatheringResult')) ...[
                  _buildEnhancedSystemPromptSection(context, theme, data),
                  const SizedBox(height: 16),
                ],

                // Step Modifications (if available)
                if (data.containsKey('modifications') ||
                    data.containsKey('modificationSummary')) ...[
                  _buildStepModificationsSection(context, theme, data),
                  const SizedBox(height: 16),
                ],

                // Data Output section (only show if not skipped and has meaningful data)
                if (!isSkipped && data.isNotEmpty) ...[
                  _buildCopyableSection(context, theme, '📤 Data Output', data),
                  const SizedBox(height: 16),
                ],

                // Error Details section
                if (error != null) ...[
                  _buildCopyableSection(
                    context,
                    theme,
                    '❌ Error Details',
                    error,
                    isError: true,
                  ),
                ],

                // Raw JSON section
                const SizedBox(height: 12),
                _buildCopyableSection(
                  context,
                  theme,
                  '🔍 Raw Step Data',
                  step,
                  isRaw: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value is String) {
      return value.length > 100 ? '${value.substring(0, 100)}...' : value;
    } else if (value is List) {
      return 'List with ${value.length} items';
    } else if (value is Map) {
      return 'Map with ${value.length} keys';
    }
    return value.toString();
  }

  Widget _buildCopyableSection(
    BuildContext context,
    ThemeData theme,
    String title,
    Map<String, dynamic> data, {
    bool isError = false,
    bool isMetadata = false,
    bool isRaw = false,
  }) {
    String jsonString;
    try {
      jsonString = const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      // Handle objects that can't be JSON serialized
      final sanitizedData = _sanitizeDataForJson(data);
      try {
        jsonString = const JsonEncoder.withIndent('  ').convert(sanitizedData);
      } catch (e2) {
        // Last resort: convert everything to strings
        jsonString =
            'Error serializing data: ${e2.toString()}\n\nRaw data:\n${data.toString()}';
      }
    }
    final displayString = isRaw ? jsonString : _formatDataForDisplay(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isError ? Colors.red : null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => _copyToClipboard(context, jsonString),
              tooltip: 'Copy to clipboard',
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isError
                    ? Colors.red.withValues(alpha: 0.1)
                    : isMetadata
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border:
                isError
                    ? Border.all(color: Colors.red.withValues(alpha: 0.3))
                    : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isRaw) ...[
                Text(
                  displayString,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: isRaw ? 'monospace' : null,
                    color: isError ? Colors.red : null,
                  ),
                ),
                if (data.length > 3) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed:
                        () => _showFullDataDialog(context, title, jsonString),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: Text(AppLocalizations.of(context)!.viewFullData),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  jsonString,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepModificationsSection(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
  ) {
    try {
      final modifications = data['modifications'] as Map<String, dynamic>?;
      if (modifications == null) return const SizedBox();

      final modificationsList = modifications['modifications'] as List? ?? [];
      if (modificationsList.isEmpty) return const SizedBox();

      final modificationSummary =
          data['modificationSummary'] as String? ?? 'No summary available';

      // Find most severe modification for border color
      String highestSeverity = 'low';
      for (final mod in modificationsList) {
        final modSeverity = mod['severity'] as String? ?? 'low';
        if (modSeverity == 'critical') {
          highestSeverity = 'critical';
          break;
        } else if (modSeverity == 'high' && highestSeverity != 'critical') {
          highestSeverity = 'high';
        } else if (modSeverity == 'medium' &&
            highestSeverity != 'critical' &&
            highestSeverity != 'high') {
          highestSeverity = 'medium';
        }
      }

      // Get border color based on highest severity
      final borderColor = _getModificationSeverityColor(highestSeverity);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🔧 Step Modifications',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed:
                    () => _copyToClipboard(
                      context,
                      const JsonEncoder.withIndent('  ').convert(modifications),
                    ),
                tooltip: 'Copy modifications',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary: $modificationSummary',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...modificationsList.map<Widget>((mod) {
                  final type = mod['type'] as String? ?? '';
                  final description = mod['description'] as String? ?? '';
                  final details = mod['technicalDetails'] as String? ?? '';
                  final severity = mod['severity'] as String? ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getModificationTypeEmoji(type),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getModificationSeverityColor(
                                    severity,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getModificationSeverityColor(
                                      severity,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  severity.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getModificationSeverityColor(
                                      severity,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (details.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              details,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  Widget _buildEnhancedSystemPromptSection(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
  ) {
    try {
      final contextGatheringResult =
          data['contextGatheringResult'] as Map<String, dynamic>?;
      if (contextGatheringResult == null) return const SizedBox();

      final enhancedSystemPrompt =
          contextGatheringResult['enhancedSystemPrompt'] as String?;
      if (enhancedSystemPrompt == null) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🤖 Enhanced System Prompt',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed:
                    () => _copyToClipboard(context, enhancedSystemPrompt),
                tooltip: 'Copy enhanced system prompt',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Length: ${enhancedSystemPrompt.length} characters',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  enhancedSystemPrompt.length > 200
                      ? '${enhancedSystemPrompt.substring(0, 200)}...'
                      : enhancedSystemPrompt,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                if (enhancedSystemPrompt.length > 200) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed:
                        () => _showFullDataDialog(
                          context,
                          'Enhanced System Prompt',
                          enhancedSystemPrompt,
                        ),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: Text(AppLocalizations.of(context)!.viewFullPrompt),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  String _formatDataForDisplay(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    var count = 0;
    data.forEach((key, value) {
      if (count >= 3) return; // Show only first 3 items in summary
      buffer.writeln('$key: ${_formatValue(value)}');
      count++;
    });
    if (data.length > 3) {
      buffer.writeln('... and ${data.length - 3} more items');
    }
    return buffer.toString().trim();
  }

  /// Sanitizes data for JSON encoding by converting complex objects to serializable forms
  Map<String, dynamic> _sanitizeDataForJson(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    data.forEach((key, value) {
      if (value == null) {
        sanitized[key] = null;
      } else if (value is String || value is num || value is bool) {
        sanitized[key] = value;
      } else if (value is List) {
        sanitized[key] = value.map((item) => _sanitizeValue(item)).toList();
      } else if (value is Map) {
        if (value is Map<String, dynamic>) {
          sanitized[key] = _sanitizeDataForJson(value);
        } else {
          sanitized[key] = value.toString();
        }
      } else {
        // Try to call toJson() if available, otherwise convert to string
        try {
          // Use reflection-like approach to check for toJson method
          final hasToJson =
              value.toString().contains('toJson') ||
              value.runtimeType.toString().contains(
                'ChatStepVerificationResult',
              ) ||
              value.runtimeType.toString().contains('ChatAgentError');
          if (hasToJson) {
            sanitized[key] = (value as dynamic).toJson();
          } else {
            sanitized[key] = value.toString();
          }
        } catch (e) {
          sanitized[key] = value.toString();
        }
      }
    });

    return sanitized;
  }

  /// Sanitizes individual values for JSON encoding
  dynamic _sanitizeValue(dynamic value) {
    if (value == null) {
      return null;
    } else if (value is String || value is num || value is bool) {
      return value;
    } else if (value is List) {
      return value.map((item) => _sanitizeValue(item)).toList();
    } else if (value is Map<String, dynamic>) {
      return _sanitizeDataForJson(value);
    } else {
      // Try to call toJson() if available, otherwise convert to string
      try {
        final hasToJson =
            value.runtimeType.toString().contains(
              'ChatStepVerificationResult',
            ) ||
            value.runtimeType.toString().contains('ChatAgentError');
        if (hasToJson) {
          return (value as dynamic).toJson();
        } else {
          return value.toString();
        }
      } catch (e) {
        return value.toString();
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.copiedToClipboard),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showFullDataDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyToClipboard(context, content),
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  content,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
    );
  }

  /// Build the pipeline modifications section
  Widget _buildModificationsSection(BuildContext context, ThemeData theme) {
    // Extract modifications from top-level pipelineModifications
    final modifications =
        metadata['pipelineModifications'] as Map<String, dynamic>? ?? {};
    final modificationsList = modifications['modifications'] as List? ?? [];
    final summary = modifications['summary'] as Map<String, dynamic>? ?? {};

    // Also check for step-level modifications that might not have been aggregated
    final steps = metadata['stepResults'] as List? ?? [];
    List<dynamic> allModifications = List.from(modificationsList);

    // Check each step for modifications data
    for (final step in steps) {
      if (step is Map<String, dynamic> &&
          step['data'] != null &&
          step['data'] is Map<String, dynamic>) {
        final stepData = step['data'] as Map<String, dynamic>;

        // Check if this step has modifications
        if (stepData.containsKey('modifications') &&
            stepData['modifications'] is Map<String, dynamic>) {
          final stepMods = stepData['modifications'] as Map<String, dynamic>;

          if (stepMods.containsKey('modifications') &&
              stepMods['modifications'] is List) {
            final stepModsList = stepMods['modifications'] as List;
            if (stepModsList.isNotEmpty) {
              allModifications.addAll(stepModsList);
            }
          }
        }
      }
    }

    // The total modifications count now includes step-level modifications

    if (allModifications.isEmpty) {
      return _buildSectionCard(
        context,
        theme,
        '✨ Pipeline Modifications',
        'No modifications were needed - your request was processed smoothly!',
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Perfect processing! No corrections or modifications were needed.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildSectionCard(
      context,
      theme,
      '🔧 Pipeline Modifications',
      'Automatic fixes and AI improvements applied during processing',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary stats
          _buildModificationSummary(context, theme, summary),
          const SizedBox(height: 16),

          // Individual modifications
          ...allModifications.asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final modification = entry.value as Map<String, dynamic>;
            return _buildModificationItem(
              context,
              theme,
              index + 1,
              modification,
            );
          }),

          // Copy all button
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed:
                    () => _copyToClipboard(
                      context,
                      const JsonEncoder.withIndent('  ').convert(modifications),
                    ),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy All Modifications'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build modification summary
  Widget _buildModificationSummary(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> summary,
  ) {
    final totalMods = summary['totalModifications'] as int? ?? 0;
    final hasEmergency = summary['hasEmergencyOverrides'] as bool? ?? false;
    final hasAi = summary['hasAiValidations'] as bool? ?? false;
    final hasAuto = summary['hasAutomaticFixes'] as bool? ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Processing Summary',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total modifications: $totalMods',
            style: theme.textTheme.bodySmall,
          ),
          if (hasEmergency)
            _buildSummaryBadge('🚨', 'Emergency overrides', Colors.red),
          if (hasAi) _buildSummaryBadge('🤖', 'AI validations', Colors.blue),
          if (hasAuto)
            _buildSummaryBadge('🔧', 'Automatic fixes', Colors.green),
        ],
      ),
    );
  }

  /// Build summary badge
  Widget _buildSummaryBadge(String emoji, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual modification item
  Widget _buildModificationItem(
    BuildContext context,
    ThemeData theme,
    int index,
    Map<String, dynamic> modification,
  ) {
    final type = modification['type'] as String? ?? '';
    final severity = modification['severity'] as String? ?? '';
    final stepName = modification['stepName'] as String? ?? '';
    final description = modification['description'] as String? ?? '';
    final technicalDetails = modification['technicalDetails'] as String?;
    final wasSuccessful = modification['wasSuccessful'] as bool? ?? true;
    final timestamp = modification['timestamp'] as String?;

    final typeEmoji = _getModificationTypeEmoji(type);
    final severityColor = _getModificationSeverityColor(severity);
    final severityEmoji = _getModificationSeverityEmoji(severity);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color:
                wasSuccessful
                    ? severityColor.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: wasSuccessful ? severityColor : Colors.red,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(typeEmoji, style: const TextStyle(fontSize: 16)),
          ),
        ),
        title: Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: wasSuccessful ? null : Colors.red[700],
          ),
        ),
        subtitle: Row(
          children: [
            Text(severityEmoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              '$stepName • ${severity.toUpperCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: severityColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!wasSuccessful) ...[
              const SizedBox(width: 8),
              const Icon(Icons.error, size: 14, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                'FAILED',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (technicalDetails != null) ...[
                  Text(
                    'Technical Details',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    technicalDetails,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Before/After data if available
                if (modification.containsKey('beforeData') ||
                    modification.containsKey('afterData')) ...[
                  _buildBeforeAfterData(context, theme, modification),
                  const SizedBox(height: 12),
                ],

                // Metadata
                Row(
                  children: [
                    Text(
                      'ID: ${modification['id'] ?? 'unknown'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    if (timestamp != null) ...[
                      const SizedBox(width: 16),
                      Text(
                        'Time: ${DateTime.parse(timestamp).toLocal().toString().split('.')[0]}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build before/after data comparison
  Widget _buildBeforeAfterData(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> modification,
  ) {
    final beforeData = modification['beforeData'] as Map<String, dynamic>?;
    final afterData = modification['afterData'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Changes',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (beforeData != null) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Before',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDataForDisplay(beforeData),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (afterData != null) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'After',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDataForDisplay(afterData),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Get emoji for modification type
  String _getModificationTypeEmoji(String type) {
    switch (type) {
      case 'automaticFix':
        return '🔧';
      case 'aiValidation':
        return '🤖';
      case 'contextModification':
        return '📝';
      case 'manualCorrection':
        return '✏️';
      case 'dataEnrichment':
        return '📈';
      case 'errorRecovery':
        return '🩹';
      case 'loopPrevention':
        return '🔄';
      case 'nutritionFix':
        return '🥗';
      case 'ingredientModification':
        return '🥕';
      case 'dishMetadataUpdate':
        return '🍽️';
      case 'emergencyOverride':
        return '🚨';
      default:
        return '⚙️';
    }
  }

  /// Get color for modification severity
  Color _getModificationSeverityColor(String severity) {
    switch (severity) {
      case 'low':
        return Colors.blue;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.purple;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get emoji for modification severity
  String _getModificationSeverityEmoji(String severity) {
    switch (severity) {
      case 'low':
        return '💡';
      case 'medium':
        return '⚡';
      case 'high':
        return '🔥';
      case 'critical':
        return '💥';
      default:
        return '⚙️';
    }
  }
}
