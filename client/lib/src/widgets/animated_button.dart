import 'package:flutter/material.dart';

import 'button.dart';

class AnimatedButton extends StatelessWidget {
  const AnimatedButton({
    super.key,
    required this.buttonEnabled,
    this.onPressed,
    required this.text,
    this.variant = ButtonVariant.primary,
    this.loading = false,
    this.onEnd,
  });
  final bool buttonEnabled;
  final Widget text;
  final Function()? onPressed;
  final ButtonVariant variant;
  final bool loading;
  final Function()? onEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      onEnd: onEnd,
      duration: const Duration(milliseconds: 200),
      height: buttonEnabled ? 64 : 0,
      curve: Curves.linearToEaseOut,
      child: Button(
        variant: variant,
        loading: loading,
        onPressed: onPressed,
        text: text,
      ),
    );
  }
}
