import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.menu),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
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
            title: AppLocalizations.of(context)!.profile,
            icon: Icons.person,
            children: [
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context)!.userProfile,
                subtitle: AppLocalizations.of(context)!.editPersonalInfo,
                icon: Icons.account_circle,
                onTap: () => context.push('/settings/profile'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context)!.nutritionGoals,
                subtitle: AppLocalizations.of(context)!.setNutritionTargets,
                icon: Icons.track_changes,
                onTap: () => context.push('/settings/nutrition-goals'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context)!.viewStatistics,
                subtitle: AppLocalizations.of(context)!.currentStats,
                icon: Icons.analytics,
                onTap: () => context.push('/settings/statistics'),
              ),
            ],
          ),

          _buildSettingsSection(
            context,
            title: AppLocalizations.of(context)!.appearance,
            icon: Icons.palette,
            children: [
              _buildThemeSelector(context),
              _buildLanguageSelector(context),
            ],
          ),

          // AI & Features Section
          _buildSettingsSection(
            context,
            title: AppLocalizations.of(context)!.aiFeatures,
            icon: Icons.smart_toy,
            children: [
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context)!.apiKeySettings,
                subtitle: AppLocalizations.of(context)!.configureApiKey,
                icon: Icons.key,
                onTap: () => context.push('/settings/api-key'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context)!.chatAgentOptions,
                subtitle:
                    AppLocalizations.of(context)!.enableAgentModeDeepSearch,
                icon: Icons.psychology,
                onTap: () => context.push('/settings/chat-agent'),
              ),
            ],
          ),

          _buildSettingsSection(
            context,
            title: AppLocalizations.of(context)!.dataManagement,
            icon: Icons.storage,
            children: [
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context)!.exportData,
                subtitle: AppLocalizations.of(context)!.exportMealData,
                icon: Icons.file_download,
                onTap: () => context.push('/settings/export-data'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context)!.importData,
                subtitle: AppLocalizations.of(context)!.importMealDataBackup,
                icon: Icons.file_upload,
                onTap: () => context.push('/settings/import-data'),
              ),
            ],
          ),
          _buildSettingsSection(
            context,
            title: AppLocalizations.of(context)!.information,
            icon: Icons.info,
            children: [
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context)!.about,
                subtitle: AppLocalizations.of(context)!.learnMorePlatePal,
                icon: Icons.info_outline,
                onTap: () => context.push('/settings/about'),
              ),
              _buildSettingsTile(
                context,
                title: AppLocalizations.of(context)!.contributors,
                subtitle: AppLocalizations.of(context)!.viewContributors,
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icons/icon.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 40,
                      color: const Color(
                        0xFFe384c7,
                      ), // PlatePal color for the icon
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'PlatePal Tracker',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.madeBy,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Card(margin: EdgeInsets.zero, child: Column(children: children)),
        const SizedBox(height: 16),
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
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.outline,
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Filter out Light and Dark themes, only show base themes
        final baseThemes =
            themeProvider.availableThemes
                .where((themeName) => !['Light', 'Dark'].contains(themeName))
                .toList();

        return ExpansionTile(
          leading: Icon(
            Icons.palette,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(AppLocalizations.of(context)!.theme),
          subtitle: Text(themeProvider.currentThemeName),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Theme Mode Selection
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeModeButton(
                          context,
                          AppLocalizations.of(context)!.light,
                          Icons.light_mode,
                          ThemePreference.light,
                          themeProvider,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeModeButton(
                          context,
                          AppLocalizations.of(context)!.dark,
                          Icons.dark_mode,
                          ThemePreference.dark,
                          themeProvider,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeModeButton(
                          context,
                          AppLocalizations.of(context)!.system,
                          Icons.brightness_auto,
                          ThemePreference.system,
                          themeProvider,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Theme Color Selection (only base themes)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        baseThemes.map((themeName) {
                          final isSelected =
                              themeProvider.currentThemeName == themeName;
                          return GestureDetector(
                            onTap:
                                () => themeProvider.setThemeByName(themeName),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                themeName,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ],
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
    final isSelected = themeProvider.themePreference == preference;

    return GestureDetector(
      onTap: () => themeProvider.setThemePreference(preference),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
        return ListTile(
          leading: Icon(
            Icons.language,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          title: Text(AppLocalizations.of(context)!.language),
          subtitle: Text(_getLanguageName(localeProvider.locale.languageCode)),
          trailing: DropdownButton<String>(
            value: localeProvider.locale.languageCode,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'es', child: Text('Español')),
              DropdownMenuItem(value: 'de', child: Text('Deutsch')),
            ],
            onChanged: (String? languageCode) {
              if (languageCode != null) {
                localeProvider.setLocale(Locale(languageCode));
              }
            },
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
