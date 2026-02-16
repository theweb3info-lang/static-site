import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../shared/theme/app_theme.dart';

class BatteryPainter extends CustomPainter {
  final double level;
  final double animationValue;
  final bool isDark;

  BatteryPainter({
    required this.level,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Battery body dimensions
    final bodyLeft = w * 0.15;
    final bodyTop = h * 0.12;
    final bodyWidth = w * 0.7;
    final bodyHeight = h * 0.78;
    final cornerRadius = 16.0;

    // Battery cap
    final capWidth = w * 0.25;
    final capHeight = h * 0.05;
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (w - capWidth) / 2,
        bodyTop - capHeight + 2,
        capWidth,
        capHeight,
      ),
      const Radius.circular(4),
    );
    final capPaint = Paint()
      ..color = isDark ? AppColors.darkBorder : AppColors.lightBorder
      ..style = PaintingStyle.fill;
    canvas.drawRRect(capRect, capPaint);

    // Battery outline
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth, bodyHeight),
      Radius.circular(cornerRadius),
    );
    final outlinePaint = Paint()
      ..color = isDark ? AppColors.darkBorder : AppColors.lightBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(bodyRect, outlinePaint);

    // Fill level
    final fillPadding = 6.0;
    final fillHeight = (bodyHeight - fillPadding * 2) * (level / 100) * animationValue;
    final fillTop = bodyTop + bodyHeight - fillPadding - fillHeight;
    final fillRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        bodyLeft + fillPadding,
        fillTop,
        bodyWidth - fillPadding * 2,
        fillHeight,
      ),
      bottomLeft: Radius.circular(cornerRadius - fillPadding),
      bottomRight: Radius.circular(cornerRadius - fillPadding),
      topLeft: Radius.circular(fillHeight > 20 ? 8 : 4),
      topRight: Radius.circular(fillHeight > 20 ? 8 : 4),
    );

    final batteryColor = AppColors.getBatteryColor(level);

    // Gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          batteryColor.withValues(alpha: 0.8),
          batteryColor,
        ],
      ).createShader(fillRect.outerRect);
    canvas.drawRRect(fillRect, fillPaint);

    // Animated wave effect on top of fill
    if (level > 5 && animationValue >= 1.0) {
      final wavePath = Path();
      final waveTop = fillTop;
      final waveLeft = bodyLeft + fillPadding;
      final waveWidth = bodyWidth - fillPadding * 2;
      final waveAmplitude = 3.0;
      final phase = DateTime.now().millisecondsSinceEpoch / 500.0;

      wavePath.moveTo(waveLeft, waveTop);
      for (double x = 0; x <= waveWidth; x += 1) {
        final y = waveTop + math.sin((x / waveWidth * 2 * math.pi) + phase) * waveAmplitude;
        wavePath.lineTo(waveLeft + x, y);
      }
      wavePath.lineTo(waveLeft + waveWidth, waveTop + 10);
      wavePath.lineTo(waveLeft, waveTop + 10);
      wavePath.close();

      final wavePaint = Paint()
        ..color = batteryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.clipRRect(fillRect);
      canvas.drawPath(wavePath, wavePaint);
      canvas.restore();
    }

    // Shine effect
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth * 0.4, bodyHeight));
    canvas.save();
    canvas.clipRRect(bodyRect);
    canvas.drawRect(
      Rect.fromLTWH(bodyLeft, bodyTop, bodyWidth * 0.35, bodyHeight),
      shinePaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(BatteryPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}
