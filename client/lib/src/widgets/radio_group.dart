import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'radio_button.dart';

class RadioGroup extends ConsumerStatefulWidget {
  const RadioGroup({
    super.key,
    required this.options,
    required this.label,
  });
  final List<RadioButton> options;
  final String label;

  @override
  ConsumerState createState() => _RadioGroupState();
}

class _RadioGroupState extends ConsumerState<RadioGroup> {
  @override
  Widget build(BuildContext context) {
    final CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            widget.label,
            style: customAppTheme.textStyles.bodySmall,
          ),
        ),
        Row(
          children: widget.options,
        ),
      ],
    );
  }
}
