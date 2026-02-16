class Chore {
  final String id;
  final String householdId;
  final String name;
  final String emoji;
  final int points;
  final bool isActive;
  final DateTime createdAt;

  const Chore({
    required this.id,
    required this.householdId,
    required this.name,
    required this.emoji,
    required this.points,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'household_id': householdId,
    'name': name,
    'emoji': emoji,
    'points': points,
    'is_active': isActive ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  factory Chore.fromMap(Map<String, dynamic> map) => Chore(
    id: map['id'] as String,
    householdId: map['household_id'] as String,
    name: map['name'] as String,
    emoji: map['emoji'] as String,
    points: map['points'] as int,
    isActive: (map['is_active'] as int) == 1,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}

class ChoreLog {
  final String id;
  final String choreId;
  final String memberId;
  final String householdId;
  final int points;
  final DateTime completedAt;
  final String? note;

  // Joined fields
  final String? choreName;
  final String? choreEmoji;
  final String? memberName;
  final int? memberAvatarColor;

  const ChoreLog({
    required this.id,
    required this.choreId,
    required this.memberId,
    required this.householdId,
    required this.points,
    required this.completedAt,
    this.note,
    this.choreName,
    this.choreEmoji,
    this.memberName,
    this.memberAvatarColor,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'chore_id': choreId,
    'member_id': memberId,
    'household_id': householdId,
    'points': points,
    'completed_at': completedAt.toIso8601String(),
    'note': note,
  };

  factory ChoreLog.fromMap(Map<String, dynamic> map) => ChoreLog(
    id: map['id'] as String,
    choreId: map['chore_id'] as String,
    memberId: map['member_id'] as String,
    householdId: map['household_id'] as String,
    points: map['points'] as int,
    completedAt: DateTime.parse(map['completed_at'] as String),
    note: map['note'] as String?,
    choreName: map['chore_name'] as String?,
    choreEmoji: map['chore_emoji'] as String?,
    memberName: map['member_name'] as String?,
    memberAvatarColor: map['member_avatar_color'] as int?,
  );
}
