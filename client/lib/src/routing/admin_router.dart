import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_dashboard_home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_management/admin_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_setup_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/analytics_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_settings_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/order_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/product_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/table_management/table_management_scren_new.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/order_details_widget.dart';
// Import meal plan screens
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/meal_plan_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_items_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_analytics_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/meal_plan_export.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_qr_code.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/staff/pos_meal_plan_scanner.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/staff/pos_meal_plan_widget.dart';
// Import catering screens
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/catering_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_dashboard_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_order_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_package_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_item_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_category_screen.dart';

/// This class defines all admin routes based on the 4-section structure
class AdminRoutes {
  // Base admin path
  static const String basePath = '/admin';

  // --- Top Level Section Paths (relative) ---
  static const String productDashboard = ''; // Represents /admin
  static const String settings = '/settings'; // Represents /admin/settings
  static const String mealPlans = '/meal-plans'; // Represents /admin/meal-plans
  static const String catering = '/catering'; // Represents /admin/catering

  // --- Product Dashboard Sub-Paths (relative to basePath) ---
  // Note: These paths are structured differently in the router definition
  // but we need constants for matching in getIndexFromRoute
  static const String _pdPrefix =
      '/product-dashboard'; // Internal prefix used in paths
  static const String dashboardProducts = '$_pdPrefix/products';
  static const String dashboardOrders = '$_pdPrefix/orders';
  static const String dashboardTables = '$_pdPrefix/tables';
  static const String dashboardAnalytics = '$_pdPrefix/analytics';
  static const String dashboardOrderDetails = '$_pdPrefix/orders/:orderId';

  // --- Settings Sub-Paths (relative to settings path) ---
  static const String settingsUsers = 'users'; // -> /admin/settings/users

  // --- Catering Sub-Paths (relative to catering path) ---
  static const String cateringDashboard = 'dashboard';
  static const String cateringOrders = 'orders';
  static const String cateringPackages = 'packages';
  static const String cateringItems = 'items';
  static const String cateringCategories = 'categories';

  // --- Meal Plan Sub-Paths (relative to mealPlans path) ---
  static const String mealPlanManagement = 'management';
  static const String mealPlanItems = 'items';
  static const String mealPlanAnalytics = 'analytics';
  static const String mealPlanExport = 'export';
  static const String mealPlanScanner = 'scanner';
  static const String mealPlanPos = 'pos';
  static const String mealPlanQr = 'qr/:planId';

  // --- Named Routes (Ensure these match GoRoute names) ---
  static const String namePdHome = 'product-dashboard-home';
  static const String namePdProducts = 'product-dashboard-products';
  static const String namePdOrders = 'product-dashboard-orders';
  static const String namePdOrderDetails = 'product-dashboard-order-details';
  static const String namePdTables = 'product-dashboard-tables';
  static const String namePdAnalytics = 'product-dashboard-analytics';
  static const String nameSettings = 'settings';
  static const String nameSettingsUsers = 'settings-users';
  static const String nameMpHome = 'meal-plans-home';
  static const String nameMpManagement = 'meal-plans-management';
  static const String nameMpItems = 'meal-plans-items';
  static const String nameMpAnalytics = 'meal-plans-analytics';
  static const String nameMpExport = 'meal-plans-export';
  static const String nameMpScanner = 'meal-plans-scanner';
  static const String nameMpPos = 'meal-plans-pos';
  static const String nameMpQr = 'meal-plans-qr';
  static const String nameCtHome = 'catering-home';
  static const String nameCtDashboard = 'catering-dashboard';
  static const String nameCtOrders = 'catering-orders';
  static const String nameCtPackages = 'catering-packages';
  static const String nameCtItems = 'catering-items';
  static const String nameCtCategories = 'catering-categories';
  static const String nameAdminSetup = 'admin-setup';
  // Add names for login, profile, help, home if used in _showUserMenu/UnauthorizedScreen
  static const String nameLogin = 'login';
  static const String nameProfile = 'profile';
  static const String nameHelp = 'help';
  static const String nameHome = 'home';

  // Get full path by combining base path with relative path
  static String getFullPath(String relativePath) {
    if (relativePath.isEmpty || relativePath == '/') return basePath;
    final String cleanRelative =
        relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    // Avoid double slash if basePath is just '/'
    if (basePath == '/') return '/$cleanRelative';
    return '$basePath/$cleanRelative';
  }

