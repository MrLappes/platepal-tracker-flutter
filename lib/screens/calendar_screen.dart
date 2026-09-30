import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../models/dish.dart';
import '../models/user_profile.dart';
import '../services/storage/dish_service.dart';
import '../services/health_service.dart';
import '../repositories/user_profile_repository.dart';
import '../services/user_session_service.dart';
import '../services/chat/openai_service.dart';
import '../components/calendar/calendar_day_detail.dart';
import '../components/calendar/calendar_dish_picker.dart';
import '../components/calendar/macro_summary.dart';
import '../components/modals/dish_log_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DishService _dishService = DishService();
  final HealthService _healthService = HealthService();
  late final UserProfileRepository _userProfileRepository;
  final OpenAIService _openAIService = OpenAIService();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isLoadingSummary = false;
  DailyMacroSummary? _selectedDaySummary;
  List<DishLog> _selectedDayLogs = [];
  bool _hasLoadedDayLogs = false;
  int _selectionRequestId = 0;
  UserProfile? _userProfile;
  final bool _isMacroSummaryExpanded = true;
  // ignore: unused_field
  bool _isGeneratingTip = false;

  // Calendar navigation state
  late DateTime _weekStartDate;
  int _calendarMonth = DateTime.now().month - 1; // 0-based
  int _calendarYear = DateTime.now().year;
  Set<DateTime> _datesWithLogs = {};
  int? _firstDayOfWeekIndex;
  int _markerRequestId = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final firstDay = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    if (firstDay == _firstDayOfWeekIndex) return;
    final isInitialWeek = _firstDayOfWeekIndex == null;
    _firstDayOfWeekIndex = firstDay;
    _setWeekForDate(_selectedDate);
    if (!isInitialWeek) _loadCalendarDates();
  }

  Future<void> _init() async {
    await _initializeServices();
    if (!mounted) return;
    await _fetchCalendarData();
  }

  Future<void> _initializeServices() async {
    final prefs = await SharedPreferences.getInstance();
    final userSessionService = UserSessionService(prefs);
    _userProfileRepository = UserProfileRepository(
      userSessionService: userSessionService,
    );
  }

  void _setWeekForDate(DateTime date) {
    final daysSinceWeekStart =
        (date.weekday % 7 - _firstDayOfWeekIndex! + 7) % 7;
    _weekStartDate = DateTime(
      date.year,
      date.month,
      date.day - daysSinceWeekStart,
    );
  }

  Future<void> _fetchCalendarData() async {
    setState(() => _isLoading = true);

    try {
      await _loadUserProfile();
      if (!mounted) return;
      await _loadCalendarDates();
      if (!mounted) return;
      await _handleDateSelect(_selectedDate);
    } catch (error) {
      debugPrint('Error fetching calendar data: ${error.runtimeType}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await _userProfileRepository.getCurrentUserProfile();
      debugPrint('Loaded user profile: ${userProfile != null}');
      if (userProfile != null) {
        debugPrint('User profile id: ${userProfile.id}');
        debugPrint('User profile has goals');
      } else {
        debugPrint('User profile not found');
      }

      if (!mounted) return;
      setState(() {
        _userProfile = userProfile;
      });
    } catch (error) {
      debugPrint('Error loading user profile: ${error.runtimeType}');
    }
  }

  Future<void> _openProfile() async {
    await context.push('/settings/profile');
    if (!mounted) return;
    await _loadUserProfile();
    if (!mounted) return;
    await _handleDateSelect(_selectedDate);
  }

  Future<void> _createDishFromCalendar() async {
    final created = await context.push<bool>('/dishes/create');
    if (!mounted || created != true) return;
    await _openDishPicker();
  }

  Future<void> _openDishPicker() async {
    final dish = await showModalBottomSheet<Dish>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => CalendarDishPicker(
            dishService: _dishService,
            onCreateDish: () {
              Navigator.of(sheetContext).pop();
              _createDishFromCalendar();
            },
          ),
    );
    if (!mounted || dish == null) return;
    final logged = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DishLogModal(dish: dish, initialDate: _selectedDate),
    );
    if (!mounted || logged != true) return;
    await _handleDateSelect(_selectedDate);
    if (mounted) await _loadCalendarDates();
  }

  Future<void> _loadCalendarDates() async {
    final requestId = ++_markerRequestId;
    final weekEndDate = DateTime(
      _weekStartDate.year,
      _weekStartDate.month,
      _weekStartDate.day + 6,
    );
    final months = {
      DateTime(_weekStartDate.year, _weekStartDate.month),
      DateTime(weekEndDate.year, weekEndDate.month),
    };
    try {
      final dateGroups = await Future.wait(
        months.map((month) async {
          final days = await _dishService.getDatesWithLogsInMonth(
            month.year,
            month.month,
          );
          return days.map((day) => DateTime(month.year, month.month, day));
        }),
      );
      if (!mounted || requestId != _markerRequestId) return;
      setState(() {
        _datesWithLogs = dateGroups.expand((dates) => dates).toSet();
      });
    } catch (error) {
      debugPrint('Error fetching dates with logs: ${error.runtimeType}');
      if (!mounted || requestId != _markerRequestId) return;
      setState(() {
        _datesWithLogs = {};
      });
      _showLoadError(
        AppLocalizations.of(context).screensCalendarFailedToLoadDates,
        _loadCalendarDates,
      );
    }
  }

  void _showLoadError(String message, VoidCallback retry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: AppLocalizations.of(context).componentsSharedErrorDisplayRetry,
          onPressed: retry,
        ),
      ),
    );
  }

  Future<void> _handleDateSelect(DateTime date) async {
    final requestId = ++_selectionRequestId;
    setState(() {
      _selectedDate = date;
      _selectedDaySummary = null;
      _selectedDayLogs = [];
      _hasLoadedDayLogs = false;
      _isLoadingSummary = true;
    });
    try {
      final logs = await _dishService.getDishLogsForDate(date);
      if (!mounted || requestId != _selectionRequestId) return;
      setState(() {
        _selectedDayLogs = logs;
        _hasLoadedDayLogs = true;
      });
      final summary = await _dishService.getMacroSummaryForDate(date);
      if (!mounted || requestId != _selectionRequestId) return;
      setState(() {
        _selectedDaySummary = summary;
      });
    } catch (error) {
      debugPrint('Error loading logs for date: ${error.runtimeType}');
      if (!mounted || requestId != _selectionRequestId) return;
      _showLoadError(
        _hasLoadedDayLogs
            ? AppLocalizations.of(context).screensCalendarFailedToLoadSummary
            : AppLocalizations.of(
              context,
            ).componentsCalendarCalendarDayDetailErrorLoadingMeals,
        () {
          if (_selectedDate == date) _handleDateSelect(date);
        },
      );
    } finally {
      if (mounted && requestId == _selectionRequestId) {
        setState(() => _isLoadingSummary = false);
      }
    }
  }

  Future<void> _handleDeleteLog(DishLog log) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.screensCalendarDeleteLog),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.screensCalendarDeleteLogConfirmation),
                if (_healthService.isConnected) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          ).screensCalendarHealthDeleteWarning,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.componentsChatBotProfileCustomizationDialogCancel,
                ),
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
    if (!mounted) return;
    if (confirmed == true) {
      try {
        await _dishService.deleteDishLog(log.id);
        if (!mounted) return;
        await _loadCalendarDates();
        if (!mounted) return;
        await _handleDateSelect(_selectedDate);
        if (!mounted) return;
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
    if (!mounted) return;
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
              '\n- ${log.dish?.name ?? log.dishName ?? l10n.componentsCalendarCalendarDayDetailUnknownDish} (${log.mealType})';
        }
      }

      contextMessage +=
          '\n\nPlease provide a brief, actionable nutrition tip or recommendation to help me reach my goals. Keep it under 100 words.';
      final response = await _openAIService.sendMessage(contextMessage);

      if (mounted) _showAiTipDialog(response);
    } catch (error) {
      debugPrint('Error getting AI tip: ${error.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.screensCalendarFailedToGetAiTip),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingTip = false);
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
      _weekStartDate = DateTime(
        _weekStartDate.year,
        _weekStartDate.month,
        _weekStartDate.day - 7,
      );
      _calendarMonth = _weekStartDate.month - 1;
      _calendarYear = _weekStartDate.year;
    });
    _loadCalendarDates(); // Only reload calendar dates, not user profile
  }

  void _goToNextWeek() {
    setState(() {
      _weekStartDate = DateTime(
        _weekStartDate.year,
        _weekStartDate.month,
        _weekStartDate.day + 7,
      );
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
      _setWeekForDate(today);
    });
    _loadCalendarDates(); // Only reload calendar dates
    _handleDateSelect(today); // Load data for today
  }

  void _updateWeekForMonth() {
    final firstDayOfMonth = DateTime(_calendarYear, _calendarMonth + 1, 1);
    _setWeekForDate(firstDayOfMonth);
  }

  List<DateTime> _generateWeekDays() {
    return List.generate(7, (index) {
      return DateTime(
        _weekStartDate.year,
        _weekStartDate.month,
        _weekStartDate.day + index,
      );
    });
  }

  String _getWeekRangeText() {
    final weekEndDate = _generateWeekDays().last;
    final locale = Localizations.localeOf(context).toString();
    final startFormat =
        _weekStartDate.year != weekEndDate.year
            ? DateFormat.yMMMd(locale)
            : _weekStartDate.month != weekEndDate.month
            ? DateFormat.MMMd(locale)
            : DateFormat.d(locale);
    return '${startFormat.format(_weekStartDate)} – ${DateFormat.yMMMd(locale).format(weekEndDate)}';
  }

  String _getMonthYearText() {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMM(
      locale,
    ).format(DateTime(_calendarYear, _calendarMonth + 1));
  }

  Widget _buildWeekView() {
    final weekDays = _generateWeekDays();
    final today = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  weekDays.map((date) {
                    final isSelected =
                        date.day == _selectedDate.day &&
                        date.month == _selectedDate.month &&
                        date.year == _selectedDate.year;
                    final isToday =
                        date.day == today.day &&
                        date.month == today.month &&
                        date.year == today.year;
                    final hasLogs = _datesWithLogs.contains(
                      DateTime(date.year, date.month, date.day),
                    );

                    return SizedBox(
                      width:
                          constraints.maxWidth / 7 < 52
                              ? 52
                              : constraints.maxWidth / 7,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Semantics(
                          button: true,
                          selected: isSelected,
                          label:
                              '${DateFormat.yMMMMEEEEd(locale).format(date)}${hasLogs ? ', ${l10n.screensCalendarHasMealsLogged}' : ''}',
                          onTap: () => _handleDateSelect(date),
                          excludeSemantics: true,
                          child: Material(
                            color:
                                isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : isToday
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: 0.2)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _handleDateSelect(date),
                              child: SizedBox(
                                height: 72,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat.E(locale).format(date),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color:
                                            isSelected
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary
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
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary
                                                : isToday
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (hasLogs && !isSelected)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
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
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
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
                  (log.dish?.name ??
                          log.dishName ??
                          l10n.componentsCalendarCalendarDayDetailUnknownDish)
                      .toUpperCase(),
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
                      style: TextStyle(
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      '${log.calories.round()} KCAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _handleDeleteLog(log),
            tooltip: l10n.screensCalendarDeleteLog,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Icon(
              Icons.close,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'calendar_log_meal',
        onPressed: _openDishPicker,
        tooltip: AppLocalizations.of(context).screensCalendarLogMeal,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).screensCalendarLogMeal),
      ),
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
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              tooltip:
                                  MaterialLocalizations.of(
                                    context,
                                  ).previousMonthTooltip,
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
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              tooltip:
                                  MaterialLocalizations.of(
                                    context,
                                  ).nextMonthTooltip,
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
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              tooltip:
                                  MaterialLocalizations.of(
                                    context,
                                  ).previousPageTooltip,
                              icon: const Icon(Icons.keyboard_arrow_left),
                            ),
                            Semantics(
                              button: true,
                              label: MaterialLocalizations.of(context).currentDateLabel,
                              onTap: _goToToday,
                              excludeSemantics: true,
                              child: GestureDetector(
                                onTap: _goToToday,
                                behavior: HitTestBehavior.opaque,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minHeight: 48),
                                  child: Center(
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
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _goToNextWeek,
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              tooltip:
                                  MaterialLocalizations.of(
                                    context,
                                  ).nextPageTooltip,
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
                                if (_isLoadingSummary)
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                if (_selectedDaySummary != null &&
                                    (_userProfile == null ||
                                        _userProfile!.goals.targetCalories <=
                                            0))
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainer,
                                      border: Border.all(
                                        color: colorScheme.outline.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          ).screensCalendarProfileNudge,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        TextButton(
                                          onPressed: _openProfile,
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(48, 48),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(
                                              context,
                                            ).screensCalendarSetUpProfile,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_selectedDaySummary != null)
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
                                    isHealthConnected:
                                        _selectedDaySummary!.isHealthConnected,
                                    calorieTarget:
                                        (_userProfile?.goals.targetCalories ??
                                                    0) >
                                                0
                                            ? _userProfile!.goals.targetCalories
                                            : null,
                                    proteinTarget:
                                        _userProfile?.goals.targetProtein,
                                    carbsTarget:
                                        _userProfile?.goals.targetCarbs,
                                    fatTarget: _userProfile?.goals.targetFat,
                                    fiberTarget:
                                        _userProfile?.goals.targetFiber,
                                    isCollapsible: true,
                                    initiallyExpanded: _isMacroSummaryExpanded,
                                    onAiTipPressed: _getAiTip,
                                    selectedDate: _selectedDate,
                                  ),

                                // Calendar Day Detail
                                if (_hasLoadedDayLogs && !_isLoadingSummary)
                                  CalendarDayDetail(
                                    date: _selectedDate,
                                    logs: _selectedDayLogs,
                                    onLogMeal: _openDishPicker,
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
