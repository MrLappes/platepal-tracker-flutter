import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';

class LinkHandler {
  /// Opens a URL with smart app detection
  /// For GitHub URLs, tries to open GitHub app first, then falls back to web
  /// For other URLs, opens in external browser
  static Future<void> openUrl(
    BuildContext context,
    String url, {
    bool showLoadingMessage = false,
    String? loadingMessage,
  }) async {
    if (!context.mounted) return;

    final localizations = AppLocalizations.of(context);

    // Show loading message if requested
    if (showLoadingMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loadingMessage ?? localizations?.openingLink ?? 'Opening link...',
          ),
          duration: const Duration(milliseconds: 500),
        ),
      );
    }

    try {
      // Determine the type of URL and handle accordingly
      if (url.contains('github.com')) {
        await _openGitHubUrl(context, url);
      } else {
        await _openGenericUrl(context, url);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations?.linkError ?? 'An error occurred opening the link',
            ),
          ),
        );
      }
    }
  }

  /// Handles GitHub URLs with app preference
  static Future<void> _openGitHubUrl(BuildContext context, String url) async {
    final localizations = AppLocalizations.of(context);

    // Try to open in GitHub app first (if available)
    try {
      final gitHubAppUrl = _convertToGitHubAppUrl(url);
      final gitHubUri = Uri.parse(gitHubAppUrl);

      if (await canLaunchUrl(gitHubUri)) {
        final success = await launchUrl(
          gitHubUri,
          mode: LaunchMode.externalApplication,
        );
        if (success) return;
      }
    } catch (e) {
      // GitHub app not available or URL conversion failed, continue to web
    }

    // Fall back to opening in web browser
    try {
      final webUri = Uri.parse(url);
      if (await canLaunchUrl(webUri)) {
        final success = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        if (success) return;
      } // Try with platformDefault mode as fallback
      try {
        final success = await launchUrl(
          webUri,
          mode: LaunchMode.platformDefault,
        );
        if (success) return;
      } catch (e) {
        // Continue to error handling
      }

      if (context.mounted) {
        _showErrorMessage(context, url, localizations?.couldNotOpenUrl);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, url, null, localizations?.linkError);
      }
    }
  }

  /// Handles generic URLs
  static Future<void> _openGenericUrl(BuildContext context, String url) async {
    final localizations = AppLocalizations.of(context);

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        final success = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (success) return;
      } // Try with platformDefault mode as fallback
      try {
        final success = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (success) return;
      } catch (e) {
        // Continue to error handling
      }

      if (context.mounted) {
        _showErrorMessage(context, url, localizations?.couldNotOpenUrl);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage(context, url, null, localizations?.linkError);
      }
    }
  }

  /// Converts GitHub web URLs to GitHub app URLs
  static String _convertToGitHubAppUrl(String url) {
    // GitHub app uses github:// scheme
    // Convert https://github.com/user/repo to github://github.com/user/repo
    if (url.startsWith('https://github.com/')) {
      return url.replaceFirst('https://', 'github://');
    }
    return url;
  }

  /// Shows error message when URL cannot be opened
  static void _showErrorMessage(
    BuildContext context,
    String url,
    String? Function(String)? messageFunction, [
    String? fallbackMessage,
  ]) {
    if (!context.mounted) return;

    final message =
        messageFunction?.call(url) ?? fallbackMessage ?? 'Could not open $url';

    // In debug mode, show more detailed information
    final debugMessage =
        kDebugMode
            ? '$message\n(This is expected in emulator - no browser/app available)'
            : message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(debugMessage),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Convenience method for opening GitHub profiles
  static Future<void> openGitHubProfile(
    BuildContext context,
    String username,
  ) async {
    await openUrl(context, 'https://github.com/$username');
  }

  /// Convenience method for opening GitHub repositories
  static Future<void> openGitHubRepo(
    BuildContext context,
    String owner,
    String repo,
  ) async {
    await openUrl(context, 'https://github.com/$owner/$repo');
  }

  /// Convenience method for opening Buy Me Coffee/Creatine with loading message
  static Future<void> openBuyMeCreatine(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    await openUrl(
      context,
      'https://www.buymeacoffee.com/mrlappes',
      showLoadingMessage: true,
      loadingMessage:
          localizations?.openingLink ?? 'Opening Buy Me Creatine page...',
    );
  }

  /// Convenience method for opening the PlatePal website
  static Future<void> openPlatePalWebsite(BuildContext context) async {
    await openUrl(context, 'https://plate-pal.de');
  }

  /// Test method to verify URL launching capabilities
  static Future<void> testUrlLaunching(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final urls = [
      'https://flutter.dev',
      'https://github.com/MrLappes/platepal-tracker',
      'https://plate-pal.de',
    ];

    for (final url in urls) {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);

      if (kDebugMode) {
        print('URL: $url, Can launch: $canLaunch');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$url: ${canLaunch ? l10n.available : l10n.notAvailable}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 1200));
    }
  }
}
