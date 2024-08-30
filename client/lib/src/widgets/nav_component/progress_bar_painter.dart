import 'package:flutter/material.dart';

class ProgressBarPainter extends CustomPainter {
  ProgressBarPainter({
    required this.backgroundColor,
    required this.color,
    required this.progress,
  });

  Color backgroundColor;
  Color color;
  double progress;

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgPaint = Paint()
      ..strokeWidth = 5
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round;

    Paint fgPaint = Paint()
      ..strokeWidth = 5
      ..color = color
      ..strokeCap = StrokeCap.round;

    double scale = size.width / 100;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), bgPaint);
    canvas.drawLine(const Offset(0, 0), Offset(progress * scale, 0), fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
