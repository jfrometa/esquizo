import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_setup_screen.dart';
// Existing screen imports...
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/payment/order_payment_details_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/payment/payment_management_screen.dart'; // Add this import
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_dashboard_home.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_management/admin_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_panel_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/admin_setup_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/analytics_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_settings_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/order_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/product_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/staff/staff_order_entry_screen.dart';
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
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_order_details.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/screens/meal_plan_order_detail_screen.dart';

// --- Import Staff Screens ---
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/staff/staff_management_screen.dart';
// --- End Import ---

/// This class defines all admin routes based on a 6-section structure
class AdminRoutes {
  // Base admin path
  static const String basePath = '/admin';

  // --- Top Level Section Paths (relative) ---
  static const String dashboard =
      ''; // Represents /admin - main dashboard with subroutes
  static const String payments = '/payments'; // Payments section
  static const String staff = '/staff'; // Staff section
  static const String mealPlans = '/meal-plans'; // Meal Plans section
  static const String catering = '/catering'; // Catering section
  static const String settings = '/settings'; // Settings section

  // --- Dashboard Sub-Paths (relative to dashboard path) ---
  static const String products = 'products'; // Dashboard subroute
  static const String orders = 'orders'; // Dashboard subroute
  static const String tables = 'tables'; // Dashboard subroute
  static const String analytics = 'analytics'; // Dashboard subroute

  // --- Sub-Paths for specific sections ---
  // Orders sub-paths (relative to dashboard/orders path)
  static const String orderDetails = ':orderId';

  // Payments Sub-Paths (relative to payments path) ---
  static const String paymentsOverview = 'overview';
  static const String paymentsTransactions = 'transactions';
  static const String paymentsTips = 'tips';
  static const String paymentsTaxes = 'taxes';
  static const String paymentsService = 'service';
  static const String paymentsOrderDetails = 'order/:orderId';

  // --- Staff Sub-Paths (relative to staff path) ---
  static const String staffKitchen = 'kitchen';
  static const String staffWaiter = 'waiter';
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
  static const String mealPlanOrders = 'orders';

  // --- Named Routes ---
  // Dashboard (Main section with subroutes)
  static const String nameDashboard = 'dashboard';
  static const String nameProducts = 'products';
  static const String nameOrders = 'orders';
  static const String nameOrderDetails = 'order-details';
  static const String nameTables = 'tables';
  static const String nameAnalytics = 'analytics';

  // Payments (NEW separate section)
  static const String namePaymentsHome = 'payments-home';
  static const String namePaymentsOverview = 'payments-overview';
  static const String namePaymentsTransactions = 'payments-transactions';
  static const String namePaymentsTips = 'payments-tips';
  static const String namePaymentsTaxes = 'payments-taxes';
  static const String namePaymentsService = 'payments-service';
  static const String namePaymentsOrderDetails = 'payments-order-details';

  // Staff (NEW)
  static const String nameStaffHome = 'staff-home';
  static const String nameStaffOverview = 'staff-overview';
  static const String nameStaffKitchen = 'staff-kitchen';
  static const String nameStaffWaiter = 'staff-waiter';
  static const String nameStaffWaiterOrderEntry = 'staff-waiter-order-entry';
  // Settings
  static const String nameSettings = 'settings';
  static const String nameSettingsOverview = 'settings-overview';
  static const String nameSettingsUsers = 'settings-users';
  // Meal Plans
  static const String nameMpHome = 'meal-plans-home';
  static const String nameMpOverview = 'meal-plans-overview';
  static const String nameMpManagement = 'meal-plans-management';
  static const String nameMpItems = 'meal-plans-items';
  static const String nameMpAnalytics = 'meal-plans-analytics';
  static const String nameMpExport = 'meal-plans-export';
  static const String nameMpScanner = 'meal-plans-scanner';
  static const String nameMpPos = 'meal-plans-pos';
  static const String nameMpQr = 'meal-plans-qr';
  static const String nameMpOrders = 'meal-plans-orders';
  static const String nameMpOrderDetails = 'meal-plans-order-details';
  // Catering
  static const String nameCtHome = 'catering-home';
  static const String nameCtOverview = 'catering-overview';
  static const String nameCtDashboard = 'catering-dashboard';
  static const String nameCtOrders = 'catering-orders';
  static const String nameCtOrderDetails = 'catering-order-details';
  static const String nameCtPackages = 'catering-packages';
  static const String nameCtItems = 'catering-items';
  static const String nameCtCategories = 'catering-categories';
  // Others
  static const String nameAdminSetup = 'admin-setup';
  static const String nameLogin = 'login';
  static const String nameProfile = 'profile';
  static const String nameHelp = 'help';
  static const String nameHome = 'home';

