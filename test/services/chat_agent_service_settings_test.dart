import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/repositories/dish_repository.dart';
import 'package:platepal_tracker/repositories/meal_repository.dart';
import 'package:platepal_tracker/repositories/user_profile_repository.dart';
import 'package:platepal_tracker/services/chat/chat_agent_service.dart';
import 'package:platepal_tracker/services/chat/openai_service.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';
import 'package:platepal_tracker/services/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ChatAgentService> buildService() async {
    final session = UserSessionService(await SharedPreferences.getInstance());
    return ChatAgentService(
      openaiService: OpenAIService(),
      dishRepository: DishRepository(),
      mealRepository: MealRepository(userSessionService: session),
      userProfileRepository: UserProfileRepository(userSessionService: session),
      dishService: DishService(),
    );
  }

  group('initializeFromPreferences', () {
    test('keeps loaded settings when a later read fails', () async {
      SharedPreferences.setMockInitialValues({'deep_search_enabled': true});
      final service = await buildService();
      await service.initializeFromPreferences();
      expect(service.isDeepSearchEnabled, isTrue);

      // A non-bool value makes getBool throw, simulating a failed read.
      SharedPreferences.setMockInitialValues({
        'deep_search_enabled': 'user@example.com',
      });
      final logs = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
      try {
        await service.initializeFromPreferences();
      } finally {
        debugPrint = originalDebugPrint;
      }

      expect(service.isDeepSearchEnabled, isTrue);
      expect(logs, isNotEmpty);
      expect(logs.join('\n'), isNot(contains('user@example.com')));
    });
  });

  group('loadLanguageCode', () {
    test('uses the saved locale', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'es'});
      expect(await ChatAgentService.loadLanguageCode(const Locale('de')), 'es');
    });

    test('follows a supported device locale when none is saved', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await ChatAgentService.loadLanguageCode(const Locale('de')), 'de');
    });

    test('follows the device locale when the read fails', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 42});
      expect(await ChatAgentService.loadLanguageCode(const Locale('de')), 'de');
    });

    test('uses English for an unsupported device locale on failure', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 42});
      expect(await ChatAgentService.loadLanguageCode(const Locale('fr')), 'en');
    });
  });
}
