import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import '../../services/data/import_export_service.dart';
import '../../utils/number_parsing.dart';

String _importErrorMessage(AppLocalizations localizations, ImportExportResult result) {
  switch (result.errorCode) {
    case ImportExportErrorCode.importFileMissing:
      return localizations.screensSettingsImportDataFileMissing;
    case ImportExportErrorCode.importFileTooLarge:
      return localizations.screensSettingsImportDataFileTooLarge(
        ImportExportService.maxImportBytes ~/ (1024 * 1024),
      );
    case ImportExportErrorCode.importInvalidJson:
      return localizations.screensSettingsImportDataInvalidJson;
    case ImportExportErrorCode.importUnsupportedFormat:
      return localizations.screensSettingsImportDataUnsupportedFormat;
    case ImportExportErrorCode.importInvalidData:
      return localizations.screensSettingsImportDataInvalidData;
    case ImportExportErrorCode.restoreBackupMissing:
      return localizations.screensSettingsImportDataBackupMissing;
    case ImportExportErrorCode.restoreBackupUnreadable:
      return localizations.screensSettingsImportDataBackupUnreadable;
    case ImportExportErrorCode.restoreSnapshotFailed:
      return localizations.screensSettingsImportDataSnapshotFailed;
    case ImportExportErrorCode.restoreRolledBack:
      return localizations.screensSettingsImportDataRestoreRolledBack;
    case ImportExportErrorCode.restoreRollbackFailed:
      return result.filePath == null
          ? localizations.screensSettingsImportDataRestoreProblem
          : localizations.screensSettingsImportDataRestoreCopySaved(result.filePath!);
    case ImportExportErrorCode.restoreFailed:
      return localizations.screensSettingsImportDataRestoreProblem;
    case ImportExportErrorCode.importFailed:
    case ImportExportErrorCode.exportSectionFailed:
    case ImportExportErrorCode.exportFailed:
    case null:
      return localizations.screensSettingsImportDataImportFailed;
  }
}

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
  DuplicateHandling _duplicateHandling = DuplicateHandling.skip;
  String? _selectedFilePath;
  String? _lastError;
  List<String> _importErrors = [];
  ImportExportResult? _lastResult;
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
        title: Text(
          '${AppLocalizations.of(context).screensMenuImportData.toUpperCase()} //',
        ),
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
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
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
                ? AppLocalizations.of(context).screensSettingsImportDataRestoring
                : AppLocalizations.of(
                  context,
                ).screensSettingsImportDataImportProgress,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_totalItems > 0 && !_isRestoring) ...[
            Text(
              AppLocalizations.of(context).screensSettingsImportDataProcessingItems(
                _currentProgress,
                _totalItems,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_currentType.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(
                  context,
                ).screensSettingsImportDataCurrentType(
                  _dataTypeName(DataType.values.byName(_currentType)),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ] else
            Text(
              _isRestoring
                  ? AppLocalizations.of(context).screensSettingsImportDataUndoing
                  : AppLocalizations.of(context).screensSettingsExportDataPreparing,
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
          if (_lastResult != null) ...[
            const SizedBox(height: 16),
            ImportResultsCard(result: _lastResult!),
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
                  AppLocalizations.of(context).screensSettingsImportDataFileSelection,
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
                      tooltip:
                          AppLocalizations.of(context).screensSettingsImportDataRemoveFile,
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
                      ? AppLocalizations.of(context).screensSettingsImportDataChangeFile
                      : AppLocalizations.of(
                        context,
                      ).screensSettingsImportDataSelectFile,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).screensSettingsImportDataSupportedFormats,
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
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).screensSettingsImportDataSelectDataToImport,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
        title = AppLocalizations.of(context).screensSettingsExportDataDishes;
        subtitle = AppLocalizations.of(context).screensSettingsExportDataDishesDescription;
        break;
      case DataType.mealLogs:
        title = AppLocalizations.of(context).screensSettingsExportDataMealLogs;
        subtitle = AppLocalizations.of(context).screensSettingsExportDataMealLogsDescription;
        break;
      case DataType.userProfiles:
        title =
            AppLocalizations.of(context).screensSettingsExportDataUserProfiles;
        subtitle = AppLocalizations.of(context).screensSettingsExportDataUserProfilesDescription;
        break;
      case DataType.ingredients:
        title =
            AppLocalizations.of(context).componentsChatMessageBubbleIngredients;
        subtitle = AppLocalizations.of(context).screensSettingsExportDataIngredientsDescription;
        break;
      case DataType.allData:
        title = AppLocalizations.of(context).screensSettingsExportDataAllData;
        subtitle = AppLocalizations.of(context).screensSettingsImportDataAllDataDescription;
        break;
      case DataType.supplements:
        title = AppLocalizations.of(context).screensSettingsExportDataSupplements;
        subtitle = AppLocalizations.of(context).screensSettingsExportDataSupplementsDescription;
        break;
      case DataType.fitnessGoals:
        title = AppLocalizations.of(context).screensSettingsExportDataNutritionGoalsData;
        subtitle = AppLocalizations.of(context).screensSettingsExportDataFitnessGoalsDescription;
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
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).screensSettingsImportDataHowToHandleDuplicates,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RadioGroup<DuplicateHandling>(
              groupValue: _duplicateHandling,
              onChanged: (value) {
                if (value != null) setState(() => _duplicateHandling = value);
              },
              child: Column(
                children: [
                  RadioListTile<DuplicateHandling>(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      ).screensSettingsImportDataSkipDuplicates,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context).screensSettingsImportDataSkipDescription,
                    ),
                    value: DuplicateHandling.skip,
                    secondary: const Icon(Icons.skip_next, color: Colors.blue),
                  ),
                  RadioListTile<DuplicateHandling>(
                    title: Text(
                      AppLocalizations.of(
                        context,
                      ).screensSettingsImportDataOverwriteDuplicates,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context).screensSettingsImportDataOverwriteDescription,
                    ),
                    value: DuplicateHandling.overwrite,
                    secondary: const Icon(Icons.update, color: Colors.orange),
                  ),
                ],
              ),
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
                    AppLocalizations.of(context).screensSettingsImportDataAdvancedOptions,
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
                title: Text(AppLocalizations.of(context).screensSettingsImportDataValidateBeforeImport),
                subtitle: Text(AppLocalizations.of(context).screensSettingsImportDataValidateDescription),
                value: true,
                onChanged: null, // Always enabled for now
                secondary: const Icon(Icons.verified, color: Colors.green),
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context).screensSettingsImportDataBackupBeforeImport),
                subtitle: Text(AppLocalizations.of(context).screensSettingsImportDataBackupDescription),
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
                  AppLocalizations.of(context).screensSettingsImportDataIssues,
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
                AppLocalizations.of(context).screensSettingsImportDataTechnicalDetails,
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
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.5),
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

  Widget _buildImportButton() {
    final canImport =
        _selectedFilePath != null && _selectedDataTypes.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canImport ? _performImport : null,
        icon: const Icon(Icons.file_download),
        label: Text(
          AppLocalizations.of(context).screensSettingsImportDataImportFromFile,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
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

      if (!mounted) return;
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedFilePath = file.path;
            _lastError = null;
            _importErrors.clear();
            _lastResult = null;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('ImportDataScreen: File selection failed (${e.runtimeType})');
      setState(() {
        _lastError = AppLocalizations.of(context).screensSettingsImportDataFileSelectionProblem;
      });
    }
  }

  Future<void> _performImport() async {
    if (_selectedFilePath == null || _selectedDataTypes.isEmpty) return;
    final filePath = _selectedFilePath!;
    final dataTypes = _selectedDataTypes.toList();
    final duplicateHandling = _duplicateHandling;
    final localizations = AppLocalizations.of(context);
    final confirmed = await showImportConfirmationDialog(
      context,
      sectionNames: dataTypes.map((type) => _dataTypeName(type)).toList(),
      duplicateHandlingLabel:
          duplicateHandling == DuplicateHandling.skip
              ? localizations.screensSettingsImportDataSkipDuplicates
              : localizations.screensSettingsImportDataOverwriteDuplicates,
    );
    if (!mounted || !confirmed) return;

    setState(() {
      _isImporting = true;
      _lastError = null;
      _importErrors.clear();
      _lastResult = null;
      _currentProgress = 0;
      _totalItems = 0;
      _currentType = '';
    });

    try {
      // Create backup before import
      final backupCreated =
          await _importExportService.createBackupBeforeImport();
      if (!mounted) return;
      if (!backupCreated) {
        setState(() => _isImporting = false);
        final continueWithoutBackup = await showBackupFailureDialog(context);
        if (!mounted || !continueWithoutBackup) return;
        setState(() => _isImporting = true);
      }
      final result = await _importExportService.importData(
        filePath: filePath,
        dataTypes: dataTypes,
        duplicateHandling: duplicateHandling,
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
          _lastResult = result;
        });

        if (result.success || result.isPartial) {
          // Refresh backup availability after successful import
          await _checkBackupAvailability();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result.isPartial
                      ? AppLocalizations.of(context).screensSettingsImportDataImportedSkipped(
                        result.itemsProcessed,
                        result.itemsSkipped,
                      )
                      : AppLocalizations.of(
                        context,
                      ).screensSettingsImportDataImportedItemsCount(
                        result.itemsProcessed,
                      ),
                ),
                backgroundColor: result.isPartial ? Colors.orange : Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (!result.isPartial) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.of(context).pop(true);
            });
          }
        } else {
          setState(() {
            _importErrors = result.errorCode == ImportExportErrorCode.importInvalidData
                ? result.errors
                : [];
            _lastError = _importErrorMessage(AppLocalizations.of(context), result);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('ImportDataScreen: Import failed (${e.runtimeType})');
        setState(() {
          _isImporting = false;
          _lastError = AppLocalizations.of(context).screensSettingsImportDataImportFailed;
        });
      }
    }
  }

  String _dataTypeName(DataType type) {
    final localizations = AppLocalizations.of(context);
    switch (type) {
      case DataType.dishes:
        return localizations.screensSettingsExportDataDishes;
      case DataType.mealLogs:
        return localizations.screensSettingsExportDataMealLogs;
      case DataType.userProfiles:
        return localizations.screensSettingsExportDataUserProfiles;
      case DataType.ingredients:
        return localizations.componentsChatMessageBubbleIngredients;
      case DataType.allData:
        return localizations.screensSettingsExportDataAllData;
      case DataType.supplements:
        return localizations.screensSettingsExportDataSupplements;
      case DataType.fitnessGoals:
        return localizations.screensSettingsExportDataNutritionGoalsData;
    }
  }

  Widget _buildBackupCard() {
    if (!_hasBackupAvailable || _backupInfo == null) {
      return const SizedBox.shrink();
    }

    final locale = Localizations.localeOf(context).toString();
    final backupDate = _backupInfo!['date'] as DateTime;
    final backupSize = _backupInfo!['size'] as int;
    final formattedSize = formatDecimal(backupSize / 1024, locale);

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
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).screensSettingsImportDataBackupAvailable,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).screensSettingsImportDataBackupAvailableDescription,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).screensSettingsImportDataBackupCreated(_formatDate(backupDate)),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.storage, size: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).screensSettingsImportDataBackupSize(formattedSize),
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSecondaryContainer),
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
                label: Text(
                  AppLocalizations.of(context).screensSettingsImportDataUndoLastImport,
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
      return AppLocalizations.of(context).screensSettingsHealthSettingsJustNow;
    } else if (difference.inHours < 1) {
      return AppLocalizations.of(context).screensSettingsImportDataMinutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return AppLocalizations.of(context).screensSettingsImportDataHoursAgo(difference.inHours);
    } else {
      return AppLocalizations.of(context).screensSettingsImportDataDaysAgo(difference.inDays);
    }
  }

  Future<void> _performRestore() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).screensSettingsImportDataRestoreTitle),
            content: Text(
              AppLocalizations.of(context).screensSettingsImportDataRestoreWarning,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context).screensSettingsProfileSettingsResetAppCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: Text(AppLocalizations.of(context).screensSettingsImportDataRestoreAction),
              ),
            ],
          ),
    );

    if (!mounted || confirmed != true) return;

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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).screensSettingsImportDataRestoreSuccess),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // Close the screen after successful restore
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.of(context).pop(true);
          });
        } else {
          setState(() {
            _lastError = _importErrorMessage(AppLocalizations.of(context), result);
            _importErrors = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('ImportDataScreen: Restore failed (${e.runtimeType})');
        setState(() {
          _isRestoring = false;
          _lastError = AppLocalizations.of(context).screensSettingsImportDataRestoreProblem;
        });
      }
    }
  }
}

