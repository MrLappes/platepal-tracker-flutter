import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

class ErrorDisplay extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final Widget? icon;

  const ErrorDisplay({super.key, required this.error, this.onRetry, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon ??
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.componentsSharedErrorDisplayRetry),
                style: ElevatedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onErrorContainer,
                  backgroundColor: theme.colorScheme.errorContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
