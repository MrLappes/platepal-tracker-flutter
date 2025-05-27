import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../utils/service_extensions.dart';

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
    _weightController.addListener(_onFieldChanged);
    _targetWeightController.addListener(_onFieldChanged);
    _bodyFatController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);

      // Load from SQLite database
      final userProfile = await context.userProfileService.getUserProfile('1');

      if (userProfile != null) {
        _originalProfile = userProfile;

        // Load metrics history to get the latest body fat percentage
        _metricsHistory = await context.userProfileService
            .getUserMetricsHistory(
              userProfile.id,
              startDate: DateTime.now().subtract(
                const Duration(days: 30),
              ), // Last 30 days
            );
      } else {
        // Create a default profile if none exists
        final migratedProfile = await context.userProfileService.getUserProfile(
          '1',
        );
        if (migratedProfile != null) {
          _originalProfile = migratedProfile;
        } else {
          // Create a default profile if none exists
          _originalProfile = UserProfile(
            id: '1',
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
            ),
            preferences: const DietaryPreferences(),
            preferredUnit: 'metric',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
            updatedAt: DateTime.now(),
          );

          // Save the default profile to the database
          await context.userProfileService.saveUserProfile(_originalProfile!);
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
      _targetWeightController.text =
          profile.goals.targetWeight.round().toString();
    } else {
      _heightController.text = (profile.height / 2.54).round().toString();
      _weightController.text = (profile.weight * 2.2046).round().toString();
      _targetWeightController.text =
          (profile.goals.targetWeight * 2.2046).round().toString();
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
      );

      // Use a constant email instead of getting from form
      const defaultEmail = "user@platepal.app";

      final updatedProfile = UserProfile(
        id: _originalProfile?.id ?? '1',
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
        ),
        preferences:
            _originalProfile?.preferences ?? const DietaryPreferences(),
        preferredUnit: _selectedUnitSystem,
        createdAt: _originalProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

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

      if (weightChanged || heightChanged || bodyFat != null) {
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
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations?.profileUpdated ?? 'Profile updated successfully',
            ),
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
    final localizations = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations?.unsavedChanges ?? 'Unsaved Changes'),
            content: Text(
              localizations?.unsavedChangesMessage ??
                  'You have unsaved changes. Do you want to save them before leaving?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(localizations?.discardChanges ?? 'Discard Changes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  _saveProfile();
                },
                child: Text(localizations?.saveChanges ?? 'Save Changes'),
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
    double protein, carbs, fat;

    switch (goal) {
      case 'lose_weight':
        protein = weight * 2.2; // Higher protein for fat loss
        fat = calories * 0.25 / 9;
        carbs = (calories - (protein * 4) - (fat * 9)) / 4;
        break;
      case 'build_muscle':
        protein = weight * 2.0; // High protein for muscle building
        fat = calories * 0.25 / 9;
        carbs = (calories - (protein * 4) - (fat * 9)) / 4;
        break;
      default:
        protein = weight * 1.6; // Moderate protein
        fat = calories * 0.25 / 9;
        carbs = (calories - (protein * 4) - (fat * 9)) / 4;
    }

    return {'protein': protein, 'carbs': carbs, 'fat': fat};
  }

  String? _validateRequired(String? value, String fieldName) {
    final localizations = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return localizations?.requiredField ?? 'This field is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final localizations = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return localizations?.requiredField ?? 'This field is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return localizations?.invalidEmail ??
          'Please enter a valid email address';
    }
    return null;
  }

  String? _validateAge(String? value) {
    final localizations = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return localizations?.requiredField ?? 'This field is required';
    }
    final age = int.tryParse(value.trim());
    if (age == null || age < 13 || age > 120) {
      return localizations?.ageRange ?? 'Age must be between 13 and 120';
    }
    return null;
  }

  String? _validateHeight(String? value) {
    final localizations = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return localizations?.requiredField ?? 'This field is required';
    }
    final height = double.tryParse(value.trim());
    if (height == null) {
      return localizations?.requiredField ?? 'This field is required';
    }

    if (_selectedUnitSystem == 'metric') {
      if (height < 100 || height > 250) {
        return localizations?.heightRange ??
            'Height must be between 100-250 cm';
      }
    } else {
      if (height < 39 || height > 98) {
        return 'Height must be between 39-98 inches';
      }
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final localizations = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return localizations?.requiredField ?? 'This field is required';
    }
    final weight = double.tryParse(value.trim());
    if (weight == null) {
      return localizations?.requiredField ?? 'This field is required';
    }

    if (_selectedUnitSystem == 'metric') {
      if (weight < 30 || weight > 300) {
        return localizations?.weightRange ?? 'Weight must be between 30-300 kg';
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
    final localizations = AppLocalizations.of(context);
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasUnsavedChanges) {
          await _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations?.profileSettings ?? 'Profile Settings'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _isSaving ? null : _saveProfile,
                tooltip: localizations?.save ?? 'Save',
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
                      Text(localizations?.loading ?? 'Loading...'),
                    ],
                  ),
                )
                : _buildProfileForm(context, localizations),
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
                            localizations?.discardChanges ?? 'Discard Changes',
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
                                    localizations?.saveChanges ??
                                        'Save Changes',
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

  Widget _buildProfileForm(
    BuildContext context,
    AppLocalizations? localizations,
  ) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Personal Information Section
            _buildSectionHeader(
              localizations?.personalInformation ?? 'Personal Information',
            ),
            _buildPersonalInfoCard(localizations),
            const SizedBox(height: 24),

            // Physical Stats Section
            _buildSectionHeader('Physical Stats'),
            _buildPhysicalStatsCard(localizations),
            const SizedBox(height: 24),

            // Fitness Goals Section
            _buildSectionHeader(localizations?.fitnessGoals ?? 'Fitness Goals'),
            _buildFitnessGoalsCard(localizations),
            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader(localizations?.preferences ?? 'Preferences'),
            _buildPreferencesCard(localizations),
            const SizedBox(height: 24), // Current Stats Section (Read-only)
            if (_originalProfile != null) ...[
              _buildSectionHeader(
                localizations?.currentStats ?? 'Current Stats',
              ),
              _buildCurrentStatsCard(localizations),
              const SizedBox(height: 24),
            ],

            // Danger Zone Section
            _buildSectionHeader(localizations?.dangerZone ?? 'Danger Zone'),
            _buildDangerZoneCard(localizations),

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

  Widget _buildPersonalInfoCard(AppLocalizations? localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _nameController,
              label: localizations?.name ?? 'Name',
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
                    label: localizations?.age ?? 'Age',
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
                    label: localizations?.gender ?? 'Gender',
                    icon: Icons.person_outline,
                    items: [
                      DropdownMenuItem(
                        value: 'male',
                        child: Text(localizations?.male ?? 'Male'),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text(localizations?.female ?? 'Female'),
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

  Widget _buildPhysicalStatsCard(AppLocalizations? localizations) {
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
                    label:
                        '${localizations?.height ?? 'Height'} (${isMetric ? 'cm' : 'in'})',
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                    validator: _validateHeight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _weightController,
                    label:
                        '${localizations?.weight ?? 'Weight'} (${isMetric ? 'kg' : 'lbs'})',
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
                    label: localizations?.activityLevel ?? 'Activity Level',
                    icon: Icons.directions_run,
                    items:
                        _activityLevels.keys.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(
                              _getActivityLevelText(level, localizations),
                            ),
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

  Widget _buildFitnessGoalsCard(AppLocalizations? localizations) {
    final isMetric = _selectedUnitSystem == 'metric';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdown<String>(
              value: _selectedFitnessGoal,
              label: localizations?.fitnessGoal ?? 'Fitness Goal',
              icon: Icons.flag,
              items:
                  _fitnessGoals.keys.map((goal) {
                    return DropdownMenuItem(
                      value: goal,
                      child: Text(_getFitnessGoalText(goal, localizations)),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFitnessGoal = value!;
                  _onFieldChanged();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _targetWeightController,
              label:
                  '${localizations?.targetWeight ?? 'Target Weight'} (${isMetric ? 'kg' : 'lbs'})',
              icon: Icons.track_changes,
              keyboardType: TextInputType.number,
              validator: _validateWeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(AppLocalizations? localizations) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdown<String>(
              value: _selectedUnitSystem,
              label: localizations?.unitSystem ?? 'Unit System',
              icon: Icons.straighten,
              items: [
                DropdownMenuItem(
                  value: 'metric',
                  child: Text(localizations?.metric ?? 'Metric (kg, cm)'),
                ),
                DropdownMenuItem(
                  value: 'imperial',
                  child: Text(localizations?.imperial ?? 'Imperial (lb, ft)'),
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

  Widget _buildCurrentStatsCard(AppLocalizations? localizations) {
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
                  localizations?.bmi ?? 'BMI',
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

  String _getActivityLevelText(String level, AppLocalizations? localizations) {
    switch (level) {
      case 'sedentary':
        return localizations?.sedentary ?? 'Sedentary';
      case 'lightly_active':
        return localizations?.lightlyActive ?? 'Lightly Active';
      case 'moderately_active':
        return localizations?.moderatelyActive ?? 'Moderately Active';
      case 'very_active':
        return localizations?.veryActive ?? 'Very Active';
      case 'extra_active':
        return localizations?.extraActive ?? 'Extra Active';
      default:
        return level;
    }
  }

  String _getFitnessGoalText(String goal, AppLocalizations? localizations) {
    switch (goal) {
      case 'lose_weight':
        return localizations?.loseWeight ?? 'Lose Weight';
      case 'maintain_weight':
        return localizations?.maintainWeight ?? 'Maintain Weight';
      case 'gain_weight':
        return localizations?.gainWeight ?? 'Gain Weight';
      case 'build_muscle':
        return localizations?.buildMuscle ?? 'Build Muscle';
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

  Widget _buildDangerZoneCard(AppLocalizations? localizations) {
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
                    localizations?.dangerZone ?? 'Danger Zone',
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
                onPressed: () => _showResetConfirmationDialog(localizations),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.delete_forever),
                label: Text(
                  localizations?.resetApp ?? 'Reset App',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResetConfirmationDialog(
    AppLocalizations? localizations,
  ) async {
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
                    localizations?.resetAppTitle ?? 'Reset Application Data',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(
                localizations?.resetAppDescription ??
                    'This will permanently delete ALL your data including:\n\n• Your profile information\n• All meal logs and nutrition data\n• All preferences and settings\n• All stored information\n\nThis action cannot be undone. Are you sure you want to continue?',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  localizations?.resetAppCancel ?? 'Cancel',
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
                  localizations?.resetAppConfirm ?? 'Yes, Delete Everything',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _performAppReset(localizations);
    }
  }

  Future<void> _performAppReset(AppLocalizations? localizations) async {
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
            content: Text(
              localizations?.resetAppSuccess ??
                  'Application data has been reset successfully',
            ),
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
            content: Text(
              '${localizations?.resetAppError ?? 'Failed to reset application data'}: $e',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
