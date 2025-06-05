import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/data/import_export_service.dart';

class ImportDataScreen extends StatefulWidget {
  const ImportDataScreen({super.key});

  @override
  State<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends State<ImportDataScreen> {
  final ImportExportService _importExportService = ImportExportService();
  bool _isImporting = false;
  bool _isRestoring = false;
  bool _hasBackupAvailable = false;
  Map<String, dynamic>? _backupInfo;
  final Set<DataType> _selectedDataTypes = {DataType.dishes, DataType.mealLogs};
  DuplicateHandling _duplicateHandling = DuplicateHandling.overwrite;
  String? _selectedFilePath;
  String? _lastError;
  List<String> _importErrors = [];
  ImportDetailedResults? _lastResults;
  bool _showAdvancedOptions = false;

  // Progress tracking
  int _currentProgress = 0;
  int _totalItems = 0;
  String _currentType = '';

  @override
  void initState() {
    super.initState();
    _checkBackupAvailability();
  }

  Future<void> _checkBackupAvailability() async {
    final hasBackup = await _importExportService.hasBackupAvailable();
    final backupInfo = await _importExportService.getBackupInfo();

    if (mounted) {
      setState(() {
        _hasBackupAvailable = hasBackup;
        _backupInfo = backupInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.importData),
        elevation: 2,
      ),
      body:
          _isImporting || _isRestoring
              ? _buildLoadingView()
              : _buildImportForm(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress indicator
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 8,
                  value:
                      _totalItems > 0 ? _currentProgress / _totalItems : null,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                if (_totalItems > 0)
                  Text(
                    '${((_currentProgress / _totalItems) * 100).round()}%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isRestoring
                ? 'Restoring from backup...'
                : AppLocalizations.of(context)!.importProgress,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_totalItems > 0 && !_isRestoring) ...[
            Text(
              'Processing $_currentProgress of $_totalItems items',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_currentType.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Current: $_currentType',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ] else
            Text(
              _isRestoring
                  ? 'Undoing the last import...'
                  : 'Preparing your data...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImportForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasBackupAvailable) ...[
            _buildBackupCard(),
            const SizedBox(height: 16),
          ],
          _buildFileSelectionCard(),
          const SizedBox(height: 16),
          _buildDataTypeSelectionCard(),
          const SizedBox(height: 16),
          _buildDuplicateHandlingCard(),
          const SizedBox(height: 16),
          _buildAdvancedOptionsCard(),
          if (_lastError != null || _importErrors.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildErrorCard(),
          ],
          if (_lastResults != null) ...[
            const SizedBox(height: 16),
            _buildResultsCard(),
          ],
          const SizedBox(height: 24),
          _buildImportButton(),
        ],
      ),
    );
  }

  Widget _buildFileSelectionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_upload, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'File Selection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedFilePath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFilePath!.split('/').last,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _selectedFilePath = null),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectFile,
                icon: const Icon(Icons.folder_open),
                label: Text(
                  _selectedFilePath != null
                      ? 'Change File'
                      : AppLocalizations.of(context)!.selectFile,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supported formats: JSON, CSV',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeSelectionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.selectDataToImport,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDataTypeCheckbox(
              DataType.dishes,
              Icons.restaurant,
              Colors.orange,
            ),
            _buildDataTypeCheckbox(
              DataType.mealLogs,
              Icons.history,
              Colors.green,
            ),
            _buildDataTypeCheckbox(
              DataType.userProfiles,
              Icons.person,
              Colors.blue,
            ),
            _buildDataTypeCheckbox(
              DataType.ingredients,
              Icons.food_bank,
              Colors.purple,
            ),
            const Divider(height: 24),
            _buildDataTypeCheckbox(
              DataType.allData,
              Icons.select_all,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTypeCheckbox(DataType dataType, IconData icon, Color color) {
    String title;
    String subtitle;

    switch (dataType) {
      case DataType.dishes:
        title = AppLocalizations.of(context)!.dishes;
        subtitle = 'Your saved recipes and dishes';
        break;
      case DataType.mealLogs:
        title = AppLocalizations.of(context)!.mealLogs;
        subtitle = 'Your meal history and nutrition logs';
        break;
      case DataType.userProfiles:
        title = AppLocalizations.of(context)!.userProfiles;
        subtitle = 'User profile and preferences';
        break;
      case DataType.ingredients:
        title = AppLocalizations.of(context)!.ingredients;
        subtitle = 'Ingredient database';
        break;
      case DataType.allData:
        title = AppLocalizations.of(context)!.allData;
        subtitle = 'Import everything from the file';
        break;
      default:
        title = dataType.name;
        subtitle = '';
        break;
    }

    return CheckboxListTile(
      value: _selectedDataTypes.contains(dataType),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            if (dataType == DataType.allData) {
              _selectedDataTypes.clear();
              _selectedDataTypes.add(DataType.allData);
            } else {
              _selectedDataTypes.remove(DataType.allData);
              _selectedDataTypes.add(dataType);
            }
          } else {
            _selectedDataTypes.remove(dataType);
          }
        });
      },
      secondary: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

  Widget _buildDuplicateHandlingCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.merge_type, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.howToHandleDuplicates,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RadioListTile<DuplicateHandling>(
              title: Text(AppLocalizations.of(context)!.skipDuplicates),
              subtitle: const Text(
                'Keep existing data, skip imported duplicates',
              ),
              value: DuplicateHandling.skip,
              groupValue: _duplicateHandling,
              onChanged: (value) {
                setState(() {
                  _duplicateHandling = value!;
                });
              },
              secondary: const Icon(Icons.skip_next, color: Colors.blue),
            ),
            RadioListTile<DuplicateHandling>(
              title: Text(AppLocalizations.of(context)!.overwriteDuplicates),
              subtitle: const Text('Replace existing data with imported data'),
              value: DuplicateHandling.overwrite,
              groupValue: _duplicateHandling,
              onChanged: (value) {
                setState(() {
                  _duplicateHandling = value!;
                });
              },
              secondary: const Icon(Icons.update, color: Colors.orange),
            ),
            RadioListTile<DuplicateHandling>(
              title: Text(AppLocalizations.of(context)!.mergeDuplicates),
              subtitle: const Text('Merge data intelligently'),
              value: DuplicateHandling.merge,
              groupValue: _duplicateHandling,
              onChanged: (value) {
                setState(() {
                  _duplicateHandling = value!;
                });
              },
              secondary: const Icon(Icons.call_merge, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedOptionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap:
                  () => setState(
                    () => _showAdvancedOptions = !_showAdvancedOptions,
                  ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Advanced Options',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showAdvancedOptions
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            if (_showAdvancedOptions) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Validate data before import'),
                subtitle: const Text('Check data integrity and show warnings'),
                value: true,
                onChanged: null, // Always enabled for now
                secondary: const Icon(Icons.verified, color: Colors.green),
              ),
              SwitchListTile(
                title: const Text('Create backup before import'),
                subtitle: const Text('Automatically backup existing data'),
                value: true,
                onChanged: null, // Always enabled for now
                secondary: const Icon(Icons.backup, color: Colors.blue),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Import Issues',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lastError != null) ...[
              Text(
                _lastError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_importErrors.isNotEmpty) const SizedBox(height: 12),
            ],
            if (_importErrors.isNotEmpty) ...[
              Text(
                'Detailed Errors:',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _importErrors.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• ${_importErrors[index]}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    if (_lastResults == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Import Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lastResults!.fileInfo != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'File: ${_lastResults!.fileInfo!.fileName}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            ...(_lastResults!.summary.entries.map((entry) {
              final summary = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${summary.processed}/${summary.total}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildImportButton() {
    final canImport =
        _selectedFilePath != null && _selectedDataTypes.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canImport ? _performImport : null,
        icon: const Icon(Icons.file_download),
        label: Text(
          AppLocalizations.of(context)!.importFromFile,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          disabledForegroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedFilePath = file.path;
            _lastError = null;
            _importErrors.clear();
            _lastResults = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _lastError = 'Error selecting file: $e';
      });
    }
  }

  Future<void> _performImport() async {
    if (_selectedFilePath == null || _selectedDataTypes.isEmpty) return;
    setState(() {
      _isImporting = true;
      _lastError = null;
      _importErrors.clear();
      _lastResults = null;
      _currentProgress = 0;
      _totalItems = 0;
      _currentType = '';
    });

    try {
      // Create backup before import
      final backupCreated =
          await _importExportService.createBackupBeforeImport();
      if (!backupCreated) {
        debugPrint('Warning: Failed to create backup before import');
      }
      final result = await _importExportService.importData(
        filePath: _selectedFilePath!,
        dataTypes: _selectedDataTypes.toList(),
        duplicateHandling: _duplicateHandling,
        onProgress: (current, total, currentType) {
          if (mounted) {
            setState(() {
              _currentProgress = current;
              _totalItems = total;
              _currentType = currentType;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isImporting = false;
          _lastResults = result.detailedResults;
        });

        if (result.success) {
          // Refresh backup availability after successful import
          await _checkBackupAvailability();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.importedItemsCount(result.itemsProcessed),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Close the screen after successful import
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop(true);
          });
        } else {
          setState(() {
            _importErrors = result.errors;
            _lastError =
                result.errors.isNotEmpty
                    ? 'Import completed with ${result.errors.length} errors'
                    : AppLocalizations.of(context)!.importFailed;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _lastError = 'Import failed: $e';
        });
      }
    }
  }

  Widget _buildBackupCard() {
    if (!_hasBackupAvailable || _backupInfo == null) {
      return const SizedBox.shrink();
    }

    final backupDate = _backupInfo!['date'] as DateTime;
    final backupSize = _backupInfo!['size'] as int;
    final formattedSize = (backupSize / 1024).toStringAsFixed(1);

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restore,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Backup Available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'A backup from your last import is available.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'Created: ${_formatDate(backupDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.storage,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'Size: ${formattedSize}KB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performRestore,
                icon: const Icon(Icons.undo),
                label: const Text(
                  'Ah Shit, Go Back!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _performRestore() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Restore from Backup'),
            content: const Text(
              'This will restore your data to the state before the last import. '
              'All changes made since then will be lost. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Restore'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRestoring = true;
      _lastError = null;
      _importErrors.clear();
    });

    try {
      final result = await _importExportService.restoreFromLastBackup();

      if (mounted) {
        setState(() {
          _isRestoring = false;
        });

        if (result.success) {
          // Refresh backup availability
          await _checkBackupAvailability();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully restored from backup!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Close the screen after successful restore
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop(true);
          });
        } else {
          setState(() {
            _lastError = result.message;
            _importErrors = result.errors;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRestoring = false;
          _lastError = 'Restore failed: $e';
        });
      }
    }
  }
}
