import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/theme/app_theme.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  String _currentTopic = '点击下方按钮\n抽取一个话题卡片 🎴';
  final _random = Random();
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _drawTopic() {
    if (_isFlipping) return;
    _isFlipping = true;
    HapticFeedback.mediumImpact();

    _controller.forward().then((_) {
      setState(() {
        _currentTopic = AppConstants
            .topicCards[_random.nextInt(AppConstants.topicCards.length)];
      });
      _controller.reverse().then((_) {
        _isFlipping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            '话题卡片',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '不知道聊什么？抽一张卡片吧',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Card
          AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * 3.14159;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: child,
              );
            },
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.accent,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '💬',
                    style: TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    _currentTopic,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Draw button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _drawTopic,
              icon: const Icon(Icons.shuffle),
              label: const Text(
                '抽一张',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Copy button
          OutlinedButton.icon(
            onPressed: () {
              if (_currentTopic.contains('点击下方')) return;
              Clipboard.setData(ClipboardData(text: _currentTopic));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('已复制到剪贴板 📋'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('复制话题'),
          ),
        ],
      ),
    );
  }
}
