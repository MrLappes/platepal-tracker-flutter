import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/dish_models.dart';
import '../../models/dish.dart';
import '../../services/storage/dish_service.dart';
import '../../screens/dish_create_screen.dart';

/// Nutrition profile types for dish analysis
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

  String get emoji {
    switch (this) {
      case NutritionProfile.highProtein:
        return '💪';
      case NutritionProfile.highCarb:
        return '⚡';
      case NutritionProfile.highFat:
        return '⚠️';
      case NutritionProfile.balanced:
        return '⚖️';
      case NutritionProfile.unbalanced:
        return '📊';
    }
  }

  String getEmoji() {
    switch (this) {
      case NutritionProfile.highProtein:
        return '💪';
      case NutritionProfile.highCarb:
        return '⚡';
      case NutritionProfile.highFat:
        return '⚠️';
      case NutritionProfile.balanced:
        return '✨';
      case NutritionProfile.unbalanced:
        return '';
    }
  }
}

class DishSuggestionCard extends StatefulWidget {
  final ProcessedDish dish;
  final bool isReferenced;
  final VoidCallback? onPress;
  final Function(ProcessedDish) onLog;
  final Future<ProcessedDish?> Function(ProcessedDish) onInspect;

  const DishSuggestionCard({
    super.key,
    required this.dish,
    this.isReferenced = false,
    this.onPress,
    required this.onLog,
    required this.onInspect,
  });

  @override
  State<DishSuggestionCard> createState() => _DishSuggestionCardState();
}

