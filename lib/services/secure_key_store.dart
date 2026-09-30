import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single accessor for the user's OpenAI API key, kept in platform secure
/// storage (Keystore / Keychain) instead of plain SharedPreferences.
class SecureKeyStore {
  SecureKeyStore._();

  /// Same name for the legacy SharedPreferences entry and the secure entry.
  static const String apiKeyName = 'openai_api_key';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void>? _migration;

  /// Returns the stored API key, migrating a legacy plaintext value first.
  static Future<String?> readApiKey() async {
    try {
      await _ensureMigrated();
      return await _storage.read(key: apiKeyName);
    } catch (e) {
      debugPrint(
        'SecureKeyStore: secure storage unavailable (${e.runtimeType})',
      );
      // The legacy value is only deleted after a successful migration.
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(apiKeyName);
    }
  }

  static Future<void> writeApiKey(String apiKey) async {
    await _ensureMigrated();
    await _storage.write(key: apiKeyName, value: apiKey);
  }

  static Future<void> deleteApiKey() async {
    try {
      await _ensureMigrated();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(apiKeyName);
    await _storage.delete(key: apiKeyName);
  }

  // Memoized so concurrent callers can't re-copy a stale legacy value over a
  // key saved in the meantime; reset on failure so it is retried.
  static Future<void> _ensureMigrated() {
    return _migration ??= _migrateLegacyKey().catchError((
      Object e,
      StackTrace s,
    ) {
      _migration = null;
      Error.throwWithStackTrace(e, s);
    });
  }

  static Future<void> _migrateLegacyKey() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(apiKeyName);
    if (legacy == null) return;
    final existing = await _storage.read(key: apiKeyName);
    if (legacy.isNotEmpty && (existing == null || existing.isEmpty)) {
      await _storage.write(key: apiKeyName, value: legacy);
    }
    await prefs.remove(apiKeyName);
  }

  @visibleForTesting
  static void resetForTesting() => _migration = null;
}
