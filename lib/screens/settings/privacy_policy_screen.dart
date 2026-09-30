import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sections = [
      (
        localizations.screensPrivacyOverviewTitle,
        localizations.screensPrivacyOverviewBody,
      ),
      (
        localizations.screensPrivacyStorageTitle,
        localizations.screensPrivacyStorageBody,
      ),
      (localizations.screensPrivacyAiTitle, localizations.screensPrivacyAiBody),
      (
        localizations.screensPrivacyFoodFactsTitle,
        localizations.screensPrivacyFoodFactsBody,
      ),
      (
        localizations.screensPrivacyHealthTitle,
        localizations.screensPrivacyHealthBody,
      ),
      (
        localizations.screensPrivacyExternalTitle,
        localizations.screensPrivacyExternalBody,
      ),
      (
        localizations.screensPrivacyExportTitle,
        localizations.screensPrivacyExportBody,
      ),
      (
        localizations.screensPrivacyBackupTitle,
        localizations.screensPrivacyBackupBody,
      ),
      (
        localizations.screensPrivacyDeletionTitle,
        localizations.screensPrivacyDeletionBody,
      ),
      (
        localizations.screensPrivacyChildrenTitle,
        localizations.screensPrivacyChildrenBody,
      ),
      (
        localizations.screensPrivacyChangesTitle,
        localizations.screensPrivacyChangesBody,
      ),
      (
        localizations.screensPrivacyContactTitle,
        localizations.screensPrivacyContactBody,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.screensPrivacyTitle),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.screensPrivacyEffectiveDate,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            for (final (title, body) in sections) ...[
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(body, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
            ],
            OutlinedButton.icon(
              onPressed: () async {
                final url = Uri.parse(
                  'https://github.com/MrLappes/platepal-tracker-flutter/blob/main/PRIVACY.md',
                );
                try {
                  if (await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    return;
                  }
                } catch (_) {}
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(localizations.screensPrivacyLinkError),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: Text(localizations.screensPrivacyViewOnline),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
