import 'package:flutter/foundation.dart';

/// User profile for chat customization
class ChatUserProfile {
  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime lastUpdated;

  const ChatUserProfile({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.lastUpdated,
  });

  factory ChatUserProfile.fromJson(Map<String, dynamic> json) {
    return ChatUserProfile(
      userId: json['userId'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  ChatUserProfile copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    DateTime? lastUpdated,
  }) {
    return ChatUserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatUserProfile &&
        other.userId == userId &&
        other.username == username &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode {
    return userId.hashCode ^ username.hashCode ^ avatarUrl.hashCode;
  }
}

/// Bot profile for chat customization
class ChatBotProfile {
  final String botId;
  final String name;
  final String? avatarUrl;
  final String personalityType;
  final String behaviorType;
  final Map<String, dynamic>? additionalConfig;
  final DateTime lastUpdated;

  const ChatBotProfile({
    required this.botId,
    required this.name,
    this.avatarUrl,
    required this.personalityType,
    required this.behaviorType,
    this.additionalConfig,
    required this.lastUpdated,
  });

  factory ChatBotProfile.fromJson(Map<String, dynamic> json) {
    return ChatBotProfile(
      botId: json['botId'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      personalityType: json['personalityType'] as String,
      behaviorType: json['behaviorType'] as String,
      additionalConfig: json['additionalConfig'] as Map<String, dynamic>?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'botId': botId,
      'name': name,
      'avatarUrl': avatarUrl,
      'personalityType': personalityType,
      'behaviorType': behaviorType,
      'additionalConfig': additionalConfig,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  ChatBotProfile copyWith({
    String? botId,
    String? name,
    String? avatarUrl,
    String? personalityType,
    String? behaviorType,
    Map<String, dynamic>? additionalConfig,
    DateTime? lastUpdated,
  }) {
    return ChatBotProfile(
      botId: botId ?? this.botId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      personalityType: personalityType ?? this.personalityType,
      behaviorType: behaviorType ?? this.behaviorType,
      additionalConfig: additionalConfig ?? this.additionalConfig,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatBotProfile &&
        other.botId == botId &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.personalityType == personalityType &&
        other.behaviorType == behaviorType &&
        mapEquals(other.additionalConfig, additionalConfig);
  }

  @override
  int get hashCode {
    return botId.hashCode ^
        name.hashCode ^
        avatarUrl.hashCode ^
        personalityType.hashCode ^
        behaviorType.hashCode ^
        additionalConfig.hashCode;
  }
}

/// Available personality types for bots
enum BotPersonalityType {
  nutritionist('nutritionist', 'Professional Nutritionist'),
  casualGymbro('casualGymbro', 'Casual Gym Bro'),
  angryGreg('angryGreg', 'Angry Greg'),
  veryAngryBro('veryAngryBro', 'Very Angry Bro'),
  fitnessCoach('fitnessCoach', 'Fitness Coach'),
  nice('nice', 'Nice & Friendly');

  const BotPersonalityType(this.value, this.displayName);

  final String value;
  final String displayName;

  static BotPersonalityType fromString(String value) {
    return BotPersonalityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BotPersonalityType.nice,
    );
  }
}

/// Chat profiles container
class ChatProfiles {
  final ChatUserProfile userProfile;
  final ChatBotProfile botProfile;

  const ChatProfiles({required this.userProfile, required this.botProfile});

  factory ChatProfiles.fromJson(Map<String, dynamic> json) {
    return ChatProfiles(
      userProfile: ChatUserProfile.fromJson(
        json['userProfile'] as Map<String, dynamic>,
      ),
      botProfile: ChatBotProfile.fromJson(
        json['botProfile'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userProfile': userProfile.toJson(),
      'botProfile': botProfile.toJson(),
    };
  }

  ChatProfiles copyWith({
    ChatUserProfile? userProfile,
    ChatBotProfile? botProfile,
  }) {
    return ChatProfiles(
      userProfile: userProfile ?? this.userProfile,
      botProfile: botProfile ?? this.botProfile,
    );
  }

  /// Create default chat profiles
  static ChatProfiles createDefault() {
    final now = DateTime.now();
    return ChatProfiles(
      userProfile: ChatUserProfile(
        userId: '1',
        username: 'You',
        lastUpdated: now,
      ),
      botProfile: ChatBotProfile(
        botId: 'platepal_assistant',
        name: 'PlatePal Assistant',
        personalityType: BotPersonalityType.nice.value,
        behaviorType: 'helpful_expert',
        lastUpdated: now,
      ),
    );
  }
}
