import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage/storage_service_provider.dart';

class StorageProvider extends StatefulWidget {
  final Widget child;

  const StorageProvider({super.key, required this.child});

  @override
  StorageProviderState createState() => StorageProviderState();
}

class StorageProviderState extends State<StorageProvider> {
  final StorageServiceProvider _storageServiceProvider =
      StorageServiceProvider();
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _storageServiceProvider.initialize();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
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
      if (_error != null) {
        return MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Error initializing database: $_error')),
          ),
        );
      }
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return ChangeNotifierProvider<StorageServiceProvider>.value(
      value: _storageServiceProvider,
      child: widget.child,
    );
  }
}
