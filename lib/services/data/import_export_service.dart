import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/dish_service.dart';
import '../storage/meal_log_service.dart';
import '../storage/database_service.dart';
import '../../models/dish.dart';

enum DataType {
  userProfiles,
  dishes,
  mealLogs,
  ingredients,
  supplements,
  fitnessGoals,
  allData,
}

enum ExportFormat { json, csv }

enum DuplicateHandling { skip, overwrite, merge }

class ImportExportService {
  final DishService _dishService = DishService();
  final MealLogService _mealLogService = MealLogService();

  Future<ImportExportResult> exportData({
    required List<DataType> dataTypes,
    required ExportFormat format,
  }) async {
    try {
      final exportData = <String, dynamic>{};
      int itemsProcessed = 0;

      for (final type in dataTypes) {
        try {
          final data = await _exportDataType(type);
          if (type == DataType.allData) {
            if (data is Map<String, dynamic>) {
              exportData.addAll(data);
              // Calculate total items from all data types
              for (final entry in data.entries) {
                if (entry.value is List) {
                  itemsProcessed += (entry.value as List).length;
                }
              }
            }
          } else {
            exportData[type.name] = data;
            if (data is List) {
              itemsProcessed += data.length;
            }
          }
        } catch (e) {
          print('Error exporting ${type.name}: $e');
          return ImportExportResult(
            success: false,
            message: 'Failed to export ${type.name}: $e',
            itemsProcessed: 0,
            duplicatesFound: 0,
            errors: ['Export error for ${type.name}: $e'],
          );
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'platepal_export_$timestamp.${format.name}';
      final file = File('${directory.path}/$filename');

      if (format == ExportFormat.json) {
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(exportData),
        );
      } else {
        final csvData = _convertToCSV(exportData);
        await file.writeAsString(csvData);
      }

      print('Export successful: ${file.path} ($itemsProcessed items)');
      return ImportExportResult(
        success: true,
        message: 'Data exported successfully to ${file.path}',
        itemsProcessed: itemsProcessed,
        duplicatesFound: 0,
        errors: [],
      );
    } catch (e) {
      print('Export failed: $e');
      return ImportExportResult(
        success: false,
        message: 'Export failed: $e',
        itemsProcessed: 0,
        duplicatesFound: 0,
        errors: [e.toString()],
      );
    }
  }

  Future<ImportExportResult> importData({
    required String filePath,
    required List<DataType> dataTypes,
    required DuplicateHandling duplicateHandling,
    Map<String, dynamic>? jsonData,
    Function(int current, int total, String currentType)? onProgress,
  }) async {
    try {
      Map<String, dynamic> importData;
      final detailedResults = ImportDetailedResults();

      if (jsonData != null) {
        importData = jsonData;
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('File not found');
        }

        final content = await file.readAsString();
        detailedResults.setFileInfo(
          FileInfo(
            fileName: file.path.split('/').last,
            fileSize: content.length,
            totalLines: content.split('\n').length,
          ),
        );

        if (filePath.endsWith('.json')) {
          try {
            importData = json.decode(content) as Map<String, dynamic>;
          } catch (e) {
            detailedResults.parsingErrors.add(
              ParsingError(
                line: _findJsonErrorLine(content, e.toString()),
                column: 0,
                error: 'JSON parsing failed: ${e.toString()}',
                context: _getContextLines(
                  content,
                  _findJsonErrorLine(content, e.toString()),
                ),
              ),
            );
            throw Exception('JSON parsing failed: $e');
          }
        } else if (filePath.endsWith('.csv')) {
          final csvResult = _convertFromCSVWithErrors(content);
          importData = csvResult.data;
          detailedResults.parsingErrors.addAll(csvResult.errors);
        } else {
          throw Exception('Unsupported file format');
        }
      }

      // Validate data integrity
      final validationResult = _validateImportData(importData);
      if (!validationResult.isValid) {
        detailedResults.validationErrors.addAll(
          validationResult.errors.map(
            (error) =>
                ValidationError(field: 'general', error: error, value: ''),
          ),
        );
      }

      // Transform data for backward compatibility
      importData = _transformBackwardCompatibility(importData);
      int totalProcessed = 0;
      int totalDuplicates = 0;
      final errors = <String>[];

      // Sort data types by dependency order to ensure dishes are imported before meal logs
      final sortedDataTypes = _sortDataTypesByDependency(dataTypes);

      // Calculate total items for progress tracking
      int totalItems = 0;
      int currentProgress = 0;
      for (final type in sortedDataTypes) {
        final items = _getItemsForDataType(type, importData);
        totalItems += items.length;
      }

      for (final type in sortedDataTypes) {
        final result = await _importDataTypeDetailed(
          type,
          importData,
          duplicateHandling,
          detailedResults,
        );
        totalProcessed += result.itemsProcessed;
        totalDuplicates += result.duplicatesFound;
        errors.addAll(result.errors);

        currentProgress += result.itemsProcessed;
        onProgress?.call(currentProgress, totalItems, type.name);
      }

      return ImportExportResult(
        success: errors.isEmpty && detailedResults.parsingErrors.isEmpty,
        message: 'Import completed. Processed $totalProcessed items.',
        itemsProcessed: totalProcessed,
        duplicatesFound: totalDuplicates,
        errors: errors,
        detailedResults: detailedResults,
      );
    } catch (e) {
      return ImportExportResult(
        success: false,
        message: 'Import failed: $e',
        itemsProcessed: 0,
        duplicatesFound: 0,
        errors: [e.toString()],
        detailedResults: ImportDetailedResults(),
      );
    }
  }

