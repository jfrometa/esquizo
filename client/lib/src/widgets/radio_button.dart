import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RadioButton<T> extends StatefulWidget {
  const RadioButton({
    super.key,
    required this.onChanged,
    required this.value,
    required this.groupValue,
    this.isEnabled = true,
    this.labelStyle,
    this.label,
  });
  final void Function(T value) onChanged;
  final T value;
  final T groupValue;
  final String? label;
  final TextStyle? labelStyle;
  final bool isEnabled;

  bool get _selected => value == groupValue;

  @override
  State<RadioButton<T>> createState() => _RadioButtonState<T>();
}

class _RadioButtonState<T> extends State<RadioButton<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void didUpdateWidget(RadioButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isEnabled != oldWidget.isEnabled) {
      if (!widget.isEnabled) {
        _animationController.forward();
        return;
      } else {
        _animationController.reverse();
        return;
      }
    }

    if (widget._selected != oldWidget._selected) {
      if (widget._selected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    if (widget._selected && widget.isEnabled) {
      _animationController.forward();
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
      value: widget._selected ? 1 : 0,
    );
  }

  @override
  void dispose() {
    super.dispose();

    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        CustomAppTheme customAppTheme = ref.read(appThemeProvider);
        return Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (widget.isEnabled) {
                  widget.onChanged(widget.value);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => Container(
                    height: 26,
                    width: 26,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        width: _animationController.value *
                            (widget.isEnabled ? 8 : 13),
                        color: widget.isEnabled
                            ? customAppTheme.colorsPalette.primary
                            : customAppTheme.colorsPalette.neutral4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            widget.label != null
                ? Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 24.0),
                      child: Text(
                        widget.label!,
                        style: widget.labelStyle ??
                            customAppTheme.textStyles.headlineLarge,
                      ),
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }
}
