import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';

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
class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width < 450
        ? ScaffoldWithNavigationBar(
            body: navigationShell,
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
          )
        : ScaffoldWithNavigationRail(
            body: navigationShell,
            currentIndex: navigationShell.currentIndex,
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
    required this.body,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  ScaffoldWithNavigationBarState createState() =>
      ScaffoldWithNavigationBarState();
}

class ScaffoldWithNavigationBarState
    extends ConsumerState<ScaffoldWithNavigationBar> {
  bool _isVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

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
  }

  void _goBranch(int index) {
    setState(() {
      // Ensure the navigation bar is visible on tab "Cuenta" (assumed index 3)
      _isVisible = index == 3 ? true : _isVisible;
    });
    widget.onDestinationSelected(index);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(navigationDestinationsProvider);
    final totalQuantity = ref.watch(totalCartQuantityProvider);

    // Watch both the cached status and the auth state
    final isAdmin = ref.watch(cachedAdminStatusProvider);
    final authState = ref.watch(authStateChangesProvider);

    // If user is null (signed out), ensure admin is false
    if (authState.value == null && isAdmin) {
      // Use Future.microtask to avoid build-time state changes
      Future.microtask(() {
        ref.read(cachedAdminStatusProvider.notifier).state = false;
      });
    }

    final theme = Theme.of(context);

    return Scaffold(
      body: widget.body,
      bottomNavigationBar: NavigationBarTheme(
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
            selectedIndex: widget.currentIndex,
            onDestinationSelected: _goBranch,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              // Map regular destinations
              ...destinations.map((dest) => _buildDestination(
                  dest, totalQuantity, destinations.indexOf(dest))),

              // Admin destination with animation
              if (isAdmin && authState.value != null) _buildAdminDestination(),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _buildDestination(
    NavigationDestinationItem destination,
    int totalQuantity,
    int index,
  ) {
    Widget iconWidget;
    if (destination.icon == Icons.shopping_cart) {
      // Use CartBadge for the shopping cart.
      iconWidget = const CartBadge(icon: Icons.shopping_cart);
    } else {
      iconWidget = Icon(destination.icon);
    }
    return NavigationDestination(
      icon: iconWidget,
      label: destination.label,
    );
  }

  // New method to build the admin destination
  NavigationDestination _buildAdminDestination() {
    return NavigationDestination(
      icon: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: const Icon(Icons.admin_panel_settings),
          );
        },
      ),
      label: 'Admin',
    );
  }
}

/// --------------------------------------------------------------------------
/// 5. ScaffoldWithNavigationRail (ConsumerWidget)
/// --------------------------------------------------------------------------
class ScaffoldWithNavigationRail extends ConsumerWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(navigationDestinationsProvider);
    final totalQuantity = ref.watch(totalCartQuantityProvider);

    // Watch both the cached status and the auth state
    final isAdmin = ref.watch(cachedAdminStatusProvider);
    final authState = ref.watch(authStateChangesProvider);

    // If user is null (signed out), ensure admin is false
    if (authState.value == null && isAdmin) {
      // Use Future.microtask to avoid build-time state changes
      Future.microtask(() {
        ref.read(cachedAdminStatusProvider.notifier).state = false;
      });
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
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
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
                ...destinations.map((dest) => _buildRailDestination(
                    dest, totalQuantity, destinations.indexOf(dest))),

                // Admin destination with animation
                if (isAdmin && authState.value != null)
                  _buildAdminRailDestination(),
              ],
            ),
          ),
          VerticalDivider(thickness: 1, width: 1, color: theme.dividerColor),
          Expanded(child: body),
        ],
      ),
    );
  }

  NavigationRailDestination _buildRailDestination(
    NavigationDestinationItem destination,
    int totalQuantity,
    int index,
  ) {
    Widget iconWidget;
    if (destination.icon == Icons.shopping_cart) {
      iconWidget = const CartBadge(icon: Icons.shopping_cart);
    } else {
      iconWidget = Icon(destination.icon);
    }
    return NavigationRailDestination(
      icon: iconWidget,
      label: Text(destination.label),
    );
  }

  // New method to build the admin rail destination
  NavigationRailDestination _buildAdminRailDestination() {
    return NavigationRailDestination(
      icon: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: const Icon(Icons.admin_panel_settings),
          );
        },
      ),
      label: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: const Text('Admin'),
          );
        },
      ),
    );
  }
}
