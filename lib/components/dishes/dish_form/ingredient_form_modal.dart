import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/themes/app_theme.dart';
import '../../../models/dish.dart';
import '../../../models/product.dart';
import '../../../utils/number_parsing.dart';
import '../../scanner/barcode_scanner_screen.dart';
import '../../scanner/product_search_screen.dart';

class IngredientFormModal extends StatefulWidget {
  final Ingredient? ingredient;
  final Function(Ingredient) onSave;
  final Function(Product)? onProductScanned;

  /// Barcode of an unknown product the user enters by hand.
  final String? initialBarcode;

  /// Product to prefill the form with when it opens.
  final Product? initialProduct;

  const IngredientFormModal({
    super.key,
    this.ingredient,
    required this.onSave,
    this.onProductScanned,
    this.initialBarcode,
    this.initialProduct,
  });

  @override
  State<IngredientFormModal> createState() => _IngredientFormModalState();

  static void show(
    BuildContext context, {
    Ingredient? ingredient,
    required Function(Ingredient) onSave,
    Function(Product)? onProductScanned,
    String? initialBarcode,
    Product? initialProduct,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => IngredientFormModal(
            ingredient: ingredient,
            onSave: onSave,
            onProductScanned: onProductScanned,
            initialBarcode: initialBarcode,
            initialProduct: initialProduct,
          ),
    );
  }
}

