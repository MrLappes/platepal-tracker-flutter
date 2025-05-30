import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import '../models/dish.dart';
import '../services/storage/dish_service.dart';
import '../components/dishes/dish_form/ingredient_form_modal.dart';
import '../components/dishes/dish_form/smart_nutrition_card.dart';

class DishCreateScreenAdvanced extends StatefulWidget {
  final Dish? dish;
  final bool isFullScreen;
  final Function(Dish)? onDishCreated;

  const DishCreateScreenAdvanced({
    super.key,
    this.dish,
    this.isFullScreen = false,
    this.onDishCreated,
  });

  @override
  State<DishCreateScreenAdvanced> createState() =>
      _DishCreateScreenAdvancedState();
}

class _DishCreateScreenAdvancedState extends State<DishCreateScreenAdvanced>
    with TickerProviderStateMixin {
  final DishService _dishService = DishService();
  final ImagePicker _imagePicker = ImagePicker(); // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _isFavorite = false;
  String _selectedCategory = 'breakfast';
  List<Ingredient> _ingredients = [];
  File? _selectedImage;
  bool _justRecalculated = false;

  // Animation controllers
  late AnimationController _recalculatedAnimationController;
  late Animation<double> _recalculatedAnimation;

  @override
  void initState() {
    super.initState();
    _recalculatedAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _recalculatedAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _recalculatedAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _loadDishData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _recalculatedAnimationController.dispose();
    super.dispose();
  }

  void _loadDishData() {
    if (widget.dish != null) {
      final dish = widget.dish!;
      _nameController.text = dish.name;
      _descriptionController.text = dish.description ?? '';
      _caloriesController.text = dish.nutrition.calories.toString();
      _proteinController.text = dish.nutrition.protein.toString();
      _carbsController.text = dish.nutrition.carbs.toString();
      _fatController.text = dish.nutrition.fat.toString();
      _fiberController.text = dish.nutrition.fiber.toString();
      _isFavorite = dish.isFavorite;
      _selectedCategory = dish.category ?? 'breakfast';
      _ingredients = List.from(dish.ingredients);
    }
  }

  Future<void> _saveDish() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar(AppLocalizations.of(context)!.pleaseEnterDishName);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nutrition = NutritionInfo(
        calories: double.tryParse(_caloriesController.text) ?? 0.0,
        protein: double.tryParse(_proteinController.text) ?? 0.0,
        carbs: double.tryParse(_carbsController.text) ?? 0.0,
        fat: double.tryParse(_fatController.text) ?? 0.0,
        fiber: double.tryParse(_fiberController.text) ?? 0.0,
      );

      final dishData = Dish(
        id: widget.dish?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        imageUrl: _selectedImage != null ? _selectedImage!.path : null,
        ingredients: _ingredients,
        nutrition: nutrition,
        createdAt: widget.dish?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: _isFavorite,
        category: _selectedCategory,
      );
      if (widget.dish != null) {
        await _dishService.updateDish(dishData);
        _showSuccessSnackBar(
          AppLocalizations.of(context)!.dishUpdatedSuccessfully,
        );
      } else {
        await _dishService.saveDish(dishData);
        _showSuccessSnackBar(
          AppLocalizations.of(context)!.dishCreatedSuccessfully,
        );
      }

      // Call the callback if provided
      widget.onDishCreated?.call(dishData);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorSnackBar(AppLocalizations.of(context)!.errorSavingDish);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(AppLocalizations.of(context)!.camera),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(AppLocalizations.of(context)!.gallery),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      AppLocalizations.of(context)!.removeImage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  void _recalculateNutrition() {
    if (_ingredients.isEmpty) return;

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    for (final ingredient in _ingredients) {
      if (ingredient.nutrition != null) {
        final multiplier =
            ingredient.amount / 100; // Assuming nutrition is per 100g
        totalCalories += ingredient.nutrition!.calories * multiplier;
        totalProtein += ingredient.nutrition!.protein * multiplier;
        totalCarbs += ingredient.nutrition!.carbs * multiplier;
        totalFat += ingredient.nutrition!.fat * multiplier;
        totalFiber += ingredient.nutrition!.fiber * multiplier;
      }
    }

    setState(() {
      _caloriesController.text = totalCalories.toStringAsFixed(1);
      _proteinController.text = totalProtein.toStringAsFixed(1);
      _carbsController.text = totalCarbs.toStringAsFixed(1);
      _fatController.text = totalFat.toStringAsFixed(1);
      _fiberController.text = totalFiber.toStringAsFixed(1);
      _justRecalculated = true;
    });

    _recalculatedAnimationController.forward().then((_) {
      _recalculatedAnimationController.reverse();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _justRecalculated = false);
        }
      });
    });

    _showSuccessSnackBar(AppLocalizations.of(context)!.nutritionRecalculated);
  }

  void _addIngredient() {
    IngredientFormModal.show(
      context,
      onSave: (ingredient) {
        setState(() {
          _ingredients.add(ingredient);
          _recalculateNutrition();
        });
      },
    );
  }

  void _editIngredient(int index) {
    IngredientFormModal.show(
      context,
      ingredient: _ingredients[index],
      onSave: (ingredient) {
        setState(() {
          _ingredients[index] = ingredient;
          _recalculateNutrition();
        });
      },
    );
  }

  void _deleteIngredient(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteIngredient),
            content: Text(
              AppLocalizations.of(context)!.confirmDeleteIngredient,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _ingredients.removeAt(index);
                  });
                  Navigator.pop(context);
                  _showSuccessSnackBar(
                    AppLocalizations.of(context)!.ingredientDeleted,
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildImageSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 40,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No image selected',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showImageSourceSelector,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(
                      _selectedImage != null ? 'Change Image' : 'Add Image',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement barcode scanning
                      _showErrorSnackBar('Barcode scanning coming soon!');
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(AppLocalizations.of(context)!.scanBarcode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement product search
                      _showErrorSnackBar('Product search coming soon!');
                    },
                    icon: const Icon(Icons.search),
                    label: Text(AppLocalizations.of(context)!.searchProduct),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.basicInfo,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context)!.dishName} *',
                hintText: AppLocalizations.of(context)!.dishNamePlaceholder,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.restaurant),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.description,
                hintText: AppLocalizations.of(context)!.descriptionPlaceholder,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.category,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              items: [
                DropdownMenuItem(
                  value: 'breakfast',
                  child: Text(AppLocalizations.of(context)!.breakfast),
                ),
                DropdownMenuItem(
                  value: 'lunch',
                  child: Text(AppLocalizations.of(context)!.lunch),
                ),
                DropdownMenuItem(
                  value: 'dinner',
                  child: Text(AppLocalizations.of(context)!.dinner),
                ),
                DropdownMenuItem(
                  value: 'snack',
                  child: Text(AppLocalizations.of(context)!.snack),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInputs() {
    return SmartNutritionCard(
      caloriesController: _caloriesController,
      proteinController: _proteinController,
      carbsController: _carbsController,
      fatController: _fatController,
      fiberController: _fiberController,
      justRecalculated: _justRecalculated,
      recalculatedAnimation: _recalculatedAnimation,
      onRecalculate: _recalculateNutrition,
    );
  }

  Widget _buildIngredientsSection() {
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
                  AppLocalizations.of(context)!.ingredients,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.addIngredient),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_ingredients.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.noIngredientsAdded,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.restaurant,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(ingredient.name),
                    subtitle: Text('${ingredient.amount} ${ingredient.unit}'),
                    trailing: PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit, size: 20),
                                  const SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.edit),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.delete,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editIngredient(index);
                        } else if (value == 'delete') {
                          _deleteIngredient(index);
                        }
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.options,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.favorite),
              subtitle: Text(AppLocalizations.of(context)!.markAsFavorite),
              value: _isFavorite,
              onChanged: (value) => setState(() => _isFavorite = value),
              secondary: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dish != null
              ? AppLocalizations.of(context)!.editDish
              : AppLocalizations.of(context)!.createDish,
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveDish,
              child: Text(
                AppLocalizations.of(context)!.save,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImageSelector(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildBasicInformation(),
            const SizedBox(height: 16),
            _buildNutritionInputs(),
            const SizedBox(height: 16), _buildIngredientsSection(),
            const SizedBox(height: 16),
            _buildOptionsSection(),
            const SizedBox(
              height: 100,
            ), // Extra space for floating action button
          ],
        ),
      ),
      floatingActionButton:
          _isLoading
              ? null
              : FloatingActionButton.extended(
                onPressed: _saveDish,
                icon: const Icon(Icons.save),
                label: Text(
                  widget.dish != null
                      ? AppLocalizations.of(context)!.saveDish
                      : AppLocalizations.of(context)!.createDish,
                ),
              ),
    );
  }
}
