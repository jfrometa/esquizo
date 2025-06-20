import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/animated_admin_icon.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';

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
    final currentPath = GoRouterState.of(context).uri.path;
    final isAdmin = ref.watch(isAdminComputedProvider);

    // If on an admin route and user is admin, show dedicated admin navigation
    if (isAdmin && currentPath.startsWith('/admin')) {
      return AdminPanelScreen(child: navigationShell!);
    }

    // The root scaffold is now extremely simple. It only decides which layout to show.
    return size.width < 600
        ? ScaffoldWithNavigationBar(navigationShell: navigationShell!)
        : ScaffoldWithNavigationRail(navigationShell: navigationShell!);
  }
}

// --------------------------------------------------------------------------
// 4. ScaffoldWithNavigationBar (Mobile View) - Optimized
// --------------------------------------------------------------------------
class ScaffoldWithNavigationBar extends ConsumerWidget {
  const ScaffoldWithNavigationBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers to get the current state
    final destinations = ref.watch(navigationDestinationsProvider);
    final currentPath = GoRouterState.of(context).uri.path;

    // Debug print to see what destinations we have
    debugPrint('🏠 ScaffoldWithNavigationBar Build:');
    debugPrint('  📍 Current Path: $currentPath');
    debugPrint(
        '🔍 Navigation destinations: ${destinations.map((d) => '${d.label}(${d.path})').join(', ')}');

    // Simple selected index logic based on current path
    int selectedIndex = 0;
    for (int i = 0; i < destinations.length; i++) {
      final dest = destinations[i];
      if (currentPath == dest.path ||
          (dest.path == '/' && currentPath == '/') ||
          (dest.path != '/' && currentPath.startsWith(dest.path))) {
        selectedIndex = i;
        break;
      }
    }

