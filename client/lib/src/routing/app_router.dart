import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/app_config/app_config_services.dart';
import 'package:starter_architecture_flutter_firebase/src/extensions/firebase_analitics.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/customer_meal_plan_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_analytics_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_items_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/meal_plan_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_qr_code.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/meal_plan_admin_section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/meal_plan_export.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/staff/pos_meal_plan_scanner.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/staff/pos_meal_plan_widget.dart';
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
import 'package:starter_architecture_flutter_firebase/src/screens/orders/in_progress_orders_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_setup_screen.dart';

// Add catering management imports
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/catering_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_dashboard_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_order_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_package_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_item_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_category_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/caterig_order_details_screen.dart';

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
  caterings,
  cateringMenuE,
  cateringQuote,
  landing,
  local,
  adminPanel,
  adminSetup,
  inProgressOrders,
  manualQuote,
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
  final appStartupState = ref.watch(appStartupProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final destinations = ref.watch(navigationDestinationsProvider);
  final isFirebaseInitialized = ref.watch(isFirebaseInitializedProvider);

  return GoRouter(
    initialLocation: '/signIn',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      // Firebase initialization and authentication logic...
      if (!isFirebaseInitialized) {
        try {
          await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform);
        } catch (e) {
          debugPrint("Error initializing Firebase: $e");
          return '/error';
        }
      }

      if (appStartupState.isLoading || appStartupState.hasError) {
        return '/startup';
      }

      final path = state.uri.path;
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
    observers: [
      // Firebase Analytics Observer...
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
    ],
    errorPageBuilder: (context, state) => const NoTransitionPage(
      child: NotFoundScreen(),
    ),
  );
}

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
    case '/admin':
      return [
        // Admin setup nested route
        GoRoute(
          path: 'setup',
          name: 'adminSetupNested',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminSetupScreen(),
          ),
        ),
        // Catering management routes
        GoRoute(
          path: 'catering',
          name: AppRoute.cateringManagement.name,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CateringManagementScreen(),
          ),
          routes: [
            // Catering dashboard route (default route)
            GoRoute(
              path: 'dashboard',
              name: AppRoute.cateringDashboard.name,
              builder: (context, state) => const CateringDashboardScreen(),
            ),
            // Catering orders route
            GoRoute(
              path: 'orders',
              name: AppRoute.cateringOrders.name,
              builder: (context, state) => const CateringOrdersScreen(),
              routes: [
                // Order details route
                GoRoute(
                  path: ':orderId',
                  name: AppRoute.cateringOrderDetails.name,
                  builder: (context, state) {
                    final orderId = state.pathParameters['orderId']!;
                    return CateringOrderDetailsScreen(orderId: orderId);
                  },
                ),
              ],
            ),
            // Catering packages route
            GoRoute(
              path: 'packages',
              name: AppRoute.cateringPackages.name,
              builder: (context, state) => const CateringPackageScreen(),
            ),
            // Catering items route
            GoRoute(
              path: 'items',
              name: AppRoute.cateringItems.name,
              builder: (context, state) => const CateringItemScreen(),
            ),
            // Catering categories route
            GoRoute(
              path: 'categories',
              name: AppRoute.cateringCategories.name,
              builder: (context, state) => const CateringCategoryScreen(),
            ),
          ],
        ),
        // Meal plan management routes
        GoRoute(
          path: 'meal-plans',
          name: AppRoute.mealPlanManagement.name,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MealPlanAdminSection(),
          ),
          routes: [
            // Meal plan management dashboard
            GoRoute(
              path: 'management',
              name: AppRoute.mealPlanAdminSection.name,
              builder: (context, state) => const MealPlanManagementScreen(),
            ),
            // Meal plan items route
            GoRoute(
              path: 'items',
              name: AppRoute.mealPlanItems.name,
              builder: (context, state) => const MealPlanItemsScreen(),
            ),
            // Meal plan analytics route
            GoRoute(
              path: 'analytics',
              name: AppRoute.mealPlanAnalytics.name,
              builder: (context, state) => const MealPlanAnalyticsScreen(),
            ),
            // Meal plan export route
            GoRoute(
              path: 'export',
              name: AppRoute.mealPlanExport.name,
              builder: (context, state) => const MealPlanExportScreen(),
            ),
            // Meal plan QR code route
            GoRoute(
              path: 'qr/:planId',
              name: AppRoute.mealPlanQrCode.name,
              builder: (context, state) {
                final planId = state.pathParameters['planId']!;
                return MealPlanQRCode(mealPlanId: planId);
              },
            ),
            // Meal plan scanner route
            GoRoute(
              path: 'scanner',
              name: AppRoute.mealPlanScanner.name,
              builder: (context, state) {
                return MealPlanScanner(
                  onMealPlanScanned: (mealPlan) =>
                      context.go('/admin/meal-plans'),
                );
              },
            ),
            // Meal plan POS widget route
            GoRoute(
              path: 'pos',
              name: AppRoute.mealPlanPos.name,
              builder: (context, state) {
                return POSMealPlanWidget(
                  onMealPlanUsed: (item) {},
                );
              },
            ),
          ],
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
      return _OrdersNavigatorKey;
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
            data: (isAdmin) =>
                isAdmin ? const AdminPanelScreen() : const UnauthorizedScreen(),
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
