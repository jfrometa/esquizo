import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Toggle extends ConsumerStatefulWidget {
  const Toggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final Function(bool) onChanged;

  @override
  ConsumerState createState() => _ToggleState();
}

class _ToggleState extends ConsumerState<Toggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideAnimationController;

  @override
  void initState() {
    super.initState();

    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    if (widget.value) {
      _slideAnimationController.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant Toggle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _slideAnimationController.forward();
      } else {
        _slideAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: GestureDetector(
        onTap: () {
          widget.onChanged(!widget.value);
        },
        child: FadeTransition(
          opacity: Tween<double>(begin: .4, end: 1).animate(
            _slideAnimationController,
          ),
          child: Container(
            height: 22,
            width: 40,
            decoration: BoxDecoration(
              color: customAppTheme.colorsPalette.primary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-.25, 0),
                  end: const Offset(.25, 0),
                ).animate(_slideAnimationController),
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: customAppTheme.colorsPalette.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
