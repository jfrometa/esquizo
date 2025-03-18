import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/app_config/app_config_services.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/QR/qr_code_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/authenticated_profile_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/screens/catering_menu/catering_menu_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/landing-page-home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/menu_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/cart_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/catering_entry_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_selection_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_quote/manual_quote_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/checkout/checkout_creen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/all_dishes_menu_home/all_dishes_menu_home_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/dish_details/dish_details_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_details.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_subscription.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/screens_mesa_redonda/categories.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/screens_mesa_redonda/home/home.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_startup.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/custom_profile_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/custom_sign_in_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/onboarding/presentation/onboarding_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/go_router_refresh_stream.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/not_found_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/unauthorized_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/orders/in_progress_orders_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_setup_screen.dart'; // Add import for AdminSetupScreen

part 'app_router.g.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');
final _landingNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'landing');
final _cartNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cart');
final _adminNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'admin');
final _OrdersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'local');
final _localNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'orders');
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
  caterings, // If both are used
  cateringMenuE, // Add this route
  cateringQuote, // Add this route
  landing,
  local,
  adminPanel,
  adminSetup, // Add this route for admin setup
  inProgressOrders,
  manualQuote
}

@riverpod
GoRouter goRouter(Ref ref) {
  final appStartupState = ref.watch(appStartupProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final destinations = ref.watch(navigationDestinationsProvider);
  final isFirebaseInitialized = ref.watch(isFirebaseInitializedProvider);

  return GoRouter(
    initialLocation: '/signIn',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      if (!isFirebaseInitialized) {
        try {
          await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform);
        } catch (e) {
          debugPrint("Error initializing Firebase: $e"); // Log the error
          return '/error'; // Redirect to error page
        }
      }

      // If the app is still initializing, show the /startup route
      if (appStartupState.isLoading || appStartupState.hasError) {
        return '/startup';
      }

      final path = state.uri.path;

      // final onboardingRepository =
      //     ref.read(onboardingRepositoryProvider).requireValue;
      // final didCompleteOnboarding = onboardingRepository.isOnboardingComplete();

      // if (!didCompleteOnboarding) {
      //   if (path != '/onboarding') {
      //     return '/onboarding';
      //   }
      //   return null;
      // }

      final isLoggedIn = authRepository.currentUser != null;

      if (isLoggedIn) {
        if (path.startsWith('/startup') ||
            path.startsWith('/onboarding') ||
            path.startsWith('/signIn')) {
          return '/';
        }
      } else {
        if (path.startsWith('/startup') ||
            path.startsWith('/onboarding') ||
            path.startsWith('/jobs') ||
            path.startsWith('/home') ||
            path.startsWith('/chat') ||
            path.startsWith('/entries') ||
            path.startsWith('/account')) {
          return '/signIn';
        }
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: [
      GoRoute(
        path: '/startup',
        pageBuilder: (context, state) => NoTransitionPage(
          child: AppStartupWidget(
            onLoaded: (_) => const SizedBox.shrink(),
          ),
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
        path: '/signIn',
        name: AppRoute.signIn.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CustomSignInScreen(),
        ),
      ),
      // Add a root-level admin setup route that can be accessed from anywhere
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
    ],
    errorPageBuilder: (context, state) => const NoTransitionPage(
      child: NotFoundScreen(),
    ),
  );
}

List<RouteBase> _getNestedRoutes(String path) {
  switch (path) {
    case '/':
      return [     // ... your existing routes
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
      //     case '/local':
      // return [     // ... your existing routes
      //   GoRoute(
      //     path: '/locales',
      //     name: AppRoute.local.name,
      //     builder: (context, state) => const QRCodeScreen(),
      //   ),
        // GoRoute(
        //   path: '/catering-quote',
        //   name: AppRoute.cateringQuote.name, 
        //   builder: (context, state) => const QuoteScreen(),
        // ),
      // ];
    case '/menu':
      return [
        GoRoute(
          path: 'subscripciones',
          name: AppRoute.mealPlan.name,
          pageBuilder: (context, state) => const MaterialPage(
            child: MealPlansScreen(),
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
                index: int.parse(itemId),
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
                child: MealPlansScreen(),
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
                    index: int.parse(itemId),
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
    case '/admin':
      return [
        // Add the setup route to the admin nested routes as well
        GoRoute(
          path: 'setup',
          name: 'adminSetupNested', // Different name to avoid conflict
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminSetupScreen(),
          ),
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
      ];
    default:
      return [];
  }
}

GlobalKey<NavigatorState> _getNavigatorKey(String path) {
  switch (path) {
    case '/':
      return _landingNavigatorKey;
    case '/local':
      return _localNavigatorKey;
    case '/menu':
      return _homeNavigatorKey;
    case '/carrito':
      return _cartNavigatorKey;
    case '/cuenta':
      return _accountNavigatorKey;
    case '/admin':
      return _adminNavigatorKey;
    case '/ordenes':
      return _OrdersNavigatorKey;
    default:
      return _rootNavigatorKey;
  }
}

String _getRouteName(String path) {
  final pathToRoute = {
    '/': AppRoute.landing.name,
    '/local': AppRoute.local.name,
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
          case '/local':
    return const QRCodeScreen();
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
                ? const AdminPanelScreen()
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