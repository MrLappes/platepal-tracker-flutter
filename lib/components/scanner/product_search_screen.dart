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
import '../../utils/number_parsing.dart';
import '../../utils/product_converter.dart';

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

String _categoryLabel(OFFCategory category, AppLocalizations l10n) =>
    switch (category.id) {
      'all' => l10n.componentsScannerProductSearchCategoryAll,
      'fruits' => l10n.componentsScannerProductSearchCategoryFruits,
      'vegetables' => l10n.componentsScannerProductSearchCategoryVegetables,
      'dairy' => l10n.componentsScannerProductSearchCategoryDairy,
      'meat' => l10n.componentsScannerProductSearchCategoryMeat,
      'seafood' => l10n.componentsScannerProductSearchCategorySeafood,
      'beverages' => l10n.componentsScannerProductSearchCategoryBeverages,
      'cereals' => l10n.componentsScannerProductSearchCategoryCereals,
      'breads' => l10n.componentsScannerProductSearchCategoryBreads,
      'snacks' => l10n.componentsScannerProductSearchCategorySnacks,
      'sweets' => l10n.componentsScannerProductSearchCategorySweets,
      'legumes' => l10n.componentsScannerProductSearchCategoryLegumes,
      'nuts' => l10n.componentsScannerProductSearchCategoryNuts,
      'condiments' => l10n.componentsScannerProductSearchCategoryCondiments,
      'oilsAndFats' => l10n.componentsScannerProductSearchCategoryOilsAndFats,
      'frozen' => l10n.componentsScannerProductSearchCategoryFrozen,
      'readyMeals' => l10n.componentsScannerProductSearchCategoryReadyMeals,
      'babyFoods' => l10n.componentsScannerProductSearchCategoryBabyFoods,
      _ => category.id,
    };

