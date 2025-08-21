import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../../models/dish.dart';
import '../../services/storage/dish_service.dart';

class DishLogModal extends StatefulWidget {
  final Dish dish;

  const DishLogModal({super.key, required this.dish});

  @override
  State<DishLogModal> createState() => _DishLogModalState();
}

class _DishLogModalState extends State<DishLogModal> {
  final DishService _dishService = DishService();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedMealType = 'breakfast';
  double _portionSize = 1.0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _mealTypes = [
    {'type': 'breakfast', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {'type': 'lunch', 'icon': Icons.wb_sunny_outlined, 'color': Colors.blue},
    {'type': 'dinner', 'icon': Icons.nightlight_round, 'color': Colors.purple},
    {'type': 'snack', 'icon': Icons.local_cafe, 'color': Colors.green},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getMealTypeDisplayName(String mealType) {
    final localizations = AppLocalizations.of(context)!;
    switch (mealType) {
      case 'breakfast':
        return localizations.breakfast;
      case 'lunch':
        return localizations.lunch;
      case 'dinner':
        return localizations.dinner;
      case 'snack':
        return localizations.snack;
      default:
        return mealType;
    }
  }

  Future<void> _saveDishLog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _dishService.logDish(
        dishId: widget.dish.id,
        loggedAt: _selectedDate,
        mealType: _selectedMealType,
        servingSize: _portionSize,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.dishLoggedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorLoggingDish),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    // Calculate nutrition based on portion size
    final calculatedCalories = widget.dish.nutrition.calories * _portionSize;
    final calculatedProtein = widget.dish.nutrition.protein * _portionSize;
    final calculatedCarbs = widget.dish.nutrition.carbs * _portionSize;
    final calculatedFat = widget.dish.nutrition.fat * _portionSize;

    return DraggableScrollableSheet(
      initialChildSize: 0.9, // 90% of screen height
      minChildSize: 0.5, // Minimum size when dragged down
      maxChildSize: 0.9, // Maximum size
      builder: (context, scrollController) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant, color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.logDishTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.dish.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Content - Make it scrollable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Selection
                        _buildSectionTitle(localizations.selectDate),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: theme.colorScheme.outline,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Meal Type Selection
                        _buildSectionTitle(localizations.selectMealType),
                        const SizedBox(height: 12),
                        Row(
                          children:
                              _mealTypes.map((mealType) {
                                final isSelected =
                                    _selectedMealType == mealType['type'];
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedMealType = mealType['type'];
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? mealType['color']
                                                      .withValues(alpha: 0.2)
                                                  : theme.colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? mealType['color']
                                                    : theme.colorScheme.outline
                                                        .withValues(alpha: 0.3),
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              mealType['icon'],
                                              color:
                                                  isSelected
                                                      ? mealType['color']
                                                      : theme
                                                          .colorScheme
                                                          .outline,
                                              size: 24,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getMealTypeDisplayName(
                                                mealType['type'],
                                              ),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        isSelected
                                                            ? mealType['color']
                                                            : theme
                                                                .colorScheme
                                                                .outline,
                                                    fontWeight:
                                                        isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.normal,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Portion Size
                        _buildSectionTitle(localizations.portionSize),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _portionSize,
                                min: 0.01, // 1% minimum portion size
                                max: 3.0, // 300% maximum
                                divisions: 299, // 299 divisions for 1% steps
                                label: '${(_portionSize * 100).round()}%',
                                onChanged: (value) {
                                  setState(() {
                                    _portionSize = value;
                                  });
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(_portionSize * 100).round()}%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Calculated Nutrition
                        _buildSectionTitle(localizations.calculatedNutrition),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildNutritionItem(
                                localizations.calories,
                                calculatedCalories.round().toString(),
                                'kcal',
                                Colors.red,
                              ),
                              _buildNutritionItem(
                                localizations.protein,
                                calculatedProtein.toStringAsFixed(1),
                                'g',
                                Colors.blue,
                              ),
                              _buildNutritionItem(
                                localizations.carbs,
                                calculatedCarbs.toStringAsFixed(1),
                                'g',
                                Colors.orange,
                              ),
                              _buildNutritionItem(
                                localizations.fat,
                                calculatedFat.toStringAsFixed(1),
                                'g',
                                Colors.purple,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Notes
                        _buildSectionTitle(localizations.notes),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            hintText: localizations.addNotes,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                        ),

                        // Add some bottom padding for better scroll experience
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                        child: Text(localizations.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveDishLog,
                        child:
                            _isLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                                : Text(localizations.save),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildNutritionItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
