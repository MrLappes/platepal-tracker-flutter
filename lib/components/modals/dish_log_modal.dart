import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/themes/app_theme.dart';
import '../../models/dish.dart';
import '../../models/meal_type.dart';
import '../../services/storage/dish_service.dart';
import '../../services/health_service.dart';
import '../../utils/number_parsing.dart';
import '../../utils/unit_conversion.dart';

/// Combines a local calendar date with a selected meal time.
DateTime combineMealDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Allowed portion range, in servings of the dish.
const double minServings = 0.01;
const double maxServings = 20;
const double servingStep = 0.25;

/// Next servings value on the [servingStep] grid in [direction] (+1/-1),
/// kept within [servingStep]..[maxServings].
double stepServings(double servings, int direction) {
  final steps = (servings / servingStep * 1e6).round() / 1e6;
  final next =
      direction > 0
          ? (steps.floor() + 1) * servingStep
          : (steps.ceil() - 1) * servingStep;
  return next.clamp(servingStep, maxServings).toDouble();
}

/// Weight of one serving of [dish] (total ingredient weight / yield), or null
/// when its ingredients have no common weight.
({double amount, String unit})? servingWeight(Dish dish) {
  final total = totalDishWeight(
    dish.ingredients.map((i) => (amount: i.amount, unit: i.unit)),
  );
  if (total == null) return null;
  return (amount: total.amount / dish.servings, unit: total.unit);
}

/// The dish a diary entry was logged from, rebuilt from its snapshot so it
/// can be edited even when the dish was changed or deleted. [current] only
/// contributes ingredients and yield (for the weight input).
Dish dishForLog(DishLog log, {Dish? current, required String fallbackName}) {
  final servings = current?.servings ?? 1;
  double recipeTotal(double value) =>
      (log.servingSize > 0 ? value / log.servingSize : value) * servings;
  return Dish(
    id: log.dishId,
    name: log.dishName ?? current?.name ?? fallbackName,
    ingredients: current?.ingredients ?? const [],
    nutrition: NutritionInfo(
      calories: recipeTotal(log.calories),
      protein: recipeTotal(log.protein),
      carbs: recipeTotal(log.carbs),
      fat: recipeTotal(log.fat),
      fiber: recipeTotal(log.fiber),
    ),
    createdAt: log.loggedAt,
    updatedAt: log.loggedAt,
    servings: servings,
  );
}

class DishLogModal extends StatefulWidget {
  final Dish dish;
  final DateTime? initialDate;
  final String? initialMealType;

  /// When set, the sheet edits this diary entry instead of logging anew.
  final DishLog? existingLog;
  final DishService? dishService;

  const DishLogModal({
    super.key,
    required this.dish,
    this.initialDate,
    this.initialMealType,
    this.existingLog,
    this.dishService,
  });

  @override
  State<DishLogModal> createState() => _DishLogModalState();
}

class _DishLogModalState extends State<DishLogModal> {
  late final DishService _dishService = widget.dishService ?? DishService();
  final HealthService _healthService = HealthService();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  late final ({double amount, String unit})? _dishWeight = servingWeight(
    widget.dish,
  );

