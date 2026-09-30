import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/providers/chat_provider.dart';
import 'package:platepal_tracker/screens/settings/chat_agent_settings_screen.dart';
import 'package:platepal_tracker/services/storage/storage_service_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingStorage extends StorageServiceProvider {
  @override
  Future<SharedPreferences> getPrefs() async =>
      throw StateError('disk failure');
}

void main() {
  testWidgets('save failure shows feedback and re-enables the save button', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final chatProvider = ChatProvider();
    final storage = _FailingStorage();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: chatProvider),
          ChangeNotifierProvider<StorageServiceProvider>.value(value: storage),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChatAgentSettingsScreen(),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();

    expect(find.text('Failed to save chat settings'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
