// File: lib/src/screens/setup/color_picker_widget.dart

import 'dart:math';

import 'package:flutter/material.dart';

enum PickerType { materialDesign, hueWheel, custom }

class ColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final PickerType pickerType;

  const ColorPicker({
    super.key,
    required this.color,
    required this.onColorChanged,
    this.pickerType = PickerType.materialDesign,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;
  late HSVColor _currentHsvColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.color;
    _currentHsvColor = HSVColor.fromColor(_currentColor);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.pickerType) {
      case PickerType.materialDesign:
        return _buildMaterialPicker();
      case PickerType.hueWheel:
        return _buildHueWheelPicker();
      case PickerType.custom:
        return _buildCustomPicker();
      default:
        return _buildMaterialPicker();
    }
  }

  Widget _buildMaterialPicker() {
    return SizedBox(
      height: 380,
      width: 300,
      child: Column(
        children: [
          _buildColorDisplay(),
          const SizedBox(height: 16),
          _buildMaterialPalette(),
          const SizedBox(height: 16),
          _buildShadesSlider(),
        ],
      ),
    );
  }

  Widget _buildHueWheelPicker() {
    return SizedBox(
      height: 380,
      width: 300,
      child: Column(
        children: [
          _buildColorDisplay(),
          const SizedBox(height: 16),
          _buildHueWheel(),
          const SizedBox(height: 16),
          _buildSaturationValueSliders(),
        ],
      ),
    );
  }

  Widget _buildCustomPicker() {
    return SizedBox(
      height: 380,
      width: 300,
      child: Column(
        children: [
          _buildColorDisplay(),
          const SizedBox(height: 16),
          _buildMaterialPalette(),
          const SizedBox(height: 16),
          _buildRgbSliders(),
        ],
      ),
    );
  }

  Widget _buildColorDisplay() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _currentColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '#${_currentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
          style: TextStyle(
            color: _currentColor.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialPalette() {
    // Material Design color palette
    final List<List<Color>> materialColors = [
      // Red
      [
        const Color(0xFFFFEBEE),
        const Color(0xFFFFCDD2),
        const Color(0xFFEF9A9A),
        const Color(0xFFE57373),
        const Color(0xFFEF5350),
        const Color(0xFFF44336),
        const Color(0xFFE53935),
        const Color(0xFFD32F2F),
        const Color(0xFFC62828),
        const Color(0xFFB71C1C),
      ],
      // Pink
      [
        const Color(0xFFFCE4EC),
        const Color(0xFFF8BBD0),
        const Color(0xFFF48FB1),
        const Color(0xFFF06292),
        const Color(0xFFEC407A),
        const Color(0xFFE91E63),
        const Color(0xFFD81B60),
        const Color(0xFFC2185B),
        const Color(0xFFAD1457),
        const Color(0xFF880E4F),
      ],
      // Purple
      [
        const Color(0xFFF3E5F5),
        const Color(0xFFE1BEE7),
        const Color(0xFFCE93D8),
        const Color(0xFFBA68C8),
        const Color(0xFFAB47BC),
        const Color(0xFF9C27B0),
        const Color(0xFF8E24AA),
        const Color(0xFF7B1FA2),
        const Color(0xFF6A1B9A),
        const Color(0xFF4A148C),
      ],
      // Deep Purple
      [
        const Color(0xFFEDE7F6),
        const Color(0xFFD1C4E9),
        const Color(0xFFB39DDB),
        const Color(0xFF9575CD),
        const Color(0xFF7E57C2),
        const Color(0xFF673AB7),
        const Color(0xFF5E35B1),
        const Color(0xFF512DA8),
        const Color(0xFF4527A0),
        const Color(0xFF311B92),
      ],
      // Indigo
      [
        const Color(0xFFE8EAF6),
        const Color(0xFFC5CAE9),
        const Color(0xFF9FA8DA),
        const Color(0xFF7986CB),
        const Color(0xFF5C6BC0),
        const Color(0xFF3F51B5),
        const Color(0xFF3949AB),
        const Color(0xFF303F9F),
        const Color(0xFF283593),
        const Color(0xFF1A237E),
      ],
      // Blue
      [
        const Color(0xFFE3F2FD),
        const Color(0xFFBBDEFB),
        const Color(0xFF90CAF9),
        const Color(0xFF64B5F6),
        const Color(0xFF42A5F5),
        const Color(0xFF2196F3),
        const Color(0xFF1E88E5),
        const Color(0xFF1976D2),
        const Color(0xFF1565C0),
        const Color(0xFF0D47A1),
      ],
      // Light Blue
      [
        const Color(0xFFE1F5FE),
        const Color(0xFFB3E5FC),
        const Color(0xFF81D4FA),
        const Color(0xFF4FC3F7),
        const Color(0xFF29B6F6),
        const Color(0xFF03A9F4),
        const Color(0xFF039BE5),
        const Color(0xFF0288D1),
        const Color(0xFF0277BD),
        const Color(0xFF01579B),
      ],
      // Cyan
      [
        const Color(0xFFE0F7FA),
        const Color(0xFFB2EBF2),
        const Color(0xFF80DEEA),
        const Color(0xFF4DD0E1),
        const Color(0xFF26C6DA),
        const Color(0xFF00BCD4),
        const Color(0xFF00ACC1),
        const Color(0xFF0097A7),
        const Color(0xFF00838F),
        const Color(0xFF006064),
      ],
      // Teal
      [
        const Color(0xFFE0F2F1),
        const Color(0xFFB2DFDB),
        const Color(0xFF80CBC4),
        const Color(0xFF4DB6AC),
        const Color(0xFF26A69A),
        const Color(0xFF009688),
        const Color(0xFF00897B),
        const Color(0xFF00796B),
        const Color(0xFF00695C),
        const Color(0xFF004D40),
      ],
      // Green
      [
        const Color(0xFFE8F5E9),
        const Color(0xFFC8E6C9),
        const Color(0xFFA5D6A7),
        const Color(0xFF81C784),
        const Color(0xFF66BB6A),
        const Color(0xFF4CAF50),
        const Color(0xFF43A047),
        const Color(0xFF388E3C),
        const Color(0xFF2E7D32),
        const Color(0xFF1B5E20),
      ],
      // Light Green
      [
        const Color(0xFFF1F8E9),
        const Color(0xFFDCEDC8),
        const Color(0xFFC5E1A5),
        const Color(0xFFAED581),
        const Color(0xFF9CCC65),
        const Color(0xFF8BC34A),
        const Color(0xFF7CB342),
        const Color(0xFF689F38),
        const Color(0xFF558B2F),
        const Color(0xFF33691E),
      ],
      // Lime
      [
        const Color(0xFFF9FBE7),
        const Color(0xFFF0F4C3),
        const Color(0xFFE6EE9C),
        const Color(0xFFDCE775),
        const Color(0xFFD4E157),
        const Color(0xFFCDDC39),
        const Color(0xFFC0CA33),
        const Color(0xFFAFB42B),
        const Color(0xFF9E9D24),
        const Color(0xFF827717),
      ],
      // Yellow
      [
        const Color(0xFFFFFDE7),
        const Color(0xFFFFF9C4),
        const Color(0xFFFFF59D),
        const Color(0xFFFFF176),
        const Color(0xFFFFEE58),
        const Color(0xFFFFEB3B),
        const Color(0xFFFDD835),
        const Color(0xFFFBC02D),
        const Color(0xFFF9A825),
        const Color(0xFFF57F17),
      ],
      // Amber
      [
        const Color(0xFFFFF8E1),
        const Color(0xFFFFECB3),
        const Color(0xFFFFE082),
        const Color(0xFFFFD54F),
        const Color(0xFFFFCA28),
        const Color(0xFFFFC107),
        const Color(0xFFFFB300),
        const Color(0xFFFFA000),
        const Color(0xFFFF8F00),
        const Color(0xFFFF6F00),
      ],
      // Orange
      [
        const Color(0xFFFFF3E0),
        const Color(0xFFFFE0B2),
        const Color(0xFFFFCC80),
        const Color(0xFFFFB74D),
        const Color(0xFFFFA726),
        const Color(0xFFFF9800),
        const Color(0xFFFB8C00),
        const Color(0xFFF57C00),
        const Color(0xFFEF6C00),
        const Color(0xFFE65100),
      ],
      // Deep Orange
      [
        const Color(0xFFFBE9E7),
        const Color(0xFFFFCCBC),
        const Color(0xFFFFAB91),
        const Color(0xFFFF8A65),
        const Color(0xFFFF7043),
        const Color(0xFFFF5722),
        const Color(0xFFF4511E),
        const Color(0xFFE64A19),
        const Color(0xFFD84315),
        const Color(0xFFBF360C),
      ],
      // Brown
      [
        const Color(0xFFEFEBE9),
        const Color(0xFFD7CCC8),
        const Color(0xFFBCAAA4),
        const Color(0xFFA1887F),
        const Color(0xFF8D6E63),
        const Color(0xFF795548),
        const Color(0xFF6D4C41),
        const Color(0xFF5D4037),
        const Color(0xFF4E342E),
        const Color(0xFF3E2723),
      ],
      // Grey
      [
        const Color(0xFFFAFAFA),
        const Color(0xFFF5F5F5),
        const Color(0xFFEEEEEE),
        const Color(0xFFE0E0E0),
        const Color(0xFFBDBDBD),
        const Color(0xFF9E9E9E),
        const Color(0xFF757575),
        const Color(0xFF616161),
        const Color(0xFF424242),
        const Color(0xFF212121),
      ],
      // Blue Grey
      [
        const Color(0xFFECEFF1),
        const Color(0xFFCFD8DC),
        const Color(0xFFB0BEC5),
        const Color(0xFF90A4AE),
        const Color(0xFF78909C),
        const Color(0xFF607D8B),
        const Color(0xFF546E7A),
        const Color(0xFF455A64),
        const Color(0xFF37474F),
        const Color(0xFF263238),
      ],
    ];

    return SizedBox(
      height: 180,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 1,
        ),
        itemCount: materialColors.length * 10,
        itemBuilder: (context, index) {
          final colorFamily = index ~/ 10;
          final shade = index % 10;
          final color = materialColors[colorFamily][shade];

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentColor = color;
                _currentHsvColor = HSVColor.fromColor(_currentColor);
                widget.onColorChanged(_currentColor);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: color == _currentColor
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShadesSlider() {
    return Column(
      children: [
        const Text('Brightness'),
        Slider(
          value: _currentHsvColor.value,
          min: 0.0,
          max: 1.0,
          onChanged: (value) {
            setState(() {
              _currentHsvColor = _currentHsvColor.withValue(value);
              _currentColor = _currentHsvColor.toColor();
              widget.onColorChanged(_currentColor);
            });
          },
        ),
      ],
    );
  }

  Widget _buildHueWheel() {
    return SizedBox(
      height: 180,
      width: 180,
      child: CustomPaint(
        painter: HueWheelPainter(
          hue: _currentHsvColor.hue,
          onHueChanged: (hue) {
            setState(() {
              _currentHsvColor = _currentHsvColor.withHue(hue);
              _currentColor = _currentHsvColor.toColor();
              widget.onColorChanged(_currentColor);
            });
          },
        ),
        child: Center(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _currentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaturationValueSliders() {
    return Column(
      children: [
        const Text('Saturation'),
        Slider(
          value: _currentHsvColor.saturation,
          min: 0.0,
          max: 1.0,
          onChanged: (value) {
            setState(() {
              _currentHsvColor = _currentHsvColor.withSaturation(value);
              _currentColor = _currentHsvColor.toColor();
              widget.onColorChanged(_currentColor);
            });
          },
        ),
        const Text('Brightness'),
        Slider(
          value: _currentHsvColor.value,
          min: 0.0,
          max: 1.0,
          onChanged: (value) {
            setState(() {
              _currentHsvColor = _currentHsvColor.withValue(value);
              _currentColor = _currentHsvColor.toColor();
              widget.onColorChanged(_currentColor);
            });
          },
        ),
      ],
    );
  }

  Widget _buildRgbSliders() {
    return Column(
      children: [
        const Text('Red'),
        Slider(
          value: _currentColor.r * 255,
          min: 0,
          max: 255,
          activeColor: Colors.red,
          onChanged: (value) {
            setState(() {
              _currentColor = Color.fromARGB(
                (_currentColor.a * 255).round(),
                value.toInt(),
                (_currentColor.g * 255).round(),
                (_currentColor.b * 255).round(),
              );
              _currentHsvColor = HSVColor.fromColor(_currentColor);
              widget.onColorChanged(_currentColor);
            });
          },
        ),
        const Text('Green'),
        Slider(
          value: _currentColor.g * 255,
          min: 0,
          max: 255,
          activeColor: Colors.green,
          onChanged: (value) {
            setState(() {
              _currentColor = Color.fromARGB(
                (_currentColor.a * 255).round(),
                (_currentColor.r * 255).round(),
                value.toInt(),
                (_currentColor.b * 255).round(),
              );
              _currentHsvColor = HSVColor.fromColor(_currentColor);
              widget.onColorChanged(_currentColor);
            });
          },
        ),
        const Text('Blue'),
        Slider(
          value: _currentColor.b * 255,
          min: 0,
          max: 255,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              _currentColor = Color.fromARGB(
                (_currentColor.a * 255).round(),
                (_currentColor.r * 255).round(),
                (_currentColor.g * 255).round(),
                value.toInt(),
              );
              _currentHsvColor = HSVColor.fromColor(_currentColor);
              widget.onColorChanged(_currentColor);
            });
          },
        ),
      ],
    );
  }
}

class HueWheelPainter extends CustomPainter {
  final double hue;
  final ValueChanged<double> onHueChanged;

  HueWheelPainter({
    required this.hue,
    required this.onHueChanged,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw hue wheel
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius;

    for (int i = 0; i < 360; i++) {
      final color = HSVColor.fromAHSV(1.0, i.toDouble(), 1.0, 1.0).toColor();
      paint.color = color;

      final startAngle = (i - 0.5) * pi / 180;
      final endAngle = (i + 0.5) * pi / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius / 2),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }

    // Draw thumb
    final thumbAngle = hue * pi / 180;
    final thumbX = center.dx + cos(thumbAngle) * (radius / 2);
    final thumbY = center.dy + sin(thumbAngle) * (radius / 2);
    final thumbCenter = Offset(thumbX, thumbY);

    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(thumbCenter, 5, thumbPaint);

    final thumbBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(thumbCenter, 5, thumbBorderPaint);
  }

  @override
  bool shouldRepaint(HueWheelPainter oldDelegate) {
    return oldDelegate.hue != hue;
  }

  @override
  bool hitTest(Offset position) {
    return true;
  }
}
