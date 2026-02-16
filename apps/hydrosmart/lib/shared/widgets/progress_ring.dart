import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0+
  final double size;
  final double strokeWidth;
  final Color? color;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 14,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final ringColor = color ?? Theme.of(context).colorScheme.primary;
    final trackColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: clampedProgress,
              strokeWidth: strokeWidth,
              color: ringColor,
              trackColor: trackColor,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
