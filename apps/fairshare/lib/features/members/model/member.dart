class Member {
  final String id;
  final String householdId;
  final String name;
  final int avatarColor;
  final DateTime createdAt;

  const Member({
    required this.id,
    required this.householdId,
    required this.name,
    required this.avatarColor,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'household_id': householdId,
    'name': name,
    'avatar_color': avatarColor,
    'created_at': createdAt.toIso8601String(),
  };

  factory Member.fromMap(Map<String, dynamic> map) => Member(
    id: map['id'] as String,
    householdId: map['household_id'] as String,
    name: map['name'] as String,
    avatarColor: map['avatar_color'] as int,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}

class Household {
  final String id;
  final String name;
  final String inviteCode;
  final DateTime createdAt;

  const Household({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'invite_code': inviteCode,
    'created_at': createdAt.toIso8601String(),
  };

  factory Household.fromMap(Map<String, dynamic> map) => Household(
    id: map['id'] as String,
    name: map['name'] as String,
    inviteCode: map['invite_code'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
