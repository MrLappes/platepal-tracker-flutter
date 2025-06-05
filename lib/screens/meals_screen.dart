import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/ui/empty_state_widget.dart';
import '../components/ui/loading_widget.dart';
import '../components/modals/dish_log_modal.dart';
import '../models/dish.dart';
import '../services/storage/dish_service.dart';
import 'dish_create_screen.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryFilter = 'all';
  List<Dish> _dishes = [];
  bool _isLoading = false;
  String? _error;
  final DishService _dishService = DishService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDishes();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh dishes when app comes back to foreground
      debugPrint('🔄 MealsScreen: App resumed, refreshing dishes...');
      _loadDishes();
    }
  }

  // Add a method to refresh when screen becomes visible
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh dishes every time dependencies change (e.g., when coming back to this screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint(
          '🔄 MealsScreen: Dependencies changed, refreshing dishes...',
        );
        _loadDishes();
      }
    });
  }

  Future<void> _loadDishes() async {
    debugPrint('🔄 MealsScreen: Loading dishes...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dishes = await _dishService.getAllDishes();
      debugPrint(
        '🔄 MealsScreen: Loaded ${dishes.length} dishes from database',
      );

      setState(() {
        _dishes = dishes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ MealsScreen: Error loading dishes: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Dish> get _filteredDishes {
    var filteredDishes = _dishes;

    // Filter by category
    if (_selectedCategoryFilter != 'all') {
      filteredDishes =
          filteredDishes
              .where((dish) => dish.category == _selectedCategoryFilter)
              .toList();
    }

    // Filter by search query
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filteredDishes =
          filteredDishes
              .where(
                (dish) =>
                    dish.name.toLowerCase().contains(searchQuery) ||
                    (dish.description?.toLowerCase().contains(searchQuery) ??
                        false),
              )
              .toList();
    }

    return filteredDishes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.meals),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewDish,
            tooltip: localizations.addMeal,
          ),
          // Add a refresh button for manual refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              debugPrint('🔄 MealsScreen: Manual refresh triggered');
              _loadDishes();
            },
            tooltip: 'Refresh dishes',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDishes,
        child: Column(
          children: [
            // Search and filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: localizations.searchDishes,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(
                        0.3,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Category filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(localizations.allCategories, 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip(localizations.breakfast, 'breakfast'),
                        const SizedBox(width: 8),
                        _buildFilterChip(localizations.lunch, 'lunch'),
                        const SizedBox(width: 8),
                        _buildFilterChip(localizations.dinner, 'dinner'),
                        const SizedBox(width: 8),
                        _buildFilterChip(localizations.snack, 'snack'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Dishes list
            Expanded(child: _buildDishesList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "meals_fab", // Unique hero tag to avoid conflicts
        onPressed: _createNewDish,
        tooltip: localizations.createDish,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final theme = Theme.of(context);
    final isSelected = _selectedCategoryFilter == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategoryFilter = selected ? value : 'all';
        });
      },
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color:
            isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildDishesList() {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return CustomScrollView(
        slivers: [SliverFillRemaining(child: const LoadingWidget())],
      );
    }

    if (_error != null) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.errorLoadingDishes,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDishes,
                    child: Text(localizations.retry),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final filteredDishes = _filteredDishes;

    if (filteredDishes.isEmpty) {
      if (_dishes.isEmpty) {
        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: EmptyStateWidget(
                icon: Icons.restaurant,
                title: localizations.noDishesCreated,
                subtitle: localizations.createFirstDish,
                onAction: _createNewDish,
                actionLabel: localizations.createDish,
              ),
            ),
          ],
        );
      } else {
        return CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      localizations.noDishesFound,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.tryAdjustingSearch,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final dish = filteredDishes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDishCard(dish),
              );
            }, childCount: filteredDishes.length),
          ),
        ),
      ],
    );
  }

  Widget _buildDishCard(Dish dish) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewDishDetails(dish),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Dish image or placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.surfaceVariant,
                ),
                child:
                    dish.imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            dish.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.restaurant,
                                size: 24,
                                color: theme.colorScheme.outline,
                              );
                            },
                          ),
                        )
                        : Icon(
                          Icons.restaurant,
                          size: 24,
                          color: theme.colorScheme.outline,
                        ),
              ),

              const SizedBox(width: 16),

              // Dish info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dish name with overflow handling
                    Text(
                      dish.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Nutrition info row
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Calories with fire icon
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 12,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dish.nutrition.calories.round()} kcal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),

                        // Macros
                        Text(
                          'P: ${dish.nutrition.protein.round()}g',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        ),

                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        ),

                        Text(
                          'C: ${dish.nutrition.carbs.round()}g',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        ),

                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        ),

                        Text(
                          'F: ${dish.nutrition.fat.round()}g',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 11,
                          ),
                        ),

                        // Favorite indicator
                        if (dish.isFavorite) ...[
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 12,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                localizations.favorite,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Navigation arrow
              Icon(
                Icons.keyboard_arrow_right,
                size: 20,
                color: theme.colorScheme.outline,
              ),

              const SizedBox(width: 8),

              // Three-dot menu button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PopupMenuButton<String>(
                  onSelected: (value) => _handleDishAction(value, dish),
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 18),
                              const SizedBox(width: 8),
                              Text(localizations.edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'favorite',
                          child: Row(
                            children: [
                              Icon(
                                dish.isFavorite
                                    ? Icons.favorite_border
                                    : Icons.favorite,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dish.isFavorite
                                    ? localizations.removeFromFavorites
                                    : localizations.addToFavorites,
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
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localizations.delete,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createNewDish() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DishCreateScreenAdvanced(
              heroTag: "dish_create_fab_meals_new",
              onDishCreated: (dish) {
                debugPrint(
                  '🍽️ MealsScreen: onDishCreated callback triggered for: ${dish.name}',
                );
                _loadDishes(); // Refresh the list
              },
            ),
      ),
    );
  }

  void _editDishDetails(Dish dish) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DishCreateScreenAdvanced(
              heroTag: "dish_create_fab_meals_edit",
              dish: dish,
              onDishCreated: (dish) {
                _loadDishes(); // Refresh the list
              },
            ),
      ),
    );
  }

  void _viewDishDetails(Dish dish) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows modal to take up more space
      backgroundColor: Colors.transparent, // Makes the modal look better
      builder: (context) => DishLogModal(dish: dish),
    );
  }

  void _handleDishAction(String action, Dish dish) {
    switch (action) {
      case 'edit':
        _editDishDetails(dish);
        break;
      case 'favorite':
        _toggleFavorite(dish);
        break;
      case 'delete':
        _deleteDish(dish);
        break;
    }
  }

  Future<void> _toggleFavorite(Dish dish) async {
    try {
      final updatedDish = Dish(
        id: dish.id,
        name: dish.name,
        description: dish.description,
        imageUrl: dish.imageUrl,
        ingredients: dish.ingredients,
        nutrition: dish.nutrition,
        createdAt: dish.createdAt,
        updatedAt: DateTime.now(),
        isFavorite: !dish.isFavorite,
        category: dish.category,
      );

      await _dishService.saveDish(updatedDish);
      _loadDishes(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              dish.isFavorite
                  ? AppLocalizations.of(context)!.removedFromFavorites
                  : AppLocalizations.of(context)!.addedToFavorites,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorUpdatingDish),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteDish(Dish dish) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteDish),
            content: Text(
              AppLocalizations.of(context)!.deleteDishConfirmation(dish.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(AppLocalizations.of(context)!.delete),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _dishService.deleteDish(dish.id);
        _loadDishes(); // Refresh the list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.dishDeletedSuccessfully,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToDeleteDish),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
