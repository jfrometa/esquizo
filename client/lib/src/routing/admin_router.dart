import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Existing screen imports...
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/payment/order_payment_details_screen.dart';
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
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/meal_plan_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_items_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_analytics_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/meal_plan_export.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_qr_code.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/staff/pos_meal_plan_scanner.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/widgets/staff/pos_meal_plan_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/catering_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_dashboard_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_order_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_package_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_item_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_category_screen.dart';

// --- Import Staff Screens ---
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/staff/staff_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/staff/staff_order_entry_screen.dart';
// --- End Import ---

/// This class defines all admin routes based on a 5-section structure
class AdminRoutes {
  // Base admin path
  static const String basePath = '/admin';

  // --- Top Level Section Paths (relative) ---
  static const String productDashboard = ''; // Represents /admin
  static const String staff = '/staff'; // NEW: Represents /admin/staff
  static const String mealPlans = '/meal-plans'; // Represents /admin/meal-plans
  static const String catering = '/catering'; // Represents /admin/catering
  static const String settings = '/settings'; // Represents /admin/settings

  // --- Product Dashboard Sub-Paths (relative to basePath) ---
  static const String _pdPrefix = '/product-dashboard';
  static const String dashboardProducts = '$_pdPrefix/products';
  static const String dashboardOrders = '$_pdPrefix/orders';
  static const String dashboardTables = '$_pdPrefix/tables';
  static const String dashboardAnalytics = '$_pdPrefix/analytics';
  static const String dashboardOrderDetails = '$_pdPrefix/orders/:orderId';

  // --- Staff Sub-Paths (relative to staff path) ---
  static const String staffWaiterOrderEntry = 'table/:tableId/order';

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

  // --- Named Routes ---
  // Product Dashboard
  static const String namePdHome = 'product-dashboard-home';
  static const String namePdProducts = 'product-dashboard-products';
  static const String namePdOrders = 'product-dashboard-orders';
  static const String namePdOrderDetails = 'product-dashboard-order-details';
  static const String namePdOrderPaymentDetails =
      'product-dashboard-order-payment-details';
  static const String namePdTables = 'product-dashboard-tables';
  static const String namePdAnalytics = 'product-dashboard-analytics';
  // Staff (NEW)
  static const String nameStaffHome = 'staff-home';
  static const String nameStaffWaiterOrderEntry = 'staff-waiter-order-entry';
  // Settings
  static const String nameSettings = 'settings';
  static const String nameSettingsUsers = 'settings-users';
  // Meal Plans
  static const String nameMpHome = 'meal-plans-home';
  static const String nameMpManagement = 'meal-plans-management';
  static const String nameMpItems = 'meal-plans-items';
  static const String nameMpAnalytics = 'meal-plans-analytics';
  static const String nameMpExport = 'meal-plans-export';
  static const String nameMpScanner = 'meal-plans-scanner';
  static const String nameMpPos = 'meal-plans-pos';
  static const String nameMpQr = 'meal-plans-qr';
  // Catering
  static const String nameCtHome = 'catering-home';
  static const String nameCtDashboard = 'catering-dashboard';
  static const String nameCtOrders = 'catering-orders';
  static const String nameCtPackages = 'catering-packages';
  static const String nameCtItems = 'catering-items';
  static const String nameCtCategories = 'catering-categories';
  // Others
  static const String nameAdminSetup = 'admin-setup';
  static const String nameLogin = 'login';
  static const String nameProfile = 'profile';
  static const String nameHelp = 'help';
  static const String nameHome = 'home';

  // Get full path by combining base path with relative path
  static String getFullPath(String relativePath) {
    if (relativePath.isEmpty || relativePath == '/') return basePath;
    final String cleanRelative =
        relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    if (basePath == '/') return '/$cleanRelative';
    return '$basePath/$cleanRelative';
  }

