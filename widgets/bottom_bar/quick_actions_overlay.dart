import 'package:starter_architecture_flutter_firebase/widgets/bottom_bar/quick_actions_overlay_content.dart';
import 'package:flutter/material.dart';

class QuickActionsOverlay extends ModalRoute {
  QuickActionsOverlay({
    this.left,
    this.middle,
    this.right,
  });
  QuickActionData? left;
  QuickActionData? middle;
  QuickActionData? right;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'Teste';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return QuickActionsOverlayContent(
      left: left,
      middle: middle,
      right: right,
    );
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration();

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => Colors.transparent;
}
