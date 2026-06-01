import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dish.dart';
import '../../models/product.dart';
import '../../providers/locale_provider.dart';
import '../../services/open_food_facts_service.dart';
import '../../services/storage/database_service.dart';
import '../../services/storage/dish_service.dart';
import '../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Nutri-Score colour helpers
// ─────────────────────────────────────────────────────────────────────────────

Color _nutriColor(NutriScoreGrade g) {
  switch (g) {
    case NutriScoreGrade.a:
      return const Color(0xFF1A7D37);
    case NutriScoreGrade.b:
      return const Color(0xFF75B72A);
    case NutriScoreGrade.c:
      return const Color(0xFFEFBF0F);
    case NutriScoreGrade.d:
      return const Color(0xFFE87920);
    case NutriScoreGrade.e:
      return const Color(0xFFE63E11);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class ProductSearchScreen extends StatefulWidget {
  final Function(Product)? onProductSelected;
  final VoidCallback? onCancel;

  const ProductSearchScreen({super.key, this.onProductSelected, this.onCancel});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Services
  final OpenFoodFactsService _offService = OpenFoodFactsService();
  final DatabaseService _databaseService = DatabaseService.instance;
  final DishService _dishService = DishService();

  // Filter state
  OFFCategory _selectedCategory = OFFCategory.all.first; // "All"
  NutriScoreGrade? _selectedNutriScore;
  OFFSortBy _sortBy = OFFSortBy.popularity;
  bool _showFilters = false;

  // Results
  List<Product> _searchResults = [];
  List<Ingredient> _localIngredients = [];
  List<Dish> _localDishes = [];

  // Pagination
  int _currentPage = 1;
  bool _hasMoreResults = false;
  bool _isSearching = false;
  bool _isBrowsing = false; // category browse without text

  // Debounce
  Timer? _debounceTimer;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _scrollController.addListener(_onScroll);
    // On open, show popular products for the selected category
    _triggerBrowse();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Event handlers ─────────────────────────────────────────────────────────

  void _onSearchTextChanged() {
    final q = _searchController.text.trim();
    _debounceTimer?.cancel();

    if (q.isEmpty) {
      _triggerBrowse(); // switch back to browse mode
      return;
    }

    // Local instant search
    if (q.length >= 2) _searchLocalItems(q);

    // Remote debounced (avoid 10 req/min rate limit)
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (q.length >= 2) _triggerSearch(q, isNewSearch: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  void _onCategoryChanged(OFFCategory cat) {
    setState(() {
      _selectedCategory = cat;
      _searchResults = [];
      _currentPage = 1;
    });
    if (_searchController.text.trim().isEmpty) {
      _triggerBrowse();
    } else {
      _triggerSearch(_searchController.text.trim(), isNewSearch: true);
    }
  }

  void _onNutriScoreChanged(NutriScoreGrade? grade) {
    setState(() {
      _selectedNutriScore = grade;
      _searchResults = [];
      _currentPage = 1;
    });
    if (_searchController.text.trim().isEmpty) {
      _triggerBrowse();
    } else {
      _triggerSearch(_searchController.text.trim(), isNewSearch: true);
    }
  }

  void _onSortChanged(OFFSortBy sort) {
    setState(() {
      _sortBy = sort;
      _searchResults = [];
      _currentPage = 1;
    });
    if (_searchController.text.trim().isEmpty) {
      _triggerBrowse();
    } else {
      _triggerSearch(_searchController.text.trim(), isNewSearch: true);
    }
  }

  // ── Data fetching ──────────────────────────────────────────────────────────

  Future<void> _searchLocalItems(String query) async {
    final db = await _databaseService.database;
    final ingMaps = await db.query(
      'ingredients',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      limit: 10,
    );

    final ingredients = <Ingredient>[];
    for (final map in ingMaps) {
      final nutMaps = await db.query(
        'ingredient_nutrition',
        where: 'ingredient_id = ?',
        whereArgs: [map['id']],
      );
      NutritionInfo? nut;
      if (nutMaps.isNotEmpty) {
        final m = nutMaps.first;
        nut = NutritionInfo(
          calories: (m['calories'] as num?)?.toDouble() ?? 0.0,
          protein: (m['protein'] as num?)?.toDouble() ?? 0.0,
          carbs: (m['carbs'] as num?)?.toDouble() ?? 0.0,
          fat: (m['fat'] as num?)?.toDouble() ?? 0.0,
          fiber: (m['fiber'] as num?)?.toDouble() ?? 0.0,
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
            .take(5)
            .toList();

    if (mounted) {
      setState(() {
        _localIngredients = ingredients;
        _localDishes = dishes;
      });
    }
  }

  Future<void> _triggerSearch(String query, {bool isNewSearch = true}) async {
    if (_isSearching) return;

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    setState(() {
      _isSearching = true;
      _isBrowsing = false;
      if (isNewSearch) {
        _currentPage = 1;
        _searchResults = [];
      }
    });

    try {
      final products = await _offService.searchProducts(
        query,
        page: _currentPage,
        pageSize: 20,
        countryCode: localeProvider.locale.languageCode,
        languageCode: localeProvider.locale.languageCode,
        category: _selectedCategory.tag.isNotEmpty ? _selectedCategory : null,
        nutriScore: _selectedNutriScore,
        sortBy: _sortBy,
      );

      if (!mounted) return;
      setState(() {
        if (isNewSearch) {
          _searchResults = products;
        } else {
          _searchResults.addAll(products);
        }
        _isSearching = false;
        _hasMoreResults = products.length == 20;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search error: $e')));
    }
  }

  Future<void> _triggerBrowse() async {
    if (_isBrowsing) return;

    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    setState(() {
      _isBrowsing = true;
      _isSearching = true;
      _localIngredients = [];
      _localDishes = [];
      _searchResults = [];
      _currentPage = 1;
    });

    try {
      final products = await _offService.browseCategory(
        _selectedCategory,
        page: 1,
        pageSize: 20,
        nutriScore: _selectedNutriScore,
        sortBy: _sortBy,
        languageCode: localeProvider.locale.languageCode,
      );

      if (!mounted) return;
      setState(() {
        _searchResults = products;
        _isSearching = false;
        _hasMoreResults = products.length == 20;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _isBrowsing = false;
      });
    }
  }

  void _loadMore() {
    if (_isSearching || !_hasMoreResults) return;
    final query = _searchController.text.trim();
    setState(() => _currentPage++);
    if (query.isNotEmpty) {
      _triggerSearch(query, isNewSearch: false);
    } else {
      _loadMoreBrowse();
    }
  }

  Future<void> _loadMoreBrowse() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    setState(() => _isSearching = true);

    try {
      final products = await _offService.browseCategory(
        _selectedCategory,
        page: _currentPage,
        pageSize: 20,
        nutriScore: _selectedNutriScore,
        sortBy: _sortBy,
        languageCode: localeProvider.locale.languageCode,
      );

      if (!mounted) return;
      setState(() {
        _searchResults.addAll(products);
        _isSearching = false;
        _hasMoreResults = products.length == 20;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  // ── Widget builders ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color:
                  (_selectedNutriScore != null ||
                          _sortBy != OFFSortBy.popularity)
                      ? colorScheme.primary
                      : null,
            ),
            tooltip: 'Filters & Sort',
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search field ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              autofocus: false,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _localIngredients = [];
                              _localDishes = [];
                            });
                            _triggerBrowse();
                          },
                        )
                        : null,
              ),
            ),
          ),

          // ── Category chips ──────────────────────────────────────────────
          const SizedBox(height: 8),
          _buildCategoryChips(theme, colorScheme),

          // ── Expanded filters (nutri-score + sort) ──────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child:
                _showFilters
                    ? _buildExpandedFilters(theme, colorScheme)
                    : const SizedBox.shrink(),
          ),

          // ── Results ─────────────────────────────────────────────────────
          Expanded(
            child:
                _isSearching && _currentPage == 1
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty &&
                        _localIngredients.isEmpty &&
                        _localDishes.isEmpty &&
                        !_isSearching
                    ? _buildEmptyState(theme, colorScheme)
                    : _buildResultsList(theme, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: OFFCategory.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final cat = OFFCategory.all[i];
          final selected = _selectedCategory.tag == cat.tag;
          return GestureDetector(
            onTap: () => _onCategoryChanged(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    selected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      selected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    cat.label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color:
                          selected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandedFilters(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // — Nutri-Score
          Row(
            children: [
              Text(
                'NUTRI-SCORE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: [
                    // "Any" pill
                    GestureDetector(
                      onTap: () => _onNutriScoreChanged(null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _selectedNutriScore == null
                                  ? colorScheme.primary
                                  : colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                _selectedNutriScore == null
                                    ? colorScheme.primary
                                    : colorScheme.outline.withValues(
                                      alpha: 0.5,
                                    ),
                          ),
                        ),
                        child: Text(
                          'ANY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color:
                                _selectedNutriScore == null
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                    ...NutriScoreGrade.values.map((g) {
                      final selected = _selectedNutriScore == g;
                      final bg = _nutriColor(g);
                      return GestureDetector(
                        onTap: () => _onNutriScoreChanged(selected ? null : g),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? bg : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  selected
                                      ? bg
                                      : colorScheme.outline.withValues(
                                        alpha: 0.5,
                                      ),
                            ),
                          ),
                          child: Text(
                            g.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: selected ? Colors.white : bg,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // — Sort
          Row(
            children: [
              Text(
                'SORT BY',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        OFFSortBy.values.map((s) {
                          final selected = _sortBy == s;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => _onSortChanged(s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      selected
                                          ? colorScheme.primary
                                          : colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        selected
                                            ? colorScheme.primary
                                            : colorScheme.outline.withValues(
                                              alpha: 0.5,
                                            ),
                                  ),
                                ),
                                child: Text(
                                  s.label.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color:
                                        selected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme, ColorScheme colorScheme) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      children: [
        // — Section header
        if (_searchController.text.trim().isEmpty)
          _sectionHeader(
            theme,
            colorScheme,
            '${_selectedCategory.emoji}  ${_selectedCategory.label.toUpperCase()} — POPULAR //',
          )
        else
          _sectionHeader(
            theme,
            colorScheme,
            'RESULTS FOR "${_searchController.text.trim().toUpperCase()}" //',
          ),

        // — Local items
        if (_localIngredients.isNotEmpty || _localDishes.isNotEmpty) ...[
          _sectionHeader(theme, colorScheme, '📦  MY DATABASE //'),
          ..._localIngredients.map(
            (ing) => _buildLocalIngredientCard(ing, theme, colorScheme),
          ),
          ..._localDishes.map(
            (d) => _buildLocalDishCard(d, theme, colorScheme),
          ),
          if (_searchResults.isNotEmpty)
            _sectionHeader(theme, colorScheme, '🌍  GLOBAL FEED //'),
        ],

        // — Remote products
        ..._searchResults.map(_buildProductCard),

        // — Load-more spinner
        if (_isSearching && _currentPage > 1)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),

        if (!_isSearching && !_hasMoreResults && _searchResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '— END OF RESULTS —',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(ThemeData theme, ColorScheme colorScheme, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    final q = _searchController.text.trim();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              q.isEmpty ? Icons.category_outlined : Icons.search_off,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              q.isEmpty
                  ? 'SELECT A CATEGORY\nOR TYPE TO SEARCH'
                  : 'NO RESULTS FOR\n"${q.toUpperCase()}"',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card builders ──────────────────────────────────────────────────────────

  Widget _buildProductCard(Product product) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Nutri-score badge from product data
    final rawGrade = product.rawData?['nutrition_grades'] as String?;
    final gradeColor = rawGrade != null ? _gradeColor(rawGrade) : null;

    return _itemCard(
      theme: theme,
      colorScheme: colorScheme,
      onTap: () {
        Navigator.of(context).pop();
        widget.onProductSelected?.call(product);
      },
      icon:
          product.imageUrl != null
              ? CachedNetworkImage(
                imageUrl: product.imageUrl!,
                fit: BoxFit.cover,
                errorWidget:
                    (_, __, ___) => Icon(
                      Icons.fastfood,
                      size: 22,
                      color: colorScheme.primary,
                    ),
              )
              : Icon(Icons.fastfood, size: 22, color: colorScheme.primary),
      topRight:
          rawGrade != null
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: gradeColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  rawGrade.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
              : null,
      title: (product.name ?? 'UNKNOWN').toUpperCase(),
      subtitle: product.brand?.toUpperCase(),
      subtitleColor: colorScheme.primary,
      nutrition:
          product.hasNutrition
              ? '${product.nutrition!.calories.round()} KCAL | '
                  'P:${product.nutrition!.protein.toStringAsFixed(1)}G | '
                  'C:${product.nutrition!.carbs.toStringAsFixed(1)}G | '
                  'F:${product.nutrition!.fat.toStringAsFixed(1)}G'
              : null,
    );
  }

  Widget _buildLocalIngredientCard(
    Ingredient ing,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return _itemCard(
      theme: theme,
      colorScheme: colorScheme,
      onTap: () {
        Navigator.of(context).pop();
        widget.onProductSelected?.call(
          Product(
            name: ing.name,
            brand: null,
            barcode: ing.barcode,
            imageUrl: null,
            nutrition:
                ing.nutrition != null
                    ? ProductNutrition(
                      energyKcal100g: ing.nutrition!.calories,
                      proteins100g: ing.nutrition!.protein,
                      carbohydrates100g: ing.nutrition!.carbs,
                      fat100g: ing.nutrition!.fat,
                      fiber100g: ing.nutrition!.fiber,
                      sugars100g: ing.nutrition!.sugar,
                      sodium100g: ing.nutrition!.sodium,
                    )
                    : null,
          ),
        );
      },
      icon: Icon(Icons.inventory_2, size: 22, color: colorScheme.primary),
      title: ing.name.toUpperCase(),
      subtitle: '${ing.amount.toStringAsFixed(0)}${ing.unit} — INGREDIENT',
      subtitleColor: colorScheme.secondary,
      nutrition:
          ing.nutrition != null
              ? '${ing.nutrition!.calories.round()} KCAL | '
                  'P:${ing.nutrition!.protein.toStringAsFixed(1)}G | '
                  'C:${ing.nutrition!.carbs.toStringAsFixed(1)}G'
              : null,
    );
  }

  Widget _buildLocalDishCard(
    Dish dish,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return _itemCard(
      theme: theme,
      colorScheme: colorScheme,
      onTap: () {
        Navigator.of(context).pop();
        widget.onProductSelected?.call(
          Product(
            name: dish.name,
            brand: null,
            barcode: null,
            imageUrl: null,
            nutrition: ProductNutrition(
              energyKcal100g: dish.nutrition.calories,
              proteins100g: dish.nutrition.protein,
              carbohydrates100g: dish.nutrition.carbs,
              fat100g: dish.nutrition.fat,
              fiber100g: dish.nutrition.fiber,
              sugars100g: dish.nutrition.sugar,
              sodium100g: dish.nutrition.sodium,
            ),
          ),
        );
      },
      icon: Icon(Icons.restaurant, size: 22, color: colorScheme.primary),
      title: dish.name.toUpperCase(),
      subtitle: '${dish.ingredients.length} INGREDIENTS — DISH',
      subtitleColor: colorScheme.secondary,
      nutrition:
          '${dish.nutrition.calories.round()} KCAL | '
          'P:${dish.nutrition.protein.toStringAsFixed(1)}G | '
          'C:${dish.nutrition.carbs.toStringAsFixed(1)}G',
    );
  }

  /// Generic card used by all three item types.
  Widget _itemCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
    required Widget icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    String? nutrition,
    Widget? topRight,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.25),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Center(child: icon),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (topRight != null) ...[
                          const SizedBox(width: 6),
                          topRight,
                        ],
                      ],
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: subtitleColor ?? colorScheme.onSurface,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (nutrition != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        nutrition,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: colorScheme.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a':
        return const Color(0xFF1A7D37);
      case 'b':
        return const Color(0xFF75B72A);
      case 'c':
        return const Color(0xFFEFBF0F);
      case 'd':
        return const Color(0xFFE87920);
      case 'e':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }
}