  late DateTime _selectedDate;
  late String _selectedMealType;
  double _portionSize = 1.0;
  bool _byWeight = false;
  String? _portionError;
  bool _controllersReady = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _mealTypes = [
    {'type': 'breakfast', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {'type': 'lunch', 'icon': Icons.wb_sunny_outlined, 'color': Colors.blue},
    {'type': 'dinner', 'icon': Icons.nightlight_round, 'color': Colors.purple},
    {'type': 'snack', 'icon': Icons.local_cafe, 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    final log = widget.existingLog;
    if (log != null) {
      _selectedDate = log.loggedAt;
      _selectedMealType = MealType.fromString(log.mealType).toJsonValue();
      _portionSize = log.servingSize;
      _notesController.text = log.notes ?? '';
      return;
    }
    final now = DateTime.now();
    _selectedDate =
        widget.initialDate == null
            ? now
            : combineMealDateAndTime(
              widget.initialDate!,
              TimeOfDay.fromDateTime(now),
            );
    _selectedMealType =
        widget.initialMealType != null
            ? MealType.fromString(widget.initialMealType!).toJsonValue()
            : defaultMealTypeForTime(_selectedDate).toJsonValue();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersReady) return;
    _controllersReady = true;
    _syncPortionFields();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _servingsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  String get _locale => Localizations.localeOf(context).toString();

  /// Writes [_portionSize] into the servings and weight fields.
  void _syncPortionFields({bool servings = true, bool weight = true}) {
    if (servings) {
      _servingsController.text = formatAmount(_portionSize, _locale);
    }
    final dishWeight = _dishWeight;
    if (weight && dishWeight != null) {
      _weightController.text = formatAmount(
        (_portionSize * dishWeight.amount).roundToDouble(),
        _locale,
      );
    }
  }

  void _stepPortion(int direction) {
    setState(() {
      _portionSize = stepServings(_portionSize, direction);
      _portionError = null;
      _syncPortionFields();
    });
  }

  void _onServingsChanged(String text) {
    final value = parseLocalizedDouble(text);
    setState(() {
      if (value == null || value < minServings || value > maxServings) {
        _portionError = AppLocalizations.of(
          context,
        ).componentsModalsDishLogModalAmountRange(
          formatAmount(minServings, _locale),
          formatAmount(maxServings, _locale),
        );
        return;
      }
      _portionError = null;
      _portionSize = value;
      _syncPortionFields(servings: false);
    });
  }

  void _onWeightChanged(String text) {
    final dishWeight = _dishWeight!;
    final value = parseLocalizedDouble(text);
    final servings = value == null ? null : value / dishWeight.amount;
    setState(() {
      if (servings == null ||
          servings < minServings ||
          servings > maxServings) {
        _portionError = AppLocalizations.of(
          context,
        ).componentsModalsDishLogModalAmountRange(
          '${formatAmount((minServings * dishWeight.amount).ceilToDouble(), _locale)} ${dishWeight.unit}',
          '${formatAmount((maxServings * dishWeight.amount).floorToDouble(), _locale)} ${dishWeight.unit}',
        );
        return;
      }
      _portionError = null;
      _portionSize = servings;
      _syncPortionFields(weight: false);
    });
  }

  void _setByWeight(bool byWeight) {
    setState(() {
      _byWeight = byWeight;
      _portionError = null;
      _syncPortionFields();
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final defaultFirst = now.subtract(const Duration(days: 365));
    final defaultLast = now.add(const Duration(days: 30));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate:
          _selectedDate.isBefore(defaultFirst) ? _selectedDate : defaultFirst,
      lastDate: _selectedDate.isAfter(defaultLast) ? _selectedDate : defaultLast,
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _selectedDate = combineMealDateAndTime(
          picked,
          TimeOfDay.fromDateTime(_selectedDate),
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _selectedDate = combineMealDateAndTime(_selectedDate, picked);
      });
    }
  }

  Future<void> _saveDishLog() async {
    if (_portionError != null) return;
    setState(() {
      _isLoading = true;
    });

    final existingLog = widget.existingLog;
    try {
      if (existingLog != null) {
        await _dishService.updateDishLog(
          existingLog,
          servingSize: _portionSize,
          loggedAt: _selectedDate,
          mealType: _selectedMealType,
          notes: _notesController.text,
        );
      } else {
        await _dishService.logDish(
          dishId: widget.dish.id,
          loggedAt: _selectedDate,
          mealType: _selectedMealType,
          servingSize: _portionSize,
          notes: _notesController.text,
        );
      }

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text(
                  existingLog != null
                      ? l10n.componentsModalsDishLogModalEntryUpdated
                      : l10n.componentsModalsDishLogModalDishLoggedSuccessfully,
                ),
              ),
              if (existingLog == null && _healthService.isConnected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.sync, color: Colors.white, size: 16),
                ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingLog != null
                ? l10n.componentsModalsDishLogModalUpdateFailed
                : l10n.componentsModalsDishLogModalErrorLoggingDish,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final macroColors = MacroColors.of(context);
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    // Calculate nutrition based on portion size
    final perServing = widget.dish.nutritionPerServing;
    final calculatedCalories = perServing.calories * _portionSize;
    final calculatedProtein = perServing.protein * _portionSize;
    final calculatedCarbs = perServing.carbs * _portionSize;
    final calculatedFat = perServing.fat * _portionSize;

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
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
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
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
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
                            widget.existingLog != null
                                ? localizations
                                    .componentsModalsDishLogModalEditTitle
                                : localizations
                                    .componentsModalsDishLogModalLogDishTitle,
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
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
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
                        // Date and time selection
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(
                                    localizations
                                        .componentsModalsDishLogModalSelectDate,
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _selectDate,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorScheme.outline
                                              .withValues(alpha: 0.5),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              MaterialLocalizations.of(
                                                context,
                                              ).formatCompactDate(
                                                _selectedDate,
                                              ),
                                              style: theme.textTheme.bodyMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(
                                    localizations
                                        .componentsModalsDishLogModalSelectTime,
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _selectTime,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.colorScheme.outline
                                              .withValues(alpha: 0.5),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              TimeOfDay.fromDateTime(
                                                _selectedDate,
                                              ).format(context),
                                              style: theme.textTheme.bodyMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Meal Type Selection
                        _buildSectionTitle(
                          localizations
                              .componentsModalsDishLogModalSelectMealType,
                        ),
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
                                    child: Semantics(
                                      button: true,
                                      selected: isSelected,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedMealType =
                                                mealType['type'];
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
                                                      : theme
                                                          .colorScheme
                                                          .outline,
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
                                                            .onSurfaceVariant,
                                                size: 24,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                MealType.fromString(
                                                  mealType['type'],
                                                ).localizedDisplayName(
                                                  localizations,
                                                ),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          isSelected
                                                              ? mealType['color']
                                                              : theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                      fontWeight:
                                                          isSelected
                                                              ? FontWeight.w600
                                                              : FontWeight
                                                                  .normal,
                                                    ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Portion Size
                        _buildSectionTitle(
                          localizations.componentsModalsDishLogModalPortionSize,
                        ),
                        const SizedBox(height: 8),
                        _buildPortionInput(theme, localizations, locale),

                        const SizedBox(height: 20),

                        // Calculated Nutrition
                        _buildSectionTitle(
                          localizations
                              .componentsModalsDishLogModalCalculatedNutrition,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildNutritionItem(
                                  localizations
                                      .componentsCalendarMacroSummaryCalories,
                                  calculatedCalories.round().toString(),
                                  'kcal',
                                  macroColors.calories,
                                ),
                              ),
                              Expanded(
                                child: _buildNutritionItem(
                                  localizations
                                      .componentsCalendarMacroSummaryProtein,
                                  formatDecimal(calculatedProtein, locale),
                                  'g',
                                  macroColors.protein,
                                ),
                              ),
                              Expanded(
                                child: _buildNutritionItem(
                                  localizations
                                      .componentsCalendarMacroSummaryCarbs,
                                  formatDecimal(calculatedCarbs, locale),
                                  'g',
                                  macroColors.carbs,
                                ),
                              ),
                              Expanded(
                                child: _buildNutritionItem(
                                  localizations
                                      .componentsCalendarMacroSummaryFat,
                                  formatDecimal(calculatedFat, locale),
                                  'g',
                                  macroColors.fat,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Notes
                        _buildSectionTitle(
                          localizations.componentsModalsDishLogModalNotes,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            hintText:
                                localizations
                                    .componentsModalsDishLogModalAddNotes,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                        ),

                        if (widget.existingLog != null &&
                            _healthService.isConnected) ...[
                          const SizedBox(height: 12),
                          Text(
                            localizations
                                .componentsModalsDishLogModalHealthEditWarning,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

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
                        child: Text(
                          localizations
                              .componentsChatBotProfileCustomizationDialogCancel,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _isLoading || _portionError != null
                                ? null
                                : _saveDishLog,
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
                                : Text(
                                  localizations
                                      .componentsChatBotProfileCustomizationDialogSave,
                                ),
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

  Widget _buildPortionInput(
    ThemeData theme,
    AppLocalizations localizations,
    String locale,
  ) {
    final dishWeight = _dishWeight;
    final byWeight = _byWeight && dishWeight != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dishWeight != null) ...[
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(localizations.componentsModalsDishLogModalServings),
              ),
              ButtonSegment(
                value: true,
                label: Text(localizations.componentsModalsDishLogModalWeight),
              ),
            ],
            selected: {byWeight},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => _setByWeight(selection.first),
          ),
          const SizedBox(height: 12),
        ],
        if (byWeight)
          TextField(
            key: const ValueKey('dish-log-weight'),
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [decimalInputFormatter],
            decoration: InputDecoration(
              labelText: localizations.componentsModalsDishLogModalAmountInUnit(
                dishWeight.unit,
              ),
              suffixText: dishWeight.unit,
              helperText: localizations
                  .componentsModalsDishLogModalServingWeight(
                    formatAmount(dishWeight.amount.roundToDouble(), locale),
                    dishWeight.unit,
                  ),
              errorText: _portionError,
              border: const OutlineInputBorder(),
            ),
            onChanged: _onWeightChanged,
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton.outlined(
                tooltip: localizations.componentsModalsDishLogModalFewerServings,
                onPressed:
                    _portionSize > servingStep ? () => _stepPortion(-1) : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  key: const ValueKey('dish-log-servings'),
                  controller: _servingsController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [decimalInputFormatter],
                  decoration: InputDecoration(
                    labelText:
                        localizations.componentsModalsDishLogModalServings,
                    errorText: _portionError,
                    errorMaxLines: 2,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: _onServingsChanged,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: localizations.componentsModalsDishLogModalMoreServings,
                onPressed:
                    _portionSize < maxServings ? () => _stepPortion(1) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
      ],
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
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
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
        ),
      ],
    );
  }
}
