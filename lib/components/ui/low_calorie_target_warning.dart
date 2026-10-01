import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

import '../../utils/number_parsing.dart';
import '../../utils/nutrition_calculator.dart';

/// Non-blocking warning for a daily calorie target below
/// [lowCalorieWarningThreshold]; renders nothing otherwise.
class LowCalorieTargetWarning extends StatelessWidget {
  final double calories;
  final EdgeInsetsGeometry padding;

  const LowCalorieTargetWarning({
    super.key,
    required this.calories,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLowCalorieTarget(calories)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Semantics(
        container: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.error),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.componentsLowCalorieWarningTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.componentsLowCalorieWarningMessage(
                        formatDecimal(calories, locale, fractionDigits: 0),
                        formatDecimal(
                          lowCalorieWarningThreshold,
                          locale,
                          fractionDigits: 0,
                        ),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
