import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/providers/locale_provider.dart';
import 'package:platepal_tracker/providers/storage_provider.dart';
import 'package:platepal_tracker/providers/theme_provider.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'startup fallback uses saved theme during storage initialization',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'theme_preference': 'dark',
        'theme_name': 'Oceanic',
      });
      final prefs = await SharedPreferences.getInstance();
      final localeProvider = LocaleProvider(prefs: prefs);
      final themeProvider = ThemeProvider(prefs: prefs);
      addTearDown(localeProvider.dispose);
      addTearDown(themeProvider.dispose);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
            ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ],
          child: StorageProvider(
            storageServiceProvider: _FailingStorageServiceProvider(),
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(app.darkTheme?.colorScheme.primary, const Color(0xFF0077BE));
    },
  );
}

class _FailingStorageServiceProvider extends StorageServiceProvider {
  @override
  Future<void> initialize() async => throw StateError('Storage unavailable');

  @override
  Future<void> closeDatabase() async {}
}
