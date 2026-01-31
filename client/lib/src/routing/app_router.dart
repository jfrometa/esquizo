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
import 'package:starter_architecture_flutter_firebase/src/core/business/business_constants.dart';
import 'package:starter_architecture_flutter_firebase/src/extensions/firebase_analitics.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_startup.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/optimized_business_wrappers.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_dashboard_home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_setup_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_set_comple_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_settings_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_setup_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/order_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/product_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/custom_sign_in_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/debug/admin_debug_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/onboarding/presentation/onboarding_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/landing_page_home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/dish_details/dish_details_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/dish_caterogy/category_dishes_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/all_dishes_menu_home/all_dishes_menu_home_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/checkout_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/QR/models/qr_code_data.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/screens/catering_menu/catering_menu_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_selection_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_quote/manual_quote_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/catering_entry_screen.dart';
import 'package:go_router/go_router.dart';

part 'app_router.g.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// Error state for router
@riverpod
class RouterErrorNotifier extends _$RouterErrorNotifier {
  @override
  String? build() => null;

  void setError(String? error) => state = error;
}

// =============================================================================
// Route Path Constants - Single source of truth for all route paths
// =============================================================================

/// Centralized route path constants for type-safe routing
abstract class RoutePaths {
  // System routes
  static const root = '/';
  static const signin = '/signin';
  static const onboarding = '/onboarding';
  static const startup = '/startup';
  static const error = '/error';
  static const debug = '/debug';

  // Admin routes
  static const admin = '/admin';
  static const adminSetup = '/admin-setup';

  // Business setup
  static const businessSetup = '/business-setup';
  static const businessSetupComplete = '/business-setup/complete';

  // Business sub-routes (relative paths)
  static const menu = 'menu';
  static const cart = 'carrito';
  static const cartEn = 'cart';
  static const profile = 'cuenta';
  static const orders = 'ordenes';

  /// Build a business-prefixed path
  static String forBusiness(String businessSlug, [String? subRoute]) {
    if (subRoute == null || subRoute.isEmpty || subRoute == '/') {
      return '/$businessSlug';
    }
    final cleanSubRoute =
        subRoute.startsWith('/') ? subRoute.substring(1) : subRoute;
    return '/$businessSlug/$cleanSubRoute';
  }
}

// =============================================================================
// Navigation Helpers - Safe navigation with automatic businessSlug
// =============================================================================

/// Extension on BuildContext for safe business-aware navigation
extension BusinessNavigationExtension on BuildContext {
  /// Navigate to business home with automatic slug detection
  /// Falls back to default business if no slug is available
  void goToBusinessHome([String? businessSlug]) {
    final slug = businessSlug ?? BusinessConstants.defaultSlug;
    GoRouter.of(this).go(RoutePaths.forBusiness(slug));
  }

  /// Navigate to business menu
  void goToBusinessMenu([String? businessSlug]) {
    final slug = businessSlug ?? BusinessConstants.defaultSlug;
    GoRouter.of(this).go(RoutePaths.forBusiness(slug, RoutePaths.menu));
  }

  /// Navigate to business cart
  void goToBusinessCart([String? businessSlug]) {
    final slug = businessSlug ?? BusinessConstants.defaultSlug;
    GoRouter.of(this).go(RoutePaths.forBusiness(slug, RoutePaths.cart));
  }

  /// Navigate to business profile
  void goToBusinessProfile([String? businessSlug]) {
    final slug = businessSlug ?? BusinessConstants.defaultSlug;
    GoRouter.of(this).go(RoutePaths.forBusiness(slug, RoutePaths.profile));
  }