  // Helper to get the primary named route for a section index (0-3)
  static String getPrimaryNamedRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return namePdHome;
      case 1:
        return nameSettings;
      case 2:
        return nameMpHome;
      case 3:
        return nameCtHome;
      default:
        return namePdHome;
    }
  }

  // Helper to get index (0-3) from ANY valid admin route path - REFINED
  static int getIndexFromRoute(String route) {
    // Ensure we are comparing full paths starting from root or /admin
    final String fullRoute = route.startsWith('/') ? route : getFullPath(route);

    // Define full base paths for sections
    final String mpBasePath = getFullPath(mealPlans); // /admin/meal-plans
    final String ctBasePath = getFullPath(catering); // /admin/catering
    final String stBasePath = getFullPath(settings); // /admin/settings
    final String pdSubroutePrefix =
        '$basePath$_pdPrefix/'; // /admin/product-dashboard/

    // Check Meal Plans first (most specific prefix)
    if (fullRoute.startsWith(mpBasePath)) {
      return 2; // Index for Meal Plans
    }

    // Check Catering
    if (fullRoute.startsWith(ctBasePath)) {
      return 3; // Index for Catering
    }

    // Check Settings
    if (fullRoute.startsWith(stBasePath)) {
      return 1; // Index for Settings
    }

    // Check Product Dashboard and its subroutes LAST
    // Matches /admin OR /admin/product-dashboard/...
    if (fullRoute == basePath || fullRoute.startsWith(pdSubroutePrefix)) {
      return 0; // Index for Product Dashboard
    }

    // Fallback if none match (e.g., /admin/setup) - default to 0 for ShellRoute context
    // Log this case if it happens unexpectedly during navigation
    // print("Warning: Route '$fullRoute' did not match any admin section, defaulting to index 0.");
    return 0;
  }
}

