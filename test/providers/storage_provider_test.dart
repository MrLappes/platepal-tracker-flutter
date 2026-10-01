import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/providers/locale_provider.dart';
import 'package:platepal_tracker/providers/storage_provider.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('storage failure shows localized recovery actions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app_locale': 'es'});
    final prefs = await SharedPreferences.getInstance();
    final localeProvider = LocaleProvider(prefs: prefs);
    final storageService = _FailingOnceStorageServiceProvider();
    addTearDown(localeProvider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<LocaleProvider>.value(
        value: localeProvider,
        child: StorageProvider(
          storageServiceProvider: storageService,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: Text('Ready'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar tus datos.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Ready'), findsOneWidget);
  });
}

class _FailingOnceStorageServiceProvider extends StorageServiceProvider {
  int _attempts = 0;

  @override
  Future<void> initialize() async {
    if (++_attempts == 1) throw StateError('Database unavailable');
  }

  @override
  Future<void> closeDatabase() async {}
}
