import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

/// Layout of a full backup: the export JSON plus the dish photos it uses.
const String backupArchiveDataFile = 'platepal_data.json';
const String backupArchiveImageDir = 'images';

/// Limits applied to entries of an imported archive.
const int maxBackupImageBytes = 20 * 1024 * 1024;
const int maxBackupDataBytes = 50 * 1024 * 1024;

const Set<String> _imageExtensions = {
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
  '.heic',
};
final RegExp _archiveImageName = RegExp(
  r'^images/[A-Za-z0-9_-]{1,64}\.(jpg|jpeg|png|webp|gif|heic)$',
);

class BackupArchiveContents {
  const BackupArchiveContents({required this.data, required this.images});

  final Map<String, dynamic> data;

  /// Image entries by archive path, e.g. `images/0.jpg`.
  final Map<String, ArchiveFile> images;
}

Iterable<Map<dynamic, dynamic>> _dishes(Map<String, dynamic> data) {
  final dishes = data['dishes'];
  return dishes is List ? dishes.whereType<Map>() : const [];
}

/// Absolute on-device image paths referenced by dishes in [data].
Set<String> localDishImagePaths(Map<String, dynamic> data) => {
  for (final dish in _dishes(data))
    if (dish['imageUrl'] case final String url when p.isAbsolute(url)) url,
};

/// Archive image paths referenced by dishes in an imported backup.
Set<String> archivedDishImagePaths(Map<String, dynamic> data) => {
  for (final dish in _dishes(data))
    if (dish['imageUrl'] case final String url
        when _archiveImageName.hasMatch(url))
      url,
};

/// Copy of [data] with each dish `imageUrl` replaced by [rewrite]; returning
/// null drops the image.
Map<String, dynamic> rewriteDishImagePaths(
  Map<String, dynamic> data,
  String? Function(String imageUrl) rewrite,
) {
  final dishes = data['dishes'];
  if (dishes is! List) return data;
  return {
    ...data,
    'dishes': [
      for (final dish in dishes)
        if (dish is Map<String, dynamic> && dish['imageUrl'] is String)
          <String, dynamic>{
            ...dish,
            'imageUrl': rewrite(dish['imageUrl'] as String),
          }
        else
          dish,
    ],
  };
}

/// Zips [data] with [images] (file bytes keyed by the path used in [data]),
/// pointing each dish at its copy inside the archive.
List<int> encodeBackupArchive(
  Map<String, dynamic> data,
  Map<String, List<int>> images,
) {
  final names = <String, String>{};
  for (final path in images.keys) {
    final extension = p.extension(path).toLowerCase();
    names[path] =
        '$backupArchiveImageDir/${names.length}'
        '${_imageExtensions.contains(extension) ? extension : '.jpg'}';
  }
  final archive = Archive()
    ..add(
      ArchiveFile.string(
        backupArchiveDataFile,
        const JsonEncoder.withIndent(
          '  ',
        ).convert(rewriteDishImagePaths(data, (url) => names[url] ?? url)),
      ),
    );
  for (final MapEntry(key: path, value: bytes) in images.entries) {
    archive.add(ArchiveFile.noCompress(names[path]!, bytes.length, bytes));
  }
  return ZipEncoder().encode(archive);
}

/// Reads a full backup. Throws [FormatException] if [archive] is not one.
/// Unexpected entries, unsafe names and oversized images are ignored.
BackupArchiveContents readBackupArchive(Archive archive) {
  final dataFile = archive.find(backupArchiveDataFile);
  if (dataFile == null || !dataFile.isFile) {
    throw const FormatException('Backup data file missing');
  }
  if (dataFile.size > maxBackupDataBytes) {
    throw const FormatException('Backup data file too large');
  }
  final decoded = json.decode(utf8.decode(dataFile.content));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Backup data must be a JSON object');
  }
  return BackupArchiveContents(
    data: decoded,
    images: {
      for (final file in archive.files)
        if (file.isFile &&
            _archiveImageName.hasMatch(file.name) &&
            file.size <= maxBackupImageBytes)
          file.name: file,
    },
  );
}
