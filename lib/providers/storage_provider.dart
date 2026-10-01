import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import 'locale_provider.dart';
import 'theme_provider.dart';
import '../services/storage/storage_service_provider.dart';

class StorageProvider extends StatefulWidget {
  final Widget child;
  final StorageServiceProvider? storageServiceProvider;

  const StorageProvider({
    super.key,
    required this.child,
    this.storageServiceProvider,
  });

  @override
  StorageProviderState createState() => StorageProviderState();
}

class StorageProviderState extends State<StorageProvider> {
  late final StorageServiceProvider _storageServiceProvider;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _storageServiceProvider =
        widget.storageServiceProvider ?? StorageServiceProvider();
    _initialize();
  }

  Future<void> _initialize() async {
    if (_error != null) {
      setState(() => _error = null);
    }
    try {
      await _storageServiceProvider.initialize();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize database: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    // Close database connections
    _storageServiceProvider.closeDatabase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      final themeProvider = context.watch<ThemeProvider?>();
      return MaterialApp(
        theme: themeProvider?.lightTheme,
        darkTheme: themeProvider?.darkTheme,
        themeMode: switch (themeProvider?.themePreference) {
          ThemePreference.light => ThemeMode.light,
          ThemePreference.dark => ThemeMode.dark,
          _ => ThemeMode.system,
        },
        locale: context.watch<LocaleProvider>().selectedLocale,
        localeResolutionCallback: (locale, supportedLocales) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return const Locale('en');
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child:
                _error == null
                    ? const CircularProgressIndicator()
                    : Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context);
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.providersStorageError,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _initialize,
                                child: Text(l10n.providersStorageRetry),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider<StorageServiceProvider>.value(
      value: _storageServiceProvider,
      child: widget.child,
    );
  }
}
