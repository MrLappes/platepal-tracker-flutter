import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data classes for category / sort / filter options
// ─────────────────────────────────────────────────────────────────────────────

/// A curated list of top-level Open Food Facts categories (en: taxonomy tags).
class OFFCategory {
  final String label; // human-readable
  final String tag; // e.g. "en:fruits"
  final String emoji;

  const OFFCategory(this.label, this.tag, this.emoji);

  static const List<OFFCategory> all = [
    OFFCategory('All', '', '🌍'),
    OFFCategory('Fruits', 'en:fruits', '🍎'),
    OFFCategory('Vegetables', 'en:vegetables', '🥦'),
    OFFCategory('Dairy', 'en:dairies', '🧀'),
    OFFCategory('Meat', 'en:meats', '🥩'),
    OFFCategory('Seafood', 'en:seafood', '🐟'),
    OFFCategory('Beverages', 'en:beverages', '🥤'),
    OFFCategory('Cereals', 'en:cereals-and-potatoes', '🌾'),
    OFFCategory('Breads', 'en:breads', '🍞'),
    OFFCategory('Snacks', 'en:snacks', '🍿'),
    OFFCategory('Sweets', 'en:confectioneries', '🍬'),
    OFFCategory('Legumes', 'en:legumes', '🫘'),
    OFFCategory('Nuts', 'en:nuts', '🥜'),
    OFFCategory('Condiments', 'en:condiments', '🫙'),
    OFFCategory('Oils & Fats', 'en:fats', '🫒'),
    OFFCategory('Frozen', 'en:frozen-foods', '🧊'),
    OFFCategory('Ready Meals', 'en:meals', '🍱'),
    OFFCategory('Baby Foods', 'en:baby-foods', '👶'),
  ];
}

enum OFFSortBy {
  popularity, // unique_scans_n
  productName, // product_name
  lastModified, // last_modified_t
  completeness, // completeness
}

extension OFFSortByExt on OFFSortBy {
  String get apiValue {
    switch (this) {
      case OFFSortBy.popularity:
        return 'unique_scans_n';
      case OFFSortBy.productName:
        return 'product_name';
      case OFFSortBy.lastModified:
        return 'last_modified_t';
      case OFFSortBy.completeness:
        return 'completeness';
    }
  }

  String get label {
    switch (this) {
      case OFFSortBy.popularity:
        return 'Most Popular';
      case OFFSortBy.productName:
        return 'Name A–Z';
      case OFFSortBy.lastModified:
        return 'Newest';
      case OFFSortBy.completeness:
        return 'Most Complete';
    }
  }
}

/// Nutri-Score grade filter (a–e).
enum NutriScoreGrade { a, b, c, d, e }

extension NutriScoreGradeExt on NutriScoreGrade {
  String get apiValue => name; // 'a', 'b' … 'e'
  String get label => name.toUpperCase();
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

/// Service for interacting with the Open Food Facts API.
///
/// Key API facts:
///  - v1 search (`cgi/search.pl`) supports full-text + tagtype filters.
///  - v2 search (`/api/v2/search`) supports facet filters but NO full-text.
///  - Rate limit: 10 req/min for search queries.
class OpenFoodFactsService {
  static const String _baseUrl = 'https://world.openfoodfacts.org';
  static const Map<String, String> _headers = {
    'User-Agent':
        'PlatePalTracker/1.0 (android; https://github.com/MrLappes/platepal-tracker-flutter)',
  };

