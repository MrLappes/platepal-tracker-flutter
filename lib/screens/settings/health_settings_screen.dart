import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../../services/health_service.dart';
import '../../services/calorie_expenditure_service.dart';

class HealthSettingsScreen extends StatefulWidget {
  const HealthSettingsScreen({super.key});

  @override
  State<HealthSettingsScreen> createState() => _HealthSettingsScreenState();
}

class _HealthSettingsScreenState extends State<HealthSettingsScreen> {
  final HealthService _healthService = HealthService();
  final CalorieExpenditureService _calorieExpenditureService =
      CalorieExpenditureService();

  bool _isHealthAvailable = false;
  bool _isSyncing = false;
  bool _writeMealsEnabled = true;
  double? _todaysBurnedCalories;
  int _cachedDaysCount = 0;

  StreamSubscription<bool>? _healthConnectionSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _healthConnectionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _healthService.loadConnectionStatus();
    final available = await _healthService.isHealthDataAvailable();
    final prefs = await SharedPreferences.getInstance();
    final writeMeals = prefs.getBool('health_write_meals_enabled') ?? true;

    // Subscribe to connection status changes
    _healthConnectionSubscription = _healthService.connectionStatusStream
        .listen((isConnected) {
          if (mounted) {
            setState(() {});
            if (isConnected) _loadHealthData();
          }
        });

    setState(() {
      _isHealthAvailable = available;
      _writeMealsEnabled = writeMeals;
    });

