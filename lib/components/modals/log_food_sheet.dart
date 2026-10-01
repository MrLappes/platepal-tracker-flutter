import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

import '../../models/dish.dart';
import '../../models/meal_type.dart';
import '../../screens/dish_create_screen.dart';
import '../../services/storage/dish_service.dart';
import 'dish_log_modal.dart';
import 'quick_add_modal.dart';

/// Ways to log something besides picking a saved dish.
enum LogFoodAction { quickAdd, scanBarcode, searchProducts, createDish }

/// What the user picked in the [LogFoodSheet].
sealed class LogFoodChoice {
  const LogFoodChoice();
}

class LogFoodDishChoice extends LogFoodChoice {
  final Dish dish;
  const LogFoodDishChoice(this.dish);
}

class LogFoodActionChoice extends LogFoodChoice {
  final LogFoodAction action;
  const LogFoodActionChoice(this.action);
}

/// Saved dishes split into the sheet's sections; every dish is listed once.
class LogFoodSections {
  final List<Dish> favorites;
  final List<Dish> recent;
  final List<Dish> others;

  const LogFoodSections({
    required this.favorites,
    required this.recent,
    required this.others,
  });
}

/// Favorites first, then up to [recentLimit] most recently logged dishes,
/// then the rest by last use or edit.
LogFoodSections buildLogFoodSections(
  List<Dish> dishes,
  Map<String, DateTime> lastLogged, {
  int recentLimit = 10,
}) {
  DateTime lastUsed(Dish dish) {
    final logged = lastLogged[dish.id];
    return logged != null && logged.isAfter(dish.updatedAt)
        ? logged
        : dish.updatedAt;
  }

  int byLastUsed(Dish left, Dish right) {
    final byDate = lastUsed(right).compareTo(lastUsed(left));
    return byDate != 0
        ? byDate
        : left.name.toLowerCase().compareTo(right.name.toLowerCase());
  }

  final favorites =
      dishes.where((d) => d.isFavorite).toList()..sort(byLastUsed);
  final recent =
      (dishes
              .where((d) => !d.isFavorite && lastLogged.containsKey(d.id))
              .toList()
            ..sort((l, r) => lastLogged[r.id]!.compareTo(lastLogged[l.id]!)))
          .take(recentLimit)
          .toList();
  final shown = {
    for (final d in [...favorites, ...recent]) d.id,
  };
  final others =
      dishes.where((d) => !shown.contains(d.id)).toList()..sort(byLastUsed);
  return LogFoodSections(favorites: favorites, recent: recent, others: others);
}

/// Opens the log food sheet and follows the chosen path through to the log
/// form. Returns true when something was logged.
Future<bool> showLogFoodFlow(
  BuildContext context, {
  required DishService dishService,
  DateTime? date,
  String? mealType,
  required VoidCallback onCreateDish,
}) async {
  final choice = await showModalBottomSheet<LogFoodChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LogFoodSheet(dishService: dishService, mealType: mealType),
  );
  if (!context.mounted || choice == null) return false;

  Future<bool> logDish(Dish dish) async {
    final logged = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => DishLogModal(
            dish: dish,
            initialDate: date,
            initialMealType: mealType,
            dishService: dishService,
          ),
    );
    return logged == true;
  }

  Future<bool> createThenLog(DishCreateEntry entry) async {
    Dish? created;
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder:
            (_) => DishCreateScreenAdvanced(
              heroTag: 'log_food_create_dish',
              entry: entry,
              dishService: dishService,
              onDishCreated: (dish) => created = dish,
            ),
      ),
    );
    final dish = created;
    if (!context.mounted || dish == null) return false;
    return logDish(dish);
  }

  switch (choice) {
    case LogFoodDishChoice(:final dish):
      return logDish(dish);
    case LogFoodActionChoice(action: LogFoodAction.quickAdd):
      final logged = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder:
            (_) => QuickAddModal(
              initialDate: date,
              initialMealType: mealType,
              dishService: dishService,
            ),
      );
      return logged == true;
    case LogFoodActionChoice(action: LogFoodAction.scanBarcode):
      return createThenLog(DishCreateEntry.scanBarcode);
    case LogFoodActionChoice(action: LogFoodAction.searchProducts):
      return createThenLog(DishCreateEntry.searchProduct);
    case LogFoodActionChoice(action: LogFoodAction.createDish):
      onCreateDish();
      return false;
  }
}

