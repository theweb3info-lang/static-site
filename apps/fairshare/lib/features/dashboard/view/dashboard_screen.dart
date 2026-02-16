import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../app/providers.dart';
import '../../members/model/member.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statPeriodProvider);
    final DateTime? from;
    final DateTime? to;

    switch (period) {
      case StatPeriod.week:
        from = getStartOfWeek();
        to = null;
      case StatPeriod.month:
        from = getStartOfMonth();
        to = null;
      case StatPeriod.all:
        from = null;
        to = null;
    }

    final membersAsync = ref.watch(membersProvider);
    final pointsAsync = ref.watch(memberPointsProvider((from: from, to: to)));

    return Scaffold(
      appBar: AppBar(title: const Text('公平度仪表盘 ⚖️')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          children: [
            // Period selector
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: StatPeriod.values.map((p) {
                  final selected = period == p;
                  final label = switch (p) {
                    StatPeriod.week => '本周',
                    StatPeriod.month => '本月',
                    StatPeriod.all => '全部',
                  };
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => ref.read(statPeriodProvider.notifier).state = p,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Pie chart
            membersAsync.when(
              data: (members) => pointsAsync.when(
                data: (points) => _buildChart(members, points),
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('$e'),
              ),
              loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('$e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<Member> members, Map<String, int> points) {
    final totalPoints = points.values.fold(0, (a, b) => a + b);

    if (members.isEmpty || totalPoints == 0) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xxl),
        child: Column(
          children: [
            Text('📊', style: TextStyle(fontSize: 64)),
            SizedBox(height: AppSpacing.base),
            Text('还没有数据', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: AppSpacing.sm),
            Text('去打卡完成一些家务吧！', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Pie chart
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: members.map((m) {
                final p = points[m.id] ?? 0;
                final pct = (p / totalPoints * 100).round();
                final color = AppColors.avatarColors[m.avatarColor % AppColors.avatarColors.length];
                return PieChartSectionData(
                  value: p.toDouble(),
                  color: color,
                  title: '$pct%',
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                );
              }).where((s) => s.value > 0).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Fairness message
        _buildFairnessMessage(members, points, totalPoints),
        const SizedBox(height: AppSpacing.lg),

        // Leaderboard
        ...members.map((m) {
          final p = points[m.id] ?? 0;
          final pct = totalPoints > 0 ? p / totalPoints : 0.0;
          final color = AppColors.avatarColors[m.avatarColor % AppColors.avatarColors.length];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color,
                    child: Text(m.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.xs),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppColors.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation(color),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '$p 分',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFairnessMessage(List<Member> members, Map<String, int> points, int totalPoints) {
    if (members.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.base),
          child: Text('邀请更多成员来比较公平度 👥', textAlign: TextAlign.center),
        ),
      );
    }

    final fairShare = totalPoints / members.length;
    final maxDiff = members.map((m) => ((points[m.id] ?? 0) - fairShare).abs()).reduce((a, b) => a > b ? a : b);
    final fairness = fairShare > 0 ? (1 - maxDiff / fairShare).clamp(0.0, 1.0) : 1.0;

    final String message;
    final String emoji;
    final Color color;

    if (fairness >= 0.85) {
      message = '家务分配很均衡，大家都在努力！';
      emoji = '🌟';
      color = AppColors.success;
    } else if (fairness >= 0.6) {
      message = '还不错，但可以更均衡一些哦～';
      emoji = '💪';
      color = AppColors.warning;
    } else {
      message = '分配有点不均衡，多帮帮忙吧～';
      emoji = '🤗';
      color = AppColors.accent;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('公平度 ${(fairness * 100).round()}%', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
