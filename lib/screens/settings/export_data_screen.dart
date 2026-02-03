import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../services/data/import_export_service.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final ImportExportService _importExportService = ImportExportService();

  bool _isExporting = false;
  final Set<DataType> _selectedDataTypes = {DataType.dishes, DataType.mealLogs};
  ExportFormat _selectedFormat = ExportFormat.json;
  String? _lastExportPath;
  String? _lastError;
  ImportExportResult? _lastResults;
  bool _showAdvancedOptions = false;
  bool _createBackup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context).screensMenuExportData.toUpperCase()} //',
        ),
      ),
      body: _isExporting ? _buildLoadingView() : _buildExportForm(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(
              context,
            ).screensSettingsExportDataExportProgress,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Preparing your data...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_lastResults != null) ...[
            _buildResultsCard(),
            const SizedBox(height: 16),
          ],
          if (_lastError != null) ...[
            _buildErrorCard(),
            const SizedBox(height: 16),
          ],
          _buildExportPreviewCard(),
          const SizedBox(height: 16),
          _buildDataTypeSelectionCard(),
          const SizedBox(height: 16),
          _buildFormatSelectionCard(),
          const SizedBox(height: 16),
          _buildAdvancedOptionsCard(),
          const SizedBox(height: 24),
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildExportPreviewCard() {
    final selectedCount = _selectedDataTypes.length;
    final formatName = _selectedFormat == ExportFormat.json ? 'JSON' : 'CSV';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.preview, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Export Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Format: $formatName',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.folder,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Data types: $selectedCount selected',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ready to export',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
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
                  AppLocalizations.of(
                    context,
                  ).screensSettingsExportDataSelectDataToExport,
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
            _buildDataTypeCheckbox(
              DataType.supplements,
              Icons.medication,
              Colors.teal,
            ),
            _buildDataTypeCheckbox(
              DataType.fitnessGoals,
              Icons.fitness_center,
              Colors.red,
            ),
            const Divider(height: 24),
            _buildDataTypeCheckbox(
              DataType.allData,
              Icons.select_all,
              Colors.deepPurple,
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
        subtitle = 'Your saved recipes and dishes';
        break;
      case DataType.mealLogs:
        title = AppLocalizations.of(context).screensSettingsExportDataMealLogs;
        subtitle = 'Your meal history and nutrition logs';
        break;
      case DataType.userProfiles:
        title =
            AppLocalizations.of(context).screensSettingsExportDataUserProfiles;
        subtitle = 'User profile and preferences';
        break;
      case DataType.ingredients:
        title =
            AppLocalizations.of(context).componentsChatMessageBubbleIngredients;
        subtitle = 'Ingredient database';
        break;
      case DataType.supplements:
        title =
            AppLocalizations.of(context).screensSettingsExportDataSupplements;
        subtitle = 'Supplement tracking data';
        break;
      case DataType.fitnessGoals:
        title =
            AppLocalizations.of(
              context,
            ).screensSettingsExportDataNutritionGoalsData;
        subtitle = 'Fitness and nutrition goals';
        break;
      case DataType.allData:
        title = AppLocalizations.of(context).screensSettingsExportDataAllData;
        subtitle = 'Export everything from your account';
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

  Widget _buildFormatSelectionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Export Format',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RadioListTile<ExportFormat>(
              title: Text(
                AppLocalizations.of(
                  context,
                ).screensSettingsExportDataExportAsJson,
              ),
              subtitle: const Text('Structured data format, best for backup'),
              value: ExportFormat.json,
              groupValue: _selectedFormat,
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              secondary: const Icon(Icons.code, color: Colors.blue),
            ),
            RadioListTile<ExportFormat>(
              title: Text(
                AppLocalizations.of(
                  context,
                ).screensSettingsExportDataExportAsCsv,
              ),
              subtitle: const Text('Spreadsheet format, good for analysis'),
              value: ExportFormat.csv,
              groupValue: _selectedFormat,
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              secondary: const Icon(Icons.table_chart, color: Colors.green),
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
                title: const Text('Create backup before export'),
                subtitle: const Text('Automatically backup data during export'),
                value: _createBackup,
                onChanged: (value) {
                  setState(() {
                    _createBackup = value;
                  });
                },
                secondary: const Icon(Icons.backup, color: Colors.blue),
              ),
              SwitchListTile(
                title: const Text('Validate data during export'),
                subtitle: const Text('Check data integrity while exporting'),
                value: true,
                onChanged: null, // Always enabled for now
                secondary: const Icon(Icons.verified, color: Colors.green),
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
                  'Export Error',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _lastError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
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
                  'Export Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lastExportPath != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'File: ${_lastExportPath!.split('/').last}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.folder,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location: ${_lastExportPath!}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items Exported:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_lastResults!.itemsProcessed}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareExportedFile(),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showExportLocationDialog(),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Show in Files'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    final canExport = _selectedDataTypes.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canExport ? _exportData : null,
        icon: const Icon(Icons.file_upload),
        label: Text(
          AppLocalizations.of(context).screensMenuExportData,
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

  void _showExportLocationDialog() {
    if (_lastExportPath == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your exported file is located at:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    _lastExportPath!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ],
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

  Future<void> _shareExportedFile() async {
    if (_lastExportPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file to share. Please export data first.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final file = File(_lastExportPath!);
      if (await file.exists()) {
        final fileName = _lastExportPath!.split('/').last;
        await Share.shareXFiles(
          [XFile(_lastExportPath!)],
          text: 'PlatePal Data Export - $fileName',
          subject: 'PlatePal Data Export',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export file not found. Please export data again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share file: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _lastError = null;
      _lastExportPath = null;
      _lastResults = null;
    });

    try {
      final result = await _importExportService.exportData(
        dataTypes: _selectedDataTypes.toList(),
        format: _selectedFormat,
      );

      if (mounted) {
        setState(() {
          _isExporting = false;
          _lastResults = result;
          if (result.success) {
            // Extract the file path from the success message
            final message = result.message;
            final pathMatch = RegExp(r'to (.+)$').firstMatch(message);
            if (pathMatch != null) {
              _lastExportPath = pathMatch.group(1);
            } else {
              _lastExportPath = 'Export completed successfully';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  ).screensSettingsExportDataExportedItemsCount(
                    result.itemsProcessed,
                  ),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            _lastError = result.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _lastError = e.toString();
        });
      }
    }
  }
}
