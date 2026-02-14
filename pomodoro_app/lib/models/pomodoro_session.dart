enum SessionType {
  focus,
  shortBreak,
  longBreak,
}

class PomodoroSession {
  final String id;
  final SessionType type;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final bool completed;
  final String? taskId;

  PomodoroSession({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.startTime,
    this.endTime,
    this.completed = false,
    this.taskId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'durationMinutes': durationMinutes,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'completed': completed ? 1 : 0,
      'taskId': taskId,
    };
  }

  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'],
      type: SessionType.values[map['type']],
      durationMinutes: map['durationMinutes'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: map['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['endTime']) 
          : null,
      completed: map['completed'] == 1,
      taskId: map['taskId'],
    );
  }

  PomodoroSession copyWith({
    DateTime? endTime,
    bool? completed,
  }) {
    return PomodoroSession(
      id: id,
      type: type,
      durationMinutes: durationMinutes,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      completed: completed ?? this.completed,
      taskId: taskId,
    );
  }
}
