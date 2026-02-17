import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';

class PaceChart extends StatelessWidget {
  final Goal goal;

  const PaceChart({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final totalDays = goal.deadline.difference(goal.startDate).inDays.toDouble();
    if (totalDays <= 0) return const SizedBox.shrink();

    // Ideal pace line
    final idealSpots = [
      const FlSpot(0, 0),
      FlSpot(totalDays, goal.targetValue),
    ];

    // Actual pace line from entries
    final sorted = [...goal.entries]..sort((a, b) => a.date.compareTo(b.date));
    double cumulative = 0;
    final actualSpots = <FlSpot>[const FlSpot(0, 0)];
    for (final e in sorted) {
      cumulative += e.value;
      final day = e.date.difference(goal.startDate).inDays.toDouble();
      actualSpots.add(FlSpot(day.clamp(0, totalDays), cumulative));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: goal.targetValue / 4,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.white.withAlpha(15),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: totalDays,
          minY: 0,
          maxY: goal.targetValue * 1.1,
          lineBarsData: [
            // Ideal
            LineChartBarData(
              spots: idealSpots,
              isCurved: false,
              color: Colors.white.withAlpha(50),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              dashArray: [8, 4],
            ),
            // Actual
            LineChartBarData(
              spots: actualSpots,
              isCurved: true,
              color: goal.color,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (s, _, bar, idx) => FlDotCirclePainter(
                  radius: 3,
                  color: goal.color,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: goal.color.withAlpha(30),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      ),
    );
  }
}
