import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../model/capsule.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/countdown_widget.dart';
import 'open_capsule_page.dart';

class CapsuleDetailPage extends StatelessWidget {
  final Capsule capsule;

  const CapsuleDetailPage({super.key, required this.capsule});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年M月d日');

    // If unlocked and not opened, go to open ceremony
    if (capsule.canOpen) {
      return OpenCapsulePage(capsule: capsule);
    }

    // If already opened, show content directly
    if (capsule.isOpened) {
      return OpenCapsulePage(capsule: capsule);
    }

    // Locked view
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('时间胶囊')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Big lock
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.03, 1.03),
                    duration: 2000.ms,
                  ),
              const SizedBox(height: 32),

              Text(
                capsule.mood ?? '💌',
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 12),
              Text(
                capsule.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '写于 ${dateFormat.format(capsule.createdAt)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 32),

              // Countdown
              const Text(
                '距离解锁还有',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              CountdownWidget(capsule: capsule),
              const SizedBox(height: 16),
              Text(
                '${dateFormat.format(capsule.unlockAt)} 解锁',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 48),

              const Text(
                '这封信正在安静地等待着...\n到时候会提醒你来打开它 ✨',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                  height: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
