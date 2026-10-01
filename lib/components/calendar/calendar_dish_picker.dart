import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

import '../../models/dish.dart';
import '../../services/storage/dish_service.dart';

class CalendarDishPicker extends StatefulWidget {
  final DishService dishService;
  final VoidCallback onCreateDish;

  const CalendarDishPicker({
    super.key,
    required this.dishService,
    required this.onCreateDish,
  });

  @override
  State<CalendarDishPicker> createState() => _CalendarDishPickerState();
}

class _CalendarDishPickerState extends State<CalendarDishPicker> {
  List<Dish> _dishes = [];
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
      dishes.sort((left, right) {
        if (left.isFavorite != right.isFavorite) {
          return left.isFavorite ? -1 : 1;
        }
        final leftLog = lastLogged[left.id];
        final rightLog = lastLogged[right.id];
        final leftRecent =
            leftLog != null && leftLog.isAfter(left.updatedAt)
                ? leftLog
                : left.updatedAt;
        final rightRecent =
            rightLog != null && rightLog.isAfter(right.updatedAt)
                ? rightLog
                : right.updatedAt;
        final byDate = rightRecent.compareTo(leftRecent);
        return byDate == 0
            ? left.name.toLowerCase().compareTo(right.name.toLowerCase())
            : byDate;
      });
      if (!mounted) return;
      setState(() {
        _dishes = dishes;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading calendar dishes: $error');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final matches =
        _dishes
            .where((dish) => dish.name.toLowerCase().contains(_query))
            .toList();

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
                          child: Text(
                            l10n.screensCalendarLogMeal.toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _hasError
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(l10n.screensMealsErrorLoadingDishes),
                                  TextButton(
                                    onPressed: _loadDishes,
                                    child: Text(
                                      l10n.componentsSharedErrorDisplayRetry,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : _dishes.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(l10n.screensMealsNoDishesCreated),
                                  const SizedBox(height: 12),
                                  TextButton.icon(
                                    onPressed: widget.onCreateDish,
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(48, 48),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: Text(
                                      l10n.screensDishCreateCreateDish,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : matches.isEmpty
                            ? Center(
                              child: Text(l10n.screensMealsNoDishesFound),
                            )
                            : ListView.builder(
                              controller: scrollController,
                              itemCount: matches.length,
                              itemBuilder: (context, index) {
                                final dish = matches[index];
                                return ListTile(
                                  leading: Icon(
                                    dish.isFavorite
                                        ? Icons.star
                                        : Icons.restaurant_outlined,
                                    color: colors.primary,
                                  ),
                                  title: Text(
                                    dish.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    l10n.screensCalendarCaloriesPerServing(
                                      dish.nutrition.calories.round(),
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.of(context).pop(dish),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
