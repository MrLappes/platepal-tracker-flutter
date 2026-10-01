import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

import '../../services/data/auto_backup.dart';

/// Settings → Backup: automatic backups and a manual "Back up now".
class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key, this.service, this.pickDirectory});

  final AutoBackupService? service;

  /// Folder picker, defaulting to file_picker.
  final Future<String?> Function()? pickDirectory;

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  late final AutoBackupService _service = widget.service ?? AutoBackupService();
  AutoBackupSettings? _settings;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final settings = await _service.loadSettings();
    if (mounted) setState(() => _settings = settings);
  }

  Future<void> _update(Future<void> Function() change) async {
    await change();
    await _reload();
  }

  Future<void> _chooseFolder() async {
    try {
      final path =
          await (widget.pickDirectory ??
              () => FilePicker.platform.getDirectoryPath())();
      if (path == null || path.isEmpty) return;
      if (!await _service.canWriteTo(path)) {
        _showPickFailed();
        return;
      }
      await _update(() => _service.setDirectory(path));
    } catch (e) {
      debugPrint('Choosing a backup folder failed: ${e.runtimeType}');
      _showPickFailed();
    }
  }

  void _showPickFailed() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).screensBackupFolderPickFailed,
        ),
      ),
    );
  }

  Future<void> _backUpNow() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _running = true);
    final result = await _service.backUpNow();
    if (!mounted) return;
    setState(() => _running = false);
    await _reload();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.success ? l10n.screensBackupDone : l10n.screensBackupFailed,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final locale = Localizations.localeOf(context).toString();
    return '${DateFormat.yMMMd(locale).format(time)}, '
        '${TimeOfDay.fromDateTime(time).format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = _settings;
    return Scaffold(
      appBar: AppBar(title: Text('${l10n.screensBackupTitle.toUpperCase()} //')),
      body:
          settings == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  SwitchListTile(
                    key: const ValueKey('auto-backup-switch'),
                    title: Text(l10n.screensBackupAutomatic),
                    subtitle: Text(l10n.screensBackupAutomaticSubtitle),
                    value: settings.enabled,
                    onChanged: (value) => _update(() => _service.setEnabled(value)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SegmentedButton<AutoBackupFrequency>(
                      segments: [
                        ButtonSegment(
                          value: AutoBackupFrequency.daily,
                          label: Text(l10n.screensBackupDaily),
                        ),
                        ButtonSegment(
                          value: AutoBackupFrequency.weekly,
                          label: Text(l10n.screensBackupWeekly),
                        ),
                      ],
                      selected: {settings.frequency},
                      showSelectedIcon: false,
                      onSelectionChanged:
                          settings.enabled
                              ? (selection) => _update(
                                () => _service.setFrequency(selection.first),
                              )
                              : null,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(l10n.screensBackupFolder),
                    subtitle: Text(
                      settings.directory ?? l10n.screensBackupFolderDefault,
                    ),
                    trailing: TextButton(
                      onPressed: _chooseFolder,
                      child: Text(l10n.screensBackupChooseFolder),
                    ),
                  ),
                  if (settings.directory != null)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextButton(
                          onPressed:
                              () => _update(() => _service.setDirectory(null)),
                          child: Text(l10n.screensBackupUseDefaultFolder),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Text(
                      l10n.screensBackupKeepNote(autoBackupsToKeep),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(
                      settings.lastBackupAt == null
                          ? l10n.screensBackupNever
                          : l10n.screensBackupLast(
                            _formatTime(settings.lastBackupAt!),
                          ),
                    ),
                    subtitle:
                        settings.lastFailureAt == null
                            ? null
                            : Text(
                              l10n.screensBackupLastFailed(
                                _formatTime(settings.lastFailureAt!),
                              ),
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton.icon(
                      onPressed: _running ? null : _backUpNow,
                      icon:
                          _running
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                              : const Icon(Icons.backup_outlined),
                      label: Text(l10n.screensBackupNow),
                    ),
                  ),
                ],
              ),
    );
  }
}