    if (_healthService.isConnected) {
      await _loadHealthData();
    }
  }

  Future<void> _loadHealthData() async {
    try {
      final storedData = await _healthService.getStoredCaloriesBurnedData();
      final todayKey = DateTime.now().toIso8601String().split('T')[0];
      final todayCalories = storedData[todayKey];

      setState(() {
        _todaysBurnedCalories = todayCalories;
        _cachedDaysCount = storedData.length;
      });
    } catch (_) {}
  }

  Future<void> _connectToHealth() async {
    setState(() => _isSyncing = true);

    try {
      final result = await _healthService.connectToHealthWithDetails();

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).screensSettingsProfileSettingsHealthSyncSuccess,
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _syncHealthData();
      } else {
        switch (result.error) {
          case HealthConnectionError.platformNotSupported:
            _showErrorDialog(
              AppLocalizations.of(
                context,
              ).screensSettingsProfileSettingsHealthNotAvailable,
              AppLocalizations.of(
                context,
              ).screensSettingsProfileSettingsHealthNotAvailableMessage,
            );
            break;
          case HealthConnectionError.permissionDenied:
            _showErrorDialog(
              AppLocalizations.of(
                context,
              ).screensSettingsProfileSettingsHealthPermissionDenied,
              AppLocalizations.of(
                context,
              ).screensSettingsProfileSettingsHealthPermissionDeniedMessage,
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _disconnectFromHealth() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsDisconnectTitle,
            ),
            content: Text(
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsDisconnectMessage,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).componentsChatBotProfileCustomizationDialogCancel,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsHealthSettingsDisconnect,
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _healthService.disconnectFromHealth();
      setState(() {
        _todaysBurnedCalories = null;
        _cachedDaysCount = 0;
      });
    }
  }

  Future<void> _syncHealthData() async {
    if (!_healthService.isConnected) return;

    setState(() => _isSyncing = true);

    try {
      await _healthService.refreshCaloriesBurnedCache();
      await _loadHealthData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).screensSettingsProfileSettingsHealthSyncSuccess,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).screensSettingsProfileSettingsHealthSyncFailed,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _toggleWriteMeals(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('health_write_meals_enabled', value);
    setState(() => _writeMealsEnabled = value);
  }

  Future<void> _analyzeCalorieTargets() async {
    setState(() => _isSyncing = true);

    try {
      await _calorieExpenditureService.initialize();
      final analysis = await _calorieExpenditureService.syncAndAnalyze();

      if (!mounted) return;

      await _showCalorieAnalysisDialog(analysis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsAnalysisFailed(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _showCalorieAnalysisDialog(
    CalorieTargetAnalysis analysis,
  ) async {
    final l10n = AppLocalizations.of(context);

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.screensSettingsProfileSettingsAnalyzeTargets,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnalysisRow(
                    l10n.screensSettingsHealthSettingsCurrentTarget,
                    '${analysis.currentTarget.toStringAsFixed(0)} kcal',
                  ),
                  _buildAnalysisRow(
                    l10n.screensSettingsHealthSettingsAvgExpenditure,
                    '${analysis.averageExpenditure.toStringAsFixed(0)} kcal',
                  ),
                  if (analysis.needsAdjustment)
                    _buildAnalysisRow(
                      l10n.screensSettingsHealthSettingsSuggestedTarget,
                      '${analysis.suggestedTarget.toStringAsFixed(0)} kcal',
                      isHighlighted: true,
                    ),
                  if (analysis.daysAnalyzed > 0)
                    _buildAnalysisRow(
                      l10n.screensSettingsHealthSettingsDaysAnalyzed,
                      '${analysis.daysAnalyzed}',
                    ),
                  const SizedBox(height: 12),
                  Text(
                    analysis.analysisMessage,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.componentsCommonOk),
              ),
              if (analysis.needsAdjustment)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _applyCalorieTarget(analysis.suggestedTarget);
                  },
                  child: Text(l10n.screensSettingsHealthSettingsApply),
                ),
            ],
          ),
    );
  }

  Future<void> _applyCalorieTarget(double newTarget) async {
    final success = await _calorieExpenditureService.updateCalorieTargets(
      newTarget,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? AppLocalizations.of(
                  context,
                ).screensSettingsHealthSettingsCalorieTargetUpdated(
                  newTarget.toStringAsFixed(0),
                )
                : AppLocalizations.of(
                  context,
                ).screensSettingsHealthSettingsCalorieTargetUpdateFailed,
          ),
          backgroundColor:
              success ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildAnalysisRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              color:
                  isHighlighted ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openHealthSettings() async {
    try {
      // Try to open Health Connect settings on Android
      final uri = Uri.parse(
        'market://details?id=com.google.android.apps.healthdata',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).componentsCommonOk),
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
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).screensSettingsHealthSettingsTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Connection status card
          _buildConnectionCard(theme, colorScheme),
          const SizedBox(height: 16),

          // Only show other cards when connected
          if (_healthService.isConnected) ...[
            _buildDataOverviewCard(theme, colorScheme),
            const SizedBox(height: 16),
            _buildSyncCard(theme, colorScheme),
            const SizedBox(height: 16),
            _buildWriteBehaviorCard(theme, colorScheme),
            const SizedBox(height: 16),
            _buildAnalysisCard(theme, colorScheme),
            const SizedBox(height: 16),
          ],

          // Info card when disconnected
          if (!_healthService.isConnected) _buildInfoCard(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(ThemeData theme, ColorScheme colorScheme) {
    final isConnected = _healthService.isConnected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        isConnected
                            ? Colors.green.withValues(alpha: 0.1)
                            : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    isConnected
                        ? Icons.health_and_safety
                        : Icons.health_and_safety_outlined,
                    color: isConnected ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected
                            ? AppLocalizations.of(
                              context,
                            ).screensSettingsHealthSettingsConnected
                            : AppLocalizations.of(
                              context,
                            ).screensSettingsHealthSettingsNotConnected,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isConnected ? Colors.green : Colors.grey[700],
                        ),
                      ),
                      if (isConnected && _healthService.lastSyncDate != null)
                        Text(
                          AppLocalizations.of(
                            context,
                          ).screensSettingsHealthSettingsLastSynced(
                            _formatTimestamp(_healthService.lastSyncDate!),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                // Connection status dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isConnected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child:
                  isConnected
                      ? OutlinedButton.icon(
                        onPressed: _isSyncing ? null : _disconnectFromHealth,
                        icon: const Icon(Icons.link_off),
                        label: Text(
                          AppLocalizations.of(
                            context,
                          ).screensSettingsProfileSettingsDisconnectHealth,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(
                            color: colorScheme.error.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                      : ElevatedButton.icon(
                        onPressed:
                            _isSyncing || !_isHealthAvailable
                                ? null
                                : _connectToHealth,
                        icon:
                            _isSyncing
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.add_link),
                        label: Text(
                          AppLocalizations.of(
                            context,
                          ).screensSettingsProfileSettingsConnectToHealth,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
            ),
            if (!_isHealthAvailable && !_healthService.isConnected) ...[
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(
                  context,
                ).screensSettingsHealthSettingsNotAvailableOnDevice,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataOverviewCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsHealthSettingsDataOverview,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Today's burned calories
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.deepOrange,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        ).screensSettingsHealthSettingsTodaysBurned,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        _todaysBurnedCalories != null
                            ? '${_todaysBurnedCalories!.toStringAsFixed(0)} kcal'
                            : AppLocalizations.of(
                              context,
                            ).screensSettingsHealthSettingsNoDataYet,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Cached days count
            Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsHealthSettingsDaysCached(_cachedDaysCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsHealthSettingsSyncControls,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _syncHealthData,
                icon:
                    _isSyncing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.sync),
                label: Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsProfileSettingsSyncHealthData,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsSyncDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            // Open Health Connect
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openHealthSettings,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsHealthSettingsOpenHealthConnect,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteBehaviorCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsHealthSettingsWriteBehavior,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppLocalizations.of(
                  context,
                ).screensSettingsHealthSettingsWriteMeals,
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                ).screensSettingsHealthSettingsWriteMealsDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: _writeMealsEnabled,
              onChanged: _toggleWriteMeals,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsHealthSettingsTargetAnalysis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsTargetAnalysisDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _analyzeCalorieTargets,
                icon:
                    _isSyncing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.analytics),
                label: Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsProfileSettingsAnalyzeTargets,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsHealthSettingsAboutHealthConnect,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsAboutDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(
              Icons.local_fire_department,
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsFeatureReadCalories,
            ),
            _buildFeatureItem(
              Icons.restaurant,
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsFeatureWriteMeals,
            ),
            _buildFeatureItem(
              Icons.trending_up,
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsFeatureNetBalance,
            ),
            _buildFeatureItem(
              Icons.analytics,
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsFeatureRecommendations,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(
                context,
              ).screensSettingsHealthSettingsAboutNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context).screensSettingsHealthSettingsJustNow;
    } else if (difference.inHours < 1) {
      return AppLocalizations.of(
        context,
      ).screensSettingsHealthSettingsMinutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return AppLocalizations.of(
        context,
      ).screensSettingsHealthSettingsHoursAgo(difference.inHours);
    } else {
      return AppLocalizations.of(
        context,
      ).screensSettingsHealthSettingsDaysAgo(difference.inDays);
    }
  }
}
