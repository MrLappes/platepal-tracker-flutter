class UserProfile {
  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final double height; // in cm
  final double weight; // in kg
  final String activityLevel;
  final FitnessGoals goals;
  final DietaryPreferences preferences;
  final String preferredUnit; // metric or imperial
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goals,
    required this.preferences,
    this.preferredUnit = 'metric',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      activityLevel: json['activityLevel'] as String,
      goals: FitnessGoals.fromJson(json['goals'] as Map<String, dynamic>),
      preferences: DietaryPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>,
      ),
      preferredUnit: json['preferredUnit'] as String? ?? 'metric',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'goals': goals.toJson(),
      'preferences': preferences.toJson(),
      'preferredUnit': preferredUnit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
    FitnessGoals? goals,
    DietaryPreferences? preferences,
    String? preferredUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      goals: goals ?? this.goals,
      preferences: preferences ?? this.preferences,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FitnessGoals {
  final String goal; // lose_weight, maintain_weight, gain_weight, build_muscle
  final double targetWeight;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;

  const FitnessGoals({
    required this.goal,
    required this.targetWeight,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });

  factory FitnessGoals.fromJson(Map<String, dynamic> json) {
    return FitnessGoals(
      goal: json['goal'] as String,
      targetWeight: (json['targetWeight'] as num).toDouble(),
      targetCalories: (json['targetCalories'] as num).toDouble(),
      targetProtein: (json['targetProtein'] as num).toDouble(),
      targetCarbs: (json['targetCarbs'] as num).toDouble(),
      targetFat: (json['targetFat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'targetWeight': targetWeight,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
    };
  }
}

class DietaryPreferences {
  final List<String> allergies;
  final List<String> dislikes;
  final String dietType; // omnivore, vegetarian, vegan, keto, etc.
  final bool preferOrganic;
  final List<String> cuisinePreferences;

  const DietaryPreferences({
    this.allergies = const [],
    this.dislikes = const [],
    this.dietType = 'omnivore',
    this.preferOrganic = false,
    this.cuisinePreferences = const [],
  });

  factory DietaryPreferences.fromJson(Map<String, dynamic> json) {
    return DietaryPreferences(
      allergies: List<String>.from(json['allergies'] as List? ?? []),
      dislikes: List<String>.from(json['dislikes'] as List? ?? []),
      dietType: json['dietType'] as String? ?? 'omnivore',
      preferOrganic: json['preferOrganic'] as bool? ?? false,
      cuisinePreferences: List<String>.from(
        json['cuisinePreferences'] as List? ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergies': allergies,
      'dislikes': dislikes,
      'dietType': dietType,
      'preferOrganic': preferOrganic,
      'cuisinePreferences': cuisinePreferences,
    };
  }
}
