import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
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
    this.businessSlug,
  });
  final StatefulNavigationShell? navigationShell;
  final String? businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    // The root scaffold is now extremely simple. It only decides which layout to show.
    return size.width < 600
        ? ScaffoldWithNavigationBar(navigationShell: navigationShell!)
        : ScaffoldWithNavigationRail(navigationShell: navigationShell!);
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
    final allDestinations = ref.watch(allNavigationDestinationsProvider);
    // Filter out admin from shell destinations since it's handled separately
    final shellDestinations =
        allDestinations.where((dest) => dest.path != '/admin').toList();
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

    // Determine the correct selected index by mapping from shell currentIndex to visible destinations
    int selectedIndex = 0;

    // If we're on admin path and admin is visible, select admin
    if (currentPath.startsWith('/admin')) {
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        selectedIndex = adminIndex;
      }
    } else {
      // Find the current destination in destinations based on shell index
      final shellIndex = widget.navigationShell.currentIndex;
      if (shellIndex >= 0 && shellIndex < shellDestinations.length) {
        final currentDest = shellDestinations[shellIndex];
        final visibleIndex =
            destinations.indexWhere((d) => d.path == currentDest.path);
        if (visibleIndex >= 0) {
          selectedIndex = visibleIndex;
        }
      }
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          if (index >= 0 && index < destinations.length) {
            final dest = destinations[index];
            if (dest.path == '/admin') {
              // Admin routes are handled separately from shell branches
              // Use the root context to navigate to admin
              final router = GoRouter.of(context);
              router.go('/admin');
            } else {
              // For default navigation, always use default routes (no business slug)
              debugPrint('🏠 Default navigation to: ${dest.path}');
              context.go(dest.path);
            }
          }
        },
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
    final allDestinations = ref.watch(allNavigationDestinationsProvider);
    // Filter out admin from shell destinations since it's handled separately
    final shellDestinations =
        allDestinations.where((dest) => dest.path != '/admin').toList();
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

    // Determine the correct selected index by mapping from shell currentIndex to visible destinations
    int selectedIndex = 0;

    // If we're on admin path and admin is visible, select admin
    if (currentPath.startsWith('/admin')) {
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        selectedIndex = adminIndex;
      }
    } else {
      // Find the current destination in destinations based on shell index
      final shellIndex = widget.navigationShell.currentIndex;
      if (shellIndex >= 0 && shellIndex < shellDestinations.length) {
        final currentDest = shellDestinations[shellIndex];
        final visibleIndex =
            destinations.indexWhere((d) => d.path == currentDest.path);
        if (visibleIndex >= 0) {
          selectedIndex = visibleIndex;
        }
      }
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              if (index >= 0 && index < destinations.length) {
                final dest = destinations[index];
                if (dest.path == '/admin') {
                  // Admin routes are handled separately from shell branches
                  // Use the root context to navigate to admin
                  final router = GoRouter.of(context);
                  router.go('/admin');
                } else {
                  // For default navigation, always use default routes (no business slug)
                  debugPrint('🏠 Default navigation to: ${dest.path}');
                  context.go(dest.path);
                }
              }
            },
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

// --------------------------------------------------------------------------
// 5. BusinessScaffoldWithNavigation (Business-specific routing)
// --------------------------------------------------------------------------
class BusinessScaffoldWithNavigation extends ConsumerWidget {
  const BusinessScaffoldWithNavigation({
    super.key,
    required this.businessSlug,
    required this.child,
  });

  final String businessSlug;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return size.width < 600
        ? BusinessScaffoldWithNavigationBar(
            businessSlug: businessSlug, child: child)
        : BusinessScaffoldWithNavigationRail(
            businessSlug: businessSlug, child: child);
  }
}

// --------------------------------------------------------------------------
// 6. BusinessScaffoldWithNavigationBar (Mobile View for Business)
// --------------------------------------------------------------------------
class BusinessScaffoldWithNavigationBar extends ConsumerWidget {
  const BusinessScaffoldWithNavigationBar({
    super.key,
    required this.businessSlug,
    required this.child,
  });

  final String businessSlug;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(navigationDestinationsProvider);
    final businessDestinations =
        destinations.where((dest) => dest.path != '/admin').toList();

    // Get current path to determine selected index
    final currentPath =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final selectedIndex = _getBusinessSelectedIndex(currentPath, businessSlug);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: businessDestinations.map((dest) {
          if (dest.path == '/carrito') {
            return NavigationDestination(
              icon: const CartBadge(icon: Icons.shopping_cart_outlined),
              selectedIcon: const CartBadge(icon: Icons.shopping_cart),
              label: dest.label,
            );
          }
          return dest.toNavigationDestination();
        }).toList(),
        onDestinationSelected: (index) {
          final dest = businessDestinations[index];
          // Always navigate within business context, preserving the business slug
          String businessPath;
          if (dest.path == '/') {
            businessPath = '/$businessSlug';
          } else {
            businessPath = '/$businessSlug${dest.path}';
          }
          debugPrint(
              '🏢 Business navigation from /$businessSlug to: $businessPath');
          context.go(businessPath);
        },
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 7. BusinessScaffoldWithNavigationRail (Desktop View for Business)
// --------------------------------------------------------------------------
class BusinessScaffoldWithNavigationRail extends ConsumerWidget {
  const BusinessScaffoldWithNavigationRail({
    super.key,
    required this.businessSlug,
    required this.child,
  });

  final String businessSlug;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(navigationDestinationsProvider);
    final businessDestinations =
        destinations.where((dest) => dest.path != '/admin').toList();

    // Get current path to determine selected index
    final currentPath =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final selectedIndex = _getBusinessSelectedIndex(currentPath, businessSlug);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              final dest = businessDestinations[index];
              // Always navigate within business context, preserving the business slug
              String businessPath;
              if (dest.path == '/') {
                businessPath = '/$businessSlug';
              } else {
                businessPath = '/$businessSlug${dest.path}';
              }
              debugPrint(
                  '🏢 Business navigation from /$businessSlug to: $businessPath');
              context.go(businessPath);
            },
            labelType: NavigationRailLabelType.all,
            destinations: businessDestinations.map((dest) {
              if (dest.path == '/carrito') {
                return const NavigationRailDestination(
                  icon: CartBadge(icon: Icons.shopping_cart_outlined),
                  selectedIcon: CartBadge(icon: Icons.shopping_cart),
                  label: Text('Cart'),
                );
              }
              return NavigationRailDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon),
                label: Text(dest.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Helper functions for business routing
// --------------------------------------------------------------------------
int _getBusinessSelectedIndex(String currentPath, String businessSlug) {
  // Remove business slug prefix to get the route path
  final pathWithoutSlug = currentPath.replaceFirst('/$businessSlug', '');
  final cleanPath = pathWithoutSlug.isEmpty ? '/' : pathWithoutSlug;

  switch (cleanPath) {
    case '/':
      return 0; // Home
    case '/menu':
      return 1; // Menu
    case '/carrito':
      return 2; // Cart
    case '/cuenta':
      return 3; // Account
    default:
      return 0; // Default to home
  }
}
