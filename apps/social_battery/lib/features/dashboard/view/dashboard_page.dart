import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/providers.dart';
import '../widgets/battery_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryLevel = ref.watch(batteryLevelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          BatteryWidget(level: batteryLevel),
          const SizedBox(height: AppSpacing.xl),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.remove_circle_outline,
                  label: '消耗 -10',
                  color: AppColors.error,
                  onTap: () {
                    ref.read(batteryLevelProvider.notifier).consume(10);
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.add_circle_outline,
                  label: '充电 +20',
                  color: AppColors.success,
                  onTap: () {
                    ref.read(batteryLevelProvider.notifier).recharge(20);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),

          // Today's summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.today,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '今日概况',
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
                  Consumer(
                    builder: (context, ref, _) {
                      final activities = ref.watch(activitiesProvider);
                      final now = DateTime.now();
                      final today = activities.where((a) =>
                          a.createdAt.year == now.year &&
                          a.createdAt.month == now.month &&
                          a.createdAt.day == now.day);
                      final todayCount = today.length;
                      final todayCost = today.fold<double>(
                          0, (sum, a) => sum + a.energyCost);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            value: '$todayCount',
                            label: '社交活动',
                            color: AppColors.info,
                          ),
                          _StatItem(
                            value: '${todayCost.toInt()}',
                            label: '消耗能量',
                            color: AppColors.warning,
                          ),
                          _StatItem(
                            value: '${batteryLevel.toInt()}%',
                            label: '剩余电量',
                            color: AppColors.getBatteryColor(batteryLevel),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Recharge tips
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
                        '充电小贴士',
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
                  _RechargeTip(
                    emoji: '📖',
                    text: '独处阅读 30分钟',
                    energy: '+15',
                  ),
                  _RechargeTip(
                    emoji: '🚶',
                    text: '独自散步',
                    energy: '+10',
                  ),
                  _RechargeTip(
                    emoji: '🎵',
                    text: '听音乐放空',
                    energy: '+8',
                  ),
                  _RechargeTip(
                    emoji: '🛁',
                    text: '热水澡/泡脚',
                    energy: '+12',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
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
    );
  }
}

class _RechargeTip extends StatelessWidget {
  final String emoji;
  final String text;
  final String energy;

  const _RechargeTip({
    required this.emoji,
    required this.text,
    required this.energy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          Text(
            energy,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
