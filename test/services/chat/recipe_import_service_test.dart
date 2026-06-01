import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/services/chat/openai_service.dart';
import 'package:platepal_tracker/services/chat/recipe_import_service.dart';

void main() {
  group('RecipeImportService URL security', () {
    final service = RecipeImportService(openAIService: OpenAIService());

    test('allows public https URLs', () {
      expect(
        service.isAllowedRecipeUriForTest('https://example.com/recipe'),
        isTrue,
      );
    });

    test('rejects localhost URLs', () {
      expect(
        service.isAllowedRecipeUriForTest('http://localhost:3000/recipe'),
        isFalse,
      );
    });

    test('rejects loopback and private IPv4 URLs', () {
      expect(
        service.isAllowedRecipeUriForTest('http://127.0.0.1/recipe'),
        isFalse,
      );
      expect(
        service.isAllowedRecipeUriForTest('http://192.168.1.10/recipe'),
        isFalse,
      );
      expect(
        service.isAllowedRecipeUriForTest('http://10.0.0.3/recipe'),
        isFalse,
      );
      expect(
        service.isAllowedRecipeUriForTest('http://172.16.0.5/recipe'),
        isFalse,
      );
    });

    test('rejects non-http schemes', () {
      expect(
        service.isAllowedRecipeUriForTest('ftp://example.com/recipe'),
        isFalse,
      );
    });
  });

  group('RecipeImportService recipe detection and extraction', () {
    final service = RecipeImportService(openAIService: OpenAIService());

    const recipeJsonLdHtml = '''
<html>
  <head>
    <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "Recipe",
        "name": "Simple Tomato Pasta",
        "description": "Quick pasta recipe",
        "recipeYield": "2 servings",
        "recipeIngredient": ["200 g pasta", "300 g tomatoes", "10 g olive oil"],
        "recipeInstructions": [
          {"@type": "HowToStep", "text": "Boil pasta."},
          {"@type": "HowToStep", "text": "Cook tomatoes with oil."},
          {"@type": "HowToStep", "text": "Combine and serve."}
        ]
      }
    </script>
  </head>
  <body><h1>Simple Tomato Pasta</h1></body>
</html>
''';

    test('detects recipe signals in JSON-LD recipe page', () {
      expect(service.hasRecipeSignalsForTest(recipeJsonLdHtml), isTrue);
    });

    test('extracts recipe payload from JSON-LD', () {
      final extracted = service.extractRecipeForTest(
        recipeJsonLdHtml,
        'https://example.com/simple-tomato-pasta',
      );

      expect(extracted, isNotNull);
      expect(extracted!['title'], 'Simple Tomato Pasta');
      expect(
        (extracted['ingredients'] as List).length,
        greaterThanOrEqualTo(3),
      );
      expect(
        (extracted['instructions'] as List).length,
        greaterThanOrEqualTo(3),
      );
    });

    test('does not detect non-recipe HTML as recipe', () {
      const nonRecipe =
          '<html><body><h1>Welcome</h1><p>Just an article.</p></body></html>';
      expect(service.hasRecipeSignalsForTest(nonRecipe), isFalse);
    });
  });

  group('RecipeImportService import pipeline', () {
    test('imports a recipe URL into a dish with safe DI pipeline', () async {
      const html = '''
<html>
  <head>
    <script type="application/ld+json">
      {
        "@type": "Recipe",
        "name": "Protein Oats",
        "recipeIngredient": ["80 g oats", "250 ml milk"],
        "recipeInstructions": ["Mix ingredients", "Cook and serve"]
      }
    </script>
  </head>
</html>
''';

      final service = RecipeImportService(
        openAIService: OpenAIService(),
        htmlFetcher: (_) async => html,
        recipeAnalyzer: ({required extractedRecipe, requestedMealType}) async {
          return {
            'name': 'Protein Oats',
            'description': 'Creamy oats bowl',
            'meal_type': requestedMealType ?? 'breakfast',
            'recommendation': 'Add berries for extra fiber.',
            'ingredients': [
              {
                'name': 'Oats',
                'quantity': 80,
                'unit': 'g',
                'calories_per_100': 389,
                'protein_per_100': 16.9,
                'carbs_per_100': 66.3,
                'fat_per_100': 6.9,
                'fiber_per_100': 10.6,
              },
              {
                'name': 'Milk',
                'quantity': 250,
                'unit': 'ml',
                'calories_per_100': 61,
                'protein_per_100': 3.2,
                'carbs_per_100': 4.8,
                'fat_per_100': 3.3,
                'fiber_per_100': 0,
              },
            ],
          };
        },
      );

      final result = await service.importRecipeFromUrl(
        recipeUrl: 'https://example.com/protein-oats',
        requestedMealType: 'breakfast',
      );

      expect(result.success, isTrue);
      expect(result.dish, isNotNull);
      expect(result.dish!.name, 'Protein Oats');
      expect(result.dish!.ingredients.length, 2);
      expect(
        result.dish!.description,
        contains('Source: https://example.com/protein-oats'),
      );
    });

    test('blocks non-recipe page before analyzer call', () async {
      var analyzerCalled = false;

      final service = RecipeImportService(
        openAIService: OpenAIService(),
        htmlFetcher:
            (_) async =>
                '<html><body><h1>News article</h1><p>No recipe here.</p></body></html>',
        recipeAnalyzer: ({required extractedRecipe, requestedMealType}) async {
          analyzerCalled = true;
          return null;
        },
      );

      final result = await service.importRecipeFromUrl(
        recipeUrl: 'https://example.com/article',
      );

      expect(result.success, isFalse);
      expect(result.replyText, contains('could not detect recipe content'));
      expect(analyzerCalled, isFalse);
    });

    test('accepts quoted recipe URLs from tool arguments', () async {
      const html = '''
<html>
  <head>
    <script type="application/ld+json">
      {
        "@type": "Recipe",
        "name": "Quoted URL Pasta",
        "recipeIngredient": ["100 g pasta", "50 g sauce"],
        "recipeInstructions": ["Boil pasta", "Add sauce"]
      }
    </script>
  </head>
</html>
''';

      final service = RecipeImportService(
        openAIService: OpenAIService(),
        htmlFetcher: (_) async => html,
        recipeAnalyzer: ({required extractedRecipe, requestedMealType}) async {
          return {
            'name': 'Quoted URL Pasta',
            'ingredients': [
              {
                'name': 'Pasta',
                'quantity': 100,
                'unit': 'g',
                'calories_per_100': 350,
                'protein_per_100': 12,
                'carbs_per_100': 70,
                'fat_per_100': 2,
              },
            ],
          };
        },
      );

      final result = await service.importRecipeFromUrl(
        recipeUrl: '"https://example.com/quoted-url-pasta"',
      );

      expect(result.success, isTrue);
      expect(result.dish, isNotNull);
      expect(result.dish!.name, 'Quoted URL Pasta');
    });
  });
}