/// Summarizes an import without hiding skipped items or their reasons.
class ImportResultsCard extends StatelessWidget {
  const ImportResultsCard({super.key, required this.result});

  final ImportExportResult result;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isPartial = result.isPartial;
    final details = result.detailedResults;
    final reasons = <String>{
      ...?details?.parsingErrors.map((error) => error.error),
      ...?details?.validationErrors.map((error) => error.error),
      ...?details?.processingErrors.map((error) => error.error),
      ...result.errors,
      ...result.failedSections.map(
        (section) => localizations.screensSettingsImportDataFailedSection(section),
      ),
    }.toList();
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        isPartial
            ? colorScheme.onTertiaryContainer
            : colorScheme.onPrimaryContainer;

    return Card(
      elevation: 2,
      color:
          isPartial ? colorScheme.tertiaryContainer : colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPartial ? Icons.warning_amber_rounded : Icons.check_circle,
                  color: foregroundColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPartial
                        ? localizations.screensSettingsImportDataPartialResults
                        : localizations.screensSettingsImportDataResults,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isPartial) ...[
              Text(
                localizations.screensSettingsImportDataImportedSkipped(
                  result.itemsProcessed,
                  result.itemsSkipped,
                ),
              ),
              if (reasons.isNotEmpty)
                ExpansionTile(
                  title: Text(localizations.screensSettingsImportDataShowReasons),
                  children: [
                    Text(localizations.screensSettingsImportDataTechnicalDetails),
                    for (final reason in reasons)
                      ListTile(dense: true, title: Text(reason)),
                    if ((details?.omittedErrors ?? 0) > 0)
                      ListTile(
                        dense: true,
                        title: Text(
                          localizations.screensSettingsImportDataMoreReasons(
                            details!.omittedErrors,
                          ),
                        ),
                      ),
                  ],
                ),
            ] else if (!result.success)
              Text(_importErrorMessage(localizations, result))
            else
              Text(
                localizations.screensSettingsImportDataImportedItemsCount(
                  result.itemsProcessed,
                ),
              ),
            if (details?.fileInfo != null)
              Text(
                localizations.screensSettingsExportDataFileLabel(
                  details!.fileInfo!.fileName,
                ),
              ),
            for (final entry in details?.summary.entries ?? <MapEntry<String, TypeSummary>>[])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text('${entry.value.processed}/${entry.value.total}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Confirms the sections and duplicate strategy before any data is written.
Future<bool> showImportConfirmationDialog(
  BuildContext context, {
  required List<String> sectionNames,
  required String duplicateHandlingLabel,
}) async {
  final localizations = AppLocalizations.of(context);
  return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.screensSettingsImportDataConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.screensSettingsImportDataSelectedSections),
            for (final section in sectionNames) Text(section),
            const SizedBox(height: 12),
            Text(localizations.screensSettingsImportDataDuplicatesLabel(duplicateHandlingLabel)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.screensSettingsProfileSettingsResetAppCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.screensSettingsImportDataConfirmAction),
          ),
        ],
      ),
    ) ?? false;
  }

/// Requires explicit consent when a safety backup could not be created.
Future<bool> showBackupFailureDialog(BuildContext context) async {
  final localizations = AppLocalizations.of(context);
  return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.screensSettingsImportDataBackupFailedTitle),
        content: Text(
          localizations.screensSettingsImportDataBackupFailedDescription,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.screensSettingsProfileSettingsResetAppCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.screensSettingsImportDataContinueWithoutBackup),
          ),
        ],
      ),
    ) ?? false;
  }
