import 'dart:convert';

import 'package:archive/archive.dart';
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
}
