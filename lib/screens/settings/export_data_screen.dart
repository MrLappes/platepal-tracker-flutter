import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/data/import_export_service.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final ImportExportService _importExportService = ImportExportService();

  bool _isExporting = false;
  final Set<DataType> _selectedDataTypes = {DataType.dishes};
  ExportFormat _selectedFormat = ExportFormat.json;
  String? _lastExportPath;
  String? _lastError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.exportData)),
      body:
          _isExporting
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.exportProgress),
                  ],
                ),
              )
              : _buildExportForm(),
    );
  }

  Widget _buildExportForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.selectDataToExport,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildDataTypeCheckbox(DataType.dishes),
                _buildDataTypeCheckbox(DataType.mealLogs),
                _buildDataTypeCheckbox(DataType.userProfiles),
                _buildDataTypeCheckbox(DataType.ingredients),
                _buildDataTypeCheckbox(DataType.supplements),
                _buildDataTypeCheckbox(DataType.fitnessGoals),
                const Divider(),
                _buildDataTypeCheckbox(DataType.allData),
                const SizedBox(height: 24),
                Text(
                  'Export Format',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioListTile<ExportFormat>(
                  title: Text(AppLocalizations.of(context)!.exportAsJson),
                  value: ExportFormat.json,
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                ),
                RadioListTile<ExportFormat>(
                  title: Text(AppLocalizations.of(context)!.exportAsCsv),
                  value: ExportFormat.csv,
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_lastError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _lastError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
          if (_lastExportPath != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Exported to: $_lastExportPath',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedDataTypes.isEmpty ? null : _exportData,
              child: Text(AppLocalizations.of(context)!.exportData),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypeCheckbox(DataType dataType) {
    String title;
    switch (dataType) {
      case DataType.dishes:
        title = AppLocalizations.of(context)!.dishes;
        break;
      case DataType.mealLogs:
        title = AppLocalizations.of(context)!.mealLogs;
        break;
      case DataType.userProfiles:
        title = AppLocalizations.of(context)!.userProfiles;
        break;
      case DataType.ingredients:
        title = AppLocalizations.of(context)!.ingredients;
        break;
      case DataType.supplements:
        title = AppLocalizations.of(context)!.supplements;
        break;
      case DataType.fitnessGoals:
        title = AppLocalizations.of(context)!.nutritionGoalsData;
        break;
      case DataType.allData:
        title = AppLocalizations.of(context)!.allData;
        break;
    }

    return CheckboxListTile(
      title: Text(title),
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
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _lastError = null;
      _lastExportPath = null;
    });

    try {
      final result = await _importExportService.exportData(
        dataTypes: _selectedDataTypes.toList(),
        format: _selectedFormat,
      );

      if (mounted) {
        setState(() {
          _isExporting = false;
          if (result.success) {
            _lastExportPath = result.message;
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
