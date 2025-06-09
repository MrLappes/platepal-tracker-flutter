import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/settings/about_screen.dart';
import 'screens/settings/api_key_settings_screen.dart';
import 'screens/settings/profile_settings_screen.dart';
import 'screens/settings/statistics_screen.dart';
import 'screens/settings/nutrition_goals_screen.dart';
import 'screens/settings/contributors_screen.dart';
import 'screens/settings/export_data_screen.dart';
import 'screens/settings/import_data_screen.dart';
import 'screens/settings/chat_agent_settings_screen.dart';
import 'providers/meal_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/storage_provider.dart';
import 'providers/app_state_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: StorageProvider(child: const PlatePalApp()),
    ),
  );
}

class PlatePalApp extends StatelessWidget {
  const PlatePalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, ThemeProvider>(
      builder: (context, localeProvider, themeProvider, child) {
        return MaterialApp.router(
          title: 'PlatePal Tracker',
          theme: themeProvider.materialTheme,
          darkTheme: themeProvider.materialTheme,
          themeMode: _getThemeMode(themeProvider.themePreference),
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
        );
      },
    );
  }

  ThemeMode _getThemeMode(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(path: '/meals', builder: (context, state) => const MealsScreen()),
    GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(
      path: '/settings/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ), // Settings routes
    GoRoute(
      path: '/settings/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: '/settings/api-key',
      builder: (context, state) => const ApiKeySettingsScreen(),
    ),
    GoRoute(
      path: '/settings/profile',
      builder: (context, state) => const ProfileSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/nutrition-goals',
      builder: (context, state) => const NutritionGoalsScreen(),
    ),
    GoRoute(
      path: '/settings/contributors',
      builder: (context, state) => const ContributorsScreen(),
    ),
    GoRoute(
      path: '/settings/contributions',
      builder: (context, state) => const ContributorsScreen(),
    ),
    GoRoute(
      path: '/settings/export-data',
      builder: (context, state) => const ExportDataScreen(),
    ),
    GoRoute(
      path: '/settings/import-data',
      builder: (context, state) => const ImportDataScreen(),
    ),
    GoRoute(
      path: '/settings/chat-agent',
      builder: (context, state) => const ChatAgentSettingsScreen(),
    ),
  ],
);
