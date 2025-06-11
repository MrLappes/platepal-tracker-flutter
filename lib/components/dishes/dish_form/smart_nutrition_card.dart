import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SmartNutritionCard extends StatefulWidget {
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;
  final TextEditingController fiberController;
  final bool justRecalculated;
  final Animation<double> recalculatedAnimation;
  final VoidCallback? onRecalculate;

  const SmartNutritionCard({
    super.key,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatController,
    required this.fiberController,
    required this.justRecalculated,
    required this.recalculatedAnimation,
    this.onRecalculate,
  });

  @override
  State<SmartNutritionCard> createState() => _SmartNutritionCardState();
}

class _SmartNutritionCardState extends State<SmartNutritionCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  NutritionProfile _nutritionProfile = NutritionProfile.balanced;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Listen to controllers for changes
    widget.caloriesController.addListener(_analyzeNutrition);
    widget.proteinController.addListener(_analyzeNutrition);
    widget.carbsController.addListener(_analyzeNutrition);
    widget.fatController.addListener(_analyzeNutrition);

    _analyzeNutrition();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _analyzeNutrition() {
    final calories = double.tryParse(widget.caloriesController.text) ?? 0;
    final protein = double.tryParse(widget.proteinController.text) ?? 0;
    final carbs = double.tryParse(widget.carbsController.text) ?? 0;
    final fat = double.tryParse(widget.fatController.text) ?? 0;
    final fiber =
        double.tryParse(widget.fiberController.text) ??
        0; // Count filled nutrition fields (excluding calories)
    final filledFields =
        [protein, carbs, fat, fiber].where((value) => value > 0).length;

    // Only show analysis when calories > 0 and at least 1 other nutrition field is filled
    if (calories <= 0 || filledFields < 1) {
      setState(() => _nutritionProfile = NutritionProfile.unbalanced);
      return;
    }

    // Calculate calories from macros
    final proteinCals = protein * 4;
    final carbsCals = carbs * 4;
    final fatCals = fat * 9;
    final totalMacroCals = proteinCals + carbsCals + fatCals;

    // Calculate percentages
    final proteinPercentage =
        totalMacroCals > 0 ? (proteinCals / totalMacroCals) * 100 : 0;
    final carbsPercentage =
        totalMacroCals > 0 ? (carbsCals / totalMacroCals) * 100 : 0;
    final fatPercentage =
        totalMacroCals > 0 ? (fatCals / totalMacroCals) * 100 : 0;

    // Analyze protein density (grams of protein per 100 calories)
    final proteinDensity = (protein / calories) * 100;

    NutritionProfile newProfile;

    if (proteinDensity >= 10) {
      newProfile = NutritionProfile.highProtein;
      _triggerPositiveAnimation();
    } else if (fatPercentage >= 60) {
      newProfile = NutritionProfile.highFat;
      _triggerWarningAnimation();
    } else if (carbsPercentage >= 65) {
      newProfile = NutritionProfile.highCarb;
      _triggerNeutralAnimation();
    } else if (proteinPercentage >= 25 &&
        fatPercentage >= 25 &&
        carbsPercentage >= 25) {
      newProfile = NutritionProfile.balanced;
      _triggerPositiveAnimation();
    } else {
      newProfile = NutritionProfile.unbalanced;
      _triggerNeutralAnimation();
    }

    if (newProfile != _nutritionProfile) {
      setState(() => _nutritionProfile = newProfile);
    }
  }

  void _triggerPositiveAnimation() {
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _pulseController.stop();
    });
  }

  void _triggerWarningAnimation() {
    _shakeController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _shakeController.stop();
    });
  }

  void _triggerNeutralAnimation() {
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  bool _shouldShowAnalysis() {
    final calories = double.tryParse(widget.caloriesController.text) ?? 0;
    final protein = double.tryParse(widget.proteinController.text) ?? 0;
    final carbs = double.tryParse(widget.carbsController.text) ?? 0;
    final fat = double.tryParse(widget.fatController.text) ?? 0;
    final fiber =
        double.tryParse(widget.fiberController.text) ??
        0; // Count filled nutrition fields (excluding calories)
    final filledFields =
        [protein, carbs, fat, fiber].where((value) => value > 0).length;

    // Show analysis when calories > 0 and at least 1 other nutrition field is filled
    return calories > 0 && filledFields >= 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _shakeAnimation,
          widget.recalculatedAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale:
                widget.justRecalculated
                    ? widget.recalculatedAnimation.value
                    : _pulseAnimation.value,
            child: Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _nutritionProfile.color.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _nutritionProfile.color.withValues(alpha: 0.05),
                      colorScheme.surface,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with nutrition status
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _nutritionProfile.color.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _nutritionProfile.icon,
                              color: _nutritionProfile.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.nutritionalInformation,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _nutritionProfile.getTitle(l10n),
                                    key: ValueKey(_nutritionProfile),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _nutritionProfile.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.onRecalculate != null)
                            IconButton(
                              onPressed: widget.onRecalculate,
                              icon: const Icon(Icons.calculate_outlined),
                              tooltip: 'Recalculate from ingredients',
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.surfaceContainer,
                                foregroundColor: colorScheme.primary,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Nutrition inputs
                      Row(
                        children: [
                          Expanded(
                            child: _buildNutritionField(
                              controller: widget.caloriesController,
                              label: l10n.calories,
                              suffix: l10n.kcal,
                              icon: Icons.local_fire_department_outlined,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNutritionField(
                              controller: widget.fiberController,
                              label: l10n.fiber,
                              suffix: l10n.grams,
                              icon: Icons.grass_outlined,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildNutritionField(
                              controller: widget.proteinController,
                              label: l10n.protein,
                              suffix: l10n.grams,
                              icon: Icons.fitness_center_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNutritionField(
                              controller: widget.carbsController,
                              label: l10n.carbs,
                              suffix: l10n.grams,
                              icon: Icons.grain_outlined,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildNutritionField(
                              controller: widget.fatController,
                              label: l10n.fat,
                              suffix: l10n.grams,
                              icon: Icons.water_drop_outlined,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Smart feedback - only show when analysis is available
                      if (_shouldShowAnalysis())
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _nutritionProfile.color.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _nutritionProfile.color.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _nutritionProfile.feedbackIcon,
                                color: _nutritionProfile.color,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _nutritionProfile.getFeedback(l10n),
                                    key: ValueKey(_nutritionProfile),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _nutritionProfile.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutritionField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            hintText: '0',
            suffixText: suffix,
            suffixStyle: TextStyle(color: color.withValues(alpha: 0.7)),
            prefixIcon: Icon(icon, size: 18, color: color),
            filled: true,
            fillColor: colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

enum NutritionProfile {
  highProtein,
  highCarb,
  highFat,
  balanced,
  unbalanced;

  Color get color {
    switch (this) {
      case NutritionProfile.highProtein:
        return Colors.green;
      case NutritionProfile.highCarb:
        return Colors.orange;
      case NutritionProfile.highFat:
        return Colors.red.shade400;
      case NutritionProfile.balanced:
        return Colors.blue;
      case NutritionProfile.unbalanced:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case NutritionProfile.highProtein:
        return Icons.fitness_center;
      case NutritionProfile.highCarb:
        return Icons.grain;
      case NutritionProfile.highFat:
        return Icons.warning_rounded;
      case NutritionProfile.balanced:
        return Icons.balance;
      case NutritionProfile.unbalanced:
        return Icons.help_outline;
    }
  }

  IconData get feedbackIcon {
    switch (this) {
      case NutritionProfile.highProtein:
        return Icons.thumb_up;
      case NutritionProfile.highCarb:
        return Icons.info;
      case NutritionProfile.highFat:
        return Icons.warning;
      case NutritionProfile.balanced:
        return Icons.verified;
      case NutritionProfile.unbalanced:
        return Icons.lightbulb_outline;
    }
  }

  String getTitle(AppLocalizations l10n) {
    switch (this) {
      case NutritionProfile.highProtein:
        return 'High Protein';
      case NutritionProfile.highCarb:
        return 'High Carb';
      case NutritionProfile.highFat:
        return 'High Fat';
      case NutritionProfile.balanced:
        return 'Well Balanced';
      case NutritionProfile.unbalanced:
        return 'Nutrition Analysis';
    }
  }

  String getFeedback(AppLocalizations l10n) {
    switch (this) {
      case NutritionProfile.highProtein:
        return 'Excellent! High protein content supports muscle building and satiety.';
      case NutritionProfile.highCarb:
        return 'Great for energy! Perfect pre-workout or active days.';
      case NutritionProfile.highFat:
        return 'High in fats. Enjoy in moderation and balance with other meals.';
      case NutritionProfile.balanced:
        return 'Perfect balance! This dish provides well-rounded nutrition.';
      case NutritionProfile.unbalanced:
        return 'Enter nutrition values to see smart analysis and recommendations.';
    }
  }
}
