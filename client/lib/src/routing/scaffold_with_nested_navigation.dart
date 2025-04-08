import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/setup/app_config_services.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/web/web_utils.dart';
import 'package:flutter/foundation.dart';

// Update the provider to include both catering and manual orders
final cateringItemCountProvider = StateProvider<int>((ref) {
  final cateringOrder = ref.watch(cateringOrderProvider);
  final manualQuote = ref.watch(manualQuoteProvider);

  final hasCateringOrder = (cateringOrder?.dishes.length ?? 0) > 0 ? 1 : 0;
  final hasManualQuote = (manualQuote?.dishes.length ?? 0) > 0 ? 1 : 0;

  return hasCateringOrder + hasManualQuote;
});

/// --------------------------------------------------------------------------
/// 1. Computed Provider to Lazily Calculate the Total Cart Quantity
/// --------------------------------------------------------------------------
final totalCartQuantityProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  final mealItems = ref.watch(mealOrderProvider);
  final cateringCount = ref.watch(cateringItemCountProvider);
  final cartTotal =
      cartItems.items.fold(0, (total, item) => total + item.quantity);
  final mealTotal = mealItems.length;
  return cartTotal + mealTotal + cateringCount;
});

/// --------------------------------------------------------------------------
/// 2. A Separate Widget for the Cart Badge to Limit Rebuilds
/// --------------------------------------------------------------------------
class CartBadge extends ConsumerWidget {
  final IconData icon;
  const CartBadge({super.key, required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalQuantity = ref.watch(totalCartQuantityProvider);
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (totalQuantity > 0)
          Positioned(
            top: -7,
            right: -9,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: theme.colorScheme.error,
              child: Text(
                '$totalQuantity',
                style: TextStyle(
                  color: theme.colorScheme.onError,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// --------------------------------------------------------------------------
/// 3. ScaffoldWithNestedNavigation
/// --------------------------------------------------------------------------
class ScaffoldWithNestedNavigation extends ConsumerStatefulWidget {
  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ScaffoldWithNestedNavigation> createState() =>
      _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState
    extends ConsumerState<ScaffoldWithNestedNavigation> {
  bool _navigatedToAdmin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // First, trigger the app startup provider to ensure admin status is checked
      ref.read(appStartupProvider);

      // Check if we're in the admin route and handle accordingly
      _checkCurrentPath();

      // Then update the selectedTabIndex provider for non-admin routes
      ref
          .read(selectedTabIndexProvider.notifier)
          .setIndex(widget.navigationShell.currentIndex);
    });
  }

  void _checkCurrentPath() async {
    // Check if we're in an admin route
    String currentPath = '';

    if (kIsWeb) {
      // For web, directly get the path from the browser URL
      currentPath = WebUtils.getCurrentPath();
    } else {
      // For mobile, get the current location from GoRouter
      try {
        final router = GoRouter.of(context);
        currentPath = router.state.matchedLocation;
      } catch (e) {
        debugPrint('❌ Error getting current path: $e');
      }
    }

    debugPrint('🛣️ Current path check: $currentPath');

    // Check admin status eagerly, regardless of path
    final isAdmin = await ref.read(eagerAdminStatusProvider.future);

    // If we're in admin route, handle it appropriately
    if (currentPath.startsWith('/admin')) {
      debugPrint('🔐 Detected admin path on startup/reload: $currentPath');

      // Set admin status to true if we're in admin path
      if (!ref.read(cachedAdminStatusProvider)) {
        debugPrint('🔄 Setting admin status to true based on path');
        ref.read(cachedAdminStatusProvider.notifier).state = true;
      }

      if (!_navigatedToAdmin) {
        _navigatedToAdmin = true;

        // Find admin destination index
        final destinations = ref.read(navigationDestinationsProvider);
        final adminIndex = destinations.indexWhere((d) => d.path == '/admin');

        if (adminIndex >= 0) {
          // Navigate directly to admin tab
          debugPrint('🧭 Setting admin tab (index: $adminIndex)');

          // Use microtask to avoid rebuild issues
          Future.microtask(() {
            _goBranch(adminIndex);
          });
        }
      }
    } else if (isAdmin) {
      // We're not on an admin path, but user is admin - make sure the option is visible
      debugPrint('👤 User is admin but not on admin path');
      ref.read(cachedAdminStatusProvider.notifier).state = true;
    }
  }

  void _goBranch(int index) {
    // Get the list of destinations
    final destinations = ref.read(navigationDestinationsProvider);

    // Handle direct navigation for admin routes
    if (index < destinations.length && destinations[index].path == '/admin') {
      debugPrint('🔐 Directly navigating to admin panel');
      context.go('/admin');
      return;
    }

    // Update the provider state
    ref.read(selectedTabIndexProvider.notifier).setIndex(index);

    // Use the navigationShell to navigate
    widget.navigationShell.goBranch(
      index,
      // Navigate to initial location if selecting the same tab
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Choose which scaffold to use based on screen size
    return size.width < 450
        ? ScaffoldWithNavigationBar(
            navigationShell: widget.navigationShell,
            currentIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
          )
        : ScaffoldWithNavigationRail(
            navigationShell: widget.navigationShell,
            currentIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
          );
  }
}

/// --------------------------------------------------------------------------
/// 4. ScaffoldWithNavigationBar (ConsumerStatefulWidget)
/// --------------------------------------------------------------------------
class ScaffoldWithNavigationBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavigationBar({
    super.key,
    required this.navigationShell,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  ScaffoldWithNavigationBarState createState() =>
      ScaffoldWithNavigationBarState();
}

class ScaffoldWithNavigationBarState
    extends ConsumerState<ScaffoldWithNavigationBar>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _adminIconController;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();

    // Animation controller for smooth admin icon appearance
    _adminIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Listen to scroll events to hide/show the navigation bar (except for the "Cuenta" tab).
    _scrollController.addListener(() {
      if (widget.currentIndex != 3) {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_isVisible) {
            setState(() {
              _isVisible = false;
            });
          }
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!_isVisible) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
    });

    // Check admin status on first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatusAndRoute();
    });
  }

  void _checkAdminStatusAndRoute() async {
    // Eagerly check admin status
    final isAdmin = await ref.read(eagerAdminStatusProvider.future);

    // Start animation if admin
    if (isAdmin &&
        !_adminIconController.isAnimating &&
        _adminIconController.status != AnimationStatus.completed) {
      _adminIconController.forward();
    }

    // Check if we should navigate to admin
    final currentPath = GoRouterState.of(context).uri.path;
    final isAdminRoute = currentPath.startsWith('/admin');

    // If we're supposed to be in admin route but UI doesn't reflect it yet
    if (isAdmin && isAdminRoute && widget.currentIndex != -1) {
      // Find admin index in destinations
      final destinations = ref.read(navigationDestinationsProvider);
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');

      if (adminIndex >= 0 && widget.currentIndex != adminIndex) {
        // Navigate to admin without rebuilding whole screen
        debugPrint('🔄 Detected admin route, navigating smoothly to admin tab');
        Future.microtask(() {
          widget.onDestinationSelected(adminIndex);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _adminIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(navigationDestinationsProvider);

    // Watch both the cached status and the auth state
    final isAdmin = ref.watch(cachedAdminStatusProvider);
    final authState = ref.watch(authStateChangesProvider);

    // If user is signed out, ensure admin is false and reset animation
    if (authState.value == null && isAdmin) {
      // Use Future.microtask to avoid build-time state changes
      Future.microtask(() {
        ref.read(cachedAdminStatusProvider.notifier).state = false;
        _adminIconController.reset();
      });
    }

    // Get the current route to check if we're on an admin page
    final currentPath = GoRouterState.of(context).uri.path;
    final isAdminRoute = currentPath.startsWith('/admin');

    // If we're on an admin route but admin status is false, update it
    if (isAdminRoute && !isAdmin && authState.value != null) {
      debugPrint('🔄 On admin route but admin status is false, updating...');
      Future.microtask(() {
        ref.read(cachedAdminStatusProvider.notifier).state = true;
        if (!_adminIconController.isAnimating &&
            _adminIconController.status != AnimationStatus.completed) {
          _adminIconController.forward();
        }
      });
    }

    // Check if admin status changed to trigger animation
    if (isAdmin && authState.value != null) {
      if (_adminIconController.status != AnimationStatus.completed &&
          !_adminIconController.isAnimating) {
        Future.microtask(() => _adminIconController.forward());
      }
    }

    // We'll use this to highlight the admin tab if needed
    int selectedIndex = widget.currentIndex;
    if (isAdminRoute) {
      // Find the index of the admin destination if it exists
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        selectedIndex = adminIndex;
      }
    }

    final theme = Theme.of(context);

    // If this is the first build and we're on an admin route, navigate immediately
    if (_isFirstBuild && isAdminRoute && isAdmin) {
      _isFirstBuild = false;
      // Find the admin tab index
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        // Queue navigation after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onDestinationSelected(adminIndex);
        });
      }
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _isVisible ? kBottomNavigationBarHeight + 16 : 0.0,
        child: AnimatedOpacity(
          opacity: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: theme.colorScheme.primary,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  );
                }
                return theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? IconThemeData(color: theme.colorScheme.onPrimary)
                    : IconThemeData(color: theme.colorScheme.onSurface);
              }),
            ),
            // Use AnimatedSize to smoothly resize the navigation bar when items are added/removed
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  // Map regular destinations
                  ...destinations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dest = entry.value;

                    // Special handling for cart icon
                    if (dest.path == '/carrito') {
                      return NavigationDestination(
                        icon:
                            const CartBadge(icon: Icons.shopping_cart_outlined),
                        selectedIcon:
                            const CartBadge(icon: Icons.shopping_cart),
                        label: dest.label,
                      );
                    }

                    return NavigationDestination(
                      icon: Icon(dest.icon),
                      selectedIcon: Icon(dest.selectedIcon),
                      label: dest.label,
                    );
                  }),

                  // Admin destination with smooth animation
                  if (isAdmin && authState.value != null)
                    _buildAdminDestination(isAdminRoute, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build the admin destination with enhanced animation
  NavigationDestination _buildAdminDestination(
      bool isAdminRoute, ThemeData theme) {
    return NavigationDestination(
      icon: FadeTransition(
        opacity: _adminIconController,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _adminIconController,
            curve: Curves.easeOutBack,
          ),
          child: Icon(Icons.admin_panel_settings_outlined,
              color: isAdminRoute ? theme.colorScheme.primary : null),
        ),
      ),
      selectedIcon: FadeTransition(
        opacity: _adminIconController,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _adminIconController,
            curve: Curves.easeOutBack,
          ),
          child: Icon(Icons.admin_panel_settings,
              color: isAdminRoute ? theme.colorScheme.primary : null),
        ),
      ),
      label: 'Admin',
    );
  }
}

