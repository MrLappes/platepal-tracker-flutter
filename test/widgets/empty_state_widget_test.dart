import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/ui/empty_state_widget.dart';
import 'package:platepal_tracker/themes/app_theme.dart';

void main() {
  testWidgets('subtitle and icon stay readable in the dark theme', (
    tester,
  ) async {
    final theme = AppThemes.dark.materialTheme;
    final colorScheme = theme.colorScheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(
          body: EmptyStateWidget(
            icon: Icons.restaurant,
            title: 'No dishes',
            subtitle: 'Add your first dish',
          ),
        ),
      ),
    );

    final subtitle = tester.widget<Text>(find.text('Add your first dish'));
    final icon = tester.widget<Icon>(find.byIcon(Icons.restaurant));
    expect(subtitle.style?.color, colorScheme.onSurfaceVariant);
    expect(icon.color, colorScheme.onSurfaceVariant);
    expect(subtitle.style?.color, isNot(colorScheme.outline));

    final foregroundLuminance = subtitle.style!.color!.computeLuminance();
    final backgroundLuminance =
        theme.scaffoldBackgroundColor.computeLuminance();
    expect(
      (foregroundLuminance + 0.05) / (backgroundLuminance + 0.05),
      greaterThanOrEqualTo(4.5),
    );
  });
}