  // --- Business-specific route names (to avoid conflicts with regular admin routes) ---
  // Dashboard (Main section with subroutes)
  static const String nameBusinessDashboard = 'business-dashboard';
  static const String nameBusinessProducts = 'business-products';
  static const String nameBusinessOrders = 'business-orders';
  static const String nameBusinessOrderDetails = 'business-order-details';
  static const String nameBusinessTables = 'business-tables';
  static const String nameBusinessAnalytics = 'business-analytics';

  // Payments (NEW)
  static const String nameBusinessPaymentsHome = 'business-payments-home';
  static const String nameBusinessPaymentsOverview =
      'business-payments-overview';
  static const String nameBusinessPaymentsTransactions =
      'business-payments-transactions';
  static const String nameBusinessPaymentsTips = 'business-payments-tips';
  static const String nameBusinessPaymentsTaxes = 'business-payments-taxes';
  static const String nameBusinessPaymentsService = 'business-payments-service';
  static const String nameBusinessPaymentsOrderDetails =
      'business-payments-order-details';

  // Staff
  static const String nameBusinessStaffHome = 'business-staff-home';
  static const String nameBusinessStaffOverview = 'business-staff-overview';
  static const String nameBusinessStaffKitchen = 'business-staff-kitchen';
  static const String nameBusinessStaffWaiter = 'business-staff-waiter';
  static const String nameBusinessStaffWaiterOrderEntry =
      'business-staff-waiter-order-entry';

  // Meal Plans
  static const String nameBusinessMpHome = 'business-meal-plans-home';
  static const String nameBusinessMpOverview = 'business-meal-plans-overview';
  static const String nameBusinessMpManagement =
      'business-meal-plans-management';
  static const String nameBusinessMpItems = 'business-meal-plans-items';
  static const String nameBusinessMpAnalytics = 'business-meal-plans-analytics';
  static const String nameBusinessMpExport = 'business-meal-plans-export';
  static const String nameBusinessMpScanner = 'business-meal-plans-scanner';
  static const String nameBusinessMpPos = 'business-meal-plans-pos';
  static const String nameBusinessMpQr = 'business-meal-plans-qr';
  static const String nameBusinessMpOrders = 'business-meal-plans-orders';
  static const String nameBusinessMpOrderDetails =
      'business-meal-plans-order-details';

  // Catering
  static const String nameBusinessCtHome = 'business-catering-home';
  static const String nameBusinessCtOverview = 'business-catering-overview';
  static const String nameBusinessCtDashboard = 'business-catering-dashboard';
  static const String nameBusinessCtOrders = 'business-catering-orders';
  static const String nameBusinessCtOrderDetails =
      'business-catering-order-details';
  static const String nameBusinessCtPackages = 'business-catering-packages';
  static const String nameBusinessCtItems = 'business-catering-items';
  static const String nameBusinessCtCategories = 'business-catering-categories';

