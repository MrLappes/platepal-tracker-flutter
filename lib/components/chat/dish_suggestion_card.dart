import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/dish_models.dart';
import '../../services/storage/dish_service.dart';

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
    with SingleTickerProviderStateMixin {
  final DishService _dishService = DishService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _loading = false;
  bool _dishExists = false;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Start animation
    _animationController.forward();

    // Check if dish exists
    _checkDishExists();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkDishExists() async {
    if (widget.isReferenced) {
      setState(() => _dishExists = true);
      return;
    }

    try {
      final existingDishes = await _dishService.getAllDishes();
      final exists = existingDishes.any(
        (existingDish) =>
            existingDish.name.toLowerCase() == widget.dish.name.toLowerCase(),
      );
      setState(() => _dishExists = exists);
    } catch (error) {
      debugPrint('Error checking if dish exists: $error');
    }
  }

  Future<void> _handleInspect() async {
    setState(() => _loading = true);
    try {
      final result = await widget.onInspect(widget.dish);
      if (result != null) {
        setState(() => _dishExists = true);
      }
    } catch (error) {
      debugPrint('Error inspecting dish: $error');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildNutritionBar(
    String label,
    double value,
    double maxValue,
    Color color,
  ) {
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
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
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
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [
                            colorScheme.surfaceContainer,
                            colorScheme.surfaceContainerHighest,
                          ]
                          : [colorScheme.surface, colorScheme.surfaceContainer],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            color: colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.dish.totalNutrition.calories.round()} kcal',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12), // Nutrition indicators
                    _buildNutritionBar(
                      'P',
                      widget.dish.totalNutrition.protein,
                      50,
                      Colors.green,
                    ),
                    _buildNutritionBar(
                      'C',
                      widget.dish.totalNutrition.carbs,
                      100,
                      Colors.blue,
                    ),
                    _buildNutritionBar(
                      'F',
                      widget.dish.totalNutrition.fat,
                      40,
                      Colors.pink,
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogButton(
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary
                .withBlue(colorScheme.primary.blue + 20)
                .withRed(colorScheme.primary.red - 20),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 4,
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
              Icon(Icons.add, size: 18, color: colorScheme.onPrimary),
              const SizedBox(width: 6),
              Text(
                l10n.addToMeals,
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
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _loading ? null : _handleInspect,
          child: Opacity(
            opacity: _loading ? 0.7 : 1.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _loading ? Icons.hourglass_empty : Icons.visibility_outlined,
                  size: 18,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 6),
                Text(
                  _loading ? l10n.loading : l10n.details,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
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
