import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:platepal_tracker/screens/dish_create_screen.dart';

void main() {
  test('copies a temporary dish image to a unique documents path', () async {
    final directory = await Directory.systemTemp.createTemp('dish-image-test-');
    addTearDown(() => directory.delete(recursive: true));
    final source = File(path.join(directory.path, 'picked.png'));
    await source.writeAsBytes([1, 2, 3]);
    final documents = Directory(path.join(directory.path, 'documents'));

    final first = await persistDishImage(source, documentsDirectory: documents);
    final second = await persistDishImage(
      source,
      documentsDirectory: documents,
    );

    expect(first, startsWith(path.join(documents.path, 'dish_images')));
    expect(path.extension(first), '.png');
    expect(first, isNot(second));
    expect(await File(first).readAsBytes(), [1, 2, 3]);
    expect(await source.exists(), isTrue);
  });

  test(
    'skips product images larger than 5 MB, even without a length header',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'dish-download-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final payload = List<int>.filled(5 * 1024 * 1024 + 1, 1);
      for (final declaredLength in [payload.length, null]) {
        final client = _ImageClient(payload, declaredLength);
        addTearDown(client.close);
        final image = await downloadProductImage(
          Uri.parse('https://example.org/product.jpg'),
          temporaryDirectory: directory,
          client: client,
        );
        expect(image, isNull);
      }
      expect(directory.listSync(), isEmpty);
    },
  );

  test('keeps a small product image download', () async {
    final directory = await Directory.systemTemp.createTemp(
      'dish-download-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final client = _ImageClient([1, 2, 3], 3);
    addTearDown(client.close);

    final image = await downloadProductImage(
      Uri.parse('https://example.org/product.png'),
      temporaryDirectory: directory,
      client: client,
    );

    expect(image, isNotNull);
    expect(path.extension(image!.path), '.png');
    expect(await image.readAsBytes(), [1, 2, 3]);
  });
}

class _ImageClient extends http.BaseClient {
  final List<int> payload;
  final int? declaredLength;

  _ImageClient(this.payload, this.declaredLength);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(
        Stream.value(payload),
        200,
        contentLength: declaredLength,
      );
}
