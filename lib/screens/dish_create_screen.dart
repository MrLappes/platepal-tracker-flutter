import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/dish.dart';
import '../services/storage/dish_service.dart';

class DishCreateScreen extends StatefulWidget {
  final Dish? dish; // If provided, we're editing; otherwise creating new
  final Function(Dish)? onDishCreated;

  const DishCreateScreen({super.key, this.dish, this.onDishCreated});

  @override
  State<DishCreateScreen> createState() => _DishCreateScreenState();
}

class _DishCreateScreenState extends State<DishCreateScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DishService _dishService = DishService();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  // Nutrition controllers
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _fiberController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _sodiumController = TextEditingController();

  // State variables
  String? _selectedCategory;
  bool _isFavorite = false;
  bool _isLoading = false;
  List<Ingredient> _ingredients = [];

  // Available categories
  final List<String> _categories = [
    'breakfast',
    'lunch',
    'dinner',
    'snack',
    'dessert',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.dish != null) {
      final dish = widget.dish!;
      _nameController.text = dish.name;
      _descriptionController.text = dish.description ?? '';
      _imageUrlController.text = dish.imageUrl ?? '';
      _selectedCategory = dish.category;
      _isFavorite = dish.isFavorite;
      _ingredients = List.from(dish.ingredients);

      // Initialize nutrition values
      _caloriesController.text = dish.nutrition.calories.toString();
      _proteinController.text = dish.nutrition.protein.toString();
      _carbsController.text = dish.nutrition.carbs.toString();
      _fatController.text = dish.nutrition.fat.toString();
      _fiberController.text = dish.nutrition.fiber.toString();
      _sugarController.text = dish.nutrition.sugar.toString();
      _sodiumController.text = dish.nutrition.sodium.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dish != null
              ? localizations.editDish
              : localizations.createDish,
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveDish,
            child: Text(
              localizations.save,
              style: TextStyle(
                color:
                    _isLoading
                        ? theme.colorScheme.outline
                        : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoSection(localizations, theme),
                      const SizedBox(height: 24),
                      _buildNutritionSection(localizations, theme),
                      const SizedBox(height: 24),
                      _buildIngredientsSection(localizations, theme),
                      const SizedBox(height: 24),
                      _buildOptionsSection(localizations, theme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildBasicInfoSection(
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.basicInformation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: localizations.dishName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.pleaseEnterDishName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: localizations.description,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: localizations.imageUrl,
                border: const OutlineInputBorder(),
                helperText: localizations.optional,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: localizations.category,
                border: const OutlineInputBorder(),
              ),
              items:
                  _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        _getCategoryDisplayName(category, localizations),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSection(
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.nutritionInfo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    decoration: InputDecoration(
                      labelText: localizations.calories,
                      border: const OutlineInputBorder(),
                      suffixText: 'kcal',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations.required;
                      }
                      if (double.tryParse(value) == null) {
                        return localizations.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    decoration: InputDecoration(
                      labelText: localizations.protein,
                      border: const OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations.required;
                      }
                      if (double.tryParse(value) == null) {
                        return localizations.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    decoration: InputDecoration(
                      labelText: localizations.carbs,
                      border: const OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations.required;
                      }
                      if (double.tryParse(value) == null) {
                        return localizations.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    decoration: InputDecoration(
                      labelText: localizations.fat,
                      border: const OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations.required;
                      }
                      if (double.tryParse(value) == null) {
                        return localizations.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fiberController,
                    decoration: InputDecoration(
                      labelText: localizations.fiber,
                      border: const OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return localizations.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sugarController,
                    decoration: InputDecoration(
                      labelText: localizations.sugar,
                      border: const OutlineInputBorder(),
                      suffixText: 'g',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return localizations.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sodiumController,
              decoration: InputDecoration(
                labelText: localizations.sodium,
                border: const OutlineInputBorder(),
                suffixText: 'mg',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null) {
                  return localizations.invalidNumber;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    localizations.ingredients,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: Text(localizations.addIngredient),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_ingredients.isEmpty)
              Text(
                localizations.noIngredientsAdded,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              )
            else
              ..._ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(ingredient.name),
                    subtitle: Text('${ingredient.amount} ${ingredient.unit}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeIngredient(index),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(AppLocalizations localizations, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.options,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(localizations.favorite),
              subtitle: Text(localizations.markAsFavorite),
              value: _isFavorite,
              onChanged: (value) {
                setState(() {
                  _isFavorite = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(
    String category,
    AppLocalizations localizations,
  ) {
    switch (category) {
      case 'breakfast':
        return localizations.breakfast;
      case 'lunch':
        return localizations.lunch;
      case 'dinner':
        return localizations.dinner;
      case 'snack':
        return localizations.snack;
      case 'dessert':
        return localizations.dessert;
      default:
        return category;
    }
  }

  void _addIngredient() {
    showDialog(
      context: context,
      builder:
          (context) => _IngredientDialog(
            onIngredientAdded: (ingredient) {
              setState(() {
                _ingredients.add(ingredient);
              });
            },
          ),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveDish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final nutrition = NutritionInfo(
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fat: double.parse(_fatController.text),
        fiber:
            _fiberController.text.isEmpty
                ? 0
                : double.parse(_fiberController.text),
        sugar:
            _sugarController.text.isEmpty
                ? 0
                : double.parse(_sugarController.text),
        sodium:
            _sodiumController.text.isEmpty
                ? 0
                : double.parse(_sodiumController.text),
      );

      final dish = Dish(
        id: widget.dish?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        imageUrl:
            _imageUrlController.text.trim().isEmpty
                ? null
                : _imageUrlController.text.trim(),
        ingredients: _ingredients,
        nutrition: nutrition,
        createdAt: widget.dish?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: _isFavorite,
        category: _selectedCategory,
      );

      if (widget.dish != null) {
        await _dishService.updateDish(dish);
      } else {
        await _dishService.saveDish(dish);
      }

      widget.onDishCreated?.call(dish);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.dish != null
                  ? AppLocalizations.of(context)!.dishUpdatedSuccessfully
                  : AppLocalizations.of(context)!.dishCreatedSuccessfully,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorSavingDish),
            backgroundColor: Theme.of(context).colorScheme.error,
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
}

class _IngredientDialog extends StatefulWidget {
  final Function(Ingredient) onIngredientAdded;

  const _IngredientDialog({required this.onIngredientAdded});

  @override
  State<_IngredientDialog> createState() => _IngredientDialogState();
}

class _IngredientDialogState extends State<_IngredientDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.addIngredient),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: localizations.ingredientName,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.pleaseEnterIngredientName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: localizations.amount,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations.required;
                      }
                      if (double.tryParse(value) == null) {
                        return localizations.invalidNumber;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: localizations.unit,
                      border: const OutlineInputBorder(),
                      hintText: 'g, ml, cup, etc.',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations.required;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: _addIngredient,
          child: Text(localizations.add),
        ),
      ],
    );
  }

  void _addIngredient() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ingredient = Ingredient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text),
      unit: _unitController.text.trim(),
      barcode: null,
      nutrition: null,
    );

    widget.onIngredientAdded(ingredient);
    Navigator.of(context).pop();
  }
}
