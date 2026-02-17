import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';
import 'progress_ring.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCard({super.key, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = (goal.progress * 100).toStringAsFixed(0);
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;
    final ahead = goal.isAhead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: goal.color.withAlpha(40)),
        ),
        child: Row(
          children: [
            ProgressRing(
              progress: goal.progress,
              color: goal.color,
              size: 56,
              strokeWidth: 5,
              child: Text(
                '$pct%',
                style: TextStyle(
                  color: goal.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    '${goal.currentValue.toStringAsFixed(1)} / ${goal.targetValue.toStringAsFixed(0)} ${goal.unit}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: ahead ? AppTheme.aheadGradient : AppTheme.behindGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ahead ? 'Ahead' : 'Behind',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$daysLeft days left',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
