import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

/// Layout of a full backup: the export JSON plus the dish photos it uses.
const String backupArchiveDataFile = 'platepal_data.json';
const String backupArchiveImageDir = 'images';

/// Folder in the app documents directory that holds dish photos.
const String dishImagesDirName = 'dish_images';

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

/// Whether [path] is an image file inside [dishImagesDir]. Pass canonical
/// paths when the files exist, so symlinks cannot point elsewhere.
bool isDishImageInDirectory(String path, String dishImagesDir) =>
    p.isAbsolute(path) &&
    p.isWithin(p.normalize(dishImagesDir), p.normalize(path)) &&
    _imageExtensions.contains(p.extension(path).toLowerCase());

/// The `imageUrl` an imported dish may keep: http(s) URLs and photos in the
/// app's own [dishImagesDir]. Any other path could name a private app file
/// that later full backups would bundle.
String? sanitizeImportedImageUrl(String? url, String dishImagesDir) {
  if (url == null || url.isEmpty) return null;
  final uri = Uri.tryParse(url);
  if (uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty) {
    return url;
  }
  return isDishImageInDirectory(url, dishImagesDir) ? url : null;
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
/// Zip headers can lie about sizes, so the decompressed data is checked too.
BackupArchiveContents readBackupArchive(
  Archive archive, {
  int maxDataBytes = maxBackupDataBytes,
  int maxImageBytes = maxBackupImageBytes,
}) {
  final dataFile = archive.find(backupArchiveDataFile);
  if (dataFile == null || !dataFile.isFile) {
    throw const FormatException('Backup data file missing');
  }
  if (dataFile.size > maxDataBytes) {
    throw const FormatException('Backup data file too large');
  }
  final content = dataFile.content;
  if (content.length > maxDataBytes) {
    throw const FormatException('Backup data file too large');
  }
  final decoded = json.decode(utf8.decode(content));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Backup data must be a JSON object');
  }
  return BackupArchiveContents(
    data: decoded,
    images: {
      for (final file in archive.files)
        if (file.isFile &&
            _archiveImageName.hasMatch(file.name) &&
            file.size <= maxImageBytes)
          file.name: file,
    },
  );
}

/// Decompressed bytes of an archived image, or null when they exceed
/// [maxBytes] whatever the zip header claims.
List<int>? readBackupImage(
  ArchiveFile file, {
  int maxBytes = maxBackupImageBytes,
}) {
  final bytes = file.readBytes();
  return bytes == null || bytes.length > maxBytes ? null : bytes;
}
