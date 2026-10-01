import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../../models/dish.dart';
import '../../models/meal_type.dart';
import '../../services/storage/dish_service.dart';

class CalendarDayDetail extends StatefulWidget {
  final DateTime date;
  final List<DishLog>? logs;
  final Widget Function(BuildContext, DishLog)? renderLogItem;
  final VoidCallback? onLogMeal;

  /// When set, logs are grouped into one section per meal type (all four
  /// are shown, even empty ones), each starting with this header.
  final Widget Function(BuildContext, MealType, List<DishLog>)?
  mealSectionHeader;

  const CalendarDayDetail({
    super.key,
    required this.date,
    this.logs,
    this.renderLogItem,
    this.onLogMeal,
    this.mealSectionHeader,
  });

  @override
  State<CalendarDayDetail> createState() => _CalendarDayDetailState();
}

class _CalendarDayDetailState extends State<CalendarDayDetail> {
  final DishService _dishService = DishService();
  List<DishLog> _logs = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.logs == null) _loadData();
  }

  @override
  void didUpdateWidget(CalendarDayDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs == null &&
        (oldWidget.date != widget.date || oldWidget.logs != null)) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final date = widget.date;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final logs = await _dishService.getDishLogsForDate(date);

      if (!mounted) return;
      if (widget.date != date || widget.logs != null) return;
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      if (widget.date != date || widget.logs != null) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
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
            log.dish?.name ??
                log.dishName ??
                l10n.componentsCalendarCalendarDayDetailUnknownDish,
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
    final logs = widget.logs ?? _logs;

    if (widget.logs == null && _isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.logs == null && _hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colorScheme.error),
              const SizedBox(height: 8),
              Text(
                l10n.componentsCalendarCalendarDayDetailErrorLoadingMeals,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadData,
                child: Text(l10n.componentsSharedErrorDisplayRetry),
              ),
            ],
          ),
        ),
      );
    }

    Widget renderLog(DishLog log) =>
        widget.renderLogItem?.call(context, log) ??
        _defaultRenderItem(context, log);

    final sectionHeader = widget.mealSectionHeader;
    final emptyMessage =
        logs.isEmpty
            ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.componentsCalendarCalendarDayDetailNoMealsLoggedForDay,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (widget.onLogMeal != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: widget.onLogMeal,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        child: Text(l10n.screensCalendarLogMeal),
                      ),
                    ],
                  ],
                ),
              ),
            )
            : null;

    if (sectionHeader == null) {
      return emptyMessage ?? Column(children: logs.map(renderLog).toList());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (emptyMessage != null) emptyMessage,
        for (final type in MealType.values) ...[
          sectionHeader(
            context,
            type,
            logs
                .where((log) => MealType.fromString(log.mealType) == type)
                .toList(),
          ),
          for (final log in logs)
            if (MealType.fromString(log.mealType) == type) renderLog(log),
        ],
      ],
    );
  }
}
