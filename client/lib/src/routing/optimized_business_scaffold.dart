// Optimized business scaffold for seamless navigation
// Provides persistent navigation state for business routes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';

/// Optimized business scaffold that provides seamless navigation
class OptimizedBusinessScaffold extends ConsumerStatefulWidget {
  const OptimizedBusinessScaffold({
    super.key,
    required this.businessSlug,
    required this.currentRoute,
    required this.child,
  });

  final String businessSlug;
  final String currentRoute;
  final Widget child;

  @override
  ConsumerState<OptimizedBusinessScaffold> createState() =>
      _OptimizedBusinessScaffoldState();
}

class _OptimizedBusinessScaffoldState
    extends ConsumerState<OptimizedBusinessScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transitionController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );
    _transitionController.forward();
  }

  @override
  void didUpdateWidget(OptimizedBusinessScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle route transitions within the same business
    if (oldWidget.businessSlug == widget.businessSlug &&
        oldWidget.currentRoute != widget.currentRoute) {
      debugPrint(
          '🔄 Optimized route transition: ${oldWidget.currentRoute} -> ${widget.currentRoute}');

      // Animate transition
      _transitionController.reset();
      _transitionController.forward();
    }
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(businessNavigationControllerProvider);
    final size = MediaQuery.of(context).size;

    // Show loading if business context is not ready
    if (navigationState == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Create navigation destinations for business
    final businessDestinations =
        _getBusinessNavigationDestinations(widget.businessSlug);

    return Scaffold(
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: widget.child,
                );
              },
            ),
          ),
        ],
      ),

      // Business-specific navigation
      bottomNavigationBar: size.width < 600
          ? _BusinessBottomNavigationBar(
              businessSlug: widget.businessSlug,
              currentRoute: widget.currentRoute,
              destinations: businessDestinations,
            )
          : null,
    );
  }

  List<NavigationDestination> _getBusinessNavigationDestinations(
      String businessSlug) {
    return [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: 'Inicio',
      ),
      NavigationDestination(
        icon: const Icon(Icons.restaurant_menu_outlined),
        selectedIcon: const Icon(Icons.restaurant_menu),
        label: 'Menú',
      ),
      NavigationDestination(
        icon: const CartBadge(icon: Icons.shopping_cart_outlined),
        selectedIcon: const CartBadge(icon: Icons.shopping_cart),
        label: 'Carrito',
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: 'Cuenta',
      ),
      NavigationDestination(
        icon: const Icon(Icons.receipt_long_outlined),
        selectedIcon: const Icon(Icons.receipt_long),
        label: 'Admin',
      ),
    ];
  }
}

/// Business-specific bottom navigation bar
class _BusinessBottomNavigationBar extends ConsumerWidget {
  const _BusinessBottomNavigationBar({
    required this.businessSlug,
    required this.currentRoute,
    required this.destinations,
  });

  final String businessSlug;
  final String currentRoute;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _getCurrentIndex(currentRoute);

    return NavigationBar(
      selectedIndex: currentIndex,
      destinations: destinations,
      onDestinationSelected: (index) {
        _handleNavigation(context, ref, index);
      },
    );
  }

  int _getCurrentIndex(String route) {
    // Map routes to navigation indices
    switch (route) {
      case '/':
        return 0;
      case '/menu':
        return 1;
      case '/carrito': 
        return 2;
      case '/cuenta':
        return 3;
      case '/admin':
        return 4;
      default:
        return 0;
    }
  }

  void _handleNavigation(BuildContext context, WidgetRef ref, int index) {
    final routes = ['/', '/menu', '/carrito', '/cuenta', '/admin'];
    final targetRoute = routes[index];
    final targetPath = '/$businessSlug$targetRoute';

    debugPrint('🧭 Business navigation: $businessSlug -> $targetRoute');

    // Check if we should optimize navigation (same business)
    final shouldOptimize =
        ref.read(shouldOptimizeNavigationProvider(businessSlug, targetRoute));

    if (shouldOptimize) {
      debugPrint('⚡ Optimized navigation within business: $targetRoute');

      // Update navigation state without full page load
      ref
          .read(businessNavigationControllerProvider.notifier)
          .updateRoute(targetRoute);

      // Navigate with smooth transition
      context.go(targetPath);
    } else {
      debugPrint('🌐 Standard navigation to: $targetPath');
      context.go(targetPath);
    }
  }
}

/// Business route transition wrapper
class BusinessRouteTransition extends StatefulWidget {
  const BusinessRouteTransition({
    super.key,
    required this.child,
    required this.routeKey,
  });

  final Widget child;
  final String routeKey;

  @override
  State<BusinessRouteTransition> createState() =>
      _BusinessRouteTransitionState();
}

class _BusinessRouteTransitionState extends State<BusinessRouteTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(BusinessRouteTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeKey != widget.routeKey) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
