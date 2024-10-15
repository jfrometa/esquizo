import 'dart:developer';
import 'dart:ui' as ui;

import 'package:starter_architecture_flutter_firebase/helpers/currency_converter.dart';
import 'package:starter_architecture_flutter_firebase/widgets/chart/chart_data.dart';
import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  ChartPainter({
    required this.data,
    required this.currency,
    this.color,
    this.axisTextStyle,
    this.labelTextStyle,
  });
  ChartData data;
  Color? color;
  TextStyle? labelTextStyle;
  TextStyle? axisTextStyle;
  String currency;

  final num _labelsHeight = 30;
  final num _yAxisWidth = 56;
  final num _topPadding = 16;

  _drawYAxis(Canvas canvas, Size size) {
    var hLine = (size.height - _labelsHeight) / (data.intervals().length - 1);

    var guides = Paint();
    guides.color = Colors.grey.withOpacity(.5);
    guides.strokeWidth = .7;

    for (var i = 0; i < data.intervals().length; i++) {
      final label =
          data.intervals()[i].toDouble().convertToCompactCurrency(currency);

      TextPainter tp = TextPainter(
        text: TextSpan(
          style: axisTextStyle ?? TextStyle(color: Colors.grey[600]),
          text: label,
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        _invertOffest(
          Offset(0, (_labelsHeight + i * hLine) - tp.height / 2),
          size,
        ),
      );
      canvas.drawPoints(
        ui.PointMode.lines,
        List.generate(
          ((size.width - _yAxisWidth) / 6).truncate() + 1,
          (index) => Offset(_yAxisWidth + (index * 6), _topPadding + i * hLine),
        ),
        guides,
      );
    }
  }

  Offset _invertOffest(Offset offset, Size size) {
    return Offset(offset.dx, size.height - offset.dy);
  }

  _plotLine(Canvas canvas, Size size) {
    var values = data.values;
    var hLine = (size.height - _labelsHeight) / (data.intervals().length - 1);
    var columnWidth = (size.width - _yAxisWidth) / (data.values.length - 1);

    var fill = Paint()
      ..color = color ?? Colors.amber
      ..strokeWidth = 3
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.63, size.height * 0.21),
        Offset(size.width * 0.63, size.height * 0.9),
        [
          color?.withOpacity(.3) ?? Colors.amber.withOpacity(.3),
          color?.withOpacity(0) ?? Colors.amber.withOpacity(0),
        ],
        [0.0, 1.00],
      );

    var linePaint = Paint()
      ..color = color ?? Colors.amber
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var linePath = Path();
    var path = Path();
    path.moveTo(_yAxisWidth.toDouble(), size.height - 14);
    path.lineTo(
      _yAxisWidth.toDouble(),
      size.height -
          ((values[0] - data.intervals().first) *
              data.scale(hLine * (data.intervals().length - 1))) +
          _topPadding -
          _labelsHeight,
    );
    linePath.moveTo(
      _yAxisWidth.toDouble(),
      size.height -
          ((values[0] - data.intervals().first) *
              data.scale(hLine * (data.intervals().length - 1))) +
          _topPadding -
          _labelsHeight,
    );

    int xAxisInterval = 1;
    if (data.values.length > 10) {
      xAxisInterval = 2;
    }
    if (data.values.length > 15) {
      xAxisInterval = 3;
    }
    if (data.values.length > 28) {
      xAxisInterval = 8;
    }

    for (var index = 0; index < data.values.length; index++) {
      final label = data.labels?[index] ?? '';

      TextPainter tp = TextPainter(
        text: TextSpan(
          style: labelTextStyle ?? TextStyle(color: Colors.grey[600]),
          text: label,
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      tp.layout();

      if (index % xAxisInterval == 0) {
        tp.paint(
          canvas,
          Offset(
            _yAxisWidth + (index * columnWidth) - tp.width / 2,
            size.height,
          ),
        );
      }
      if (index > 0) {
        path.lineTo(
          _yAxisWidth + index * columnWidth,
          size.height -
              (((values[index] - data.intervals().first) *
                      data.scale(hLine * (data.intervals().length - 1))) +
                  14),
        );
        linePath.lineTo(
          _yAxisWidth + index * columnWidth,
          size.height -
              (((values[index] - data.intervals().first) *
                      data.scale(hLine * (data.intervals().length - 1))) +
                  14),
        );
      }
    }

    path.lineTo(
      _yAxisWidth + (data.values.length - 1) * columnWidth,
      size.height - 14,
    );

    canvas.drawPath(path, fill);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    try {
      _drawYAxis(canvas, size);
      _plotLine(canvas, size);
    } catch (exception) {
      log('chartPainter Error: $exception');
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