  // Settings
  static const String nameBusinessSettings = 'business-settings';
  static const String nameBusinessSettingsOverview =
      'business-settings-overview';
  static const String nameBusinessSettingsUsers = 'business-settings-users';
  static const String nameBusinessSettingsEdit = 'business-settings-edit';
  // Get full path by combining base path with relative path
  static String getFullPath(String relativePath) {
    if (relativePath.isEmpty || relativePath == '/') return basePath;
    final String cleanRelative =
        relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    if (basePath == '/') return '/$cleanRelative';
    return '$basePath/$cleanRelative';
  }

  // Helper to get the primary named route for a section index (0-5) - REVERTED TO OPTION 1
  static String getPrimaryNamedRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return nameDashboard;
      case 1:
        return namePaymentsHome;
      case 2:
        return nameStaffHome;
      case 3:
        return nameMpHome;
      case 4:
        return nameCtHome;
      case 5:
        return nameSettings;
      default:
        return nameDashboard;
    }
  }

  // Helper to get index (0-5) from ANY valid admin route path - REVERTED TO OPTION 1
  static int getIndexFromRoute(String route) {
    final String fullRoute = route.startsWith('/') ? route : getFullPath(route);
    debugPrint('🔍 Getting admin index for route: "$fullRoute"');

    // Define full base paths for sections
    final String dashboardPath = getFullPath(dashboard); // /admin
    final String paymentsPath = getFullPath(payments); // /admin/payments
    final String staffPath = getFullPath(staff); // /admin/staff
    final String mealPlansPath = getFullPath(mealPlans); // /admin/meal-plans
    final String cateringPath = getFullPath(catering); // /admin/catering
    final String settingsPath = getFullPath(settings); // /admin/settings

    // Check each section in order (prioritize longer paths first)
    if (fullRoute.startsWith(mealPlansPath)) {
      debugPrint('✅ Route matches meal plans section, index: 3');
      return 3; // Index for Meal Plans
    }

    if (fullRoute.startsWith(paymentsPath)) {
      debugPrint('✅ Route matches payments section, index: 1');
      return 1; // Index for Payments
    }

    if (fullRoute.startsWith(settingsPath)) {
      debugPrint('✅ Route matches settings section, index: 5');
      return 5; // Index for Settings
    }

    if (fullRoute.startsWith(cateringPath)) {
      debugPrint('✅ Route matches catering section, index: 4');
      return 4; // Index for Catering
    }

    if (fullRoute.startsWith(staffPath)) {
      debugPrint('✅ Route matches staff section, index: 2');
      return 2; // Index for Staff
    }

    // Check Dashboard (exact match or base path or dashboard subroutes)
    if (fullRoute == dashboardPath ||
        fullRoute.startsWith(dashboardPath + '/')) {
      debugPrint('✅ Route matches dashboard section, index: 0');
      return 0; // Index for Dashboard
    }

    // Fallback
    debugPrint('⚠️ No section match found for route, using default index: 0');
    return 0;
  }

  // Helper to get the path for a given section index
  static String getPathFromIndex(int index) {
    switch (index) {
      case 0:
        return getFullPath(dashboard); // Dashboard
      case 1:
        return getFullPath(payments); // Payments
      case 2:
        return getFullPath(staff); // Staff
      case 3:
        return getFullPath(mealPlans); // Meal plans
      case 4:
        return getFullPath(catering); // Catering
      case 5:
        return getFullPath(settings); // Settings
      default:
        return getFullPath(dashboard);
    }
  }
}

