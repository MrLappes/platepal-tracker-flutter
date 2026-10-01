import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/dish.dart';
import '../models/product.dart';
import '../services/storage/dish_service.dart';
import '../themes/app_theme.dart';
import '../utils/number_parsing.dart';
import '../utils/unit_conversion.dart';
import '../components/dishes/dish_form/ingredient_form_modal.dart';
import '../components/dishes/dish_form/smart_nutrition_card.dart';
import '../components/scanner/barcode_scanner_screen.dart';
import '../components/scanner/product_search_screen.dart';

/// How a new dish starts when opened from a shortcut.
enum DishCreateEntry { scanBarcode, searchProduct }

/// Copies a selected image into app documents so it outlives picker temp files.
Future<String> persistDishImage(
  File source, {
  required Directory documentsDirectory,
}) async {
  final imagesDirectory = Directory(
    path.join(documentsDirectory.path, 'dish_images'),
  );
  await imagesDirectory.create(recursive: true);
  final extension = path.extension(source.path).toLowerCase();
  final destination = File(
    path.join(imagesDirectory.path, '${const Uuid().v4()}$extension'),
  );
  await source.copy(destination.path);
  return destination.path;
}

/// Returns null if a product image fails to load or exceeds 5 MB.
Future<File?> downloadProductImage(
  Uri url, {
  required Directory temporaryDirectory,
  required http.Client client,
}) async {
  const maxBytes = 5 * 1024 * 1024;
  final response = await client.send(http.Request('GET', url));
  if (response.statusCode != 200 ||
      (response.contentLength != null && response.contentLength! > maxBytes)) {
    return null;
  }

  final bytes = BytesBuilder(copy: false);
  await for (final chunk in response.stream) {
    if (bytes.length + chunk.length > maxBytes) return null;
    bytes.add(chunk);
  }
  await temporaryDirectory.create(recursive: true);
  final extension = path.extension(url.path).toLowerCase();
  final imageExtension =
      {'.png', '.jpg', '.jpeg', '.webp'}.contains(extension)
          ? extension
          : '.jpg';
  final file = File(
    path.join(temporaryDirectory.path, '${const Uuid().v4()}$imageExtension'),
  );
  await file.writeAsBytes(bytes.takeBytes());
  return file;
}

class DishCreateScreenAdvanced extends StatefulWidget {
  final Dish? dish;
  final bool isFullScreen;
  final Function(Dish)? onDishCreated;
  final String? heroTag;
  final DishService? dishService;

  /// Opens the scanner or product search right away.
  final DishCreateEntry? entry;

  const DishCreateScreenAdvanced({
    super.key,
    this.dish,
    this.isFullScreen = false,
    this.onDishCreated,
    this.heroTag,
    this.dishService,
    this.entry,
  });

  @override
  State<DishCreateScreenAdvanced> createState() =>
      _DishCreateScreenAdvancedState();
}

