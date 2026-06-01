import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../models/dish.dart';
import 'openai_service.dart';

const _uuid = Uuid();

typedef RecipeHtmlFetcher = Future<String?> Function(Uri uri);
typedef RecipeAnalyzer =
    Future<Map<String, dynamic>?> Function({
      required Map<String, dynamic> extractedRecipe,
      String? requestedMealType,
    });

class RecipeImportResult {
  final bool success;
  final String replyText;
  final String? recommendation;
  final Dish? dish;

  const RecipeImportResult({
    required this.success,
    required this.replyText,
    this.recommendation,
    this.dish,
  });
}

class _ExtractedRecipe {
  final String title;
  final String? description;
  final String? servings;
  final List<String> ingredients;
  final List<String> instructions;
  final String sourceUrl;

  const _ExtractedRecipe({
    required this.title,
    this.description,
    this.servings,
    required this.ingredients,
    required this.instructions,
    required this.sourceUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
      'sourceUrl': sourceUrl,
    };
  }
}

class RecipeImportService {
  static const int _maxHtmlBytes = 2 * 1024 * 1024;

  final OpenAIService _openAIService;
  final RecipeHtmlFetcher? _htmlFetcher;
  final RecipeAnalyzer? _recipeAnalyzer;

  const RecipeImportService({
    required OpenAIService openAIService,
    RecipeHtmlFetcher? htmlFetcher,
    RecipeAnalyzer? recipeAnalyzer,
  }) : _openAIService = openAIService,
       _htmlFetcher = htmlFetcher,
       _recipeAnalyzer = recipeAnalyzer;

  Future<RecipeImportResult> importRecipeFromUrl({
    required String recipeUrl,
    String? requestedMealType,
    String? fallbackReplyText,
  }) async {
    final normalizedUrl = _normalizeRecipeUrl(recipeUrl);
    final uri = Uri.tryParse(normalizedUrl);
    if (!_isAllowedRecipeUri(uri)) {
      return const RecipeImportResult(
        success: false,
        replyText:
            'That URL is not allowed for recipe import. Please provide a public http/https recipe URL.',
      );
    }

    final htmlResult =
        _htmlFetcher != null
            ? await _htmlFetcher(uri!)
            : await _fetchHtml(uri!);
    if (htmlResult == null) {
      return const RecipeImportResult(
        success: false,
        replyText:
            'I could not fetch a valid recipe page from that URL. Please try another source.',
      );
    }

    final pageHtml = htmlResult;
    if (!_hasRecipeSignals(pageHtml)) {
      return const RecipeImportResult(
        success: false,
        replyText:
            'I could not detect recipe content on that page. Please share a page with ingredients and instructions.',
      );
    }

    final extracted = _extractRecipe(pageHtml, uri.toString());
    if (extracted == null ||
        extracted.ingredients.isEmpty ||
        extracted.instructions.isEmpty) {
      return const RecipeImportResult(
        success: false,
        replyText:
            'I found a recipe-like page, but could not extract enough structured recipe details to import safely.',
      );
    }

    final analyzed =
        _recipeAnalyzer != null
            ? await _recipeAnalyzer(
              extractedRecipe: extracted.toJson(),
              requestedMealType: requestedMealType,
            )
            : await _analyzeRecipeWithLlm(
              extracted: extracted,
              requestedMealType: requestedMealType,
            );
    if (analyzed == null) {
      return const RecipeImportResult(
        success: false,
        replyText:
            'I could not safely convert that recipe into a dish format right now. Please try a different recipe URL.',
      );
    }

    final dish = _dishFromNormalizedRecipe(analyzed, extracted.sourceUrl);
    if (dish == null) {
      return const RecipeImportResult(
        success: false,
        replyText:
            'I extracted the recipe, but it was incomplete for dish creation. Please try another recipe page.',
      );
    }

    final replyText =
        fallbackReplyText?.trim().isNotEmpty == true
            ? fallbackReplyText!.trim()
            : 'Imported recipe "${dish.name}" from URL and prepared it as a new dish draft.';

    return RecipeImportResult(
      success: true,
      replyText: replyText,
      recommendation: analyzed['recommendation'] as String?,
      dish: dish,
    );
  }