/// --------------------------------------------------------------------------
/// 5. ScaffoldWithNavigationRail (ConsumerWidget)
/// --------------------------------------------------------------------------
class ScaffoldWithNavigationRail extends ConsumerStatefulWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.navigationShell,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final StatefulNavigationShell navigationShell;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  ConsumerState<ScaffoldWithNavigationRail> createState() =>
      _ScaffoldWithNavigationRailState();
}

class _ScaffoldWithNavigationRailState
    extends ConsumerState<ScaffoldWithNavigationRail>
    with SingleTickerProviderStateMixin {
  late AnimationController _adminIconController;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();

    // Animation controller for smooth admin icon appearance
    _adminIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Eagerly check admin status for the navigation rail
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatusAndRoute();
    });
  }

  @override
  void dispose() {
    _adminIconController.dispose();
    super.dispose();
  }

  void _checkAdminStatusAndRoute() async {
    // Eagerly check admin status
    final isAdmin = await ref.read(eagerAdminStatusProvider.future);

    // Start animation if admin
    if (isAdmin &&
        !_adminIconController.isAnimating &&
        _adminIconController.status != AnimationStatus.completed) {
      _adminIconController.forward();
    }

    // Check if we should navigate to admin
    final currentPath = GoRouterState.of(context).uri.path;
    final isAdminRoute = currentPath.startsWith('/admin');

    // If we're supposed to be in admin route but UI doesn't reflect it yet
    if (isAdmin && isAdminRoute && widget.currentIndex != -1) {
      // Find admin index in destinations
      final destinations = ref.read(navigationDestinationsProvider);
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');

      if (adminIndex >= 0 && widget.currentIndex != adminIndex) {
        // Navigate to admin without rebuilding whole screen
        debugPrint('🔄 Detected admin route, navigating smoothly to admin tab');
        Future.microtask(() {
          widget.onDestinationSelected(adminIndex);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(navigationDestinationsProvider);

    // Watch both the cached status and the auth state
    final isAdmin = ref.watch(cachedAdminStatusProvider);
    final authState = ref.watch(authStateChangesProvider);

    // If user is signed out, ensure admin is false and reset animation
    if (authState.value == null && isAdmin) {
      // Use Future.microtask to avoid build-time state changes
      Future.microtask(() {
        ref.read(cachedAdminStatusProvider.notifier).state = false;
        _adminIconController.reset();
      });
    }

    // Get the current route to check if we're on an admin page
    final currentPath = GoRouterState.of(context).uri.path;
    final isAdminRoute = currentPath.startsWith('/admin');

    // If we're on an admin route but admin status is false, update it
    if (isAdminRoute && !isAdmin && authState.value != null) {
      debugPrint('🔄 On admin route but admin status is false, updating...');
      Future.microtask(() {
        ref.read(cachedAdminStatusProvider.notifier).state = true;
        if (!_adminIconController.isAnimating &&
            _adminIconController.status != AnimationStatus.completed) {
          _adminIconController.forward();
        }
      });
    }

    // Check if admin status changed to trigger animation
    if (isAdmin && authState.value != null) {
      if (_adminIconController.status != AnimationStatus.completed &&
          !_adminIconController.isAnimating) {
        Future.microtask(() => _adminIconController.forward());
      }
    }

    // We'll use this to highlight the admin tab if needed
    int selectedIndex = widget.currentIndex;
    if (isAdminRoute) {
      // Find the index of the admin destination if it exists
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        selectedIndex = adminIndex;
      }
    }

    // If this is the first build and we're on an admin route, navigate immediately
    if (_isFirstBuild && isAdminRoute && isAdmin) {
      _isFirstBuild = false;
      // Find the admin tab index
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        // Queue navigation after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onDestinationSelected(adminIndex);
        });
      }
    }

    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Use AnimatedContainer to smoothly resize the rail when items are added/removed
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: NavigationRail(
              indicatorColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              selectedIndex: selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme:
                  IconThemeData(color: theme.colorScheme.onPrimary),
              selectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              unselectedIconTheme:
                  IconThemeData(color: theme.colorScheme.onSurface),
              unselectedLabelTextStyle: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              destinations: [
                // Map regular destinations
                ...destinations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final dest = entry.value;

                  // Special handling for cart icon
                  if (dest.path == '/carrito') {
                    return NavigationRailDestination(
                      icon: const CartBadge(icon: Icons.shopping_cart_outlined),
                      selectedIcon: const CartBadge(icon: Icons.shopping_cart),
                      label: Text(dest.label),
                    );
                  }

                  return NavigationRailDestination(
                    icon: Icon(dest.icon),
                    selectedIcon: Icon(dest.selectedIcon),
                    label: Text(dest.label),
                  );
                }),

                // Admin destination with enhanced animation
                if (isAdmin && authState.value != null)
                  _buildAdminRailDestination(isAdminRoute, theme),
              ],
            ),
          ),
          VerticalDivider(thickness: 1, width: 1, color: theme.dividerColor),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }

  // Enhanced admin rail destination with smoother animations
  NavigationRailDestination _buildAdminRailDestination(
      bool isAdminRoute, ThemeData theme) {
    return NavigationRailDestination(
      icon: FadeTransition(
        opacity: _adminIconController,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _adminIconController,
            curve: Curves.easeOutBack,
          ),
          child: Icon(Icons.admin_panel_settings_outlined,
              color: isAdminRoute ? theme.colorScheme.primary : null),
        ),
      ),
      selectedIcon: FadeTransition(
        opacity: _adminIconController,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _adminIconController,
            curve: Curves.easeOutBack,
          ),
          child: Icon(Icons.admin_panel_settings,
              color: isAdminRoute ? theme.colorScheme.primary : null),
        ),
      ),
      label: FadeTransition(
        opacity: _adminIconController,
        child: Text('Admin',
            style: isAdminRoute
                ? TextStyle(color: theme.colorScheme.primary)
                : null),
      ),
    );
  }
}
