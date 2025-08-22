import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

class ImportProfileCompletionScreen extends StatefulWidget {
  final Map<String, dynamic> incompleteProfile;
  final VoidCallback onCompleted;
  final VoidCallback onSkipped;

  const ImportProfileCompletionScreen({
    super.key,
    required this.incompleteProfile,
    required this.onCompleted,
    required this.onSkipped,
  });

  @override
  State<ImportProfileCompletionScreen> createState() =>
      _ImportProfileCompletionScreenState();
}

class _ImportProfileCompletionScreenState
    extends State<ImportProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String _selectedGender = 'other';
  String _selectedActivityLevel = 'sedentary';
  String _selectedFitnessGoal = 'maintainWeight';
  String _selectedUnitSystem = 'metric';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profile = widget.incompleteProfile;

    _nameController = TextEditingController(text: profile['name'] ?? '');
    _emailController = TextEditingController(text: profile['email'] ?? '');
    _ageController = TextEditingController(
      text: profile['age']?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: profile['height']?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: profile['weight']?.toString() ?? '',
    );

    _selectedGender = profile['gender'] ?? 'other';
    _selectedActivityLevel = profile['activityLevel'] ?? 'sedentary';
    _selectedFitnessGoal = profile['fitnessGoal'] ?? 'maintainWeight';
    _selectedUnitSystem = profile['unitSystem'] ?? 'metric';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile'),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Complete Your Profile',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We found some missing information in your imported profile. Please fill in the required fields to continue.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information
            Text(l10n.screensSettingsImportProfileCompletionPersonalInformation, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.screensSettingsImportProfileCompletionName,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: l10n.screensSettingsImportProfileCompletionEmail,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
                        }
                        if (!value.contains('@')) {
                          return l10n.screensSettingsImportProfileCompletionInvalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: InputDecoration(
                              labelText: l10n.screensSettingsImportProfileCompletionAge,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.cake),
                              suffixText: l10n.screensSettingsImportProfileCompletionYears,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
                              }
                              final age = int.tryParse(value);
                              if (age == null || age < 13 || age > 120) {
                                return l10n.screensSettingsImportProfileCompletionAgeRange;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: InputDecoration(
                              labelText: l10n.screensSettingsImportProfileCompletionGender,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.wc),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text(l10n.screensSettingsImportProfileCompletionMale),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text(l10n.screensSettingsImportProfileCompletionFemale),
                              ),
                              DropdownMenuItem(
                                value: 'other',
                                child: Text(l10n.screensSettingsImportProfileCompletionOther),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: InputDecoration(
                              labelText: l10n.screensSettingsImportProfileCompletionHeight,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.height),
                              suffixText:
                                  _selectedUnitSystem == 'metric'
                                      ? l10n.screensSettingsImportProfileCompletionCm
                                      : l10n.screensSettingsImportProfileCompletionInches,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
                              }
                              final height = double.tryParse(value);
                              if (height == null) {
                                return 'Invalid number';
                              }
                              if (_selectedUnitSystem == 'metric') {
                                if (height < 100 || height > 250) {
                                  return l10n.screensSettingsImportProfileCompletionHeightRange;
                                }
                              } else {
                                if (height < 36 || height > 96) {
                                  return 'Height must be between 36-96 inches';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: l10n.screensSettingsImportProfileCompletionWeight,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.monitor_weight),
                              suffixText:
                                  _selectedUnitSystem == 'metric'
                                      ? l10n.screensSettingsImportProfileCompletionKg
                                      : l10n.screensSettingsImportProfileCompletionLb,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.componentsChatBotProfileCustomizationDialogRequiredField;
                              }
                              final weight = double.tryParse(value);
                              if (weight == null) {
                                return 'Invalid number';
                              }
                              if (_selectedUnitSystem == 'metric') {
                                if (weight < 30 || weight > 300) {
                                  return l10n.screensSettingsImportProfileCompletionWeightRange;
                                }
                              } else {
                                if (weight < 66 || weight > 660) {
                                  return 'Weight must be between 66-660 lb';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Preferences
            Text(l10n.screensSettingsImportProfileCompletionPreferences, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedUnitSystem,
                      decoration: InputDecoration(
                        labelText: l10n.screensSettingsImportProfileCompletionUnitSystem,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.straighten),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'metric',
                          child: Text(l10n.screensSettingsImportProfileCompletionMetric),
                        ),
                        DropdownMenuItem(
                          value: 'imperial',
                          child: Text(l10n.screensSettingsImportProfileCompletionImperial),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedUnitSystem = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedActivityLevel,
                      decoration: InputDecoration(
                        labelText: l10n.screensSettingsImportProfileCompletionActivityLevel,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.directions_run),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'sedentary',
                          child: Text(l10n.screensSettingsImportProfileCompletionSedentary),
                        ),
                        DropdownMenuItem(
                          value: 'lightlyActive',
                          child: Text(l10n.screensSettingsImportProfileCompletionLightlyActive),
                        ),
                        DropdownMenuItem(
                          value: 'moderatelyActive',
                          child: Text(l10n.screensSettingsImportProfileCompletionModeratelyActive),
                        ),
                        DropdownMenuItem(
                          value: 'veryActive',
                          child: Text(l10n.screensSettingsImportProfileCompletionVeryActive),
                        ),
                        DropdownMenuItem(
                          value: 'extraActive',
                          child: Text(l10n.screensSettingsImportProfileCompletionExtraActive),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedActivityLevel = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedFitnessGoal,
                      decoration: InputDecoration(
                        labelText: l10n.screensSettingsImportProfileCompletionFitnessGoal,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.flag),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'loseWeight',
                          child: Text(l10n.screensSettingsImportProfileCompletionLoseWeight),
                        ),
                        DropdownMenuItem(
                          value: 'maintainWeight',
                          child: Text(l10n.screensSettingsImportProfileCompletionMaintainWeight),
                        ),
                        DropdownMenuItem(
                          value: 'gainWeight',
                          child: Text(l10n.screensSettingsImportProfileCompletionGainWeight),
                        ),
                        DropdownMenuItem(
                          value: 'buildMuscle',
                          child: Text(l10n.screensSettingsImportProfileCompletionBuildMuscle),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFitnessGoal = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onSkipped,
                  child: const Text('Skip for Now'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _saveProfile,
                  child: Text(l10n.componentsChatBotProfileCustomizationDialogSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Update the profile with completed data
      widget.incompleteProfile.addAll({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'age': int.parse(_ageController.text),
        'gender': _selectedGender,
        'height': double.parse(_heightController.text),
        'weight': double.parse(_weightController.text),
        'activityLevel': _selectedActivityLevel,
        'fitnessGoal': _selectedFitnessGoal,
        'unitSystem': _selectedUnitSystem,
      });

      widget.onCompleted();
    }
  }
}
