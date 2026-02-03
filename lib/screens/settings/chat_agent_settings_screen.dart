import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../../providers/chat_provider.dart';
import '../../services/storage/storage_service_provider.dart';

class ChatAgentSettingsScreen extends StatefulWidget {
  const ChatAgentSettingsScreen({super.key});

  @override
  State<ChatAgentSettingsScreen> createState() =>
      _ChatAgentSettingsScreenState();
}

class _ChatAgentSettingsScreenState extends State<ChatAgentSettingsScreen> {
  late bool agentModeEnabled;
  late bool deepSearchEnabled;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    agentModeEnabled = chatProvider.isAgentModeEnabled;
    deepSearchEnabled = chatProvider.isDeepSearchEnabled;
  }

  Future<void> _saveSettings() async {
    setState(() => loading = true);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final storageProvider = Provider.of<StorageServiceProvider>(
      context,
      listen: false,
    );

    // Save to SharedPreferences via storage provider
    final prefs = await storageProvider.getPrefs();
    await prefs.setBool('agent_mode_enabled', agentModeEnabled);
    await prefs.setBool('deep_search_enabled', deepSearchEnabled);

    // Update provider state
    await chatProvider.setAgentModeEnabled(agentModeEnabled);
    chatProvider.deepSearchEnabled = deepSearchEnabled;

    // Ensure provider reloads from SharedPreferences
    await chatProvider.reloadAgentSettings();

    setState(() => loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).screensSettingsChatAgentSettingsChatSettingsSaved,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${localizations.screensSettingsChatAgentSettingsChatAgentSettingsTitle.toUpperCase()} //',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile.adaptive(
            title: Text(
              localizations
                  .screensSettingsChatAgentSettingsChatAgentEnableTitle,
            ),
            subtitle: Text(
              localizations
                  .screensSettingsChatAgentSettingsChatAgentEnableSubtitle,
            ),
            value: agentModeEnabled,
            onChanged: (value) {
              setState(() {
                agentModeEnabled = value;
                if (!value) deepSearchEnabled = false;
              });
            },
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            title: Text(
              localizations
                  .screensSettingsChatAgentSettingsChatAgentDeepSearchTitle,
            ),
            subtitle: Text(
              localizations
                  .screensSettingsChatAgentSettingsChatAgentDeepSearchSubtitle,
            ),
            value: deepSearchEnabled,
            onChanged:
                agentModeEnabled
                    ? (value) => setState(() => deepSearchEnabled = value)
                    : null,
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: loading ? null : _saveSettings,
            icon:
                loading
                    ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Icon(Icons.save),
            label: Text(
              localizations.componentsChatBotProfileCustomizationDialogSave,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations
                        .screensSettingsChatAgentSettingsChatAgentInfoTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations
                        .screensSettingsChatAgentSettingsChatAgentInfoDescription,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
