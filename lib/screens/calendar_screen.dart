import 'dart:math';
import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../models/dish.dart';
import '../models/user_profile.dart';
import '../services/storage/dish_service.dart';
import '../repositories/user_profile_repository.dart';
import '../services/user_session_service.dart';
import '../services/chat/openai_service.dart';
import '../components/calendar/calendar_day_detail.dart';
import '../components/calendar/macro_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DishService _dishService = DishService();
  late final UserProfileRepository _userProfileRepository;
  final OpenAIService _openAIService = OpenAIService();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  DailyMacroSummary? _selectedDaySummary;
  List<DishLog> _selectedDayLogs = [];
  UserProfile? _userProfile;
  final bool _isMacroSummaryExpanded = true;
  // ignore: unused_field
  bool _isGeneratingTip = false;

  // Calendar navigation state
  late DateTime _weekStartDate;
  int _calendarMonth = DateTime.now().month - 1; // 0-based
  int _calendarYear = DateTime.now().year;
  List<int> _datesWithLogs = [];
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeCalendar();
    _fetchCalendarData();
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    final userSessionService = UserSessionService(prefs);
    _userProfileRepository = UserProfileRepository(
      userSessionService: userSessionService,
    );
  }

  void _initializeCalendar() {
    final today = DateTime.now();
    _selectedDate = today;
    _calendarMonth = today.month - 1; // 0-based
    _calendarYear = today.year;

    // Set week to current week (starting from Sunday)
    final dayOfWeek = today.weekday % 7; // Convert to Sunday = 0
    _weekStartDate = today.subtract(Duration(days: dayOfWeek));
  }

  Future<void> _fetchCalendarData() async {
    setState(() => _isLoading = true);

    try {
      await _loadUserProfile();
      await _loadCalendarDates();
      await _handleDateSelect(_selectedDate);
    } catch (error) {
      debugPrint('Error fetching calendar data: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await _userProfileRepository.getCurrentUserProfile();
      debugPrint('Loaded user profile: ${userProfile != null}');
      if (userProfile != null) {
        debugPrint('User profile id: ${userProfile.id}');
        debugPrint('User profile has goals');
        debugPrint(
          'User goals: ${userProfile.goals.targetCalories} cal, ${userProfile.goals.targetProtein}g protein',
        );
      } else {
        debugPrint('User profile not found');
      }

      setState(() {
        _userProfile = userProfile;
      });
    } catch (error) {
      debugPrint('Error loading user profile: $error');
    }
  }

  Future<void> _loadCalendarDates() async {
    try {
      final dates = await _dishService.getDatesWithLogsInMonth(
        _calendarYear,
        _calendarMonth + 1, // Convert from 0-based to 1-based month
      );
      setState(() {
        _datesWithLogs = dates;
      });
    } catch (error) {
      debugPrint('Error fetching dates with logs: $error');
      setState(() {
        _datesWithLogs = [];
      });
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

  Future<void> _handleDeleteLog(DishLog log) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.screensCalendarDeleteLog),
            content: Text(l10n.screensCalendarDeleteLogConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.componentsChatBotProfileCustomizationDialogCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(l10n.componentsDishesDishCardDelete),
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
        // Only reload the selected date and calendar dates, not user profile
        await _loadCalendarDates();
        await _handleDateSelect(_selectedDate);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.screensCalendarMealLogDeletedSuccessfully),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.screensCalendarFailedToDeleteMealLog),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _getAiTip() async {
    final l10n = AppLocalizations.of(context);
    // Check if OpenAI service is configured
    final isConfigured = await _openAIService.isConfigured();
    if (!isConfigured) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.screensCalendarConfigureApiKeyForAiTips),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    setState(() => _isGeneratingTip = true);

    try {
      // Build context for AI recommendation
      final summary = _selectedDaySummary;
      final profile = _userProfile;
      final goals = profile?.goals;

      String contextMessage = 'Based on my nutrition today:\n';

      if (summary != null) {
        contextMessage += '- Calories: ${summary.calories.toStringAsFixed(0)}';
        if (goals != null) {
          contextMessage +=
              ' / ${goals.targetCalories.toStringAsFixed(0)} target';
        }
        contextMessage += '\n- Protein: ${summary.protein.toStringAsFixed(1)}g';
        if (goals != null) {
          contextMessage +=
              ' / ${goals.targetProtein.toStringAsFixed(0)}g target';
        }
        contextMessage += '\n- Carbs: ${summary.carbs.toStringAsFixed(1)}g';
        if (goals != null) {
          contextMessage +=
              ' / ${goals.targetCarbs.toStringAsFixed(0)}g target';
        }
        contextMessage += '\n- Fat: ${summary.fat.toStringAsFixed(1)}g';
        if (goals != null) {
          contextMessage += ' / ${goals.targetFat.toStringAsFixed(0)}g target';
        }
        if (summary.fiber > 0) {
          contextMessage += '\n- Fiber: ${summary.fiber.toStringAsFixed(1)}g';
        }
      }

      if (goals != null) {
        contextMessage += '\n\nMy fitness goals: ${goals.goal}';
        contextMessage += ', target weight: ${goals.targetWeight}kg';
        if (profile != null) {
          contextMessage += ', activity level: ${profile.activityLevel}';
        }
      }

      if (_selectedDayLogs.isNotEmpty) {
        contextMessage += '\n\nMeals eaten today:';
        for (final log in _selectedDayLogs) {
          contextMessage +=
              '\n- ${log.dish?.name ?? "Unknown"} (${log.mealType})';
        }
      }

      contextMessage +=
          '\n\nPlease provide a brief, actionable nutrition tip or recommendation to help me reach my goals. Keep it under 100 words.';
      final response = await _openAIService.sendMessage(contextMessage);

      _showAiTipDialog(response);
    } catch (error) {
      debugPrint('Error getting AI tip: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.screensCalendarFailedToGetAiTip),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isGeneratingTip = false);
    }
  }

  void _showAiTipDialog(String tip) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(l10n.screensCalendarAiNutritionTip),
              ],
            ),
            content: Text(tip),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.screensCalendarOk),
              ),
            ],
          ),
    );
  }

  // Calendar navigation methods
  void _goToPreviousMonth() {
    setState(() {
      if (_calendarMonth == 0) {
        _calendarMonth = 11;
        _calendarYear--;
      } else {
        _calendarMonth--;
      }
      _updateWeekForMonth();
    });
    _loadCalendarDates(); // Only reload calendar dates, not user profile
  }

  void _goToNextMonth() {
    setState(() {
      if (_calendarMonth == 11) {
        _calendarMonth = 0;
        _calendarYear++;
      } else {
        _calendarMonth++;
      }
      _updateWeekForMonth();
    });
    _loadCalendarDates(); // Only reload calendar dates, not user profile
  }

  void _goToPreviousWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.subtract(const Duration(days: 7));
      _calendarMonth = _weekStartDate.month - 1;
      _calendarYear = _weekStartDate.year;
    });
    _loadCalendarDates(); // Only reload calendar dates, not user profile
  }

  void _goToNextWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.add(const Duration(days: 7));
      _calendarMonth = _weekStartDate.month - 1;
      _calendarYear = _weekStartDate.year;
    });
    _loadCalendarDates(); // Only reload calendar dates, not user profile
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _selectedDate = today;
      _calendarMonth = today.month - 1;
      _calendarYear = today.year;
      final dayOfWeek = today.weekday % 7;
      _weekStartDate = today.subtract(Duration(days: dayOfWeek));
    });
    _loadCalendarDates(); // Only reload calendar dates
    _handleDateSelect(today); // Load data for today
  }

  void _updateWeekForMonth() {
    final firstDayOfMonth = DateTime(_calendarYear, _calendarMonth + 1, 1);
    final dayOfWeek = firstDayOfMonth.weekday % 7;
    _weekStartDate = firstDayOfMonth.subtract(Duration(days: dayOfWeek));
  }

  List<DateTime> _generateWeekDays() {
    return List.generate(7, (index) {
      return _weekStartDate.add(Duration(days: index));
    });
  }

  String _getWeekRangeText() {
    final weekEndDate = _weekStartDate.add(const Duration(days: 6));
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final startMonth = monthNames[_weekStartDate.month - 1];
    final endMonth = monthNames[weekEndDate.month - 1];

    if (_weekStartDate.year == weekEndDate.year) {
      if (_weekStartDate.month == weekEndDate.month) {
        return '$startMonth ${_weekStartDate.day}-${weekEndDate.day}, ${_weekStartDate.year}';
      }
      return '$startMonth ${_weekStartDate.day} - $endMonth ${weekEndDate.day}, ${_weekStartDate.year}';
    }

    return '$startMonth ${_weekStartDate.day}, ${_weekStartDate.year} - $endMonth ${weekEndDate.day}, ${weekEndDate.year}';
  }

  String _getMonthYearText() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[_calendarMonth]} $_calendarYear';
  }

  Widget _buildWeekView() {
    final weekDays = _generateWeekDays();
    final today = DateTime.now();
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      children:
          weekDays.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final isSelected =
                date.day == _selectedDate.day &&
                date.month == _selectedDate.month &&
                date.year == _selectedDate.year;
            final isToday =
                date.day == today.day &&
                date.month == today.month &&
                date.year == today.year;
            final hasLogs =
                _datesWithLogs.contains(date.day) &&
                date.month == _calendarMonth + 1 &&
                date.year == _calendarYear;

            return Expanded(
              child: GestureDetector(
                onTap: () => _handleDateSelect(date),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isToday
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayNames[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : isToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasLogs && !isSelected)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildLogItem(BuildContext context, DishLog log) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (log.dish?.name ?? l10n.componentsCalendarCalendarDayDetailUnknownDish).toUpperCase(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      log.mealType.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '  |  ',
                      style: TextStyle(color: colorScheme.outline.withValues(alpha: 0.5)),
                    ),
                    Text(
                      '${log.calories.round()} KCAL',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _handleDeleteLog(log),
            icon: const Icon(
              Icons.close,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
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
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _fetchCalendarData,
                  child: Column(
                    children: [
                      // Month header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _goToPreviousMonth,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text(
                              _getMonthYearText(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _goToNextMonth,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),

                      // Week view header with Today button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _goToPreviousWeek,
                              icon: const Icon(Icons.keyboard_arrow_left),
                            ),
                            GestureDetector(
                              onTap: _goToToday,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getWeekRangeText(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _goToNextWeek,
                              icon: const Icon(Icons.keyboard_arrow_right),
                            ),
                          ],
                        ),
                      ),

                      // Week view
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: _buildWeekView(),
                      ),

                      // Date selector and details
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                // Collapsible Macro Summary                                if (_selectedDaySummary != null)
                                MacroSummary(
                                  calories: _selectedDaySummary!.calories,
                                  protein: _selectedDaySummary!.protein,
                                  carbs: _selectedDaySummary!.carbs,
                                  fat: _selectedDaySummary!.fat,
                                  fiber: _selectedDaySummary!.fiber,
                                  caloriesBurned:
                                      _selectedDaySummary!.caloriesBurned,
                                  isCaloriesBurnedEstimated:
                                      _selectedDaySummary!
                                          .isCaloriesBurnedEstimated,
                                  calorieTarget:
                                      _userProfile?.goals.targetCalories,
                                  proteinTarget:
                                      _userProfile?.goals.targetProtein,
                                  carbsTarget: _userProfile?.goals.targetCarbs,
                                  fatTarget: _userProfile?.goals.targetFat,
                                  fiberTarget: _userProfile?.goals.targetFiber,
                                  isCollapsible: true,
                                  initiallyExpanded: _isMacroSummaryExpanded,
                                  onAiTipPressed: _getAiTip,
                                  selectedDate: _selectedDate,
                                ),

                                // Calendar Day Detail
                                CalendarDayDetail(
                                  date: _selectedDate,
                                  renderLogItem:
                                      (context, log) =>
                                          _buildLogItem(context, log),
                                ),
                                // Add some bottom padding to ensure there's enough space to scroll
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