  static const Map<String, String> _countryTagMap = {
    'de': 'germany',
    'en': 'united-states',
    'es': 'spain',
    'fr': 'france',
    'it': 'italy',
    'pt': 'portugal',
    'nl': 'netherlands',
    'pl': 'poland',
  };

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Full-text search with optional category / nutri-score / sort filters.
  ///
  /// Uses the v1 search endpoint — the only one that supports combined
  /// full-text search AND tag-based facet filtering.
  Future<List<Product>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
    String? countryCode,
    String? languageCode,
    OFFCategory? category,
    NutriScoreGrade? nutriScore,
    OFFSortBy sortBy = OFFSortBy.popularity,
  }) async {
    final lc = languageCode ?? 'en';
    final cc = countryCode ?? 'en';
    int tagIndex = 0;
    final tagParams = StringBuffer();

    // — Country filter (only applies when not "world")
    final countryTag = _countryTagMap[cc];
    if (countryTag != null) {
      tagParams.write(
        '&tagtype_$tagIndex=countries'
        '&tag_contains_$tagIndex=contains'
        '&tag_$tagIndex=$countryTag',
      );
      tagIndex++;
    }

    // — Category filter
    if (category != null && category.tag.isNotEmpty) {
      tagParams.write(
        '&tagtype_$tagIndex=categories'
        '&tag_contains_$tagIndex=contains'
        '&tag_$tagIndex=${Uri.encodeComponent(category.tag)}',
      );
      tagIndex++;
    }

    // — Nutri-Score filter
    if (nutriScore != null) {
      tagParams.write(
        '&tagtype_$tagIndex=nutrition_grades'
        '&tag_contains_$tagIndex=contains'
        '&tag_$tagIndex=${nutriScore.apiValue}',
      );
      tagIndex++;
    }

    final encodedQuery = Uri.encodeComponent(query.trim());
    final searchTermsPart =
        query.trim().isNotEmpty ? '&search_terms=$encodedQuery' : '';

    final url =
        '$_baseUrl/cgi/search.pl?action=process&json=1$searchTermsPart'
        '&page=$page&page_size=$pageSize'
        '&sort_by=${sortBy.apiValue}'
        '&fields=code,product_name,product_name_en,brands,image_url,'
        'image_front_url,quantity,nutriments,nutrition_grades,categories_tags_en'
        '$tagParams'
        '&lc=$lc&nocache=1';

    debugPrint('🔍 OFF search (page $page): $url');
    return _fetchAndParse(url);
  }

  /// Browse a category without a text query.
  Future<List<Product>> browseCategory(
    OFFCategory category, {
    int page = 1,
    int pageSize = 20,
    NutriScoreGrade? nutriScore,
    OFFSortBy sortBy = OFFSortBy.popularity,
    String? languageCode,
  }) async {
    if (category.tag.isEmpty) {
      return _fetchPopularProducts(
        page: page,
        pageSize: pageSize,
        nutriScore: nutriScore,
        sortBy: sortBy,
        languageCode: languageCode,
      );
    }

    final lc = languageCode ?? 'en';
    final nutritionPart =
        nutriScore != null
            ? '&tagtype_1=nutrition_grades&tag_contains_1=contains&tag_1=${nutriScore.apiValue}'
            : '';

    final url =
        '$_baseUrl/cgi/search.pl?action=process&json=1'
        '&tagtype_0=categories&tag_contains_0=contains'
        '&tag_0=${Uri.encodeComponent(category.tag)}'
        '$nutritionPart'
        '&page=$page&page_size=$pageSize'
        '&sort_by=${sortBy.apiValue}'
        '&fields=code,product_name,product_name_en,brands,image_url,'
        'image_front_url,quantity,nutriments,nutrition_grades,categories_tags_en'
        '&lc=$lc&nocache=1';

    debugPrint('📂 OFF browse "${category.label}" (page $page): $url');
    return _fetchAndParse(url);
  }

  /// Get a single product by barcode.
  Future<Product?> getProductByBarcode(String barcode) async {
    final url =
        '$_baseUrl/api/v2/product/$barcode'
        '?fields=code,product_name,brands,image_url,image_front_url,'
        'quantity,nutriments,nutrition_grades,categories_tags_en';

    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] == 1) return _parseProduct(data['product']);
    }
    return null;
  }

  /// Autocomplete category suggestions from the OFF taxonomy.
  Future<List<String>> suggestCategories(String term) async {
    if (term.trim().isEmpty) return [];
    try {
      final encoded = Uri.encodeComponent(term.trim());
      final url =
          '$_baseUrl/cgi/suggest.pl?tagtype=categories&term=$encoded&lc=en';
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List<dynamic>).cast<String>();
      }
    } catch (_) {}
    return [];
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<List<Product>> _fetchPopularProducts({
    int page = 1,
    int pageSize = 20,
    NutriScoreGrade? nutriScore,
    OFFSortBy sortBy = OFFSortBy.popularity,
    String? languageCode,
  }) async {
    final lc = languageCode ?? 'en';
    final nutritionFilter =
        nutriScore != null
            ? '&nutrition_grades_tags=${nutriScore.apiValue}'
            : '';

    final url =
        '$_baseUrl/api/v2/search?sort_by=${sortBy.apiValue}'
        '&page=$page&page_size=$pageSize$nutritionFilter'
        '&fields=code,product_name,product_name_en,brands,image_url,'
        'image_front_url,quantity,nutriments,nutrition_grades,categories_tags_en'
        '&lc=$lc';

    return _fetchAndParse(url, v2: true);
  }

  Future<List<Product>> _fetchAndParse(String url, {bool v2 = false}) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>? ?? [];
        debugPrint('✅ Parsed ${products.length} products');
        return products
            .map(_parseProduct)
            .where((p) => p != null && p.isValid)
            .cast<Product>()
            .toList();
      }
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Fetch error: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  Product? _parseProduct(dynamic productData) {
    try {
      if (productData is! Map<String, dynamic>) return null;
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