String _sortLabel(OFFSortBy sort, AppLocalizations l10n) => switch (sort) {
  OFFSortBy.popularity => l10n.componentsScannerProductSearchSortPopularity,
  OFFSortBy.productName => l10n.componentsScannerProductSearchSortName,
  OFFSortBy.lastModified => l10n.componentsScannerProductSearchSortNewest,
  OFFSortBy.completeness => l10n.componentsScannerProductSearchSortCompleteness,
};

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
  bool _browseFailed = false;
  int _requestGeneration = 0;

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
    ++_requestGeneration;

    if (q.isEmpty) {
      _triggerBrowse(); // switch back to browse mode
      return;
    }

    setState(() {
      _localIngredients = [];
      _localDishes = [];
      _browseFailed = false;
      _searchResults = [];
      _hasMoreResults = false;
      _isSearching = q.length >= 2;
      _isBrowsing = false;
    });
    if (q.length < 2) return;

    // Local instant search
    _searchLocalItems(q);

    // Remote debounced (avoid 10 req/min rate limit)
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _triggerSearch(q, isNewSearch: true);
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
            .take(5)
            .toList();

    if (mounted && _searchController.text.trim() == query) {
      setState(() {
        _localIngredients = ingredients;
        _localDishes = dishes;
      });
    }
  }

  Future<void> _triggerSearch(String query, {bool isNewSearch = true}) async {
    final generation = ++_requestGeneration;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    setState(() {
      _isSearching = true;
      _isBrowsing = false;
      _browseFailed = false;
      if (isNewSearch) {
        _currentPage = 1;
        _searchResults = [];
        _hasMoreResults = false;
      }
    });

    try {
      final products = await _offService.searchProducts(
        query,
        page: _currentPage,
        pageSize: 20,
        countryCode:
            WidgetsBinding.instance.platformDispatcher.locale.countryCode,
        languageCode: localeProvider.locale.languageCode,
        category: _selectedCategory.tag.isNotEmpty ? _selectedCategory : null,
        nutriScore: _selectedNutriScore,
        sortBy: _sortBy,
      );

      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        if (isNewSearch) {
          _searchResults = products;
        } else {
          _searchResults.addAll(products);
        }
        _hasMoreResults = products.length == 20;
      });
    } catch (e) {
      if (!mounted || generation != _requestGeneration) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).componentsScannerProductSearchErrorSearchingProduct(e.toString()),
          ),
        ),
      );
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _triggerBrowse() async {
    final generation = ++_requestGeneration;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    setState(() {
      _isBrowsing = true;
      _isSearching = true;
      _browseFailed = false;
      _localIngredients = [];
      _localDishes = [];
      _searchResults = [];
      _currentPage = 1;
      _hasMoreResults = false;
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

      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _searchResults = products;
        _hasMoreResults = products.length == 20;
      });
    } catch (_) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _browseFailed = true;
      });
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() {
          _isSearching = false;
          _isBrowsing = false;
        });
      }
    }
  }

  void _loadMore() {
    if (_isSearching || _isBrowsing || _browseFailed || !_hasMoreResults) {
      return;
    }
    final query = _searchController.text.trim();
    setState(() => _currentPage++);
    if (query.isNotEmpty) {
      _triggerSearch(query, isNewSearch: false);
    } else {
      _loadMoreBrowse();
    }
  }

  Future<void> _loadMoreBrowse() async {
    final generation = ++_requestGeneration;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    setState(() {
      _isSearching = true;
      _browseFailed = false;
    });

    try {
      final products = await _offService.browseCategory(
        _selectedCategory,
        page: _currentPage,
        pageSize: 20,
        nutriScore: _selectedNutriScore,
        sortBy: _sortBy,
        languageCode: localeProvider.locale.languageCode,
      );

      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _searchResults.addAll(products);
        _hasMoreResults = products.length == 20;
      });
    } catch (_) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _browseFailed = true;
        _hasMoreResults = false;
      });
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() => _isSearching = false);
      }
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
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
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
            tooltip: localizations.componentsScannerProductSearchFiltersAndSort,
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
                    localizations.componentsScannerProductSearchSearchProducts
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
                          tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                          onPressed: _searchController.clear,
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
                _isSearching &&
                        _currentPage == 1 &&
                        _localIngredients.isEmpty &&
                        _localDishes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _browseFailed &&
                        _searchResults.isEmpty &&
                        _localIngredients.isEmpty &&
                        _localDishes.isEmpty
                    ? _buildBrowseErrorState(theme, colorScheme)
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
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: OFFCategory.all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final cat = OFFCategory.all[i];
          final selected = _selectedCategory.tag == cat.tag;
          return _selectableChip(
            label: _categoryLabel(cat, l10n),
            selected: selected,
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
                    _categoryLabel(cat, l10n).toUpperCase(),
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

  Widget _selectableChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(widthFactor: 1, child: child),
        ),
      ),
    );
  }

  Widget _buildExpandedFilters(ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
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
                l10n.componentsScannerProductSearchNutriScore,
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
                    _selectableChip(
                      label: l10n.componentsScannerProductSearchAny,
                      selected: _selectedNutriScore == null,
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
                          l10n.componentsScannerProductSearchAny.toUpperCase(),
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
                      return _selectableChip(
                        label: g.label,
                        selected: selected,
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
                l10n.componentsScannerProductSearchSortBy.toUpperCase(),
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
                            child: _selectableChip(
                              label: _sortLabel(s, l10n),
                              selected: selected,
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
                                  _sortLabel(s, l10n).toUpperCase(),
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
    final l10n = AppLocalizations.of(context);
    final hasLocalResults =
        _localIngredients.isNotEmpty || _localDishes.isNotEmpty;
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: _sectionHeader(
            theme,
            colorScheme,
            _searchController.text.trim().isEmpty
                ? '${_selectedCategory.emoji}  ${_categoryLabel(_selectedCategory, l10n).toUpperCase()} — ${l10n.componentsScannerProductSearchPopular.toUpperCase()} //'
                : '${l10n.componentsScannerProductSearchResultsFor(_searchController.text.trim().toUpperCase()).toUpperCase()} //',
          ),
        ),
        if (hasLocalResults) ...[
          SliverToBoxAdapter(
            child: _sectionHeader(
              theme,
              colorScheme,
              '📦  ${l10n.componentsScannerProductSearchMyDatabase.toUpperCase()} //',
            ),
          ),
          SliverList.builder(
            itemCount: _localIngredients.length,
            itemBuilder:
                (context, index) => _buildLocalIngredientCard(
                  _localIngredients[index],
                  theme,
                  colorScheme,
                ),
          ),
          SliverList.builder(
            itemCount: _localDishes.length,
            itemBuilder:
                (context, index) => _buildLocalDishCard(
                  _localDishes[index],
                  theme,
                  colorScheme,
                ),
          ),
          if (_searchResults.isNotEmpty)
            SliverToBoxAdapter(
              child: _sectionHeader(
                theme,
                colorScheme,
                '🌍  ${l10n.componentsScannerProductSearchGlobalFeed.toUpperCase()} //',
              ),
            ),
        ],
        SliverList.builder(
          itemCount: _searchResults.length,
          itemBuilder:
              (context, index) => _buildProductCard(_searchResults[index]),
        ),
        if (_isSearching && _currentPage > 1)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        if (_browseFailed)
          SliverToBoxAdapter(child: _buildBrowseErrorState(theme, colorScheme)),
        if (!_browseFailed &&
            !_isSearching &&
            !_hasMoreResults &&
            _searchResults.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '— ${l10n.componentsScannerProductSearchEndOfResults.toUpperCase()} —',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
    final l10n = AppLocalizations.of(context);
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
                  ? l10n.componentsScannerProductSearchSelectCategoryOrSearch
                      .toUpperCase()
                  : l10n
                      .componentsScannerProductSearchNoResultsFor(
                        q.toUpperCase(),
                      )
                      .toUpperCase(),
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

  Widget _buildBrowseErrorState(ThemeData theme, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(
              l10n.componentsScannerProductSearchBrowseUnavailable,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _currentPage > 1 ? _loadMoreBrowse : _triggerBrowse,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.componentsSharedErrorDisplayRetry),
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
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final thumbnailPixels =
        (48 * MediaQuery.devicePixelRatioOf(context)).round();

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
        icon: ExcludeSemantics(
          child:
              product.imageUrl != null
                  ? CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    fit: BoxFit.cover,
                    memCacheWidth: thumbnailPixels,
                    memCacheHeight: thumbnailPixels,
                    errorWidget:
                        (_, __, ___) => Icon(
                          Icons.fastfood,
                          size: 22,
                          color: colorScheme.primary,
                        ),
                  )
                  : Icon(Icons.fastfood, size: 22, color: colorScheme.primary),
        ),
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
      title:
          (product.name ?? l10n.componentsScannerProductSearchUnknown)
              .toUpperCase(),
      subtitle: product.brand?.toUpperCase(),
      subtitleColor: colorScheme.primary,
      nutrition:
          product.hasNutrition
              ? _nutritionSummary(
                calories: product.nutrition!.calories,
                protein: product.nutrition!.protein,
                carbs: product.nutrition!.carbs,
                fat: product.nutrition!.fat,
                locale: locale,
              )
              : null,
    );
  }

  String _nutritionSummary({
    required double calories,
    required double protein,
    required double carbs,
    double? fat,
    required String locale,
  }) {
    final l10n = AppLocalizations.of(context);
    final grams =
        l10n.componentsScannerProductSearchGramsAbbreviation.toUpperCase();
    final fatSummary =
        fat == null
            ? ''
            : ' | ${l10n.componentsScannerProductSearchFatAbbreviation.toUpperCase()}${formatDecimal(fat, locale)}$grams';
    return '${calories.round()} ${l10n.componentsScannerProductSearchKcal.toUpperCase()} | '
        '${l10n.componentsScannerProductSearchProteinAbbreviation.toUpperCase()}${formatDecimal(protein, locale)}$grams | '
        '${l10n.componentsScannerProductSearchCarbsAbbreviation.toUpperCase()}${formatDecimal(carbs, locale)}$grams$fatSummary';
  }

  Widget _buildLocalIngredientCard(
    Ingredient ing,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final locale = Localizations.localeOf(context).toString();
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
      subtitle:
          '${formatDecimal(ing.amount, locale, fractionDigits: 0)}${ing.unit} — ${AppLocalizations.of(context).componentsScannerProductSearchIngredient.toUpperCase()}',
      subtitleColor: colorScheme.secondary,
      nutrition:
          ing.nutrition != null
              ? _nutritionSummary(
                calories: ing.nutrition!.calories,
                protein: ing.nutrition!.protein,
                carbs: ing.nutrition!.carbs,
                locale: locale,
              )
              : null,
    );
  }

  Widget _buildLocalDishCard(
    Dish dish,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final locale = Localizations.localeOf(context).toString();
    return _itemCard(
      theme: theme,
      colorScheme: colorScheme,
      onTap: () {
        Navigator.of(context).pop();
        widget.onProductSelected?.call(
          ProductToIngredientConverter.productFromDish(dish),
        );
      },
      icon: Icon(Icons.restaurant, size: 22, color: colorScheme.primary),
      title: dish.name.toUpperCase(),
      subtitle:
          AppLocalizations.of(context)
              .componentsScannerProductSearchDishIngredients(
                dish.ingredients.length,
              )
              .toUpperCase(),
      subtitleColor: colorScheme.secondary,
      nutrition: _nutritionSummary(
        calories: dish.nutrition.calories,
        protein: dish.nutrition.protein,
        carbs: dish.nutrition.carbs,
        locale: locale,
      ),
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
