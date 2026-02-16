import 'dart:async';
import 'package:flutter/material.dart';
import '../model/capsule.dart';
import '../../../shared/theme/app_theme.dart';

class CountdownWidget extends StatefulWidget {
  final Capsule capsule;
  final bool compact;

  const CountdownWidget({
    super.key,
    required this.capsule,
    this.compact = false,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.capsule.remainingTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = widget.capsule.remainingTime;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return _buildUnlockedBadge();
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    if (widget.compact) {
      return Text(
        days > 0 ? '${days}天${hours}时' : '${hours}时${minutes}分',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeBlock('$days', '天'),
        _buildSeparator(),
        _buildTimeBlock('${hours.toString().padLeft(2, '0')}', '时'),
        _buildSeparator(),
        _buildTimeBlock('${minutes.toString().padLeft(2, '0')}', '分'),
        _buildSeparator(),
        _buildTimeBlock('${seconds.toString().padLeft(2, '0')}', '秒'),
      ],
    );
  }

  Widget _buildTimeBlock(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildUnlockedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_open_rounded, size: 14, color: AppColors.accentGold),
          SizedBox(width: 4),
          Text(
            '已解锁',
            style: TextStyle(
              color: AppColors.accentGold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
