import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MacroSummary extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double? calorieTarget;
  final double? proteinTarget;
  final double? carbsTarget;
  final double? fatTarget;
  final double? fiberTarget;

  const MacroSummary({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.calorieTarget,
    this.proteinTarget,
    this.carbsTarget,
    this.fatTarget,
    this.fiberTarget,
  });

  Color _interpolateColor(Color start, Color end, double factor) {
    factor = factor.clamp(0.0, 1.0);
    return Color.lerp(start, end, factor)!;
  }

  Color _getCaloriesColor(double current, double? target) {
    if (target == null) return Colors.grey;

    const yellow = Color(0xFFfacc15);
    const green = Color(0xFF4ade80);
    const red = Color(0xFFef4444);

    final ratio = current / target;

    if (ratio < 0.9) {
      final factor = min(1.0, ratio / 0.9);
      return _interpolateColor(yellow, green, factor);
    } else if (ratio >= 0.9 && ratio <= 1.1) {
      return green;
    } else if (ratio > 1.1 && ratio <= 1.2) {
      final factor = (ratio - 1.1) / 0.1;
      return _interpolateColor(green, yellow, factor);
    } else {
      final factor = min(1.0, (ratio - 1.2) / 0.3);
      return _interpolateColor(yellow, red, factor);
    }
  }

  Color _getProteinColor(double current, double? target) {
    if (target == null) return Colors.grey;

    const lightGreen = Color(0xFFa3e635);
    const green = Color(0xFF4ade80);
    const darkGreen = Color(0xFF16a34a);

    final ratio = current / target;

    if (ratio < 0.7) {
      final factor = min(1.0, ratio / 0.7);
      return _interpolateColor(const Color(0xFFd1d5db), lightGreen, factor);
    } else if (ratio >= 0.7 && ratio < 0.9) {
      final factor = (ratio - 0.7) / 0.2;
      return _interpolateColor(lightGreen, green, factor);
    } else {
      return darkGreen;
    }
  }

  Color _getCarbsColor(double current, double? target) {
    if (target == null) return Colors.grey;

    const yellow = Color(0xFFfacc15);
    const green = Color(0xFF4ade80);
    const red = Color(0xFFef4444);

    final optimalTarget = target;
    final distance = (current - optimalTarget).abs() / optimalTarget;

    if (distance <= 0.2) {
      return green;
    } else if (distance <= 0.5) {
      final factor = (distance - 0.2) / 0.3;
      return _interpolateColor(green, yellow, factor);
    } else {
      final factor = min(1.0, (distance - 0.5) / 0.5);
      return _interpolateColor(yellow, red, factor);
    }
  }

  Color _getFatColor(double current, double? target) {
    if (target == null) return Colors.grey;

    const green = Color(0xFF4ade80);
    const yellow = Color(0xFFfacc15);
    const red = Color(0xFFef4444);

    final ratio = current / target;

    if (ratio < 0.8) {
      return green;
    } else if (ratio >= 0.8 && ratio <= 1) {
      final factor = (ratio - 0.8) / 0.2;
      return _interpolateColor(green, yellow, factor);
    } else {
      final factor = min(1.0, (ratio - 1) / 0.2);
      return _interpolateColor(yellow, red, factor);
    }
  }

  Color _getFiberColor(double current, double? target) {
    if (target == null || target == 0) return Colors.grey;

    const yellow = Color(0xFFfacc15);
    const green = Color(0xFF4ade80);

    final ratio = current / target;

    if (ratio < 1) {
      return _interpolateColor(yellow, green, ratio);
    }
    return green;
  }

  double _getProgressWidth(double current, double? target) {
    if (target == null) return 0.2;

    if (current > target * 1.5) {
      return 1.0;
    }

    return min(1.0, current / target);
  }

  Widget _buildMacroBar({
    required String label,
    required double current,
    double? target,
    required String unit,
    required Color color,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressWidth = _getProgressWidth(current, target);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${current.toStringAsFixed(1)}${target != null ? ' / ${target.toStringAsFixed(0)}' : ''} $unit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.nutritionSummary,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.getAiTip,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calories
            _buildMacroBar(
              label: l10n.calories,
              current: calories,
              target: calorieTarget,
              unit: 'kcal',
              color: _getCaloriesColor(calories, calorieTarget),
              context: context,
            ),

            // Protein
            _buildMacroBar(
              label: l10n.protein,
              current: protein,
              target: proteinTarget,
              unit: 'g',
              color: _getProteinColor(protein, proteinTarget),
              context: context,
            ),

            // Carbs
            _buildMacroBar(
              label: l10n.carbs,
              current: carbs,
              target: carbsTarget,
              unit: 'g',
              color: _getCarbsColor(carbs, carbsTarget),
              context: context,
            ),

            // Fat
            _buildMacroBar(
              label: l10n.fat,
              current: fat,
              target: fatTarget,
              unit: 'g',
              color: _getFatColor(fat, fatTarget),
              context: context,
            ),

            // Fiber (only show if has value or target)
            if (fiber > 0 || (fiberTarget != null && fiberTarget! > 0))
              _buildMacroBar(
                label: l10n.fiber,
                current: fiber,
                target: fiberTarget,
                unit: 'g',
                color: _getFiberColor(fiber, fiberTarget),
                context: context,
              ),
          ],
        ),
      ),
    );
  }
}
