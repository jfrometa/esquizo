// Optimized business scaffold for seamless navigation
// Provides persistent navigation state for business routes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';

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
    final isAdmin = ref.watch(isAdminComputedProvider);
    final currentPath = widget.currentRoute;

    // If on a business admin route and user is admin, show dedicated admin navigation
    if (isAdmin &&
        (currentPath == '/admin' ||
            currentPath.startsWith('/admin/') ||
            currentPath.endsWith('/admin'))) {
      // Use the AdminPanelScreen for business context as well
      return AdminPanelScreen(child: widget.child);
    }

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

    // For desktop, use NavigationRail layout similar to BusinessScaffoldWithNavigationRail
    if (size.width >= 600) {
      return Scaffold(
        body: Row(
          children: [
            // Desktop navigation rail
            NavigationRail(
              selectedIndex: _getCurrentIndex(widget.currentRoute),
              onDestinationSelected: (index) {
                _handleNavigation(context, ref, index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: _getBusinessNavigationRailDestinations(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
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
      );
    }

    // For mobile, use bottom navigation bar layout
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

      // Business-specific navigation for mobile
      bottomNavigationBar: _BusinessBottomNavigationBar(
        businessSlug: widget.businessSlug,
        currentRoute: widget.currentRoute,
        destinations: businessDestinations,
        onDestinationSelected: _handleNavigation,
        getCurrentIndex: _getCurrentIndex,
      ),
    );
  }

  int _getCurrentIndex(String route) {
    // Map routes to navigation indices
    // Must match the order in _getBusinessNavigationDestinations
    final isAdmin = ref.watch(isAdminComputedProvider);

    switch (route) {
      case '/':
        return 0;
      case '/menu':
        return 1;
      case '/carrito':
        return 2;
      case '/ordenes':
        return 3;
      case '/admin':
        return isAdmin ? 4 : 0; // Admin is index 4 if present
      case '/cuenta':
        return isAdmin ? 5 : 4; // Cuenta is last
      default:
        return 0;
    }
  }

  void _handleNavigation(BuildContext context, WidgetRef ref, int index) {
    final isAdmin = ref.watch(isAdminComputedProvider);

    // Determine the target route based on index and admin status
    String targetRoute;
    if (isAdmin) {
      final routes = [
        '/',
        '/menu',
        '/carrito',
        '/ordenes',
        '/admin',
        '/cuenta'
      ];
      targetRoute = routes[index];
    } else {
      final routes = ['/', '/menu', '/carrito', '/ordenes', '/cuenta'];
      targetRoute = routes[index];
    }
    final targetPath = targetRoute == '/'
        ? '/${widget.businessSlug}'
        : '/${widget.businessSlug}$targetRoute';

    debugPrint(
        '🧭 Business navigation: ${widget.businessSlug} -> $targetRoute');

    // Check if we should optimize navigation (same business)
    final shouldOptimize = ref.read(
        shouldOptimizeNavigationProvider(widget.businessSlug, targetRoute));

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

  List<NavigationRailDestination> _getBusinessNavigationRailDestinations() {
    return [
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Inicio'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.restaurant_menu_outlined),
        selectedIcon: Icon(Icons.restaurant_menu),
        label: Text('Menú'),
      ),
      const NavigationRailDestination(
        icon: CartBadge(icon: Icons.shopping_cart_outlined),
        selectedIcon: CartBadge(icon: Icons.shopping_cart),
        label: Text('Carrito'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Cuenta'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: Text('Ordenes'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: Text('Admin'),
      ),
    ];
  }

  List<NavigationDestination> _getBusinessNavigationDestinations(
      String businessSlug) {
    // Get admin status to determine if admin destination should be included
    final adminStatusAsync = ref.watch(isAdminProvider);
    final isAdmin = adminStatusAsync.valueOrNull ?? false;

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Inicio',
      ),
      const NavigationDestination(
        icon: Icon(Icons.restaurant_menu_outlined),
        selectedIcon: Icon(Icons.restaurant_menu),
        label: 'Menú',
      ),
      const NavigationDestination(
        icon: CartBadge(icon: Icons.shopping_cart_outlined),
        selectedIcon: CartBadge(icon: Icons.shopping_cart),
        label: 'Carrito',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'Ordenes',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Cuenta',
      ),
    ];

    // Add admin destination if user is admin (between orders and account)
    if (isAdmin) {
      destinations.insert(
          4,
          const NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ));
    }

    return destinations;
  }
}

/// Business-specific bottom navigation bar
class _BusinessBottomNavigationBar extends ConsumerWidget {
  const _BusinessBottomNavigationBar({
    required this.businessSlug,
    required this.currentRoute,
    required this.destinations,
    required this.onDestinationSelected,
    required this.getCurrentIndex,
  });

  final String businessSlug;
  final String currentRoute;
  final List<NavigationDestination> destinations;
  final Function(BuildContext, WidgetRef, int) onDestinationSelected;
  final Function(String) getCurrentIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = getCurrentIndex(currentRoute);

    return NavigationBar(
      selectedIndex: currentIndex,
      destinations: destinations,
      onDestinationSelected: (index) {
        onDestinationSelected(context, ref, index);
      },
    );
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