/// Admin router configuration based on Option 1 structure - REVERTED
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
        // --- Dashboard Section (Index 0) with subroutes ---
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.dashboard), // /admin
          name: AdminRoutes.nameDashboard,
          builder: (context, state) => const AdminDashboardHome(),
          routes: [
            // Products subroute
            GoRoute(
              path: AdminRoutes.products, // products
              name: AdminRoutes.nameProducts,
              builder: (context, state) => const ProductManagementScreen(),
            ),
            // Orders subroute
            GoRoute(
              path: AdminRoutes.orders, // orders
              name: AdminRoutes.nameOrders,
              builder: (context, state) => const OrderManagementScreen(),
              routes: [
                GoRoute(
                  path: AdminRoutes.orderDetails, // :orderId
                  name: AdminRoutes.nameOrderDetails,
                  builder: (context, state) => OrderDetailScreen(
                    orderId: state.pathParameters['orderId'] ?? '',
                  ),
                ),
              ],
            ),
            // Tables subroute
            GoRoute(
              path: AdminRoutes.tables, // tables
              name: AdminRoutes.nameTables,
              builder: (context, state) => const TableManagementScreen(),
            ),
            // Analytics subroute
            GoRoute(
              path: AdminRoutes.analytics, // analytics
              name: AdminRoutes.nameAnalytics,
              builder: (context, state) => const AnalyticsDashboard(),
            ),
          ],
        ),

        // --- Payments Section (Index 1) ---
        GoRoute(
          path:
              AdminRoutes.getFullPath(AdminRoutes.payments), // /admin/payments
          name: AdminRoutes.namePaymentsHome,
          builder: (context, state) => const PaymentManagementScreen(),
          routes: [
            GoRoute(
              path: AdminRoutes.paymentsOverview,
              name: AdminRoutes.namePaymentsOverview,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 0),
            ),
            GoRoute(
              path: AdminRoutes.paymentsTransactions,
              name: AdminRoutes.namePaymentsTransactions,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 1),
            ),
            GoRoute(
              path: AdminRoutes.paymentsTips,
              name: AdminRoutes.namePaymentsTips,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 2),
            ),
            GoRoute(
              path: AdminRoutes.paymentsTaxes,
              name: AdminRoutes.namePaymentsTaxes,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 3),
            ),
            GoRoute(
              path: AdminRoutes.paymentsService,
              name: AdminRoutes.namePaymentsService,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 4),
            ),
            GoRoute(
              path: AdminRoutes.paymentsOrderDetails,
              name: AdminRoutes.namePaymentsOrderDetails,
              builder: (context, state) => OrderPaymentDetailsScreen(
                orderId: state.pathParameters['orderId'] ?? '',
              ),
            ),
          ],
        ),

        // --- Staff Section (Index 2) ---
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.staff), // /admin/staff
          name: AdminRoutes.nameStaffHome,
          builder: (context, state) => const StaffManagementScreen(),
          routes: [
            GoRoute(
              path: 'overview',
              name: AdminRoutes.nameStaffOverview,
              builder: (context, state) => const StaffManagementScreen(),
            ),
            GoRoute(
              path: 'kitchen',
              name: AdminRoutes.nameStaffKitchen,
              builder: (context, state) =>
                  const StaffManagementScreen(initialIndex: 0),
            ),
            GoRoute(
              path: 'waiter',
              name: AdminRoutes.nameStaffWaiter,
              builder: (context, state) =>
                  const StaffManagementScreen(initialIndex: 1),
            ),
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

        // --- Meal Plans Section (Index 3) ---
        GoRoute(
          path: AdminRoutes.getFullPath(
              AdminRoutes.mealPlans), // /admin/meal-plans
          name: AdminRoutes.nameMpHome,
          builder: (context, state) => const MealPlanManagementScreen(),
          routes: [
            GoRoute(
              path: 'overview',
              name: AdminRoutes.nameMpOverview,
              builder: (context, state) => const MealPlanManagementScreen(),
            ),
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
              path: AdminRoutes.mealPlanOrders,
              name: AdminRoutes.nameMpOrders,
              builder: (context, state) => const MealPlanItemsScreen(),
              routes: [
                GoRoute(
                  path: ':orderId',
                  name: AdminRoutes.nameMpOrderDetails,
                  builder: (context, state) => MealPlanOrderDetailScreen(
                    orderId: state.pathParameters['orderId'] ?? '',
                  ),
                ),
              ],
            ),
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

        // --- Catering Section (Index 4) ---
        GoRoute(
          path:
              AdminRoutes.getFullPath(AdminRoutes.catering), // /admin/catering
          name: AdminRoutes.nameCtHome,
          builder: (context, state) => const CateringManagementScreen(),
          routes: [
            GoRoute(
              path: 'overview',
              name: AdminRoutes.nameCtOverview,
              builder: (context, state) => const CateringManagementScreen(),
            ),
            GoRoute(
                path: AdminRoutes.cateringDashboard,
                name: AdminRoutes.nameCtDashboard,
                builder: (context, state) => const CateringDashboardScreen()),
            GoRoute(
              path: AdminRoutes.cateringOrders,
              name: AdminRoutes.nameCtOrders,
              builder: (context, state) => const CateringOrdersScreen(),
              routes: [
                GoRoute(
                  path: ':orderId',
                  name: AdminRoutes.nameCtOrderDetails,
                  builder: (context, state) => CateringOrderDetailsScreen(
                    orderId: state.pathParameters['orderId'] ?? '',
                  ),
                ),
              ],
            ),
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

        // --- Settings Section (Index 5) ---
        GoRoute(
          path:
              AdminRoutes.getFullPath(AdminRoutes.settings), // /admin/settings
          name: AdminRoutes.nameSettings,
          builder: (context, state) => const BusinessSettingsScreen(),
          routes: [
            GoRoute(
              path: 'overview',
              name: AdminRoutes.nameSettingsOverview,
              builder: (context, state) => const BusinessSettingsScreen(),
            ),
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

/// Helper function to get business-slugged admin routes - REVERTED TO OPTION 1
List<RouteBase> getBusinessSluggedAdminRoutes() {
  debugPrint('🏗️ Building business-slugged admin routes');

  return [
    ShellRoute(
      builder: (context, state, child) {
        final businessSlug = state.pathParameters['businessSlug'] ?? '';
        final currentRoute =
            state.uri.path; // Use full URI path instead of matchedLocation
        debugPrint(
            '🔄 BusinessAdminShellRoute: $businessSlug, route: "$currentRoute"');

        // Remove business slug from route for index calculation
        final routeWithoutSlug = businessSlug.isNotEmpty
            ? currentRoute.replaceFirst('/$businessSlug', '')
            : currentRoute;
        final index = AdminRoutes.getIndexFromRoute(routeWithoutSlug);

        return AdminPanelScreen(
          initialIndex: index,
          businessSlug: businessSlug,
          child: child,
        );
      },
      routes: [
        // --- Dashboard Section (Index 0) with subroutes ---
        GoRoute(
          path: 'admin', // This becomes /:businessSlug/admin
          name: AdminRoutes.nameBusinessDashboard,
          builder: (context, state) => const AdminDashboardHome(),
          routes: [
            // Products subroute
            GoRoute(
              path: AdminRoutes.products, // products
              name: AdminRoutes.nameBusinessProducts,
              builder: (context, state) => const ProductManagementScreen(),
            ),
            // Orders subroute
            GoRoute(
              path: AdminRoutes.orders, // orders
              name: AdminRoutes.nameBusinessOrders,
              builder: (context, state) => const OrderManagementScreen(),
              routes: [
                GoRoute(
                  path: AdminRoutes.orderDetails, // :orderId
                  name: AdminRoutes.nameBusinessOrderDetails,
                  builder: (context, state) => OrderDetailScreen(
                    orderId: state.pathParameters['orderId'] ?? '',
                  ),
                ),
              ],
            ),
            // Tables subroute
            GoRoute(
              path: AdminRoutes.tables, // tables
              name: AdminRoutes.nameBusinessTables,
              builder: (context, state) => const TableManagementScreen(),
            ),
            // Analytics subroute
            GoRoute(
              path: AdminRoutes.analytics, // analytics
              name: AdminRoutes.nameBusinessAnalytics,
              builder: (context, state) => const AnalyticsDashboard(),
            ),
          ],
        ),

        // --- Payments Section (Index 1) ---
        GoRoute(
          path: 'admin/payments', // This becomes /:businessSlug/admin/payments
          name: AdminRoutes.nameBusinessPaymentsHome,
          builder: (context, state) => const PaymentManagementScreen(),
          routes: [
            GoRoute(
              path: AdminRoutes.paymentsOverview,
              name: AdminRoutes.nameBusinessPaymentsOverview,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 0),
            ),
            GoRoute(
              path: AdminRoutes.paymentsTransactions,
              name: AdminRoutes.nameBusinessPaymentsTransactions,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 1),
            ),
            GoRoute(
              path: AdminRoutes.paymentsTips,
              name: AdminRoutes.nameBusinessPaymentsTips,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 2),
            ),
            GoRoute(
              path: AdminRoutes.paymentsTaxes,
              name: AdminRoutes.nameBusinessPaymentsTaxes,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 3),
            ),
            GoRoute(
              path: AdminRoutes.paymentsService,
              name: AdminRoutes.nameBusinessPaymentsService,
              builder: (context, state) =>
                  const PaymentManagementScreen(initialTab: 4),
            ),
            GoRoute(
              path: AdminRoutes.paymentsOrderDetails,
              name: AdminRoutes.nameBusinessPaymentsOrderDetails,
              builder: (context, state) => OrderPaymentDetailsScreen(
                orderId: state.pathParameters['orderId'] ?? '',
              ),
            ),
          ],
        ),
        // --- End Payments Section ---

        // --- Staff Section (Index 2) ---
        GoRoute(
          path: 'admin/staff', // This becomes /:businessSlug/admin/staff
          name: AdminRoutes.nameBusinessStaffHome,
          builder: (context, state) => const StaffManagementScreen(),
          routes: [
            // Overview route for Staff section
            GoRoute(
              path: 'overview',
              name: AdminRoutes.nameBusinessStaffOverview,
              builder: (context, state) => const StaffManagementScreen(),
            ),
            // Kitchen management route
            GoRoute(
              path: 'kitchen',
              name: AdminRoutes.nameBusinessStaffKitchen,
              builder: (context, state) =>
                  const StaffManagementScreen(initialIndex: 0),
            ),
            // Waiter management route
            GoRoute(
              path: 'waiter',
              name: AdminRoutes.nameBusinessStaffWaiter,
              builder: (context, state) =>
                  const StaffManagementScreen(initialIndex: 1),
            ),
            // Order entry route for waiter flow
            GoRoute(
              path: 'table/:tableId/order',
              name: AdminRoutes.nameBusinessStaffWaiterOrderEntry,
              builder: (context, state) {
                final tableId = state.pathParameters['tableId'] ?? 'unknown';
                return StaffOrderEntryScreen(tableId: tableId);
              },
            ),
          ],
        ),

        // --- Meal Plans Section (Index 3) ---
        GoRoute(
          path:
              'admin/meal-plans', // This becomes /:businessSlug/admin/meal-plans
          name: AdminRoutes.nameBusinessMpHome,
          builder: (context, state) => const MealPlanManagementScreen(),
          routes: [
            // Overview route for Meal Plans section
            GoRoute(
              path: 'overview',
              name: AdminRoutes.nameBusinessMpOverview,
              builder: (context, state) => const MealPlanManagementScreen(),
            ),
            GoRoute(
                path: AdminRoutes.mealPlanManagement,
                name: AdminRoutes.nameBusinessMpManagement,
                builder: (context, state) => const MealPlanManagementScreen()),
            GoRoute(
                path: AdminRoutes.mealPlanItems,
                name: AdminRoutes.nameBusinessMpItems,
                builder: (context, state) => const MealPlanItemsScreen()),
            GoRoute(
                path: AdminRoutes.mealPlanAnalytics,
                name: AdminRoutes.nameBusinessMpAnalytics,
                builder: (context, state) => const MealPlanAnalyticsScreen()),
            GoRoute(
                path: AdminRoutes.mealPlanExport,
                name: AdminRoutes.nameBusinessMpExport,
                builder: (context, state) => const MealPlanExportScreen()),
            GoRoute(
              path: AdminRoutes.mealPlanOrders,
              name: AdminRoutes.nameBusinessMpOrders,
              builder: (context, state) => const MealPlanItemsScreen(),
              routes: [
                GoRoute(
                  path: ':orderId',
                  name: AdminRoutes.nameBusinessMpOrderDetails,
                  builder: (context, state) => MealPlanOrderDetailScreen(
                    orderId: state.pathParameters['orderId'] ?? '',
                  ),
                ),
              ],
            ),
            GoRoute(
                path: AdminRoutes.mealPlanScanner,
                name: AdminRoutes.nameBusinessMpScanner,
                builder: (context, state) =>
                    MealPlanScanner(onMealPlanScanned: (_) {})),
            GoRoute(
                path: AdminRoutes.mealPlanPos,
                name: AdminRoutes.nameBusinessMpPos,
                builder: (context, state) =>
                    POSMealPlanWidget(onMealPlanUsed: (_) {})),
            GoRoute(
                path: AdminRoutes.mealPlanQr,
                name: AdminRoutes.nameBusinessMpQr,
                builder: (context, state) => MealPlanQRCode(
                    mealPlanId: state.pathParameters['planId'] ?? '')),
          ],
        ),

        // --- Catering Section (Index 4) ---
        GoRoute(
          path: 'admin/catering', // This becomes /:businessSlug/admin/catering
          name: AdminRoutes.nameBusinessCtHome,
          builder: (context, state) => const CateringManagementScreen(),
          routes: [
            // Overview route for Catering section
            GoRoute(
              path: 'overview',
              name: AdminRoutes.nameBusinessCtOverview,
              builder: (context, state) => const CateringManagementScreen(),
            ),
            GoRoute(
                path: AdminRoutes.cateringDashboard,
                name: AdminRoutes.nameBusinessCtDashboard,
                builder: (context, state) => const CateringDashboardScreen()),
            GoRoute(
              path: AdminRoutes.cateringOrders,
              name: AdminRoutes.nameBusinessCtOrders,
              builder: (context, state) => const CateringOrdersScreen(),
              routes: [
                GoRoute(
                  path: ':orderId',
                  name: AdminRoutes.nameBusinessCtOrderDetails,
                  builder: (context, state) => CateringOrderDetailsScreen(
                    orderId: state.pathParameters['orderId'] ?? '',
                  ),
                ),
              ],
            ),
            GoRoute(
                path: AdminRoutes.cateringPackages,
                name: AdminRoutes.nameBusinessCtPackages,
                builder: (context, state) => const CateringPackageScreen()),
            GoRoute(
                path: AdminRoutes.cateringItems,
                name: AdminRoutes.nameBusinessCtItems,
                builder: (context, state) => const CateringItemScreen()),
            GoRoute(
                path: AdminRoutes.cateringCategories,
                name: AdminRoutes.nameBusinessCtCategories,
                builder: (context, state) => const CateringCategoryScreen()),
          ],
        ),

        // --- Settings Section (Index 5) ---
        GoRoute(
          path: 'admin/settings', // This becomes /:businessSlug/admin/settings
          name: AdminRoutes.nameBusinessSettings,
          builder: (context, state) => const BusinessSettingsScreen(),
          routes: [
            // Overview route for Settings section
            GoRoute(
              path: 'overview',
              name: AdminRoutes.nameBusinessSettingsOverview,
              builder: (context, state) => const BusinessSettingsScreen(),
            ),
            GoRoute(
                path: AdminRoutes.settingsUsers,
                name: AdminRoutes.nameBusinessSettingsUsers,
                builder: (context, state) => const AdminManagementScreen()),
            // Add edit route for business settings
            GoRoute(
                path: 'edit',
                name: AdminRoutes.nameBusinessSettingsEdit,
                builder: (context, state) => const BusinessSetupScreen()),
          ],
        ),
      ],
    ),
  ];
}
