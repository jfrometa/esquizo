import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_cart.dart';

// --- Cart and Badge Providers (Unchanged) ---
final cateringItemCountProvider = StateProvider<int>((ref) {
  final cateringOrder = ref.watch(cateringOrderProvider);
  final manualQuote = ref.watch(manualQuoteProvider);
  final hasCateringOrder = (cateringOrder?.dishes.length ?? 0) > 0 ? 1 : 0;
  final hasManualQuote = (manualQuote?.dishes.length ?? 0) > 0 ? 1 : 0;
  return hasCateringOrder + hasManualQuote;
});

final totalCartQuantityProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  final mealItems = ref.watch(mealOrderProvider);
  final cateringCount = ref.watch(cateringItemCountProvider);
  final cartTotal =
      cartItems.items.fold(0, (total, item) => total + item.quantity);
  final mealTotal = mealItems.length;
  return cartTotal + mealTotal + cateringCount;
});

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

// --------------------------------------------------------------------------
// 3. Main Scaffold - Simplified to a stateless ConsumerWidget
// --------------------------------------------------------------------------
class ScaffoldWithNestedNavigation extends ConsumerWidget {
  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    // The root scaffold is now extremely simple. It only decides which layout to show.
    return size.width < 600
        ? ScaffoldWithNavigationBar(navigationShell: navigationShell)
        : ScaffoldWithNavigationRail(navigationShell: navigationShell);
  }
}

// --------------------------------------------------------------------------
// 4. ScaffoldWithNavigationBar (Mobile View)
// --------------------------------------------------------------------------
class ScaffoldWithNavigationBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavigationBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ScaffoldWithNavigationBarState createState() =>
      ScaffoldWithNavigationBarState();
}

class ScaffoldWithNavigationBarState
    extends ConsumerState<ScaffoldWithNavigationBar>
    with TickerProviderStateMixin {
  late final AnimationController _adminIconController;

  @override
  void initState() {
    super.initState();
    _adminIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _adminIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the providers to get the current state
    final destinations = ref.watch(navigationDestinationsProvider);
    final adminStatusAsync = ref.watch(isAdminProvider);
    final currentPath = GoRouterState.of(context).uri.path;

    // Get admin status from async provider, defaulting to false
    final isAdmin = adminStatusAsync.valueOrNull ?? false;

    // Drive the animation based on the admin status
    if (isAdmin) {
      _adminIconController.forward();
    } else {
      _adminIconController.reverse();
    }

    // Determine the correct selected index
    int selectedIndex = widget.navigationShell.currentIndex;
    final adminDestination = destinations.firstWhere(
      (d) => d.path == '/admin',
      orElse: () =>
          destinations.first, // Should not happen if provider is correct
    );
    if (currentPath.startsWith('/admin')) {
      selectedIndex = destinations.indexOf(adminDestination);
    }

    void onDestinationSelected(int index) {
      if (index >= 0 && index < destinations.length) {
        final dest = destinations[index];
        if (dest.path == '/admin') {
          context.go('/admin');
        } else {
          widget.navigationShell.goBranch(index);
        }
      }
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((dest) {
          // Handle the admin destination specifically to wrap it in animations
          if (dest.path == '/admin') {
            return NavigationDestination(
              icon: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: SizedBox(
                  width: isAdmin ? null : 0, // Collapses when not admin
                  child: FadeTransition(
                    opacity: _adminIconController,
                    child: Icon(dest.icon),
                  ),
                ),
              ),
              label: 'Admin',
            );
          }

          // Handle the cart badge
          if (dest.path == '/carrito') {
            return const NavigationDestination(
              icon: CartBadge(icon: Icons.shopping_cart_outlined),
              selectedIcon: CartBadge(icon: Icons.shopping_cart),
              label: 'Cart',
            );
          }

          // Return regular destinations
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: Icon(dest.selectedIcon),
            label: dest.label,
          );
        }).toList(),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 5. ScaffoldWithNavigationRail (Desktop View)
// --------------------------------------------------------------------------
class ScaffoldWithNavigationRail extends ConsumerStatefulWidget {
  const ScaffoldWithNavigationRail({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  _ScaffoldWithNavigationRailState createState() =>
      _ScaffoldWithNavigationRailState();
}

class _ScaffoldWithNavigationRailState
    extends ConsumerState<ScaffoldWithNavigationRail>
    with TickerProviderStateMixin {
  late final AnimationController _adminIconController;

  @override
  void initState() {
    super.initState();
    _adminIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _adminIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers to get the current state
    final destinations = ref.watch(navigationDestinationsProvider);
    final adminStatusAsync = ref.watch(isAdminProvider);
    final currentPath = GoRouterState.of(context).uri.path;

    // Get admin status from async provider, defaulting to false
    final isAdmin = adminStatusAsync.valueOrNull ?? false;

    // Drive the animation
    if (isAdmin) {
      _adminIconController.forward();
    } else {
      _adminIconController.reverse();
    }

    // Determine the correct selected index
    int selectedIndex = widget.navigationShell.currentIndex;
    final adminDestination = destinations.firstWhere(
      (d) => d.path == '/admin',
      orElse: () => destinations.first,
    );
    if (currentPath.startsWith('/admin')) {
      selectedIndex = destinations.indexOf(adminDestination);
    }

    void onDestinationSelected(int index) {
      if (index >= 0 && index < destinations.length) {
        final dest = destinations[index];
        if (dest.path == '/admin') {
          context.go('/admin');
        } else {
          widget.navigationShell.goBranch(index);
        }
      }
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: destinations.map((dest) {
              // Handle the admin destination specifically for animation
              if (dest.path == '/admin') {
                return NavigationRailDestination(
                  icon: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: isAdmin ? 56 : 0, // Fixed width for rail icon area
                      child: FadeTransition(
                        opacity: _adminIconController,
                        child: Icon(dest.icon),
                      ),
                    ),
                  ),
                  label: FadeTransition(
                    opacity: _adminIconController,
                    child: Text(dest.label),
                  ),
                );
              }

              // Handle the cart badge
              if (dest.path == '/carrito') {
                return const NavigationRailDestination(
                  icon: CartBadge(icon: Icons.shopping_cart_outlined),
                  selectedIcon: CartBadge(icon: Icons.shopping_cart),
                  label: Text('Cart'),
                );
              }

              // Return regular destinations
              return NavigationRailDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon),
                label: Text(dest.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }
}
