// Optimized business screen wrappers with seamless navigation
// Uses the new business navigation system for better performance

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/optimized_business_scaffold_v2.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/screens_mesa_redonda/home/home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/menu_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/cart_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/custom_profile_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/orders/in_progress_orders_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_dashboard_home.dart';

/// Optimized business context wrapper with caching and navigation optimization
class OptimizedBusinessWrapper extends ConsumerWidget {
  const OptimizedBusinessWrapper({
    super.key,
    required this.businessSlug,
    required this.route,
    required this.child,
  });

  final String businessSlug;
  final String route;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use cached business context to avoid re-fetching
    final cachedContext =
        ref.watch(cachedBusinessContextProvider(businessSlug));

    // Initialize business navigation if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(businessNavigationControllerProvider.notifier)
          .setBusinessNavigation(businessSlug, route);
    });

    // If we have cached context, use it immediately
    if (cachedContext != null) {
      final fullPath = route == '/' ? '/$businessSlug' : '/$businessSlug$route';
      debugPrint('⚡ Using cached context for $fullPath');
      return OptimizedBusinessScaffold(
        businessSlug: businessSlug,
        currentRoute: route,
        child: BusinessRouteTransition(
          routeKey: '$businessSlug$route',
          child: child,
        ),
      );
    }

    // Otherwise fetch context
    return FutureBuilder(
      future: ref
          .read(cachedBusinessContextProvider(businessSlug).notifier)
          .getBusinessContext(businessSlug),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('❌ Error loading business context: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error cargando: $businessSlug'),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(cachedBusinessContextProvider(businessSlug)
                              .notifier)
                          .clearCache(businessSlug);
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        return OptimizedBusinessScaffold(
          businessSlug: businessSlug,
          currentRoute: route,
          child: BusinessRouteTransition(
            routeKey: '$businessSlug$route',
            child: child,
          ),
        );
      },
    );
  }
}

/// Optimized wrapper for business home screen
class OptimizedHomeScreenWrapper extends ConsumerWidget {
  const OptimizedHomeScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🏠 Optimized home screen for: $businessSlug');

    return OptimizedBusinessWrapper(
      businessSlug: businessSlug,
      route: '/', // Just the root path within the business context
      child: const MenuHome(),
    );
  }
}

/// Optimized wrapper for business menu screen
class OptimizedMenuScreenWrapper extends ConsumerWidget {
  const OptimizedMenuScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🍽️ Optimized menu screen for: $businessSlug');

    return OptimizedBusinessWrapper(
      businessSlug: businessSlug,
      route: '/menu', // Just the menu path within the business context
      child: const MenuScreen(),
    );
  }
}

/// Optimized wrapper for business cart screen
class OptimizedCartScreenWrapper extends ConsumerWidget {
  const OptimizedCartScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🛒 Optimized cart screen for: $businessSlug');

    return OptimizedBusinessWrapper(
      businessSlug: businessSlug,
      route: '/carrito', // Just the cart path within the business context
      child: const CartScreen(isAuthenticated: true),
    );
  }
}

/// Optimized wrapper for business profile screen
class OptimizedProfileScreenWrapper extends ConsumerWidget {
  const OptimizedProfileScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('👤 Optimized profile screen for: $businessSlug');

    return OptimizedBusinessWrapper(
      businessSlug: businessSlug,
      route: '/cuenta', // Just the profile path within the business context
      child: const CustomProfileScreen(),
    );
  }
}

/// Optimized wrapper for business orders screen
class OptimizedOrdersScreenWrapper extends ConsumerWidget {
  const OptimizedOrdersScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('📋 Optimized orders screen for: $businessSlug');

    return OptimizedBusinessWrapper(
      businessSlug: businessSlug,
      route: '/ordenes', // Just the orders path within the business context
      child: const InProgressOrdersScreen(),
    );
  }
}

/// Optimized wrapper for business admin screen
class OptimizedAdminScreenWrapper extends ConsumerWidget {
  const OptimizedAdminScreenWrapper({
    super.key,
    required this.businessSlug,
  });

