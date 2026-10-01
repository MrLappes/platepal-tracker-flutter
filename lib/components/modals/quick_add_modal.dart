import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

import '../../models/dish.dart';
import '../../models/meal_type.dart';
import '../../services/chat/meal_log_proposal.dart';
import '../../services/storage/dish_service.dart';
import '../../utils/number_parsing.dart';
import 'dish_log_modal.dart';

/// Logs calories (and optional macros) without creating a catalog dish.
class QuickAddModal extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialMealType;
  final DishService? dishService;

  /// Prefill, e.g. from a chat proposal: exact time, name and nutrition.
  final DateTime? initialLoggedAt;
  final String? initialName;
  final NutritionInfo? initialNutrition;

  const QuickAddModal({
    super.key,
    this.initialDate,
    this.initialMealType,
    this.dishService,
    this.initialLoggedAt,
    this.initialName,
    this.initialNutrition,
  });

  @override
  State<QuickAddModal> createState() => _QuickAddModalState();
}

class _QuickAddModalState extends State<QuickAddModal> {
  late final DishService _dishService = widget.dishService ?? DishService();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _fiber = TextEditingController();
  late DateTime _loggedAt;
  late MealType _mealType;
  bool _isSaving = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final date = widget.initialDate;
    _loggedAt =
        widget.initialLoggedAt ??
        (date == null
            ? now
            : combineMealDateAndTime(date, TimeOfDay.fromDateTime(now)));
    _mealType =
        widget.initialMealType != null
            ? MealType.fromString(widget.initialMealType!)
            : defaultMealTypeForTime(_loggedAt);
    _name.text = widget.initialName ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nutrition = widget.initialNutrition;
    if (_prefilled || nutrition == null) return;
    _prefilled = true;
    final locale = Localizations.localeOf(context).toString();
    String amount(double value) =>
        formatAmount((value * 10).roundToDouble() / 10, locale);
    _calories.text = formatAmount(nutrition.calories.roundToDouble(), locale);
    _protein.text = amount(nutrition.protein);
    _carbs.text = amount(nutrition.carbs);
    _fat.text = amount(nutrition.fat);
    _fiber.text = amount(nutrition.fiber);
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _calories,
      _protein,
      _carbs,
      _fat,
      _fiber,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateNumber(
    String? text, {
    bool required = false,
    required double max,
  }) {
    final l10n = AppLocalizations.of(context);
    if (text == null || text.trim().isEmpty) {
      return required ? l10n.componentsModalsQuickAddCaloriesRequired : null;
    }
    final value = parseLocalizedDouble(text);
    if (value == null || value < 0) {
      return l10n.componentsModalsQuickAddInvalidNumber;
    }
    if (value > max) {
      return l10n.componentsModalsQuickAddTooLarge(
        formatAmount(max, Localizations.localeOf(context).toString()),
      );
    }
    return null;
  }

  double _number(TextEditingController controller) =>
      parseLocalizedDouble(controller.text) ?? 0;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final defaultFirst = now.subtract(const Duration(days: 365));
    final defaultLast = now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: _loggedAt,
      firstDate: _loggedAt.isBefore(defaultFirst) ? _loggedAt : defaultFirst,
      lastDate: _loggedAt.isAfter(defaultLast) ? _loggedAt : defaultLast,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _loggedAt = combineMealDateAndTime(
        picked,
        TimeOfDay.fromDateTime(_loggedAt),
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_loggedAt),
    );
    if (!mounted || picked == null) return;
    setState(() => _loggedAt = combineMealDateAndTime(_loggedAt, picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    setState(() => _isSaving = true);
    try {
      await _dishService.logQuickAdd(
        name: name.isEmpty ? l10n.componentsModalsLogFoodQuickAdd : name,
        loggedAt: _loggedAt,
        mealType: _mealType.toJsonValue(),
        calories: _number(_calories),
        protein: _number(_protein),
        carbs: _number(_carbs),
        fat: _number(_fat),
        fiber: _number(_fiber),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.componentsModalsQuickAddSaved)),
      );
    } catch (error) {
      debugPrint('Quick add failed: ${error.runtimeType}');
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.componentsModalsQuickAddFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool autofocus = false,
    double max = MealLogProposal.maxGrams,
  }) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [decimalInputFormatter],
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator:
          (text) => _validateNumber(text, required: required, max: max),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final materialL10n = MaterialLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.componentsModalsLogFoodQuickAdd.toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: materialL10n.closeButtonTooltip,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _numberField(
                    _calories,
                    l10n.componentsModalsQuickAddCalories,
                    required: true,
                    autofocus: true,
                    max: MealLogProposal.maxCalories,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _name,
                    maxLength: 200,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.componentsModalsQuickAddName,
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          _protein,
                          l10n.componentsModalsQuickAddProtein,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _numberField(
                          _carbs,
                          l10n.componentsModalsQuickAddCarbs,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _numberField(
                          _fat,
                          l10n.componentsModalsQuickAddFat,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _numberField(
                          _fiber,
                          l10n.componentsModalsQuickAddFiber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.componentsModalsDishLogModalSelectMealType,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in MealType.values)
                        ChoiceChip(
                          label: Text(type.localizedDisplayName(l10n)),
                          selected: _mealType == type,
                          onSelected: (_) => setState(() => _mealType = type),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            materialL10n.formatCompactDate(_loggedAt),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                          icon: const Icon(Icons.access_time),
                          label: Text(
                            TimeOfDay.fromDateTime(_loggedAt).format(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              l10n.componentsChatBotProfileCustomizationDialogSave,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