  /// Simple import from file method for backward compatibility
  Future<ImportResult> importFromFile(String filePath) async {
    try {
      final result = await importData(
        filePath: filePath,
        dataTypes: [DataType.dishes, DataType.mealLogs, DataType.userProfiles],
        duplicateHandling: DuplicateHandling.overwrite,
      );

      return ImportResult(
        success: result.success,
        itemsProcessed: result.itemsProcessed,
        duplicatesFound: result.duplicatesFound,
        errors: result.errors,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        itemsProcessed: 0,
        duplicatesFound: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Save valid items only (for error recovery)
  Future<ImportResult> saveValidItemsOnly() async {
    try {
      // This would save previously validated items
      // For now, return a success result
      return ImportResult(
        success: true,
        itemsProcessed: 0,
        duplicatesFound: 0,
        errors: [],
      );
    } catch (e) {
      return ImportResult(
        success: false,
        itemsProcessed: 0,
        duplicatesFound: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Process meal logs from import data
  Future<ImportExportResult> _processMealLogs(Map<String, dynamic> data) async {
    final List<String> errors = [];
    int itemsProcessed = 0;
    int duplicatesFound = 0; // Processing meal logs from import data

    if (data.containsKey('mealLogs')) {
      final mealLogsData = data['mealLogs'] as List<dynamic>? ?? [];
      // Found ${mealLogsData.length} meal logs to process
      for (int i = 0; i < mealLogsData.length; i++) {
        try {
          final mealLogData = mealLogsData[i];
          // Processing raw meal log data [$i]: $mealLogData

          if (mealLogData is Map<String, dynamic>) {
            final convertedMealLog = _createMealLogFromImportData(mealLogData);
            // Converted meal log data [$i]: $convertedMealLog            // Processing meal log $i: ${convertedMealLog['dishId']}

            final success = await _saveMealLogFromImport(convertedMealLog);
            if (success) {
              itemsProcessed++;
              // Meal log $i processed successfully
            } else {
              final errorMsg =
                  'Failed to save meal log for dish ${convertedMealLog['dishId']}';
              errors.add(errorMsg);
              debugPrint('❌ $errorMsg');
            }
          } else {
            final errorMsg = 'Invalid meal log format at index $i';
            errors.add(errorMsg);
            debugPrint('❌ $errorMsg');
          }
        } catch (e) {
          final errorMsg = 'Error processing meal log item at index $i: $e';
          errors.add(errorMsg);
          debugPrint('❌ $errorMsg');
        }
      }
    } else {
      debugPrint('⚠️ No mealLogs found in import data');
    } // Meal log processing complete: $itemsProcessed processed, ${errors.length} errors

    return ImportExportResult(
      success: errors.isEmpty,
      message: 'Processed $itemsProcessed meal logs',
      itemsProcessed: itemsProcessed,
      duplicatesFound: duplicatesFound,
      errors: errors,
    );
  }

  /// Save meal log from import data
  Future<bool> _saveMealLogFromImport(Map<String, dynamic> mealLogData) async {
    try {
      // Attempting to save meal log: ${mealLogData}

      // Ensure we have a valid dish ID
      final dishId = mealLogData['dishId'] as String?;
      if (dishId == null || dishId.isEmpty) {
        debugPrint('❌ Invalid dish ID for meal log: $dishId');
        return false;
      }

      // Check if the dish exists
      final dish = await _dishService.getDishById(dishId);
      if (dish == null) {
        debugPrint('❌ Dish not found for meal log: $dishId');
        return false;
      }

      // Parse the logged date
      DateTime loggedAt;
      try {
        loggedAt = DateTime.parse(mealLogData['loggedAt'] as String);
      } catch (e) {
        debugPrint('❌ Invalid date format: ${mealLogData['loggedAt']}');
        loggedAt = DateTime.now();
      }

      final servingSize =
          (mealLogData['servingSize'] as num?)?.toDouble() ?? 1.0;
      final mealType = mealLogData['mealType'] as String? ?? 'lunch';
      final userId = mealLogData['userId'] as String? ?? 'default_user';

      // Save to meal_logs table (traditional meal logging)
      final mealLogId = await _mealLogService.logMeal(
        userId: userId,
        dishId: dishId,
        servingSize: servingSize,
        mealType: mealType,
        loggedAt: loggedAt,
      );

      // Also save to dish_logs table (for calendar display)
      await _dishService.logDish(
        dishId: dishId,
        loggedAt: loggedAt,
        mealType: mealType,
        servingSize: servingSize,
      );

      // Meal log saved to both tables with ID: $mealLogId
      return mealLogId > 0;
    } catch (e) {
      debugPrint('❌ Error saving meal log: $e');
      return false;
    }
  }

  Map<String, dynamic> _createMealLogFromImportData(Map<String, dynamic> data) {
    // Parse and validate meal type with fallback to "lunch"
    String mealType = _parseMealType(data['mealType'] ?? data['meal_type']);

    // Ensure we have a valid dish ID
    String dishId = data['dishId'] ?? data['dish_id'] ?? '';
    if (dishId.isEmpty) {
      throw Exception('Dish ID is required for meal log');
    }

    // Parse serving size with validation
    double servingSize = 1.0;
    final servingSizeRaw = data['servingSize'] ?? data['serving_size'];
    if (servingSizeRaw != null) {
      servingSize = _safeParseDouble(servingSizeRaw) ?? 1.0;
    } // Parse logged date with fallback
    // Check multiple possible date field names from different database structures
    String loggedAt;
    final loggedAtRaw = data['loggedAt'] ?? data['logged_at'] ?? data['date'];
    if (loggedAtRaw != null) {
      try {
        // Handle different date formats from old database structure
        String dateString = loggedAtRaw.toString();

        // If it's just a date (YYYY-MM-DD), convert to full ISO string
        if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
          dateString = '${dateString}T12:00:00.000Z';
        }

        // Validate and parse the date
        DateTime parsedDate = DateTime.parse(dateString);
        loggedAt = parsedDate.toIso8601String();

        debugPrint(
          '📅 Preserved original date: $loggedAt from raw: $loggedAtRaw',
        );
      } catch (e) {
        debugPrint(
          '⚠️ Failed to parse date $loggedAtRaw, using current date: $e',
        );
        loggedAt = DateTime.now().toIso8601String();
      }
    } else {
      debugPrint('⚠️ No date field found in import data, using current date');
      loggedAt = DateTime.now().toIso8601String();
    }

    return {
      'id': data['id'] ?? _generateId(),
      'userId': data['userId'] ?? data['user_id'] ?? 'default_user',
      'dishId': dishId,
      'servingSize': servingSize,
      'mealType': mealType,
      'loggedAt': loggedAt,
    };
  }

  /// Parses meal type and returns a valid value or defaults to "lunch"
  String _parseMealType(dynamic value) {
    if (value == null) return 'lunch';
    final type = value.toString().toLowerCase();
    const validTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    if (validTypes.contains(type)) {
      return type;
    }
    return 'lunch';
  }

  Future<dynamic> _exportDataType(DataType type) async {
    try {
      switch (type) {
        case DataType.userProfiles:
          // TODO: Implement user profiles export when service is available
          return <Map<String, dynamic>>[];
        case DataType.mealLogs:
          try {
            // Get all meal logs from both tables
            final mealLogs = await _getAllMealLogs();
            final dishLogs = await _getAllDishLogs();

            // Combine and format for export
            final allLogs = <Map<String, dynamic>>[];

            // Add meal_logs entries
            allLogs.addAll(
              mealLogs.map(
                (log) => {
                  'id': log['id'].toString(),
                  'userId': log['user_id'],
                  'dishId': log['dish_id'],
                  'servingSize': log['serving_size'],
                  'mealType': log['meal_type'],
                  'loggedAt': log['logged_at'],
                  'source': 'meal_logs',
                },
              ),
            );

            // Add dish_logs entries
            allLogs.addAll(
              dishLogs.map(
                (log) => {
                  'id': log['id'],
                  'dishId': log['dish_id'],
                  'servingSize': log['serving_size'],
                  'mealType': log['meal_type'],
                  'loggedAt': log['logged_at'],
                  'calories': log['calories'],
                  'protein': log['protein'],
                  'carbs': log['carbs'],
                  'fat': log['fat'],
                  'fiber': log['fiber'],
                  'source': 'dish_logs',
                },
              ),
            );

            return allLogs;
          } catch (e) {
            throw Exception('Failed to retrieve meal logs: $e');
          }
        case DataType.dishes:
          try {
            final dishes = await _dishService.getAllDishes();
            return dishes.map((dish) => dish.toJson()).toList();
          } catch (e) {
            throw Exception('Failed to retrieve dishes: $e');
          }
        case DataType.ingredients:
          // TODO: Implement ingredients export when service is available
          return <Map<String, dynamic>>[];
        case DataType.supplements:
          // TODO: Implement supplements export when service is available
          return <Map<String, dynamic>>[];
        case DataType.fitnessGoals:
          // TODO: Implement fitness goals export when service is available
          return <Map<String, dynamic>>[];
        case DataType.allData:
          final allData = <String, dynamic>{};
          for (final dataType in DataType.values) {
            if (dataType != DataType.allData) {
              try {
                final data = await _exportDataType(dataType);
                allData[dataType.name] = data;
              } catch (e) {
                // Continue with other data types even if one fails
                allData[dataType.name] = <Map<String, dynamic>>[];
              }
            }
          }
          return allData;
      }
    } catch (e) {
      rethrow;
    }
  }

  int _findJsonErrorLine(String content, String error) {
    // Extract line number from JSON error message
    final lineMatch = RegExp(r'line (\d+)').firstMatch(error);
    if (lineMatch != null) {
      return int.parse(lineMatch.group(1)!);
    }
    // Try to find the line number in position-based error
    final positionMatch = RegExp(r'position (\d+)').firstMatch(error);
    if (positionMatch != null) {
      final position = int.parse(positionMatch.group(1)!);
      final lines = content.substring(0, position).split('\n');
      return lines.length;
    }
    return 1;
  }

  List<String> _getContextLines(String content, int errorLine) {
    final lines = content.split('\n');
    final start = (errorLine - 10).clamp(0, lines.length);
    final end = (errorLine + 10).clamp(0, lines.length);

    final context = <String>[];
    for (int i = start; i < end; i++) {
      final lineNumber = i + 1;
      final prefix = lineNumber == errorLine ? '>>> ' : '    ';
      context.add('$prefix$lineNumber: ${lines[i]}');
    }

    return context;
  }

  DataValidationResult _validateImportData(Map<String, dynamic> data) {
    final errors = <String>[];

    // Check for malicious patterns
    final jsonString = json.encode(data);
    if (jsonString.contains('<script>') ||
        jsonString.contains('javascript:') ||
        jsonString.contains('eval(')) {
      errors.add('Potentially malicious content detected');
    }

    // Validate data structure
    for (final entry in data.entries) {
      if (entry.value is List) {
        final list = entry.value as List;
        if (list.length > 10000) {
          errors.add('${entry.key} contains too many items (${list.length})');
        }
      }
    }

    return DataValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  Map<String, dynamic> _transformBackwardCompatibility(
    Map<String, dynamic> data,
  ) {
    final transformed = Map<String, dynamic>.from(data);

    // Handle old format where dishLogs was used instead of mealLogs
    if (data.containsKey('dishLogs') && !data.containsKey('mealLogs')) {
      transformed['mealLogs'] = data['dishLogs'];
    }

    // Handle single dish JSON format
    if (data.containsKey('name') &&
        data.containsKey('calories') &&
        !data.containsKey('dishes')) {
      transformed['dishes'] = [data];
    }

    // Handle old userProfile format (singular vs plural)
    if (data.containsKey('userProfile') && !data.containsKey('userProfiles')) {
      transformed['userProfiles'] = [data['userProfile']];
    }

    return transformed;
  }

  String _getItemIdentifier(DataType type, dynamic item) {
    if (item is! Map<String, dynamic>) return 'unknown';

    final map = item;

    switch (type) {
      case DataType.dishes:
        return map['name']?.toString() ??
            map['id']?.toString() ??
            'unnamed dish';
      case DataType.userProfiles:
        return map['email']?.toString() ?? map['name']?.toString() ?? 'user';
      default:
        return map['id']?.toString() ?? map['name']?.toString() ?? 'item';
    }
  }

  /// Enhanced import data type processing for meal logs
  Future<ImportExportResult> _importDataTypeDetailed(
    DataType type,
    Map<String, dynamic> data,
    DuplicateHandling duplicateHandling,
    ImportDetailedResults detailedResults,
  ) async {
    try {
      // Processing data type: ${type.name}

      // Special handling for meal logs
      if (type == DataType.mealLogs) {
        return await _processMealLogs(data);
      }

      List<dynamic> items = [];

      // Handle different data structures based on type
      switch (type) {
        case DataType.dishes:
          items = _extractDishesFromData(data);
          break;
        case DataType.mealLogs:
          items = _extractMealLogsFromData(data);
          break;
        case DataType.userProfiles:
          items = _extractUserProfilesFromData(data);
          break;
        default:
          items = data[type.name] as List<dynamic>? ?? [];
          break;
      }

      // Found ${items.length} items to process for ${type.name}

      int processed = 0;
      int duplicates = 0;
      int skipped = 0;
      final errors = <String>[];

      for (int index = 0; index < items.length; index++) {
        final item = items[index];
        try {
          final itemValidation = _validateItem(type, item, index);
          if (itemValidation.isNotEmpty) {
            detailedResults.validationErrors.addAll(itemValidation);
            skipped++;
            continue;
          }

          final exists = await _checkIfExists(type, item);

          if (exists) {
            final duplicate = DuplicateItem(
              type: type.name,
              index: index,
              identifier: _getItemIdentifier(type, item),
              action: duplicateHandling.name,
            );
            detailedResults.duplicates.add(duplicate);

            if (duplicateHandling == DuplicateHandling.skip) {
              duplicates++;
              continue;
            }
          }

          await _saveItem(type, item, duplicateHandling);
          processed++;

          detailedResults.processedItems.add(
            ProcessedItem(
              type: type.name,
              index: index,
              identifier: _getItemIdentifier(type, item),
              action: exists ? 'updated' : 'created',
            ),
          );
        } catch (e) {
          final error =
              'Error processing ${type.name} item at index $index: $e';
          errors.add(error);
          detailedResults.processingErrors.add(
            ProcessingError(
              type: type.name,
              index: index,
              error: e.toString(),
              item: item.toString(),
            ),
          );
          skipped++;
        }
      }

      detailedResults.summary[type.name] = TypeSummary(
        total: items.length,
        processed: processed,
        duplicates: duplicates,
        skipped: skipped,
        errors: errors.length,
      ); // ${type.name} processing complete: $processed processed, ${errors.length} errors

      return ImportExportResult(
        success: errors.isEmpty,
        message: 'Processed $processed ${type.name} items',
        itemsProcessed: processed,
        duplicatesFound: duplicates,
        errors: errors,
      );
    } catch (e) {
      debugPrint('❌ Error importing ${type.name}: $e');
      return ImportExportResult(
        success: false,
        message: 'Failed to import ${type.name}: $e',
        itemsProcessed: 0,
        duplicatesFound: 0,
        errors: [e.toString()],
      );
    }
  }

  List<dynamic> _extractDishesFromData(Map<String, dynamic> data) {
    // _extractDishesFromData: Analyzing import data structure
    // Available top-level keys: ${data.keys.toList()}

    // Check if it's the new format first
    if (data.containsKey('dishes') && data['dishes'] is List) {
      final dishes =
          data['dishes']
              as List<
                dynamic
              >; // Found dishes array with ${dishes.length} items (new format)
      return dishes;
    }

    // Check if it's a single dish (old format)
    if (data.containsKey('name') && data.containsKey('calories')) {
      // Found single dish data (old format)
      return [_convertOldDishFormat(data)];
    }

    // Check if it's the old React Native export format with table data
    if (data.containsKey('dishes') && data['dishes'] is Map) {
      final dishesTable = data['dishes'] as Map<String, dynamic>;
      // Found dishes table, keys: ${dishesTable.keys.toList()}

      if (dishesTable.containsKey('data') && dishesTable['data'] is List) {
        final dishes = <Map<String, dynamic>>[];
        final dishRows = dishesTable['data'] as List<dynamic>;
        // Found ${dishRows.length} dish rows in table format

        for (final row in dishRows) {
          if (row is Map<String, dynamic>) {
            dishes.add(_convertOldDishFormat(row));
          }
        }

        // Also handle ingredients if they exist
        if (data.containsKey('ingredients') && data['ingredients'] is Map) {
          final ingredientsTable = data['ingredients'] as Map<String, dynamic>;
          if (ingredientsTable.containsKey('data') &&
              ingredientsTable['data'] is List) {
            final ingredientRows =
                ingredientsTable['data']
                    as List<
                      dynamic
                    >; // Found ${ingredientRows.length} ingredient rows, attaching to dishes
            _attachIngredientsTooDishes(dishes, ingredientRows);
          }
        }

        // Returning ${dishes.length} converted dishes
        return dishes;
      }
    }

    debugPrint('❌ No dishes found in data structure');
    debugPrint('❌ Data structure: ${data.toString().substring(0, 500)}...');
    return [];
  }

  List<dynamic> _extractMealLogsFromData(Map<String, dynamic> data) {
    // Check new format first
    if (data.containsKey('mealLogs') && data['mealLogs'] is List) {
      return data['mealLogs'] as List<dynamic>;
    }

    // Check old format (dishLogs)
    if (data.containsKey('dishLogs')) {
      if (data['dishLogs'] is List) {
        return (data['dishLogs'] as List<dynamic>)
            .map((log) => _convertOldMealLogFormat(log))
            .toList();
      } else if (data['dishLogs'] is Map) {
        final dishLogsTable = data['dishLogs'] as Map<String, dynamic>;
        if (dishLogsTable.containsKey('data') &&
            dishLogsTable['data'] is List) {
          return (dishLogsTable['data'] as List<dynamic>)
              .map((log) => _convertOldMealLogFormat(log))
              .toList();
        }
      }
    }

    // Check old React Native table format
    if (data.containsKey('dish_logs') && data['dish_logs'] is Map) {
      final dishLogsTable = data['dish_logs'] as Map<String, dynamic>;
      if (dishLogsTable.containsKey('data') && dishLogsTable['data'] is List) {
        return (dishLogsTable['data'] as List<dynamic>)
            .map((log) => _convertOldMealLogFormat(log))
            .toList();
      }
    }

    return [];
  }

  /// Converts an old meal log format to the new format
  Map<String, dynamic> _convertOldMealLogFormat(dynamic oldLog) {
    if (oldLog is! Map<String, dynamic>) return {};

    // Attempt to map old keys to new keys
    return {
      'id': oldLog['id'] ?? _generateId(),
      'userId': oldLog['userId'] ?? oldLog['user_id'] ?? 'default_user',
      'dishId': oldLog['dishId'] ?? oldLog['dish_id'] ?? '',
      'servingSize':
          _safeParseDouble(oldLog['servingSize'] ?? oldLog['serving_size']) ??
          1.0,
      'mealType': oldLog['mealType'] ?? oldLog['meal_type'] ?? 'lunch',
      'loggedAt':
          oldLog['loggedAt'] ??
          oldLog['logged_at'] ??
          DateTime.now().toIso8601String(),
    };
  }

  List<dynamic> _extractUserProfilesFromData(Map<String, dynamic> data) {
    // Check new format first
    if (data.containsKey('userProfiles') && data['userProfiles'] is List) {
      return data['userProfiles'] as List<dynamic>;
    }

    // Check old format (singular)
    if (data.containsKey('userProfile')) {
      return [_convertOldUserProfileFormat(data['userProfile'])];
    }

    // Check old React Native table format
    if (data.containsKey('user_profile') && data['user_profile'] is Map) {
      final userProfileTable = data['user_profile'] as Map<String, dynamic>;
      if (userProfileTable.containsKey('data') &&
          userProfileTable['data'] is List) {
        final profiles = userProfileTable['data'] as List<dynamic>;
        return profiles
            .map((profile) => _convertOldUserProfileFormat(profile))
            .toList();
      }
    }

    return [];
  }

  Map<String, dynamic> _convertOldUserProfileFormat(dynamic oldProfile) {
    if (oldProfile is! Map<String, dynamic>) return {};

    return {
      'id': oldProfile['id'] ?? _generateId(),
      'name': oldProfile['name'] ?? 'User',
      'email': oldProfile['email'] ?? 'imported.user@platepal.local',
      'age':
          _safeParseInt(oldProfile['age'] ?? oldProfile['dateOfBirth']) ?? 25,
      'gender': oldProfile['gender'] ?? 'other',
      'height': _safeParseDouble(oldProfile['height']) ?? 170.0,
      'weight': _safeParseDouble(oldProfile['weight']) ?? 70.0,
      'targetWeight': _safeParseDouble(oldProfile['targetWeight']),
      'activityLevel':
          oldProfile['activityLevel'] ??
          oldProfile['activity_level'] ??
          'sedentary',
      'fitnessGoal':
          oldProfile['fitnessGoal'] ??
          oldProfile['fitness_goal'] ??
          'maintainWeight',
      'unitSystem':
          (oldProfile['useMetricSystem'] ?? oldProfile['use_metric_system']) ==
                  true
              ? 'metric'
              : 'imperial',
      'createdAt':
          oldProfile['createdAt'] ??
          oldProfile['created_at'] ??
          DateTime.now().toIso8601String(),
      'updatedAt':
          oldProfile['updatedAt'] ??
          oldProfile['updated_at'] ??
          DateTime.now().toIso8601String(),
      'nutritionTargets': {
        'calories':
            _safeParseDouble(oldProfile['dailyCalorieTarget']) ?? 2000.0,
        'protein': _safeParseDouble(oldProfile['dailyProteinTarget']) ?? 150.0,
        'carbs': _safeParseDouble(oldProfile['dailyCarbsTarget']) ?? 250.0,
        'fat': _safeParseDouble(oldProfile['dailyFatTarget']) ?? 65.0,
        'fiber': _safeParseDouble(oldProfile['dailyFiberTarget']) ?? 25.0,
      },
    };
  }

  Map<String, dynamic> _convertOldDishFormat(Map<String, dynamic> oldDish) {
    return {
      'id': oldDish['id'] ?? _generateId(),
      'name': oldDish['name'] ?? 'Imported Dish',
      'description': oldDish['description'] ?? '',
      'imageUrl': oldDish['imageUri'] ?? oldDish['image_url'] ?? '',
      'category': oldDish['category'] ?? 'other',
      'isFavorite':
          _safeParseBool(oldDish['isFavorite'] ?? oldDish['is_favorite']) ??
          false,
      'createdAt':
          oldDish['createdAt'] ??
          oldDish['created_at'] ??
          DateTime.now().toIso8601String(),
      'updatedAt':
          oldDish['updatedAt'] ??
          oldDish['updated_at'] ??
          DateTime.now().toIso8601String(),
      'nutrition': {
        'calories': _safeParseDouble(oldDish['calories']) ?? 0.0,
        'protein': _safeParseDouble(oldDish['protein']) ?? 0.0,
        'carbs': _safeParseDouble(oldDish['carbs']) ?? 0.0,
        'fat': _safeParseDouble(oldDish['fat']) ?? 0.0,
        'fiber': _safeParseDouble(oldDish['fiber']) ?? 0.0,
      },
      'ingredients': oldDish['ingredients'] ?? [],
      'tags': _convertTags(oldDish['tags']),
      'defaultMealType':
          oldDish['defaultMealType'] ?? oldDish['default_meal_type'] ?? 'snack',
    };
  }

  void _attachIngredientsTooDishes(
    List<Map<String, dynamic>> dishes,
    List<dynamic> ingredientRows,
  ) {
    // Group ingredients by dishId
    final ingredientsByDish = <String, List<Map<String, dynamic>>>{};

    for (final row in ingredientRows) {
      if (row is Map<String, dynamic>) {
        final dishId = row['dishId'] ?? row['dish_id'];
        if (dishId != null) {
          ingredientsByDish.putIfAbsent(dishId, () => []).add({
            'id': row['id'] ?? _generateId(),
            'name': row['name'] ?? 'Unknown Ingredient',
            'quantity': _safeParseDouble(row['quantity']) ?? 0.0,
            'unit': row['unit'] ?? 'g',
            'calories': _safeParseDouble(row['calories']) ?? 0.0,
            'protein': _safeParseDouble(row['protein']) ?? 0.0,
            'carbs': _safeParseDouble(row['carbs']) ?? 0.0,
            'fat': _safeParseDouble(row['fat']) ?? 0.0,
            'fiber': _safeParseDouble(row['fiber']) ?? 0.0,
            'caloriesPer100': _safeParseDouble(row['caloriesPer100']) ?? 0.0,
            'proteinPer100': _safeParseDouble(row['proteinPer100']) ?? 0.0,
            'carbsPer100': _safeParseDouble(row['carbsPer100']) ?? 0.0,
            'fatPer100': _safeParseDouble(row['fatPer100']) ?? 0.0,
            'fiberPer100': _safeParseDouble(row['fiberPer100']) ?? 0.0,
            // Explicitly ignore sodium and sugar - they are no longer tracked
          });
        }
      }
    }

    // Attach ingredients to dishes
    for (final dish in dishes) {
      final dishId = dish['id'];
      if (dishId != null && ingredientsByDish.containsKey(dishId)) {
        dish['ingredients'] = ingredientsByDish[dishId];
      }
    }
  }

  // Safe parsing helper methods
  double? _safeParseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        try {
          return double.parse(value).round();
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  bool? _safeParseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }

  List<ValidationError> _validateItem(DataType type, dynamic item, int index) {
    final errors = <ValidationError>[];

    if (item is! Map<String, dynamic>) {
      errors.add(
        ValidationError(
          field: 'structure',
          error: 'Item must be a JSON object',
          value: item.toString(),
          itemIndex: index,
        ),
      );
      return errors;
    }

    final map = item;

    switch (type) {
      case DataType.dishes:
        if (!map.containsKey('name') ||
            map['name'] == null ||
            map['name'].toString().trim().isEmpty) {
          errors.add(
            ValidationError(
              field: 'name',
              error: 'Dish name is required',
              value: map['name']?.toString() ?? '',
              itemIndex: index,
            ),
          );
        }

        // Validate nutrition data structure
        if (map.containsKey('nutrition') && map['nutrition'] is Map) {
          final nutrition = map['nutrition'] as Map<String, dynamic>;
          final requiredNutrients = ['calories', 'protein', 'carbs', 'fat'];

          for (final nutrient in requiredNutrients) {
            if (nutrition.containsKey(nutrient)) {
              final value = _safeParseDouble(nutrition[nutrient]);
              if (value == null) {
                errors.add(
                  ValidationError(
                    field: 'nutrition.$nutrient',
                    error: '$nutrient must be a valid number',
                    value: nutrition[nutrient]?.toString() ?? '',
                    itemIndex: index,
                  ),
                );
              }
            }
          }
        } else {
          // Check old format
          if (map.containsKey('calories')) {
            final calories = _safeParseDouble(map['calories']);
            if (calories == null) {
              errors.add(
                ValidationError(
                  field: 'calories',
                  error: 'Calories must be a valid number',
                  value: map['calories']?.toString() ?? '',
                  itemIndex: index,
                ),
              );
            }
          }
        }
        break;
      case DataType.userProfiles:
        // Email validation - if missing, we'll add a default one
        if (map.containsKey('email') &&
            map['email'] != null &&
            map['email'].toString().trim().isNotEmpty) {
          final email = map['email'].toString();
          if (!email.contains('@')) {
            errors.add(
              ValidationError(
                field: 'email',
                error: 'Invalid email format',
                value: email,
                itemIndex: index,
              ),
            );
          }
        }
        // Don't add error for missing email, we'll handle it in conversion
        break;
      case DataType.mealLogs:
        if (!map.containsKey('dishId') ||
            map['dishId'] == null ||
            map['dishId'].toString().trim().isEmpty) {
          errors.add(
            ValidationError(
              field: 'dishId',
              error: 'Dish ID is required for meal logs',
              value: map['dishId']?.toString() ?? '',
              itemIndex: index,
            ),
          );
        }
        break;
      default:
        break;
    }

    return errors;
  }

  Future<bool> _checkIfExists(DataType type, dynamic item) async {
    if (item is! Map<String, dynamic>) return false;

    switch (type) {
      case DataType.dishes:
        final id = item['id'] as String?;
        if (id != null) {
          final dish = await _dishService.getDishById(id);
          return dish != null;
        }

        // Check by name if no ID
        final name = item['name'] as String?;
        if (name != null) {
          final dishes = await _dishService.getAllDishes();
          return dishes.any(
            (dish) => dish.name.toLowerCase() == name.toLowerCase(),
          );
        }
        return false;
      case DataType.userProfiles:
      case DataType.mealLogs:
      case DataType.ingredients:
      case DataType.supplements:
      case DataType.fitnessGoals:
        // TODO: Implement checks for other data types when services are available
        return false;
      default:
        return false;
    }
  }

  /// Save an item to the database based on its type
  Future<void> _saveItem(
    DataType type,
    dynamic item,
    DuplicateHandling duplicateHandling,
  ) async {
    debugPrint(
      '💾 Saving ${type.name} item: ${_getItemIdentifier(type, item)}',
    );

    switch (type) {
      case DataType.dishes:
        await _saveDishItem(item as Map<String, dynamic>, duplicateHandling);
        break;
      case DataType.mealLogs:
        // Meal logs are handled separately in _processMealLogs
        throw Exception(
          'Meal logs should be processed through _processMealLogs method',
        );
      case DataType.userProfiles:
        // TODO: Implement user profiles saving when service is available
        debugPrint('⚠️ User profiles saving not yet implemented');
        break;
      case DataType.ingredients:
        // TODO: Implement ingredients saving when service is available
        debugPrint('⚠️ Ingredients saving not yet implemented');
        break;
      case DataType.supplements:
        // TODO: Implement supplements saving when service is available
        debugPrint('⚠️ Supplements saving not yet implemented');
        break;
      case DataType.fitnessGoals:
        // TODO: Implement fitness goals saving when service is available
        debugPrint('⚠️ Fitness goals saving not yet implemented');
        break;
      case DataType.allData:
        throw Exception('allData should not be processed as individual items');
    }
  }

  /// Save a dish item to the database
  Future<void> _saveDishItem(
    Map<String, dynamic> dishData,
    DuplicateHandling duplicateHandling,
  ) async {
    try {
      // Convert the dish data to a Dish object
      final dish = _convertToDishObject(dishData);

      // Check if dish already exists
      final existingDish = await _dishService.getDishById(dish.id);

      if (existingDish != null) {
        switch (duplicateHandling) {
          case DuplicateHandling.skip:
            debugPrint('⏭️ Skipping duplicate dish: ${dish.name}');
            return;
          case DuplicateHandling.overwrite:
            // Updating existing dish: ${dish.name}
            await _dishService.updateDish(dish);
            break;
          case DuplicateHandling.merge:
            debugPrint('🔀 Merging dish data: ${dish.name}');
            // For now, treat merge as overwrite
            await _dishService.updateDish(dish);
            break;
        }
      } else {
        debugPrint('✨ Creating new dish: ${dish.name}');
        await _dishService.saveDish(dish);
      }
    } catch (e) {
      debugPrint('❌ Error saving dish: $e');
      rethrow;
    }
  }

  /// Convert import data to a Dish object
  Dish _convertToDishObject(Map<String, dynamic> dishData) {
    try {
      // Handle direct Dish JSON format
      if (dishData.containsKey('ingredients') &&
          dishData['ingredients'] is List) {
        return Dish.fromJson(dishData);
      }

      // Handle old format conversion - convert to new format then create Dish object
      final convertedData = _convertOldDishFormat(dishData);
      return Dish.fromJson(convertedData);
    } catch (e) {
      debugPrint('❌ Error converting dish data: $e');
      debugPrint('❌ Dish data: $dishData');
      rethrow;
    }
  }

  String _convertToCSV(Map<String, dynamic> data) {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Type,Data');

      for (final entry in data.entries) {
        if (entry.value is List) {
          final list = entry.value as List;
          for (final item in list) {
            try {
              final jsonString = json.encode(item).replaceAll('"', '""');
              buffer.writeln('${entry.key},"$jsonString"');
            } catch (e) {
              // Skip this item and continue
              continue;
            }
          }
        }
      }

      return buffer.toString();
    } catch (e) {
      rethrow;
    }
  }

  CSVParseResult _convertFromCSVWithErrors(String csvContent) {
    final lines = csvContent.split('\n');
    final data = <String, List<dynamic>>{};
    final errors = <ParsingError>[];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final commaIndex = line.indexOf(',');
        if (commaIndex == -1) {
          errors.add(
            ParsingError(
              line: i + 1,
              column: 0,
              error: 'Invalid CSV format: missing comma separator',
              context: [line],
            ),
          );
          continue;
        }

        final type = line.substring(0, commaIndex);
        final jsonData = line.substring(commaIndex + 1);

        // Remove surrounding quotes and unescape internal quotes
        final cleanJson = jsonData
            .substring(1, jsonData.length - 1)
            .replaceAll('""', '"');
        final item = json.decode(cleanJson);

        data.putIfAbsent(type, () => []).add(item);
      } catch (e) {
        errors.add(
          ParsingError(
            line: i + 1,
            column: 0,
            error: 'JSON parsing error: ${e.toString()}',
            context: [line],
          ),
        );
      }
    }

    return CSVParseResult(data: data, errors: errors);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond % 1000).toString();
  }

  List<String> _convertTags(dynamic tags) {
    if (tags == null) return [];

    if (tags is List) {
      return tags.map((tag) => tag.toString()).toList();
    } else if (tags is String) {
      // Handle comma-separated tags
      return tags
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Get all meal logs from meal_logs table
  Future<List<Map<String, dynamic>>> _getAllMealLogs() async {
    final db = await DatabaseService.instance.database;
    return await db.query('meal_logs', orderBy: 'logged_at DESC');
  }

  /// Get all dish logs from dish_logs table
  Future<List<Map<String, dynamic>>> _getAllDishLogs() async {
    final db = await DatabaseService.instance.database;
    return await db.query('dish_logs', orderBy: 'logged_at DESC');
  }

  /// Create automatic backup of current data
  Future<bool> createBackupBeforeImport() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = 'platepal_backup_$timestamp.json';

      // Get platform-specific directory
      String backupPath;
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        backupPath = '${directory?.path}/PlatePal/backups/$backupFileName';
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        backupPath = '${directory.path}/backups/$backupFileName';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        backupPath = '${directory.path}/backups/$backupFileName';
      }

      // Create backup directory if it doesn't exist
      final backupDir = Directory(backupPath).parent;
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Get all data directly without using exportData
      final exportData = await _exportDataType(DataType.allData);

      // Write the exported data to file
      final file = File(backupPath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(exportData),
      );

      // Store backup path in SharedPreferences for "go back" functionality
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup_path', backupPath);
      await prefs.setInt('last_backup_timestamp', timestamp);
      // Backup created successfully: $backupPath
      return true;
    } catch (e) {
      debugPrint('❌ Failed to create backup: $e');
      return false;
    }
  }

  /// Restore from the last backup (the "ah shit go back" functionality)
  Future<ImportExportResult> restoreFromLastBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackupPath = prefs.getString('last_backup_path');

      if (lastBackupPath == null || !await File(lastBackupPath).exists()) {
        return ImportExportResult(
          success: false,
          message: 'No backup found to restore from',
          itemsProcessed: 0,
          duplicatesFound: 0,
          errors: ['No backup file found'],
        );
      }

      // Clear current data before restore
      await _clearAllData();

      // Import from backup
      final result = await importData(
        filePath: lastBackupPath,
        dataTypes: [DataType.allData],
        duplicateHandling: DuplicateHandling.overwrite,
      );

      if (result.success) {
        // Clear the backup reference since we've restored
        await prefs.remove('last_backup_path');
        await prefs.remove('last_backup_timestamp');
      }

      return result;
    } catch (e) {
      return ImportExportResult(
        success: false,
        message: 'Failed to restore from backup: $e',
        itemsProcessed: 0,
        duplicatesFound: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Check if backup exists for "go back" functionality
  Future<bool> hasBackupAvailable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackupPath = prefs.getString('last_backup_path');
      return lastBackupPath != null && await File(lastBackupPath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Get backup info for display
  Future<Map<String, dynamic>?> getBackupInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackupPath = prefs.getString('last_backup_path');
      final lastBackupTimestamp = prefs.getInt('last_backup_timestamp');

      if (lastBackupPath != null && lastBackupTimestamp != null) {
        final file = File(lastBackupPath);
        if (await file.exists()) {
          final stat = await file.stat();
          return {
            'path': lastBackupPath,
            'timestamp': lastBackupTimestamp,
            'size': stat.size,
            'date': DateTime.fromMillisecondsSinceEpoch(lastBackupTimestamp),
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear all data from database (for restore functionality)
  Future<void> _clearAllData() async {
    final db = await DatabaseService.instance.database;
    await db.transaction((txn) async {
      // Clear in reverse dependency order
      await txn.delete('dish_logs');
      await txn.delete('meal_logs');
      await txn.delete('dish_ingredients');
      await txn.delete('dish_nutrition');
      await txn.delete('ingredient_nutrition');
      await txn.delete('dishes');
      await txn.delete('ingredients');
      // Note: Not clearing user profiles, preferences, etc. for safety
    });
  }

  /// Sort data types by dependency order to ensure correct import sequence
  List<DataType> _sortDataTypesByDependency(List<DataType> dataTypes) {
    // Define dependencies: child -> parent (child depends on parent)
    final dependencies = <DataType, List<DataType>>{
      DataType.mealLogs: [DataType.dishes], // meal logs depend on dishes
      // Add more dependencies as needed in the future
    };

    final sorted = <DataType>[];
    final remaining = List<DataType>.from(dataTypes);

    // Keep processing until all types are sorted
    while (remaining.isNotEmpty) {
      bool progressMade = false;

      for (int i = remaining.length - 1; i >= 0; i--) {
        final type = remaining[i];
        final deps = dependencies[type] ?? [];

        // Check if all dependencies are already sorted or not in the list
        final allDepsReady = deps.every(
          (dep) => sorted.contains(dep) || !dataTypes.contains(dep),
        );

        if (allDepsReady) {
          sorted.add(type);
          remaining.removeAt(i);
          progressMade = true;
        }
      }

      // Safety check to prevent infinite loops
      if (!progressMade) {
        debugPrint('⚠️ Circular dependency detected, using fallback order');
        sorted.addAll(remaining);
        break;
      }
    }

    return sorted;
  }

  /// Helper method to get items for a data type (used for progress calculation)
  List<dynamic> _getItemsForDataType(DataType type, Map<String, dynamic> data) {
    switch (type) {
      case DataType.dishes:
        return _extractDishesFromData(data);
      case DataType.mealLogs:
        return _extractMealLogsFromData(data);
      case DataType.userProfiles:
        return _extractUserProfilesFromData(data);
      default:
        return data[type.name] as List<dynamic>? ?? [];
    }
  }
}

class ImportExportResult {
  final bool success;
  final String message;
  final int itemsProcessed;
  final int duplicatesFound;
  final List<String> errors;
  final ImportDetailedResults? detailedResults;

  const ImportExportResult({
    required this.success,
    required this.message,
    required this.itemsProcessed,
    required this.duplicatesFound,
    required this.errors,
    this.detailedResults,
  });
}

class ImportDetailedResults {
  FileInfo? _fileInfo;
  final List<ParsingError> parsingErrors;
  final List<ValidationError> validationErrors;
  final List<ProcessingError> processingErrors;
  final List<DuplicateItem> duplicates;
  final List<ProcessedItem> processedItems;
  final Map<String, TypeSummary> summary;

  ImportDetailedResults({
    FileInfo? fileInfo,
    List<ParsingError>? parsingErrors,
    List<ValidationError>? validationErrors,
    List<ProcessingError>? processingErrors,
    List<DuplicateItem>? duplicates,
    List<ProcessedItem>? processedItems,
    Map<String, TypeSummary>? summary,
  }) : _fileInfo = fileInfo,
       parsingErrors = parsingErrors ?? [],
       validationErrors = validationErrors ?? [],
       processingErrors = processingErrors ?? [],
       duplicates = duplicates ?? [],
       processedItems = processedItems ?? [],
       summary = summary ?? {};

  FileInfo? get fileInfo => _fileInfo;

  void setFileInfo(FileInfo info) {
    _fileInfo = info;
  }
}

class FileInfo {
  final String fileName;
  final int fileSize;
  final int totalLines;

  const FileInfo({
    required this.fileName,
    required this.fileSize,
    required this.totalLines,
  });
}

class ParsingError {
  final int line;
  final int column;
  final String error;
  final List<String> context;

  const ParsingError({
    required this.line,
    required this.column,
    required this.error,
    required this.context,
  });
}

class ValidationError {
  final String field;
  final String error;
  final String value;
  final int? itemIndex;

  const ValidationError({
    required this.field,
    required this.error,
    required this.value,
    this.itemIndex,
  });
}

class ProcessingError {
  final String type;
  final int index;
  final String error;
  final String item;

  const ProcessingError({
    required this.type,
    required this.index,
    required this.error,
    required this.item,
  });
}

class DuplicateItem {
  final String type;
  final int index;
  final String identifier;
  final String action;

  const DuplicateItem({
    required this.type,
    required this.index,
    required this.identifier,
    required this.action,
  });
}

class ProcessedItem {
  final String type;
  final int index;
  final String identifier;
  final String action;

  const ProcessedItem({
    required this.type,
    required this.index,
    required this.identifier,
    required this.action,
  });
}

class TypeSummary {
  final int total;
  final int processed;
  final int duplicates;
  final int skipped;
  final int errors;

  const TypeSummary({
    required this.total,
    required this.processed,
    required this.duplicates,
    required this.skipped,
    required this.errors,
  });
}

class CSVParseResult {
  final Map<String, List<dynamic>> data;
  final List<ParsingError> errors;

  const CSVParseResult({required this.data, required this.errors});
}

class DataValidationResult {
  final bool isValid;
  final List<String> errors;

  const DataValidationResult({required this.isValid, required this.errors});
}

class ImportResult {
  final bool success;
  final int itemsProcessed;
  final int duplicatesFound;
  final List<String> errors;

  ImportResult({
    required this.success,
    required this.itemsProcessed,
    required this.duplicatesFound,
    required this.errors,
  });
}