  final String businessSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🔧 Optimized admin screen for: $businessSlug');

    return OptimizedBusinessWrapper(
      businessSlug: businessSlug,
      route: '/admin', // Just the admin path within the business context
      child:
          const AdminDashboardHome(), // Use dashboard home for business admin
    );
  }
}

/// Business navigation helper for seamless transitions
class BusinessNavigationHelper {
  static void navigateToBusinessRoute(
    BuildContext context,
    WidgetRef ref,
    String? businessSlug,
    String route,
  ) {
    // Determine the correct path based on whether we have a business slug
    String targetPath;

    if (businessSlug != null && businessSlug.isNotEmpty) {
      // Business-specific routing: /$businessSlug, /$businessSlug/menu, etc.
      targetPath = route == '/' ? '/$businessSlug' : '/$businessSlug$route';
      debugPrint('🏢 Navigating to business-specific route: $targetPath');
    } else {
      // Default routing: /, /menu, /carrito, /admin, etc.
      targetPath = route;
      debugPrint('🏠 Navigating to default route: $targetPath');
    }

    final currentNavigation = ref.read(currentBusinessNavigationProvider);

    // Check if we should optimize navigation for business-specific routes
    if (businessSlug != null &&
        businessSlug.isNotEmpty &&
        currentNavigation?.businessSlug == businessSlug) {
      debugPrint('⚡ Optimized business navigation: $businessSlug$route');

      // Update navigation state first
      ref
          .read(businessNavigationControllerProvider.notifier)
          .updateRoute(route);

      // Then navigate
      context.go(targetPath);
    } else {
      debugPrint('🌐 Standard navigation: $targetPath');
      context.go(targetPath);
    }
  }

  /// Navigate to business home
  static void navigateToHome(
      BuildContext context, WidgetRef ref, String? businessSlug) {
    navigateToBusinessRoute(context, ref, businessSlug, '/');
  }

  /// Navigate to business menu
  static void navigateToMenu(
      BuildContext context, WidgetRef ref, String? businessSlug) {
    navigateToBusinessRoute(context, ref, businessSlug, '/menu');
  }

  /// Navigate to business cart
  static void navigateToCart(
      BuildContext context, WidgetRef ref, String? businessSlug) {
    navigateToBusinessRoute(context, ref, businessSlug, '/carrito');
  }

  /// Navigate to business profile
  static void navigateToProfile(
      BuildContext context, WidgetRef ref, String? businessSlug) {
    navigateToBusinessRoute(context, ref, businessSlug, '/cuenta');
  }

  /// Navigate to business orders
  static void navigateToOrders(
      BuildContext context, WidgetRef ref, String? businessSlug) {
    navigateToBusinessRoute(context, ref, businessSlug, '/ordenes');
  }

  /// Navigate to business admin
  static void navigateToAdmin(
      BuildContext context, WidgetRef ref, String? businessSlug) {
    navigateToBusinessRoute(context, ref, businessSlug, '/admin');
  }

  // Default routing helpers (no business slug)

  /// Navigate to default home
  static void navigateToDefaultHome(BuildContext context, WidgetRef ref) {
    navigateToBusinessRoute(context, ref, null, '/');
  }

  /// Navigate to default menu
  static void navigateToDefaultMenu(BuildContext context, WidgetRef ref) {
    navigateToBusinessRoute(context, ref, null, '/menu');
  }

  /// Navigate to default cart
  static void navigateToDefaultCart(BuildContext context, WidgetRef ref) {
    navigateToBusinessRoute(context, ref, null, '/carrito');
  }

  /// Navigate to default profile
  static void navigateToDefaultProfile(BuildContext context, WidgetRef ref) {
    navigateToBusinessRoute(context, ref, null, '/cuenta');
  }

  /// Navigate to default orders
  static void navigateToDefaultOrders(BuildContext context, WidgetRef ref) {
    navigateToBusinessRoute(context, ref, null, '/ordenes');
  }

  /// Navigate to default admin
  static void navigateToDefaultAdmin(BuildContext context, WidgetRef ref) {
    navigateToBusinessRoute(context, ref, null, '/admin');
  }
}
