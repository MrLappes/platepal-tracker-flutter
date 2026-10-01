import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

import '../../services/data/auto_backup.dart';

/// Runs due automatic backups on app start and resume, and reports a failed
/// run from an earlier session with a snackbar.
class AutoBackupRunner extends StatefulWidget {
  const AutoBackupRunner({
    super.key,
    required this.child,
    this.onOpenSettings,
    this.service,
  });

  final Widget child;
  final VoidCallback? onOpenSettings;
  final AutoBackupService? service;

  @override
  State<AutoBackupRunner> createState() => _AutoBackupRunnerState();
}

class _AutoBackupRunnerState extends State<AutoBackupRunner>
    with WidgetsBindingObserver {
  late final AutoBackupService _service = widget.service ?? AutoBackupService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onStart());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _service.runIfDue();
  }

  Future<void> _onStart() async {
    try {
      if (await _service.takeFailureNotice() && mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(l10n.screensBackupFailureNotice),
            action:
                widget.onOpenSettings == null
                    ? null
                    : SnackBarAction(
                      label: l10n.screensBackupOpenSettings,
                      onPressed: widget.onOpenSettings!,
                    ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Backup notice failed: ${e.runtimeType}');
    }
    await _service.runIfDue();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
