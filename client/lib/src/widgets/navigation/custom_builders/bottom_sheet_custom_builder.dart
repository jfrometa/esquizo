import 'package:flutter/material.dart';

Route<T> bottomSheetCustomBuilder<T>(
  BuildContext context,
  Widget child,
  Page<T> page,
) {
  return PageRouteBuilder(
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    opaque: false,
    barrierDismissible: true,
    settings: page,
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: const Offset(0, 0),
        ).animate(animation),
        child: child,
      );
    },
  );
}
