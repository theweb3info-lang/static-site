import '../models/goal.dart';

class GoalAnalysis {
  final double currentPace;
  final double idealPace;
  final bool isAhead;
  final DateTime? projectedCompletion;
  final int currentStreak;
  final String strongestDay;
  final String weakestDay;
  final double suggestedDailyTarget;
  final double momentumScore;
  final String summary;

  GoalAnalysis({
    required this.currentPace,
    required this.idealPace,
    required this.isAhead,
    this.projectedCompletion,
    required this.currentStreak,
    required this.strongestDay,
    required this.weakestDay,
    required this.suggestedDailyTarget,
    required this.momentumScore,
    required this.summary,
  });
}

class GoalAnalyzer {
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static GoalAnalysis analyze(Goal goal) {
    final now = DateTime.now();
    final totalDays = goal.deadline.difference(goal.startDate).inDays.toDouble();
    final elapsedDays = now.difference(goal.startDate).inDays.toDouble();
    final remainingDays = goal.deadline.difference(now).inDays.toDouble();

    final idealPace = totalDays > 0 ? goal.targetValue / totalDays : goal.targetValue;
    final currentPace = elapsedDays > 0 ? goal.currentValue / elapsedDays : 0.0;
    final isAhead = goal.progress >= goal.idealProgress;

    // Projected completion
    DateTime? projected;
    if (currentPace > 0) {
      final daysNeeded = (goal.targetValue - goal.currentValue) / currentPace;
      projected = now.add(Duration(days: daysNeeded.ceil()));
    }

    // Streak
    int streak = 0;
    if (goal.entries.isNotEmpty) {
      final sorted = [...goal.entries]..sort((a, b) => b.date.compareTo(a.date));
      var checkDate = DateTime(now.year, now.month, now.day);
      for (final e in sorted) {
        final eDate = DateTime(e.date.year, e.date.month, e.date.day);
        if (eDate == checkDate || eDate == checkDate.subtract(const Duration(days: 1))) {
          streak++;
          checkDate = eDate.subtract(const Duration(days: 1));
        } else if (eDate.isBefore(checkDate)) {
          break;
        }
      }
    }

    // Day of week analysis
    final dayTotals = List.filled(7, 0.0);
    final dayCounts = List.filled(7, 0);
    for (final e in goal.entries) {
      final d = e.date.weekday - 1;
      dayTotals[d] += e.value;
      dayCounts[d]++;
    }
    final dayAvg = List.generate(7, (i) => dayCounts[i] > 0 ? dayTotals[i] / dayCounts[i] : 0.0);
    int strongIdx = 0, weakIdx = 0;
    for (int i = 1; i < 7; i++) {
      if (dayAvg[i] > dayAvg[strongIdx]) strongIdx = i;
      if (dayAvg[i] < dayAvg[weakIdx]) weakIdx = i;
    }

    // Suggested daily target
    final remaining = goal.targetValue - goal.currentValue;
    final suggestedDaily = remainingDays > 0 ? remaining / remainingDays : remaining;

    // Momentum (recent 7 days vs prior 7 days)
    final week1 = goal.entries.where((e) => now.difference(e.date).inDays < 7).fold(0.0, (s, e) => s + e.value);
    final week2 = goal.entries.where((e) {
      final d = now.difference(e.date).inDays;
      return d >= 7 && d < 14;
    }).fold(0.0, (s, e) => s + e.value);
    final momentum = week2 > 0 ? ((week1 / week2) * 100).clamp(0.0, 200.0) : (week1 > 0 ? 150.0 : 50.0);

    // Summary
    String summary;
    if (goal.entries.isEmpty) {
      summary = "No entries yet. Start logging to see insights!";
    } else if (isAhead) {
      summary = "Great pace! You're ${((goal.progress - goal.idealProgress) * 100).toStringAsFixed(0)}% ahead of schedule. "
          "Keep it up — projected to finish ${projected != null && projected.isBefore(goal.deadline) ? '${goal.deadline.difference(projected).inDays} days early' : 'on time'}.";
    } else {
      summary = "You're ${((goal.idealProgress - goal.progress) * 100).toStringAsFixed(0)}% behind ideal pace. "
          "Try hitting ${suggestedDaily.toStringAsFixed(1)} ${goal.unit}/day to catch up.";
    }

    return GoalAnalysis(
      currentPace: currentPace,
      idealPace: idealPace,
      isAhead: isAhead,
      projectedCompletion: projected,
      currentStreak: streak,
      strongestDay: _dayNames[strongIdx],
      weakestDay: _dayNames[weakIdx],
      suggestedDailyTarget: suggestedDaily.clamp(0, double.infinity),
      momentumScore: momentum,
      summary: summary,
    );
  }
}
