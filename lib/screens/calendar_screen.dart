import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/ui/empty_state_widget.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.calendar),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: EmptyStateWidget(
        icon: Icons.calendar_today,
        title: 'Calendar Coming Soon',
        subtitle: 'Track your meal history with an interactive calendar view.',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Calendar feature will be available in the next update',
              ),
            ),
          );
        },
        actionLabel: 'Get Notified',
      ),
    );
  }
}
