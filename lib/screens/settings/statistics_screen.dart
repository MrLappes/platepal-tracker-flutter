import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/service_extensions.dart';
import '../../models/user_profile.dart';
import '../../services/user_session_service.dart';
import '../../services/health_service.dart';
import '../../services/calorie_expenditure_service.dart';
import 'dart:math' as math;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  String? _error;
  UserProfile? _userProfile;
  List<Map<String, dynamic>> _metricsHistory = [];
  List<Map<String, dynamic>> _calorieHistory = [];
  bool _isShowingTestData = false; // Track if we're showing test data

  // Services
  final HealthService _healthService = HealthService();
  final CalorieExpenditureService _calorieExpenditureService =
      CalorieExpenditureService();
  // Selected time range
  String _selectedTimeRange = 'month';
  final Map<String, String> _timeRanges = {
    'week': 'week',
    'month': 'month',
    'threeMonths': 'threeMonths',
    'sixMonths': 'sixMonths',
    'year': 'year',
    'all': 'allTime',
  };

  // Current stats values
  double? _currentWeight;
  double? _currentHeight;
  double? _currentBMI;
  double? _currentBodyFat;
  double? _maintenanceCalories;

  // Health data integration
  final Map<String, double> _caloriesBurnedData = {};
  bool _isHealthConnected = false;

  // Graph min/max values for scaling
  double _minWeight = 0;
  double _maxWeight = 100;
  double _minHeight = 0;
  double _maxHeight = 200;
  double _minBMI = 0;
  double _maxBMI = 40;
  double _minBodyFat = 0;
  double _maxBodyFat = 40;
  double _minCalories = 0;
  double _maxCalories = 3000;
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadData();
  }

  // Initialize services
  Future<void> _initializeServices() async {
    await _calorieExpenditureService.initialize();
    await _healthService.loadConnectionStatus();
    _isHealthConnected = _healthService.isConnected;

    // Refresh calorie-burn cache on screen visit
    if (_isHealthConnected) {
      _healthService.refreshCaloriesBurnedCache();
    }
  }

  // Load user profile and metrics history
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _isShowingTestData = false; // Clear test data flag
      });

      // Get current user ID from session service
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs);
      final currentUserId = userSessionService.getCurrentUserId();
      if (!mounted) return;
      // Load current user profile
      final userProfiles = await context.userProfileService.getUserProfile(
        currentUserId,
      );

      if (userProfiles != null) {
        _userProfile =
            userProfiles; // Load metrics history based on selected time range
        final DateTime now = DateTime.now();
        DateTime startDate;

        switch (_selectedTimeRange) {
          case 'week':
            startDate = now.subtract(const Duration(days: 7));
            break;
          case 'month':
            startDate = DateTime(now.year, now.month - 1, now.day);
            break;
          case 'threeMonths':
            startDate = DateTime(now.year, now.month - 3, now.day);
            break;
          case 'sixMonths':
            startDate = DateTime(now.year, now.month - 6, now.day);
            break;
          case 'year':
            startDate = DateTime(now.year - 1, now.month, now.day);
            break;
          case 'all':
            startDate = DateTime(2000); // Arbitrary old date
            break;
          default:
            startDate = DateTime(now.year, now.month - 1, now.day);
        }

        var history = <Map<String, dynamic>>[];
        if (mounted) {
          history = await context.userProfileService.getUserMetricsHistory(
            _userProfile!.id,
            startDate: startDate,
          );
        } else {
          setState(() {
            _error = "No metrics history found";
            _isLoading = false;
          });
          return;
        } // Load calorie data from meal logs and health data
        final calorieData = await _loadCalorieHistory(startDate);

        // Load health data if connected
        if (_isHealthConnected) {
          await _loadHealthData(startDate);
        }

        // Process the history data
        _metricsHistory = history;
        _calorieHistory = calorieData;
        _processMetricsData();
      } else {
        setState(() {
          _error = "User profile not found";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Load health data for calorie expenditure
  Future<void> _loadHealthData(DateTime startDate) async {
    try {
      final DateTime endDate = DateTime.now();
      final int daysDifference = endDate.difference(startDate).inDays;

      _caloriesBurnedData.clear();

      for (int i = 0; i <= daysDifference; i++) {
        final currentDate = startDate.add(Duration(days: i));

        // Get calories burned for this date
        final (caloriesBurned, isEstimated) = await _calorieExpenditureService
            .getCaloriesBurnedForDateWithStatus(currentDate);

        if (caloriesBurned != null) {
          final dateKey = currentDate.toIso8601String().split('T')[0];
          _caloriesBurnedData[dateKey] = caloriesBurned;
        }
      }
    } catch (e) {
      // Health data loading failed, continue without it
      debugPrint('Failed to load health data: $e');
    }
  }

  // Load calorie history from meal logs
  Future<List<Map<String, dynamic>>> _loadCalorieHistory(
    DateTime startDate,
  ) async {
    try {
      final List<Map<String, dynamic>> calorieData = [];
      final DateTime endDate = DateTime.now();
      final int daysDifference = endDate.difference(startDate).inDays;

      for (int i = 0; i <= daysDifference; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final dayStart = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );
        final dayEnd = dayStart.add(const Duration(days: 1));

        // Get nutrition summary for this day
        final summary = await context.mealLogService.getNutritionSummary(
          userId: _userProfile!.id,
          startDate: dayStart,
          endDate: dayEnd,
        );
        if (summary.totalCalories > 0) {
          final dateKey = currentDate.toIso8601String().split('T')[0];
          final caloriesBurned = _caloriesBurnedData[dateKey];

          // Calculate deficit/surplus if we have expenditure data
          double? deficit;
          double? netCalories;
          if (caloriesBurned != null) {
            deficit = summary.totalCalories - caloriesBurned;
            netCalories = summary.totalCalories - caloriesBurned;
          }

          calorieData.add({
            'date': currentDate.toIso8601String(),
            'calories': summary.totalCalories,
            'protein': summary.totalProtein,
            'carbs': summary.totalCarbs,
            'fat': summary.totalFat,
            'calories_burned': caloriesBurned,
            'deficit': deficit,
            'net_calories': netCalories,
          });
        }
      }

      return calorieData;
    } catch (e) {
      return [];
    }
  }

  // Process metrics data to calculate derived values like BMI
  void _processMetricsData() {
    if (_metricsHistory.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Get the most recent values for current stats
    final latestEntry = _metricsHistory.last;

    _currentWeight = latestEntry['weight'] as double?;
    _currentHeight = latestEntry['height'] as double?;
    _currentBodyFat = latestEntry['body_fat'] as double?;

    // Calculate BMI if both weight and height are available
    if (_currentWeight != null &&
        _currentHeight != null &&
        _currentHeight! > 0) {
      // BMI = weight(kg) / height²(m²)
      _currentBMI =
          _currentWeight! / ((_currentHeight! / 100) * (_currentHeight! / 100));
    }

    // Calculate maintenance calories based on user profile
    if (_userProfile != null &&
        _currentWeight != null &&
        _currentHeight != null) {
      final bmr = _calculateBMR(
        _currentWeight!,
        _currentHeight!,
        _userProfile!.age,
        _userProfile!.gender,
      );
      _maintenanceCalories = _calculateTDEE(bmr, _userProfile!.activityLevel);
    }

    // Find min/max values for scaling graphs
    if (_metricsHistory.isNotEmpty) {
      // Initialize with the first value
      _minWeight = double.maxFinite;
      _maxWeight = double.minPositive;
      _minHeight = double.maxFinite;
      _maxHeight = double.minPositive;

      for (final entry in _metricsHistory) {
        // Weight min/max
        final weight = entry['weight'] as double?;
        if (weight != null) {
          _minWeight = math.min(_minWeight, weight);
          _maxWeight = math.max(_maxWeight, weight);
        }

        // Height min/max
        final height = entry['height'] as double?;
        if (height != null) {
          _minHeight = math.min(_minHeight, height);
          _maxHeight = math.max(_maxHeight, height);
        }

        // Body fat min/max
        final bodyFat = entry['body_fat'] as double?;
        if (bodyFat != null) {
          _minBodyFat = math.min(_minBodyFat, bodyFat);
          _maxBodyFat = math.max(_maxBodyFat, bodyFat);
        }

        // Calculate BMI for each entry
        if (weight != null && height != null && height > 0) {
          final bmi = weight / ((height / 100) * (height / 100));
          _minBMI = math.min(_minBMI, bmi);
          _maxBMI = math.max(_maxBMI, bmi);
        }
      }

      // Process calorie data for min/max
      if (_calorieHistory.isNotEmpty) {
        _minCalories = double.maxFinite;
        _maxCalories = double.minPositive;

        for (final entry in _calorieHistory) {
          final calories = entry['calories'] as double?;
          if (calories != null) {
            _minCalories = math.min(_minCalories, calories);
            _maxCalories = math.max(_maxCalories, calories);
          }
        }

        // Add maintenance calories to the range
        if (_maintenanceCalories != null) {
          _minCalories = math.min(_minCalories, _maintenanceCalories!);
          _maxCalories = math.max(_maxCalories, _maintenanceCalories!);
        }

        // Add padding to calorie range
        _minCalories = _minCalories.isFinite ? (_minCalories * 0.9) : 1200;
        _maxCalories = _maxCalories.isFinite ? (_maxCalories * 1.1) : 3000;
      }

      // Add padding to min/max values for better visualization
      _minWeight = _minWeight.isFinite ? (_minWeight * 0.95) : 0;
      _maxWeight = _maxWeight.isFinite ? (_maxWeight * 1.05) : 100;
      _minHeight = _minHeight.isFinite ? (_minHeight * 0.95) : 0;
      _maxHeight = _maxHeight.isFinite ? (_maxHeight * 1.05) : 200;
      _minBMI = _minBMI.isFinite ? (_minBMI * 0.95) : 0;
      _maxBMI = _maxBMI.isFinite ? (_maxBMI * 1.05) : 40;
      _minBodyFat = _minBodyFat.isFinite ? (_minBodyFat * 0.95) : 0;
      _maxBodyFat = _maxBodyFat.isFinite ? (_maxBodyFat * 1.05) : 40;
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Calculate BMR using Mifflin-St Jeor equation
  double _calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  } // Calculate TDEE (Total Daily Energy Expenditure)

  double _calculateTDEE(double bmr, String activityLevel) {
    final multipliers = {
      'sedentary': 1.2,
      'lightly_active': 1.375,
      'moderately_active': 1.55,
      'very_active': 1.725,
      'extra_active': 1.9,
    };
    return bmr * (multipliers[activityLevel] ?? 1.55);
  }

  // Generate test data for development/demo purposes (temporary, not saved to DB)
  Future<void> _generateTestData() async {
    if (_userProfile == null) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    try {
      final now = DateTime.now();
      final startDate = now.subtract(
        const Duration(days: 90),
      ); // 3 months of data

      // Generate realistic test data using sin curves
      _metricsHistory = _generateTestMetricsHistory(startDate, now);
      _calorieHistory = _generateTestCalorieHistory(startDate, now);

      // Mark as test data
      _isShowingTestData = true;

      // Process the generated data
      _processMetricsData();

      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate test data: $e';
        _isLoading = false;
      });
    }
  }

  // Generate realistic metrics history using sin curves
  List<Map<String, dynamic>> _generateTestMetricsHistory(
    DateTime startDate,
    DateTime endDate,
  ) {
    final List<Map<String, dynamic>> history = [];
    final baseWeight = _userProfile!.weight;
    final baseHeight = _userProfile!.height;

    final totalDays = endDate.difference(startDate).inDays;
    final random = math.Random(42); // Fixed seed for consistent results

    for (int i = 0; i <= totalDays; i += 2) {
      // Every 2 days for realistic frequency
      final currentDate = startDate.add(Duration(days: i));
      final progress = i / totalDays; // 0 to 1

      // Weight: slow loss trend with weekly variations (sin curve)
      final weightTrend =
          baseWeight - (progress * 3.0); // 3kg loss over 3 months
      final weeklyVariation =
          math.sin(i * 2 * math.pi / 7) * 0.8; // Weekly cycle
      final dailyNoise = (random.nextDouble() - 0.5) * 0.6; // Daily variation
      final weight = weightTrend + weeklyVariation + dailyNoise;

      // Body fat: gradual decrease with some plateaus
      final baseFat = 20.0; // Default body fat percentage
      final bodyFatTrend =
          baseFat - (progress * 2.5); // 2.5% loss over 3 months
      final bodyFatVariation =
          math.sin(i * 2 * math.pi / 14) * 0.3; // Bi-weekly cycle
      final bodyFat = math.max(
        bodyFatTrend + bodyFatVariation + (random.nextDouble() - 0.5) * 0.4,
        8.0,
      );

      history.add({
        'id': i,
        'user_id': _userProfile!.id,
        'weight': double.parse(weight.toStringAsFixed(1)),
        'height': baseHeight,
        'body_fat': double.parse(bodyFat.toStringAsFixed(1)),
        'recorded_date': currentDate.toIso8601String(),
      });
    }

    return history;
  }

  // Generate realistic calorie history using sin curves
  List<Map<String, dynamic>> _generateTestCalorieHistory(
    DateTime startDate,
    DateTime endDate,
  ) {
    final List<Map<String, dynamic>> history = [];
    final totalDays = endDate.difference(startDate).inDays;
    final random = math.Random(42); // Fixed seed for consistent results

    // Calculate maintenance calories
    final maintenanceCalories = _calculateMaintenanceCalories();

    for (int i = 0; i <= totalDays; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final progress = i / totalDays;

      // Calorie intake: cutting phase with weekend variations
      final isWeekend =
          currentDate.weekday == DateTime.saturday ||
          currentDate.weekday == DateTime.sunday;
      final baseCalories = maintenanceCalories - 300; // Cutting calories

      // Weekly pattern: higher on weekends, lower midweek
      final weeklyPattern =
          math.sin((currentDate.weekday - 1) * 2 * math.pi / 7) * 150;
      final weekendBonus = isWeekend ? 200 : 0;

      // Monthly pattern: slight increase over time (less strict as time goes on)
      final monthlyPattern =
          math.sin(i * 2 * math.pi / 30) * 100 + (progress * 150);

      // Random daily variation
      final dailyVariation = (random.nextDouble() - 0.5) * 200;

      final calories =
          baseCalories +
          weeklyPattern +
          weekendBonus +
          monthlyPattern +
          dailyVariation;
      final clampedCalories = math.max(
        math.min(calories, maintenanceCalories + 800),
        maintenanceCalories - 800,
      );

      history.add({
        'date':
            currentDate
                .toIso8601String(), // Keeping full ISO format to match other data
        'calories':
            clampedCalories
                .toDouble(), // Changed property name to 'calories' and ensured it's a double
        'protein':
            (clampedCalories * 0.25 / 4)
                .toDouble(), // Adding missing macro data (25% protein)
        'carbs': (clampedCalories * 0.5 / 4).toDouble(), // 50% carbs
        'fat': (clampedCalories * 0.25 / 9).toDouble(), // 25% fat
      });
    }
    return history;
  }

  // Calculate maintenance calories using BMR and TDEE
  double _calculateMaintenanceCalories() {
    if (_userProfile == null) return 2200.0; // Default fallback

    final bmr = _calculateBMR(
      _userProfile!.weight,
      _userProfile!.height,
      _userProfile!.age,
      _userProfile!.gender,
    );

    return _calculateTDEE(bmr, _userProfile!.activityLevel);
  }

  // Method to calculate weekly median weight
  List<Map<String, dynamic>> _calculateWeeklyMedian(
    List<Map<String, dynamic>> data,
  ) {
    if (data.isEmpty) return [];

    // Group entries by week
    final Map<int, List<double>> weightsByWeek = {};

    for (final entry in data) {
      final DateTime date = DateTime.parse(entry['recorded_date'] as String);
      final weight = entry['weight'] as double?;
      if (weight != null) {
        // Calculate week number (based on ISO week date)
        final int weekNumber =
            ((date.difference(DateTime(date.year, 1, 1)).inDays) / 7).floor();
        if (weightsByWeek.containsKey(weekNumber)) {
          weightsByWeek[weekNumber]!.add(weight);
        } else {
          weightsByWeek[weekNumber] = [weight];
        }
      }
    }

    // Calculate median for each week
    final List<Map<String, dynamic>> medianData = [];
    weightsByWeek.forEach((weekNumber, weights) {
      weights.sort();
      double median;
      if (weights.length.isOdd) {
        median = weights[weights.length ~/ 2];
      } else {
        median =
            (weights[(weights.length ~/ 2) - 1] +
                weights[weights.length ~/ 2]) /
            2;
      }

      // Estimate a date for this week number
      final DateTime weekDate = DateTime(
        DateTime.now().year,
        1,
        1,
      ).add(Duration(days: weekNumber * 7));

      medianData.add({
        'recorded_date': weekDate.toIso8601String(),
        'weight': median,
      });
    });

    // Sort by date
    medianData.sort((a, b) {
      final dateA = DateTime.parse(a['recorded_date'] as String);
      final dateB = DateTime.parse(b['recorded_date'] as String);
      return dateA.compareTo(dateB);
    });

    return medianData;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.screensSettingsStatisticsStatistics)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.screensSettingsStatisticsStatistics)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.screensSettingsStatisticsErrorLoadingData,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_error!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                child: Text(l10n.screensSettingsStatisticsTryAgain),
              ),
            ],
          ),
        ),
      );
    } // Empty state check - show empty state if no real data (ignore test data)
    final bool hasEnoughData =
        _metricsHistory.length > 3 && !_isShowingTestData;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${l10n.screensSettingsStatisticsStatistics.toUpperCase()} //',
        ),
        actions: [
          // Show "Back to Real Data" button when showing test data
          if (_isShowingTestData)
            TextButton(
              onPressed: _loadData,
              child: Text(
                l10n.screensSettingsStatisticsRealData,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: l10n.screensSettingsStatisticsRefresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child:
            hasEnoughData || _isShowingTestData
                ? _buildStatisticsContent(context, l10n)
                : _buildEmptyState(context, l10n),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timeline_outlined,
                size: 80,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.screensSettingsStatisticsNotEnoughDataTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  l10n.screensSettingsStatisticsStatisticsEmptyDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(l10n.screensSettingsStatisticsUpdateMetricsNow),
                onPressed: () {
                  // Navigate to profile settings to update metrics
                  Navigator.pushReplacementNamed(context, '/settings/profile');
                },
              ),
              const SizedBox(height: 16),
              // Test data generation button
              OutlinedButton.icon(
                icon: const Icon(Icons.science),
                label: Text(l10n.screensSettingsStatisticsGenerateTestData),
                onPressed: _generateTestData,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.screensSettingsStatisticsTestDataDescription,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsContent(BuildContext context, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Current Stats Summary Card
        _buildCurrentStatsCard(context, l10n),
        const SizedBox(height: 16),

        // Health Data Status Card
        if (_isHealthConnected) _buildHealthDataStatusCard(context, l10n),
        if (_isHealthConnected) const SizedBox(height: 16),

        // Time Range Selector
        _buildTimeRangeSelector(context, l10n),
        const SizedBox(height: 24),

        // Weight Chart
        _buildStatsSection(
          context,
          title: l10n.screensSettingsStatisticsWeightHistory,
          icon: Icons.monitor_weight_outlined,
          tooltipText: l10n.screensSettingsStatisticsWeightStatsTip,
          chart: _buildWeightChart(context),
        ),

        const SizedBox(height: 24),

        // BMI Chart
        _buildStatsSection(
          context,
          title: l10n.screensSettingsStatisticsBmiHistory,
          icon: Icons.insights_outlined,
          tooltipText: l10n.screensSettingsStatisticsBmiStatsTip,
          chart: _buildBMIChart(context),
        ),
        if (_metricsHistory.any((entry) => entry['body_fat'] != null)) ...[
          const SizedBox(height: 24),

          // Body Fat Chart
          _buildStatsSection(
            context,
            title: l10n.screensSettingsStatisticsBodyFatHistory,
            icon: Icons.pie_chart_outline,
            tooltipText: l10n.screensSettingsStatisticsBodyFatStatsTip,
            chart: _buildBodyFatChart(context),
          ),
        ],
        if (_calorieHistory.isNotEmpty && _maintenanceCalories != null) ...[
          const SizedBox(height: 24), // Calorie Intake vs Maintenance Chart
          _buildStatsSection(
            context,
            title:
                _isHealthConnected && _caloriesBurnedData.isNotEmpty
                    ? l10n.screensSettingsStatisticsCalorieBalanceTitle
                    : l10n.screensSettingsStatisticsCalorieIntakeHistory,
            icon: Icons.local_fire_department_outlined,
            tooltipText:
                _isHealthConnected && _caloriesBurnedData.isNotEmpty
                    ? l10n.screensSettingsStatisticsCalorieBalanceTip
                    : l10n.screensSettingsStatisticsCalorieStatsTip,
            chart: _buildCalorieChart(context),
          ),

          // Phase and warning indicators
          if (_calorieHistory.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPhaseIndicators(context, l10n),
          ],
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHealthDataStatusCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final healthDataDays = _caloriesBurnedData.length;
    final totalDays = _calorieHistory.length;
    final coverage = totalDays > 0 ? (healthDataDays / totalDays * 100) : 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.screensSettingsStatisticsHealthDataIntegration,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Calorie expenditure data coverage: ${coverage.toStringAsFixed(1)}% ($healthDataDays/$totalDays days)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            if (coverage > 0)
              Text(
                l10n.screensSettingsStatisticsHealthDataActive,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.green.shade700),
              )
            else
              Text(
                l10n.screensSettingsStatisticsHealthDataInactive,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade700),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatsCard(BuildContext context, AppLocalizations l10n) {
    final String weightUnit =
        _userProfile?.preferredUnit == 'imperial' ? 'lbs' : 'kg';
    final String heightUnit =
        _userProfile?.preferredUnit == 'imperial' ? 'in' : 'cm';

    // Convert values if using imperial
    double? displayWeight = _currentWeight;
    double? displayHeight = _currentHeight;

    if (_userProfile?.preferredUnit == 'imperial') {
      displayWeight =
          displayWeight != null ? displayWeight * 2.2046 : null; // kg to lbs
      displayHeight =
          displayHeight != null ? displayHeight / 2.54 : null; // cm to inches
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.screensMenuCurrentStats,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.monitor_weight,
                    label: l10n.screensSettingsImportProfileCompletionWeight,
                    value:
                        displayWeight != null
                            ? '${displayWeight.toStringAsFixed(1)} $weightUnit'
                            : '-',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.height,
                    label: l10n.screensSettingsImportProfileCompletionHeight,
                    value:
                        displayHeight != null
                            ? '${displayHeight.toStringAsFixed(1)} $heightUnit'
                            : '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.speed,
                    label: 'BMI',
                    value:
                        _currentBMI != null
                            ? _currentBMI!.toStringAsFixed(1)
                            : '-',
                    detail: _getBMICategory(_currentBMI),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    icon: Icons.pie_chart,
                    label: l10n.screensSettingsStatisticsBodyFat,
                    value:
                        _currentBodyFat != null
                            ? '${_currentBodyFat!.toStringAsFixed(1)}%'
                            : '-',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getBMICategory(double? bmi) {
    final l10n = AppLocalizations.of(context);
    if (bmi == null) return '';

    if (bmi < 18.5) {
      return l10n.screensSettingsStatisticsBmiUnderweight;
    } else if (bmi < 25) {
      return l10n.screensSettingsStatisticsBmiNormal;
    } else if (bmi < 30) {
      return l10n.screensSettingsStatisticsBmiOverweight;
    } else {
      return l10n.screensSettingsStatisticsBmiObese;
    }
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? detail,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        if (detail != null) ...[
          const SizedBox(height: 4),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context, AppLocalizations l10n) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.screensSettingsStatisticsTimeRange,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTimeRange,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              items:
                  _timeRanges.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        _getLocalizedTimeRange(l10n, entry.key) ?? entry.value,
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTimeRange = value;
                  });
                  _loadData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _getLocalizedTimeRange(AppLocalizations l10n, String key) {
    switch (key) {
      case 'week':
        return l10n.screensSettingsStatisticsLastWeek;
      case 'month':
        return l10n.screensSettingsStatisticsLastMonth;
      case 'threeMonths':
        return l10n.screensSettingsStatisticsLastThreeMonths;
      case 'sixMonths':
        return l10n.screensSettingsStatisticsLastSixMonths;
      case 'year':
        return l10n.screensSettingsStatisticsLastYear;
      case 'all':
        return l10n.screensSettingsStatisticsAllTime;
      default:
        return null;
    }
  }

  Widget _buildStatsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String tooltipText,
    required Widget chart,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Tooltip(
                  message: tooltipText,
                  child: const Icon(Icons.info_outline, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_metricsHistory.isEmpty) {
      return Center(
        child: Text(l10n.screensSettingsStatisticsNoWeightDataAvailable),
      );
    }

    // Use weekly median for weight to smooth out daily fluctuations
    final medianData = _calculateWeeklyMedian(_metricsHistory);

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: LineChartPainter(
        data: medianData,
        valueKey: 'weight',
        dateKey: 'recorded_date',
        minValue: _minWeight,
        maxValue: _maxWeight,
        lineColor: Colors.blue,
        pointColor: Colors.blue.shade800,
      ),
    );
  }

  Widget _buildBMIChart(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_metricsHistory.isEmpty) {
      return Center(
        child: Text(l10n.screensSettingsStatisticsNoBmiDataAvailable),
      );
    }

    // Calculate BMI for each entry
    final bmiData =
        _metricsHistory
            .where((entry) {
              final weight = entry['weight'] as double?;
              final height = entry['height'] as double?;
              return weight != null && height != null && height > 0;
            })
            .map((entry) {
              final weight = entry['weight'] as double;
              final height = entry['height'] as double;
              final bmi = weight / ((height / 100) * (height / 100));

              return {'recorded_date': entry['recorded_date'], 'bmi': bmi};
            })
            .toList();

    if (bmiData.isEmpty) {
      return Center(
        child: Text(l10n.screensSettingsStatisticsCannotCalculateBmiFromData),
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: LineChartPainter(
        data: bmiData,
        valueKey: 'bmi',
        dateKey: 'recorded_date',
        minValue: _minBMI,
        maxValue: _maxBMI,
        lineColor: Colors.green,
        pointColor:
            Colors.green.shade800, // Add reference lines for BMI categories
        referenceLines: [
          ReferenceLine(
            value: 18.5,
            color: Colors.orange.withValues(alpha: 0.5),
            label: l10n.screensSettingsStatisticsBmiUnderweight,
          ),
          ReferenceLine(
            value: 25.0,
            color: Colors.orange.withValues(alpha: 0.5),
            label: l10n.screensSettingsStatisticsBmiOverweight,
          ),
          ReferenceLine(
            value: 30.0,
            color: Colors.red.withValues(alpha: 0.5),
            label: l10n.screensSettingsStatisticsBmiObese,
          ),
        ],
      ),
    );
  }

  Widget _buildBodyFatChart(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bodyFatData =
        _metricsHistory.where((entry) => entry['body_fat'] != null).toList();

    if (bodyFatData.isEmpty) {
      return Center(
        child: Text(l10n.screensSettingsStatisticsNoBodyFatDataAvailable),
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: LineChartPainter(
        data: bodyFatData,
        valueKey: 'body_fat',
        dateKey: 'recorded_date',
        minValue: _minBodyFat,
        maxValue: _maxBodyFat,
        lineColor: Colors.purple,
        pointColor: Colors.purple.shade800,
      ),
    );
  }

  Widget _buildCalorieChart(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_calorieHistory.isEmpty || _maintenanceCalories == null) {
      return Center(
        child: Text(l10n.screensSettingsStatisticsNoCalorieDataAvailable),
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: CalorieChartPainter(
        data: _calorieHistory,
        maintenanceCalories: _maintenanceCalories!,
        minValue: _minCalories,
        maxValue: _maxCalories,
      ),
    );
  }

  Widget _buildPhaseIndicators(BuildContext context, AppLocalizations l10n) {
    if (_calorieHistory.isEmpty || _maintenanceCalories == null) {
      return const SizedBox.shrink();
    }

    // Calculate phase statistics
    final phaseStats = _calculatePhaseStatistics();
    final warnings = _getCalorieWarnings();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.screensSettingsStatisticsPhaseAnalysis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Phase distribution
            Row(
              children: [
                Expanded(
                  child: _buildPhaseIndicator(
                    context,
                    l10n.screensSettingsStatisticsMaintenance,
                    phaseStats['maintenance']!,
                    Colors.green,
                    Icons.balance,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPhaseIndicator(
                    context,
                    l10n.screensSettingsStatisticsCutting,
                    phaseStats['cutting']!,
                    Colors.blue,
                    Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPhaseIndicator(
                    context,
                    l10n.screensSettingsStatisticsBulking,
                    phaseStats['bulking']!,
                    Colors.orange,
                    Icons.trending_up,
                  ),
                ),
              ],
            ),

            // Weekly surplus/deficit
            const SizedBox(height: 16),
            _buildWeeklySummary(context, l10n),

            // Warnings
            if (warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...warnings.map((warning) => _buildWarningCard(context, warning)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseIndicator(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    final percentage =
        _calorieHistory.isNotEmpty
            ? (count / _calorieHistory.length * 100).round()
            : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '($count days)',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(BuildContext context, AppLocalizations l10n) {
    final weeklyAverage = _calculateWeeklyCalorieAverage();
    final weeklyDeficit = _maintenanceCalories! - weeklyAverage;
    final isDeficit = weeklyDeficit > 0;

    // Calculate actual weekly deficit if health data is available
    double? actualWeeklyDeficit;
    String? healthDataLabel;

    if (_isHealthConnected && _caloriesBurnedData.isNotEmpty) {
      final healthDataDays = _calorieHistory.where(
        (entry) => entry['deficit'] != null,
      );
      if (healthDataDays.isNotEmpty) {
        final totalActualDeficit = healthDataDays
            .map((entry) => entry['deficit'] as double)
            .reduce((a, b) => a + b);
        actualWeeklyDeficit = totalActualDeficit / healthDataDays.length;
        healthDataLabel = 'Actual Balance';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Estimated deficit row (original calculation)
          Row(
            children: [
              Icon(
                isDeficit ? Icons.trending_down : Icons.trending_up,
                color: isDeficit ? Colors.blue : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      actualWeeklyDeficit != null
                          ? l10n.screensSettingsStatisticsEstimatedBalance
                          : (l10n.screensSettingsStatisticsWeeklyAverage),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${isDeficit ? "-" : "+"}${weeklyDeficit.abs().round()} cal/day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDeficit ? Colors.blue : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${weeklyAverage.round()} cal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Actual deficit row (if health data available)
          if (actualWeeklyDeficit != null) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  actualWeeklyDeficit < 0
                      ? Icons.trending_down
                      : Icons.trending_up,
                  color: actualWeeklyDeficit < 0 ? Colors.blue : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            healthDataLabel!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.health_and_safety,
                            size: 12,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      Text(
                        '${actualWeeklyDeficit < 0 ? "" : "+"}${actualWeeklyDeficit.round()} cal/day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              actualWeeklyDeficit < 0
                                  ? Colors.blue
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n.screensSettingsStatisticsVsExpenditure,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context, String warning) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.warning_amber,
              color: colorScheme.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warning,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
                height: 1.3,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculatePhaseStatistics() {
    int maintenance = 0;
    int cutting = 0;
    int bulking = 0;

    for (final entry in _calorieHistory) {
      final calories = entry['calories'] as double;
      final diff = calories - _maintenanceCalories!;

      if (diff.abs() <= 100) {
        maintenance++;
      } else if (diff < 0) {
        cutting++;
      } else {
        bulking++;
      }
    }

    return {'maintenance': maintenance, 'cutting': cutting, 'bulking': bulking};
  }

  double _calculateWeeklyCalorieAverage() {
    if (_calorieHistory.isEmpty) return 0;

    final totalCalories = _calorieHistory.fold<double>(
      0,
      (sum, entry) => sum + (entry['calories'] as double),
    );

    return totalCalories / _calorieHistory.length;
  }

  List<String> _getCalorieWarnings() {
    final l10n = AppLocalizations.of(context);
    final warnings = <String>[];

    // Check for extremely low calorie days
    final veryLowDays =
        _calorieHistory
            .where((entry) => (entry['calories'] as double) < 1000)
            .length;
    if (veryLowDays > 0) {
      warnings.add(
        l10n.screensSettingsStatisticsVeryLowCalorieWarning(
          veryLowDays.toString(),
        ),
      );
    }

    // Check for extremely high calorie days
    final veryHighDays =
        _calorieHistory
            .where(
              (entry) =>
                  (entry['calories'] as double) >
                  (_maintenanceCalories! + 1000),
            )
            .length;
    if (veryHighDays > 0) {
      warnings.add(
        l10n.screensSettingsStatisticsVeryHighCalorieNotice(
          veryHighDays.toString(),
        ),
      );
    }

    // Check for consistent extreme deficit
    final extremeDeficitDays =
        _calorieHistory
            .where(
              (entry) =>
                  (entry['calories'] as double) < (_maintenanceCalories! - 750),
            )
            .length;

    if (extremeDeficitDays > _calorieHistory.length * 0.5) {
      warnings.add(l10n.screensSettingsStatisticsExtremeDeficitWarning);
    }

    // Health data based warnings
    if (_isHealthConnected && _caloriesBurnedData.isNotEmpty) {
      // Check for days with very large deficits based on actual expenditure
      final largeDeficitDays =
          _calorieHistory.where((entry) {
            final deficit = entry['deficit'] as double?;
            return deficit != null &&
                deficit < -1000; // More than 1000 cal deficit
          }).length;
      if (largeDeficitDays > 0) {
        warnings.add(
          l10n.screensSettingsStatisticsHealthDataAlert(
            largeDeficitDays.toString(),
          ),
        );
      }

      // Check for inconsistent deficit patterns
      final deficits =
          _calorieHistory
              .where((entry) => entry['deficit'] != null)
              .map((entry) => entry['deficit'] as double)
              .toList();

      if (deficits.length > 7) {
        final avgDeficit = deficits.reduce((a, b) => a + b) / deficits.length;
        final deficitVariance =
            deficits
                .map((d) => math.pow(d - avgDeficit, 2))
                .reduce((a, b) => a + b) /
            deficits.length;
        if (deficitVariance > 250000) {
          // High variance in deficits
          final varianceValue = math.sqrt(deficitVariance).round();
          warnings.add(
            l10n.screensSettingsStatisticsInconsistentDeficitWarning(
              varianceValue.toString(),
            ),
          );
        }
      }
    }

    return warnings;
  }
}

// Simple chart painter for a line chart
class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final String valueKey;
  final String dateKey;
  final double minValue;
  final double maxValue;
  final Color lineColor;
  final Color pointColor;
  final List<ReferenceLine>? referenceLines;

  LineChartPainter({
    required this.data,
    required this.valueKey,
    required this.dateKey,
    required this.minValue,
    required this.maxValue,
    required this.lineColor,
    required this.pointColor,
    this.referenceLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final horizontalPadding = width * 0.05;
    final verticalPadding = height * 0.1;

    final chartWidth = width - (horizontalPadding * 2);
    final chartHeight = height - (verticalPadding * 2);

    // Draw X and Y axis
    final axisPaint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1;

    canvas.drawLine(
      Offset(horizontalPadding, height - verticalPadding),
      Offset(width - horizontalPadding, height - verticalPadding),
      axisPaint,
    );

    canvas.drawLine(
      Offset(horizontalPadding, verticalPadding),
      Offset(horizontalPadding, height - verticalPadding),
      axisPaint,
    );

    // Draw reference lines if any
    final referenceLinePaint =
        Paint()
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    referenceLines?.forEach((line) {
      final yPos = _mapValueToYPosition(
        line.value,
        minValue,
        maxValue,
        verticalPadding,
        chartHeight,
      );

      referenceLinePaint.color = line.color;

      // Draw dashed line
      final dashWidth = 5;
      final dashSpace = 3;
      double startX = horizontalPadding;
      final endX = width - horizontalPadding;
      final dashPath = Path();

      while (startX < endX) {
        final endDash = startX + dashWidth < endX ? startX + dashWidth : endX;
        dashPath.moveTo(startX, yPos);
        dashPath.lineTo(endDash, yPos);
        startX = endDash + dashSpace;
      }

      canvas.drawPath(dashPath, referenceLinePaint);

      // Draw label
      textPainter.text = TextSpan(
        text: line.label,
        style: TextStyle(color: line.color, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(horizontalPadding + 4, yPos - textPainter.height),
      );
    });

    // Sort data by date
    final sortedData = List<Map<String, dynamic>>.from(data);
    sortedData.sort((a, b) {
      final dateA = DateTime.parse(a[dateKey] as String);
      final dateB = DateTime.parse(b[dateKey] as String);
      return dateA.compareTo(dateB);
    });

    // Get min and max dates for scaling
    final DateTime minDate = DateTime.parse(
      sortedData.first[dateKey] as String,
    );
    final DateTime maxDate = DateTime.parse(sortedData.last[dateKey] as String);
    final totalDays = maxDate.difference(minDate).inDays + 1;

    // Line and point paints
    final linePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final pointPaint =
        Paint()
          ..color = pointColor
          ..strokeWidth = 1
          ..style = PaintingStyle.fill;

    // Draw the line graph
    final path = Path();
    bool firstPoint = true;

    for (final entry in sortedData) {
      final value = entry[valueKey] as double;
      final date = DateTime.parse(entry[dateKey] as String);

      // Map data point to coordinates
      final daysSinceStart = date.difference(minDate).inDays;
      final xPos =
          horizontalPadding + (daysSinceStart / totalDays) * chartWidth;
      final yPos = _mapValueToYPosition(
        value,
        minValue,
        maxValue,
        verticalPadding,
        chartHeight,
      );

      if (firstPoint) {
        path.moveTo(xPos, yPos);
        firstPoint = false;
      } else {
        path.lineTo(xPos, yPos);
      }

      // Draw point
      canvas.drawCircle(Offset(xPos, yPos), 3, pointPaint);
    }

    // Draw the line
    canvas.drawPath(path, linePaint);

    // Draw Y axis labels
    _drawYAxisLabels(
      canvas,
      minValue,
      maxValue,
      horizontalPadding,
      verticalPadding,
      chartHeight,
    );

    // Draw X axis date labels
    _drawDateLabels(
      canvas,
      minDate,
      maxDate,
      horizontalPadding,
      chartWidth,
      height - verticalPadding,
    );
  }

  double _mapValueToYPosition(
    double value,
    double minValue,
    double maxValue,
    double verticalPadding,
    double chartHeight,
  ) {
    // Map value to Y position (inverted, as Y grows downwards in canvas)
    final valueRange = maxValue - minValue;
    if (valueRange <= 0) return verticalPadding;

    final normalizedValue = (value - minValue) / valueRange;
    return verticalPadding + chartHeight * (1 - normalizedValue);
  }

  void _drawYAxisLabels(
    Canvas canvas,
    double minValue,
    double maxValue,
    double horizontalPadding,
    double verticalPadding,
    double chartHeight,
  ) {
    final labelCount = 5;
    final valueStep = (maxValue - minValue) / (labelCount - 1);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    for (int i = 0; i < labelCount; i++) {
      final value = minValue + (valueStep * i);
      final yPos = _mapValueToYPosition(
        value,
        minValue,
        maxValue,
        verticalPadding,
        chartHeight,
      );

      // Draw tick
      canvas.drawLine(
        Offset(horizontalPadding - 5, yPos),
        Offset(horizontalPadding, yPos),
        Paint()..color = Colors.grey,
      );

      // Draw label
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          horizontalPadding - textPainter.width - 8,
          yPos - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawDateLabels(
    Canvas canvas,
    DateTime minDate,
    DateTime maxDate,
    double horizontalPadding,
    double chartWidth,
    double yPos,
  ) {
    final daysDiff = maxDate.difference(minDate).inDays;

    // Validate daysDiff to prevent Infinity/NaN issues
    if (!daysDiff.isFinite || daysDiff <= 0) {
      return; // Skip drawing labels if invalid date range
    }

    int labelCount;

    // Adjust label count based on date range
    if (daysDiff <= 7) {
      labelCount = daysDiff + 1; // Show each day
    } else if (daysDiff <= 60) {
      labelCount = 4;
    } else {
      labelCount = 3;
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < labelCount; i++) {
      final labelPosition = i / (labelCount - 1);

      // Validate labelPosition and prevent NaN/Infinity
      if (!labelPosition.isFinite) continue;

      final xPos = horizontalPadding + labelPosition * chartWidth;

      // Validate xPos
      if (!xPos.isFinite) continue;

      final daysOffsetDouble = daysDiff * labelPosition;

      // Validate daysOffset before converting to int
      if (!daysOffsetDouble.isFinite) continue;

      final daysOffset = daysOffsetDouble.round();
      final labelDate = minDate.add(Duration(days: daysOffset));

      // Format date based on range
      String dateLabel;
      if (daysDiff <= 30) {
        dateLabel = '${labelDate.day}/${labelDate.month}';
      } else {
        dateLabel = '${labelDate.month}/${labelDate.year}';
      }

      // Draw tick
      canvas.drawLine(
        Offset(xPos, yPos),
        Offset(xPos, yPos + 5),
        Paint()..color = Colors.grey,
      );

      // Draw label
      textPainter.text = TextSpan(
        text: dateLabel,
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos - textPainter.width / 2, yPos + 8));
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue;
  }
}

class ReferenceLine {
  final double value;
  final Color color;
  final String label;

  ReferenceLine({
    required this.value,
    required this.color,
    required this.label,
  });
}

// Custom chart painter for calorie intake vs maintenance
class CalorieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maintenanceCalories;
  final double minValue;
  final double maxValue;

  CalorieChartPainter({
    required this.data,
    required this.maintenanceCalories,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const horizontalPadding = 40.0;
    const verticalPadding = 20.0;
    final chartWidth = size.width - (horizontalPadding * 2);
    final chartHeight = size.height - (verticalPadding * 2);

    // Sort data by date
    final sortedData = List<Map<String, dynamic>>.from(data);
    sortedData.sort((a, b) {
      final dateA = DateTime.parse(a['date'] as String);
      final dateB = DateTime.parse(b['date'] as String);
      return dateA.compareTo(dateB);
    });

    if (sortedData.isEmpty) return;

    final firstDate = DateTime.parse(sortedData.first['date'] as String);
    final lastDate = DateTime.parse(sortedData.last['date'] as String);
    final totalDays = lastDate.difference(firstDate).inDays.toDouble();

    // Draw maintenance line
    _drawMaintenanceLine(
      canvas,
      horizontalPadding,
      chartWidth,
      verticalPadding,
      chartHeight,
    );

    // Draw calorie bars with color coding
    _drawCalorieBars(
      canvas,
      sortedData,
      firstDate,
      totalDays,
      horizontalPadding,
      chartWidth,
      verticalPadding,
      chartHeight,
    );

    // Draw Y axis labels
    _drawYAxisLabels(canvas, horizontalPadding, verticalPadding, chartHeight);

    // Draw X axis date labels
    _drawDateLabels(
      canvas,
      firstDate,
      lastDate,
      horizontalPadding,
      chartWidth,
      size.height - verticalPadding,
    );
  }

  void _drawMaintenanceLine(
    Canvas canvas,
    double horizontalPadding,
    double chartWidth,
    double verticalPadding,
    double chartHeight,
  ) {
    final maintenanceY = _mapValueToYPosition(
      maintenanceCalories,
      verticalPadding,
      chartHeight,
    );

    final paint =
        Paint()
          ..color = Colors.green.withValues(alpha: 0.7)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(horizontalPadding, maintenanceY),
      Offset(horizontalPadding + chartWidth, maintenanceY),
      paint,
    );

    // Draw maintenance label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Maintenance',
        style: TextStyle(
          color: Colors.green.shade700,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        horizontalPadding + chartWidth - textPainter.width - 8,
        maintenanceY - textPainter.height - 4,
      ),
    );
  }

  void _drawCalorieBars(
    Canvas canvas,
    List<Map<String, dynamic>> sortedData,
    DateTime firstDate,
    double totalDays,
    double horizontalPadding,
    double chartWidth,
    double verticalPadding,
    double chartHeight,
  ) {
    final barWidth = totalDays > 0 ? (chartWidth / totalDays) * 0.8 : 2.0;

    for (final entry in sortedData) {
      final date = DateTime.parse(entry['date'] as String);
      final calories = entry['calories'] as double;

      final daysDiff = date.difference(firstDate).inDays.toDouble();
      final xPos = horizontalPadding + (daysDiff / totalDays) * chartWidth;

      final calorieY = _mapValueToYPosition(
        calories,
        verticalPadding,
        chartHeight,
      );
      final baseY = _mapValueToYPosition(0, verticalPadding, chartHeight);

      // Determine color based on phase
      Color barColor;
      final diff = calories - maintenanceCalories;

      if (diff.abs() <= 100) {
        barColor = Colors.green; // Maintenance
      } else if (diff < 0) {
        barColor = Colors.blue; // Cutting
      } else {
        barColor = Colors.orange; // Bulking
      }

      // Add intensity based on how far from maintenance
      final intensity = (diff.abs() / 500).clamp(0.3, 1.0);
      barColor = barColor.withValues(alpha: intensity);

      final paint =
          Paint()
            ..color = barColor
            ..style = PaintingStyle.fill;

      // Draw bar
      canvas.drawRect(
        Rect.fromLTWH(
          xPos - barWidth / 2,
          math.min(calorieY, baseY),
          barWidth,
          (baseY - calorieY).abs(),
        ),
        paint,
      );
    }
  }

  double _mapValueToYPosition(
    double value,
    double verticalPadding,
    double chartHeight,
  ) {
    final valueRange = maxValue - minValue;
    if (valueRange <= 0) return verticalPadding;

    final normalizedValue = (value - minValue) / valueRange;
    return verticalPadding + chartHeight * (1 - normalizedValue);
  }

  void _drawYAxisLabels(
    Canvas canvas,
    double horizontalPadding,
    double verticalPadding,
    double chartHeight,
  ) {
    final labelCount = 5;
    final valueStep = (maxValue - minValue) / (labelCount - 1);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    for (int i = 0; i < labelCount; i++) {
      final value = minValue + (valueStep * i);
      final yPos = _mapValueToYPosition(value, verticalPadding, chartHeight);

      // Draw tick
      canvas.drawLine(
        Offset(horizontalPadding - 5, yPos),
        Offset(horizontalPadding, yPos),
        Paint()..color = Colors.grey,
      );

      // Draw label
      textPainter.text = TextSpan(
        text: '${value.round()}',
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          horizontalPadding - textPainter.width - 8,
          yPos - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawDateLabels(
    Canvas canvas,
    DateTime minDate,
    DateTime maxDate,
    double horizontalPadding,
    double chartWidth,
    double yPos,
  ) {
    final daysDiff = maxDate.difference(minDate).inDays;

    // Validate daysDiff to prevent Infinity/NaN issues
    if (!daysDiff.isFinite || daysDiff <= 0) {
      return; // Skip drawing labels if invalid date range
    }

    int labelCount;

    // Adjust label count based on date range
    if (daysDiff <= 7) {
      labelCount = daysDiff + 1; // Show each day
    } else if (daysDiff <= 60) {
      labelCount = 4;
    } else {
      labelCount = 3;
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < labelCount; i++) {
      final labelPosition = i / (labelCount - 1);

      // Validate labelPosition and prevent NaN/Infinity
      if (!labelPosition.isFinite) continue;

      final xPos = horizontalPadding + labelPosition * chartWidth;

      // Validate xPos
      if (!xPos.isFinite) continue;

      final daysOffsetDouble = daysDiff * labelPosition;

      // Validate daysOffset before converting to int
      if (!daysOffsetDouble.isFinite) continue;

      final daysOffset = daysOffsetDouble.round();
      final labelDate = minDate.add(Duration(days: daysOffset));

      // Format date based on range
      String dateLabel;
      if (daysDiff <= 30) {
        dateLabel = '${labelDate.day}/${labelDate.month}';
      } else {
        dateLabel = '${labelDate.month}/${labelDate.year}';
      }

      // Draw tick
      canvas.drawLine(
        Offset(xPos, yPos),
        Offset(xPos, yPos + 5),
        Paint()..color = Colors.grey,
      );

      // Draw label
      textPainter.text = TextSpan(
        text: dateLabel,
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos - textPainter.width / 2, yPos + 8));
    }
  }

  @override
  bool shouldRepaint(CalorieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.maintenanceCalories != maintenanceCalories ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue;
  }
}