class _IngredientFormModalState extends State<IngredientFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;
  String? _barcode;
  bool _didPrefillIngredient = false;

  String _selectedUnit = 'g';
  final List<String> _commonUnits = [
    'g',
    'ml',
    'cup',
    'tbsp',
    'tsp',
    'oz',
    'piece',
    'slice',
  ];

  @override
  void initState() {
    super.initState();
    final ingredient = widget.ingredient;
    _barcode = ingredient?.barcode ?? widget.initialBarcode;
    _nameController = TextEditingController(text: ingredient?.name ?? '');
    _quantityController = TextEditingController();
    _caloriesController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatController = TextEditingController();
    _fiberController = TextEditingController();

    if (ingredient?.unit != null) {
      _selectedUnit = ingredient!.unit;
    }
    final product = widget.initialProduct;
    if (product != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _prefillFormWithProduct(product),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrefillIngredient) return;
    _didPrefillIngredient = true;
    final ingredient = widget.ingredient;
    if (ingredient == null) return;
    final locale = Localizations.localeOf(context).toString();
    if (ingredient.amount > 0) {
      _quantityController.text = _formatEditableNumber(
        ingredient.amount,
        locale,
      );
    }
    final nutrition = ingredient.nutrition;
    if (nutrition == null) return;
    _caloriesController.text = _formatEditableNumber(
      nutrition.calories,
      locale,
    );
    _proteinController.text = _formatEditableNumber(nutrition.protein, locale);
    _carbsController.text = _formatEditableNumber(nutrition.carbs, locale);
    _fatController.text = _formatEditableNumber(nutrition.fat, locale);
    _fiberController.text = _formatEditableNumber(nutrition.fiber, locale);
  }

  String _formatEditableNumber(double value, String locale) {
    final text = value.toString();
    final exponentIndex = text.indexOf('e');
    final decimalIndex = text.indexOf('.');
    final fractionDigits =
        decimalIndex == -1
            ? 0
            : (exponentIndex == -1 ? text.length : exponentIndex) -
                decimalIndex -
                1;
    final exponent =
        exponentIndex == -1 ? 0 : int.parse(text.substring(exponentIndex + 1));
    final digits = fractionDigits - exponent;
    return formatDecimal(
      value,
      locale,
      fractionDigits: digits > 0 ? digits : 1,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  void _saveIngredient() {
    if (_formKey.currentState!.validate()) {
      final ingredient = Ingredient(
        id:
            widget.ingredient?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        amount: parseLocalizedDouble(_quantityController.text)!,
        unit: _selectedUnit,
        barcode: _barcode,
        nutrition: NutritionInfo(
          calories: parseLocalizedDouble(_caloriesController.text) ?? 0,
          protein: parseLocalizedDouble(_proteinController.text) ?? 0,
          carbs: parseLocalizedDouble(_carbsController.text) ?? 0,
          fat: parseLocalizedDouble(_fatController.text) ?? 0,
          fiber: parseLocalizedDouble(_fiberController.text) ?? 0,
        ),
      );
      widget.onSave(ingredient);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final macroColors = MacroColors.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.9,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.ingredient == null
                        ? l10n
                            .componentsDishesDishFormIngredientFormModalAddIngredient
                        : l10n
                            .componentsDishesDishFormIngredientFormModalEditIngredient,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.qr_code_scanner,
                    label: l10n.componentsChatChatInputScanBarcode,
                    onTap: _openBarcodeScanner,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.search,
                    label: l10n.componentsChatChatInputSearchProduct,
                    onTap: _openProductSearch,
                  ),
                ),
              ],
            ),
          ),

          if (_barcode != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.componentsDishesDishFormIngredientFormModalBarcode(
                      _barcode!,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ingredient Name
                    _buildModernTextField(
                      controller: _nameController,
                      label:
                          l10n.componentsDishesDishFormIngredientFormModalIngredientName,
                      hint:
                          l10n.componentsDishesDishFormIngredientFormModalIngredientNamePlaceholder,
                      icon: Icons.food_bank_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n
                              .componentsDishesDishFormIngredientFormModalPleaseEnterIngredientName;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Quantity and Unit
                    Text(
                      l10n.componentsDishesDishFormIngredientFormModalQuantity,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildModernTextField(
                            controller: _quantityController,
                            label: '',
                            hint:
                                l10n.componentsDishesDishFormIngredientFormModalQuantityPlaceholder,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [decimalInputFormatter],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n
                                    .componentsDishesDishFormIngredientFormModalPleaseEnterQuantity;
                              }
                              final quantity = parseLocalizedDouble(value);
                              if (quantity == null || quantity <= 0) {
                                return l10n
                                    .componentsDishesDishFormIngredientFormModalPleaseEnterValidNumber;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(flex: 3, child: _buildUnitSelector()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Nutrition Section
                    Text(
                      l10n.componentsDishesDishFormIngredientFormModalNutritionInformation,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      switch (_selectedUnit) {
                        'piece' =>
                          l10n.componentsDishesDishFormIngredientFormModalNutritionPerPiece,
                        'slice' =>
                          l10n.componentsDishesDishFormIngredientFormModalNutritionPerSlice,
                        _ =>
                          l10n.componentsDishesDishFormIngredientFormModalNutritionPer100g,
                      },
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), // Calories and Fiber
                    Row(
                      children: [
                        Expanded(
                          child: _buildNutritionField(
                            controller: _caloriesController,
                            label: l10n.componentsCalendarMacroSummaryCalories,
                            suffix:
                                l10n.componentsDishesDishFormIngredientFormModalKcal,
                            icon: Icons.local_fire_department_outlined,
                            color: macroColors.calories,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNutritionField(
                            controller: _fiberController,
                            label: l10n.componentsCalendarMacroSummaryFiber,
                            suffix:
                                l10n.componentsDishesDishFormIngredientFormModalGrams,
                            icon: Icons.grass_outlined,
                            color: macroColors.fiber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Macronutrients - responsive layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 400;

                        if (isNarrow) {
                          // Narrow screen: 2 fields per row max
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNutritionField(
                                      controller: _proteinController,
                                      label:
                                          l10n.componentsCalendarMacroSummaryProtein,
                                      suffix:
                                          l10n.componentsDishesDishFormIngredientFormModalGrams,
                                      icon: Icons.fitness_center_outlined,
                                      color: macroColors.protein,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildNutritionField(
                                      controller: _carbsController,
                                      label:
                                          l10n.componentsCalendarMacroSummaryCarbs,
                                      suffix:
                                          l10n.componentsDishesDishFormIngredientFormModalGrams,
                                      icon: Icons.grain_outlined,
                                      color: macroColors.carbs,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildNutritionField(
                                      controller: _fatController,
                                      label:
                                          l10n.componentsCalendarMacroSummaryFat,
                                      suffix:
                                          l10n.componentsDishesDishFormIngredientFormModalGrams,
                                      icon: Icons.water_drop_outlined,
                                      color: macroColors.fat,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Empty space to maintain layout consistency
                                  const Expanded(child: SizedBox()),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Wide screen: 3 fields in one row
                          return Row(
                            children: [
                              Expanded(
                                child: _buildNutritionField(
                                  controller: _proteinController,
                                  label:
                                      l10n.componentsCalendarMacroSummaryProtein,
                                  suffix:
                                      l10n.componentsDishesDishFormIngredientFormModalGrams,
                                  icon: Icons.fitness_center_outlined,
                                  color: macroColors.protein,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildNutritionField(
                                  controller: _carbsController,
                                  label:
                                      l10n.componentsCalendarMacroSummaryCarbs,
                                  suffix:
                                      l10n.componentsDishesDishFormIngredientFormModalGrams,
                                  icon: Icons.grain_outlined,
                                  color: macroColors.carbs,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildNutritionField(
                                  controller: _fatController,
                                  label: l10n.componentsCalendarMacroSummaryFat,
                                  suffix:
                                      l10n.componentsDishesDishFormIngredientFormModalGrams,
                                  icon: Icons.water_drop_outlined,
                                  color: macroColors.fat,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: colorScheme.onSurfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outline),
                        ),
                      ),
                      child: Text(
                        l10n.componentsChatBotProfileCustomizationDialogCancel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.componentsChatBotProfileCustomizationDialogSave,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
          color: colorScheme.surfaceContainer,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
          inputFormatters: [decimalInputFormatter],
          decoration: InputDecoration(
            hintText: '0',
            suffixText: suffix,
            suffixStyle: TextStyle(color: color),
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
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                parseLocalizedDouble(value) == null) {
              return AppLocalizations.of(
                context,
              ).componentsDishesDishFormIngredientFormModalPleaseEnterValidNumber;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    String? suffix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            prefixIcon:
                icon != null
                    ? Icon(icon, size: 20, color: colorScheme.onSurfaceVariant)
                    : null,
            suffixText: suffix,
            suffixStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildUnitSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(
            context,
          ).componentsDishesDishFormIngredientFormModalUnit,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                _commonUnits.map((unit) {
                  final isSelected = _selectedUnit == unit;
                  return InkWell(
                    onTap: () => setState(() => _selectedUnit = unit),
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Center(
                        widthFactor: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                            ),
                          ),
                          child: Text(
                            unit,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  /// Open barcode scanner to add product as ingredient
  void _openBarcodeScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BarcodeScannerScreen(
              onProductFound: (product) {
                _prefillFormWithProduct(product);
              },
              onManualEntry: (barcode) {
                if (mounted) setState(() => _barcode = barcode);
              },
            ),
      ),
    );
  }

  /// Open product search to add product as ingredient
  void _openProductSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ProductSearchScreen(
              onProductSelected: (product) {
                _prefillFormWithProduct(product);
              },
            ),
      ),
    );
  }

  /// Pre-fill form with product data
  void _prefillFormWithProduct(Product product) {
    // Check if widget is still mounted before calling setState
    if (!mounted) return;
    final locale = Localizations.localeOf(context).toString();

    // Call the onProductScanned callback if provided (for dish name/image auto-fill)
    widget.onProductScanned?.call(product);

    setState(() {
      _barcode = product.barcode;
      // Set ingredient name from product
      if (product.name != null) {
        _nameController.text = product.name!;
      }

      final servingNutrition = product.servingNutrition;
      _quantityController.text = servingNutrition == null ? '100' : '1';
      _selectedUnit = servingNutrition == null ? 'g' : 'piece';

      // Set nutrition data if available
      if (servingNutrition != null || product.hasNutrition) {
        final nutrition = product.nutrition;
        _caloriesController.text = formatDecimal(
          servingNutrition?.calories ?? nutrition?.calories ?? 0,
          locale,
        );
        _proteinController.text = formatDecimal(
          servingNutrition?.protein ?? nutrition?.protein ?? 0,
          locale,
        );
        _carbsController.text = formatDecimal(
          servingNutrition?.carbs ?? nutrition?.carbs ?? 0,
          locale,
        );
        _fatController.text = formatDecimal(
          servingNutrition?.fat ?? nutrition?.fat ?? 0,
          locale,
        );
        _fiberController.text = formatDecimal(
          servingNutrition?.fiber ?? nutrition?.fiber ?? 0,
          locale,
        );
      }
    });

    // Show success message if still mounted
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).componentsDishesDishFormIngredientFormModalProductInformationLoaded,
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
