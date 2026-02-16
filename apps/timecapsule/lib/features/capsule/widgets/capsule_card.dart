import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../model/capsule.dart';
import '../../../shared/theme/app_theme.dart';
import 'countdown_widget.dart';
import 'package:intl/intl.dart';

class CapsuleCard extends StatelessWidget {
  final Capsule capsule;
  final VoidCallback onTap;

  const CapsuleCard({
    super.key,
    required this.capsule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !capsule.isUnlocked;
    final dateFormat = DateFormat('yyyy年M月d日');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: capsule.isOpened
                ? AppColors.accentGold.withValues(alpha: 0.3)
                : isLocked
                    ? AppColors.border
                    : AppColors.primary.withValues(alpha: 0.4),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Lock icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? AppColors.surfaceVariant
                        : capsule.isOpened
                            ? AppColors.accentGold.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLocked
                        ? Icons.lock_rounded
                        : capsule.isOpened
                            ? Icons.mail_outline_rounded
                            : Icons.lock_open_rounded,
                    size: 20,
                    color: isLocked
                        ? AppColors.textTertiary
                        : capsule.isOpened
                            ? AppColors.accentGold
                            : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capsule.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '写于 ${dateFormat.format(capsule.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (capsule.mood != null)
                  Text(capsule.mood!, style: const TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom row
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '解锁：${dateFormat.format(capsule.unlockAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                CountdownWidget(capsule: capsule, compact: true),
              ],
            ),
            if (capsule.canOpen) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accentGold],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    '✨ 点击打开这封信',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2000.ms, color: Colors.white24),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}
