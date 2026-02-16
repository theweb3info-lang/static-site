class Capsule {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime unlockAt;
  final bool isOpened;
  final String? mood; // emoji mood

  Capsule({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.unlockAt,
    this.isOpened = false,
    this.mood,
  });

  bool get isUnlocked => DateTime.now().isAfter(unlockAt);
  bool get canOpen => isUnlocked && !isOpened;

  Duration get remainingTime {
    final diff = unlockAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'unlockAt': unlockAt.millisecondsSinceEpoch,
    'isOpened': isOpened ? 1 : 0,
    'mood': mood,
  };

  factory Capsule.fromMap(Map<String, dynamic> map) => Capsule(
    id: map['id'] as String,
    title: map['title'] as String,
    content: map['content'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    unlockAt: DateTime.fromMillisecondsSinceEpoch(map['unlockAt'] as int),
    isOpened: (map['isOpened'] as int) == 1,
    mood: map['mood'] as String?,
  );

  Capsule copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? unlockAt,
    bool? isOpened,
    String? mood,
  }) => Capsule(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    unlockAt: unlockAt ?? this.unlockAt,
    isOpened: isOpened ?? this.isOpened,
    mood: mood ?? this.mood,
  );
}
