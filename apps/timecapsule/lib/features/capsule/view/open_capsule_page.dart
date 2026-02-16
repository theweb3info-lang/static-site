import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../model/capsule.dart';
import '../service/capsule_provider.dart';
import '../../../shared/theme/app_theme.dart';

class OpenCapsulePage extends ConsumerStatefulWidget {
  final Capsule capsule;

  const OpenCapsulePage({super.key, required this.capsule});

  @override
  ConsumerState<OpenCapsulePage> createState() => _OpenCapsulePageState();
}

class _OpenCapsulePageState extends ConsumerState<OpenCapsulePage>
    with TickerProviderStateMixin {
  bool _isOpening = true;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    // Mark as opened
    if (!widget.capsule.isOpened) {
      ref.read(capsuleListProvider.notifier).openCapsule(widget.capsule.id);
    }
    // Ceremony animation sequence
    Future.delayed(2500.ms, () {
      if (mounted) setState(() => _isOpening = false);
    });
    Future.delayed(3200.ms, () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isOpening) {
      return _buildOpeningCeremony();
    }
    return _buildLetterView();
  }

  Widget _buildOpeningCeremony() {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing lock icon that opens
            const Icon(
              Icons.lock_open_rounded,
              size: 80,
              color: AppColors.accentGold,
            )
                .animate()
                .scale(
                  begin: const Offset(0.3, 0.3),
                  end: const Offset(1.2, 1.2),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(duration: 1000.ms, color: AppColors.accentGold.withValues(alpha: 0.5))
                .then()
                .fadeOut(duration: 500.ms),
            const SizedBox(height: 32),
            Text(
              '来自 ${DateFormat('yyyy年M月d日').format(widget.capsule.createdAt)}',
              style: const TextStyle(
                color: AppColors.accentGold,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 800.ms),
            const SizedBox(height: 8),
            Text(
              '过去的你写了一封信',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ).animate(delay: 1000.ms).fadeIn(duration: 800.ms),
            const SizedBox(height: 48),
            // Particle-like dots
            ...List.generate(5, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(delay: (1500 + i * 100).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 1, end: 0),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterView() {
    final capsule = widget.capsule;
    final dateFormat = DateFormat('yyyy年M月d日');
    final daysAgo = DateTime.now().difference(capsule.createdAt).inDays;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareCapsule(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: _showContent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Mood + Title
                  Center(
                    child: Text(
                      capsule.mood ?? '💌',
                      style: const TextStyle(fontSize: 48),
                    ),
                  ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      capsule.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '写于 ${dateFormat.format(capsule.createdAt)} · $daysAgo 天前',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ).animate(delay: 400.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 32),

                  // Divider
                  Center(
                    child: Container(
                      width: 40,
                      height: 1,
                      color: AppColors.border,
                    ),
                  ).animate(delay: 500.ms).fadeIn().scaleX(begin: 0, alignment: Alignment.center),

                  const SizedBox(height: 32),

                  // Letter content
                  Text(
                    capsule.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 2.0,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ).animate(delay: 700.ms).fadeIn(duration: 800.ms),

                  const SizedBox(height: 48),

                  // Signature
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 1,
                          color: AppColors.border,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '来自 ${dateFormat.format(capsule.createdAt)} 的你',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 1000.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 64),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  void _shareCapsule() {
    final capsule = widget.capsule;
    final text = '📮 时间胶囊\n\n'
        '「${capsule.title}」\n\n'
        '${capsule.content}\n\n'
        '—— 写于${DateFormat('yyyy年M月d日').format(capsule.createdAt)}，'
        '在${DateFormat('yyyy年M月d日').format(capsule.unlockAt)}打开\n\n'
        '#时间胶囊 #写给未来的自己';
    Share.share(text);
  }
}