    // Special handling for admin routes
    if (currentPath.startsWith('/admin')) {
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        selectedIndex = adminIndex;
      }
    }

    debugPrint(
        '🏠 Selected navigation index: $selectedIndex for path: $currentPath');

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (int index) {
          if (index >= 0 && index < destinations.length) {
            final dest = destinations[index];
            debugPrint('🏠 Navigation selected: ${dest.label} (${dest.path})');

            if (dest.path == '/admin') {
              // Admin routes (including payments) are handled through admin panel
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
              icon: AnimatedAdminIcon(
                icon: dest.icon,
                isNavigationRail: false,
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

          // Handle the orders destination
          if (dest.path == '/ordenes') {
            return NavigationDestination(
              icon: Icon(dest.icon),
              selectedIcon: Icon(dest.selectedIcon),
              label: 'Orders',
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
// 5. ScaffoldWithNavigationRail (Desktop View) - Optimized
// --------------------------------------------------------------------------
class ScaffoldWithNavigationRail extends ConsumerWidget {
  const ScaffoldWithNavigationRail({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers to get the current state
    final destinations = ref.watch(navigationDestinationsProvider);
    final currentPath = GoRouterState.of(context).uri.path;

    // Simple selected index logic based on current path
    int selectedIndex = 0;
    for (int i = 0; i < destinations.length; i++) {
      final dest = destinations[i];
      if (currentPath == dest.path ||
          (dest.path == '/' && currentPath == '/') ||
          (dest.path != '/' && currentPath.startsWith(dest.path))) {
        selectedIndex = i;
        break;
      }
    }

    // Special handling for admin routes
    if (currentPath.startsWith('/admin')) {
      final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
      if (adminIndex >= 0) {
        selectedIndex = adminIndex;
      }
    }

    debugPrint(
        '🏠 NavigationRail selected index: $selectedIndex for path: $currentPath');

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              if (index >= 0 && index < destinations.length) {
                final dest = destinations[index];
                debugPrint(
                    '🏠 NavigationRail selected: ${dest.label} (${dest.path})');

                if (dest.path == '/admin') {
                  // Admin routes (including payments) are handled through admin panel
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
                  icon: AnimatedAdminIcon(
                    icon: dest.icon,
                    isNavigationRail: true,
                  ),
                  label: const Text('Admin'),
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

              // Handle the orders destination
              if (dest.path == '/ordenes') {
                return NavigationRailDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: Icon(dest.selectedIcon),
                  label: const Text('Orders'),
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
          Expanded(child: navigationShell),
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
    final isAdmin = ref.watch(isAdminComputedProvider);

    // Include admin destination for business routes if user is admin
    final businessDestinations = destinations.where((dest) {
      if (dest.path == '/admin') {
        return isAdmin; // Only include admin if user is admin
      }
      return true;
    }).toList();

    // Get current path to determine selected index
    final currentPath =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final selectedIndex = _getBusinessSelectedIndex(
        currentPath, businessSlug, businessDestinations);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        destinations: businessDestinations.map((dest) {
          // Handle admin destination for business context
          if (dest.path == '/admin') {
            return NavigationDestination(
              icon: AnimatedAdminIcon(
                icon: dest.icon,
                isNavigationRail: false,
              ),
              label: 'Admin',
            );
          }

          if (dest.path == '/carrito') {
            return NavigationDestination(
              icon: const CartBadge(icon: Icons.shopping_cart_outlined),
              selectedIcon: const CartBadge(icon: Icons.shopping_cart),
              label: 'Cart',
            );
          }

          // Handle the orders destination
          if (dest.path == '/ordenes') {
            return NavigationDestination(
              icon: Icon(dest.icon),
              selectedIcon: Icon(dest.selectedIcon),
              label: 'Orders',
            );
          }

          return dest.toNavigationDestination();
        }).toList(),
        onDestinationSelected: (index) {
          final dest = businessDestinations[index];
          debugPrint(
              '🏢 Business navigation selected: ${dest.label} (${dest.path}) for /$businessSlug');

          // Handle admin navigation for business context (includes payments)
          if (dest.path == '/admin') {
            context.go('/$businessSlug/admin');
            return;
          }

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
    final isAdmin = ref.watch(isAdminComputedProvider);

    // Include admin destination for business routes if user is admin
    final businessDestinations = destinations.where((dest) {
      if (dest.path == '/admin') {
        return isAdmin; // Only include admin if user is admin
      }
      return true;
    }).toList();

    // Get current path to determine selected index
    final currentPath =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final selectedIndex = _getBusinessSelectedIndex(
        currentPath, businessSlug, businessDestinations);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              final dest = businessDestinations[index];

              // Handle admin navigation for business context (includes payments)
              if (dest.path == '/admin') {
                context.go('/$businessSlug/admin');
                return;
              }

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
              // Handle admin destination for business context
              if (dest.path == '/admin') {
                return NavigationRailDestination(
                  icon: AnimatedAdminIcon(
                    icon: dest.icon,
                    isNavigationRail: true,
                  ),
                  label: const Text('Admin'),
                );
              }

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
int _getBusinessSelectedIndex(String currentPath, String businessSlug,
    List<NavigationDestinationItem> destinations) {
  // Remove business slug prefix to get the route path
  final pathWithoutSlug = currentPath.replaceFirst('/$businessSlug', '');
  final cleanPath = pathWithoutSlug.isEmpty ? '/' : pathWithoutSlug;

  debugPrint('🏢 Business path matching: $currentPath -> $cleanPath');

  // Find the index in the visible destinations list
  for (int i = 0; i < destinations.length; i++) {
    final dest = destinations[i];
    if (dest.path == cleanPath) {
      debugPrint('🏢 Found matching destination: ${dest.label} at index $i');
      return i;
    }
  }

  // Special handling for admin routes in business context
  if (cleanPath.startsWith('/admin')) {
    final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
    if (adminIndex >= 0) {
      debugPrint('🏢 Found admin destination at index $adminIndex');
      return adminIndex;
    }
  }

  debugPrint('🏢 No match found, defaulting to home (index 0)');
  // Default to home if no match found
  return 0;
}