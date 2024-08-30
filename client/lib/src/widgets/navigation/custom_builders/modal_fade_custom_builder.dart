import 'package:flutter/material.dart';

Route<T> modalFadeCustomBuilder<T>(
  BuildContext context,
  Widget child,
  Page<T> page,
) {
  return PageRouteBuilder(
    barrierColor: Colors.transparent,
    opaque: false,
    barrierDismissible: true,
    settings: page,
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
