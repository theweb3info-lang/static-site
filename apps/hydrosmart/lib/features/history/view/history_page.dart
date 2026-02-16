import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../shared/services/preferences_service.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/models/water_record.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(waterRecordsProvider);
    final goal = ref.watch(adjustedGoalProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Compute 7-day data
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final dayRecords = records.where((r) =>
          r.timestamp.year == date.year &&
          r.timestamp.month == date.month &&
          r.timestamp.day == date.day);
      final total = dayRecords.fold(0, (s, r) => s + r.amountMl);
      return _DayData(date: date, totalMl: total);
    });

    final maxY = days.map((d) => d.totalMl).fold(goal, (a, b) => a > b ? a : b) * 1.2;

    // Today's records for the list
    final todayRecords = records
        .where((r) =>
            r.timestamp.year == now.year &&
            r.timestamp.month == now.month &&
            r.timestamp.day == now.day)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(title: const Text('历史记录 📊')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 7-day chart
              Text('过去7天', style: textTheme.titleSmall),
              const SizedBox(height: AppSpacing.base),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY.toDouble(),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()}ml',
                            TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 12,
                            ),
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
                            final idx = value.toInt();
                            if (idx >= 0 && idx < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  DateFormat('E', 'zh').format(days[idx].date),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: days.asMap().entries.map((e) {
                      final isToday = e.key == 6;
                      final reachedGoal = e.value.totalMl >= goal;
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.totalMl.toDouble(),
                            color: reachedGoal
                                ? AppColors.success
                                : isToday
                                    ? colorScheme.primary
                                    : colorScheme.primary.withValues(alpha: 0.4),
                            width: 24,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: goal.toDouble(),
                          color: AppColors.accent.withValues(alpha: 0.5),
                          strokeWidth: 1,
                          dashArray: [8, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            labelResolver: (_) => '目标 ${goal}ml',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  duration: const Duration(milliseconds: 300),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Today's records list
              Text('今日记录', style: textTheme.titleSmall),
              const SizedBox(height: AppSpacing.md),
              if (todayRecords.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        const Text('💧', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '还没有记录，去喝一杯水吧！',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...todayRecords.map((r) => _RecordTile(record: r)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordTile extends ConsumerWidget {
  final WaterRecord record;
  const _RecordTile({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(record.timestamp),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) {
        ref.read(waterRecordsProvider.notifier).removeRecord(record);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.water_drop_rounded,
                color: colorScheme.onPrimaryContainer, size: 20),
          ),
          title: Text('${record.amountMl}ml'),
          trailing: Text(
            DateFormat('HH:mm').format(record.timestamp),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayData {
  final DateTime date;
  final int totalMl;
  const _DayData({required this.date, required this.totalMl});
}