/// Search, favorites, recent dishes and the other ways to log food.
class LogFoodSheet extends StatefulWidget {
  final DishService dishService;

  /// Meal type the sheet was opened for, shown as a subtitle.
  final String? mealType;

  const LogFoodSheet({super.key, required this.dishService, this.mealType});

  @override
  State<LogFoodSheet> createState() => _LogFoodSheetState();
}

class _LogFoodSheetState extends State<LogFoodSheet> {
  List<Dish> _dishes = [];
  LogFoodSections _sections = const LogFoodSections(
    favorites: [],
    recent: [],
    others: [],
  );
  String _query = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final dishes = await widget.dishService.getAllDishes();
      final lastLogged = await widget.dishService.getLastLoggedAtByDish();
      if (!mounted) return;
      final sections = buildLogFoodSections(dishes, lastLogged);
      setState(() {
        _sections = sections;
        _dishes = [
          ...sections.favorites,
          ...sections.recent,
          ...sections.others,
        ];
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading dishes to log: ${error.runtimeType}');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _choose(LogFoodChoice choice) => Navigator.of(context).pop(choice);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final mealType = widget.mealType;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder:
            (context, scrollController) => Material(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.componentsModalsLogFoodTitle.toUpperCase(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (mealType != null)
                                Text(
                                  l10n.componentsModalsLogFoodForMealType(
                                    MealType.fromString(
                                      mealType,
                                    ).localizedDisplayName(l10n),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip:
                              MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: l10n.screensMealsSearchDishes,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged:
                          (value) => setState(() {
                            _query = value.trim().toLowerCase();
                          }),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      spacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.bolt),
                          label: Text(l10n.componentsModalsLogFoodQuickAdd),
                          onPressed:
                              () => _choose(
                                const LogFoodActionChoice(
                                  LogFoodAction.quickAdd,
                                ),
                              ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.qr_code_scanner),
                          label: Text(l10n.screensMealsScanBarcode),
                          onPressed:
                              () => _choose(
                                const LogFoodActionChoice(
                                  LogFoodAction.scanBarcode,
                                ),
                              ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.travel_explore),
                          label: Text(
                            l10n.componentsModalsLogFoodSearchOpenFoodFacts,
                          ),
                          onPressed:
                              () => _choose(
                                const LogFoodActionChoice(
                                  LogFoodAction.searchProducts,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16),
                  Expanded(child: _buildList(context, scrollController)),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildList(BuildContext context, ScrollController scrollController) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.screensMealsErrorLoadingDishes),
            TextButton(
              onPressed: _loadDishes,
              child: Text(l10n.componentsSharedErrorDisplayRetry),
            ),
          ],
        ),
      );
    }
    if (_dishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.screensMealsNoDishesCreated),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed:
                  () => _choose(
                    const LogFoodActionChoice(LogFoodAction.createDish),
                  ),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              icon: const Icon(Icons.add),
              label: Text(l10n.screensDishCreateCreateDish),
            ),
          ],
        ),
      );
    }

    final children = <Widget>[];
    if (_query.isNotEmpty) {
      final matches =
          _dishes
              .where((dish) => dish.name.toLowerCase().contains(_query))
              .toList();
      if (matches.isEmpty) {
        return Center(child: Text(l10n.screensMealsNoDishesFound));
      }
      children.addAll(matches.map(_dishTile));
    } else {
      for (final (title, dishes) in [
        (l10n.componentsModalsLogFoodFavorites, _sections.favorites),
        (l10n.componentsModalsLogFoodRecent, _sections.recent),
        (l10n.componentsModalsLogFoodAllDishes, _sections.others),
      ]) {
        if (dishes.isEmpty) continue;
        children.add(_sectionTitle(context, title));
        children.addAll(dishes.map(_dishTile));
      }
    }
    return ListView(controller: scrollController, children: children);
  }

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Semantics(
        header: true,
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _dishTile(Dish dish) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        dish.isFavorite ? Icons.star : Icons.restaurant_outlined,
        color: colors.primary,
      ),
      title: Text(dish.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        l10n.screensCalendarCaloriesPerServing(
          dish.nutritionPerServing.calories.round(),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _choose(LogFoodDishChoice(dish)),
    );
  }
}