class _DishSuggestionCardState extends State<DishSuggestionCard>
    with TickerProviderStateMixin {
  final DishService _dishService = DishService();
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  bool _loading = false;
  bool _dishExists = false;
  NutritionProfile _nutritionProfile = NutritionProfile.unbalanced;
  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Start animation
    _animationController.forward();

    // Check if dish exists and analyze nutrition
    _checkDishExists();
    _analyzeNutrition();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Analyzes nutrition to detect dish profile and trigger appropriate animations
  void _analyzeNutrition() {
    final nutrition = widget.dish.totalNutrition;
    final calories = nutrition.calories;
    final protein = nutrition.protein;
    final carbs = nutrition.carbs;
    final fat = nutrition.fat;

    if (calories <= 0) {
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

    final previousProfile = _nutritionProfile;
    NutritionProfile newProfile;

    if (proteinDensity >= 10) {
      newProfile = NutritionProfile.highProtein;
    } else if (fatPercentage >= 60) {
      newProfile = NutritionProfile.highFat;
    } else if (carbsPercentage >= 65) {
      newProfile = NutritionProfile.highCarb;
    } else if (proteinPercentage >= 25 &&
        fatPercentage >= 25 &&
        carbsPercentage >= 25) {
      newProfile = NutritionProfile.balanced;
    } else {
      newProfile = NutritionProfile.unbalanced;
    }

    if (newProfile != previousProfile) {
      setState(() => _nutritionProfile = newProfile);
      _triggerProfileAnimation(newProfile);
    }
  }

  /// Triggers appropriate animation based on nutrition profile
  void _triggerProfileAnimation(NutritionProfile profile) {
    switch (profile) {
      case NutritionProfile.highProtein:
      case NutritionProfile.balanced:
        _triggerPositiveAnimation();
        break;
      case NutritionProfile.highFat:
        _triggerWarningAnimation();
        break;
      case NutritionProfile.highCarb:
      case NutritionProfile.unbalanced:
        _triggerNeutralAnimation();
        break;
    }
  }

  /// Triggers positive pulsing animation for good nutrition profiles
  void _triggerPositiveAnimation() {
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _pulseController.stop();
    });
  }

  /// Triggers warning shake animation for concerning nutrition profiles
  void _triggerWarningAnimation() {
    _shakeController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _shakeController.stop();
    });
  }

  /// Triggers neutral animation for informational profiles
  void _triggerNeutralAnimation() {
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  Future<void> _checkDishExists() async {
    try {
      final existingDishes = await _dishService.getAllDishes();
      final exists = existingDishes.any(
        (existingDish) =>
            existingDish.name.toLowerCase() == widget.dish.name.toLowerCase(),
      );
      setState(() => _dishExists = exists);
    } catch (error) {
      debugPrint('Error checking if dish exists: $error');
      setState(() => _dishExists = false);
    }
  }

  Future<void> _handleInspect() async {
    if (widget.isReferenced) {
      // For referenced dishes, check if dish exists in database
      await _handleReferencedDishInspect();
    } else {
      // For new dishes, navigate to creation screen
      await _handleNewDishInspect();
    }
  }

  Future<void> _handleReferencedDishInspect() async {
    // For referenced dishes, always go directly to creation screen
    // The _dishExists state is already determined in _checkDishExists()
    await _openDishCreationScreen();
  }

  Future<void> _handleNewDishInspect() async {
    await _openDishCreationScreen();
  }

  /// Opens the dish creation screen with pre-filled data for editing
  Future<void> _openDishCreationScreen() async {
    setState(() => _loading = true);
    try {
      // Navigate to dish creation screen with pre-filled data
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (context) => _buildDishCreationScreen()),
      );
      if (result == true) {
        // Dish was created/updated successfully
        final wasExisting = _dishExists;
        setState(() => _dishExists = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                wasExisting
                    ? 'Dish "${widget.dish.name}" updated successfully!'
                    : 'Dish "${widget.dish.name}" created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      debugPrint('Error opening dish creation screen: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.errorOpeningDishScreen(error.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildDishCreationScreen() {
    // Convert ProcessedDish to Dish for the creation screen
    final dishData = Dish(
      id: widget.dish.id,
      name: widget.dish.name,
      description: widget.dish.description,
      imageUrl: widget.dish.imageUrl,
      ingredients:
          widget.dish.ingredients.map((ingredient) {
            return Ingredient(
              id: ingredient.id,
              name: ingredient.name,
              amount: ingredient.amount,
              unit: ingredient.unit,
              nutrition:
                  ingredient.nutrition != null
                      ? NutritionInfo(
                        calories: ingredient.nutrition!.calories,
                        protein: ingredient.nutrition!.protein,
                        carbs: ingredient.nutrition!.carbs,
                        fat: ingredient.nutrition!.fat,
                        fiber: ingredient.nutrition!.fiber,
                        sugar: ingredient.nutrition!.sugar,
                        sodium: ingredient.nutrition!.sodium,
                      )
                      : null,
              barcode: ingredient.barcode,
            );
          }).toList(),
      nutrition: NutritionInfo(
        calories: widget.dish.totalNutrition.calories,
        protein: widget.dish.totalNutrition.protein,
        carbs: widget.dish.totalNutrition.carbs,
        fat: widget.dish.totalNutrition.fat,
        fiber: widget.dish.totalNutrition.fiber,
        sugar: widget.dish.totalNutrition.sugar,
        sodium: widget.dish.totalNutrition.sodium,
      ),
      createdAt: widget.dish.createdAt,
      updatedAt: widget.dish.updatedAt,
      isFavorite: widget.dish.isFavorite,
      category: widget.dish.mealType?.toJsonValue(),
    );
    return DishCreateScreenAdvanced(
      heroTag: "dish_create_fab_suggestion_${widget.dish.id}",
      dish: dishData,
      onDishCreated: (createdDish) {
        // The dish was successfully created/updated
        // The navigation result will handle the main UI updates
        debugPrint('Dish created/updated: ${createdDish.name}');
      },
    );
  }

  Widget _buildNutritionBar(
    String label,
    double value,
    double maxValue,
    Color color, {
    bool isHighlight = false,
  }) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: isHighlight ? FontWeight.w900 : FontWeight.bold,
                color:
                    isHighlight
                        ? color
                        : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: isHighlight ? 8 : 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isHighlight ? 4 : 3),
                border:
                    isHighlight
                        ? Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1,
                        )
                        : null,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(isHighlight ? 4 : 3),
                    boxShadow:
                        isHighlight
                            ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                            : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '${value.round()}g',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
                color:
                    isHighlight
                        ? color
                        : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// Get contextual button text based on dish state
  String _getButtonText(AppLocalizations l10n, bool isSpecialProfile) {
    if (widget.isReferenced) {
      // For referenced dishes
      if (_dishExists) {
        return isSpecialProfile
            ? '${l10n.details} ${_nutritionProfile.emoji}'
            : 'Edit Dish';
      } else {
        return 'Create Missing Dish';
      }
    } else {
      // For new dishes
      if (_dishExists) {
        return isSpecialProfile
            ? '${l10n.details} ${_nutritionProfile.emoji}'
            : 'Edit Dish';
      } else {
        return 'Create Dish';
      }
    }
  }

  /// Get contextual button icon based on dish state
  IconData _getButtonIcon(bool isSpecialProfile) {
    if (isSpecialProfile) {
      return Icons.analytics;
    }

    if (widget.isReferenced) {
      // For referenced dishes
      if (_dishExists) {
        return Icons.edit;
      } else {
        return Icons.add_circle_outline;
      }
    } else {
      // For new dishes
      if (_dishExists) {
        return Icons.edit;
      } else {
        return Icons.add;
      }
    }
  }

  /// Get tooltip text for the button based on current state
  String _getButtonTooltip(AppLocalizations l10n) {
    if (widget.isReferenced) {
      if (_dishExists) {
        return 'Edit this existing dish';
      } else {
        return 'This dish is referenced but not found in your database. Tap to create it.';
      }
    } else {
      if (_dishExists) {
        return 'A dish with this name already exists. Tap to edit it.';
      } else {
        return 'Create this new dish and add it to your collection';
      }
    }
  }

  /// Get visual state color for the card border
  Color _getStateColor(ColorScheme colorScheme) {
    if (widget.isReferenced && !_dishExists) {
      return Colors.orange; // Warning color for missing referenced dishes
    } else if (!widget.isReferenced && _dishExists) {
      return Colors.blue; // Info color for duplicate names
    }
    return colorScheme.outline; // Default color
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    // Get profile colors and animation state
    final profileColor = _nutritionProfile.color;
    final isSpecialProfile = _nutritionProfile != NutritionProfile.unbalanced;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _animationController,
        _pulseController,
        _shakeController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale:
              _scaleAnimation.value *
              (_nutritionProfile == NutritionProfile.highProtein ||
                      _nutritionProfile == NutritionProfile.balanced
                  ? _pulseAnimation.value
                  : 1.0),
          child: Transform.translate(
            offset:
                _nutritionProfile == NutritionProfile.highFat
                    ? Offset(_shakeAnimation.value, 0)
                    : Offset.zero,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isSpecialProfile
                            ? isDark
                                ? [
                                  profileColor.withValues(alpha: 0.15),
                                  profileColor.withValues(alpha: 0.08),
                                ]
                                : [
                                  profileColor.withValues(alpha: 0.1),
                                  profileColor.withValues(alpha: 0.05),
                                ]
                            : isDark
                            ? [
                              colorScheme.surfaceContainer,
                              colorScheme.surfaceContainerHighest,
                            ]
                            : [
                              colorScheme.surface,
                              colorScheme.surfaceContainer,
                            ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isSpecialProfile
                            ? profileColor.withValues(alpha: 0.4)
                            : _getStateColor(
                              colorScheme,
                            ).withValues(alpha: 0.2),
                    width: isSpecialProfile ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isSpecialProfile
                              ? profileColor.withValues(alpha: 0.2)
                              : colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: isSpecialProfile ? 12 : 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile indicator badge (only for special profiles)
                      if (isSpecialProfile) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: profileColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: profileColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _nutritionProfile.icon,
                                size: 12,
                                color: profileColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _nutritionProfile.emoji,
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getProfileTitle(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: profileColor,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Dish title and calories
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.dish.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSpecialProfile
                                      ? profileColor.withValues(alpha: 0.2)
                                      : colorScheme.primary.withValues(
                                        alpha: 0.15,
                                      ),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  isSpecialProfile
                                      ? Border.all(
                                        color: profileColor.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 1,
                                      )
                                      : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSpecialProfile) ...[
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 12,
                                    color: profileColor,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  '${widget.dish.totalNutrition.calories.round()} kcal',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSpecialProfile
                                            ? profileColor
                                            : colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Nutrition indicators with profile-specific highlighting
                      _buildNutritionBar(
                        'P',
                        widget.dish.totalNutrition.protein,
                        50,
                        _getNutritionBarColor('protein'),
                        isHighlight: _shouldHighlightBar('protein'),
                      ),
                      _buildNutritionBar(
                        'C',
                        widget.dish.totalNutrition.carbs,
                        100,
                        _getNutritionBarColor('carbs'),
                        isHighlight: _shouldHighlightBar('carbs'),
                      ),
                      _buildNutritionBar(
                        'F',
                        widget.dish.totalNutrition.fat,
                        40,
                        _getNutritionBarColor('fat'),
                        isHighlight: _shouldHighlightBar('fat'),
                      ),
                      const SizedBox(height: 16), // Action buttons
                      SizedBox(
                        width: double.infinity,
                        child:
                            _dishExists
                                ? _buildLogButton(theme, colorScheme, l10n)
                                : _buildInspectButton(
                                  theme,
                                  colorScheme,
                                  l10n,
                                  isDark,
                                ),
                      ),

                      // Status badge for dish state
                      if (widget.isReferenced && !_dishExists) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Referenced dish not found',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ] else if (!widget.isReferenced && _dishExists) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Similar dish exists',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Gets the appropriate title for the current nutrition profile
  String _getProfileTitle() {
    switch (_nutritionProfile) {
      case NutritionProfile.highProtein:
        return 'High Protein';
      case NutritionProfile.highCarb:
        return 'High Carb';
      case NutritionProfile.highFat:
        return 'High Fat';
      case NutritionProfile.balanced:
        return 'Balanced';
      case NutritionProfile.unbalanced:
        return 'Analyze';
    }
  }

  /// Gets the color for nutrition bars based on profile
  Color _getNutritionBarColor(String nutrient) {
    switch (nutrient) {
      case 'protein':
        return _nutritionProfile == NutritionProfile.highProtein
            ? _nutritionProfile.color
            : Colors.green;
      case 'carbs':
        return _nutritionProfile == NutritionProfile.highCarb
            ? _nutritionProfile.color
            : Colors.blue;
      case 'fat':
        return _nutritionProfile == NutritionProfile.highFat
            ? _nutritionProfile.color
            : Colors.pink;
      default:
        return Colors.grey;
    }
  }

  /// Determines if a nutrition bar should be highlighted
  bool _shouldHighlightBar(String nutrient) {
    switch (nutrient) {
      case 'protein':
        return _nutritionProfile == NutritionProfile.highProtein;
      case 'carbs':
        return _nutritionProfile == NutritionProfile.highCarb;
      case 'fat':
        return _nutritionProfile == NutritionProfile.highFat;
      default:
        return false;
    }
  }

  Widget _buildLogButton(
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final isSpecialProfile = _nutritionProfile != NutritionProfile.unbalanced;
    final profileColor = _nutritionProfile.color;

    final buttonColors =
        isSpecialProfile
            ? [
              profileColor,
              profileColor.withBlue(
                ((profileColor.b + 30).clamp(0, 255)).toInt(),
              ),
            ]
            : [
              colorScheme.primary,
              colorScheme.primary
                  .withBlue(
                    ((colorScheme.primary.b + 20).clamp(0, 255)).toInt(),
                  )
                  .withRed(
                    ((colorScheme.primary.r - 20).clamp(0, 255)).toInt(),
                  ),
            ];

    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: buttonColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isSpecialProfile ? profileColor : colorScheme.primary)
                .withValues(alpha: 0.3),
            blurRadius: isSpecialProfile ? 6 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => widget.onLog(widget.dish),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSpecialProfile ? Icons.add_circle : Icons.add,
                size: 18,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                isSpecialProfile
                    ? '${l10n.logDish} ${_nutritionProfile.emoji}'
                    : l10n.logDish,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspectButton(
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final isSpecialProfile = _nutritionProfile != NutritionProfile.unbalanced;
    final profileColor = _nutritionProfile.color;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color:
            isSpecialProfile
                ? profileColor.withValues(alpha: isDark ? 0.3 : 0.1)
                : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isSpecialProfile
                  ? profileColor.withValues(alpha: 0.5)
                  : colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isSpecialProfile ? profileColor : colorScheme.primary)
                .withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Tooltip(
          message: _getButtonTooltip(l10n),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _loading ? null : _handleInspect,
            child:
                _loading
                    ? const Center(
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getButtonIcon(isSpecialProfile),
                          size: 18,
                          color:
                              isSpecialProfile
                                  ? profileColor
                                  : colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getButtonText(l10n, isSpecialProfile),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                isSpecialProfile
                                    ? profileColor
                                    : colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
