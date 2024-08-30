import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';

enum ButtonVariant {
  primary,
  secondary,
  neutral,
  success,
  successSoft,
  danger,
}

class Button extends ConsumerWidget {
  const Button({
    super.key,
    this.onPressed,
    this.text,
    this.variant = ButtonVariant.primary,
    this.rounded = false,
    this.loading = false,
    this.wrap = false,
  });

  factory Button.danger({
    Key? key,
    Function()? onPressed,
    Widget? text,
    bool rounded = false,
    bool loading = false,
    bool wrap = false,
  }) {
    return Button(
      key: key,
      onPressed: onPressed,
      text: text,
      variant: ButtonVariant.danger,
      rounded: rounded,
      loading: loading,
      wrap: wrap,
    );
  }

  factory Button.successSoft({
    Key? key,
    Function()? onPressed,
    Widget? text,
    bool rounded = false,
    bool wrap = false,
  }) {
    return Button(
      key: key,
      onPressed: onPressed,
      text: text,
      variant: ButtonVariant.successSoft,
      rounded: rounded,
      wrap: wrap,
    );
  }

  factory Button.success({
    Key? key,
    Function()? onPressed,
    Widget? text,
    bool rounded = false,
    bool wrap = false,
  }) {
    return Button(
      key: key,
      onPressed: onPressed,
      text: text,
      variant: ButtonVariant.success,
      rounded: rounded,
      wrap: wrap,
    );
  }

  factory Button.white({
    Key? key,
    Function()? onPressed,
    Widget? text,
    bool rounded = false,
    bool loading = false,
    bool wrap = false,
  }) {
    return Button(
      key: key,
      onPressed: onPressed,
      text: text,
      variant: ButtonVariant.neutral,
      rounded: rounded,
      loading: loading,
      wrap: wrap,
    );
  }

  factory Button.secondary({
    Key? key,
    Function()? onPressed,
    Widget? text,
    bool rounded = false,
    bool loading = false,
    bool wrap = false,
  }) {
    return Button(
      key: key,
      onPressed: onPressed,
      text: text,
      variant: ButtonVariant.secondary,
      rounded: rounded,
      loading: loading,
      wrap: wrap,
    );
  }

  factory Button.primary({
    Key? key,
    Function()? onPressed,
    Widget? text,
    bool rounded = false,
    bool loading = false,
    bool wrap = false,
  }) {
    return Button(
      key: key,
      onPressed: onPressed,
      text: text,
      rounded: rounded,
      loading: loading,
      wrap: wrap,
    );
  }

  final Function()? onPressed;
  final Widget? text;
  final ButtonVariant variant;
  final bool rounded;
  final bool loading;
  final bool wrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);
    Color backgroundColor;
    Color foregroundColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = customAppTheme.colorsPalette.primary;
        foregroundColor = customAppTheme.colorsPalette.white;
        break;
      case ButtonVariant.secondary:
        backgroundColor = customAppTheme.colorsPalette.white;
        foregroundColor = customAppTheme.colorsPalette.primary;
        break;
      case ButtonVariant.neutral:
        backgroundColor = customAppTheme.colorsPalette.primary7;
        foregroundColor = customAppTheme.colorsPalette.primary70;
        break;
      case ButtonVariant.success:
        backgroundColor = customAppTheme.colorsPalette.positiveAction;
        foregroundColor = customAppTheme.colorsPalette.white;
        break;
      case ButtonVariant.successSoft:
        backgroundColor = customAppTheme.colorsPalette.neutral3;
        foregroundColor = customAppTheme.colorsPalette.primary;
        break;
      case ButtonVariant.danger:
        backgroundColor = customAppTheme.colorsPalette.negativeAction;
        foregroundColor = customAppTheme.colorsPalette.white;
        break;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        elevation: WidgetStateProperty.all<double>(0),
        backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
        minimumSize: WidgetStateProperty.all<Size>(
          Size(wrap ? 0 : double.infinity, rounded ? 55 : 64),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          customAppTheme.textStyles.headlineLarge,
        ),
        foregroundColor: WidgetStateProperty.all<Color>(foregroundColor),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              rounded ? const Radius.circular(8) : Radius.zero,
            ),
          ),
        ),
      ),
      child: loading
          ? CircularProgressIndicator(
              color: foregroundColor,
              strokeWidth: 3,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: text,
            ),
    );
  }
}
