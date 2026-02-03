import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
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

  Future<void> _searchLocalItems(String query) async {
    final db = await _databaseService.database;
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
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );

      final products = await _openFoodFactsService.searchProducts(
        query.trim(),
        page: _currentPage,
        pageSize: 20,
        countryCode: localeProvider.locale.languageCode,
        languageCode: localeProvider.locale.languageCode,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _loadMore() {
    if (!_isSearching && _hasMoreResults) {
      setState(() => _currentPage++);
      _searchProducts(_searchController.text.trim());
    }
  }

  Widget _buildProductCard(Product product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          widget.onProductSelected?.call(product);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child:
                    product.imageUrl != null
                        ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.broken_image, size: 20),
                        )
                        : const Icon(Icons.fastfood, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (product.name ?? 'UNKNOWN').toUpperCase(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.brand != null)
                      Text(
                        product.brand!.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontSize: 9,
                        ),
                      ),
                    if (product.hasNutrition) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${product.nutrition!.calories.round()} KCAL | P:${product.nutrition!.protein.toStringAsFixed(1)}G | C:${product.nutrition!.carbs.toStringAsFixed(1)}G',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.primary),
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${localizations.componentsChatChatInputSearchProduct.toUpperCase()} //',
        ),
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
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    localizations.screensDishCreateDishNamePlaceholder
                        .toUpperCase(),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: const EdgeInsets.all(12),
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
              ),
              onChanged: (value) {
                if (value.length > 2) {
                  _searchProducts(value);
                }
              },
            ),
          ),
          Expanded(
            child:
                _isSearching && _currentPage == 1
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: [
                        if (_localIngredients.isNotEmpty ||
                            _localDishes.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'LOCAL DATABASE //',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          ..._localIngredients.map(
                            (ing) =>
                                ListTile(title: Text(ing.name.toUpperCase())),
                          ),
                          ..._localDishes.map(
                            (dish) =>
                                ListTile(title: Text(dish.name.toUpperCase())),
                          ),
                        ],
                        if (_searchResults.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'GLOBAL FEED //',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          ..._searchResults.map(_buildProductCard),
                        ],
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
