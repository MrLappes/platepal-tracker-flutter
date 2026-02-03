import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../../services/chat/openai_service.dart';

class ApiKeySettingsScreen extends StatefulWidget {
  const ApiKeySettingsScreen({super.key});

  @override
  State<ApiKeySettingsScreen> createState() => _ApiKeySettingsScreenState();
}

class _ApiKeySettingsScreenState extends State<ApiKeySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _customUrlController = TextEditingController();
  final _customModelController = TextEditingController();
  final _openAIService = OpenAIService();

  bool _isLoading = false;
  bool _isObscured = true;
  bool _hasApiKey = false;
  bool _isLoadingModels = false;
  bool _pasteSuccess = false;
  bool _isCompatibilityMode = false;

  String _selectedModel = 'gpt-4o';
  String? _errorMessage;
  String? _modelError;
  List<OpenAIModel> _availableModels = [];

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _loadCompatibilitySettings();
    _loadDefaultModels();
    _loadSelectedModel();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _customUrlController.dispose();
    _customModelController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('openai_api_key');
      if (apiKey != null && apiKey.isNotEmpty) {
        setState(() {
          _apiKeyController.text = apiKey;
          _hasApiKey = true;
        });

        // Load available models for existing API key
        await _fetchAvailableModels(apiKey);
        // After models are loaded, reload selected model
        await _loadSelectedModel();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      final localizations = AppLocalizations.of(context);
      _showErrorSnackBar(
        localizations.screensSettingsApiKeySettingsFailedToLoadApiKey,
      );
    }
  }

  Future<void> _loadSelectedModel() async {
    final model = await _openAIService.getSelectedModel();
    setState(() {
      _selectedModel = model;
      // Ensure the selected model is in the available models list
      if (!_availableModels.any((m) => m.id == _selectedModel) &&
          _availableModels.isNotEmpty) {
        _selectedModel = _availableModels.first.id;
      }
    });
  }

  Future<void> _loadCompatibilitySettings() async {
    try {
      final isCompatibility = await _openAIService.getIsCompatibilityMode();
      final customUrl = await _openAIService.getCustomBaseUrl();
      final customModel = await _openAIService.getCustomModel();

      setState(() {
        _isCompatibilityMode = isCompatibility;
        _customUrlController.text = customUrl ?? '';
        _customModelController.text = customModel ?? '';
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      final localizations = AppLocalizations.of(context);
      _showErrorSnackBar(
        localizations.screensSettingsApiKeySettingsFailedToLoadApiKey,
      );
    }
  }

  void _loadDefaultModels() {
    setState(() {
      _availableModels = _openAIService.getDefaultModels();
      // Ensure the selected model is in the available models list
      if (!_availableModels.any((m) => m.id == _selectedModel) &&
          _availableModels.isNotEmpty) {
        _selectedModel = _availableModels.first.id;
      }
    });
  }

  Future<void> _fetchAvailableModels(String apiKey) async {
    if (apiKey.trim().length < 30) return; // Only try if key looks valid

    setState(() {
      _isLoadingModels = true;
      _modelError = null;
    });

    try {
      final customUrl =
          _isCompatibilityMode ? _customUrlController.text.trim() : null;
      final models = await _openAIService.getAvailableModels(
        apiKey,
        customBaseUrl: customUrl,
      );
      setState(() {
        _availableModels = models;

        // Set to first model if current selected model is not in the list
        if (!models.any((m) => m.id == _selectedModel) && models.isNotEmpty) {
          _selectedModel = models.first.id;
        }
      });
      // After models are loaded, reload selected model
      await _loadSelectedModel();
    } catch (e) {
      // ignore: use_build_context_synchronously
      final localizations = AppLocalizations.of(context);
      setState(() {
        _modelError =
            localizations.screensSettingsApiKeySettingsCouldNotLoadModels;
        _availableModels = _openAIService.getDefaultModels();
      });
    } finally {
      setState(() {
        _isLoadingModels = false;
      });
    }
  }

  Future<void> _testAndSaveApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    final rawApiKey = _apiKeyController.text.trim();
    // Clean the API key of any unwanted characters (null terminators, control chars)
    final apiKey = rawApiKey.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    if (apiKey.isEmpty) {
      final localizations = AppLocalizations.of(context);
      setState(() {
        _errorMessage =
            localizations.screensSettingsApiKeySettingsApiKeyMustStartWith;
      });
      return;
    }

    // Validate compatibility mode fields
    if (_isCompatibilityMode) {
      final customUrl = _customUrlController.text.trim();
      final customModel = _customModelController.text.trim();

      if (customUrl.isEmpty) {
        setState(() {
          _errorMessage = 'Custom base URL is required for compatibility mode';
        });
        return;
      }

      if (customModel.isEmpty) {
        setState(() {
          _errorMessage = 'Model name is required for compatibility mode';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the model to test
      final modelToTest =
          _isCompatibilityMode
              ? _customModelController.text.trim()
              : _selectedModel;
      final customUrl =
          _isCompatibilityMode ? _customUrlController.text.trim() : null;

      // Test API key with selected model
      final testResult = await _openAIService.testApiKey(
        apiKey,
        modelToTest,
        customBaseUrl: customUrl,
      );

      if (!testResult.success) {
        setState(() {
          _errorMessage = testResult.message;
        });
        return;
      }

      // If successful, save all settings
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('openai_api_key', apiKey);
      await _openAIService.setIsCompatibilityMode(_isCompatibilityMode);

      if (_isCompatibilityMode) {
        await _openAIService.setCustomBaseUrl(_customUrlController.text.trim());
        await _openAIService.setCustomModel(_customModelController.text.trim());
      } else {
        await _openAIService.setSelectedModel(_selectedModel);
      }

      setState(() {
        _hasApiKey = true;
      });

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        _showSuccessDialog(
          localizations.screensSettingsApiKeySettingsApiKeySavedSuccessfully,
          testResult.message,
        );
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeApiKey() async {
    final localizations = AppLocalizations.of(context);
    final confirm = await _showConfirmDialog(
      localizations.screensSettingsApiKeySettingsRemoveApiKey,
      localizations.screensSettingsApiKeySettingsRemoveApiKeyConfirmation,
    );

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('openai_api_key');

      // Also clear compatibility mode settings
      await _openAIService.setIsCompatibilityMode(false);
      await _openAIService.setCustomBaseUrl(null);
      await _openAIService.setCustomModel(null);

      setState(() {
        _apiKeyController.clear();
        _customUrlController.clear();
        _customModelController.clear();
        _hasApiKey = false;
        _isCompatibilityMode = false;
        _errorMessage = null;
      });

      if (mounted) {
        _showSuccessSnackBar(
          localizations.screensSettingsApiKeySettingsApiKeyRemovedSuccessfully,
        );
      }
    } catch (e) {
      _showErrorSnackBar(
        localizations.screensSettingsApiKeySettingsFailedToRemoveApiKey,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openApiKeyUrl() async {
    const url = 'https://platform.openai.com/api-keys';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      final localizations = AppLocalizations.of(context);
      _showErrorSnackBar(localizations.screensSettingsApiKeySettingsLinkError);
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        // Clean the pasted text of any unwanted characters
        final cleanedText = clipboardData.text!.trim().replaceAll(
          RegExp(r'[\x00-\x1F\x7F]'),
          '',
        );

        setState(() {
          _apiKeyController.text = cleanedText;
          _pasteSuccess = true;
        });

        // Show success message briefly
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _pasteSuccess = false;
            });
          }
        });

        // Fetch models if key looks valid
        if (cleanedText.length > 30) {
          _fetchAvailableModels(cleanedText);
        }

        // ignore: use_build_context_synchronously
        final localizations = AppLocalizations.of(context);
        _showSuccessSnackBar(
          localizations.screensSettingsApiKeySettingsPastedFromClipboard,
        );
      } else {
        // ignore: use_build_context_synchronously
        final localizations = AppLocalizations.of(context);
        _showErrorSnackBar(
          localizations.screensSettingsApiKeySettingsClipboardEmpty,
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      final localizations = AppLocalizations.of(context);
      _showErrorSnackBar(
        localizations.screensSettingsApiKeySettingsFailedToAccessClipboard,
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _showSuccessDialog(String title, String message) async {
    final localizations = AppLocalizations.of(context);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to settings
                },
                child: Text(localizations.screensCalendarOk),
              ),
            ],
          ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final localizations = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  localizations
                      .componentsChatBotProfileCustomizationDialogCancel,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(localizations.screensSettingsApiKeySettingsRemove),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  String? _validateApiKey(String? value) {
    final localizations = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty for removal
    }

    final trimmedValue = value.trim();

    // For compatibility mode, be more flexible with API key format
    if (_isCompatibilityMode) {
      if (trimmedValue.length < 10) {
        return 'API key seems too short';
      }
      return null;
    }

    // For OpenAI mode, enforce OpenAI format
    if (!trimmedValue.startsWith('sk-')) {
      return localizations.screensSettingsApiKeySettingsApiKeyMustStartWith;
    }

    if (trimmedValue.length < 40) {
      return localizations.screensSettingsApiKeySettingsApiKeyTooShort;
    }

    return null;
  }

  String _getModelInfoText() {
    final localizations = AppLocalizations.of(context);
    if (_selectedModel.contains('gpt-4')) {
      return localizations.screensSettingsApiKeySettingsGpt4ModelsInfo;
    } else {
      return localizations.screensSettingsApiKeySettingsGpt35ModelsInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${localizations.screensMenuApiKeySettings.toUpperCase()} //',
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localizations
                                .screensSettingsApiKeySettingsAboutOpenAiApiKey,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations
                            .screensSettingsApiKeySettingsApiKeyDescription,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations
                            .screensSettingsApiKeySettingsApiKeyBulletPoints,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24), // Status Card
              if (_hasApiKey) ...[
                Card(
                  color: Colors.green.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations
                                    .screensSettingsApiKeySettingsApiKeyConfigured,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                localizations
                                    .screensSettingsApiKeySettingsAiFeaturesEnabled,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.green.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Compatibility Mode Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API Mode',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('OpenAI Compatible API'),
                        subtitle: Text(
                          _isCompatibilityMode
                              ? 'Using custom OpenAI-compatible API endpoint'
                              : 'Using official OpenAI API',
                        ),
                        value: _isCompatibilityMode,
                        onChanged: (value) {
                          setState(() {
                            _isCompatibilityMode = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Custom Base URL (only in compatibility mode)
              if (_isCompatibilityMode) ...[
                Text(
                  'Base URL',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customUrlController,
                  validator: (value) {
                    if (_isCompatibilityMode &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Base URL is required for compatibility mode';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'https://api.example.com/v1',
                    helperText:
                        'Enter the base URL for your OpenAI-compatible API',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // API Key Input
              Text(
                _isCompatibilityMode
                    ? 'API Key'
                    : localizations.screensSettingsApiKeySettingsOpenAiApiKey,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _apiKeyController,
                obscureText: _isObscured,
                validator: _validateApiKey,
                onChanged: (value) {
                  // Fetch models when API key changes
                  if (value.length > 30) {
                    _fetchAvailableModels(value);
                  }
                },
                decoration: InputDecoration(
                  hintText:
                      localizations
                          .screensSettingsApiKeySettingsApiKeyPlaceholder,
                  helperText:
                      localizations
                          .screensSettingsApiKeySettingsApiKeyHelperText,
                  prefixIcon: const Icon(Icons.key),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _pasteSuccess ? Icons.check : Icons.content_paste,
                          color: _pasteSuccess ? Colors.green : null,
                        ),
                        onPressed: _isLoading ? null : _pasteFromClipboard,
                        tooltip:
                            localizations
                                .screensSettingsApiKeySettingsPasteFromClipboard,
                      ),
                      IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed:
                            () => setState(() => _isObscured = !_isObscured),
                      ),
                      if (_hasApiKey)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: _isLoading ? null : _removeApiKey,
                        ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Model Selection
              Text(
                _isCompatibilityMode
                    ? 'Model Name'
                    : localizations.screensSettingsApiKeySettingsSelectModel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_isCompatibilityMode) ...[
                // Custom model text field for compatibility mode
                TextFormField(
                  controller: _customModelController,
                  validator: (value) {
                    if (_isCompatibilityMode &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Model name is required for compatibility mode';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'gpt-3.5-turbo, claude-3-sonnet, etc.',
                    helperText:
                        'Enter the exact model name supported by your API',
                    prefixIcon: const Icon(Icons.memory),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else ...[
                // OpenAI model dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value:
                                  _availableModels.any(
                                        (m) => m.id == _selectedModel,
                                      )
                                      ? _selectedModel
                                      : (_availableModels.isNotEmpty
                                          ? _availableModels.first.id
                                          : null),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items:
                                  _availableModels.map((model) {
                                    return DropdownMenuItem(
                                      value: model.id,
                                      child: Text(model.displayName),
                                    );
                                  }).toList(),
                              onChanged:
                                  _isLoading
                                      ? null
                                      : (value) async {
                                        if (value != null) {
                                          setState(() {
                                            _selectedModel = value;
                                          });
                                          // Save selected model immediately
                                          await _openAIService.setSelectedModel(
                                            value,
                                          );
                                        }
                                      },
                            ),
                          ),
                          if (_isLoadingModels)
                            const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_modelError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _modelError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _getModelInfoText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Warning Text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  localizations.screensSettingsApiKeySettingsApiKeyTestWarning,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Test & Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testAndSaveApiKey,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                localizations
                                    .screensSettingsApiKeySettingsTestingApiKey,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                          : Text(
                            _hasApiKey
                                ? (localizations
                                    .screensSettingsApiKeySettingsUpdateApiKey)
                                : (localizations
                                    .screensSettingsApiKeySettingsTestAndSaveApiKey),
                            style: const TextStyle(fontSize: 16),
                          ),
                ),
              ),

              const SizedBox(height: 16),

              // Get API Key Button (only for OpenAI mode)
              if (!_isCompatibilityMode) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _openApiKeyUrl,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.open_in_new),
                        const SizedBox(width: 8),
                        Text(
                          localizations
                              .screensSettingsApiKeySettingsGetApiKeyFromOpenAi,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
