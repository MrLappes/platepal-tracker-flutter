import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/services/secure_key_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _name = SecureKeyStore.apiKeyName;

Future<String?> _secureValue() => const FlutterSecureStorage().read(key: _name);

Future<String?> _prefsValue() async =>
    (await SharedPreferences.getInstance()).getString(_name);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(SecureKeyStore.resetForTesting);

  // Must run before setMockInitialValues replaces the (unregistered) plugin.
  test(
    'keeps the legacy key usable when secure storage is unavailable',
    () async {
      SharedPreferences.setMockInitialValues({_name: 'sk-legacy'});

      expect(await SecureKeyStore.readApiKey(), 'sk-legacy');
      expect(await _prefsValue(), 'sk-legacy');
    },
  );

  group('with secure storage', () {
    test(
      'migrates a legacy prefs key and deletes the plaintext copy',
      () async {
        SharedPreferences.setMockInitialValues({_name: 'sk-legacy'});
        FlutterSecureStorage.setMockInitialValues({});

        expect(await SecureKeyStore.readApiKey(), 'sk-legacy');
        expect(await _secureValue(), 'sk-legacy');
        expect(await _prefsValue(), isNull);
      },
    );

    test('an already stored secure key wins over a stale legacy one', () async {
      SharedPreferences.setMockInitialValues({_name: 'sk-old'});
      FlutterSecureStorage.setMockInitialValues({_name: 'sk-new'});

      expect(await SecureKeyStore.readApiKey(), 'sk-new');
      expect(await _prefsValue(), isNull);
    });

    test('returns null when no key exists anywhere', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});

      expect(await SecureKeyStore.readApiKey(), isNull);
    });

    test('write stores only in secure storage', () async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});

      await SecureKeyStore.writeApiKey('sk-written');

      expect(await SecureKeyStore.readApiKey(), 'sk-written');
      expect(await _secureValue(), 'sk-written');
      expect(await _prefsValue(), isNull);
    });

    test('delete removes the key from secure storage and prefs', () async {
      SharedPreferences.setMockInitialValues({_name: 'sk-legacy'});
      FlutterSecureStorage.setMockInitialValues({_name: 'sk-secure'});

      await SecureKeyStore.deleteApiKey();

      expect(await SecureKeyStore.readApiKey(), isNull);
      expect(await _secureValue(), isNull);
      expect(await _prefsValue(), isNull);
    });
  });
}
