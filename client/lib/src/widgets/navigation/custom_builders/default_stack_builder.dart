import 'package:flutter/material.dart';

Route<T> defaultStackBuilder<T>(
  BuildContext context,
  Widget child,
  Page<T> page,
) {
  return PageRouteBuilder(
    barrierColor: Colors.black.withOpacity(0.5),
    settings: page,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.8, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}
