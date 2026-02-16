enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive;

  String get label {
    switch (this) {
      case sedentary:
        return '久坐';
      case light:
        return '轻度运动';
      case moderate:
        return '中度运动';
      case active:
        return '活跃';
      case veryActive:
        return '非常活跃';
    }
  }

  String get labelEn {
    switch (this) {
      case sedentary:
        return 'Sedentary';
      case light:
        return 'Light';
      case moderate:
        return 'Moderate';
      case active:
        return 'Active';
      case veryActive:
        return 'Very Active';
    }
  }

  double get multiplier {
    switch (this) {
      case sedentary:
        return 1.0;
      case light:
        return 1.1;
      case moderate:
        return 1.25;
      case active:
        return 1.4;
      case veryActive:
        return 1.6;
    }
  }
}

class UserProfile {
  final double weightKg;
  final ActivityLevel activityLevel;
  final int caffeineCount; // cups of coffee today

  const UserProfile({
    this.weightKg = 70,
    this.activityLevel = ActivityLevel.moderate,
    this.caffeineCount = 0,
  });

  /// Base daily goal in ml: 35ml per kg * activity multiplier + caffeine offset
  int get dailyGoalMl {
    final base = weightKg * 35 * activityLevel.multiplier;
    final caffeineOffset = caffeineCount * 150; // each coffee needs ~150ml extra
    return (base + caffeineOffset).round();
  }

  UserProfile copyWith({
    double? weightKg,
    ActivityLevel? activityLevel,
    int? caffeineCount,
  }) =>
      UserProfile(
        weightKg: weightKg ?? this.weightKg,
        activityLevel: activityLevel ?? this.activityLevel,
        caffeineCount: caffeineCount ?? this.caffeineCount,
      );
}
