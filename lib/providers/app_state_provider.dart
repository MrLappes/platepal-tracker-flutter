import 'package:flutter/foundation.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh app data after import/export operations
  Future<void> refreshData() async {
    setLoading(true);
    try {
      // Add any data refresh logic here
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate refresh
      clearError();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