  // Helper to get the primary named route for a section index (0-4) - UPDATED
  static String getPrimaryNamedRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return namePdHome;
      case 1:
        return nameStaffHome; // NEW
      case 2:
        return nameMpHome;
      case 3:
        return nameCtHome;
      case 4:
        return nameSettings;
      default:
        return namePdHome;
    }
  }

  // Helper to get index (0-4) from ANY valid admin route path - UPDATED
  static int getIndexFromRoute(String route) {
    final String fullRoute = route.startsWith('/') ? route : getFullPath(route);
    debugPrint('🔍 Getting admin index for route: "$fullRoute"');

    // Define full base paths for sections
    final String sfBasePath = getFullPath(staff); // /admin/staff
    final String mpBasePath = getFullPath(mealPlans); // /admin/meal-plans
    final String ctBasePath = getFullPath(catering); // /admin/catering
    final String stBasePath = getFullPath(settings); // /admin/settings
    final String pdSubroutePrefix =
        '$basePath$_pdPrefix/'; // /admin/product-dashboard/

    // Check Staff section first (NEW)
    if (fullRoute.startsWith(sfBasePath)) {
      debugPrint('✅ Route matches staff section, index: 1');
      return 1; // Index for Staff
    }

    // Check Meal Plans
    if (fullRoute.startsWith(mpBasePath)) {
      debugPrint('✅ Route matches meal plans section, index: 2');
      return 2; // Index for Meal Plans
    }

    // Check Catering
    if (fullRoute.startsWith(ctBasePath)) {
      debugPrint('✅ Route matches catering section, index: 3');
      return 3; // Index for Catering
    }

    // Check Settings
    if (fullRoute.startsWith(stBasePath)) {
      debugPrint('✅ Route matches settings section, index: 4');
      return 4; // Index for Settings
    }

    // Check Product Dashboard and its subroutes LAST
    if (fullRoute == basePath || fullRoute.startsWith(pdSubroutePrefix)) {
      debugPrint('✅ Route matches product dashboard section, index: 0');
      return 0; // Index for Product Dashboard
    }

    // Fallback
    debugPrint('⚠️ No section match found for route, using default index: 0');
    return 0;
  }

  // Helper to get the path for a given section index
  static String getPathFromIndex(int index) {
    switch (index) {
      case 0:
        return basePath; // Product dashboard
      case 1:
        return getFullPath(staff); // Staff
      case 2:
        return getFullPath(mealPlans); // Meal plans
      case 3:
        return getFullPath(catering); // Catering
      case 4:
        return getFullPath(settings); // Settings
      default:
        return basePath;
    }
  }
}

