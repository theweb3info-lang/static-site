import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/statistics_provider.dart';
import '../providers/settings_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 0; // 0: Week, 1: Month

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Statistics'),
        titleWidth: 150,
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OverviewCards(),
                  const SizedBox(height: 24),
                  _PeriodSelector(
                    selectedIndex: _selectedPeriod,
                    onChanged: (index) {
                      setState(() => _selectedPeriod = index);
                    },
                  ),
                  const SizedBox(height: 16),
                  _PomodoroChart(showWeekly: _selectedPeriod == 0),
                  const SizedBox(height: 24),
                  _FocusTimeChart(showWeekly: _selectedPeriod == 0),
                  const SizedBox(height: 24),
                  _StreakCard(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _OverviewCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsProvider>();
    final settings = context.watch<SettingsProvider>();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Today',
            value: '${stats.todayPomodoros}',
            subtitle: 'of ${settings.dailyPomodoroGoal} goal',
            icon: CupertinoIcons.flame_fill,
            color: const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'This Week',
            value: '${stats.weeklyPomodoros}',
            subtitle: stats.formatMinutes(stats.weeklyFocusMinutes),
            icon: CupertinoIcons.calendar,
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Total',
            value: '${stats.totalPomodoros}',
            subtitle: stats.formatMinutes(stats.totalFocusMinutes),
            icon: CupertinoIcons.chart_bar_fill,
            color: const Color(0xFF45B7D1),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MacosTheme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: MacosTheme.of(context).typography.caption1.color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: MacosTheme.of(context).typography.caption1.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _PeriodSelector({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PeriodButton(
          label: 'Week',
          isSelected: selectedIndex == 0,
          onPressed: () => onChanged(0),
        ),
        const SizedBox(width: 8),
        _PeriodButton(
          label: 'Month',
          isSelected: selectedIndex == 1,
          onPressed: () => onChanged(1),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? MacosTheme.of(context).primaryColor 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? MacosTheme.of(context).primaryColor 
                : MacosTheme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : MacosTheme.of(context).typography.body.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _PomodoroChart extends StatelessWidget {
  final bool showWeekly;

  const _PomodoroChart({required this.showWeekly});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsProvider>();
    final data = showWeekly ? stats.getWeeklyStats() : stats.getMonthlyStats();
    final maxVal = data.map((s) => s.completedPomodoros).fold(0, (a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MacosTheme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pomodoros Completed',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: MacosTheme.of(context).typography.headline.color,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxVal + 2).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} 🍅',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          final date = data[index].date;
                          if (showWeekly) {
                            return Text(
                              DateFormat('E').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          } else if (index % 5 == 0) {
                            return Text(
                              DateFormat('d').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: MacosTheme.of(context).dividerColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.completedPomodoros.toDouble(),
                        color: const Color(0xFFFF6B6B),
                        width: showWeekly ? 24 : 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusTimeChart extends StatelessWidget {
  final bool showWeekly;

  const _FocusTimeChart({required this.showWeekly});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsProvider>();
    final data = showWeekly ? stats.getWeeklyStats() : stats.getMonthlyStats();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MacosTheme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MacosTheme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Focus Time (minutes)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: MacosTheme.of(context).typography.headline.color,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: MacosTheme.of(context).dividerColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          final date = data[index].date;
                          if (showWeekly) {
                            return Text(
                              DateFormat('E').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          } else if (index % 5 == 0) {
                            return Text(
                              DateFormat('d').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.totalFocusMinutes.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4ECDC4),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: showWeekly,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF4ECDC4),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()} min',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatisticsProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Streak',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${stats.currentStreak} days',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Longest Streak',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${stats.longestStreak} days',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
