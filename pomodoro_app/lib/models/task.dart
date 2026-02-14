import 'package:uuid/uuid.dart';

class Task {
  final String id;
  String title;
  String? description;
  int estimatedPomodoros;
  int completedPomodoros;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;
  int priority; // 1-3 (high, medium, low)
  String? category;

  Task({
    String? id,
    required this.title,
    this.description,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.priority = 2,
    this.category,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    int? estimatedPomodoros,
    int? completedPomodoros,
    bool? isCompleted,
    DateTime? completedAt,
    int? priority,
    String? category,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      completedPomodoros: completedPomodoros ?? this.completedPomodoros,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'priority': priority,
      'category': category,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      estimatedPomodoros: map['estimatedPomodoros'] ?? 1,
      completedPomodoros: map['completedPomodoros'] ?? 0,
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      completedAt: map['completedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt']) 
          : null,
      priority: map['priority'] ?? 2,
      category: map['category'],
    );
  }

  void incrementPomodoro() {
    completedPomodoros++;
    if (completedPomodoros >= estimatedPomodoros) {
      isCompleted = true;
      completedAt = DateTime.now();
    }
  }
}
