import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user session data including current user ID
class UserSessionService {
  static const String _currentUserIdKey = 'current_user_id';
  static const String _defaultUserId = 'default';

  final SharedPreferences _prefs;

  UserSessionService(this._prefs);

  /// Get the current user ID from storage, defaulting to 'default' if not set
  String getCurrentUserId() {
    return _prefs.getString(_currentUserIdKey) ?? _defaultUserId;
  }

  /// Set the current user ID in storage
  Future<bool> setCurrentUserId(String userId) {
    return _prefs.setString(_currentUserIdKey, userId);
  }

  /// Clear the current user ID (sets back to default)
  Future<bool> clearCurrentUserId() {
    return _prefs.remove(_currentUserIdKey);
  }

  /// Check if a user is currently logged in (has a non-default user ID)
  bool hasActiveUser() {
    final userId = getCurrentUserId();
    return userId != _defaultUserId;
  }

  /// Initialize with default user if no user is set
  Future<void> initializeDefaultUser() async {
    if (!_prefs.containsKey(_currentUserIdKey)) {
      await setCurrentUserId(_defaultUserId);
    }
  }
}
