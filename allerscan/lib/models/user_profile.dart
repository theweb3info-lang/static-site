class UserProfile {
  final List<String> selectedAllergenIds;
  final List<String> customAllergens;

  const UserProfile({
    this.selectedAllergenIds = const [],
    this.customAllergens = const [],
  });

  List<String> get allAllergenNames => [...selectedAllergenIds, ...customAllergens];

  Map<String, dynamic> toJson() => {
        'selectedAllergenIds': selectedAllergenIds,
        'customAllergens': customAllergens,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        selectedAllergenIds: List<String>.from(json['selectedAllergenIds'] ?? []),
        customAllergens: List<String>.from(json['customAllergens'] ?? []),
      );

  UserProfile copyWith({
    List<String>? selectedAllergenIds,
    List<String>? customAllergens,
  }) =>
      UserProfile(
        selectedAllergenIds: selectedAllergenIds ?? this.selectedAllergenIds,
        customAllergens: customAllergens ?? this.customAllergens,
      );
}