  bool _isAllowedRecipeUri(Uri? uri) {
    if (uri == null) return false;
    if (!(uri.scheme == 'http' || uri.scheme == 'https')) return false;
    if (uri.host.trim().isEmpty) return false;

    final host = uri.host.toLowerCase();
    if (host == 'localhost' || host.endsWith('.local')) return false;

    if (host == '127.0.0.1' || host == '::1') return false;

    if (_isPrivateIpLiteral(host)) return false;

    return true;
  }

  String _normalizeRecipeUrl(String recipeUrl) {
    var normalized = recipeUrl.trim();
    if (normalized.length >= 2) {
      final first = normalized[0];
      final last = normalized[normalized.length - 1];
      if ((first == '"' && last == '"') ||
          (first == '\'' && last == '\'')) {
        normalized = normalized.substring(1, normalized.length - 1).trim();
      }
    }

    return normalized;
  }

  bool _isPrivateIpLiteral(String host) {
    final ipv4 = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (ipv4.hasMatch(host)) {
      final octets = host.split('.').map(int.tryParse).toList();
      if (octets.any((x) => x == null || x < 0 || x > 255)) return true;
      final a = octets[0]!;
      final b = octets[1]!;
      if (a == 10) return true;
      if (a == 127) return true;
      if (a == 169 && b == 254) return true;
      if (a == 172 && b >= 16 && b <= 31) return true;
      if (a == 192 && b == 168) return true;
      return false;
    }

    if (host.contains(':')) {
      final h = host.toLowerCase();
      if (h == '::1') return true;
      if (h.startsWith('fc') || h.startsWith('fd')) return true;
      if (h.startsWith('fe80:')) return true;
    }

    return false;
  }

