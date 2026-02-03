import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product.dart';
import '../../providers/locale_provider.dart';
import '../../services/open_food_facts_service.dart';
import '../../services/storage/database_service.dart';
import '../../services/storage/dish_service.dart';
import '../../models/dish.dart';

class ProductSearchScreen extends StatefulWidget {
  final Function(Product)? onProductSelected;
  final VoidCallback? onCancel;

  const ProductSearchScreen({super.key, this.onProductSelected, this.onCancel});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final OpenFoodFactsService _openFoodFactsService = OpenFoodFactsService();
  // Local data services and state
  final DatabaseService _databaseService = DatabaseService.instance;
  final DishService _dishService = DishService();
  List<Ingredient> _localIngredients = [];
  List<Dish> _localDishes = [];
  int _currentPage = 1;
  bool _hasMoreResults = false;
  List<Product> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.length >= 2) {
        _searchLocalItems(query);
      } else {
        setState(() {
          _localIngredients = [];
          _localDishes = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Search for local ingredients and dishes
  Future<void> _searchLocalItems(String query) async {
    final db = await _databaseService.database;
    // Search ingredients
    final ingMaps = await db.query(
      'ingredients',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
    final List<Ingredient> ingredients = [];
    for (var map in ingMaps) {
      final nutMaps = await db.query(
        'ingredient_nutrition',
        where: 'ingredient_id = ?',
        whereArgs: [map['id']],
      );
      NutritionInfo? nut;
      if (nutMaps.isNotEmpty) {
        final m = nutMaps.first;
        nut = NutritionInfo(
          calories: m['calories'] as double,
          protein: m['protein'] as double,
          carbs: m['carbs'] as double,
          fat: m['fat'] as double,
          fiber: m['fiber'] as double,
          sugar: 0.0,
          sodium: 0.0,
        );
      }
      ingredients.add(
        Ingredient(
          id: map['id'] as String,
          name: map['name'] as String,
          amount: 100.0,
          unit: 'g',
          nutrition: nut,
          barcode: map['barcode'] as String?,
        ),
      );
    }
    // Search dishes
    final allDishes = await _dishService.getAllDishes();
    final dishes =
        allDishes
            .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
    setState(() {
      _localIngredients = ingredients;
      _localDishes = dishes;
    });
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _currentPage = 1;
        _hasMoreResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      debugPrint('🔍 Searching for products: $query');

      // Get current locale for regional search filtering
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      final countryCode = localeProvider.locale.languageCode;
      final languageCode = localeProvider.locale.languageCode;

      final products = await _openFoodFactsService.searchProducts(
        query.trim(),
        page: _currentPage,
        pageSize: 20,
        countryCode: countryCode,
        languageCode: languageCode,
      );

      setState(() {
        _searchResults = products;
        _hasSearched = true;
        _isSearching = false;
        _hasMoreResults = products.length == 20;
      });

      debugPrint('✅ Found ${products.length} products');
    } catch (e) {
      debugPrint('❌ Error searching products: $e');
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).componentsScannerProductSearchErrorSearchingProduct(e.toString()),
          ),
        ),
      );
    }
  }

  /// Load more products for pagination
  void _loadMore() {
    if (!_isSearching && _hasMoreResults) {
      setState(() => _currentPage++);
      _searchProducts(_searchController.text.trim());
    }
  }

  Widget _buildProductCard(Product product) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Close the search screen and call the callback immediately
          Navigator.of(context).pop();
          widget.onProductSelected?.call(product);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child:
                    product.imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => const Icon(
                                  Icons.image_not_supported,
                                  size: 24,
                                ),
                          ),
                        )
                        : const Icon(Icons.food_bank, size: 24),
              ),

              const SizedBox(width: 16),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Unknown Product',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (product.brand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.brand!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],

                    if (product.hasNutrition) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (product.nutrition!.calories > 0) ...[
                            Text(
                              '${product.nutrition!.calories.toStringAsFixed(0)} kcal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (product.nutrition!.protein > 0 ||
                                product.nutrition!.carbs > 0 ||
                                product.nutrition!.fat > 0)
                              Text(
                                ' • ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                          ],
                          if (product.nutrition!.protein > 0) ...[
                            Text(
                              'P: ${product.nutrition!.protein.toStringAsFixed(1)}g',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            if (product.nutrition!.carbs > 0 ||
                                product.nutrition!.fat > 0)
                              Text(
                                ' • ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                          ],
                          if (product.nutrition!.carbs > 0) ...[
                            Text(
                              'C: ${product.nutrition!.carbs.toStringAsFixed(1)}g',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            if (product.nutrition!.fat > 0)
                              Text(
                                ' • ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                          ],
                          if (product.nutrition!.fat > 0)
                            Text(
                              'F: ${product.nutrition!.fat.toStringAsFixed(1)}g',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.keyboard_arrow_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.componentsScannerProductSearchProductSearch),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations.componentsScannerProductSearchSearchProducts,
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _searchProducts('');
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _searchProducts(value);
                  }
                });
              },
              onSubmitted: _searchProducts,
            ),
          ),

          // Results and local items
          Expanded(
            child:
                _isSearching && _currentPage == 1
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        if (_localIngredients.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              localizations.componentsScannerProductSearchLocalIngredients,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          ..._localIngredients.map(
                            (ing) => ListTile(
                              leading: const Icon(Icons.kitchen),
                              title: Text(ing.name),
                              subtitle:
                                  ing.nutrition != null
                                      ? Text(
                                        '${ing.nutrition!.calories.toStringAsFixed(0)} kcal/100g',
                                      )
                                      : null,
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onProductSelected?.call(
                                  Product(
                                    barcode: ing.barcode,
                                    name: ing.name,
                                    brand: null,
                                    imageUrl: null,
                                    quantity: '100 g',
                                    nutrition:
                                        ing.nutrition != null
                                            ? ProductNutrition(
                                              energyKcal100g:
                                                  ing.nutrition!.calories,
                                              proteins100g:
                                                  ing.nutrition!.protein,
                                              carbohydrates100g:
                                                  ing.nutrition!.carbs,
                                              fat100g: ing.nutrition!.fat,
                                              fiber100g: ing.nutrition!.fiber,
                                            )
                                            : ProductNutrition(),
                                    rawData: {},
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        if (_localDishes.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              localizations.componentsScannerProductSearchLocalDishes,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          ..._localDishes.map(
                            (dish) => ListTile(
                              leading:
                                  dish.imageUrl != null
                                      ? Image.network(
                                        dish.imageUrl!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                      : const Icon(Icons.restaurant_menu),
                              title: Text(dish.name),
                              subtitle: Text(
                                '${dish.nutrition.calories.toStringAsFixed(0)} kcal',
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                widget.onProductSelected?.call(
                                  Product(
                                    barcode: dish.id,
                                    name: dish.name,
                                    brand: null,
                                    imageUrl: dish.imageUrl,
                                    quantity: '1 serving',
                                    nutrition: ProductNutrition(
                                      energyKcal100g: dish.nutrition.calories,
                                      proteins100g: dish.nutrition.protein,
                                      carbohydrates100g: dish.nutrition.carbs,
                                      fat100g: dish.nutrition.fat,
                                      fiber100g: dish.nutrition.fiber,
                                    ),
                                    rawData: {},
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        if (_hasSearched &&
                            _searchResults.isEmpty &&
                            !_isSearching &&
                            _localIngredients.isEmpty &&
                            _localDishes.isEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: Text(
                                localizations
                                    .componentsScannerProductSearchNoProductsFound,
                              ),
                            ),
                          ),
                        ],
                        if (_searchResults.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Global Products (Open Food Facts)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ..._searchResults.map(_buildProductCard),
                        ],
                        if (_isSearching && _currentPage > 1)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (_hasMoreResults && !_isSearching)
                          TextButton(
                            onPressed: _loadMore,
                            child: Text(localizations.componentsScannerProductSearchLoadMore),
                          ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
