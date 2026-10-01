import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/services/data/backup_archive.dart';

Map<String, dynamic> _data() => {
  'dishes': [
    {'id': 'a', 'name': 'Soup', 'imageUrl': '/data/user/0/app/dish_images/a.JPG'},
    {'id': 'b', 'name': 'Toast', 'imageUrl': 'https://images.example/toast.jpg'},
    {'id': 'c', 'name': 'Salad', 'imageUrl': null},
    {'id': 'd', 'name': 'Pie', 'imageUrl': '/data/user/0/app/dish_images/missing.png'},
  ],
  'mealLogs': [
    {'id': 'log'},
  ],
};

void main() {
  test('local image paths are the absolute ones', () {
    expect(localDishImagePaths(_data()), {
      '/data/user/0/app/dish_images/a.JPG',
      '/data/user/0/app/dish_images/missing.png',
    });
    expect(localDishImagePaths({'dishes': 'not a list'}), isEmpty);
  });

  test('rewrite maps only dish images and leaves the input untouched', () {
    final data = _data();
    final rewritten = rewriteDishImagePaths(
      data,
      (url) => url.startsWith('https') ? null : 'x/$url',
    );

    final dishes = rewritten['dishes'] as List;
    expect(dishes[0]['imageUrl'], 'x//data/user/0/app/dish_images/a.JPG');
    expect(dishes[1]['imageUrl'], isNull);
    expect(dishes[2]['imageUrl'], isNull);
    expect(rewritten['mealLogs'], data['mealLogs']);
    expect(
      (data['dishes'] as List)[0]['imageUrl'],
      '/data/user/0/app/dish_images/a.JPG',
    );
  });

  test('archive round trip keeps data and bundles referenced images', () {
    final bytes = encodeBackupArchive(_data(), {
      '/data/user/0/app/dish_images/a.JPG': [1, 2, 3],
    });

    final contents = readBackupArchive(ZipDecoder().decodeBytes(bytes));
    final dishes = contents.data['dishes'] as List;
    expect(dishes[0]['imageUrl'], 'images/0.jpg');
    expect(dishes[1]['imageUrl'], 'https://images.example/toast.jpg');
    // Missing files keep their original path, as in a JSON export.
    expect(dishes[3]['imageUrl'], '/data/user/0/app/dish_images/missing.png');
    expect(contents.data['mealLogs'], [
      {'id': 'log'},
    ]);
    expect(contents.images.keys, ['images/0.jpg']);
    expect(contents.images['images/0.jpg']!.content, [1, 2, 3]);
    expect(archivedDishImagePaths(contents.data), {'images/0.jpg'});
  });

  test('unsafe or unexpected archive entries are ignored', () {
    final archive = Archive()
      ..add(
        ArchiveFile.string(
          backupArchiveDataFile,
          jsonEncode({
            'dishes': [
              {'id': 'a', 'imageUrl': 'images/../../evil.jpg'},
              {'id': 'b', 'imageUrl': 'images/ok.png'},
            ],
          }),
        ),
      )
      ..add(ArchiveFile.bytes('images/../../evil.jpg', [1]))
      ..add(ArchiveFile.bytes('../outside.png', [1]))
      ..add(ArchiveFile.bytes('images/script.sh', [1]))
      ..add(ArchiveFile.bytes('images/ok.png', [9]));

    final contents = readBackupArchive(archive);
    expect(contents.images.keys, ['images/ok.png']);
    expect(archivedDishImagePaths(contents.data), {'images/ok.png'});
  });

  test('archives without backup data are rejected', () {
    final noData = Archive()..add(ArchiveFile.bytes('images/0.jpg', [1]));
    expect(() => readBackupArchive(noData), throwsFormatException);

    final notObject = Archive()
      ..add(ArchiveFile.string(backupArchiveDataFile, '[1, 2]'));
    expect(() => readBackupArchive(notObject), throwsFormatException);
  });

  test('decompressed sizes are checked, not only the zip headers', () {
    final data = {
      'dishes': [
        {'id': 'a', 'name': 'x' * 400, 'imageUrl': 'images/0.png'},
      ],
    };
    final honest = encodeBackupArchive(data, {'/p/a.png': List.filled(500, 7)});
    var zip = _withDeclaredSize(honest, backupArchiveDataFile, 50);
    zip = _withDeclaredSize(zip, 'images/0.png', 50);
    final archive = ZipDecoder().decodeBytes(zip);
    expect(archive.find(backupArchiveDataFile)!.size, 50);

    expect(
      () => readBackupArchive(archive, maxDataBytes: 100),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          'Backup data file too large',
        ),
      ),
    );

    final contents = readBackupArchive(archive, maxImageBytes: 100);
    final image = contents.images['images/0.png']!;
    expect(image.size, 50, reason: 'the header passes the size filter');
    expect(readBackupImage(image, maxBytes: 100), isNull);
    expect(readBackupImage(image, maxBytes: 500), hasLength(500));
  });

  group('dish photo paths', () {
    const dir = '/data/user/0/app/app_flutter/dish_images';

    test('only image files inside the photo folder count as own photos', () {
      expect(isDishImageInDirectory('$dir/a.jpg', dir), isTrue);
      expect(isDishImageInDirectory('$dir/sub/a.PNG', dir), isTrue);
      expect(isDishImageInDirectory('$dir/../shared_prefs/x.jpg', dir), isFalse);
      expect(isDishImageInDirectory('$dir/notes.xml', dir), isFalse);
      expect(isDishImageInDirectory('${dir}_evil/a.jpg', dir), isFalse);
      expect(isDishImageInDirectory(dir, dir), isFalse);
      expect(isDishImageInDirectory('dish_images/a.jpg', dir), isFalse);
    });

    test('imports keep web URLs and own photos only', () {
      expect(
        sanitizeImportedImageUrl('https://images.example/a.jpg', dir),
        'https://images.example/a.jpg',
      );
      expect(
        sanitizeImportedImageUrl('http://images.example/a.jpg', dir),
        'http://images.example/a.jpg',
      );
      expect(sanitizeImportedImageUrl('$dir/a.jpg', dir), '$dir/a.jpg');
      for (final hostile in [
        '/data/user/0/app/shared_prefs/FlutterSharedPreferences.xml',
        '/data/user/0/app/databases/platepal.db',
        '$dir/../databases/platepal.jpg',
        '/etc/passwd',
        'file:///data/user/0/app/shared_prefs/x.jpg',
        'images/0.jpg',
        'https:///no-host.jpg',
        '',
        null,
      ]) {
        expect(sanitizeImportedImageUrl(hostile, dir), isNull, reason: hostile);
      }
    });
  });
}

/// [zip] with the uncompressed size of entry [name] set to [size] in its
/// local and central headers, as a crafted archive could do.
List<int> _withDeclaredSize(List<int> zip, String name, int size) {
  final bytes = Uint8List.fromList(zip);
  final view = ByteData.sublistView(bytes);
  final nameBytes = utf8.encode(name);
  for (var i = 0; i + 46 <= bytes.length; i++) {
    final signature = view.getUint32(i, Endian.little);
    final (sizeAt, nameLengthAt, nameAt) = switch (signature) {
      0x04034b50 => (i + 22, i + 26, i + 30),
      0x02014b50 => (i + 24, i + 28, i + 46),
      _ => (-1, -1, -1),
    };
    if (sizeAt < 0) continue;
    final nameLength = view.getUint16(nameLengthAt, Endian.little);
    if (nameLength != nameBytes.length ||
        nameAt + nameLength > bytes.length ||
        !listEquals(bytes.sublist(nameAt, nameAt + nameLength), nameBytes)) {
      continue;
    }
    view.setUint32(sizeAt, size, Endian.little);
  }
  return bytes;
}
