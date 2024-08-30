import 'package:flutter/widgets.dart';

Widget slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(animation),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-.5, 0),
      ).animate(secondaryAnimation),
      child: child,
    ), // child is the value returned by pageBuilder
  );
}
