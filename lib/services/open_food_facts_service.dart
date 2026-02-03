import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// Service for interacting with the Open Food Facts API
class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';

  /// Search for products by text query
  Future<List<Product>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
    String? countryCode,
    String? languageCode,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final cc = countryCode ?? 'world';
      final lc = languageCode ?? 'en';

      // Using the reliable CGI search endpoint with region and language filtering
      final url =
          'https://world.openfoodfacts.org/cgi/search.pl?action=process&json=1&search_terms=$encodedQuery&page=$page&page_size=$pageSize&sort_by=unique_scans_n&fields=code,product_name,product_name_en,brands,image_url,image_front_url,quantity,nutriments&nocache=1&cc=$cc&lc=$lc';

      debugPrint('🔍 Searching Open Food Facts (Region: $cc, Lang: $lc): $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'PlatePalTracker - Android - Version 1.0 - https://github.com/MrLappes/platepal-tracker-flutter',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>? ?? [];
        debugPrint('✅ Found ${products.length} products');

        return products
            .map((productData) => _parseProduct(productData))
            .where((product) => product != null && product.isValid)
            .cast<Product>()
            .toList();
      } else {
        debugPrint('❌ Search failed: HTTP ${response.statusCode}');
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Search error: $e');
      throw Exception('Error searching products: $e');
    }
  }

  /// Get product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final url =
          '$_baseUrl/product/$barcode?fields=code,product_name,brands,image_url,image_front_url,quantity,nutriments';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['status'] == 1) {
          return _parseProduct(data['product']);
        } else {
          return null; // Product not found
        }
      } else {
        throw Exception('Failed to get product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting product: $e');
    }
  }

  /// Parse product data from API response
  Product? _parseProduct(dynamic productData) {
    try {
      if (productData is! Map<String, dynamic>) {
        return null;
      }

      return Product(
        barcode: productData['code'] as String?,
        name:
            productData['product_name'] as String? ??
            productData['product_name_en'] as String?,
        brand: productData['brands'] as String?,
        imageUrl:
            productData['image_url'] as String? ??
            productData['image_front_url'] as String?,
        quantity: productData['quantity'] as String?,
        nutrition: ProductNutrition.fromOpenFoodFacts(productData),
        rawData: productData,
      );
    } catch (e) {
      debugPrint('Error parsing product: $e');
      return null;
    }
  }
}
