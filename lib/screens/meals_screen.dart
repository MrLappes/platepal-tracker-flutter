import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
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
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.componentsUiCustomTabBarMeals),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewDish,
            tooltip: localizations.screensMealsAddMeal,
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
                    color: Colors.black.withValues(alpha: 0.05),
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
                      hintText: localizations.screensMealsSearchDishes,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
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
                        _buildFilterChip(localizations.screensMealsAllCategories, 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip(localizations.componentsModalsDishLogModalBreakfast, 'breakfast'),
                        const SizedBox(width: 8),
                        _buildFilterChip(localizations.componentsModalsDishLogModalLunch, 'lunch'),
                        const SizedBox(width: 8),
                        _buildFilterChip(localizations.componentsModalsDishLogModalDinner, 'dinner'),
                        const SizedBox(width: 8),
                        _buildFilterChip(localizations.componentsModalsDishLogModalSnack, 'snack'),
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
        tooltip: localizations.screensDishCreateCreateDish,
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
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
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
    final localizations = AppLocalizations.of(context);

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
                    localizations.screensMealsErrorLoadingDishes,
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
                    child: Text(localizations.componentsSharedErrorDisplayRetry),
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
                title: localizations.screensMealsNoDishesCreated,
                subtitle: localizations.screensMealsCreateFirstDish,
                onAction: _createNewDish,
                actionLabel: localizations.screensDishCreateCreateDish,
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
                      localizations.screensMealsNoDishesFound,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.screensMealsTryAdjustingSearch,
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
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 1),
      ),
      child: InkWell(
        onTap: () => _viewDishDetails(dish),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category & Macros
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      (dish.category ?? 'MISC').toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (dish.isFavorite)
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                ],
              ),
            ),

            // Main Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                dish.name.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Telemetry Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTelemetryItem(theme, '${dish.nutrition.calories.round()}', 'KCAL'),
                  _buildTelemetryItem(theme, '${dish.nutrition.protein.round()}G', 'PRO'),
                  _buildTelemetryItem(theme, '${dish.nutrition.carbs.round()}G', 'CHO'),
                  _buildTelemetryItem(theme, '${dish.nutrition.fat.round()}G', 'FAT'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryItem(ThemeData theme, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          unit,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            letterSpacing: 1,
          ),
        ),
      ],
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
                  ? AppLocalizations.of(context).screensMealsRemovedFromFavorites
                  : AppLocalizations.of(context).screensMealsAddedToFavorites,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).screensMealsErrorUpdatingDish),
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
            title: Text(AppLocalizations.of(context).screensMealsDeleteDish),
            content: Text(
              AppLocalizations.of(context).screensMealsDeleteDishConfirmation(dish.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context).componentsChatBotProfileCustomizationDialogCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(AppLocalizations.of(context).componentsDishesDishCardDelete),
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
                AppLocalizations.of(context).screensMealsDishDeletedSuccessfully,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).screensMealsFailedToDeleteDish),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
