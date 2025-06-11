import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/chat/openai_service.dart';

class ApiKeySettingsScreen extends StatefulWidget {
  const ApiKeySettingsScreen({super.key});

  @override
  State<ApiKeySettingsScreen> createState() => _ApiKeySettingsScreenState();
}

class _ApiKeySettingsScreenState extends State<ApiKeySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _openAIService = OpenAIService();

  bool _isLoading = false;
  bool _isObscured = true;
  bool _hasApiKey = false;
  bool _isLoadingModels = false;
  bool _pasteSuccess = false;

  String _selectedModel = 'gpt-4o';
  String? _errorMessage;
  String? _modelError;
  List<OpenAIModel> _availableModels = [];

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _loadSelectedModel();
    _loadDefaultModels();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
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
        _fetchAvailableModels(apiKey);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      final localizations = AppLocalizations.of(context);
      _showErrorSnackBar(
        localizations?.failedToLoadApiKey ?? 'Failed to load API key',
      );
    }
  }

  Future<void> _loadSelectedModel() async {
    final model = await _openAIService.getSelectedModel();
    setState(() {
      _selectedModel = model;
      // Ensure the selected model is in the available models list
      if (!_availableModels.any((m) => m.id == _selectedModel)) {
        _selectedModel = _availableModels.first.id;
      }
    });
  }

  void _loadDefaultModels() {
    setState(() {
      _availableModels = _openAIService.getDefaultModels();
      // Ensure the selected model is in the available models list
      if (!_availableModels.any((m) => m.id == _selectedModel)) {
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
      final models = await _openAIService.getAvailableModels(apiKey);
      setState(() {
        _availableModels = models;

        // Set to first model if current selected model is not in the list
        if (!models.any((m) => m.id == _selectedModel)) {
          _selectedModel = models.first.id;
        }
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      final localizations = AppLocalizations.of(context);
      setState(() {
        _modelError =
            localizations?.couldNotLoadModels ??
            'Could not load available models. Using default model list.';
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

    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      final localizations = AppLocalizations.of(context);
      setState(() {
        _errorMessage =
            localizations?.apiKeyMustStartWith ?? 'Please enter an API key';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Test API key with selected model
      final testResult = await _openAIService.testApiKey(
        apiKey,
        _selectedModel,
      );

      if (!testResult.success) {
        setState(() {
          _errorMessage = testResult.message;
        });
        return;
      }

      // If successful, save the API key and model
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('openai_api_key', apiKey);
      await _openAIService.setSelectedModel(_selectedModel);

      setState(() {
        _hasApiKey = true;
      });

      if (mounted) {
        final localizations = AppLocalizations.of(context);
        _showSuccessDialog(
          localizations?.apiKeySavedSuccessfully ?? 'API Key Saved',
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
      localizations?.removeApiKey ?? 'Remove API Key',
      localizations?.removeApiKeyConfirmation ??
          'Are you sure you want to remove your API key? This will disable AI features.',
    );

    if (!confirm) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('openai_api_key');

      setState(() {
        _apiKeyController.clear();
        _hasApiKey = false;
        _errorMessage = null;
      });

      if (mounted) {
        _showSuccessSnackBar(
          localizations?.apiKeyRemovedSuccessfully ??
              'API key removed successfully',
        );
      }
    } catch (e) {
      _showErrorSnackBar(
        localizations?.failedToRemoveApiKey ?? 'Failed to remove API key',
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
      _showErrorSnackBar(
        localizations?.linkError ?? 'An error occurred opening the link',
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        setState(() {
          _apiKeyController.text = clipboardData.text!;
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
        if (clipboardData.text!.length > 30) {
          _fetchAvailableModels(clipboardData.text!);
        }

        // ignore: use_build_context_synchronously
        final localizations = AppLocalizations.of(context);
        _showSuccessSnackBar(
          localizations?.pastedFromClipboard ?? 'Pasted from clipboard',
        );
      } else {
        // ignore: use_build_context_synchronously
        final localizations = AppLocalizations.of(context);
        _showErrorSnackBar(
          localizations?.clipboardEmpty ?? 'Clipboard is empty',
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      final localizations = AppLocalizations.of(context);
      _showErrorSnackBar(
        localizations?.failedToAccessClipboard ?? 'Failed to access clipboard',
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
                child: Text(localizations?.ok ?? 'OK'),
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
                child: Text(localizations?.cancel ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(localizations?.remove ?? 'Remove'),
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
    if (!trimmedValue.startsWith('sk-')) {
      return localizations?.apiKeyMustStartWith ??
          'API key must start with "sk-"';
    }

    if (trimmedValue.length < 40) {
      return localizations?.apiKeyTooShort ?? 'API key appears to be too short';
    }

    return null;
  }

  String _getModelInfoText() {
    final localizations = AppLocalizations.of(context);
    if (_selectedModel.contains('gpt-4')) {
      return localizations?.gpt4ModelsInfo ??
          'GPT-4 models provide the best analysis but cost more';
    } else {
      return localizations?.gpt35ModelsInfo ??
          'GPT-3.5 models are more cost-effective for basic analysis';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.apiKeySettings ?? 'API Key Settings'),
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
                            localizations?.aboutOpenAiApiKey ??
                                'About OpenAI API Key',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations?.apiKeyDescription ??
                            'To use AI features like meal analysis and suggestions, you need to provide your own OpenAI API key. This ensures your data stays private and you have full control.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localizations?.apiKeyBulletPoints ??
                            '• Get your API key from platform.openai.com\n• Your key is stored locally on your device\n• Usage charges apply directly to your OpenAI account',
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
                                localizations?.apiKeyConfigured ??
                                    'API Key Configured',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              Text(
                                localizations?.aiFeaturesEnabled ??
                                    'AI features are enabled',
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

              // API Key Input
              Text(
                localizations?.openAiApiKey ?? 'OpenAI API Key',
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
                  hintText: localizations?.apiKeyPlaceholder ?? 'sk-...',
                  helperText:
                      localizations?.apiKeyHelperText ??
                      'Enter your OpenAI API key or leave empty to disable AI features',
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
                            localizations?.pasteFromClipboard ??
                            'Paste from Clipboard',
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
                localizations?.selectModel ?? 'Select Model',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
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
                                    : (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedModel = value;
                                        });
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                  localizations?.apiKeyTestWarning ??
                      'Your API key will be tested with a small request to verify it works. The key is only stored on your device and never sent to our servers.',
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
                                localizations?.testingApiKey ??
                                    'Testing API key...',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                          : Text(
                            _hasApiKey
                                ? (localizations?.updateApiKey ??
                                    'Update API Key')
                                : (localizations?.testAndSaveApiKey ??
                                    'Test & Save API Key'),
                            style: const TextStyle(fontSize: 16),
                          ),
                ),
              ),

              const SizedBox(height: 16), // Get API Key Button
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
                        localizations?.getApiKeyFromOpenAi ??
                            'Get API Key from OpenAI',
                      ),
                    ],
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
