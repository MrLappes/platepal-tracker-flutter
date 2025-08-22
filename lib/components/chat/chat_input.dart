import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../../models/user_ingredient.dart';
import '../../models/product.dart';
import '../scanner/barcode_scanner_screen.dart';
import '../scanner/product_search_screen.dart';
import '../dishes/dish_form/ingredient_form_modal.dart';
import '../../utils/product_converter.dart';

class ChatInput extends StatefulWidget {
  final Function(
    String message, {
    String? imageUrl,
    List<UserIngredient>? ingredients,
  })
  onSendMessage;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  final List<UserIngredient> _selectedIngredients = [];
  bool _hasText = false;
  bool _showMenu = false;
  late AnimationController _animationController;
  late Animation<double> _menuAnimation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _menuAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;
      if (_showMenu) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Stack(
      children: [
        // Overlay for tapping outside the menu
        if (_showMenu)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
        // Main content
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated menu
            SizeTransition(
              sizeFactor: _menuAnimation,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.0, // More square for larger icons
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          _buildMenuOption(
                            icon: Icons.camera_alt,
                            label: localizations.componentsChatBotProfileCustomizationDialogTakePhoto,
                            onTap: () {
                              _toggleMenu();
                              _pickImage(ImageSource.camera);
                            },
                            theme: theme,
                          ),
                          _buildMenuOption(
                            icon: Icons.photo_library,
                            label: localizations.componentsChatBotProfileCustomizationDialogChooseFromGallery,
                            onTap: () {
                              _toggleMenu();
                              _pickImage(ImageSource.gallery);
                            },
                            theme: theme,
                          ),
                          _buildMenuOption(
                            icon: Icons.barcode_reader,
                            label: localizations.componentsChatChatInputScanBarcode,
                            onTap: () {
                              _toggleMenu();
                              _openBarcodeScanner();
                            },
                            theme: theme,
                          ),
                          _buildMenuOption(
                            icon: Icons.search,
                            label: localizations.componentsChatChatInputSearchProduct,
                            onTap: () {
                              _toggleMenu();
                              _openProductSearch();
                            },
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Input container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedImage != null) _buildImagePreview(context),
                  if (_selectedIngredients.isNotEmpty)
                    _buildIngredientsPreview(context),
                  Row(
                    children: [
                      // Plus button that rotates to an X
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return InkWell(
                            onTap: widget.isLoading ? null : _toggleMenu,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    _showMenu
                                        ? theme.colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        )
                                        : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Transform.rotate(
                                  angle: _animationController.value * 0.785,
                                  child: Icon(
                                    Icons.add,
                                    size: 24,
                                    color:
                                        _showMenu
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _controller,
                            enabled: !widget.isLoading,
                            decoration: InputDecoration(
                              hintText: localizations.componentsChatChatInputTypeMessage,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              (_hasText ||
                                          _selectedImage != null ||
                                          _selectedIngredients.isNotEmpty) &&
                                      !widget.isLoading
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed:
                              (_hasText ||
                                          _selectedImage != null ||
                                          _selectedIngredients.isNotEmpty) &&
                                      !widget.isLoading
                                  ? _sendMessage
                                  : null,
                          icon:
                              widget.isLoading
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                  : Icon(
                                    Icons.send,
                                    size: 20,
                                    color:
                                        (_hasText || _selectedImage != null)
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.4),
                                  ),
                          tooltip: localizations.componentsChatChatInputSendMessage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, // Larger container for icon
              height: 64, // Larger container for icon
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 36, // Larger icon size (90% of available space)
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.componentsChatChatInputImageAttached,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.2,
                          ),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsPreview(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.componentsChatChatInputIngredientsAdded,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _selectedIngredients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ingredient = entry.value;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${ingredient.name} (${ingredient.quantity}${ingredient.unit})',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeIngredient(index),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).componentsChatChatInputImageAttached),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).componentsChatChatInputErrorPickingImage(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty &&
        _selectedImage == null &&
        _selectedIngredients.isEmpty) {
      return;
    }

    // Debug: Print what we're about to send
    debugPrint(
      '🔍 DEBUG: Sending message with ${_selectedIngredients.length} ingredients',
    );
    for (final ingredient in _selectedIngredients) {
      debugPrint(
        '   - ${ingredient.name} (${ingredient.quantity}${ingredient.unit})',
      );
    }

    // For now, we'll pass the file path as imageUrl
    // In a real app, you'd upload the image to a server first
    final imageUrl = _selectedImage?.path;

    // Make a copy of ingredients before clearing
    final ingredientsCopy = List<UserIngredient>.from(_selectedIngredients);

    // Close the menu if it's open
    if (_showMenu) {
      _toggleMenu();
    }

    // Clear UI immediately
    _controller.clear();
    setState(() {
      _selectedImage = null;
      _selectedIngredients.clear();
      _hasText = false;
    }); // Send message with the copied ingredients
    widget.onSendMessage(
      message,
      imageUrl: imageUrl,
      ingredients: ingredientsCopy.isNotEmpty ? ingredientsCopy : null,
    );
  }

  void _openBarcodeScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BarcodeScannerScreen(
              onProductFound: (product) {
                _addProductAsIngredient(product);
              },
            ),
      ),
    );
  }

  void _openProductSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ProductSearchScreen(
              onProductSelected: (product) {
                _addProductAsIngredient(product);
              },
            ),
      ),
    );
  }

  void _addProductAsIngredient(Product product) {
    // Convert product to ingredient with default 100g serving
    final defaultIngredient =
        ProductToIngredientConverter.convertProductToIngredient(
          product,
          amount: 100.0,
          unit: 'g',
        );

    // Show ingredient form modal pre-filled with product data
    IngredientFormModal.show(
      context,
      ingredient: defaultIngredient,
      onSave: (ingredient) {
        // Convert Ingredient to UserIngredient
        final userIngredient = UserIngredient(
          id: ingredient.id,
          name: ingredient.name,
          quantity: ingredient.amount,
          unit: ingredient.unit,
          barcode: product.barcode,
          scannedAt: DateTime.now(),
          metadata: {
            'productName': product.name,
            'brand': product.brand,
            'nutrition': ingredient.nutrition?.toJson(),
          },
        );

        setState(() {
          _selectedIngredients.add(userIngredient);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ingredient added to chat'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _selectedIngredients.removeAt(index);
    });
  }

  // ...existing code...
}
