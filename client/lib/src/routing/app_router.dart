import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/app_config/app_config_services.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';

import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/extensions/firebase_analitics.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_startup.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/go_router_refresh_stream.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_dashboard_home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_setup_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_set_comple_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_setup_screen.dart';
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
  final destinations = ref.watch(navigationDestinationsProvider);
  final isFirebaseInitialized = ref.watch(isFirebaseInitializedProvider);
  final isAdmin = ref.watch(cachedAdminStatusProvider);

  // Watch for business config status (same as AdminSetupScreen)
  final businessConfigAsync = ref.watch(businessConfigProvider);

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
      try {
        final path = state.uri.path;

        // Log router state for debugging
        debugPrint(
            '🧭 Router redirect, path: "$path", location: "${state.uri}"');

        // Skip redirect logic entirely if we're already at error
        if (path.startsWith('/error')) {
          return null;
        }

        // Initialize Firebase if needed
        if (!isFirebaseInitialized) {
          try {
            await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform);
            debugPrint("📱 Firebase initialized successfully");
          } catch (e) {
            debugPrint("🔥 Error initializing Firebase: $e");
            return '/error?message=${Uri.encodeComponent(e.toString())}';
          }
        }

        // Check authentication status
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

        // Handle authentication redirects
        if (!isLoggedIn) {
          // Allow access to public routes and error routes
          if (isLoggingIn || isOnboarding || isAtError || isAtStartup) {
            return null;
          }

          // Store the attempted path to redirect after login if not already at signin
          if (path != '/signin') {
            // Use Future.microtask to avoid setState during build
            Future.microtask(() {
              ref.read(_pendingAdminPathProvider.notifier).state = path;
            });

            return '/signin?from=$path';
          }
          return null;
        }

        // User is logged in
        if (isLoggedIn) {
          // Check for any pending path that was saved before authentication
          final pendingPath = ref.read(_pendingAdminPathProvider);

          // Handle admin routes - check permissions
          if (path.startsWith('/admin')) {
            if (!isAdmin) {
              return '/'; // Redirect non-admins to home
            }

            // Check business configuration status (same logic as AdminSetupScreen)
            final businessConfig = businessConfigAsync.value;
            final isBusinessConfigured =
                businessConfig != null && businessConfig.isActive;

            // Only redirect to admin setup if business is definitely not set up
            // and we're not already at the admin setup page
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

          // If we're at startup, signin, or onboarding, go to saved path or home
          if (isAtStartup || isLoggingIn || isOnboarding) {
            if (pendingPath != null &&
                pendingPath.isNotEmpty &&
                pendingPath != '/') {
              // Clear the pending path
              Future.microtask(() {
                ref.read(_pendingAdminPathProvider.notifier).state = null;
              });
              return pendingPath;
            }
            return '/'; // Default to home if no pending path
          }
        }

        return null; // No redirect needed
      } catch (e) {
        debugPrint("🔥 Router error: $e");
        return '/error?message=${Uri.encodeComponent(e.toString())}';
      }
    },
    observers: [
      // Firebase Analytics Observer
      FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
        nameExtractor: (RouteSettings settings) {
          final String? name = settings.name;
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
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) => NoTransitionPage(
          child: ScaffoldWithNestedNavigation(navigationShell: navigationShell),
        ),
        branches: destinations.map((dest) => _buildBranch(dest)).toList(),
      ),
      // Add all admin routes here for proper URL handling
      ...getAdminRoutes(),
    ],
  );
}

// Rest of your file with helper functions and route definitions...
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
              pageBuilder: (context, state) {
                return MaterialPage(child: ManualQuoteScreen());
              },
            ),
            GoRoute(
              path: 'menu',
              name: AppRoute.cateringMenu.name,
              pageBuilder: (context, state) {
                return MaterialPage(child: CateringSelectionScreen());
              },
            ),
          ],
        ),
        GoRoute(
          path: 'populares',
          name: AppRoute.allDishes.name,
          pageBuilder: (context, state) => const MaterialPage(
            child: AllDishesMenuHomeScreen(),
          ),
        ),
        GoRoute(
          path: 'carrito/:itemId',
          name: AppRoute.addToOrder.name,
          pageBuilder: (context, state) {
            final itemId = state.pathParameters['itemId']!;
            return MaterialPage(
              child: DishDetailsScreen(
                id: itemId,
              ),
            );
          },
        ),
        GoRoute(
          path: 'categorias',
          name: AppRoute.category.name,
          pageBuilder: (context, state) => const MaterialPage(
            child: Categories(),
          ),
          routes: [
            GoRoute(
              path: 'subscripciones',
              name: AppRoute.mealPlans.name,
              pageBuilder: (context, state) => const MaterialPage(
                child: CustomerMealPlanScreen(),
              ),
            ),
            GoRoute(
              path: 'catering',
              name: AppRoute.catering.name,
              pageBuilder: (context, state) => const MaterialPage(
                child: CateringEntryScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'platos',
          name: AppRoute.details.name,
          pageBuilder: (context, state) => const MaterialPage(
            child: AllDishesMenuHomeScreen(),
          ),
          routes: [
            GoRoute(
              path: 'detalle/:dishId',
              name: AppRoute.addDishToOrder.name,
              pageBuilder: (context, state) {
                final itemId = state.pathParameters['dishId']!;
                return MaterialPage(
                  child: DishDetailsScreen(
                    id: itemId,
                  ),
                );
              },
            ),
          ],
        ),
      ];

    case '/carrito':
      return [
        GoRoute(
          path: 'completar-orden',
          name: AppRoute.checkout.name,
          pageBuilder: (context, state) {
            final type = (state.extra ?? 'platos') as String;
            return MaterialPage(
              child: CheckoutScreen(
                displayType: type.toLowerCase(),
              ),
            );
          },
        ),
      ];
    case '/cuenta':
      return [
        GoRoute(
          path: '/authenticated-profile',
          name: AppRoute.authenticatedProfile.name,
          builder: (context, state) {
            final user = state.extra as User?;
            return AuthenticatedProfileScreen(user: user!);
          },
        ),
        // Customer meal plans route in account section
        GoRoute(
          path: 'meal-plans',
          name: AppRoute.customerMealPlan.name,
          builder: (context, state) => const CustomerMealPlanScreen(),
          routes: [
            GoRoute(
              path: ':planId',
              name: AppRoute.mealPlanDetails.name,
              builder: (context, state) {
                final planId = state.pathParameters['planId']!;
                return PlanDetailsScreen(planId: planId);
              },
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
