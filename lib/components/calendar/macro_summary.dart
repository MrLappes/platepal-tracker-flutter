import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MacroSummary extends StatefulWidget {
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
  final bool isCollapsible;
  final bool initiallyExpanded;
  final VoidCallback? onAiTipPressed;

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
    this.isCollapsible = false,
    this.initiallyExpanded = true,
    this.onAiTipPressed,
  });

  @override
  State<MacroSummary> createState() => _MacroSummaryState();
}

class _MacroSummaryState extends State<MacroSummary> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              target != null
                  ? '${current.toStringAsFixed(current == current.toInt() ? 0 : 1)}${unit} / ${target.toStringAsFixed(target == target.toInt() ? 0 : 1)}${unit}'
                  : '${current.toStringAsFixed(current == current.toInt() ? 0 : 1)}${unit}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.isCollapsible) {
      return Card(
        child: Column(
          children: [
            // Header with tap to expand/collapse
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.nutritionSummary,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // AI Tip button
                    if (widget.onAiTipPressed != null) ...[
                      GestureDetector(
                        onTap: widget.onAiTipPressed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.getAiTip,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Quick stats when collapsed
                    if (!_isExpanded) ...[
                      Text(
                        '${widget.calories.toStringAsFixed(0)} cal',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Calories
                    _buildMacroBar(
                      label: l10n.calories,
                      current: widget.calories,
                      target: widget.calorieTarget,
                      unit: '',
                      color: _getCaloriesColor(
                        widget.calories,
                        widget.calorieTarget,
                      ),
                      context: context,
                    ),
                    const SizedBox(height: 12),

                    // Protein
                    _buildMacroBar(
                      label: l10n.protein,
                      current: widget.protein,
                      target: widget.proteinTarget,
                      unit: 'g',
                      color: _getProteinColor(
                        widget.protein,
                        widget.proteinTarget,
                      ),
                      context: context,
                    ),
                    const SizedBox(height: 12),

                    // Carbs
                    _buildMacroBar(
                      label: l10n.carbs,
                      current: widget.carbs,
                      target: widget.carbsTarget,
                      unit: 'g',
                      color: _getCarbsColor(widget.carbs, widget.carbsTarget),
                      context: context,
                    ),
                    const SizedBox(height: 12),

                    // Fat
                    _buildMacroBar(
                      label: l10n.fat,
                      current: widget.fat,
                      target: widget.fatTarget,
                      unit: 'g',
                      color: _getFatColor(widget.fat, widget.fatTarget),
                      context: context,
                    ),

                    // Fiber (if available)
                    if (widget.fiber > 0 ||
                        (widget.fiberTarget != null &&
                            widget.fiberTarget! > 0)) ...[
                      const SizedBox(height: 12),
                      _buildMacroBar(
                        label: l10n.fiber,
                        current: widget.fiber,
                        target: widget.fiberTarget,
                        unit: 'g',
                        color: _getFiberColor(widget.fiber, widget.fiberTarget),
                        context: context,
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // Compact view - show horizontal progress bars
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCompactMacroItem(
                        'Cal',
                        widget.calories,
                        widget.calorieTarget,
                        _getCaloriesColor(
                          widget.calories,
                          widget.calorieTarget,
                        ),
                        context,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactMacroItem(
                        'Protein',
                        widget.protein,
                        widget.proteinTarget,
                        _getProteinColor(widget.protein, widget.proteinTarget),
                        context,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactMacroItem(
                        'Carbs',
                        widget.carbs,
                        widget.carbsTarget,
                        _getCarbsColor(widget.carbs, widget.carbsTarget),
                        context,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildCompactMacroItem(
                        'Fat',
                        widget.fat,
                        widget.fatTarget,
                        _getFatColor(widget.fat, widget.fatTarget),
                        context,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Non-collapsible version (original behavior)
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
              current: widget.calories,
              target: widget.calorieTarget,
              unit: 'kcal',
              color: _getCaloriesColor(widget.calories, widget.calorieTarget),
              context: context,
            ),

            // Protein
            _buildMacroBar(
              label: l10n.protein,
              current: widget.protein,
              target: widget.proteinTarget,
              unit: 'g',
              color: _getProteinColor(widget.protein, widget.proteinTarget),
              context: context,
            ),

            // Carbs
            _buildMacroBar(
              label: l10n.carbs,
              current: widget.carbs,
              target: widget.carbsTarget,
              unit: 'g',
              color: _getCarbsColor(widget.carbs, widget.carbsTarget),
              context: context,
            ),

            // Fat
            _buildMacroBar(
              label: l10n.fat,
              current: widget.fat,
              target: widget.fatTarget,
              unit: 'g',
              color: _getFatColor(widget.fat, widget.fatTarget),
              context: context,
            ),

            // Fiber (only show if has value or target)
            if (widget.fiber > 0 ||
                (widget.fiberTarget != null && widget.fiberTarget! > 0))
              _buildMacroBar(
                label: l10n.fiber,
                current: widget.fiber,
                target: widget.fiberTarget,
                unit: 'g',
                color: _getFiberColor(widget.fiber, widget.fiberTarget),
                context: context,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMacroItem(
    String label,
    double current,
    double? target,
    Color color,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final progressWidth = _getProgressWidth(current, target);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
        const SizedBox(height: 2),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressWidth,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          current.toStringAsFixed(0),
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
