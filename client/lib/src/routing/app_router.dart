import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/app_config/app_config_services.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';

import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/extensions/firebase_analitics.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_startup.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/optimized_business_wrappers.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/go_router_refresh_stream.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_dashboard_home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_setup_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_set_comple_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_setup_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_settings_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/meal_plan_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/product_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/order_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/customer_meal_plan_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/all_dishes_menu_home/all_dishes_menu_home_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/authenticated_profile_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/custom_profile_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/custom_sign_in_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/cart_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_selection_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/screens/catering_menu/catering_menu_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/catering_entry_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_quote/manual_quote_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/checkout_creen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/dish_details/dish_details_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/landing-page-home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_details.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/menu_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/onboarding/presentation/onboarding_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/orders/in_progress_orders_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/screens_mesa_redonda/categories.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/screens_mesa_redonda/home/home.dart';

import 'package:starter_architecture_flutter_firebase/src/utils/web/web_utils.dart';
import 'package:go_router/go_router.dart';

part 'app_router.g.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');
final _landingNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'landing');
final _cartNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cart');
final _adminNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'admin');
final _ordersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'local');

// Store paths that were attempted before authentication
final _pendingAdminPathProvider = StateProvider<String?>((ref) => null);
// Error state for router
final routerErrorNotifierProvider = StateProvider<String?>((ref) => null);

