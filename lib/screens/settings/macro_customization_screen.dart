import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/ui/low_calorie_target_warning.dart';
import '../../models/user_profile.dart';
import '../../utils/number_parsing.dart';
import '../../utils/service_extensions.dart';
import '../../services/user_session_service.dart';

class MacroCustomizationScreen extends StatefulWidget {
  const MacroCustomizationScreen({super.key});

  @override
  State<MacroCustomizationScreen> createState() =>
      _MacroCustomizationScreenState();
}

class _MacroCustomizationScreenState extends State<MacroCustomizationScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  // Macro ratio state (percentages)
  double _proteinRatio = 40.0; // 40%
  double _carbsRatio = 30.0; // 30%
  double _fatRatio = 30.0; // 30%

  // Pin state for macros
  bool _proteinPinned = false;
  bool _carbsPinned = false;
  bool _fatPinned = false;

  // Fiber target (grams per 1000 calories)
  double _fiberPer1000Cal = 14.0;

  UserProfile? _userProfile;
  double _dailyCalories = 2000.0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);

      // Get current user ID from session service
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs);
      final currentUserId = userSessionService.getCurrentUserId();
      try {
        if (!mounted) return;
        final userProfileService = context.userProfileService;
        var userProfile = await userProfileService.getUserProfile(
          currentUserId,
        );
        if (!mounted) return;

        if (userProfile != null) {
          _userProfile = userProfile;

          if (mounted) {
            _dailyCalories = userProfile.goals.targetCalories;

            // Calculate current ratios from existing targets
            final totalMacroCals =
                (userProfile.goals.targetProtein * 4) +
                (userProfile.goals.targetCarbs * 4) +
                (userProfile.goals.targetFat * 9);

            if (totalMacroCals > 0) {
              _proteinRatio =
                  ((userProfile.goals.targetProtein * 4) / totalMacroCals) *
                  100;
              _carbsRatio =
                  ((userProfile.goals.targetCarbs * 4) / totalMacroCals) * 100;
              _fatRatio =
                  ((userProfile.goals.targetFat * 9) / totalMacroCals) * 100;
            }

            // Calculate fiber per 1000 calories with validation
            final calculatedFiber =
                _dailyCalories > 0
                    ? userProfile.goals.targetFiber / (_dailyCalories / 1000)
                    : 14.0;
            _fiberPer1000Cal = calculatedFiber.clamp(5.0, 35.0);
          }
        } else {
          // Handle case where user profile does not exist
          _showErrorSnackBar(
            AppLocalizations.of(
              context,
            ).screensSettingsMacroCustomizationProfileNotFound,
          );
          setState(() {
            _userProfile = UserProfile(
              id: currentUserId,
              name: 'New User',
              email: '',
              age: 0,
              gender: 'Not Specified',
              height: 0,
              weight: 0,
              activityLevel: 'Sedentary',
              goals: FitnessGoals(
                goal: 'Maintain Weight',
                targetWeight: 0,
                targetCalories: 2000,
                targetProtein: 50,
                targetCarbs: 250,
                targetFat: 70,
                targetFiber: 28,
              ),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            _dailyCalories = 2000.0;
            _proteinRatio = 40.0;
            _carbsRatio = 30.0;
            _fatRatio = 30.0;
            _fiberPer1000Cal = 14.0;
          });
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(
            AppLocalizations.of(
              context,
            ).screensSettingsMacroCustomizationLoadFailed(e.toString()),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (error) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(
            context,
          ).screensSettingsMacroCustomizationLoadFailed(error.toString()),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _onRatioChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _togglePin(String macroType) {
    setState(() {
      switch (macroType) {
        case 'protein':
          if (!_proteinPinned) {
            // Pin protein and unpin others
            _proteinPinned = true;
            _carbsPinned = false;
            _fatPinned = false;
          } else {
            // Unpin protein
            _proteinPinned = false;
          }
          break;
        case 'carbs':
          if (!_carbsPinned) {
            // Pin carbs and unpin others
            _carbsPinned = true;
            _proteinPinned = false;
            _fatPinned = false;
          } else {
            // Unpin carbs
            _carbsPinned = false;
          }
          break;
        case 'fat':
          if (!_fatPinned) {
            // Pin fat and unpin others
            _fatPinned = true;
            _proteinPinned = false;
            _carbsPinned = false;
          } else {
            // Unpin fat
            _fatPinned = false;
          }
          break;
      }
      _onRatioChanged();
    });
  }

  void _adjustRatios(String changedMacro, double newValue) {
    setState(() {
      // Count pinned macros
      final pinnedCount =
          [_proteinPinned, _carbsPinned, _fatPinned].where((p) => p).length;

      // Don't allow adjustment if the changed macro is pinned
      bool isChangedMacroPinned = false;
      switch (changedMacro) {
        case 'protein':
          isChangedMacroPinned = _proteinPinned;
          break;
        case 'carbs':
          isChangedMacroPinned = _carbsPinned;
          break;
        case 'fat':
          isChangedMacroPinned = _fatPinned;
          break;
      }

      if (isChangedMacroPinned) {
        // Don't allow changes to pinned macros
        return;
      }

      // If 2 or more macros are pinned, don't allow changes
      if (pinnedCount >= 2) {
        return;
      }

      if (pinnedCount == 1) {
        final pinnedRatio =
            _proteinPinned
                ? _proteinRatio
                : _carbsPinned
                ? _carbsRatio
                : _fatRatio;
        newValue = newValue.clamp(10.0, 90.0 - pinnedRatio);
      }

      if (changedMacro == 'protein') {
        _proteinRatio = newValue;
        final remainingPercentage = 100.0 - _proteinRatio;

        if (_carbsPinned && !_fatPinned) {
          // Only fat can change
          _fatRatio = remainingPercentage - _carbsRatio;
        } else if (_fatPinned && !_carbsPinned) {
          // Only carbs can change
          _carbsRatio = remainingPercentage - _fatRatio;
        } else if (!_carbsPinned && !_fatPinned) {
          // Both carbs and fat can change proportionally
          final totalOther = _carbsRatio + _fatRatio;
          if (totalOther > 0) {
            final carbsRatio = _carbsRatio / totalOther;
            final fatRatio = _fatRatio / totalOther;
            _carbsRatio = remainingPercentage * carbsRatio;
            _fatRatio = remainingPercentage * fatRatio;
          } else {
            _carbsRatio = remainingPercentage / 2;
            _fatRatio = remainingPercentage / 2;
          }
        }
      } else if (changedMacro == 'carbs') {
        _carbsRatio = newValue;
        final remainingPercentage = 100.0 - _carbsRatio;

        if (_proteinPinned && !_fatPinned) {
          // Only fat can change
          _fatRatio = remainingPercentage - _proteinRatio;
        } else if (_fatPinned && !_proteinPinned) {
          // Only protein can change
          _proteinRatio = remainingPercentage - _fatRatio;
        } else if (!_proteinPinned && !_fatPinned) {
          // Both protein and fat can change proportionally
          final totalOther = _proteinRatio + _fatRatio;
          if (totalOther > 0) {
            final proteinRatio = _proteinRatio / totalOther;
            final fatRatio = _fatRatio / totalOther;
            _proteinRatio = remainingPercentage * proteinRatio;
            _fatRatio = remainingPercentage * fatRatio;
          } else {
            _proteinRatio = remainingPercentage / 2;
            _fatRatio = remainingPercentage / 2;
          }
        }
      } else {
        // fat
        _fatRatio = newValue;
        final remainingPercentage = 100.0 - _fatRatio;

        if (_proteinPinned && !_carbsPinned) {
          // Only carbs can change
          _carbsRatio = remainingPercentage - _proteinRatio;
        } else if (_carbsPinned && !_proteinPinned) {
          // Only protein can change
          _proteinRatio = remainingPercentage - _carbsRatio;
        } else if (!_proteinPinned && !_carbsPinned) {
          // Both protein and carbs can change proportionally
          final totalOther = _proteinRatio + _carbsRatio;
          if (totalOther > 0) {
            final proteinRatio = _proteinRatio / totalOther;
            final carbsRatio = _carbsRatio / totalOther;
            _proteinRatio = remainingPercentage * proteinRatio;
            _carbsRatio = remainingPercentage * carbsRatio;
          } else {
            _proteinRatio = remainingPercentage / 2;
            _carbsRatio = remainingPercentage / 2;
          }
        }
      }

      _onRatioChanged();
    });
  }

  Map<String, double> _calculateMacroTargets() {
    final protein = (_dailyCalories * (_proteinRatio / 100)) / 4;
    final carbs = (_dailyCalories * (_carbsRatio / 100)) / 4;
    final fat = (_dailyCalories * (_fatRatio / 100)) / 9;
    final fiber = (_dailyCalories / 1000) * _fiberPer1000Cal;

    return {'protein': protein, 'carbs': carbs, 'fat': fat, 'fiber': fiber};
  }

  Future<void> _saveChanges() async {
    if (_userProfile == null) return;

    setState(() => _isSaving = true);

    try {
      final macros = _calculateMacroTargets();

      final updatedGoals = FitnessGoals(
        goal: _userProfile!.goals.goal,
        targetWeight: _userProfile!.goals.targetWeight,
        targetCalories: _userProfile!.goals.targetCalories,
        targetProtein: macros['protein']!,
        targetCarbs: macros['carbs']!,
        targetFat: macros['fat']!,
        targetFiber: macros['fiber']!,
      );

      final updatedProfile = _userProfile!.copyWith(
        goals: updatedGoals,
        updatedAt: DateTime.now(),
      );

      await context.userProfileService.saveUserProfile(updatedProfile);
      if (!mounted) return;

      _userProfile = updatedProfile;
      setState(() => _hasUnsavedChanges = false);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.screensSettingsMacroCustomizationMacroTargetsUpdated,
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(
            context,
          ).screensSettingsMacroCustomizationSaveFailed(e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetToDefaults() {
    setState(() {
      _proteinRatio = 40.0;
      _carbsRatio = 30.0;
      _fatRatio = 30.0;
      _fiberPer1000Cal = 14.0;

      // Reset pin states
      _proteinPinned = false;
      _carbsPinned = false;
      _fatPinned = false;

      _onRatioChanged();
    });
  }

  void _setBalancedPreset() {
    setState(() {
      _proteinRatio = 30.0;
      _carbsRatio = 40.0;
      _fatRatio = 30.0;
      _fiberPer1000Cal = 14.0;

      // Reset pin states
      _proteinPinned = false;
      _carbsPinned = false;
      _fatPinned = false;

      _onRatioChanged();
    });
  }

  void _setHighProteinPreset() {
    setState(() {
      _proteinRatio = 40.0;
      _carbsRatio = 30.0;
      _fatRatio = 30.0;
      _fiberPer1000Cal = 14.0;

      // Reset pin states
      _proteinPinned = false;
      _carbsPinned = false;
      _fatPinned = false;

      _onRatioChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasUnsavedChanges) {
          final shouldSave = await _showUnsavedChangesDialog();
          if (!context.mounted) return;
          if (shouldSave == false) {
            setState(() => _hasUnsavedChanges = false);
            Navigator.of(context).pop();
          } else if (shouldSave == true) {
            await _saveChanges();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${l10n.screensSettingsMacroCustomizationMacroCustomization.toUpperCase()} //',
          ),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _isSaving ? null : _saveChanges,
                tooltip: l10n.componentsChatBotProfileCustomizationDialogSave,
              ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(l10n, theme, colorScheme, locale),
        bottomNavigationBar:
            _hasUnsavedChanges
                ? Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              _isSaving
                                  ? null
                                  : () => Navigator.of(context).pop(),
                          child: Text(
                            l10n.screensSettingsMacroCustomizationDiscardChanges,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    l10n.screensSettingsMacroCustomizationSaveChanges,
                                  ),
                        ),
                      ),
                    ],
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildContent(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    String locale,
  ) {
    final macros = _calculateMacroTargets();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.screensSettingsMacroCustomizationMacroCustomizationInfo,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.screensSettingsMacroCustomizationDailyCalories(
                      formatDecimal(_dailyCalories, locale, fractionDigits: 0),
                    ),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          LowCalorieTargetWarning(
            calories: _dailyCalories,
            padding: const EdgeInsets.only(top: 12),
          ),

          const SizedBox(height: 24),

          // Macro ratio sliders
          _buildSectionHeader(
            l10n.screensSettingsMacroCustomizationMacroRatios,
            theme,
          ),
          _buildMacroSliderCard(l10n, theme, colorScheme, macros, locale),

          const SizedBox(height: 24),

          // Fiber settings
          _buildSectionHeader(
            l10n.screensSettingsMacroCustomizationFiberTarget,
            theme,
          ),
          _buildFiberCard(l10n, theme, colorScheme, macros, locale),

          const SizedBox(height: 24),

          // Preview card
          _buildSectionHeader(
            l10n.screensSettingsMacroCustomizationTargetPreview,
            theme,
          ),
          _buildPreviewCard(l10n, theme, colorScheme, macros, locale),

          const SizedBox(height: 24), // Preset buttons
          _buildSectionHeader(
            l10n.screensSettingsMacroCustomizationQuickPresets,
            theme,
          ),
          _buildPresetButtons(l10n, theme),

          const SizedBox(height: 80), // Extra space for bottom bar
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildMacroSliderCard(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, double> macros,
    String locale,
  ) {
    final macroColors = MacroColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Protein slider
            _buildMacroSlider(
              label: l10n.componentsCalendarMacroSummaryProtein,
              value: _proteinRatio,
              color: macroColors.protein,
              onChanged: (value) => _adjustRatios('protein', value),
              grams: macros['protein']!,
              theme: theme,
              locale: locale,
              isPinned: _proteinPinned,
              onPinToggle: () => _togglePin('protein'),
            ),

            const SizedBox(height: 24),

            // Carbs slider
            _buildMacroSlider(
              label: l10n.componentsCalendarMacroSummaryCarbs,
              value: _carbsRatio,
              color: macroColors.carbs,
              onChanged: (value) => _adjustRatios('carbs', value),
              grams: macros['carbs']!,
              theme: theme,
              locale: locale,
              isPinned: _carbsPinned,
              onPinToggle: () => _togglePin('carbs'),
            ),

            const SizedBox(height: 24),

            // Fat slider
            _buildMacroSlider(
              label: l10n.componentsCalendarMacroSummaryFat,
              value: _fatRatio,
              color: macroColors.fat,
              onChanged: (value) => _adjustRatios('fat', value),
              grams: macros['fat']!,
              theme: theme,
              locale: locale,
              isPinned: _fatPinned,
              onPinToggle: () => _togglePin('fat'),
            ),

            const SizedBox(height: 16),

            // Total percentage display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      (_proteinRatio + _carbsRatio + _fatRatio).round() == 100
                          ? Colors.green
                          : Colors.orange,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    (_proteinRatio + _carbsRatio + _fatRatio).round() == 100
                        ? Icons.check_circle
                        : Icons.warning,
                    color:
                        (_proteinRatio + _carbsRatio + _fatRatio).round() == 100
                            ? Colors.green
                            : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.screensSettingsMacroCustomizationTotalRatio(
                        formatDecimal(
                          _proteinRatio + _carbsRatio + _fatRatio,
                          locale,
                          fractionDigits: 1,
                        ),
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSlider({
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
    required double grams,
    required ThemeData theme,
    required String locale,
    required bool isPinned,
    required VoidCallback onPinToggle,
  }) {
    final l10n = AppLocalizations.of(context);
    // Calculate pin count to determine if slider should be disabled
    final pinnedCount =
        [_proteinPinned, _carbsPinned, _fatPinned].where((p) => p).length;
    final isSliderDisabled = isPinned || pinnedCount >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isPinned ? color : null,
                    ),
                  ),
                  Text(
                    '${formatDecimal(value, locale, fractionDigits: 1)}% (${formatDecimal(grams, locale, fractionDigits: 0)}g)',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            MergeSemantics(
              child: Semantics(
                toggled: isPinned,
                child: IconButton(
                  onPressed: onPinToggle,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  tooltip:
                      isPinned
                          ? l10n.screensSettingsMacroCustomizationUnpinMacro(
                            label,
                          )
                          : l10n.screensSettingsMacroCustomizationPinMacro(
                            label,
                          ),
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color:
                        isPinned ? color : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor:
                isSliderDisabled ? color.withValues(alpha: 0.3) : color,
            thumbColor: isSliderDisabled ? color.withValues(alpha: 0.3) : color,
            overlayColor: color.withValues(alpha: 0.2),
            inactiveTrackColor: color.withValues(alpha: 0.3),
            disabledActiveTrackColor: color.withValues(alpha: 0.2),
            disabledThumbColor: color.withValues(alpha: 0.2),
            disabledInactiveTrackColor: color.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value,
            min: 10.0,
            max: 50.0,
            divisions: 40,
            label: label,
            semanticFormatterCallback:
                (newValue) =>
                    '${formatDecimal(newValue, locale, fractionDigits: 1)}%',
            onChanged: isSliderDisabled ? null : onChanged,
          ),
        ),
        if (isPinned || pinnedCount >= 2)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              isPinned
                  ? l10n.screensSettingsMacroCustomizationPinnedValue
                  : l10n.screensSettingsMacroCustomizationTooManyPins,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isPinned ? color : Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFiberCard(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, double> macros,
    String locale,
  ) {
    final macroColors = MacroColors.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  l10n.componentsCalendarMacroSummaryFiber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.screensSettingsMacroCustomizationFiberTotal(
                    formatDecimal(macros['fiber']!, locale, fractionDigits: 1),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: macroColors.fiber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.screensSettingsMacroCustomizationFiberPer1000Calories(
                formatDecimal(_fiberPer1000Cal, locale, fractionDigits: 1),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: macroColors.fiber,
                thumbColor: macroColors.fiber,
                overlayColor: macroColors.fiber.withValues(alpha: 0.2),
                inactiveTrackColor: macroColors.fiber.withValues(alpha: 0.3),
              ),
              child: Slider(
                value: _fiberPer1000Cal,
                min: 5.0,
                max: 35.0,
                divisions: 60,
                label: l10n.componentsCalendarMacroSummaryFiber,
                semanticFormatterCallback:
                    (newValue) => l10n
                        .screensSettingsMacroCustomizationFiberPer1000Calories(
                          formatDecimal(newValue, locale, fractionDigits: 1),
                        ),
                onChanged: (value) {
                  setState(() {
                    _fiberPer1000Cal = value;
                    _onRatioChanged();
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.screensSettingsMacroCustomizationFiberGuidance,
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

  Widget _buildPreviewCard(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    Map<String, double> macros,
    String locale,
  ) {
    final macroColors = MacroColors.of(context);
    return Card(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.screensSettingsMacroCustomizationDailyMacroTargets,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMacroPreview(
                    l10n.componentsCalendarMacroSummaryProtein,
                    macros['protein']!,
                    'g',
                    macroColors.protein,
                    theme,
                    locale,
                  ),
                ),
                Expanded(
                  child: _buildMacroPreview(
                    l10n.componentsCalendarMacroSummaryCarbs,
                    macros['carbs']!,
                    'g',
                    macroColors.carbs,
                    theme,
                    locale,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMacroPreview(
                    l10n.componentsCalendarMacroSummaryFat,
                    macros['fat']!,
                    'g',
                    macroColors.fat,
                    theme,
                    locale,
                  ),
                ),
                Expanded(
                  child: _buildMacroPreview(
                    l10n.componentsCalendarMacroSummaryFiber,
                    macros['fiber']!,
                    'g',
                    macroColors.fiber,
                    theme,
                    locale,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroPreview(
    String label,
    double value,
    String unit,
    Color color,
    ThemeData theme,
    String locale,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatDecimal(value, locale, fractionDigits: 0)}$unit',
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons(AppLocalizations l10n, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.screensSettingsMacroCustomizationPresetDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Balanced preset button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _setBalancedPreset,
                icon: const Icon(Icons.balance),
                label: Text(
                  l10n.screensSettingsMacroCustomizationBalancedPreset,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // High protein preset button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _setHighProteinPreset,
                icon: const Icon(Icons.fitness_center),
                label: Text(
                  l10n.screensSettingsMacroCustomizationHighProteinPreset,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reset to defaults button
            Center(
              child: TextButton.icon(
                onPressed: _resetToDefaults,
                icon: const Icon(Icons.refresh),
                label: Text(
                  l10n.screensSettingsMacroCustomizationResetToDefaults,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.screensSettingsMacroCustomizationUnsavedChanges),
            content: Text(
              l10n.screensSettingsMacroCustomizationUnsavedChangesMessage,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.screensSettingsMacroCustomizationDiscardChanges,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.screensSettingsMacroCustomizationSaveChanges),
              ),
            ],
          ),
    );
    return result;
  }
}