/// Admin router configuration based on the provided structure
List<RouteBase> getAdminRoutes() {
  return [
    // Wrapper route that shows the admin panel with shell navigation
    ShellRoute(
      builder: (context, state, child) {
        final currentRoute = state.matchedLocation;
        final index = AdminRoutes.getIndexFromRoute(currentRoute);
        // Add logging to see index calculation
        // print("ShellRoute builder: Route='$currentRoute', Calculated Index=$index");
        return AdminPanelScreen(
          initialIndex: index,
          child: child,
        );
      },
      routes: [
        // --- Product Dashboard Section (Index 0) ---
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.productDashboard), // /admin
          name: AdminRoutes.namePdHome,
          builder: (context, state) => const AdminDashboardHome(),
          routes: [
            // Products subroute
            GoRoute(
              // Path relative to parent '/admin', needs full prefix from base
              path:
                  'product-dashboard/products', // -> /admin/product-dashboard/products
              name: AdminRoutes.namePdProducts,
              builder: (context, state) => const ProductManagementScreen(),
            ),
            // Orders subroute
            GoRoute(
              path:
                  'product-dashboard/orders', // -> /admin/product-dashboard/orders
              name: AdminRoutes.namePdOrders,
              builder: (context, state) => const OrderManagementScreen(),
              routes: [
                // Order details subroute (relative to orders path)
                GoRoute(
                  path:
                      ':orderId', // -> /admin/product-dashboard/orders/:orderId
                  name: AdminRoutes.namePdOrderDetails,
                  builder: (context, state) {
                    final orderId = state.pathParameters['orderId'] ?? '';
                    return OrderDetailScreen(orderId: orderId);
                  },
                ),
              ],
            ),
            // Tables subroute
            GoRoute(
              path:
                  'product-dashboard/tables', // -> /admin/product-dashboard/tables
              name: AdminRoutes.namePdTables,
              builder: (context, state) => const TableManagementScreen(),
            ),
            // Analytics subroute
            GoRoute(
              path:
                  'product-dashboard/analytics', // -> /admin/product-dashboard/analytics
              name: AdminRoutes.namePdAnalytics,
              builder: (context, state) => const AnalyticsDashboard(),
            ),
          ],
        ),

        // --- Settings Section (Index 1) ---
        GoRoute(
          path:
              AdminRoutes.getFullPath(AdminRoutes.settings), // /admin/settings
          name: AdminRoutes.nameSettings,
          builder: (context, state) => const BusinessSettingsScreen(),
          routes: [
            // Users subroute (relative to settings path)
            GoRoute(
              path:
                  AdminRoutes.settingsUsers, // 'users' -> /admin/settings/users
              name: AdminRoutes.nameSettingsUsers,
              builder: (context, state) => const AdminManagementScreen(),
            ),
          ],
        ),

        // --- Meal Plans Section (Index 2) ---
        GoRoute(
          path: AdminRoutes.getFullPath(
              AdminRoutes.mealPlans), // /admin/meal-plans
          name: AdminRoutes.nameMpHome,
          // Builder for the main meal plans screen (parent route)
          // This assumes /admin/meal-plans shows the management screen
          builder: (context, state) => const MealPlanManagementScreen(),
          routes: [
            // Subroutes relative to /admin/meal-plans
            GoRoute(
              path: AdminRoutes.mealPlanManagement, // 'management'
              name: AdminRoutes.nameMpManagement,
              builder: (context, state) => const MealPlanManagementScreen(),
            ),
            GoRoute(
              path: AdminRoutes.mealPlanItems, // 'items'
              name: AdminRoutes.nameMpItems,
              builder: (context, state) => const MealPlanItemsScreen(),
            ),
            GoRoute(
              path: AdminRoutes.mealPlanAnalytics, // 'analytics'
              name: AdminRoutes.nameMpAnalytics,
              builder: (context, state) => const MealPlanAnalyticsScreen(),
            ),
            GoRoute(
              path: AdminRoutes.mealPlanExport, // 'export'
              name: AdminRoutes.nameMpExport,
              builder: (context, state) => const MealPlanExportScreen(),
            ),
            GoRoute(
              path: AdminRoutes.mealPlanScanner, // 'scanner'
              name: AdminRoutes.nameMpScanner,
              builder: (context, state) =>
                  MealPlanScanner(onMealPlanScanned: (_) {}),
            ),
            GoRoute(
              path: AdminRoutes.mealPlanPos, // 'pos'
              name: AdminRoutes.nameMpPos,
              builder: (context, state) =>
                  POSMealPlanWidget(onMealPlanUsed: (_) {}),
            ),
            GoRoute(
              path: AdminRoutes.mealPlanQr, // 'qr/:planId'
              name: AdminRoutes.nameMpQr,
              builder: (context, state) {
                final planId = state.pathParameters['planId'] ?? '';
                return MealPlanQRCode(mealPlanId: planId);
              },
            ),
          ],
        ),

        // --- Catering Section (Index 3) ---
        GoRoute(
          path:
              AdminRoutes.getFullPath(AdminRoutes.catering), // /admin/catering
          name: AdminRoutes.nameCtHome,
          // Builder for the main catering screen (parent route)
          // This assumes /admin/catering shows the management screen
          builder: (context, state) => const CateringManagementScreen(),
          routes: [
            // Subroutes relative to /admin/catering
            GoRoute(
              path: AdminRoutes.cateringDashboard, // 'dashboard'
              name: AdminRoutes.nameCtDashboard,
              builder: (context, state) => const CateringDashboardScreen(),
            ),
            GoRoute(
              path: AdminRoutes.cateringOrders, // 'orders'
              name: AdminRoutes.nameCtOrders,
              builder: (context, state) => const CateringOrdersScreen(),
            ),
            GoRoute(
              path: AdminRoutes.cateringPackages, // 'packages'
              name: AdminRoutes.nameCtPackages,
              builder: (context, state) => const CateringPackageScreen(),
            ),
            GoRoute(
              path: AdminRoutes.cateringItems, // 'items'
              name: AdminRoutes.nameCtItems,
              builder: (context, state) => const CateringItemScreen(),
            ),
            GoRoute(
              path: AdminRoutes.cateringCategories, // 'categories'
              name: AdminRoutes.nameCtCategories,
              builder: (context, state) => const CateringCategoryScreen(),
            ),
          ],
        ),
      ],
    ),

    // Setup screen outside the shell
    GoRoute(
      path: '/admin/setup', // Simple path
      name: AdminRoutes.nameAdminSetup,
      builder: (context, state) => const AdminSetupScreen(),
    ),
    // Define other top-level routes used elsewhere (login, profile, help, home)
    // GoRoute(path: '/login', name: AdminRoutes.nameLogin, builder: ...),
    // GoRoute(path: '/profile', name: AdminRoutes.nameProfile, builder: ...),
    // GoRoute(path: '/help', name: AdminRoutes.nameHelp, builder: ...),
    // GoRoute(path: '/', name: AdminRoutes.nameHome, builder: ...),
  ];
}
