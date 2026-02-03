import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context).componentsUiCustomTabBarMenu.toUpperCase()} //',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Logo Section
          _buildAppLogoSection(context),
          const SizedBox(height: 24),

          // Settings Sections
          _buildSettingsSection(
            context,
            title: AppLocalizations.of(context).screensMenuProfile,
            icon: Icons.person,
            children: [
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context).screensMenuUserProfile,
                subtitle:
                    AppLocalizations.of(context).screensMenuEditPersonalInfo,
                icon: Icons.account_circle,
                onTap: () => context.push('/settings/profile'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context).screensMenuNutritionGoals,
                subtitle:
                    AppLocalizations.of(context).screensMenuSetNutritionTargets,
                icon: Icons.track_changes,
                onTap: () => context.push('/settings/nutrition-goals'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context).screensMenuViewStatistics,
                subtitle: AppLocalizations.of(context).screensMenuCurrentStats,
                icon: Icons.analytics,
                onTap: () => context.push('/settings/statistics'),
              ),
            ],
          ),

          _buildSettingsSection(
            context,
            title: AppLocalizations.of(context).screensMenuAppearance,
            icon: Icons.palette,
            children: [
              _buildThemeSelector(context),
              _buildLanguageSelector(context),
            ],
          ),

          // AI & Features Section
          _buildSettingsSection(
            context,
            title: AppLocalizations.of(context).screensMenuAiFeatures,
            icon: Icons.smart_toy,
            children: [
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context).screensMenuApiKeySettings,
                subtitle:
                    AppLocalizations.of(context).screensMenuConfigureApiKey,
                icon: Icons.key,
                onTap: () => context.push('/settings/api-key'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context).screensMenuChatAgentOptions,
                subtitle:
                    AppLocalizations.of(
                      context,
                    ).screensMenuEnableAgentModeDeepSearch,
                icon: Icons.psychology,
                onTap: () => context.push('/settings/chat-agent'),
              ),
            ],
          ),

          _buildSettingsSection(
            context,
            title: AppLocalizations.of(context).screensMenuDataManagement,
            icon: Icons.storage,
            children: [
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context).screensMenuExportData,
                subtitle:
                    AppLocalizations.of(context).screensMenuExportMealData,
                icon: Icons.file_download,
                onTap: () => context.push('/settings/export-data'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context).screensMenuImportData,
                subtitle:
                    AppLocalizations.of(
                      context,
                    ).screensMenuImportMealDataBackup,
                icon: Icons.file_upload,
                onTap: () => context.push('/settings/import-data'),
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            title: AppLocalizations.of(context).screensMenuInformation,
            icon: Icons.info,
            children: [
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context).screensMenuAbout,
                subtitle:
                    AppLocalizations.of(context).screensMenuLearnMorePlatePal,
                icon: Icons.info_outline,
                onTap: () => context.push('/settings/about'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context).screensMenuContributors,
                subtitle:
                    AppLocalizations.of(context).screensMenuViewContributors,
                icon: Icons.people,
                onTap: () => context.push('/settings/contributions'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogoSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.asset(
                'assets/icons/icon.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PLATEPAL TRACKER',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).screensMenuMadeBy.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 14,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        // Filter out Light and Dark themes, only show base themes
        final baseThemes =
            themeProvider.availableThemes
                .where((themeName) => !['Light', 'Dark'].contains(themeName))
                .toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.palette, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          ).screensMenuTheme.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          themeProvider.currentThemeName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Theme Mode Selection
              Row(
                children: [
                  Expanded(
                    child: _buildThemeModeButton(
                      context,
                      AppLocalizations.of(context).screensMenuLight,
                      Icons.light_mode,
                      ThemePreference.light,
                      themeProvider,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemeModeButton(
                      context,
                      AppLocalizations.of(context).screensMenuDark,
                      Icons.dark_mode,
                      ThemePreference.dark,
                      themeProvider,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildThemeModeButton(
                      context,
                      AppLocalizations.of(context).screensMenuSystem,
                      Icons.brightness_auto,
                      ThemePreference.system,
                      themeProvider,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Theme Color Selection (only base themes)
              Column(
                children:
                    baseThemes.map((themeName) {
                      final isSelected =
                          themeProvider.currentThemeName == themeName;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              themeProvider.setThemeByName(themeName);
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Ink(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? colorScheme.primary
                                        : colorScheme.surface,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outline.withValues(
                                            alpha: 0.5,
                                          ),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                themeName.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color:
                                      isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeButton(
    BuildContext context,
    String label,
    IconData icon,
    ThemePreference preference,
    ThemeProvider themeProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = themeProvider.themePreference == preference;

    return GestureDetector(
      onTap: () => themeProvider.setThemePreference(preference),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.language, size: 18, color: colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).screensMenuLanguage.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getLanguageName(localeProvider.locale.languageCode),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: localeProvider.locale.languageCode,
                  underline: const SizedBox(),
                  isDense: true,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('EN')),
                    DropdownMenuItem(value: 'es', child: Text('ES')),
                    DropdownMenuItem(value: 'de', child: Text('DE')),
                  ],
                  onChanged: (String? languageCode) {
                    if (languageCode != null) {
                      localeProvider.setLocale(Locale(languageCode));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      default:
        return 'English';
    }
  }
}
