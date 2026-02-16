import 'package:flutter/material.dart';
import '../../../shared/theme/app_theme.dart';
import 'battery_painter.dart';

class BatteryWidget extends StatefulWidget {
  final double level;

  const BatteryWidget({super.key, required this.level});

  @override
  State<BatteryWidget> createState() => _BatteryWidgetState();
}

class _BatteryWidgetState extends State<BatteryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(BatteryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getStatusText(double level) {
    if (level > 80) return '精力充沛 ⚡';
    if (level > 60) return '状态不错 😊';
    if (level > 40) return '还能撑住 😐';
    if (level > 20) return '需要休息 😴';
    if (level > 10) return '电量告急 😵';
    return '请立即充电 🪫';
  }

  String _getSuggestion(double level) {
    if (level > 80) return '可以安排社交活动';
    if (level > 60) return '适合小范围交流';
    if (level > 40) return '建议只参加重要活动';
    if (level > 20) return '尽量减少社交，多独处';
    return '取消所有社交计划，给自己充电';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 240,
              child: CustomPaint(
                painter: BatteryPainter(
                  level: widget.level,
                  animationValue: _animation.value,
                  isDark: isDark,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                '${(widget.level * _animation.value).toInt()}%',
                key: ValueKey(widget.level.toInt()),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.getBatteryColor(widget.level),
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _getStatusText(widget.level),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _getSuggestion(widget.level),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}
