import 'dart:io';
import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/dish.dart';
import '../models/product.dart';
import '../services/storage/dish_service.dart';
import '../components/dishes/dish_form/ingredient_form_modal.dart';
import '../components/dishes/dish_form/smart_nutrition_card.dart';

class DishCreateScreenAdvanced extends StatefulWidget {
  final Dish? dish;
  final bool isFullScreen;
  final Function(Dish)? onDishCreated;
  final String? heroTag;

  const DishCreateScreenAdvanced({
    super.key,
    this.dish,
    this.isFullScreen = false,
    this.onDishCreated,
    this.heroTag,
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

  /// Determines if the dish should be updated (exists in DB) or created as new
  Future<bool> _shouldUpdateDish(String dishId) async {
    try {
      final existingDish = await _dishService.getDishById(dishId);
      return existingDish != null;
    } catch (e) {
      debugPrint('🍽️ Error checking dish existence: $e');
      // If we can't check, assume it's a new dish to be safe
      return false;
    }
  }

  Future<void> _saveDish() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar(
        AppLocalizations.of(context).screensDishCreatePleaseEnterDishName,
      );
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
        imageUrl: _selectedImage?.path,
        ingredients: _ingredients,
        nutrition: nutrition,
        createdAt: widget.dish?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: _isFavorite,
        category: _selectedCategory,
      );
      debugPrint('🍽️ Saving dish: ${dishData.name} with ID: ${dishData.id}');
      debugPrint('🍽️ Dish has ${dishData.ingredients.length} ingredients');
      debugPrint(
        '🍽️ Dish nutrition: ${dishData.nutrition.calories} kcal',
      ); // Determine if this is an update or create operation
      final isUpdate = await _shouldUpdateDish(dishData.id);

      if (isUpdate) {
        debugPrint('🍽️ Updating existing dish...');
        await _dishService.updateDish(dishData);
        if (mounted) {
          _showSuccessSnackBar(
            AppLocalizations.of(
              context,
            ).screensDishCreateDishUpdatedSuccessfully,
          );
        }
      } else {
        debugPrint('🍽️ Creating new dish...');
        await _dishService.saveDish(dishData);
        if (mounted) {
          _showSuccessSnackBar(
            AppLocalizations.of(
              context,
            ).screensDishCreateDishCreatedSuccessfully,
          );
        }
      }

      debugPrint('🍽️ Dish saved successfully! Calling callback...');
      // Call the callback if provided
      widget.onDishCreated?.call(dishData);

      if (mounted) {
        debugPrint('🍽️ Navigating back with success result...');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('❌ Error saving dish: $e');
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).screensDishCreateErrorSavingDish,
        );
      }
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
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(
            context,
          ).componentsChatChatInputErrorPickingImage(e.toString()),
        );
      }
      debugPrint('❌ Error picking image: $e');
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
                  title: Text(
                    AppLocalizations.of(context).screensDishCreateCamera,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(
                    AppLocalizations.of(context).screensDishCreateGallery,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      AppLocalizations.of(context).screensDishCreateRemoveImage,
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

  void _openBarcodeScanner() {
    // Open ingredient form modal with scanner integration
    IngredientFormModal.show(
      context,
      onSave: (ingredient) {
        setState(() {
          _ingredients.add(ingredient);
          _recalculateNutrition();
        });
        _showSuccessSnackBar(
          AppLocalizations.of(
            context,
          ).screensDishCreateProductAddedSuccessfully,
        );
      },
      onProductScanned: (product) {
        // Auto-fill dish info when product is scanned from within ingredient form
        _updateDishFromProduct(product);
      },
    );
  }

  void _openProductSearch() {
    // Open ingredient form modal with search integration
    IngredientFormModal.show(
      context,
      onSave: (ingredient) {
        setState(() {
          _ingredients.add(ingredient);
          _recalculateNutrition();
        });
        _showSuccessSnackBar(
          AppLocalizations.of(
            context,
          ).screensDishCreateProductAddedSuccessfully,
        );
      },
      onProductScanned: (product) {
        // Auto-fill dish info when product is searched from within ingredient form
        _updateDishFromProduct(product);
      },
    );
  }

  /// Update dish name and image from scanned product
  void _updateDishFromProduct(Product product) {
    // Auto-set dish name if not already set
    if (_nameController.text.trim().isEmpty && product.name != null) {
      setState(() {
        _nameController.text = product.name!;
      });
    }

    // Auto-set dish image if not already set and product has image
    if (_selectedImage == null && product.imageUrl != null) {
      _downloadAndSetProductImage(product.imageUrl!);
    }
  }

  /// Download product image and set it as dish image
  Future<void> _downloadAndSetProductImage(String imageUrl) async {
    try {
      debugPrint('📸 Downloading product image: $imageUrl');

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Get the app's temporary directory
        final tempDir = await getTemporaryDirectory();

        // Create a unique filename
        final fileName =
            'product_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = path.join(tempDir.path, fileName);

        // Write the image data to file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Set the downloaded image as the dish image
        if (mounted) {
          setState(() {
            _selectedImage = file;
          });
          debugPrint('✅ Product image downloaded and set successfully');
        }
      } else {
        debugPrint('❌ Failed to download image: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error downloading product image: $e');
      // Don't show error to user as this is a nice-to-have feature
    }
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

    _showSuccessSnackBar(
      AppLocalizations.of(context).screensDishCreateNutritionRecalculated,
    );
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
            title: Text(
              AppLocalizations.of(context).screensDishCreateDeleteIngredient,
            ),
            content: Text(
              AppLocalizations.of(
                context,
              ).screensDishCreateConfirmDeleteIngredient,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).componentsChatBotProfileCustomizationDialogCancel,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _ingredients.removeAt(index);
                  });
                  Navigator.pop(context);
                  _showSuccessSnackBar(
                    AppLocalizations.of(
                      context,
                    ).screensDishCreateIngredientDeleted,
                  );
                },
                child: Text(
                  AppLocalizations.of(context).componentsDishesDishCardDelete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildImageSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IMAGE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedImage != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                )
              else
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                    ),
                    color: colorScheme.surfaceContainer,
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
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showImageSourceSelector,
                  icon: const Icon(Icons.add_a_photo, size: 16),
                  label: Text(
                    (_selectedImage != null ? 'CHANGE IMAGE' : 'ADD IMAGE'),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openBarcodeScanner,
                      icon: const Icon(Icons.qr_code_scanner, size: 16),
                      label: Text(
                        AppLocalizations.of(
                          context,
                        ).componentsChatChatInputScanBarcode.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openProductSearch,
                      icon: const Icon(Icons.search, size: 16),
                      label: Text(
                        AppLocalizations.of(
                          context,
                        ).componentsChatChatInputSearchProduct.toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInformation() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).screensDishCreateBasicInfo.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText:
                      '${AppLocalizations.of(context).componentsChatNutritionAnalysisCardDishName} *',
                  hintText:
                      AppLocalizations.of(
                        context,
                      ).screensDishCreateDishNamePlaceholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  prefixIcon: const Icon(Icons.restaurant, size: 18),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context).screensDishCreateDescription,
                  hintText:
                      AppLocalizations.of(
                        context,
                      ).screensDishCreateDescriptionPlaceholder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  prefixIcon: const Icon(Icons.description, size: 18),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context).screensDishCreateCategory,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  prefixIcon: const Icon(Icons.category, size: 18),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'breakfast',
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).componentsModalsDishLogModalBreakfast,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'lunch',
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).componentsModalsDishLogModalLunch,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'dinner',
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).componentsModalsDishLogModalDinner,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'snack',
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).componentsModalsDishLogModalSnack,
                    ),
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
      ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(
                context,
              ).componentsChatMessageBubbleIngredients.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                AppLocalizations.of(context)
                    .componentsDishesDishFormIngredientFormModalAddIngredient
                    .toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              if (_ingredients.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(
                          context,
                        ).screensDishCreateNoIngredientsAdded.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ingredients.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final ingredient = _ingredients[index];
                    return _buildIngredientCard(ingredient, index);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).screensDishCreateOptions.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  AppLocalizations.of(
                    context,
                  ).screensDishCreateFavorite.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context).screensDishCreateMarkAsFavorite,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
                value: _isFavorite,
                onChanged: (value) => setState(() => _isFavorite = value),
                secondary: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? colorScheme.error : null,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with name and actions
          Row(
            children: [
              // Ingredient icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Name and amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ingredient.amount} ${ingredient.unit}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editIngredient(index);
                  } else if (value == 'delete') {
                    _deleteIngredient(index);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).componentsDishesDishCardEdit,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).componentsDishesDishCardDelete,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),

          // Nutrition information (if available)
          if (ingredient.nutrition != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  // Calories row
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Calories: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${ingredient.nutrition!.calories.toStringAsFixed(0)} kcal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Macros row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNutritionChip(
                        'P: ${ingredient.nutrition!.protein.toStringAsFixed(1)}g',
                        Colors.blue,
                        theme,
                      ),
                      _buildNutritionChip(
                        'C: ${ingredient.nutrition!.carbs.toStringAsFixed(1)}g',
                        Colors.amber,
                        theme,
                      ),
                      _buildNutritionChip(
                        'F: ${ingredient.nutrition!.fat.toStringAsFixed(1)}g',
                        Colors.teal,
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionChip(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
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
              ? '${AppLocalizations.of(context).screensDishCreateEditDish.toUpperCase()} //'
              : '${AppLocalizations.of(context).screensDishCreateCreateDish.toUpperCase()} //',
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
                AppLocalizations.of(
                  context,
                ).componentsChatBotProfileCustomizationDialogSave,
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
                heroTag:
                    widget.heroTag ??
                    "dish_create_fab_${DateTime.now().millisecondsSinceEpoch}",
                onPressed: _saveDish,
                icon: const Icon(Icons.save),
                label: Text(
                  widget.dish != null
                      ? AppLocalizations.of(context).screensDishCreateSaveDish
                      : AppLocalizations.of(
                        context,
                      ).screensDishCreateCreateDish,
                ),
              ),
    );
  }
}
