// Optimized business scaffold for seamless navigation
// Provides persistent navigation state for business routes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

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

    // Use authStateChangesProvider to track authentication status
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final isAuthenticated = user != null && !user.isAnonymous;

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

    // Define navigation items dynamically
    final items = _getNavigationItems(isAdmin, isAuthenticated);
    final currentIndex = _getSelectedIndex(items, widget.currentRoute);

    // Create navigation destinations for business
    final businessDestinations = items.map((item) {
      return NavigationDestination(
        icon: item.iconWidget ?? Icon(item.icon),
        selectedIcon: item.selectedIconWidget ?? Icon(item.selectedIcon),
        label: item.label,
      );
    }).toList();

    final appBar = AppBar(
      title: Consumer(
        builder: (context, ref, _) {
          final businessName = ref.watch(businessNameProvider);
          return Text(
            businessName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        },
      ),
      centerTitle: false,
      actions: [
        _ProfileAppBarButton(businessSlug: widget.businessSlug),
        const SizedBox(width: 8),
      ],
    );

    // For desktop, use NavigationRail layout
    if (size.width >= 600) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            // Desktop navigation rail
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                _handleNavigation(context, ref, items[index].route);
              },
              labelType: NavigationRailLabelType.all,
              destinations: items.map((item) {
                return NavigationRailDestination(
                  icon: item.iconWidget ?? Icon(item.icon),
                  selectedIcon:
                      item.selectedIconWidget ?? Icon(item.selectedIcon),
                  label: Text(item.label),
                );
              }).toList(),
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
      appBar: appBar,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: widget.child,
          );
        },
      ),

      // Business-specific navigation for mobile
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        destinations: businessDestinations,
        onDestinationSelected: (index) {
          _handleNavigation(context, ref, items[index].route);
        },
      ),
    );
  }

  List<_NavigationItem> _getNavigationItems(
      bool isAdmin, bool isAuthenticated) {
    final List<_NavigationItem> items = [
      const _NavigationItem(
        route: '/',
        label: 'Inicio',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      const _NavigationItem(
        route: '/menu',
        label: 'Menú',
        icon: Icons.restaurant_menu_outlined,
        selectedIcon: Icons.restaurant_menu,
      ),
      const _NavigationItem(
        route: '/carrito',
        label: 'Carrito',
        icon: Icons.shopping_cart_outlined,
        selectedIcon: Icons.shopping_cart,
        iconWidget: CartBadge(icon: Icons.shopping_cart_outlined),
        selectedIconWidget: CartBadge(icon: Icons.shopping_cart),
      ),
    ];

    // Conditionally show Orders
    if (isAuthenticated) {
      items.add(const _NavigationItem(
        route: '/ordenes',
        label: 'Ordenes',
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
      ));
    }

    // Conditionally show Admin
    if (isAdmin) {
      items.add(const _NavigationItem(
        route: '/admin',
        label: 'Admin',
        icon: Icons.admin_panel_settings_outlined,
        selectedIcon: Icons.admin_panel_settings,
      ));
    }

    return items;
  }

  int _getSelectedIndex(List<_NavigationItem> items, String currentRoute) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].route == currentRoute) {
        return i;
      }
    }
    return 0;
  }

  void _handleNavigation(
      BuildContext context, WidgetRef ref, String targetRoute) {
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

/// Navigation item helper
class _NavigationItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget? iconWidget;
  final Widget? selectedIconWidget;

  const _NavigationItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.iconWidget,
    this.selectedIconWidget,
  });
}

/// Profile button for the AppBar
class _ProfileAppBarButton extends ConsumerWidget {
  const _ProfileAppBarButton({required this.businessSlug});

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final isAuthenticated = user != null && !user.isAnonymous;

    return IconButton(
      icon: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(4),
        child: Icon(
          isAuthenticated ? Icons.person : Icons.person_outline,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      onPressed: () {
        context.goNamedSafe(AppRoute.profile.name);
      },
      tooltip: isAuthenticated ? 'Perfil' : 'Iniciar sesión',
    );
  }
}
