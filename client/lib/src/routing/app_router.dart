import 'package:firebase_analytics/firebase_analytics.dart';
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
import 'package:starter_architecture_flutter_firebase/src/routing/optimized_business_wrappers.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_dashboard_home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_setup_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_set_comple_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_settings_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_setup_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/order_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/product_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/custom_sign_in_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/debug/admin_debug_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/onboarding/presentation/onboarding_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/landing-page-home.dart';
import 'package:go_router/go_router.dart';

part 'app_router.g.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Error state for router
final routerErrorNotifierProvider = StateProvider<String?>((ref) => null);

// Debug navigator observer - reduced logging
class _DebugNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Only log admin routes to reduce noise
    if (kDebugMode && route.settings.name?.startsWith('/admin') == true) {
      debugPrint('🚢 Navigation: PUSH to ${route.settings.name}');
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (kDebugMode && route.settings.name?.startsWith('/admin') == true) {
      debugPrint('🚢 Navigation: POP from ${route.settings.name}');
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (kDebugMode && newRoute?.settings.name?.startsWith('/admin') == true) {
      debugPrint(
          '🚢 Navigation: REPLACE ${oldRoute?.settings.name} → ${newRoute?.settings.name}');
    }
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
  // ⚠️ CRITICAL: Only watch essential providers to prevent constant rebuilds
  final authRepository = ref.watch(authRepositoryProvider);
  final isFirebaseInitialized = ref.watch(isFirebaseInitializedProvider);

  // ⚠️ READ (not watch) these to prevent rebuilds when they change
  final isAdminAsync = ref.read(isAdminProvider);
  final businessConfigAsync = ref.read(businessConfigProvider);

  // *** CRITICAL FIX: Let GoRouter handle initial location automatically ***
  // With path URL strategy, GoRouter will automatically detect the browser URL
  // Don't override it with a hardcoded value

  if (kDebugMode) {
    debugPrint(
        '📍 Router provider creating - letting GoRouter handle initial location');
  }

  return GoRouter(
    // ⚠️ REMOVED: Don't set initialLocation - let GoRouter handle it with URL strategy
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    // ⚠️ REMOVED: Aggressive refresh stream that was causing constant redirects
    // refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    redirect: (context, state) async {
      try {
        final path = state.uri.path;

        // ⚠️ CRITICAL: Only log for admin routes to reduce noise
        if (kDebugMode && path.startsWith('/admin')) {
          debugPrint('🧭 Router evaluating admin route: "$path"');
        }

        // Skip redirect logic entirely if we're already at error
        if (path.startsWith('/error')) {
          return null;
        }

        // If Firebase is not initialized, redirect to startup (don't initialize here)
        if (!isFirebaseInitialized) {
          debugPrint("⚠️ Firebase not initialized, redirecting to startup");
          return '/startup';
        }

        // ⚠️ CRITICAL FIX: Only handle redirects for ADMIN routes
        // Let ALL business routes proceed without any interference
        // Business context persistence will be handled by the UI navigation logic
        if (!path.startsWith('/admin') &&
            !path.startsWith('/signin') &&
            !path.startsWith('/error') &&
            !path.startsWith('/startup')) {
          // This is a business route or default route - let it proceed
          return null;
        }

        // Check authentication status - ONLY for admin routes
        final isLoggedIn = authRepository.currentUser != null;
        final isLoggingIn = state.uri.path == '/signin';
        final isOnboarding = state.uri.path == '/onboarding';
        final isAtError = state.uri.path == '/error';
        final isAtStartup = state.uri.path == '/startup';

        // Allow access to business setup related paths
        if (path.startsWith('/business-setup') ||
            path.startsWith('/admin-setup')) {
          return null;
        }

        // Handle authentication redirects - ONLY for truly protected routes
        if (!isLoggedIn) {
          // Allow access to public routes and error routes
          if (isLoggingIn || isOnboarding || isAtError || isAtStartup) {
            return null;
          }

          // Only redirect to signin for admin routes - let business routes work publicly
          if (path.startsWith('/admin')) {
            return '/signin?from=$path';
          }

          // Allow all other routes (including business routes) to proceed
          return null;
        }

        // User is logged in - only handle admin routes specifically
        if (isLoggedIn && path.startsWith('/admin')) {
          // Don't redirect if admin status is still loading
          if (isAdminAsync.isLoading) {
            return null; // Allow navigation while loading
          }

          // Check if user is a PLATFORM admin (not just a business owner)
          final isPlatformAdmin = await _isPlatformAdmin(ref);

          // Only platform admins can access /admin routes
          if (!isPlatformAdmin) {
            debugPrint(
                '🚫 Non-platform-admin blocked from platform admin area');
            return '/'; // Redirect non-platform-admins to home
          }

          // Check business configuration for admin setup flow
          final businessConfig = businessConfigAsync.value;
          final isBusinessConfigured =
              businessConfig != null && businessConfig.isActive;

          // Only redirect to admin setup if business is definitely not set up
          if (businessConfigAsync.hasValue &&
              !isBusinessConfigured &&
              path != '/admin-setup') {
            return '/admin-setup';
          }

          // If business is set up and user is at admin-setup, redirect to admin panel
          if (businessConfigAsync.hasValue &&
              isBusinessConfigured &&
              path == '/admin-setup') {
            return '/admin';
          }
        }

        // ⚠️ CRITICAL: Let ALL other routes proceed without interference
        // This allows the URL strategy to work properly for business routes
        return null;
      } catch (e) {
        debugPrint("🔥 Router error: $e");
        return '/error?message=${Uri.encodeComponent(e.toString())}';
      }
    },
    observers: [
      // Custom navigation observer for debugging
      _DebugNavigatorObserver(),
      // Firebase Analytics Observer - reduced logging
      FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
        nameExtractor: (RouteSettings settings) {
          final String? name = settings.name;
          // Only log admin routes to reduce noise
          if (kDebugMode && name?.startsWith('/admin') == true) {
            debugPrint('📊 Analytics Observer: Route changed to: $name');
          }
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
      // Temporary debug route for testing admin navigation
      GoRoute(
        path: '/debug',
        name: 'debug',
        pageBuilder: (context, state) => NoTransitionPage(
          child: Scaffold(
            appBar: AppBar(title: const Text('Debug Admin Navigation')),
            body: const AdminDebugWidget(),
          ),
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

      // Root route - Landing page
      GoRoute(
        path: '/',
        name: AppRoute.landing.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ResponsiveLandingPage(),
        ),
      ),

      // --- Business-slugged admin routes ---
      // Add all admin routes under /:businessSlug/admin/... as well
      GoRoute(
        path: '/:businessSlug',
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
            path: 'menu',
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
            path: 'carrito',
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
            path: 'cart',
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug']!;
              debugPrint('🏢 Optimized business cart (EN) for: $businessSlug');
              return NoTransitionPage(
                child: OptimizedCartScreenWrapper(businessSlug: businessSlug),
              );
            },
          ),
          // Business account route (e.g., /kako/cuenta) - Optimized
          GoRoute(
            path: 'cuenta',
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug']!;
              debugPrint('🏢 Optimized business account for: $businessSlug');
              return NoTransitionPage(
                child:
                    OptimizedProfileScreenWrapper(businessSlug: businessSlug),
              );
            },
          ),
          // Business orders route (e.g., /kako/ordenes) - Optimized
          GoRoute(
            path: 'ordenes',
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug']!;
              debugPrint('🏢 Optimized business orders for: $businessSlug');
              return NoTransitionPage(
                child: OptimizedOrdersScreenWrapper(businessSlug: businessSlug),
              );
            },
          ),
          // --- Business-slugged admin routes ---
          ...getBusinessSluggedAdminRoutes(),
        ],
      ),
    ],
  );
}

