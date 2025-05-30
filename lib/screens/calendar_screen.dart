import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/dish.dart';
import '../services/storage/dish_service.dart';
import '../components/calendar/macro_summary.dart';
import '../components/calendar/calendar_day_detail.dart';
import '../components/calendar/day_selector.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DishService _dishService = DishService();
  DateTime _selectedDate = DateTime.now();
  DateTime _weekStartDate = DateTime.now();
  DateTime _calendarMonth = DateTime.now();
  bool _isLoading = true;
  List<int> _datesWithLogs = [];
  DailyMacroSummary? _selectedDaySummary;
  List<DishLog> _selectedDayLogs = [];

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
    _fetchCalendarData();
  }

  void _initializeCalendar() {
    final today = DateTime.now();
    _selectedDate = today;
    _calendarMonth = DateTime(today.year, today.month, 1);

    // Set week start to Sunday
    final dayOfWeek = today.weekday % 7; // Convert to 0=Sunday
    _weekStartDate = today.subtract(Duration(days: dayOfWeek));
  }

  Future<void> _fetchCalendarData() async {
    setState(() => _isLoading = true);

    try {
      // Get dates with logs for current month
      final dates = await _dishService.getDatesWithLogsInMonth(
        _calendarMonth.year,
        _calendarMonth.month,
      );

      setState(() {
        _datesWithLogs = dates;
      });

      // Load selected date data
      await _handleDateSelect(_selectedDate);
    } catch (error) {
      debugPrint('Error fetching calendar data: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDateSelect(DateTime date) async {
    setState(() => _selectedDate = date);
    try {
      final logs = await _dishService.getDishLogsForDate(date);
      final logsWithDishes = <DishLog>[];

      for (final log in logs) {
        try {
          final dish = await _dishService.getDish(log.dishId);
          final logWithDish = log.copyWith(dish: dish);
          logsWithDishes.add(logWithDish);
        } catch (error) {
          logsWithDishes.add(log);
        }
      }

      final summary = await _dishService.getMacroSummaryForDate(date);
      setState(() {
        _selectedDayLogs = logsWithDishes;
        _selectedDaySummary = summary;
      });
    } catch (error) {
      debugPrint('Error loading logs for date: $error');
    }
  }

  Future<void> _onRefresh() async {
    await _fetchCalendarData();
  }

  void _goToPreviousWeek() {
    final newWeekStart = _weekStartDate.subtract(const Duration(days: 7));
    setState(() {
      _weekStartDate = newWeekStart;
      _calendarMonth = DateTime(newWeekStart.year, newWeekStart.month, 1);
    });
    _fetchCalendarData();
  }

  void _goToNextWeek() {
    final newWeekStart = _weekStartDate.add(const Duration(days: 7));
    setState(() {
      _weekStartDate = newWeekStart;
      _calendarMonth = DateTime(newWeekStart.year, newWeekStart.month, 1);
    });
    _fetchCalendarData();
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _selectedDate = today;
      _calendarMonth = DateTime(today.year, today.month, 1);
      final dayOfWeek = today.weekday % 7;
      _weekStartDate = today.subtract(Duration(days: dayOfWeek));
    });
    _fetchCalendarData();
  }

  Future<void> _handleDeleteLog(DishLog log) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteLog),
            content: Text(l10n.deleteLogConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _dishService.deleteDishLog(log.id);
        setState(() {
          _selectedDayLogs.removeWhere((l) => l.id == log.id);
        });
        await _fetchCalendarData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.mealLogDeletedSuccessfully),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDeleteMealLog),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildLogItem(BuildContext context, DishLog log) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.dish?.name ?? l10n.unknownDish,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.mealType} • ${log.calories.toStringAsFixed(0)} cal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (log.servingSize != 1.0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Serving: ${log.servingSize}x',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _handleDeleteLog(log),
            icon: Icon(
              Icons.delete_outline,
              color: colorScheme.error,
              size: 20,
            ),
            tooltip: l10n.deleteLog,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Single consolidated day selector with navigation
            Container(
              padding: const EdgeInsets.all(16),
              child: DaySelector(
                selectedDate: _selectedDate,
                weekStartDate: _weekStartDate,
                datesWithLogs: _datesWithLogs,
                onDateSelected: _handleDateSelect,
                onPreviousWeek: _goToPreviousWeek,
                onNextWeek: _goToNextWeek,
                onToday: _goToToday,
              ),
            ),

            // Daily detail view
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: colorScheme.primary,
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        )
                        : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedDaySummary != null)
                                MacroSummary(
                                  calories: _selectedDaySummary!.calories,
                                  protein: _selectedDaySummary!.protein,
                                  carbs: _selectedDaySummary!.carbs,
                                  fat: _selectedDaySummary!.fat,
                                  fiber: _selectedDaySummary!.fiber,
                                ),

                              const SizedBox(height: 16),

                              CalendarDayDetail(
                                date: _selectedDate,
                                renderLogItem:
                                    (context, log) =>
                                        _buildLogItem(context, log),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/dishes');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Data classes
class CalendarDay {
  final DateTime date;
  final String dayName;
  final bool isToday;
  final bool hasEntries;

  CalendarDay({
    required this.date,
    required this.dayName,
    required this.isToday,
    required this.hasEntries,
  });
}

class FoodEaten {
  final String name;
  final String mealType;
  final double calories;
  final double protein;

  FoodEaten({
    required this.name,
    required this.mealType,
    required this.calories,
    required this.protein,
  });
}
