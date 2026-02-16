class SocialActivity {
  final String id;
  final String type;
  final int durationMinutes;
  final double energyCost;
  final String? note;
  final DateTime createdAt;

  SocialActivity({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.energyCost,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'duration_minutes': durationMinutes,
      'energy_cost': energyCost,
      'note': note ?? '',
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SocialActivity.fromMap(Map<String, dynamic> map) {
    return SocialActivity(
      id: map['id'] as String,
      type: map['type'] as String,
      durationMinutes: map['duration_minutes'] as int,
      energyCost: (map['energy_cost'] as num).toDouble(),
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