/// Admin router configuration based on the provided structure - UPDATED
List<RouteBase> getAdminRoutes() {
  debugPrint('🏗️ Building admin routes');

  return [
    // Wrapper route that shows the admin panel with shell navigation
    ShellRoute(
      builder: (context, state, child) {
        final currentRoute = state.matchedLocation;
        debugPrint('🔄 AdminShellRoute: Current route: "$currentRoute"');
        final index = AdminRoutes.getIndexFromRoute(currentRoute);
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
            GoRoute(
                path: 'product-dashboard/products',
                name: AdminRoutes.namePdProducts,
                builder: (context, state) => const ProductManagementScreen()),
            GoRoute(
              path: 'product-dashboard/orders',
              name: AdminRoutes.namePdOrders,
              builder: (context, state) => const OrderManagementScreen(),
              routes: [
                GoRoute(
                    path: ':orderId',
                    name: AdminRoutes.namePdOrderDetails,
                    builder: (context, state) => OrderDetailScreen(
                        orderId: state.pathParameters['orderId'] ?? '')),
              ],
            ),
            GoRoute(
                path: 'product-dashboard/tables',
                name: AdminRoutes.namePdTables,
                builder: (context, state) => const TableManagementScreen()),
            GoRoute(
                path: 'product-dashboard/analytics',
                name: AdminRoutes.namePdAnalytics,
                builder: (context, state) => const AnalyticsDashboard()),
            GoRoute(
              path: ':orderId/payment',
              name: AdminRoutes
                  .namePdOrderPaymentDetails, //'product-dashboard-order-payment-details',
              builder: (context, state) => OrderPaymentDetailsScreen(
                orderId: state.pathParameters['orderId'] ?? '',
              ),
            ),
          ],
        ),

        // --- Staff Section (Index 1) --- NEW ---
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.staff), // /admin/staff
          name: AdminRoutes.nameStaffHome,
          builder: (context, state) => const StaffManagementScreen(),
          routes: [
            // Order entry route for waiter flow
            GoRoute(
              path: 'table/:tableId/order',
              name: AdminRoutes.nameStaffWaiterOrderEntry,
              builder: (context, state) {
                final tableId = state.pathParameters['tableId'] ?? 'unknown';
                return StaffOrderEntryScreen(tableId: tableId);
              },
            ),
          ],
        ),
        // --- End Staff Section ---

        // --- Meal Plans Section (Index 2) ---
        GoRoute(
          path: AdminRoutes.getFullPath(
              AdminRoutes.mealPlans), // /admin/meal-plans
          name: AdminRoutes.nameMpHome,
          builder: (context, state) => const MealPlanManagementScreen(),
          routes: [
            GoRoute(
                path: AdminRoutes.mealPlanManagement,
                name: AdminRoutes.nameMpManagement,
                builder: (context, state) => const MealPlanManagementScreen()),
            GoRoute(
                path: AdminRoutes.mealPlanItems,
                name: AdminRoutes.nameMpItems,
                builder: (context, state) => const MealPlanItemsScreen()),
            GoRoute(
                path: AdminRoutes.mealPlanAnalytics,
                name: AdminRoutes.nameMpAnalytics,
                builder: (context, state) => const MealPlanAnalyticsScreen()),
            GoRoute(
                path: AdminRoutes.mealPlanExport,
                name: AdminRoutes.nameMpExport,
                builder: (context, state) => const MealPlanExportScreen()),
            GoRoute(
                path: AdminRoutes.mealPlanScanner,
                name: AdminRoutes.nameMpScanner,
                builder: (context, state) =>
                    MealPlanScanner(onMealPlanScanned: (_) {})),
            GoRoute(
                path: AdminRoutes.mealPlanPos,
                name: AdminRoutes.nameMpPos,
                builder: (context, state) =>
                    POSMealPlanWidget(onMealPlanUsed: (_) {})),
            GoRoute(
                path: AdminRoutes.mealPlanQr,
                name: AdminRoutes.nameMpQr,
                builder: (context, state) => MealPlanQRCode(
                    mealPlanId: state.pathParameters['planId'] ?? '')),
          ],
        ),

        // --- Catering Section (Index 3) ---
        GoRoute(
          path:
              AdminRoutes.getFullPath(AdminRoutes.catering), // /admin/catering
          name: AdminRoutes.nameCtHome,
          builder: (context, state) => const CateringManagementScreen(),
          routes: [
            GoRoute(
                path: AdminRoutes.cateringDashboard,
                name: AdminRoutes.nameCtDashboard,
                builder: (context, state) => const CateringDashboardScreen()),
            GoRoute(
                path: AdminRoutes.cateringOrders,
                name: AdminRoutes.nameCtOrders,
                builder: (context, state) => const CateringOrdersScreen()),
            GoRoute(
                path: AdminRoutes.cateringPackages,
                name: AdminRoutes.nameCtPackages,
                builder: (context, state) => const CateringPackageScreen()),
            GoRoute(
                path: AdminRoutes.cateringItems,
                name: AdminRoutes.nameCtItems,
                builder: (context, state) => const CateringItemScreen()),
            GoRoute(
                path: AdminRoutes.cateringCategories,
                name: AdminRoutes.nameCtCategories,
                builder: (context, state) => const CateringCategoryScreen()),
          ],
        ),

        // --- Settings Section (Index 4) ---
        GoRoute(
          path:
              AdminRoutes.getFullPath(AdminRoutes.settings), // /admin/settings
          name: AdminRoutes.nameSettings,
          builder: (context, state) => const BusinessSettingsScreen(),
          routes: [
            GoRoute(
                path: AdminRoutes.settingsUsers,
                name: AdminRoutes.nameSettingsUsers,
                builder: (context, state) => const AdminManagementScreen()),
          ],
        ),
      ],
    ),

    // Setup screen outside the shell
    GoRoute(
      path: '/admin/setup',
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
