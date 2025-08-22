import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../../../models/dish.dart';
import '../../../models/product.dart';
import '../../scanner/barcode_scanner_screen.dart';
import '../../scanner/product_search_screen.dart';

class IngredientFormModal extends StatefulWidget {
  final Ingredient? ingredient;
  final Function(Ingredient) onSave;
  final Function(Product)? onProductScanned;

  const IngredientFormModal({
    super.key,
    this.ingredient,
    required this.onSave,
    this.onProductScanned,
  });

  @override
  State<IngredientFormModal> createState() => _IngredientFormModalState();

  static void show(
    BuildContext context, {
    Ingredient? ingredient,
    required Function(Ingredient) onSave,
    Function(Product)? onProductScanned,
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
    _nameController = TextEditingController(text: ingredient?.name ?? '');
    _quantityController = TextEditingController(
      text: ingredient?.amount.toString() ?? '',
    );
    _caloriesController = TextEditingController(
      text: ingredient?.nutrition?.calories.toString() ?? '',
    );
    _proteinController = TextEditingController(
      text: ingredient?.nutrition?.protein.toString() ?? '',
    );
    _carbsController = TextEditingController(
      text: ingredient?.nutrition?.carbs.toString() ?? '',
    );
    _fatController = TextEditingController(
      text: ingredient?.nutrition?.fat.toString() ?? '',
    );
    _fiberController = TextEditingController(
      text: ingredient?.nutrition?.fiber.toString() ?? '',
    );

    if (ingredient?.unit != null) {
      _selectedUnit = ingredient!.unit;
    }
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
        amount: double.tryParse(_quantityController.text) ?? 0,
        unit: _selectedUnit,
        nutrition: NutritionInfo(
          calories: double.tryParse(_caloriesController.text) ?? 0,
          protein: double.tryParse(_proteinController.text) ?? 0,
          carbs: double.tryParse(_carbsController.text) ?? 0,
          fat: double.tryParse(_fatController.text) ?? 0,
          fiber: double.tryParse(_fiberController.text) ?? 0,
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
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.9,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
                        ? l10n.componentsDishesDishFormIngredientFormModalAddIngredient
                        : l10n.componentsDishesDishFormIngredientFormModalEditIngredient,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
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
                      label: l10n.componentsDishesDishFormIngredientFormModalIngredientName,
                      hint: l10n.componentsDishesDishFormIngredientFormModalIngredientNamePlaceholder,
                      icon: Icons.food_bank_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.componentsDishesDishFormIngredientFormModalPleaseEnterIngredientName;
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
                            hint: l10n.componentsDishesDishFormIngredientFormModalQuantityPlaceholder,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.componentsDishesDishFormIngredientFormModalPleaseEnterQuantity;
                              }
                              if (double.tryParse(value) == null) {
                                return l10n.componentsDishesDishFormIngredientFormModalPleaseEnterValidNumber;
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
                      l10n.componentsDishesDishFormIngredientFormModalNutritionPer100g,
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
                            suffix: l10n.componentsDishesDishFormIngredientFormModalKcal,
                            icon: Icons.local_fire_department_outlined,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildNutritionField(
                            controller: _fiberController,
                            label: l10n.componentsCalendarMacroSummaryFiber,
                            suffix: l10n.componentsDishesDishFormIngredientFormModalGrams,
                            icon: Icons.grass_outlined,
                            color: Colors.green,
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
                                      label: l10n.componentsCalendarMacroSummaryProtein,
                                      suffix: l10n.componentsDishesDishFormIngredientFormModalGrams,
                                      icon: Icons.fitness_center_outlined,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildNutritionField(
                                      controller: _carbsController,
                                      label: l10n.componentsCalendarMacroSummaryCarbs,
                                      suffix: l10n.componentsDishesDishFormIngredientFormModalGrams,
                                      icon: Icons.grain_outlined,
                                      color: Colors.amber,
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
                                      label: l10n.componentsCalendarMacroSummaryFat,
                                      suffix: l10n.componentsDishesDishFormIngredientFormModalGrams,
                                      icon: Icons.water_drop_outlined,
                                      color: Colors.teal,
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
                                  label: l10n.componentsCalendarMacroSummaryProtein,
                                  suffix: l10n.componentsDishesDishFormIngredientFormModalGrams,
                                  icon: Icons.fitness_center_outlined,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildNutritionField(
                                  controller: _carbsController,
                                  label: l10n.componentsCalendarMacroSummaryCarbs,
                                  suffix: l10n.componentsDishesDishFormIngredientFormModalGrams,
                                  icon: Icons.grain_outlined,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildNutritionField(
                                  controller: _fatController,
                                  label: l10n.componentsCalendarMacroSummaryFat,
                                  suffix: l10n.componentsDishesDishFormIngredientFormModalGrams,
                                  icon: Icons.water_drop_outlined,
                                  color: Colors.teal,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
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
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                double.tryParse(value) == null) {
              return 'Please enter a valid number';
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
          'Unit',
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
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12,
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

    // Call the onProductScanned callback if provided (for dish name/image auto-fill)
    widget.onProductScanned?.call(product);

    setState(() {
      // Set ingredient name from product
      if (product.name != null) {
        _nameController.text = product.name!;
      }

      // Set default quantity to 100g
      _quantityController.text = '100';
      _selectedUnit = 'g';

      // Set nutrition data if available
      if (product.hasNutrition) {
        final nutrition = product.nutrition!;
        _caloriesController.text = nutrition.calories.toStringAsFixed(1);
        _proteinController.text = nutrition.protein.toStringAsFixed(1);
        _carbsController.text = nutrition.carbs.toStringAsFixed(1);
        _fatController.text = nutrition.fat.toStringAsFixed(1);
        _fiberController.text = nutrition.fiber.toStringAsFixed(1);
      }
    });

    // Show success message if still mounted
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Product information loaded. Adjust quantity and save.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
