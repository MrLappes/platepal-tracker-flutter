import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

import '../services/data/platepal_dish_import.dart';
import 'dish_create_screen.dart';

/// Target of `platepaltracker://import-dish?d=...`: the dish form prefilled
/// with the shared dish, or an error for an invalid link.
class PlatePalImportScreen extends StatelessWidget {
  const PlatePalImportScreen({super.key, required this.payload});

  final String? payload;

  @override
  Widget build(BuildContext context) {
    final PlatePalDishDraft draft;
    try {
      draft = decodePlatePalDish(payload);
    } on PlatePalImportException catch (e) {
      return _ImportErrorScreen(error: e.error);
    }
    return DishCreateScreenAdvanced(importedDraft: draft);
  }
}

class _ImportErrorScreen extends StatelessWidget {
  const _ImportErrorScreen({required this.error});

  final PlatePalImportError error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.screensPlatePalImportTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link_off, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                error == PlatePalImportError.unsupportedVersion
                    ? l10n.screensPlatePalImportUnsupported
                    : l10n.screensPlatePalImportInvalid,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed:
                    () =>
                        context.canPop() ? context.pop() : context.go('/'),
                child: Text(l10n.componentsChatMessageBubbleClose),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
