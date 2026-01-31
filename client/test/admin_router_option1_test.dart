// Test file to verify Option 1 admin navigation structure is working correctly
// This file validates that:
// 1. AdminRoutes has the correct 6-section structure (Dashboard, Payments, Staff, Meal Plans, Catering, Settings)
// 2. Dashboard contains Products, Orders, Tables, Analytics as subroutes
// 3. Route navigation and index mapping work correctly

import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';

void main() {
  group('AdminRoutes Option 1 Structure Tests', () {
    test('should have correct 6 top-level sections', () {
      // Test that we have 6 sections (0-5)
      expect(AdminRoutes.getPrimaryNamedRouteFromIndex(0),
          AdminRoutes.nameDashboard);
      expect(AdminRoutes.getPrimaryNamedRouteFromIndex(1),
          AdminRoutes.namePaymentsHome);
      expect(AdminRoutes.getPrimaryNamedRouteFromIndex(2),
          AdminRoutes.nameStaffHome);
      expect(
          AdminRoutes.getPrimaryNamedRouteFromIndex(3), AdminRoutes.nameMpHome);
      expect(
          AdminRoutes.getPrimaryNamedRouteFromIndex(4), AdminRoutes.nameCtHome);
      expect(AdminRoutes.getPrimaryNamedRouteFromIndex(5),
          AdminRoutes.nameSettings);

      // Test that index 6 and beyond fallback to dashboard
      expect(AdminRoutes.getPrimaryNamedRouteFromIndex(6),
          AdminRoutes.nameDashboard);
      expect(AdminRoutes.getPrimaryNamedRouteFromIndex(10),
          AdminRoutes.nameDashboard);
    });

    test('should correctly map route paths to indices', () {
      // Test main sections
      expect(AdminRoutes.getIndexFromRoute('/admin'), 0); // Dashboard
      expect(AdminRoutes.getIndexFromRoute('/admin/payments'), 1); // Payments
      expect(AdminRoutes.getIndexFromRoute('/admin/staff'), 2); // Staff
      expect(
          AdminRoutes.getIndexFromRoute('/admin/meal-plans'), 3); // Meal Plans
      expect(AdminRoutes.getIndexFromRoute('/admin/catering'), 4); // Catering
      expect(AdminRoutes.getIndexFromRoute('/admin/settings'), 5); // Settings

      // Test dashboard subroutes all map to dashboard (index 0)
      expect(AdminRoutes.getIndexFromRoute('/admin/products'),
          0); // Dashboard subroute
      expect(AdminRoutes.getIndexFromRoute('/admin/orders'),
          0); // Dashboard subroute
      expect(AdminRoutes.getIndexFromRoute('/admin/tables'),
          0); // Dashboard subroute
      expect(AdminRoutes.getIndexFromRoute('/admin/analytics'),
          0); // Dashboard subroute
    });

    test('should have correct path mappings', () {
      expect(AdminRoutes.getPathFromIndex(0), '/admin'); // Dashboard
      expect(AdminRoutes.getPathFromIndex(1), '/admin/payments'); // Payments
      expect(AdminRoutes.getPathFromIndex(2), '/admin/staff'); // Staff
      expect(
          AdminRoutes.getPathFromIndex(3), '/admin/meal-plans'); // Meal Plans
      expect(AdminRoutes.getPathFromIndex(4), '/admin/catering'); // Catering
      expect(AdminRoutes.getPathFromIndex(5), '/admin/settings'); // Settings

      // Test fallback
      expect(AdminRoutes.getPathFromIndex(10),
          '/admin'); // Should fallback to dashboard
    });

    test(
        'should have products, orders, tables, analytics as dashboard subroutes',
        () {
      // These should be subroute paths, not top-level
      expect(AdminRoutes.products, 'products'); // Relative path
      expect(AdminRoutes.orders, 'orders'); // Relative path
      expect(AdminRoutes.tables, 'tables'); // Relative path
      expect(AdminRoutes.analytics, 'analytics'); // Relative path

      // They should not start with '/' since they are subroutes
      expect(AdminRoutes.products.startsWith('/'), false);
      expect(AdminRoutes.orders.startsWith('/'), false);
      expect(AdminRoutes.tables.startsWith('/'), false);
      expect(AdminRoutes.analytics.startsWith('/'), false);
    });

    test('should have correct route names for dashboard subroutes', () {
      expect(AdminRoutes.nameProducts, 'products');
      expect(AdminRoutes.nameOrders, 'orders');
      expect(AdminRoutes.nameTables, 'tables');
      expect(AdminRoutes.nameAnalytics, 'analytics');
    });

    test('should have correct business route names', () {
      expect(AdminRoutes.nameBusinessDashboard, 'business-dashboard');
      expect(AdminRoutes.nameBusinessProducts, 'business-products');
      expect(AdminRoutes.nameBusinessOrders, 'business-orders');
      expect(AdminRoutes.nameBusinessTables, 'business-tables');
      expect(AdminRoutes.nameBusinessAnalytics, 'business-analytics');
    });
  });
}