  Future<String?> _fetchHtml(Uri uri) async {
    try {
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent':
                  'PlatePalTracker/1.0 RecipeImporter (+https://github.com/MrLappes/platepal-tracker-flutter)',
              'Accept': 'text/html,application/xhtml+xml',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode < 200 || response.statusCode >= 400) {
        debugPrint('❌ Recipe import fetch failed: HTTP ${response.statusCode}');
        return null;
      }

      final contentType =
          (response.headers['content-type'] ?? '').toLowerCase();
      if (!(contentType.contains('text/html') ||
          contentType.contains('application/xhtml+xml') ||
          contentType.isEmpty)) {
        debugPrint(
          '❌ Recipe import blocked non-HTML content-type: $contentType',
        );
        return null;
      }

      if (response.bodyBytes.length > _maxHtmlBytes) {
        debugPrint(
          '❌ Recipe import blocked oversized page: ${response.bodyBytes.length} bytes',
        );
        return null;
      }

      return response.body;
    } on TimeoutException {
      debugPrint('❌ Recipe import fetch timeout');
      return null;
    } catch (e) {
      debugPrint('❌ Recipe import fetch error: $e');
      return null;
    }
  }

  bool _hasRecipeSignals(String html) {
    int score = 0;

    final recipeType = RegExp(
      r'"@type"\s*:\s*(?:\[\s*)?"Recipe"',
      caseSensitive: false,
    );
    final recipeMicrodata = RegExp(
      "itemtype\\s*=\\s*['\\\"]https?://schema\\.org/Recipe['\\\"]",
      caseSensitive: false,
    );
    final ingredientWords = RegExp(
      r'\bingredients?\b|recipeIngredient',
      caseSensitive: false,
    );
    final instructionWords = RegExp(
      r'\binstructions?\b|directions?\b|method\b|recipeInstructions',
      caseSensitive: false,
    );

    if (recipeType.hasMatch(html)) score += 3;
    if (recipeMicrodata.hasMatch(html)) score += 3;
    if (ingredientWords.hasMatch(html)) score += 1;
    if (instructionWords.hasMatch(html)) score += 1;

    return score >= 3 &&
        ingredientWords.hasMatch(html) &&
        instructionWords.hasMatch(html);
  }

  _ExtractedRecipe? _extractRecipe(String html, String sourceUrl) {
    final jsonLdRecipe = _extractFromJsonLd(html, sourceUrl);
    if (jsonLdRecipe != null) {
      return jsonLdRecipe;
    }

    return _extractFromMicrodata(html, sourceUrl);
  }

  _ExtractedRecipe? _extractFromJsonLd(String html, String sourceUrl) {
    final scripts = RegExp(
      "<script[^>]*type=['\\\"]application/ld\\+json['\\\"][^>]*>([\\s\\S]*?)</script>",
      caseSensitive: false,
    ).allMatches(html);

    for (final match in scripts) {
      final raw = (match.group(1) ?? '').trim();
      if (raw.isEmpty) continue;

      final candidates = <dynamic>[];
      try {
        candidates.add(jsonDecode(raw));
      } catch (_) {
        final cleaned =
            raw
                .replaceAll(RegExp(r'<!--|-->'), '')
                .replaceAll(RegExp(r'\s+'), ' ')
                .trim();
        try {
          candidates.add(jsonDecode(cleaned));
        } catch (_) {
          continue;
        }
      }

      for (final candidate in candidates) {
        final node = _findRecipeNode(candidate);
        if (node == null) continue;

        final title = _asString(node['name'])?.trim();
        final description = _asString(node['description'])?.trim();
        final servings = _asString(node['recipeYield'])?.trim();

        final ingredients = _normalizeLines(_extractIngredients(node));
        final instructions = _normalizeLines(_extractInstructions(node));

        if (title == null || title.isEmpty) continue;
        if (ingredients.isEmpty || instructions.isEmpty) continue;

        return _ExtractedRecipe(
          title: title,
          description: description,
          servings: servings,
          ingredients: ingredients,
          instructions: instructions,
          sourceUrl: sourceUrl,
        );
      }
    }

    return null;
  }

  Map<String, dynamic>? _findRecipeNode(dynamic value) {
    if (value is Map<String, dynamic>) {
      if (_isRecipeType(value['@type'])) {
        return value;
      }

      final graph = value['@graph'];
      if (graph is List) {
        for (final item in graph) {
          final found = _findRecipeNode(item);
          if (found != null) return found;
        }
      }

      for (final entry in value.values) {
        final found = _findRecipeNode(entry);
        if (found != null) return found;
      }
    } else if (value is List) {
      for (final item in value) {
        final found = _findRecipeNode(item);
        if (found != null) return found;
      }
    }

    return null;
  }

  bool _isRecipeType(dynamic typeField) {
    if (typeField is String) {
      return typeField.toLowerCase() == 'recipe';
    }
    if (typeField is List) {
      return typeField.any((e) => e.toString().toLowerCase() == 'recipe');
    }
    return false;
  }

  List<String> _extractIngredients(Map<String, dynamic> recipeNode) {
    final raw = recipeNode['recipeIngredient'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.split(RegExp(r'\n|;')).map((e) => e.trim()).toList();
    }
    return const [];
  }

  List<String> _extractInstructions(Map<String, dynamic> recipeNode) {
    final raw = recipeNode['recipeInstructions'];

    if (raw is String && raw.trim().isNotEmpty) {
      return raw.split(RegExp(r'\n|\.\s+')).map((e) => e.trim()).toList();
    }

    if (raw is List) {
      final steps = <String>[];
      for (final item in raw) {
        if (item is String) {
          steps.add(item);
        } else if (item is Map<String, dynamic>) {
          final text = _asString(item['text']) ?? _asString(item['name']);
          if (text != null && text.trim().isNotEmpty) {
            steps.add(text.trim());
          }
        }
      }
      return steps;
    }

    if (raw is Map<String, dynamic>) {
      final text = _asString(raw['text']) ?? _asString(raw['name']);
      if (text != null && text.trim().isNotEmpty) {
        return <String>[text.trim()];
      }
    }

    return const [];
  }

  _ExtractedRecipe? _extractFromMicrodata(String html, String sourceUrl) {
    final title =
        _firstGroup(
          RegExp(
            "itemprop\\s*=\\s*['\\\"]name['\\\"][^>]*>([^<]{2,200})<",
            caseSensitive: false,
          ),
          html,
        ) ??
        _firstGroup(
          RegExp(r'<title[^>]*>([^<]{2,200})<', caseSensitive: false),
          html,
        );

    final ingredientsMatches = RegExp(
      "itemprop\\s*=\\s*['\\\"]recipeIngredient['\\\"][^>]*>([\\s\\S]{1,240}?)<",
      caseSensitive: false,
    ).allMatches(html);
    final instructionsMatches = RegExp(
      "itemprop\\s*=\\s*['\\\"]recipeInstructions['\\\"][^>]*>([\\s\\S]{1,360}?)<",
      caseSensitive: false,
    ).allMatches(html);

    final ingredients =
        ingredientsMatches
            .map((m) => _cleanInlineHtml(m.group(1) ?? ''))
            .where((s) => s.isNotEmpty)
            .toList();
    final instructions =
        instructionsMatches
            .map((m) => _cleanInlineHtml(m.group(1) ?? ''))
            .where((s) => s.isNotEmpty)
            .toList();

    final normalizedIngredients = _normalizeLines(ingredients);
    final normalizedInstructions = _normalizeLines(instructions);

    if ((title ?? '').trim().isEmpty ||
        normalizedIngredients.isEmpty ||
        normalizedInstructions.isEmpty) {
      return null;
    }

    return _ExtractedRecipe(
      title: _cleanInlineHtml(title!).trim(),
      description: null,
      servings: null,
      ingredients: normalizedIngredients,
      instructions: normalizedInstructions,
      sourceUrl: sourceUrl,
    );
  }

  List<String> _normalizeLines(List<String> values) {
    final lines = <String>[];
    for (final value in values) {
      final cleaned = _cleanInlineHtml(value);
      if (cleaned.isEmpty) continue;
      lines.add(cleaned);
    }

    final deduped = <String>[];
    final seen = <String>{};
    for (final line in lines) {
      final key = line.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      deduped.add(line);
    }

    return deduped
        .take(40)
        .map((e) => e.length > 240 ? e.substring(0, 240) : e)
        .toList();
  }

  String _cleanInlineHtml(String text) {
    final noTags = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
    return noTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _firstGroup(RegExp regex, String text) {
    final match = regex.firstMatch(text);
    return match?.group(1);
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is List && value.isNotEmpty) {
      return _asString(value.first);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _analyzeRecipeWithLlm({
    required _ExtractedRecipe extracted,
    String? requestedMealType,
  }) async {
    final systemPrompt = '''
You convert extracted recipe data into a strict JSON object for a nutrition app.
Rules:
- Output ONLY valid JSON. No markdown.
- Use realistic nutrition estimates per 100g for each ingredient.
- Keep ingredient names simple and normalized.
- Keep quantities practical for one full recipe batch.
- meal_type must be one of: breakfast, lunch, dinner, snack.
- If uncertain, prefer conservative estimates.

Required JSON shape:
{
  "name": string,
  "description": string,
  "meal_type": "breakfast" | "lunch" | "dinner" | "snack",
  "servings": number,
  "recommendation": string,
  "ingredients": [
    {
      "name": string,
      "quantity": number,
      "unit": string,
      "calories_per_100": number,
      "protein_per_100": number,
      "carbs_per_100": number,
      "fat_per_100": number,
      "fiber_per_100": number
    }
  ]
}
''';

    final userPrompt = '''
Requested meal type: ${requestedMealType ?? 'not specified'}

Extracted recipe payload:
${jsonEncode(extracted.toJson())}
''';

    try {
      final response = await _openAIService.sendChatRequest(
        messages: [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        temperature: 0.2,
        maxTokens: 1400,
      );

      final content = response.choices.first.message.content ?? '';
      final parsed = _extractJsonMap(content);
      return parsed;
    } catch (e) {
      debugPrint('❌ Recipe import LLM analysis failed: $e');
      return null;
    }
  }

  Map<String, dynamic>? _extractJsonMap(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end <= start) return null;

    final candidate = trimmed.substring(start, end + 1);
    try {
      final decoded = jsonDecode(candidate);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }

    return null;
  }

  Dish? _dishFromNormalizedRecipe(
    Map<String, dynamic> normalized,
    String sourceUrl,
  ) {
    final name = (normalized['name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;

    final rawIngredients =
        normalized['ingredients'] as List<dynamic>? ?? const [];
    if (rawIngredients.isEmpty) return null;

    final ingredients = <Ingredient>[];
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    for (final raw in rawIngredients) {
      if (raw is! Map<String, dynamic>) continue;

      final ingredientName = (raw['name'] as String?)?.trim();
      if (ingredientName == null || ingredientName.isEmpty) continue;

      final quantity = _toDouble(raw['quantity']) ?? 100;
      final unit =
          (raw['unit'] as String?)?.trim().isNotEmpty == true
              ? (raw['unit'] as String).trim()
              : 'g';

      final caloriesPer100 = _toDouble(raw['calories_per_100']) ?? 0;
      final proteinPer100 = _toDouble(raw['protein_per_100']) ?? 0;
      final carbsPer100 = _toDouble(raw['carbs_per_100']) ?? 0;
      final fatPer100 = _toDouble(raw['fat_per_100']) ?? 0;
      final fiberPer100 = _toDouble(raw['fiber_per_100']) ?? 0;

      final ingNutrition = NutritionInfo(
        calories: caloriesPer100,
        protein: proteinPer100,
        carbs: carbsPer100,
        fat: fatPer100,
        fiber: fiberPer100,
      );

      ingredients.add(
        Ingredient(
          id: _uuid.v4(),
          name: ingredientName,
          amount: quantity,
          unit: unit,
          nutrition: ingNutrition,
        ),
      );

      final grams = _toGrams(quantity, unit);
      final multiplier = grams / 100.0;
      totalCalories += caloriesPer100 * multiplier;
      totalProtein += proteinPer100 * multiplier;
      totalCarbs += carbsPer100 * multiplier;
      totalFat += fatPer100 * multiplier;
      totalFiber += fiberPer100 * multiplier;
    }

    if (ingredients.isEmpty) return null;

    final now = DateTime.now();
    final sourceSuffix = 'Source: $sourceUrl';
    final description =
        (normalized['description'] as String?)?.trim().isNotEmpty == true
            ? '${(normalized['description'] as String).trim()}\n\n$sourceSuffix'
            : sourceSuffix;

    return Dish(
      id: _uuid.v4(),
      name: name,
      description: description,
      imageUrl: null,
      ingredients: ingredients,
      nutrition: NutritionInfo(
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        fiber: totalFiber,
      ),
      createdAt: now,
      updatedAt: now,
      isFavorite: false,
      category: normalized['meal_type'] as String?,
    );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }
    return null;
  }

  double _toGrams(double quantity, String unit) {
    switch (unit.toLowerCase()) {
      case 'g':
      case 'gram':
      case 'grams':
        return quantity;
      case 'kg':
        return quantity * 1000;
      case 'ml':
        return quantity;
      case 'l':
        return quantity * 1000;
      case 'oz':
        return quantity * 28.35;
      case 'lb':
        return quantity * 453.592;
      case 'tbsp':
        return quantity * 15;
      case 'tsp':
        return quantity * 5;
      case 'cup':
      case 'cups':
        return quantity * 240;
      default:
        return quantity;
    }
  }

  @visibleForTesting
  bool isAllowedRecipeUriForTest(String rawUrl) {
    return _isAllowedRecipeUri(Uri.tryParse(rawUrl));
  }

  @visibleForTesting
  bool hasRecipeSignalsForTest(String html) {
    return _hasRecipeSignals(html);
  }

  @visibleForTesting
  Map<String, dynamic>? extractRecipeForTest(String html, String sourceUrl) {
    final extracted = _extractRecipe(html, sourceUrl);
    return extracted?.toJson();
  }

  @visibleForTesting
  Dish? dishFromNormalizedRecipeForTest(
    Map<String, dynamic> normalized,
    String sourceUrl,
  ) {
    return _dishFromNormalizedRecipe(normalized, sourceUrl);
  }
}
