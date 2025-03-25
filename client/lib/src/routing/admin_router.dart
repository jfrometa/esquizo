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

/// This class defines all admin routes
class AdminRoutes {
  // Base admin path
  static const String basePath = '/admin';

  // Main admin module routes
  static const String dashboard = '';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String tables = '/tables';
  static const String users = '/users';
  static const String settings = '/settings';
  static const String analytics = '/analytics';
  static const String mealPlans = '/meal-plans';
  static const String catering = '/catering';

  // Order subroutes
  static const String orderDetails = '/orders/:orderId';

  // Catering subroutes
  static const String cateringDashboard = '/catering/dashboard';
  static const String cateringOrders = '/catering/orders';
  static const String cateringPackages = '/catering/packages';
  static const String cateringItems = '/catering/items';
  static const String cateringCategories = '/catering/categories';

  // Meal plan subroutes
  static const String mealPlanManagement = '/meal-plans/management';
  static const String mealPlanItems = '/meal-plans/items';
  static const String mealPlanAnalytics = '/meal-plans/analytics';
  static const String mealPlanExport = '/meal-plans/export';
  static const String mealPlanScanner = '/meal-plans/scanner';
  static const String mealPlanPos = '/meal-plans/pos';

  // Get full path by combining base path with relative path
  static String getFullPath(String relativePath) {
    return '$basePath$relativePath';
  }

  // Helper to get route from index
  static String getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return getFullPath(dashboard);
      case 1:
        return getFullPath(products);
      case 2:
        return getFullPath(orders);
      case 3:
        return getFullPath(tables);
      case 4:
        return getFullPath(users);
      case 5:
        return getFullPath(settings);
      case 6:
        return getFullPath(analytics);
      case 7:
        return getFullPath(mealPlans);
      case 8:
        return getFullPath(catering);
      default:
        return getFullPath(dashboard);
    }
  }

  // Helper to get index from route
  static int getIndexFromRoute(String route) {
    if (route.startsWith(getFullPath(products))) return 1;
    if (route.startsWith(getFullPath(orders))) return 2;
    if (route.startsWith(getFullPath(tables))) return 3;
    if (route.startsWith(getFullPath(users))) return 4;
    if (route.startsWith(getFullPath(settings))) return 5;
    if (route.startsWith(getFullPath(analytics))) return 6;
    if (route.startsWith(getFullPath(mealPlans))) return 7;
    if (route.startsWith(getFullPath(catering))) return 8;
    return 0; // Default to dashboard
  }
}

/// Admin router configuration to be used in the main app_router.dart
List<RouteBase> getAdminRoutes() {
  return [
    // Wrapper route that shows the admin panel with shell navigation
    ShellRoute(
      builder: (context, state, child) {
        // The index is determined by the current route
        final currentRoute = state.fullPath ?? '/admin';
        final index = AdminRoutes.getIndexFromRoute(currentRoute);

        return AdminPanelScreen(
          initialIndex: index,
          child: child,
        );
      },
      routes: [
        // Dashboard route (default)
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.dashboard),
          builder: (context, state) => const AdminDashboardHome(),
        ),

        // Products & Menu route
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.products),
          builder: (context, state) => const ProductManagementScreen(),
        ),

        // Orders route
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.orders),
          builder: (context, state) => const OrderManagementScreen(),
          routes: [
            GoRoute(
              path: ':orderId',
              builder: (context, state) {
                final orderId = state.pathParameters['orderId'] ?? '';
                return OrderDetailScreen(orderId: orderId);
              },
            ),
          ],
        ),

        // Tables route
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.tables),
          builder: (context, state) => const TableManagementScreen(),
        ),

        // Users & Staff route
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.users),
          builder: (context, state) => const AdminManagementScreen(),
        ),

        // Business Settings route
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.settings),
          builder: (context, state) => const BusinessSettingsScreen(),
        ),

        // Analytics route
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.analytics),
          builder: (context, state) => const AnalyticsDashboard(),
        ),

        // Meal Plans route and subroutes
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.mealPlans),
          builder: (context, state) => const MealPlanManagementScreen(),
          routes: [
            GoRoute(
              path: 'management',
              builder: (context, state) => const MealPlanManagementScreen(),
            ),
            GoRoute(
              path: 'items',
              builder: (context, state) => const MealPlanItemsScreen(),
            ),
            GoRoute(
              path: 'analytics',
              builder: (context, state) => const MealPlanAnalyticsScreen(),
            ),
            GoRoute(
              path: 'export',
              builder: (context, state) => const MealPlanExportScreen(),
            ),
            GoRoute(
              path: 'scanner',
              builder: (context, state) => MealPlanScanner(
                onMealPlanScanned: (_) {},
              ),
            ),
            GoRoute(
              path: 'pos',
              builder: (context, state) => POSMealPlanWidget(
                onMealPlanUsed: (_) {},
              ),
            ),
            // QR code requires a parameter
            GoRoute(
              path: 'qr/:planId',
              builder: (context, state) {
                final planId = state.pathParameters['planId'] ?? '';
                return MealPlanQRCode(mealPlanId: planId);
              },
            ),
          ],
        ),

        // Catering route and subroutes
        GoRoute(
          path: AdminRoutes.getFullPath(AdminRoutes.catering),
          builder: (context, state) => const CateringManagementScreen(),
          routes: [
            GoRoute(
              path: 'dashboard',
              builder: (context, state) => const CateringDashboardScreen(),
            ),
            GoRoute(
              path: 'orders',
              builder: (context, state) => const CateringOrdersScreen(),
            ),
            GoRoute(
              path: 'packages',
              builder: (context, state) => const CateringPackageScreen(),
            ),
            GoRoute(
              path: 'items',
              builder: (context, state) => const CateringItemScreen(),
            ),
            GoRoute(
              path: 'categories',
              builder: (context, state) => const CateringCategoryScreen(),
            ),
          ],
        ),
      ],
    ),

    // Setup screen outside the shell (doesn't use admin panel layout)
    GoRoute(
      path: '/admin/setup',
      builder: (context, state) => const AdminSetupScreen(),
    ),
  ];
}

// // Helper class for order details screen
// class OrderDetailScreen extends StatelessWidget {
//   final String orderId;

//   const OrderDetailScreen({super.key, required this.orderId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order #$orderId'),
//       ),
//       body: OrderDetailWidget(orderId: orderId),
//     );
//   }
// }
