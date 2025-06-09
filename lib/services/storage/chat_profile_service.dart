import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/chat_profile.dart';

class ChatProfileService {
  static const String _userProfileKey = 'chat_user_profile';
  static const String _botProfileKey = 'chat_bot_profile';

  /// Load user chat profile
  static Future<ChatUserProfile> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_userProfileKey);

      if (profileJson != null) {
        final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
        return ChatUserProfile.fromJson(profileData);
      }
    } catch (e) {
      // If there's an error loading, return default
    }

    // Return default user profile
    return ChatUserProfile(
      userId: '1',
      username: 'You',
      lastUpdated: DateTime.now(),
    );
  }

  /// Save user chat profile
  static Future<bool> saveUserProfile(ChatUserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updatedProfile = profile.copyWith(lastUpdated: DateTime.now());
      final profileJson = jsonEncode(updatedProfile.toJson());
      await prefs.setString(_userProfileKey, profileJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load bot chat profile
  static Future<ChatBotProfile> loadBotProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_botProfileKey);

      if (profileJson != null) {
        final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
        return ChatBotProfile.fromJson(profileData);
      }
    } catch (e) {
      // If there's an error loading, return default
    }

    // Return default bot profile
    return ChatBotProfile(
      botId: 'platepal_assistant',
      name: 'PlatePal Assistant',
      personalityType: BotPersonalityType.nice.value,
      behaviorType: 'helpful_expert',
      lastUpdated: DateTime.now(),
    );
  }

  /// Save bot chat profile
  static Future<bool> saveBotProfile(ChatBotProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final updatedProfile = profile.copyWith(lastUpdated: DateTime.now());
      final profileJson = jsonEncode(updatedProfile.toJson());
      await prefs.setString(_botProfileKey, profileJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load both profiles
  static Future<ChatProfiles> loadChatProfiles() async {
    final userProfile = await loadUserProfile();
    final botProfile = await loadBotProfile();

    return ChatProfiles(userProfile: userProfile, botProfile: botProfile);
  }

  /// Save both profiles
  static Future<bool> saveChatProfiles(ChatProfiles profiles) async {
    final userSaved = await saveUserProfile(profiles.userProfile);
    final botSaved = await saveBotProfile(profiles.botProfile);

    return userSaved && botSaved;
  }

  /// Reset profiles to default
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    await prefs.remove(_botProfileKey);
  }
}
