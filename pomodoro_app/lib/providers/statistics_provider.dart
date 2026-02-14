import 'package:flutter/foundation.dart';
import '../models/daily_statistics.dart';
import '../services/database_service.dart';

class StatisticsProvider extends ChangeNotifier {
  Map<String, DailyStatistics> _dailyStats = {};
  
  int get todayPomodoros => _getTodayStats().completedPomodoros;
  int get todayFocusMinutes => _getTodayStats().totalFocusMinutes;
  int get todayCompletedTasks => _getTodayStats().completedTasks;

  DailyStatistics _getTodayStats() {
    final today = _dateKey(DateTime.now());
    return _dailyStats[today] ?? DailyStatistics(date: DateTime.now());
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadStatistics() async {
    final stats = await DatabaseService.instance.getStatistics();
    _dailyStats = {for (var s in stats) _dateKey(s.date): s};
    notifyListeners();
  }

  Future<void> recordCompletedPomodoro(int focusMinutes, String? taskId) async {
    final today = _dateKey(DateTime.now());
    
    if (!_dailyStats.containsKey(today)) {
      _dailyStats[today] = DailyStatistics(date: DateTime.now());
    }
    
    _dailyStats[today]!.completedPomodoros++;
    _dailyStats[today]!.totalFocusMinutes += focusMinutes;
    
    await DatabaseService.instance.saveStatistics(_dailyStats[today]!);
    notifyListeners();
  }

  Future<void> recordCompletedTask() async {
    final today = _dateKey(DateTime.now());
    
    if (!_dailyStats.containsKey(today)) {
      _dailyStats[today] = DailyStatistics(date: DateTime.now());
    }
    
    _dailyStats[today]!.completedTasks++;
    
    await DatabaseService.instance.saveStatistics(_dailyStats[today]!);
    notifyListeners();
  }

  List<DailyStatistics> getWeeklyStats() {
    final now = DateTime.now();
    final stats = <DailyStatistics>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      stats.add(_dailyStats[key] ?? DailyStatistics(date: date));
    }
    
    return stats;
  }

  List<DailyStatistics> getMonthlyStats() {
    final now = DateTime.now();
    final stats = <DailyStatistics>[];
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      stats.add(_dailyStats[key] ?? DailyStatistics(date: date));
    }
    
    return stats;
  }

  int get weeklyPomodoros {
    return getWeeklyStats().fold(0, (sum, s) => sum + s.completedPomodoros);
  }

  int get weeklyFocusMinutes {
    return getWeeklyStats().fold(0, (sum, s) => sum + s.totalFocusMinutes);
  }

  int get monthlyPomodoros {
    return getMonthlyStats().fold(0, (sum, s) => sum + s.completedPomodoros);
  }

  int get totalPomodoros {
    return _dailyStats.values.fold(0, (sum, s) => sum + s.completedPomodoros);
  }

  int get totalFocusMinutes {
    return _dailyStats.values.fold(0, (sum, s) => sum + s.totalFocusMinutes);
  }

  String formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  double get averageDailyPomodoros {
    if (_dailyStats.isEmpty) return 0;
    return totalPomodoros / _dailyStats.length;
  }

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      
      if (_dailyStats.containsKey(key) && _dailyStats[key]!.completedPomodoros > 0) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    
    return streak;
  }

  int get longestStreak {
    if (_dailyStats.isEmpty) return 0;
    
    final sortedDates = _dailyStats.keys.toList()..sort();
    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (final key in sortedDates) {
      final stats = _dailyStats[key]!;
      if (stats.completedPomodoros > 0) {
        if (lastDate == null || 
            stats.date.difference(lastDate).inDays == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
        lastDate = stats.date;
      } else {
        currentStreak = 0;
        lastDate = null;
      }
    }
    
    return maxStreak;
  }
}
