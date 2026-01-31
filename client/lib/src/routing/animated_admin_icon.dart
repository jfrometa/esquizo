import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';

/// Animated admin icon widget that shows/hides based on admin status
/// This widget handles its own animation controller to avoid rebuilding the parent scaffold
class AnimatedAdminIcon extends ConsumerStatefulWidget {
  final IconData icon;
  final double? iconSize;
  final bool isNavigationRail;

  const AnimatedAdminIcon({
    super.key,
    required this.icon,
    this.iconSize,
    this.isNavigationRail = true,
  });

  @override
  ConsumerState<AnimatedAdminIcon> createState() => _AnimatedAdminIconState();
}

class _AnimatedAdminIconState extends ConsumerState<AnimatedAdminIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch admin status and animate accordingly
    final isAdmin = ref.watch(isAdminComputedProvider);

    // Animate based on admin status
    if (isAdmin) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    if (widget.isNavigationRail) {
      // For navigation rail, we need both horizontal and vertical animations
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: _sizeAnimation.value * 56, // Standard rail icon width
            height: _sizeAnimation.value * 56,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Icon(
                widget.icon,
                size: widget.iconSize,
              ),
            ),
          );
        },
      );
    } else {
      // For bottom navigation bar, we only need horizontal animation
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: _sizeAnimation.value * 24, // Standard icon width
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Icon(
                widget.icon,
                size: widget.iconSize,
              ),
            ),
          );
        },
      );
    }
  }
}