/// Helper function to get nested routes for a specific path
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

/// Distinguishes platform admins from business owners
/// Platform admins: Users in 'admins' collection or with 'admin' Firebase Auth claims
/// Business owners: Users with 'owner' role in business_relationships collection
Future<bool> _isPlatformAdmin(Ref ref) async {
  try {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return false;

    const cacheOption = GetOptions(source: Source.serverAndCache);
    final firestore = ref.read(firebaseFirestoreProvider);

    // Check admin document in Firestore - PLATFORM ADMIN
    final adminDoc =
        await firestore.collection('admins').doc(user.uid).get(cacheOption);
    if (adminDoc.exists) {
      debugPrint('🔐 User ${user.uid} is a PLATFORM admin (admins collection)');
      return true;
    }

    // Check admin claims in user's token - PLATFORM ADMIN
    try {
      final idTokenResult = await user.getIdTokenResult(true);
      final isAdminClaim = idTokenResult.claims?['admin'] == true;
      if (isAdminClaim) {
        debugPrint(
            '🔐 User ${user.uid} is a PLATFORM admin (Firebase Auth claims)');
        return true;
      }
    } catch (tokenError) {
      debugPrint('Error getting token claims: $tokenError');
    }

    // Note: We DON'T check business_relationships here because that would make
    // business owners count as platform admins, which is not what we want.
    // Business owners should only access /businessSlug/admin, not /admin

    debugPrint('🔐 User ${user.uid} is NOT a platform admin');
    return false;
  } catch (e) {
    debugPrint('Error checking platform admin status: $e');
    return false;
  }
}

// Helper function to validate business slugs in routing
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
      path: '/settings',
      builder: (context, state) => const BusinessSettingsScreen(),
    ),
  ];
}
