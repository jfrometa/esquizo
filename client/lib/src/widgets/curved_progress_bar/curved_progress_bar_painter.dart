import 'dart:math';

import 'package:flutter/widgets.dart';

class CurvedProgressBarPainter extends CustomPainter {

  CurvedProgressBarPainter({
    required this.color,
    required this.progress,
    this.padding = 20,
  });
  final Color color;
  final double progress;
  final double padding;

  @override
  void paint(Canvas canvas, Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    Offset center = Offset(size.width / 2, size.height + 16);

    final Paint progressBarBg = Paint()
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..color = color.withOpacity(0.07)
      ..strokeCap = StrokeCap.round;

    final progressBarBgPath = Path();
    progressBarBgPath.arcTo(
      Rect.fromCenter(
        center: center,
        height: (size.width) - padding * 2,
        width: size.width - padding * 2,
      ),
      degToRad(190),
      degToRad(160),
      false,
    );

    final Paint progressBar = Paint()
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeCap = StrokeCap.round;

    final progressBarPath = Path();
    progressBarPath.arcTo(
      Rect.fromCenter(
        center: center,
        height: (size.width) - padding * 2,
        width: size.width - padding * 2,
      ),
      degToRad(190),
      degToRad(1.6 * progress),
      false,
    );

    canvas.drawPath(progressBarBgPath, progressBarBg);
    canvas.drawPath(progressBarPath, progressBar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