// Debug navigator observer
class _DebugNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('🚢 Navigation: PUSH to ${route.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('🚢 Navigation: POP from ${route.settings.name}');
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint(
        '🚢 Navigation: REPLACE ${oldRoute?.settings.name} → ${newRoute?.settings.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

enum AppRoute {
  authenticatedProfile,
  onboarding,
  signIn,
  profile,
  allDishes,
  category,
  details,
  addToOrder,
  addDishToOrder,
  homecart,
  checkout,
  planDetails,
  home,
  mealPlans,
  mealPlan,
  catering,
  cateringMenu,
  caterings,
  cateringMenuE,
  cateringQuote,
  landing,
  local,
  adminPanel,
  adminSetup,
  inProgressOrders,
  manualQuote,
  // Business setup routes
  businessSetup,
  businessSetupComplete,
  // Catering management routes
  cateringManagement,
  cateringDashboard,
  cateringOrders,
  cateringOrderDetails,
  cateringPackages,
  cateringItems,
  cateringCategories,
  // Meal plan management routes
  mealPlanManagement,
  mealPlanAdminSection,
  mealPlanItems,
  mealPlanAnalytics,
  mealPlanExport,
  mealPlanQrCode,
  mealPlanScanner,
  mealPlanPos,
  customerMealPlan,
  mealPlanDetails
}

@riverpod
GoRouter goRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  // Use allNavigationDestinations for consistent shell branches
  final allDestinations = ref.watch(allNavigationDestinationsProvider);
  // final isFirebaseInitialized = ref.watch(isFirebaseInitializedProvider);
  final isAdminAsync = ref.watch(isAdminProvider);
 final businessSlug = ref.watch(currentBusinessSlugProvider);
  // Force admin status check if user is logged in but admin status hasn't been determined
  if (authRepository.currentUser != null && isAdminAsync.hasValue == false) {
    ref.invalidate(isAdminProvider);
  }

  // *** DIRECTLY USE WEB UTILS TO GET THE INITIAL LOCATION FROM BROWSER URL ***
  String initialLocation = '/';
  if (kIsWeb) {
    initialLocation = WebUtils.getCurrentPath();
    debugPrint('📍 Direct initial location: $initialLocation');

    // Store admin path if detected
    if (initialLocation.startsWith('/admin') && initialLocation != '/admin') {
      debugPrint('📍 Storing admin path: $initialLocation');
      ref.read(_pendingAdminPathProvider.notifier).state = initialLocation;
    }
  }

  return GoRouter(
    initialLocation: initialLocation,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    redirect: (context, state) async {
      final path = state.uri.path;

      // Handle business slug prefixing
      if (businessSlug != null && businessSlug.isNotEmpty) {
        if (path == '/') {
          // Redirect root to business root
          return '/$businessSlug';
        } else if (!path.startsWith('/$businessSlug')) {
          // Prefix slug to all routes
          return '/$businessSlug${path.startsWith('/') ? path : '/$path'}';
        }
      }

      // Synchronize browser URL with router state
      if (kIsWeb) {
        final browserPath = WebUtils.getCurrentPath();
        if (browserPath != path) {
          debugPrint('⚠️ Browser URL mismatch detected: $browserPath vs $path');
          return browserPath.startsWith('/$businessSlug') ? browserPath : '/$businessSlug$browserPath';
        }
      }

      // Allow all navigation without restrictions
      return null;
    },
    observers: [
      // Custom navigation observer for debugging
      _DebugNavigatorObserver(),
      // Firebase Analytics Observer
      FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
        nameExtractor: (RouteSettings settings) {
          final String? name = settings.name;
          debugPrint('📊 Analytics Observer: Route changed to: $name');
          if (name != null && name.isNotEmpty) {
            AnalyticsService.instance.logCustomEvent(
              eventName: 'screen_view',
              parameters: {
                'screen_name': name,
                'screen_class':
                    settings.arguments?.runtimeType.toString() ?? 'unknown',
              },
            );
          }
          return name;
        },
        onError: (Object error) {
          debugPrint('Analytics navigation observer error: $error');
          return true;
        },
      ),
    ],
    // Use only errorBuilder, not errorPageBuilder or onException
    errorBuilder: (context, state) {
      final errorMsg = state.error?.toString() ?? 'Unknown error';
      debugPrint("🔥 Router error: $errorMsg");
      return UnauthorizedScreen();
    },
    routes: [
      // Business Setup Routes
      GoRoute(
        path: '/business-setup',
        name: AppRoute.businessSetup.name,
        builder: (context, state) => const BusinessSetupScreen(),
      ),
      GoRoute(
        path: '/business-setup/complete/:businessId',
        name: AppRoute.businessSetupComplete.name,
        builder: (context, state) {
          final businessId = state.pathParameters['businessId'] ?? '';
          return BusinessSetupCompleteScreen(businessId: businessId);
        },
      ),

      GoRoute(
        path: '/startup',
        pageBuilder: (context, state) => NoTransitionPage(
          child: AppStartupWidget(
            onLoaded: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
      GoRoute(
        path: '/error',
        pageBuilder: (context, state) => NoTransitionPage(
          child: UnauthorizedScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/signin',
        name: AppRoute.signIn.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CustomSignInScreen(),
        ),
      ),
      // Admin setup route
      GoRoute(
        path: '/admin-setup',
        name: AppRoute.adminSetup.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminSetupScreen(),
        ),
      ),

      // Add all admin routes here BEFORE business routing to prevent conflicts
      // This ensures /admin is matched before /:businessSlug pattern
      ...getAdminRoutes(),

      // StatefulShellRoute for default business navigation (no slug prefix)
      // This comes FIRST to handle default routes like /menu, /carrito, /cuenta
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) => NoTransitionPage(
          child: ScaffoldWithNestedNavigation(navigationShell: navigationShell),
        ),
        branches: allDestinations
            .where((dest) =>
                dest.path != '/admin') // Exclude admin from shell branches
            .map((dest) => _buildBranch(dest))
            .toList(),
      ),

      // Optimized Business-specific routing with seamless navigation
      // This comes AFTER StatefulShellRoute to catch remaining paths as potential business slugs
      GoRoute(
        path: '/:businessSlug',
        redirect: (context, state) {
          final businessSlug = state.pathParameters['businessSlug'];
          debugPrint('🔍 Checking business slug: $businessSlug');

          if (businessSlug != null && _isValidBusinessSlug(businessSlug)) {
            // Valid business slug format - allow business routing
            // The actual business existence check happens in the business context provider
            debugPrint('🏢 Valid business slug detected: $businessSlug');
            return null;
          }
          // Invalid business slug format - redirect to home
          debugPrint(
              '❌ Invalid business slug format: $businessSlug, redirecting to home');
          return '/';
        },
        pageBuilder: (context, state) {
          final businessSlug = state.pathParameters['businessSlug']!;
          debugPrint('🏢 Optimized business home for: $businessSlug');
          return NoTransitionPage(
            child: OptimizedHomeScreenWrapper(businessSlug: businessSlug),
          );
        },
        routes: [
          // Business menu route (e.g., /kako/menu) - Optimized
          GoRoute(
            path: '/menu',
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug']!;
              debugPrint('🏢 Optimized business menu for: $businessSlug');
              return NoTransitionPage(
                child: OptimizedMenuScreenWrapper(businessSlug: businessSlug),
              );
            },
          ),
          // Business cart route (e.g., /kako/carrito) - Optimized
          GoRoute(
            path: '/carrito',
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug']!;
              debugPrint('🏢 Optimized business cart for: $businessSlug');
              return NoTransitionPage(
                child: OptimizedCartScreenWrapper(businessSlug: businessSlug),
              );
            },
          ),
          // Alias for cart with English route - Optimized
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug'];
              debugPrint('🏢 Optimized business cart (EN) for: $businessSlug');
              return NoTransitionPage(
                child: OptimizedCartScreenWrapper(businessSlug: businessSlug ?? ''),
              );
            },
          ),
          // Business account route (e.g., /kako/cuenta) - Optimized
          GoRoute(
            path: '/cuenta',
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug'];
              debugPrint('🏢 Optimized business account for: $businessSlug');
              return NoTransitionPage(
                child: OptimizedProfileScreenWrapper(businessSlug: businessSlug ?? ''),
              );
            },
          ),
          // Business orders route (e.g., /kako/ordenes) - Optimized
          GoRoute(
            path: '/ordenes',
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug'];
              debugPrint('🏢 Optimized business orders for: $businessSlug');
              return NoTransitionPage(
                child: OptimizedOrdersScreenWrapper(businessSlug: businessSlug ?? ''),
              );
            },
          ),
          // Business admin route (e.g., /kako/admin) - Optimized
          GoRoute(
            path: '/admin',
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug'];
              debugPrint('🏢 Optimized business admin for: $businessSlug');
              return NoTransitionPage(
                child: OptimizedAdminScreenWrapper(businessSlug: businessSlug ?? ''),
              );
            },
            routes: [
              // Add nested admin routes for business-specific admin access
              ...getBusinessAdminRoutes(),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Helper function to get nested routes for a specific path
List<RouteBase> _getNestedRoutes(String path) {
  switch (path) {
    case '/':
      return [
        GoRoute(
          path: '/catering-menu',
          name: AppRoute.cateringMenuE.name,
          builder: (context, state) => const CateringMenuScreen(),
        ),
        GoRoute(
          path: '/catering-quote',
          name: AppRoute.cateringQuote.name,
          builder: (context, state) => const QuoteScreen(),
        ),
      ];
    case '/menu':
      return [
        GoRoute(
          path: 'subscripciones',
          name: AppRoute.mealPlan.name,
          pageBuilder: (context, state) => const MaterialPage(
            child: CustomerMealPlanScreen(),
          ),
          routes: [
            GoRoute(
              name: AppRoute.planDetails.name,
              path: ':planId',
              builder: (context, state) {
                final planId = state.pathParameters['planId']!;
                return PlanDetailsScreen(planId: planId);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'catering',
          name: AppRoute.caterings.name,
          pageBuilder: (context, state) => const MaterialPage(
            child: CateringEntryScreen(),
          ),
          routes: [
            GoRoute(
              path: 'quote',
              name: AppRoute.manualQuote.name,
              pageBuilder: (context, state) => const MaterialPage(
                child: QuoteScreen(),
              ),
            ),
          ],
        ),
      ];
    default:
      return [];
  }
}

GlobalKey<NavigatorState> _getNavigatorKey(String path) {
  switch (path) {
    case '/':
      return _landingNavigatorKey;
    case '/menu':
      return _homeNavigatorKey;
    case '/carrito':
      return _cartNavigatorKey;
    case '/cuenta':
      return _accountNavigatorKey;
    case '/admin':
      return _adminNavigatorKey;
    case '/ordenes':
      return _ordersNavigatorKey;
    default:
      return _rootNavigatorKey;
  }
}

String _getRouteName(String path) {
  final pathToRoute = {
    '/': AppRoute.landing.name,
    '/menu': AppRoute.home.name,
    '/carrito': AppRoute.homecart.name,
    '/cuenta': AppRoute.profile.name,
    '/ordenes': AppRoute.inProgressOrders.name,
    '/admin': AppRoute.adminPanel.name,
  };
  return pathToRoute[path] ?? AppRoute.home.name;
}

Widget _getDestinationScreen(String path) {
  switch (path) {
    case '/':
      return const ResponsiveLandingPage();
    case '/menu':
      return const MenuScreen();
    case '/carrito':
      return const CartScreen(isAuthenticated: true);
    case '/cuenta':
      return const CustomProfileScreen();
    case '/admin':
      return Consumer(
        builder: (context, ref, _) {
          final isAdmin = ref.watch(isAdminProvider);
          return isAdmin.when(
            data: (isAdmin) => isAdmin
                ? const AdminPanelScreen(
                    initialIndex: 0, // Dashboard is index 0
                    child: AdminDashboardHome(),
                  )
                : const UnauthorizedScreen(),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const UnauthorizedScreen(),
          );
        },
      );
    case '/ordenes':
      return const InProgressOrdersScreen();
    default:
      return const MenuHome();
  }
}

StatefulShellBranch _buildBranch(NavigationDestinationItem destination) {
  return StatefulShellBranch(
    navigatorKey: _getNavigatorKey(destination.path),
    routes: [
      GoRoute(
        path: destination.path,
        name: _getRouteName(destination.path),
        pageBuilder: (context, state) => NoTransitionPage(
          child: _getDestinationScreen(destination.path),
        ),
        routes: _getNestedRoutes(destination.path),
      ),
    ],
  );
}

// Include bare minimum of UnauthorizedScreen to make the code complete
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),
            const Text('You do not have access to this area'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to validate business slugs in routing
bool _isValidBusinessSlug(String slug) {
  // Business slugs should:
  // - Be at least 2 characters long
  // - Not contain spaces or special routing characters
  // - Only contain lowercase letters, numbers, and hyphens
  // - Not start or end with hyphens
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#')) return false;
  if (slug.startsWith('-') || slug.endsWith('-')) return false;

  // Check valid pattern: lowercase letters, numbers, and hyphens only
  final validPattern = RegExp(r'^[a-z0-9-]+$');
  if (!validPattern.hasMatch(slug)) return false;

  // Allow reserved slugs for business-specific routing
  final reservedSlugs = {
    'admin', 'menu', 'carrito', 'cuenta', 'ordenes', 'business-setup', 'business-setup-complete', 'startup', 'error', 'onboarding', 'signin', 'admin-setup'
  };
  if (reservedSlugs.contains(slug)) return true;

  return true;
}

/// Helper function to get business-specific admin routes
/// These are simplified admin routes that work within business context
List<RouteBase> getBusinessAdminRoutes() {
  return [
    // Basic business admin sub-routes - simplified for business context
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const AdminDashboardHome(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductManagementScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrderManagementScreen(),
    ),
    GoRoute(
      path: '/meal-plans',
      builder: (context, state) => const MealPlanManagementScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const BusinessSettingsScreen(),
    ),
    // Add more business-specific admin routes as needed
  ];
}
