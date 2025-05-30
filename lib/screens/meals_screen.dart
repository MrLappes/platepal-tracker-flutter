import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/ui/empty_state_widget.dart';
import '../components/ui/loading_widget.dart';
import '../models/dish.dart';
import '../services/storage/dish_service.dart';
import 'dish_create_screen.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryFilter = 'all';
  List<Dish> _dishes = [];
  bool _isLoading = false;
  String? _error;
  final DishService _dishService = DishService();

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDishes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dishes = await _dishService.getAllDishes();

      setState(() {
        _dishes = dishes;
        _isLoading = false;
      });
    } catch (e) {
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
                        const SizedBox(width: 8),
                        _buildFilterChip(localizations.dessert, 'dessert'),
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
      return const LoadingWidget();
    }

    if (_error != null) {
      return Center(
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
      );
    }

    final filteredDishes = _filteredDishes;

    if (filteredDishes.isEmpty) {
      if (_dishes.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.restaurant,
          title: localizations.noDishesCreated,
          subtitle: localizations.createFirstDish,
          onAction: _createNewDish,
          actionLabel: localizations.createDish,
        );
      } else {
        return Center(
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
        );
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredDishes.length,
      itemBuilder: (context, index) {
        final dish = filteredDishes[index];
        return _buildDishCard(dish);
      },
    );
  }

  Widget _buildDishCard(Dish dish) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewDishDetails(dish),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dish image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: theme.colorScheme.surfaceVariant,
                ),
                child:
                    dish.imageUrl != null
                        ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            dish.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.restaurant,
                                size: 48,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.restaurant,
                          size: 48,
                          color: Colors.grey,
                        ),
              ),
            ),

            // Dish info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dish.nutrition.calories.toStringAsFixed(0)} kcal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (dish.isFavorite)
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: theme.colorScheme.error,
                          ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          onSelected: (value) => _handleDishAction(value, dish),
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit, size: 18),
                                      const SizedBox(width: 8),
                                      Text(AppLocalizations.of(context)!.edit),
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
                                            ? AppLocalizations.of(
                                              context,
                                            )!.removeFromFavorites
                                            : AppLocalizations.of(
                                              context,
                                            )!.addToFavorites,
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
                                        AppLocalizations.of(context)!.delete,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                          child: Icon(
                            Icons.more_vert,
                            size: 18,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewDish() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DishCreateScreenAdvanced(
              onDishCreated: (dish) {
                _loadDishes(); // Refresh the list
              },
            ),
      ),
    );
  }

  void _viewDishDetails(Dish dish) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => DishCreateScreenAdvanced(
              dish: dish,
              onDishCreated: (dish) {
                _loadDishes(); // Refresh the list
              },
            ),
      ),
    );
  }

  void _handleDishAction(String action, Dish dish) {
    switch (action) {
      case 'edit':
        _viewDishDetails(dish);
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