  /// Safe version of goNamed that automatically injects the current businessSlug
  /// if it is missing from pathParameters but required by the route.
  void goNamedSafe(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    final route = _findAppRouteByName(name);
    final finalPathParameters = Map<String, String>.from(pathParameters);

    // If the route requires a business context and businessSlug is missing, inject it
    if (route != null &&
        route.requiresBusinessContext &&
        !finalPathParameters.containsKey('businessSlug')) {
      // 1. Try from current GoRouter state
      String? currentSlug =
          GoRouterState.of(this).pathParameters['businessSlug'];

      // 2. Try from our business navigation provider
      if (currentSlug == null || currentSlug.isEmpty) {
        try {
          final container = ProviderScope.containerOf(this, listen: false);
          currentSlug = container.read(currentBusinessSlugProvider);
        } catch (e) {
          debugPrint('[Navigation] Error reading provider: $e');
        }
      }

      // 3. Fallback to default
      final slug = currentSlug ?? BusinessConstants.defaultSlug;
      finalPathParameters['businessSlug'] = slug;
      debugPrint(
          '[Navigation] Injected missing businessSlug: $slug for route: $name');
    }

    GoRouter.of(this).goNamed(
      name,
      pathParameters: finalPathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Safe version of pushNamed that automatically injects the current businessSlug
  /// if it is missing from pathParameters but required by the route.
  Future<T?> pushNamedSafe<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    final route = _findAppRouteByName(name);
    final finalPathParameters = Map<String, String>.from(pathParameters);

    // If the route requires a business context and businessSlug is missing, inject it
    if (route != null &&
        route.requiresBusinessContext &&
        !finalPathParameters.containsKey('businessSlug')) {
      // 1. Try from current GoRouter state
      String? currentSlug =
          GoRouterState.of(this).pathParameters['businessSlug'];

      // 2. Try from our business navigation provider
      if (currentSlug == null || currentSlug.isEmpty) {
        try {
          final container = ProviderScope.containerOf(this, listen: false);
          currentSlug = container.read(currentBusinessSlugProvider);
        } catch (e) {
          debugPrint('[Navigation] Error reading provider: $e');
        }
      }

      // 3. Fallback to default
      final slug = currentSlug ?? BusinessConstants.defaultSlug;
      finalPathParameters['businessSlug'] = slug;
      debugPrint(
          '[Navigation] Injected missing businessSlug (push): $slug for route: $name');
    }

    return GoRouter.of(this).pushNamed<T>(
      name,
      pathParameters: finalPathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Helper to find AppRoute by name
  AppRoute? _findAppRouteByName(String name) {
    try {
      return AppRoute.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }
}

// =============================================================================
// Debug Navigator Observer
// =============================================================================

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

// =============================================================================
// AppRoute Enum
// =============================================================================

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
  menu,
  adminPanel,
  adminSetup,
  inProgressOrders,
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
  mealPlanDetails,
  cateringSelection,
  manualQuote,
}

// =============================================================================
// Type-Safe Route Extensions
// =============================================================================

/// Extension for type-safe path generation from AppRoute enum
extension AppRouteExtension on AppRoute {
  /// Get the base path template for this route
  String get basePath {
    switch (this) {
      case AppRoute.home:
        return '/:businessSlug';
      case AppRoute.menu:
        return '/:businessSlug/${RoutePaths.menu}';
      case AppRoute.homecart:
        return '/:businessSlug/${RoutePaths.cart}';
      case AppRoute.profile:
        return '/:businessSlug/${RoutePaths.profile}';
      case AppRoute.inProgressOrders:
        return '/:businessSlug/${RoutePaths.orders}';
      case AppRoute.checkout:
        return '/:businessSlug/checkout';
      case AppRoute.catering:
        return '/:businessSlug/catering';
      case AppRoute.mealPlans:
        return '/:businessSlug/meal-plans';
      case AppRoute.details:
        return '/:businessSlug/details/:dishId';
      case AppRoute.addDishToOrder:
        return '/:businessSlug/add-dish/:dishId';
      case AppRoute.landing:
        return RoutePaths.root;
      case AppRoute.signIn:
        return RoutePaths.signin;
      case AppRoute.onboarding:
        return RoutePaths.onboarding;
      case AppRoute.adminSetup:
        return RoutePaths.adminSetup;
      case AppRoute.businessSetup:
        return RoutePaths.businessSetup;
      case AppRoute.cateringSelection:
        return '/:businessSlug/catering-selection';
      case AppRoute.manualQuote:
        return '/:businessSlug/manual-quote';
      default:
        // Use a heuristic: if the route name is likely a business-context route,
        // return a path that includes :businessSlug even if not explicitly mapped
        final businessContextRoutes = [
          'checkout',
          'cart',
          'menu',
          'details',
          'catering',
          'meal',
          'order'
        ];
        if (businessContextRoutes
            .any((kw) => name.toLowerCase().contains(kw))) {
          return '/:businessSlug/$name';
        }
        return '/$name';
    }
  }

  /// Build a complete path with optional business slug
  String path({String? businessSlug, Map<String, String>? params}) {
    String result = basePath;

    // Replace businessSlug placeholder
    if (businessSlug != null) {
      result = result.replaceAll(':businessSlug', businessSlug);
    }

    // Replace other parameters
    if (params != null) {
      params.forEach((key, value) {
        result = result.replaceAll(':$key', value);
      });
    }

    return result;
  }

  /// Check if this route requires a business context
  bool get requiresBusinessContext {
    return basePath.contains(':businessSlug');
  }
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

        // [Router] Evaluating path: "$path"
        if (kDebugMode) {
          debugPrint('[Router] Evaluating route: "$path"');
        }

        // Skip redirect logic entirely if we're already at error
        if (path.startsWith('/error')) {
          return null;
        }

        // If Firebase is not initialized, redirect to startup (don't initialize here)
        if (!isFirebaseInitialized) {
          debugPrint(
              "[Router] Firebase not initialized, redirecting to startup from $path");
          return '/startup?from=$path';
        }

        // If we are at startup but Firebase is already initialized, redirect to where we came from
        if (path == '/startup' && isFirebaseInitialized) {
          final from = state.uri.queryParameters['from'] ?? '/';
          debugPrint(
              "[Router] Firebase initialized, redirecting back to $from");
          return from;
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
                '[Router] Non-platform-admin blocked from platform admin area');
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
        debugPrint("[Router] Error: $e");
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
        name: AppRoute.home.name,
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
            name: AppRoute.menu.name,
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
            name: AppRoute.homecart.name,
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
            name: 'cart_en', // Unique name for English alias
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
            name: AppRoute.profile.name,
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
            name: AppRoute.inProgressOrders.name,
            pageBuilder: (context, state) {
              final businessSlug = state.pathParameters['businessSlug']!;
              debugPrint('🏢 Optimized business orders for: $businessSlug');
              return NoTransitionPage(
                child: OptimizedOrdersScreenWrapper(businessSlug: businessSlug),
              );
            },
          ),
          // Dish details route (e.g., /kako/platillo/:dishId)
          GoRoute(
            path: 'platillo/:dishId',
            name: AppRoute.addDishToOrder.name,
            pageBuilder: (context, state) {
              final dishId = state.pathParameters['dishId']!;
              return NoTransitionPage(
                child: DishDetailsScreen(id: dishId),
              );
            },
          ),
          // Category dishes route (e.g., /kako/categorias)
          GoRoute(
            path: 'categorias',
            name: AppRoute.category.name,
            pageBuilder: (context, state) {
              // Note: This route might need more parameters if it's used from scratch
              // But for now, we provide dummy table data if not coming from somewhere specific
              return NoTransitionPage(
                child: CategoryDishesScreen(
                  categoryId: '',
                  categoryName: 'Categorías',
                  tableData: QRCodeData(
                    tableId: '',
                    tableName: '',
                    restaurantId: '',
                    generatedAt: DateTime.now(),
                  ),
                  sortIndex: 0,
                ),
              );
            },
          ),
          // All dishes route (e.g., /kako/platillos)
          GoRoute(
            path: 'platillos',
            name: AppRoute.allDishes.name,
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: AllDishesMenuHomeScreen(),
              );
            },
          ),
          // Catering entry route (e.g., /kako/catering)
          GoRoute(
            path: 'catering',
            name: AppRoute.catering.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CateringEntryScreen(),
            ),
          ),
          // Catering menu route (e.g., /kako/catering-menu)
          GoRoute(
            path: 'catering-menu',
            name: AppRoute.cateringMenu.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CateringMenuScreen(),
            ),
          ),
          // Catering quote route (e.g., /kako/catering-quote)
          GoRoute(
            path: 'catering-quote',
            name: AppRoute.cateringQuote.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuoteScreen(),
            ),
          ),
          // Catering selection route (e.g., /kako/catering-selection)
          GoRoute(
            path: 'catering-selection',
            name: AppRoute.cateringSelection.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CateringSelectionScreen(),
            ),
          ),
          // Manual quote route (e.g., /kako/manual-quote)
          GoRoute(
            path: 'manual-quote',
            name: AppRoute.manualQuote.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ManualQuoteScreen(),
            ),
          ),
          // Checkout route (e.g., /kako/checkout)
          GoRoute(
            path: 'checkout',
            name: AppRoute.checkout.name,
            pageBuilder: (context, state) {
              final type = state.extra as String? ?? 'platos';
              return NoTransitionPage(
                child: CheckoutScreen(displayType: type),
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

// =============================================================================
// Error Screens
// =============================================================================

/// Error type for router errors
enum RouterErrorType {
  unauthorized,
  notFound,
  businessNotFound,
  networkError,
  unknown,
}

/// Enhanced error screen with contextual information and recovery options
class RouterErrorScreen extends StatelessWidget {
  const RouterErrorScreen({
    super.key,
    this.errorType = RouterErrorType.unknown,
    this.message,
    this.returnPath,
  });

  final RouterErrorType errorType;
  final String? message;
  final String? returnPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(colorScheme),
                const SizedBox(height: 24),
                Text(
                  _getTitle(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message ?? _getDefaultMessage(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildActions(context, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (errorType) {
      case RouterErrorType.unauthorized:
        icon = Icons.lock_outline;
        color = colorScheme.error;
        break;
      case RouterErrorType.notFound:
        icon = Icons.search_off;
        color = colorScheme.tertiary;
        break;
      case RouterErrorType.businessNotFound:
        icon = Icons.store_mall_directory_outlined;
        color = colorScheme.secondary;
        break;
      case RouterErrorType.networkError:
        icon = Icons.wifi_off;
        color = colorScheme.error;
        break;
      case RouterErrorType.unknown:
        icon = Icons.error_outline;
        color = colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 64, color: color),
    );
  }

  String _getTitle() {
    switch (errorType) {
      case RouterErrorType.unauthorized:
        return 'Access Denied';
      case RouterErrorType.notFound:
        return 'Page Not Found';
      case RouterErrorType.businessNotFound:
        return 'Business Not Found';
      case RouterErrorType.networkError:
        return 'Connection Error';
      case RouterErrorType.unknown:
        return 'Something Went Wrong';
    }
  }

  String _getDefaultMessage() {
    switch (errorType) {
      case RouterErrorType.unauthorized:
        return 'You do not have permission to access this area. Please sign in with an authorized account.';
      case RouterErrorType.notFound:
        return 'The page you\'re looking for doesn\'t exist or has been moved.';
      case RouterErrorType.businessNotFound:
        return 'We couldn\'t find the business you\'re looking for. Please check the URL and try again.';
      case RouterErrorType.networkError:
        return 'Unable to connect. Please check your internet connection and try again.';
      case RouterErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  Widget _buildActions(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: () => context.go(returnPath ?? RoutePaths.root),
          icon: const Icon(Icons.home),
          label: const Text('Go to Home'),
        ),
        const SizedBox(height: 12),
        if (errorType == RouterErrorType.unauthorized)
          OutlinedButton.icon(
            onPressed: () => context.go(RoutePaths.signin),
            icon: const Icon(Icons.login),
            label: const Text('Sign In'),
          ),
        if (errorType == RouterErrorType.networkError)
          OutlinedButton.icon(
            onPressed: () {
              // Trigger a reload by navigating to current path
              final currentPath = GoRouter.of(context)
                  .routerDelegate
                  .currentConfiguration
                  .uri
                  .path;
              context.go(currentPath);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
      ],
    );
  }
}

/// Backwards-compatible alias for UnauthorizedScreen
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RouterErrorScreen(
      errorType: RouterErrorType.unauthorized,
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
