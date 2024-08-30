import 'package:flutter/material.dart';

Route<T> slidePageBuilder<T>(
  BuildContext context,
  Widget child,
  Page<T> page,
) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    settings: page,
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1, 0),
          ).animate(secondaryAnimation),
          child: child,
        ), // child is the value returned by pageBuilder
      );
    },
  );
}
