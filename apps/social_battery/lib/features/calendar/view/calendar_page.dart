import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/providers.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeklyStats = ref.watch(weeklyStatsProvider);
    final activities = ref.watch(activitiesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本周社交负荷',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Bar chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: SizedBox(
                height: 200,
                child: weeklyStats.when(
                  data: (data) => _buildChart(data, isDark),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('加载失败: $e')),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Activity list
          Text(
            '本周活动记录',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (activities.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🧘', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '本周还没有社交活动',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '享受独处时光吧 ✨',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...activities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors
                              .getBatteryColor(100 - activity.energyCost)
                              .withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                        ),
                        child: Center(
                          child: Text(
                            '-${activity.energyCost.toInt()}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.getBatteryColor(
                                  100 - activity.energyCost),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        activity.type,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${activity.durationMinutes}分钟 · ${activity.createdAt.month}/${activity.createdAt.day}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () {
                          ref
                              .read(activitiesProvider.notifier)
                              .removeActivity(activity.id);
                        },
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, double> data, bool isDark) {
    final entries = data.entries.toList();
    final maxY = entries.fold<double>(0, (max, e) => e.value > max ? e.value : max);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY > 0 ? maxY * 1.3 : 50,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${entries[group.x.toInt()].key}\n${rod.toY.toInt()} 能量',
                TextStyle(
                  color: isDark ? Colors.white : Colors.black,
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
                final index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      entries[index].key,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((entry) {
          final color = entry.value.value > 30
              ? AppColors.batteryLow
              : (entry.value.value > 0
                  ? AppColors.batteryMedium
                  : AppColors.batteryFull);
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                color: color,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
