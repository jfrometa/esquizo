import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/catering-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/events-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/meal-plans-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/menu-section.dart';


// Custom scroll view to fix nested scroll behavior
class NestedScrollView extends StatefulWidget {
  final List<Widget> Function(BuildContext, bool) headerSliverBuilder;
  final Widget body;
  final VoidCallback onReachEnd;
  
  const NestedScrollView({
    super.key,
    required this.headerSliverBuilder,
    required this.body,
    required this.onReachEnd,
  });
  
  @override
  State<NestedScrollView> createState() => _NestedScrollViewState();
}

class _NestedScrollViewState extends State<NestedScrollView> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          if (notification.overscroll < 0 && notification.metrics.pixels <= 0) {
            // This means we're at the top of the content and trying to scroll up
            widget.onReachEnd();
          }
        }
        return false;
      },
      child: widget.body,
    );
  }
}

// Custom widget to detect overscroll at the top edge
class CustomScrollOverflowNotifier extends StatelessWidget {
  final Widget child;
  final Function(double) onOverScroll;
  
  const CustomScrollOverflowNotifier({
    super.key,
    required this.child,
    required this.onOverScroll,
  });
  
  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollNotification>(
      onNotification: (notification) {
        // Only interested in overscroll at top boundary (leading edge)
        if (notification.metrics.pixels <= 0) {
          onOverScroll(notification.overscroll);
        }
        return false;
      },
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          // Also detect when we're at top and trying to scroll up
          if (notification.metrics.pixels <= 0 && 
              notification.scrollDelta != null && 
              notification.scrollDelta! < 0) {
            onOverScroll(notification.scrollDelta!);
          }
          return false;
        },
        child: child,
      ),
    );
  }
}

  // Error view remains the same
