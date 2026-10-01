import 'dart:convert';

/// Deep link the PlatePal app sends to share a dish:
/// `platepaltracker://import-dish?d=<base64url(UTF-8 JSON) without padding>`.
const String platePalLinkScheme = 'platepaltracker';
const String platePalImportHost = 'import-dish';

/// In-app route that opens the dish form prefilled from a link.
const String platePalImportRoute = '/import-dish';

enum PlatePalImportError {
  missing,
  tooLarge,
  malformed,
  unsupportedVersion,
  invalidContent,
}

class PlatePalImportException implements Exception {
  const PlatePalImportException(this.error);

  final PlatePalImportError error;

  @override
  String toString() => 'PlatePalImportException(${error.name})';
}

/// A dish shared from PlatePal. Ingredients are names only; the user adds
/// amounts and nutrition before saving.
class PlatePalDishDraft {
  const PlatePalDishDraft({
    required this.name,
    this.description,
    required this.ingredients,
    this.servings,
  });

  final String name;
  final String? description;
  final List<String> ingredients;
  final int? servings;
}

/// Limits of payload format version 1.
const int maxPlatePalPayloadBytes = 16 * 1024;
const int maxPlatePalNameLength = 100;
const int maxPlatePalDescriptionLength = 500;
const int maxPlatePalIngredients = 50;
const int maxPlatePalIngredientLength = 100;

final RegExp _base64UrlChars = RegExp(r'^[A-Za-z0-9_-]+$');

/// C0/C1 control characters, bidi overrides/isolates and zero-width
/// characters (which can disguise text); [allowNewlines] keeps line breaks
/// and tabs.
bool _hasControlCharacters(String value, {bool allowNewlines = false}) =>
    value.runes.any(
      (rune) =>
          (rune < 0x20 &&
              !(allowNewlines &&
                  (rune == 0x0A || rune == 0x0D || rune == 0x09))) ||
          (rune >= 0x7F && rune <= 0x9F) ||
          (rune >= 0x200B && rune <= 0x200F) ||
          (rune >= 0x202A && rune <= 0x202E) ||
          (rune >= 0x2066 && rune <= 0x2069) ||
          rune == 0xFEFF,
    );

/// The in-app location for an incoming `platepaltracker://import-dish` link,
/// or null for any other URI.
String? platePalImportRedirect(Uri uri) {
  if (uri.scheme.toLowerCase() != platePalLinkScheme ||
      uri.host.toLowerCase() != platePalImportHost) {
    return null;
  }
  final payload = uri.queryParameters['d'];
  return Uri(
    path: platePalImportRoute,
    queryParameters: payload == null ? null : {'d': payload},
  ).toString();
}

/// Decodes and strictly validates the `d` parameter of an import link.
/// Throws [PlatePalImportException].
PlatePalDishDraft decodePlatePalDish(String? link) {
  // The contract has no padding; tolerate it anyway.
  final payload = link?.replaceFirst(RegExp(r'={1,2}$'), '');
  if (payload == null || payload.isEmpty) {
    throw const PlatePalImportException(PlatePalImportError.missing);
  }
  // Unpadded base64 needs 4 characters per 3 bytes.
  if (payload.length > (maxPlatePalPayloadBytes * 4 + 2) ~/ 3) {
    throw const PlatePalImportException(PlatePalImportError.tooLarge);
  }
  if (!_base64UrlChars.hasMatch(payload) || payload.length % 4 == 1) {
    throw const PlatePalImportException(PlatePalImportError.malformed);
  }

  final Object? decoded;
  try {
    final bytes = base64Url.decode(base64Url.normalize(payload));
    if (bytes.length > maxPlatePalPayloadBytes) {
      throw const PlatePalImportException(PlatePalImportError.tooLarge);
    }
    decoded = jsonDecode(utf8.decode(bytes));
  } on FormatException {
    throw const PlatePalImportException(PlatePalImportError.malformed);
  }
  if (decoded is! Map<String, dynamic>) {
    throw const PlatePalImportException(PlatePalImportError.malformed);
  }

  final version = decoded['v'];
  if (version is! int) {
    throw const PlatePalImportException(PlatePalImportError.malformed);
  }
  if (version != 1) {
    throw const PlatePalImportException(PlatePalImportError.unsupportedVersion);
  }
  if (decoded['source'] != 'platepal') {
    throw const PlatePalImportException(PlatePalImportError.invalidContent);
  }

  final name = decoded['name'];
  if (name is! String ||
      name.trim().isEmpty ||
      name.trim().length > maxPlatePalNameLength ||
      _hasControlCharacters(name)) {
    throw const PlatePalImportException(PlatePalImportError.invalidContent);
  }

  final description = decoded['description'];
  if (description != null &&
      (description is! String ||
          description.trim().length > maxPlatePalDescriptionLength ||
          _hasControlCharacters(description, allowNewlines: true))) {
    throw const PlatePalImportException(PlatePalImportError.invalidContent);
  }

  final ingredients = decoded['ingredients'];
  if (ingredients is! List || ingredients.length > maxPlatePalIngredients) {
    throw const PlatePalImportException(PlatePalImportError.invalidContent);
  }
  final names = <String>[];
  for (final ingredient in ingredients) {
    if (ingredient is! String ||
        ingredient.trim().isEmpty ||
        ingredient.trim().length > maxPlatePalIngredientLength ||
        _hasControlCharacters(ingredient)) {
      throw const PlatePalImportException(PlatePalImportError.invalidContent);
    }
    names.add(ingredient.trim());
  }

  final servings = decoded['servings'];
  if (servings != null && (servings is! int || servings < 1 || servings > 100)) {
    throw const PlatePalImportException(PlatePalImportError.invalidContent);
  }

  final trimmedDescription = (description as String?)?.trim();
  return PlatePalDishDraft(
    name: name.trim(),
    description:
        trimmedDescription == null || trimmedDescription.isEmpty
            ? null
            : trimmedDescription,
    ingredients: names,
    servings: servings as int?,
  );
}
