import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/providers.dart';

class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activities = ref.watch(activitiesProvider);
    final batteryLevel = ref.watch(batteryLevelProvider);

    // Calculate stats
    final totalActivities = activities.length;
    final totalEnergy =
        activities.fold<double>(0, (sum, a) => sum + a.energyCost);
    final totalMinutes =
        activities.fold<int>(0, (sum, a) => sum + a.durationMinutes);

    // Activity type breakdown
    final Map<String, int> typeCount = {};
    final Map<String, double> typeEnergy = {};
    for (final a in activities) {
      typeCount[a.type] = (typeCount[a.type] ?? 0) + 1;
      typeEnergy[a.type] = (typeEnergy[a.type] ?? 0) + a.energyCost;
    }

    final sortedTypes = typeEnergy.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 本周社交报告',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: '🎭',
                  value: '$totalActivities',
                  label: '社交次数',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: '⚡',
                  value: '${totalEnergy.toInt()}',
                  label: '总消耗能量',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: '⏱️',
                  value: '${(totalMinutes / 60).toStringAsFixed(1)}h',
                  label: '社交时长',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: '🔋',
                  value: '${batteryLevel.toInt()}%',
                  label: '当前电量',
                  color: AppColors.getBatteryColor(batteryLevel),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Energy drain ranking
          Text(
            '能量消耗排行',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (sortedTypes.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      const Text('📝', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '本周还没有数据',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '记录社交活动后这里会显示分析',
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
            ...sortedTypes.asMap().entries.map((entry) {
              final index = entry.key;
              final type = entry.value;
              final maxEnergy = sortedTypes.first.value;
              final ratio = maxEnergy > 0 ? type.value / maxEnergy : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                type.key,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${type.value.toInt()} 能量 · ${typeCount[type.key]}次',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.getBatteryColor(100 - type.value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

          const SizedBox(height: AppSpacing.lg),

          // Weekly insight
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '本周洞察',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _getInsight(totalActivities, totalEnergy, batteryLevel),
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInsight(int count, double energy, double battery) {
    if (count == 0) {
      return '本周是完美的充电周 🧘\n你给自己留了充足的独处时间，电量充沛。享受这份宁静吧！';
    }
    if (energy > 80) {
      return '本周社交密度较高！消耗了 ${energy.toInt()} 点能量 😵\n建议下周减少社交安排，给自己更多休息时间。';
    }
    if (energy > 50) {
      return '本周社交活动适中，消耗了 ${energy.toInt()} 点能量。\n注意观察哪些活动最消耗你的能量，下次可以适当缩短时间。';
    }
    return '本周社交节奏不错 👍\n消耗了 ${energy.toInt()} 点能量，保持了良好的能量平衡。继续保持！';
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
