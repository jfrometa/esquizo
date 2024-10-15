import 'package:starter_architecture_flutter_firebase/screens/pin_code_and_biometrics/biometric_overlay_content.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BiometricOverlay extends ModalRoute {
  BiometricOverlay({
    required this.customAppTheme,
    required this.onAuthenticate,
    required this.onCancelOrFail,
  });
  final CustomAppTheme customAppTheme;
  final Function onAuthenticate;
  final Function onCancelOrFail;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'Biometric Login';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return BiometricOverlayContent(
      onAuthenticate: onAuthenticate,
      onCancelOrFail: onCancelOrFail,
    );
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor =>
      customAppTheme.colorsPalette.primary.withOpacity(0.95);
}
