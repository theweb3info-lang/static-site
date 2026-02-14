class DailyStatistics {
  final DateTime date;
  int completedPomodoros;
  int totalFocusMinutes;
  int completedTasks;

  DailyStatistics({
    required this.date,
    this.completedPomodoros = 0,
    this.totalFocusMinutes = 0,
    this.completedTasks = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': _dateToString(date),
      'completedPomodoros': completedPomodoros,
      'totalFocusMinutes': totalFocusMinutes,
      'completedTasks': completedTasks,
    };
  }

  factory DailyStatistics.fromMap(Map<String, dynamic> map) {
    return DailyStatistics(
      date: _stringToDate(map['date']),
      completedPomodoros: map['completedPomodoros'] ?? 0,
      totalFocusMinutes: map['totalFocusMinutes'] ?? 0,
      completedTasks: map['completedTasks'] ?? 0,
    );
  }

  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _stringToDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  String get formattedFocusTime {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
