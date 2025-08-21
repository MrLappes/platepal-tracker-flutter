import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../../models/dish.dart';
import '../../services/storage/dish_service.dart';

class CalendarDayDetail extends StatefulWidget {
  final DateTime date;
  final Widget Function(BuildContext, DishLog)? renderLogItem;

  const CalendarDayDetail({super.key, required this.date, this.renderLogItem});

  @override
  State<CalendarDayDetail> createState() => _CalendarDayDetailState();
}

class _CalendarDayDetailState extends State<CalendarDayDetail> {
  final DishService _dishService = DishService();
  List<DishLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(CalendarDayDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final logs = await _dishService.getDishLogsForDate(widget.date);

      // Fetch dish details for each log
      final logsWithDishes = <DishLog>[];
      for (final log in logs) {
        try {
          final dish = await _dishService.getDish(log.dishId);
          logsWithDishes.add(log.copyWith(dish: dish));
        } catch (error) {
          // If dish not found, add log without dish
          logsWithDishes.add(log);
        }
      }

      setState(() {
        _logs = logsWithDishes;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
    }
  }

  Widget _defaultRenderItem(BuildContext context, DishLog log) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.dish?.name ?? l10n.unknownDish,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${log.calories.round()} kcal',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_logs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.noMealsLoggedForDay,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children:
          _logs.map((log) {
            return widget.renderLogItem?.call(context, log) ??
                _defaultRenderItem(context, log);
          }).toList(),
    );
  }
}
