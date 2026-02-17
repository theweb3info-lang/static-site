import 'dart:ui';

enum GoalType { numeric, count, habit }

class Goal {
  final String id;
  final String name;
  final GoalType type;
  final double targetValue;
  final String unit;
  final DateTime startDate;
  final DateTime deadline;
  final Color color;
  List<LogEntry> entries;

  Goal({
    required this.id,
    required this.name,
    required this.type,
    required this.targetValue,
    required this.unit,
    required this.startDate,
    required this.deadline,
    required this.color,
    List<LogEntry>? entries,
  }) : entries = entries ?? [];

  double get currentValue => entries.fold(0.0, (sum, e) => sum + e.value);
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  double get idealProgress {
    final total = deadline.difference(startDate).inDays.toDouble();
    if (total <= 0) return 1.0;
    final elapsed = DateTime.now().difference(startDate).inDays.toDouble();
    return (elapsed / total).clamp(0.0, 1.0);
  }

  bool get isAhead => progress >= idealProgress;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.index,
        'targetValue': targetValue,
        'unit': unit,
        'startDate': startDate.millisecondsSinceEpoch,
        'deadline': deadline.millisecondsSinceEpoch,
        'color': color.toARGB32(),
      };

  factory Goal.fromMap(Map<String, dynamic> map, [List<LogEntry>? entries]) =>
      Goal(
        id: map['id'],
        name: map['name'],
        type: GoalType.values[map['type']],
        targetValue: (map['targetValue'] as num).toDouble(),
        unit: map['unit'],
        startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
        deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline']),
        color: Color(map['color']),
        entries: entries ?? [],
      );
}

class LogEntry {
  final String id;
  final DateTime date;
  final double value;
  final String? note;
  final String goalId;

  LogEntry({
    required this.id,
    required this.date,
    required this.value,
    this.note,
    required this.goalId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.millisecondsSinceEpoch,
        'value': value,
        'note': note,
        'goalId': goalId,
      };

  factory LogEntry.fromMap(Map<String, dynamic> map) => LogEntry(
        id: map['id'],
        date: DateTime.fromMillisecondsSinceEpoch(map['date']),
        value: (map['value'] as num).toDouble(),
        note: map['note'],
        goalId: map['goalId'],
      );
}
