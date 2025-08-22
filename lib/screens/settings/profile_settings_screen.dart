import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../models/user_profile.dart';
import '../../utils/service_extensions.dart';
import '../../services/health_service.dart';
import '../../services/calorie_expenditure_service.dart';
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

  // Health service integration
  final HealthService _healthService = HealthService();
  bool _isHealthAvailable = false;
  bool _isHealthSyncing = false;
  StreamSubscription<bool>? _healthConnectionSubscription;

  // Add the calorie expenditure service
  final CalorieExpenditureService _calorieExpenditureService =
      CalorieExpenditureService();

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
    _healthConnectionSubscription?.cancel();
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
    _updateGoalBasedOnWeights();
  }

  void _onTargetWeightChanged() {
    _onFieldChanged();
    _updateGoalBasedOnWeights();
  }

  void _updateGoalBasedOnWeights() {
    final currentWeight = double.tryParse(_weightController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);

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
    final currentWeight = double.tryParse(_weightController.text);
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
        final currentTarget = double.tryParse(_targetWeightController.text);
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
        final currentTarget = double.tryParse(_targetWeightController.text);
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

    _targetWeightController.text = newTargetWeight.round().toString();
  }

  // Health service initialization
  Future<void> _initializeHealthService() async {
    await _healthService.loadConnectionStatus();
    final available = await _healthService.isHealthDataAvailable();
    setState(() {
      _isHealthAvailable = available;
    });

    // Subscribe to health connection status changes
    _healthConnectionSubscription = _healthService.connectionStatusStream
        .listen((isConnected) {
          setState(() {
            // Update health availability when connection status changes
          });
        });
  } // Connect to health data

  Future<void> _connectToHealth() async {
    setState(() => _isHealthSyncing = true);

    try {
      // Show info about permission request
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Requesting health permissions...'),
          duration: Duration(seconds: 2),
        ),
      );

      final result = await _healthService.connectToHealthWithDetails();

      if (result.success) {
        await _syncHealthData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.screensSettingsProfileSettingsHealthConnected),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          // Show appropriate dialog based on error type
          switch (result.error) {
            case HealthConnectionError.permissionDenied:
              await _showHealthPermissionDeniedDialog();
              break;
            case HealthConnectionError.platformNotSupported:
              await _showHealthErrorDialog(result.message);
              break;
            case HealthConnectionError.unknown:
            default:
              await _showHealthErrorDialog(result.message);
              break;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        await _showHealthErrorDialog(e.toString());
      }
    } finally {
      setState(() => _isHealthSyncing = false);
    }
  }

  // Sync health data
  Future<void> _syncHealthData() async {
    if (!_healthService.isConnected) return;

    setState(() => _isHealthSyncing = true);

    try {
      final healthData = await _healthService.syncHealthData();
      if (healthData != null && mounted) {
        // Update form fields with health data if available
        if (healthData.containsKey('weight')) {
          final weight = healthData['weight']['value'] as num;
          if (_selectedUnitSystem == 'metric') {
            _weightController.text = weight.round().toString();
          } else {
            _weightController.text = (weight * 2.2046).round().toString();
          }
        }

        if (healthData.containsKey('height')) {
          final height = healthData['height']['value'] as num;
          if (_selectedUnitSystem == 'metric') {
            _heightController.text = height.round().toString();
          } else {
            _heightController.text = (height / 2.54).round().toString();
          }
        }

        if (healthData.containsKey('bodyFat')) {
          final bodyFat = healthData['bodyFat']['value'] as num;
          _bodyFatController.text = bodyFat.toStringAsFixed(1);
        }

        _onFieldChanged();

        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.screensSettingsProfileSettingsHealthSyncSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.screensSettingsProfileSettingsHealthSyncFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isHealthSyncing = false);
    }
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
            name: 'John Doe',
            email: 'john.doe@example.com',
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

      _populateFields(_originalProfile!);
    } catch (e) {
      _showErrorSnackBar('Failed to load profile data: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFields(UserProfile profile) {
    _nameController.text = profile.name;
    _ageController.text = profile.age.toString();

    // Convert height/weight based on unit system
    if (profile.preferredUnit == 'metric') {
      _heightController.text = profile.height.round().toString();
      _weightController.text = profile.weight.round().toString();
      // For maintain_weight goal, set target weight to current weight
      if (profile.goals.goal == 'maintain_weight') {
        _targetWeightController.text = profile.weight.round().toString();
      } else {
        _targetWeightController.text =
            profile.goals.targetWeight.round().toString();
      }
    } else {
      _heightController.text = (profile.height / 2.54).round().toString();
      _weightController.text = (profile.weight * 2.2046).round().toString();
      // For maintain_weight goal, set target weight to current weight
      if (profile.goals.goal == 'maintain_weight') {
        _targetWeightController.text =
            (profile.weight * 2.2046).round().toString();
      } else {
        _targetWeightController.text =
            (profile.goals.targetWeight * 2.2046).round().toString();
      }
    }

    // Body fat percentage (optional field) - Try to get the last recorded body fat percentage
    if (_metricsHistory.isNotEmpty &&
        _metricsHistory.last['body_fat'] != null) {
      _bodyFatController.text = _metricsHistory.last['body_fat'].toString();
    } else {
      _bodyFatController.text = '';
    }

    setState(() {
      _selectedGender = profile.gender;
      _selectedActivityLevel = profile.activityLevel;
      _selectedFitnessGoal = profile.goals.goal;
      _selectedUnitSystem = profile.preferredUnit;
      _hasUnsavedChanges = false;
    });
  }

  // Add field to store metrics history
  List<Map<String, dynamic>> _metricsHistory = [];

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Convert units back to metric for storage
      double height = double.parse(_heightController.text);
      double weight = double.parse(_weightController.text);
      double targetWeight = double.parse(_targetWeightController.text);

      // Store previous weight and height for history tracking
      final double? previousWeight = _originalProfile?.weight;
      final double? previousHeight = _originalProfile?.height;

      if (_selectedUnitSystem == 'imperial') {
        height = height * 2.54; // inches to cm
        weight = weight / 2.2046; // lbs to kg
        targetWeight = targetWeight / 2.2046;
      }

      // Calculate nutrition targets
      final age = int.parse(_ageController.text);
      final bmr = _calculateBMR(weight, height, age, _selectedGender);
      final tdee = _calculateTDEE(bmr, _selectedActivityLevel);
      final dailyCalories = _calculateCaloriesForGoal(
        tdee,
        _selectedFitnessGoal,
      );
      final macros = _calculateMacroTargets(
        dailyCalories,
        weight,
        _selectedFitnessGoal,
      ); // Use a constant email instead of getting from form
      const defaultEmail = "user@platepal.app";

      // Get current user ID from session service
      final prefs = await SharedPreferences.getInstance();
      final userSessionService = UserSessionService(prefs);
      final currentUserId = userSessionService.getCurrentUserId();

      final updatedProfile = UserProfile(
        id: _originalProfile?.id ?? currentUserId,
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
          targetProtein: macros['protein']!,
          targetCarbs: macros['carbs']!,
          targetFat: macros['fat']!,
          targetFiber: macros['fiber']!,
        ),
        preferences:
            _originalProfile?.preferences ?? const DietaryPreferences(),
        preferredUnit: _selectedUnitSystem,
        createdAt: _originalProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (!mounted) return;
      // Save profile to SQLite database
      await context.userProfileService.saveUserProfile(updatedProfile);

      // Always update metrics if body fat was entered, otherwise only update if weight or height changed
      final bodyFat =
          _bodyFatController.text.isNotEmpty
              ? double.tryParse(_bodyFatController.text)
              : null;

      final bool weightChanged =
          previousWeight != null && (weight - previousWeight).abs() > 0.1;
      final bool heightChanged =
          previousHeight != null && (height - previousHeight).abs() > 0.1;

      if ((weightChanged || heightChanged || bodyFat != null) && mounted) {
        await context.userProfileService.updateUserMetrics(
          userId: updatedProfile.id,
          weight: weight,
          height: height,
          bodyFat: bodyFat,
        );
      }

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
      _showErrorSnackBar('Failed to update profile: ${e.toString()}');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _showUnsavedChangesDialog() async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.screensSettingsMacroCustomizationUnsavedChanges),
            content: Text(l10n.screensSettingsMacroCustomizationUnsavedChangesMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.screensSettingsMacroCustomizationDiscardChanges),
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
    return result ?? false;
  }

  // Calculation methods (simplified versions)
  double _calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

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

  double _calculateCaloriesForGoal(double tdee, String goal) {
    switch (goal) {
      case 'lose_weight':
        return tdee - 500; // 500 calorie deficit
      case 'gain_weight':
        return tdee + 300; // 300 calorie surplus
      case 'build_muscle':
        return tdee + 200; // 200 calorie surplus
      default:
        return tdee; // maintain weight
    }
  }

  Map<String, double> _calculateMacroTargets(
    double calories,
    double weight,
    String goal,
  ) {
    // High protein diet: 40% protein, 30% carbs, 30% fat
    // This helps preserve muscle mass during weight loss and supports muscle building

    double protein =
        (calories * 0.40) / 4; // 40% of calories from protein (4 cal/g)
    double carbs =
        (calories * 0.30) / 4; // 30% of calories from carbs (4 cal/g)
    double fat = (calories * 0.30) / 9; // 30% of calories from fat (9 cal/g)

    // Calculate fiber target based on calories (14g per 1000 calories)
    double fiber = (calories / 1000) * 14;

    return {'protein': protein, 'carbs': carbs, 'fat': fat, 'fiber': fiber};
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
    final height = double.tryParse(value.trim());
    if (height == null) {
      return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
    }

    if (_selectedUnitSystem == 'metric') {
      if (height < 100 || height > 250) {
        return l10n.screensSettingsImportProfileCompletionHeightRange;
      }
    } else {
      if (height < 39 || height > 98) {
        return 'Height must be between 39-98 inches';
      }
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
    }
    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
    }

    if (_selectedUnitSystem == 'metric') {
      if (weight < 30 || weight > 300) {
        return l10n.screensSettingsImportProfileCompletionWeightRange;
      }
    } else {
      if (weight < 66 || weight > 660) {
        return 'Weight must be between 66-660 lbs';
      }
    }
    return null;
  }

  String? _validateBodyFat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final bodyFat = double.tryParse(value.trim());
    if (bodyFat == null) {
      return 'Please enter a valid number';
    }
    if (bodyFat < 3 || bodyFat > 50) {
      return 'Body fat must be between 3-50%';
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
          title: Text(l10n.screensSettingsProfileSettingsProfileSettings),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
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
                          child: Text(l10n.screensSettingsMacroCustomizationDiscardChanges),
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
                                  : Text(l10n.screensSettingsMacroCustomizationSaveChanges),
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
            _buildSectionHeader(l10n.screensSettingsImportProfileCompletionPersonalInformation),
            _buildPersonalInfoCard(l10n),
            const SizedBox(height: 24),

            // Physical Stats Section
            _buildSectionHeader('Physical Stats'),
            _buildPhysicalStatsCard(l10n),
            const SizedBox(height: 24),

            // Fitness Goals Section
            _buildSectionHeader(l10n.screensSettingsProfileSettingsFitnessGoals),
            _buildFitnessGoalsCard(l10n),
            const SizedBox(height: 24), // Preferences Section
            _buildSectionHeader(l10n.screensSettingsImportProfileCompletionPreferences),
            _buildPreferencesCard(l10n),
            const SizedBox(
              height: 24,
            ), // Health Data Sync Section (only show when health is available AND connected)
            if (_isHealthAvailable && _healthService.isConnected) ...[
              _buildSectionHeader(l10n.screensSettingsProfileSettingsHealthDataSync),
              _buildHealthSyncCard(l10n),
              const SizedBox(height: 24),
            ] else if (_isHealthAvailable) ...[
              // Show connection option when available but not connected
              _buildSectionHeader(l10n.screensSettingsProfileSettingsHealthDataSync),
              _buildHealthSyncCard(l10n),
              const SizedBox(height: 24),
            ],

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
              icon: Icons.person,
              validator: (value) => _validateRequired(value, 'Name'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _ageController,
                    label: l10n.screensSettingsImportProfileCompletionAge,
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    validator: _validateAge,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _buildDropdown<String>(
                    value: _selectedGender,
                    label: l10n.screensSettingsImportProfileCompletionGender,
                    icon: Icons.person_outline,
                    items: [
                      DropdownMenuItem(value: 'male', child: Text(l10n.screensSettingsImportProfileCompletionMale)),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text(l10n.screensSettingsImportProfileCompletionFemale),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                        _onFieldChanged();
                      });
                    },
                  ),
                ),
              ],
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
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _heightController,
                    label: '${l10n.screensSettingsImportProfileCompletionHeight} (${isMetric ? 'cm' : 'in'})',
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                    validator: _validateHeight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _weightController,
                    label: '${l10n.screensSettingsImportProfileCompletionWeight} (${isMetric ? 'kg' : 'lbs'})',
                    icon: Icons.monitor_weight,
                    keyboardType: TextInputType.number,
                    validator: _validateWeight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _bodyFatController,
                    label: 'Body Fat % (optional)',
                    icon: Icons.fitness_center,
                    keyboardType: TextInputType.number,
                    validator: _validateBodyFat,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown<String>(
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
                ),
              ],
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
              label: '${l10n.screensSettingsProfileSettingsTargetWeight} (${isMetric ? 'kg' : 'lbs'})',
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
                label: Text('Customize Macro Ratios'),
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
                DropdownMenuItem(value: 'metric', child: Text(l10n.screensSettingsImportProfileCompletionMetric)),
                DropdownMenuItem(value: 'imperial', child: Text(l10n.screensSettingsImportProfileCompletionImperial)),
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
                            ? (l10n.screensSettingsProfileSettingsHealthConnected)
                            : (l10n.screensSettingsProfileSettingsHealthDisconnected),
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
                          'Last synced: ${_formatLastSyncDate(_healthService.lastSyncDate!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_healthService.isConnected) ...[
              // Connect to Health button for disconnected state
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isHealthSyncing ? null : _connectToHealth,
                  icon:
                      _isHealthSyncing
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.add_link),
                  label: Text(l10n.screensSettingsProfileSettingsConnectToHealth),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ] else ...[
              // Full-width buttons for connected state
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isHealthSyncing ? null : _syncHealthData,
                  icon:
                      _isHealthSyncing
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.sync),
                  label: Text(l10n.screensSettingsProfileSettingsSyncHealthData),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isHealthSyncing ? null : _analyzeCalorieTargets,
                  icon: const Icon(Icons.analytics),
                  label: Text(l10n.screensSettingsProfileSettingsAnalyzeTargets),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Icon buttons in horizontal row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isHealthSyncing ? null : _debugHealthData,
                      icon: const Icon(Icons.bug_report),
                      label: Text(l10n.screensSettingsProfileSettingsDebugHealthData),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isHealthSyncing
                              ? null
                              : () async {
                                await _healthService.disconnectFromHealth();
                                setState(() {});
                              },
                      icon: const Icon(Icons.link_off),
                      label: Text(l10n.screensSettingsProfileSettingsDisconnectHealth),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (!_healthService.isConnected) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Connect to Health Data',
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sync your weight, height, and daily burned calories from your device\'s health app. When you tap "Connect to Health", you\'ll be asked to grant permissions.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLastSyncDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildCurrentStatsCard(AppLocalizations l10n) {
    if (_originalProfile == null) return const SizedBox.shrink();

    // Calculate current values for display
    final height =
        double.tryParse(_heightController.text) ?? _originalProfile!.height;
    final weight =
        double.tryParse(_weightController.text) ?? _originalProfile!.weight;
    final age = int.tryParse(_ageController.text) ?? _originalProfile!.age;

    // Convert for calculations if needed
    final actualHeight =
        _selectedUnitSystem == 'metric' ? height : height * 2.54;
    final actualWeight =
        _selectedUnitSystem == 'metric' ? weight : weight / 2.2046;
    final bmi = actualWeight / ((actualHeight / 100) * (actualHeight / 100));
    final bmr = _calculateBMR(actualWeight, actualHeight, age, _selectedGender);
    final tdee = _calculateTDEE(bmr, _selectedActivityLevel);

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
                _buildStatColumn(
                  l10n.screensSettingsProfileSettingsBmi,
                  bmi.toStringAsFixed(1),
                  _getBMICategory(bmi),
                ),
                _buildStatColumn(
                  'BMR',
                  '${bmr.round()} cal',
                  'Base Metabolic Rate',
                ),
                _buildStatColumn(
                  'TDEE',
                  '${tdee.round()} cal',
                  'Total Daily Energy',
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
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _convertUnitsForDisplay() {
    try {
      if (_originalProfile == null) return;

      // Convert height and weight based on new unit system
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);
      final targetWeight = double.tryParse(_targetWeightController.text);

      if (_selectedUnitSystem == 'imperial') {
        // Convert from metric to imperial
        if (height != null) {
          _heightController.text = (height / 2.54).round().toString();
        }
        if (weight != null) {
          _weightController.text = (weight * 2.2046).round().toString();
        }
        if (targetWeight != null) {
          _targetWeightController.text =
              (targetWeight * 2.2046).round().toString();
        }
      } else {
        // Convert from imperial to metric
        if (height != null) {
          _heightController.text = (height * 2.54).round().toString();
        }
        if (weight != null) {
          _weightController.text = (weight / 2.2046).round().toString();
        }
        if (targetWeight != null) {
          _targetWeightController.text =
              (targetWeight / 2.2046).round().toString();
        }
      }
    } catch (e) {
      // Handle conversion errors gracefully
    }
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
            (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Resetting application data...'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.screensSettingsProfileSettingsResetAppError}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Show health permission denied dialog
  Future<void> _showHealthPermissionDeniedDialog() async {
    final l10n = AppLocalizations.of(context);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.screensSettingsProfileSettingsHealthPermissionDenied),
          content: Text(l10n.screensSettingsProfileSettingsHealthPermissionDeniedMessage),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.componentsChatBotProfileCustomizationDialogCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(l10n.componentsScannerBarcodeScannerOpenSettings),
              onPressed: () async {
                Navigator.of(context).pop();
                await _openHealthSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // Show health error dialog
  Future<void> _showHealthErrorDialog(String error) async {
    final l10n = AppLocalizations.of(context);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.screensSettingsProfileSettingsHealthNotAvailable),
          content: Text(l10n.screensSettingsProfileSettingsHealthNotAvailableMessage),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.componentsChatBotProfileCustomizationDialogCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(l10n.componentsScannerBarcodeScannerOpenSettings),
              onPressed: () async {
                Navigator.of(context).pop();
                await _openHealthSettings();
              },
            ),
          ],
        );
      },
    );
  }

  // Open device health settings
  Future<void> _openHealthSettings() async {
    try {
      // For Android, try Health Connect first
      bool launched = await launchUrl(
        Uri.parse('android-app://com.google.android.apps.healthdata/'),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback to general app settings
        launched = await launchUrl(
          Uri.parse('app-settings:'),
          mode: LaunchMode.externalApplication,
        );
      }

      if (!launched) {
        // Final fallback to device settings
        launched = await launchUrl(
          Uri.parse('android.settings.APPLICATION_SETTINGS'),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // Show error if unable to open settings
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to open settings. Please go to your device settings manually.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Analyze calorie targets and show recommendations
  Future<void> _analyzeCalorieTargets() async {
    setState(() => _isHealthSyncing = true);

    try {
      final analysis = await _calorieExpenditureService.syncAndAnalyze();

      if (mounted) {
        await _showCalorieAnalysisDialog(analysis);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing calorie targets: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isHealthSyncing = false);
    }
  }

  // Show calorie analysis dialog
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
                Text('Calorie Target Analysis'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    analysis.analysisMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Analysis details
                  if (analysis.daysAnalyzed > 0) ...[
                    _buildAnalysisRow(
                      'Days Analyzed',
                      '${analysis.daysAnalyzed}',
                    ),
                    _buildAnalysisRow(
                      'Current Target',
                      '${analysis.currentTarget.toStringAsFixed(0)} cal',
                    ),
                    _buildAnalysisRow(
                      'Average Expenditure',
                      '${analysis.averageExpenditure.toStringAsFixed(0)} cal',
                    ),

                    if (analysis.needsAdjustment) ...[
                      const SizedBox(height: 8),
                      _buildAnalysisRow(
                        'Suggested Target',
                        '${analysis.suggestedTarget.toStringAsFixed(0)} cal',
                        isHighlighted: true,
                      ),
                    ],
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.componentsChatBotProfileCustomizationDialogCancel),
              ),
              if (analysis.needsAdjustment)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _applyCalorieTargetAdjustment(
                      analysis.suggestedTarget,
                    );
                  },
                  child: Text('Apply Suggestion'),
                ),
            ],
          ),
    );
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
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isHighlighted ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  // Apply calorie target adjustment
  Future<void> _applyCalorieTargetAdjustment(double newTarget) async {
    setState(() => _isSaving = true);

    try {
      final success = await _calorieExpenditureService.updateCalorieTargets(
        newTarget,
      );

      if (success && mounted) {
        // Reload the profile to reflect changes
        await _loadProfile();

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calorie targets updated successfully!'),
            // ignore: use_build_context_synchronously
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update calorie targets'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating calorie targets: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Debug health data (temporary method for testing)
  Future<void> _debugHealthData() async {
    if (!_healthService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health service not connected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isHealthSyncing = true);

    try {
      final debugInfo = await _healthService.debugAvailableHealthData();

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Health Data Debug Info'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Available Data Types:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...debugInfo['available_types'].entries.map(
                        (e) => Text('${e.key}: ${e.value}'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Permissions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...debugInfo['permissions'].entries.map(
                        (e) => Text('${e.key}: ${e.value}'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Recent Data:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...debugInfo['recent_data'].entries.map(
                        (e) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key}:'),
                            Text('  ${e.value}'),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isHealthSyncing = false);
    }
  }
}
