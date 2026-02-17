import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StreakIndicator extends StatelessWidget {
  final int streak;

  const StreakIndicator({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(streak > 0 ? '🔥' : '💤', style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Text(
          '$streak day streak',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
