import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class AgentStepsModal extends StatelessWidget {
  final Map<String, dynamic> metadata;

  const AgentStepsModal({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = metadata['stepResults'] as List? ?? [];
    final thinkingSteps = metadata['thinkingSteps'] as List? ?? [];
    final processingTime = metadata['processingTime'] as int? ?? 0;
    final botType = metadata['botType'] as String? ?? 'assistant';
    final deepSearchEnabled = metadata['deepSearchEnabled'] as bool? ?? false;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agent Processing Steps'),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
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
                            label: const Text('Copy All'),
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
                      ),
                      ...thinkingSteps
                          .map<Widget>(
                            (step) => _buildThinkingStepItem(
                              context,
                              theme,
                              step.toString(),
                            ),
                          )
                          .toList(),
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
              ],
            ],
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
    final summaryData = {
      'processingTime': '${processingTime}ms',
      'botType': botType,
      'stepsCount': stepsCount,
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
            _buildInfoRow(theme, 'Steps Completed', '$stepsCount'),
            _buildInfoRow(
              theme,
              'Deep Search',
              deepSearchEnabled ? 'Enabled' : 'Disabled',
            ),
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
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
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
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
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
                      ? theme.colorScheme.primary.withOpacity(0.5)
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
                        ? theme.colorScheme.onSurface.withOpacity(0.7)
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: success ? Colors.green : Colors.red,
          child: Text(
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
            Icon(
              success ? Icons.check_circle : Icons.error,
              size: 16,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              success ? 'Completed successfully' : 'Failed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: success ? Colors.green : Colors.red,
              ),
            ),
            if (executionTime != null) ...[
              const SizedBox(width: 8),
              Text(
                '• ${executionTime}ms',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
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
                // Metadata section
                if (timestamp != null || executionTime != null) ...[
                  _buildCopyableSection(context, theme, '📊 Metadata', {
                    if (timestamp != null) 'timestamp': timestamp,
                    if (executionTime != null)
                      'executionTime': '${executionTime}ms',
                    'success': success,
                    'stepName': stepName,
                  }, isMetadata: true),
                  const SizedBox(height: 16),
                ],

                // Enhanced System Prompt (if available)
                if (data.containsKey('contextGatheringResult')) ...[
                  _buildEnhancedSystemPromptSection(context, theme, data),
                  const SizedBox(height: 16),
                ],

                // Data Output section
                if (data.isNotEmpty) ...[
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
                    ? Colors.red.withOpacity(0.1)
                    : isMetadata
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border:
                isError ? Border.all(color: Colors.red.withOpacity(0.3)) : null,
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
                    label: const Text('View Full Data'),
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
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Length: ${enhancedSystemPrompt.length} characters',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                    label: const Text('View Full Prompt'),
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
        content: const Text('Copied to clipboard'),
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
}
