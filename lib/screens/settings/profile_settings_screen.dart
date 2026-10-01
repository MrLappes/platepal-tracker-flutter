import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile.dart';
import '../../utils/number_parsing.dart';
import '../../utils/nutrition_calculator.dart';
import '../../utils/service_extensions.dart';
import '../../services/health_service.dart';

import '../../services/user_session_service.dart';
import 'macro_customization_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _bodyFatController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderately_active';
  String _selectedFitnessGoal = 'maintain_weight';
  String _selectedUnitSystem = 'metric';

  UserProfile? _originalProfile;
  double _preciseHeight = 0;
  double _preciseWeight = 0;
  double _preciseTargetWeight = 0;
  String _displayedHeight = '';
  String _displayedWeight = '';
  String _displayedTargetWeight = '';
  bool _isConvertingUnits = false;

  // Health service integration
  final HealthService _healthService = HealthService();

  // Activity levels with their descriptions
  final Map<String, String> _activityLevels = {
    'sedentary': 'sedentary',
    'lightly_active': 'lightlyActive',
    'moderately_active': 'moderatelyActive',
    'very_active': 'veryActive',
    'extra_active': 'extraActive',
  };

  // Fitness goals with their descriptions
  final Map<String, String> _fitnessGoals = {
    'lose_weight': 'loseWeight',
    'maintain_weight': 'maintainWeight',
    'gain_weight': 'gainWeight',
    'build_muscle': 'buildMuscle',
  };
  @override
  void initState() {
    super.initState();
    _loadProfile();
    _addTextFieldListeners();
    _initializeHealthService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  void _addTextFieldListeners() {
    _nameController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
    _weightController.addListener(_onWeightChanged);
    _targetWeightController.addListener(_onTargetWeightChanged);
    _bodyFatController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _onWeightChanged() {
    _onFieldChanged();
    if (!_isConvertingUnits) _updateGoalBasedOnWeights();
  }

  void _onTargetWeightChanged() {
    _onFieldChanged();
    if (!_isConvertingUnits) _updateGoalBasedOnWeights();
  }

  void _updateGoalBasedOnWeights() {
    if (_selectedFitnessGoal == 'build_muscle') return;

    final currentWeight = parseLocalizedDouble(_weightController.text);
    final targetWeight = parseLocalizedDouble(_targetWeightController.text);

    if (currentWeight == null || targetWeight == null) return;

    // Convert weights to metric for comparison if needed
    double actualCurrentWeight = currentWeight;
    double actualTargetWeight = targetWeight;

    if (_selectedUnitSystem == 'imperial') {
      actualCurrentWeight = currentWeight / 2.2046;
      actualTargetWeight = targetWeight / 2.2046;
    }

    final weightDifference = actualTargetWeight - actualCurrentWeight;
    const threshold = 2.0; // kg threshold for maintaining weight

    String newGoal = _selectedFitnessGoal;

    if (weightDifference.abs() <= threshold) {
      newGoal = 'maintain_weight';
    } else if (weightDifference < -threshold) {
      newGoal = 'lose_weight';
    } else if (weightDifference > threshold) {
      newGoal = 'gain_weight';
    }

    if (newGoal != _selectedFitnessGoal) {
      setState(() {
        _selectedFitnessGoal = newGoal;
      });
    }
  }

  void _adjustTargetWeightForGoal(String newGoal) {
    final currentWeight = parseLocalizedDouble(_weightController.text);
    if (currentWeight == null) return;

    // Convert to metric for calculations if needed
    double actualCurrentWeight = currentWeight;
    if (_selectedUnitSystem == 'imperial') {
      actualCurrentWeight = currentWeight / 2.2046;
    }

    double newTargetWeight = actualCurrentWeight;

    switch (newGoal) {
      case 'maintain_weight':
        newTargetWeight = actualCurrentWeight;
        break;
      case 'lose_weight':
        // If current target is higher than current weight, adjust to 10% lower
        final currentTarget = parseLocalizedDouble(
          _targetWeightController.text,
        );
        if (currentTarget != null) {
          double actualCurrentTarget = currentTarget;
          if (_selectedUnitSystem == 'imperial') {
            actualCurrentTarget = currentTarget / 2.2046;
          }
          if (actualCurrentTarget >= actualCurrentWeight) {
            newTargetWeight = actualCurrentWeight * 0.9; // 10% lower
          } else {
            return; // Keep current target if it's already lower
          }
        } else {
          newTargetWeight = actualCurrentWeight * 0.9; // 10% lower
        }
        break;
      case 'gain_weight':
        // If current target is lower than current weight, adjust to 10% higher
        final currentTarget = parseLocalizedDouble(
          _targetWeightController.text,
        );
        if (currentTarget != null) {
          double actualCurrentTarget = currentTarget;
          if (_selectedUnitSystem == 'imperial') {
            actualCurrentTarget = currentTarget / 2.2046;
          }
          if (actualCurrentTarget <= actualCurrentWeight) {
            newTargetWeight = actualCurrentWeight * 1.1; // 10% higher
          } else {
            return; // Keep current target if it's already higher
          }
        } else {
          newTargetWeight = actualCurrentWeight * 1.1; // 10% higher
        }
        break;
    }

    // Convert back to display units if needed
    if (_selectedUnitSystem == 'imperial') {
      newTargetWeight = newTargetWeight * 2.2046;
    }

    _targetWeightController.text = _formatMeasurement(newTargetWeight);
  }

  // Health service initialization
  Future<void> _initializeHealthService() async {
    await _healthService.loadConnectionStatus();
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);

      // Get current user ID from session service
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs);
      final currentUserId = userSessionService.getCurrentUserId();
      if (!mounted) return;
      // Load from SQLite database
      final userProfile = await context.userProfileService.getUserProfile(
        currentUserId,
      );

      if (userProfile != null && mounted) {
        _originalProfile = userProfile;

        // Load metrics history to get the latest body fat percentage
        _metricsHistory = await context.userProfileService
            .getUserMetricsHistory(
              userProfile.id,
              startDate: DateTime.now().subtract(
                const Duration(days: 30),
              ), // Last 30 days
            );
      } else if (mounted) {
        // Create a default profile if none exists
        final migratedProfile = await context.userProfileService.getUserProfile(
          currentUserId,
        );
        if (migratedProfile != null) {
          _originalProfile = migratedProfile;
        } else {
          // Create a default profile if none exists
          _originalProfile = UserProfile(
            id: currentUserId,
            name: '',
            email: 'user@platepal.app',
            age: 25,
            gender: 'male',
            height: 175.0,
            weight: 70.0,
            activityLevel: 'moderately_active',
            goals: const FitnessGoals(
              goal: 'maintain_weight',
              targetWeight: 70.0,
              targetCalories: 2200.0,
              targetProtein: 140.0,
              targetCarbs: 275.0,
              targetFat: 75.0,
              targetFiber: 25.0,
            ),
            preferences: const DietaryPreferences(),
            preferredUnit: 'metric',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            updatedAt: DateTime.now(),
          );
          if (mounted) {
            // Save the default profile to the database
            await context.userProfileService.saveUserProfile(_originalProfile!);
          }
        }
      }

      if (!mounted) return;
      _populateFields(_originalProfile!);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          AppLocalizations.of(
            context,
          ).screensSettingsProfileSettingsLoadFailed(e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _populateFields(UserProfile profile) {
    _preciseHeight = profile.height;
    _preciseWeight = profile.weight;
    _preciseTargetWeight =
        profile.goals.goal == 'maintain_weight'
            ? profile.weight
            : profile.goals.targetWeight;
    _nameController.text = profile.name;
    _ageController.text = profile.age.toString();

    // Convert height/weight based on unit system
    if (profile.preferredUnit == 'metric') {
      _heightController.text = _formatMeasurement(profile.height);
      _weightController.text = _formatMeasurement(profile.weight);
      // For maintain_weight goal, set target weight to current weight
      if (profile.goals.goal == 'maintain_weight') {
        _targetWeightController.text = _formatMeasurement(profile.weight);
      } else {
        _targetWeightController.text = _formatMeasurement(
          profile.goals.targetWeight,
        );
      }
    } else {
      _heightController.text = _formatMeasurement(profile.height / 2.54);
      _weightController.text = _formatMeasurement(profile.weight * 2.2046);
      // For maintain_weight goal, set target weight to current weight
      if (profile.goals.goal == 'maintain_weight') {
        _targetWeightController.text = _formatMeasurement(
          profile.weight * 2.2046,
        );
      } else {
        _targetWeightController.text = _formatMeasurement(
          profile.goals.targetWeight * 2.2046,
        );
      }
    }
    _displayedHeight = _heightController.text;
    _displayedWeight = _weightController.text;
    _displayedTargetWeight = _targetWeightController.text;

    // Body fat percentage (optional field) - Try to get the last recorded body fat percentage
    if (_metricsHistory.isNotEmpty &&
        _metricsHistory.last['body_fat'] != null) {
      _bodyFatController.text = _metricsHistory.last['body_fat'].toString();
    } else {
      _bodyFatController.text = '';
    }

    setState(() {
      final gender = profile.gender.toLowerCase();
      // The dropdown asserts if its value is not one of its items.
      _selectedGender =
          gender == 'male' || gender == 'female' ? gender : 'other';
      _selectedActivityLevel = profile.activityLevel;
      _selectedFitnessGoal = profile.goals.goal;
      _selectedUnitSystem = profile.preferredUnit;
      _hasUnsavedChanges = false;
    });
  }

  String _formatMeasurement(double value) =>
      value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');

  double? _metricMeasurement(
    TextEditingController controller,
    String displayed,
    double preciseValue,
    bool isMetric,
    double metricMultiplier,
  ) {
    if (controller.text == displayed) return preciseValue;
    final value = parseLocalizedDouble(controller.text);
    if (value == null) return null;
    return isMetric ? value : value * metricMultiplier;
  }

  // Add field to store metrics history
  List<Map<String, dynamic>> _metricsHistory = [];

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Convert units back to metric for storage
      final isMetric = _selectedUnitSystem == 'metric';
      final height =
          _metricMeasurement(
            _heightController,
            _displayedHeight,
            _preciseHeight,
            isMetric,
            2.54,
          )!;
      final weight =
          _metricMeasurement(
            _weightController,
            _displayedWeight,
            _preciseWeight,
            isMetric,
            1 / 2.2046,
          )!;
      final targetWeight =
          _metricMeasurement(
            _targetWeightController,
            _displayedTargetWeight,
            _preciseTargetWeight,
            isMetric,
            1 / 2.2046,
          )!;

      // Calculate nutrition targets
      final age = int.parse(_ageController.text);
      final bmr = mifflinStJeorBmr(
        weightKg: weight,
        heightCm: height,
        age: age,
        gender: _selectedGender,
      );
      final tdee = totalDailyEnergyExpenditure(bmr, _selectedActivityLevel);
      final dailyCalories = calorieTargetForGoal(tdee, _selectedFitnessGoal);
      const defaultEmail = "user@platepal.app";

      // Get current user ID from session service
      final profileService = context.userProfileService;
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs);
      final currentUserId = userSessionService.getCurrentUserId();
      final profileId = _originalProfile?.id ?? currentUserId;

      // Macro customization may have changed the split since this screen loaded.
      final savedGoals =
          (await profileService.getUserProfile(profileId))?.goals ??
          _originalProfile?.goals;
      final macros = macroTargetsFor(dailyCalories, previous: savedGoals);

      final updatedProfile = UserProfile(
        id: profileId,
        name: _nameController.text.trim(),
        email: defaultEmail, // Use default email
        age: age,
        gender: _selectedGender,
        height: height,
        weight: weight,
        activityLevel: _selectedActivityLevel,
        goals: FitnessGoals(
          goal: _selectedFitnessGoal,
          targetWeight: targetWeight,
          targetCalories: dailyCalories,
          targetProtein: macros.protein,
          targetCarbs: macros.carbs,
          targetFat: macros.fat,
          targetFiber: macros.fiber,
        ),
        preferences:
            _originalProfile?.preferences ?? const DietaryPreferences(),
        preferredUnit: _selectedUnitSystem,
        createdAt: _originalProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final bodyFat =
          _bodyFatController.text.isNotEmpty
              ? parseLocalizedDouble(_bodyFatController.text)
              : null;

      if (!mounted) return;
      // Also records a metrics history row if weight/height/body fat changed.
      await context.userProfileService.saveUserProfile(
        updatedProfile,
        bodyFat: bodyFat,
      );
      if (!mounted) return;

      // Update the original profile reference
      _originalProfile = updatedProfile;

      setState(() => _hasUnsavedChanges = false);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.screensSettingsProfileSettingsProfileUpdated),
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
          ).screensSettingsProfileSettingsUpdateFailed(e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showUnsavedChangesDialog() async {
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
                onPressed: () {
                  Navigator.of(context).pop(true);
                  _saveProfile();
                },
                child: Text(l10n.screensSettingsMacroCustomizationSaveChanges),
              ),
            ],
          ),
    );
    if (result == false && mounted) {
      setState(() => _hasUnsavedChanges = false);
      Navigator.of(context).pop();
    }
  }

  Future<void> _navigateToMacroCustomization() async {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MacroCustomizationScreen(),
        ),
      );
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
    }
    return null;
  }

  String? _validateAge(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
    }
    final age = int.tryParse(value.trim());
    if (age == null || age < 13 || age > 120) {
      return l10n.screensSettingsImportProfileCompletionAgeRange;
    }
    return null;
  }

  String? _validateHeight(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
    }
    final height = parseLocalizedDouble(value);
    if (height == null) {
      return l10n.screensSettingsProfileSettingsValidNumber;
    }

    if (_selectedUnitSystem == 'metric') {
      if (height < 100 || height > 250) {
        return l10n.screensSettingsImportProfileCompletionHeightRange;
      }
    } else {
      if (height < 39 || height > 98) {
        return l10n.screensSettingsProfileSettingsImperialHeightRange;
      }
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
    }
    final weight = parseLocalizedDouble(value);
    if (weight == null) {
      return l10n.screensSettingsProfileSettingsValidNumber;
    }

    if (_selectedUnitSystem == 'metric') {
      if (weight < 30 || weight > 300) {
        return l10n.screensSettingsImportProfileCompletionWeightRange;
      }
    } else {
      if (weight < 66 || weight > 660) {
        return l10n.screensSettingsProfileSettingsImperialWeightRange;
      }
    }
    return null;
  }

  String? _validateBodyFat(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final bodyFat = parseLocalizedDouble(value);
    if (bodyFat == null) {
      return l10n.screensSettingsProfileSettingsValidNumber;
    }
    if (bodyFat < 3 || bodyFat > 50) {
      return l10n.screensSettingsProfileSettingsBodyFatRange;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasUnsavedChanges) {
          await _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${l10n.screensSettingsProfileSettingsProfileSettings.toUpperCase()} //',
          ),
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _isSaving ? null : _saveProfile,
                tooltip: l10n.componentsChatBotProfileCustomizationDialogSave,
              ),
          ],
        ),
        body:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.screensChatLoading),
                    ],
                  ),
                )
                : _buildProfileForm(context, l10n),
        bottomNavigationBar:
            _hasUnsavedChanges
                ? Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
                                  : () => _showUnsavedChangesDialog(),
                          child: Text(
                            l10n.screensSettingsMacroCustomizationDiscardChanges,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
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

  Widget _buildProfileForm(BuildContext context, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Information Section
            _buildSectionHeader(
              l10n.screensSettingsImportProfileCompletionPersonalInformation,
            ),
            _buildPersonalInfoCard(l10n),
            const SizedBox(height: 24),

            // Physical Stats Section
            _buildSectionHeader(
              l10n.screensSettingsProfileSettingsPhysicalStats,
            ),
            _buildPhysicalStatsCard(l10n),
            const SizedBox(height: 24),

            // Fitness Goals Section
            _buildSectionHeader(
              l10n.screensSettingsProfileSettingsFitnessGoals,
            ),
            _buildFitnessGoalsCard(l10n),
            const SizedBox(height: 24), // Preferences Section
            _buildSectionHeader(
              l10n.screensSettingsImportProfileCompletionPreferences,
            ),
            _buildPreferencesCard(l10n),
            const SizedBox(height: 24), // Health Data Sync Section
            _buildSectionHeader(
              l10n.screensSettingsProfileSettingsHealthDataSync,
            ),
            _buildHealthSyncCard(l10n),
            const SizedBox(height: 24),

            // Current Stats Section (Read-only)
            if (_originalProfile != null) ...[
              _buildSectionHeader(l10n.screensMenuCurrentStats),
              _buildCurrentStatsCard(l10n),
              const SizedBox(height: 24),
            ],

            // Danger Zone Section
            _buildSectionHeader(l10n.screensSettingsProfileSettingsDangerZone),
            _buildDangerZoneCard(l10n),

            const SizedBox(height: 80), // Extra space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _nameController,
              label: l10n.screensSettingsImportProfileCompletionName,
              hint: l10n.screensSettingsProfileSettingsNameHint,
              icon: Icons.person,
              validator: (value) => _validateRequired(value, 'Name'),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _ageController,
              label: l10n.screensSettingsImportProfileCompletionAge,
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: _validateAge,
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              value: _selectedGender,
              label: l10n.screensSettingsImportProfileCompletionGender,
              icon: Icons.person_outline,
              items: [
                DropdownMenuItem(
                  value: 'male',
                  child: Text(l10n.screensSettingsImportProfileCompletionMale),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text(
                    l10n.screensSettingsImportProfileCompletionFemale,
                  ),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text(l10n.screensSettingsImportProfileCompletionOther),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                  _onFieldChanged();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalStatsCard(AppLocalizations l10n) {
    final isMetric = _selectedUnitSystem == 'metric';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _heightController,
              label:
                  '${l10n.screensSettingsImportProfileCompletionHeight} (${isMetric ? 'cm' : 'in'})',
              icon: Icons.height,
              keyboardType: TextInputType.number,
              validator: _validateHeight,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _weightController,
              label:
                  '${l10n.screensSettingsImportProfileCompletionWeight} (${isMetric ? 'kg' : 'lbs'})',
              icon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
              validator: _validateWeight,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _bodyFatController,
              label: '${l10n.screensSettingsStatisticsBodyFat} (%)',
              helper: l10n.screensSettingsProfileSettingsOptional,
              icon: Icons.fitness_center,
              keyboardType: TextInputType.number,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              validator: _validateBodyFat,
            ),
            const SizedBox(height: 16),
            _buildDropdown<String>(
              value: _selectedActivityLevel,
              label: l10n.screensSettingsImportProfileCompletionActivityLevel,
              icon: Icons.directions_run,
              items:
                  _activityLevels.keys.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(_getActivityLevelText(level, l10n)),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivityLevel = value!;
                  _onFieldChanged();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessGoalsCard(AppLocalizations l10n) {
    final isMetric = _selectedUnitSystem == 'metric';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdown<String>(
              value: _selectedFitnessGoal,
              label: l10n.screensSettingsImportProfileCompletionFitnessGoal,
              icon: Icons.flag,
              items:
                  _fitnessGoals.keys.map((goal) {
                    return DropdownMenuItem(
                      value: goal,
                      child: Text(_getFitnessGoalText(goal, l10n)),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFitnessGoal = value!;
                  _adjustTargetWeightForGoal(value);
                  _onFieldChanged();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _targetWeightController,
              label:
                  '${l10n.screensSettingsProfileSettingsTargetWeight} (${isMetric ? 'kg' : 'lbs'})',
              icon: Icons.track_changes,
              keyboardType: TextInputType.number,
              validator: _validateWeight,
            ),
            const SizedBox(height: 16),
            // Macro customization button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _navigateToMacroCustomization(),
                icon: const Icon(Icons.tune),
                label: Text(
                  l10n.screensSettingsProfileSettingsCustomizeMacroRatios,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdown<String>(
              value: _selectedUnitSystem,
              label: l10n.screensSettingsImportProfileCompletionUnitSystem,
              icon: Icons.straighten,
              items: [
                DropdownMenuItem(
                  value: 'metric',
                  child: Text(
                    l10n.screensSettingsImportProfileCompletionMetric,
                  ),
                ),
                DropdownMenuItem(
                  value: 'imperial',
                  child: Text(
                    l10n.screensSettingsImportProfileCompletionImperial,
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedUnitSystem = value!;
                  _convertUnitsForDisplay();
                  _onFieldChanged();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSyncCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _healthService.isConnected
                      ? Icons.health_and_safety
                      : Icons.health_and_safety_outlined,
                  color:
                      _healthService.isConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _healthService.isConnected
                            ? (l10n
                                .screensSettingsProfileSettingsHealthConnected)
                            : (l10n
                                .screensSettingsProfileSettingsHealthDisconnected),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              _healthService.isConnected
                                  ? Colors.green
                                  : Colors.grey[700],
                        ),
                      ),
                      if (_healthService.isConnected &&
                          _healthService.lastSyncDate != null)
                        Text(
                          AppLocalizations.of(
                            context,
                          ).screensSettingsProfileSettingsLastSynced(
                            _formatLastSyncDate(_healthService.lastSyncDate!),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                // Status dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _healthService.isConnected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.push('/settings/health');
                  // Refresh health status when returning
                  _initializeHealthService();
                },
                icon: const Icon(Icons.settings, size: 16),
                label: Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsProfileSettingsManageHealthConnect,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSyncDate(DateTime date) {
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

  Widget _buildCurrentStatsCard(AppLocalizations l10n) {
    if (_originalProfile == null) return const SizedBox.shrink();

    // Calculate current values for display
    final isMetric = _selectedUnitSystem == 'metric';
    final height =
        _metricMeasurement(
          _heightController,
          _displayedHeight,
          _preciseHeight,
          isMetric,
          2.54,
        ) ??
        _originalProfile!.height;
    final weight =
        _metricMeasurement(
          _weightController,
          _displayedWeight,
          _preciseWeight,
          isMetric,
          1 / 2.2046,
        ) ??
        _originalProfile!.weight;
    final age = int.tryParse(_ageController.text) ?? _originalProfile!.age;

    final bmi = weight / ((height / 100) * (height / 100));
    final bmr = mifflinStJeorBmr(
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _selectedGender,
    );
    final tdee = totalDailyEnergyExpenditure(bmr, _selectedActivityLevel);

    return Card(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildStatColumn(
                    l10n.screensSettingsProfileSettingsBmi,
                    bmi.toStringAsFixed(1),
                    _getBMICategory(bmi, l10n),
                  ),
                ),
                Expanded(
                  child: _buildStatColumn(
                    'BMR',
                    '${bmr.round()} cal',
                    l10n.screensSettingsProfileSettingsBaseMetabolicRate,
                  ),
                ),
                Expanded(
                  child: _buildStatColumn(
                    'TDEE',
                    '${tdee.round()} cal',
                    l10n.screensSettingsProfileSettingsTotalDailyEnergy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helper,
    required IconData icon,
    TextInputType? keyboardType,
    FloatingLabelBehavior? floatingLabelBehavior,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        prefixIcon: Icon(icon),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 48,
        ),
        floatingLabelBehavior: floatingLabelBehavior,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 48,
        ),
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      menuMaxHeight: 300,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildStatColumn(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getActivityLevelText(String level, AppLocalizations l10n) {
    switch (level) {
      case 'sedentary':
        return l10n.screensSettingsImportProfileCompletionSedentary;
      case 'lightly_active':
        return l10n.screensSettingsImportProfileCompletionLightlyActive;
      case 'moderately_active':
        return l10n.screensSettingsImportProfileCompletionModeratelyActive;
      case 'very_active':
        return l10n.screensSettingsImportProfileCompletionVeryActive;
      case 'extra_active':
        return l10n.screensSettingsImportProfileCompletionExtraActive;
      default:
        return level;
    }
  }

  String _getFitnessGoalText(String goal, AppLocalizations l10n) {
    switch (goal) {
      case 'lose_weight':
        return l10n.screensSettingsImportProfileCompletionLoseWeight;
      case 'maintain_weight':
        return l10n.screensSettingsImportProfileCompletionMaintainWeight;
      case 'gain_weight':
        return l10n.screensSettingsImportProfileCompletionGainWeight;
      case 'build_muscle':
        return l10n.screensSettingsImportProfileCompletionBuildMuscle;
      default:
        return goal;
    }
  }

  String _getBMICategory(double bmi, AppLocalizations l10n) {
    if (bmi < 18.5) return l10n.screensSettingsStatisticsBmiUnderweight;
    if (bmi < 25) return l10n.screensSettingsStatisticsBmiNormal;
    if (bmi < 30) return l10n.screensSettingsStatisticsBmiOverweight;
    return l10n.screensSettingsStatisticsBmiObese;
  }

  void _convertUnitsForDisplay() {
    if (_originalProfile == null) return;

    final wasMetric = _selectedUnitSystem == 'imperial';
    final height = _metricMeasurement(
      _heightController,
      _displayedHeight,
      _preciseHeight,
      wasMetric,
      2.54,
    );
    final weight = _metricMeasurement(
      _weightController,
      _displayedWeight,
      _preciseWeight,
      wasMetric,
      1 / 2.2046,
    );
    final targetWeight = _metricMeasurement(
      _targetWeightController,
      _displayedTargetWeight,
      _preciseTargetWeight,
      wasMetric,
      1 / 2.2046,
    );

    _isConvertingUnits = true;
    if (height != null) {
      _preciseHeight = height;
      _heightController.text = _formatMeasurement(
        wasMetric ? height / 2.54 : height,
      );
      _displayedHeight = _heightController.text;
    }
    if (weight != null) {
      _preciseWeight = weight;
      _weightController.text = _formatMeasurement(
        wasMetric ? weight * 2.2046 : weight,
      );
      _displayedWeight = _weightController.text;
    }
    if (targetWeight != null) {
      _preciseTargetWeight = targetWeight;
      _targetWeightController.text = _formatMeasurement(
        wasMetric ? targetWeight * 2.2046 : targetWeight,
      );
      _displayedTargetWeight = _targetWeightController.text;
    }
    _isConvertingUnits = false;
  }

  Widget _buildDangerZoneCard(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.screensSettingsProfileSettingsDangerZone,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showResetConfirmationDialog(l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.delete_forever),
                label: Text(
                  l10n.screensSettingsProfileSettingsResetApp,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResetConfirmationDialog(AppLocalizations l10n) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.screensSettingsProfileSettingsResetAppTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                l10n.screensSettingsProfileSettingsResetAppDescription,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l10n.screensSettingsProfileSettingsResetAppCancel,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: Text(
                  l10n.screensSettingsProfileSettingsResetAppConfirm,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _performAppReset(l10n);
    }
  }

  Future<void> _performAppReset(AppLocalizations l10n) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(l10n.screensSettingsProfileSettingsResettingAppData),
                ],
              ),
            ),
      );

      // Reset all application data
      await context.storageServiceProvider.resetAllData();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.screensSettingsProfileSettingsResetAppSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        debugPrint('ProfileSettingsScreen: Reset failed (${e.runtimeType})');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.screensSettingsProfileSettingsResetAppError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
