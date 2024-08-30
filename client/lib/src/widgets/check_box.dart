import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckBox extends ConsumerWidget {
  const CheckBox({
    super.key,
    this.onChanged,
    this.small = false,
    required this.value,
  });

  final Function(bool?)? onChanged;
  final bool value;
  final bool small;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Transform.scale(
      scale: small ? 1 : 1.4445,
      child: Checkbox(
        activeColor: customAppTheme.colorsPalette.primary,
        splashRadius: 14,
        side:
            BorderSide(width: 0.4, color: customAppTheme.colorsPalette.primary),
        shape: const CircleBorder(),
        onChanged: onChanged,
        value: value,
        visualDensity: const VisualDensity(horizontal: 2, vertical: 1),
      ),
    );
  }
}
