import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:platepal_tracker/services/open_food_facts_service.dart';

void main() {
  test('404 barcode response means product not found', () async {
    final client = MockClient((_) async => http.Response('{}', 404));
    addTearDown(client.close);

    expect(
      await OpenFoodFactsService(client: client).getProductByBarcode('123'),
      isNull,
    );
  });

  test('OFF status zero means product not found', () async {
    final client = MockClient((_) async => http.Response('{"status":0}', 200));
    addTearDown(client.close);

    expect(
      await OpenFoodFactsService(client: client).getProductByBarcode('123'),
      isNull,
    );
  });

  for (final statusCode in [429, 503]) {
    test('HTTP $statusCode barcode response is a service error', () async {
      final client = MockClient((_) async => http.Response('{}', statusCode));
      addTearDown(client.close);

      await expectLater(
        OpenFoodFactsService(client: client).getProductByBarcode('123'),
        throwsA(isA<http.ClientException>()),
      );
    });
  }

  test('OFF status one returns the product', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"status":1,"product":{"code":"123","product_name":"Oats"}}',
        200,
      ),
    );
    addTearDown(client.close);

    final product = await OpenFoodFactsService(
      client: client,
    ).getProductByBarcode('123');

    expect(product?.name, 'Oats');
  });

  test('search preserves timeout errors', () async {
    final client = MockClient((_) async => throw TimeoutException('stalled'));
    addTearDown(client.close);

    await expectLater(
      OpenFoodFactsService(client: client).searchProducts('oats'),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('category suggestions preserve timeout errors', () async {
    final client = MockClient((_) async => throw TimeoutException('stalled'));
    addTearDown(client.close);

    await expectLater(
      OpenFoodFactsService(client: client).suggestCategories('fruit'),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('search maps device region independently of UI language', () async {
    Uri? requestUri;
    final client = MockClient((request) async {
      requestUri = request.url;
      return http.Response('{"products":[]}', 200);
    });
    addTearDown(client.close);

    await OpenFoodFactsService(
      client: client,
    ).searchProducts('oats', countryCode: 'US', languageCode: 'es');

    expect(requestUri?.queryParameters['tag_0'], 'united-states');
    expect(requestUri?.queryParameters['lc'], 'es');
  });

  test('search omits country filter without a known region', () async {
    Uri? requestUri;
    final client = MockClient((request) async {
      requestUri = request.url;
      return http.Response('{"products":[]}', 200);
    });
    addTearDown(client.close);
    final service = OpenFoodFactsService(client: client);

    await service.searchProducts('oats', languageCode: 'en');
    expect(requestUri?.queryParameters, isNot(contains('tagtype_0')));

    await service.searchProducts('oats', countryCode: 'ZZ', languageCode: 'en');
    expect(requestUri?.queryParameters, isNot(contains('tagtype_0')));
  });
}