class _DishCreateScreenAdvancedState extends State<DishCreateScreenAdvanced>
    with TickerProviderStateMixin {
  late final DishService _dishService = widget.dishService ?? DishService();
  final ImagePicker _imagePicker = ImagePicker(); // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _servingsController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _isDirty = false;
  bool _isFavorite = false;
  double _servings = 1;
  String? _servingsError;
  String _selectedCategory = 'breakfast';
  List<Ingredient> _ingredients = [];
  File? _selectedImage;
  bool _removeExistingImage = false;
  bool _justRecalculated = false;
  bool _didLoadDishData = false;

  String? get _existingImageUrl =>
      _removeExistingImage || widget.dish?.imageUrl?.isEmpty == true
          ? null
          : widget.dish?.imageUrl;

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

    for (final controller in [
      _nameController,
      _descriptionController,
      _caloriesController,
      _proteinController,
      _carbsController,
      _fatController,
      _fiberController,
      _servingsController,
    ]) {
      controller.addListener(_markDirty);
    }
    final entry = widget.entry;
    if (entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openEntry(entry);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDishData) return;
    _loadDishData(Localizations.localeOf(context).toString());
    _didLoadDishData = true;
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
    _servingsController.dispose();
    _recalculatedAnimationController.dispose();
    super.dispose();
  }

  void _loadDishData(String locale) {
    _servings = widget.dish?.servings ?? 1;
    _servingsController.text = formatAmount(_servings, locale);
    if (widget.dish != null) {
      final dish = widget.dish!;
      _nameController.text = dish.name;
      _descriptionController.text = dish.description ?? '';
      _caloriesController.text = _formatEditableNumber(
        dish.nutrition.calories,
        locale,
      );
      _proteinController.text = _formatEditableNumber(
        dish.nutrition.protein,
        locale,
      );
      _carbsController.text = _formatEditableNumber(
        dish.nutrition.carbs,
        locale,
      );
      _fatController.text = _formatEditableNumber(dish.nutrition.fat, locale);
      _fiberController.text = _formatEditableNumber(
        dish.nutrition.fiber,
        locale,
      );
      _isFavorite = dish.isFavorite;
      _selectedCategory = dish.category ?? 'breakfast';
      _ingredients = List.from(dish.ingredients);
    }
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

  void _markDirty() {
    if (mounted && _didLoadDishData && !_isDirty) {
      setState(() => _isDirty = true);
    }
  }

  void _onServingsChanged(String text) {
    final value = parseLocalizedDouble(text);
    final locale = Localizations.localeOf(context).toString();
    setState(() {
      if (value == null ||
          value < Dish.minServings ||
          value > Dish.maxServings) {
        _servingsError = AppLocalizations.of(
          context,
        ).componentsModalsDishLogModalAmountRange(
          formatAmount(Dish.minServings, locale),
          formatAmount(Dish.maxServings, locale),
        );
        return;
      }
      _servingsError = null;
      _servings = value;
    });
  }

  Future<void> _confirmDiscardChanges() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.screensSettingsMacroCustomizationUnsavedChanges),
            content: Text(l10n.screensDishCreateConfirmDiscardChanges),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  l10n.componentsChatBotProfileCustomizationDialogCancel,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  l10n.screensSettingsMacroCustomizationDiscardChanges,
                ),
              ),
            ],
          ),
    );
    if (discard == true && mounted) {
      setState(() => _isDirty = false);
      Navigator.of(context).pop();
    }
  }

  /// Determines if the dish should be updated (exists in DB) or created as new
  Future<bool> _shouldUpdateDish(String dishId) async {
    final existingDish = await _dishService.getDishById(dishId);
    return existingDish != null;
  }

  Future<void> _saveDish() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar(
        AppLocalizations.of(context).screensDishCreatePleaseEnterDishName,
      );
      return;
    }
    if (_servingsError != null) {
      _showErrorSnackBar(_servingsError!);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageUrl =
          _selectedImage == null
              ? _existingImageUrl
              : await persistDishImage(
                _selectedImage!,
                documentsDirectory: await getApplicationDocumentsDirectory(),
              );
      if (!mounted) return;
      final nutrition = NutritionInfo(
        calories: parseLocalizedDouble(_caloriesController.text) ?? 0.0,
        protein: parseLocalizedDouble(_proteinController.text) ?? 0.0,
        carbs: parseLocalizedDouble(_carbsController.text) ?? 0.0,
        fat: parseLocalizedDouble(_fatController.text) ?? 0.0,
        fiber: parseLocalizedDouble(_fiberController.text) ?? 0.0,
      );

      final dishData = Dish(
        id: widget.dish?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        imageUrl: imageUrl,
        ingredients: _ingredients,
        nutrition: nutrition,
        createdAt: widget.dish?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: _isFavorite,
        category: _selectedCategory,
        servings: _servings,
      );
      debugPrint('🍽️ Saving dish ID: ${dishData.id}');
      debugPrint('🍽️ Dish has ${dishData.ingredients.length} ingredients');
      final isUpdate = await _shouldUpdateDish(dishData.id);
      if (!mounted) return;

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
      if (!mounted) return;
      _isDirty = false;
      widget.onDishCreated?.call(dishData);

      if (mounted) {
        debugPrint('🍽️ Navigating back with success result...');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('❌ Error saving dish: ${e.runtimeType}');
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(context).screensDishCreateErrorSavingDish,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _removeExistingImage = false;
          _isDirty = true;
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
      debugPrint('❌ Error picking image: ${e.runtimeType}');
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
                if (_selectedImage != null || _existingImageUrl != null)
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
                        _removeExistingImage = true;
                        _isDirty = true;
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  void _addProductIngredient(Ingredient ingredient) {
    setState(() {
      _ingredients.add(ingredient);
      _isDirty = true;
      _recalculateNutrition();
    });
    _showSuccessSnackBar(
      AppLocalizations.of(context).screensDishCreateProductAddedSuccessfully,
    );
  }

  void _openEntry(DishCreateEntry entry) {
    void addProduct(Product product) {
      if (!mounted) return;
      IngredientFormModal.show(
        context,
        initialProduct: product,
        onSave: _addProductIngredient,
        onProductScanned: _updateDishFromProduct,
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => switch (entry) {
              DishCreateEntry.scanBarcode => BarcodeScannerScreen(
                onProductFound: addProduct,
                onManualEntry: (barcode) {
                  if (!mounted) return;
                  IngredientFormModal.show(
                    context,
                    initialBarcode: barcode,
                    onSave: _addProductIngredient,
                  );
                },
              ),
              DishCreateEntry.searchProduct => ProductSearchScreen(
                onProductSelected: addProduct,
              ),
            },
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
          _isDirty = true;
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
          _isDirty = true;
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
    if (_selectedImage == null &&
        _existingImageUrl == null &&
        !_removeExistingImage &&
        product.imageUrl != null) {
      _downloadAndSetProductImage(product.imageUrl!);
    }
  }

  /// Download product image and set it as dish image
  Future<void> _downloadAndSetProductImage(String imageUrl) async {
    final client = http.Client();
    try {
      debugPrint('📸 Downloading product image');
      final file = await downloadProductImage(
        Uri.parse(imageUrl),
        temporaryDirectory: await getTemporaryDirectory(),
        client: client,
      );
      if (file != null &&
          mounted &&
          _selectedImage == null &&
          !_removeExistingImage) {
        setState(() {
          _selectedImage = file;
          _isDirty = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error downloading product image: ${e.runtimeType}');
      // Don't show error to user as this is a nice-to-have feature
    } finally {
      client.close();
    }
  }

  void _recalculateNutrition() {
    final locale = Localizations.localeOf(context).toString();
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    for (final ingredient in _ingredients) {
      if (ingredient.nutrition != null) {
        final multiplier = nutritionMultiplier(
          ingredient.amount,
          ingredient.unit,
        );
        totalCalories += ingredient.nutrition!.calories * multiplier;
        totalProtein += ingredient.nutrition!.protein * multiplier;
        totalCarbs += ingredient.nutrition!.carbs * multiplier;
        totalFat += ingredient.nutrition!.fat * multiplier;
        totalFiber += ingredient.nutrition!.fiber * multiplier;
      }
    }

    setState(() {
      _caloriesController.text = formatDecimal(totalCalories, locale);
      _proteinController.text = formatDecimal(totalProtein, locale);
      _carbsController.text = formatDecimal(totalCarbs, locale);
      _fatController.text = formatDecimal(totalFat, locale);
      _fiberController.text = formatDecimal(totalFiber, locale);
      _justRecalculated = true;
    });

    _recalculatedAnimationController.forward().then((_) {
      if (!mounted) return;
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
          _isDirty = true;
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
          _isDirty = true;
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
                    _isDirty = true;
                    _recalculateNutrition();
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
    final existingImageUrl = _existingImageUrl;
    final hasImage = _selectedImage != null || existingImageUrl != null;
    final imageLabel = [
      AppLocalizations.of(context).screensDishCreateImage,
      if (_nameController.text.trim().isNotEmpty) _nameController.text.trim(),
    ].join(': ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).screensDishCreateImage.toUpperCase(),
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
              if (hasImage)
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
                    child:
                        _selectedImage != null
                            ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              semanticLabel: imageLabel,
                            )
                            : existingImageUrl!.startsWith('http://') ||
                                existingImageUrl.startsWith('https://')
                            ? Image.network(
                              existingImageUrl,
                              fit: BoxFit.cover,
                              semanticLabel: imageLabel,
                            )
                            : Image.file(
                              File(existingImageUrl),
                              fit: BoxFit.cover,
                              semanticLabel: imageLabel,
                            ),
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
                        AppLocalizations.of(
                          context,
                        ).screensDishCreateNoImageSelected,
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
                    (hasImage
                            ? AppLocalizations.of(
                              context,
                            ).screensDishCreateChangeImage
                            : AppLocalizations.of(
                              context,
                            ).screensDishCreateAddImage)
                        .toUpperCase(),
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
          AppLocalizations.of(
            context,
          ).componentsChatQuickActionsQuickActions.toUpperCase(),
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
              TextField(
                key: const ValueKey('dish-create-servings'),
                controller: _servingsController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [decimalInputFormatter],
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context).screensDishCreateRecipeMakes,
                  suffixText:
                      AppLocalizations.of(
                        context,
                      ).screensDishCreateServingsSuffix,
                  helperText:
                      AppLocalizations.of(
                        context,
                      ).screensDishCreateServingsHelper,
                  helperMaxLines: 2,
                  errorText: _servingsError,
                  errorMaxLines: 2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  prefixIcon: const Icon(Icons.people_outline, size: 18),
                ),
                onChanged: _onServingsChanged,
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
                    setState(() {
                      _selectedCategory = value;
                      _isDirty = true;
                    });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SmartNutritionCard(
          caloriesController: _caloriesController,
          proteinController: _proteinController,
          carbsController: _carbsController,
          fatController: _fatController,
          fiberController: _fiberController,
          justRecalculated: _justRecalculated,
          recalculatedAnimation: _recalculatedAnimation,
          onRecalculate: _recalculateNutrition,
        ),
        if (_servings != 1 && _servingsError == null)
          ListenableBuilder(
            listenable: Listenable.merge([
              _caloriesController,
              _proteinController,
              _carbsController,
              _fatController,
            ]),
            builder: (context, _) => _buildPerServingSummary(),
          ),
      ],
    );
  }

  Widget _buildPerServingSummary() {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    String perServing(TextEditingController controller, int digits) =>
        formatDecimal(
          (parseLocalizedDouble(controller.text) ?? 0) / _servings,
          locale,
          fractionDigits: digits,
        );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        AppLocalizations.of(context).screensDishCreatePerServingSummary(
          formatAmount(_servings, locale),
          perServing(_caloriesController, 0),
          perServing(_proteinController, 1),
          perServing(_carbsController, 1),
          perServing(_fatController, 1),
        ),
        key: const ValueKey('dish-create-per-serving'),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
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
              Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
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
                    AppLocalizations.of(
                      context,
                    ).screensDishCreateMarkAsFavorite,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                  value: _isFavorite,
                  onChanged:
                      (value) => setState(() {
                        _isFavorite = value;
                        _isDirty = true;
                      }),
                  secondary: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? colorScheme.error : null,
                    size: 20,
                  ),
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
    final macroColors = MacroColors.of(context);
    final locale = Localizations.localeOf(context).toString();

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
                      '${formatDecimal(ingredient.amount, locale)} ${ingredient.unit}',
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
                        color: macroColors.calories,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${AppLocalizations.of(context).componentsCalendarMacroSummaryCalories}: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${formatDecimal(ingredient.nutrition!.calories, locale, fractionDigits: 0)} kcal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: macroColors.calories,
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
                        '${AppLocalizations.of(context).screensDishCreateProteinAbbreviation}: ${formatDecimal(ingredient.nutrition!.protein, locale)}${AppLocalizations.of(context).componentsDishesDishFormIngredientFormModalGrams}',
                        macroColors.protein,
                        theme,
                      ),
                      _buildNutritionChip(
                        '${AppLocalizations.of(context).screensDishCreateCarbsAbbreviation}: ${formatDecimal(ingredient.nutrition!.carbs, locale)}${AppLocalizations.of(context).componentsDishesDishFormIngredientFormModalGrams}',
                        macroColors.carbs,
                        theme,
                      ),
                      _buildNutritionChip(
                        '${AppLocalizations.of(context).screensDishCreateFatAbbreviation}: ${formatDecimal(ingredient.nutrition!.fat, locale)}${AppLocalizations.of(context).componentsDishesDishFormIngredientFormModalGrams}',
                        macroColors.fat,
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
    return PopScope<Object?>(
      canPop: !_isDirty && !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isDirty && !_isLoading) {
          _confirmDiscardChanges();
        }
      },
      child: Scaffold(
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
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            112 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            children: [
              _buildImageSelector(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 16),
              _buildBasicInformation(),
              const SizedBox(height: 16),
              _buildNutritionInputs(),
              const SizedBox(height: 16),
              _buildIngredientsSection(),
              const SizedBox(height: 16),
              _buildOptionsSection(),
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
      ),
    );
  }
}
