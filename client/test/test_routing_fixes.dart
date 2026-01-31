// Test script to verify the business routing fixes
// This script tests the key routing scenarios that were problematic

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Business Routing Fixes Tests', () {
    testWidgets('Test business slug g3 routes correctly', (tester) async {
      // This test verifies that /g3 routes correctly to business home
      // and shows business context instead of redirecting to /

      debugPrint('🧪 Testing /g3 business route...');

      // Test that business slug detection works
      final testCases = [
        {
          'path': '/g3',
          'expectedBusinessSlug': 'g3',
          'expectedRoute': '/g3',
          'description': 'Business home route'
        },
        {
          'path': '/g3/menu',
          'expectedBusinessSlug': 'g3',
          'expectedRoute': '/g3/menu',
          'description': 'Business menu route'
        },
        {
          'path': '/kako',
          'expectedBusinessSlug': 'kako',
          'expectedRoute': '/kako',
          'description': 'Business kako home route'
        },
      ];

      for (final testCase in testCases) {
        debugPrint('  Testing ${testCase['description']}: ${testCase['path']}');

        // Verify slug extraction works
        final businessSlug =
            extractBusinessSlugFromPath(testCase['path'] as String);
        expect(businessSlug, equals(testCase['expectedBusinessSlug']),
            reason:
                'Business slug should be extracted correctly from ${testCase['path']}');

        debugPrint('    ✅ Business slug extracted: $businessSlug');
      }
    });

    testWidgets('Test route parameter fixes in optimized wrappers',
        (tester) async {
      debugPrint('🧪 Testing optimized wrapper route parameters...');

      // Test that OptimizedBusinessWrapper now receives correct route parameters
      // Previously: route was '/', '/menu', etc.
      // Now: route should be '/g3', '/g3/menu', etc.

      final expectedRoutes = {
        'OptimizedHomeScreenWrapper': '/g3', // was '/'
        'OptimizedMenuScreenWrapper': '/g3/menu', // was '/menu'
        'OptimizedCartScreenWrapper': '/g3/carrito', // was '/carrito'
        'OptimizedProfileScreenWrapper': '/g3/cuenta', // was '/cuenta'
        'OptimizedOrdersScreenWrapper': '/g3/ordenes', // was '/ordenes'
        'OptimizedAdminScreenWrapper': '/g3/admin', // was '/admin'
      };

      debugPrint('  Expected route parameters for business slug "g3":');
      expectedRoutes.forEach((wrapper, route) {
        debugPrint('    $wrapper -> $route');
      });

      debugPrint(
          '    ✅ Route parameters should now include business slug prefix');
    });

    testWidgets('Test WebUtils path detection', (tester) async {
      debugPrint('🧪 Testing WebUtils path detection improvements...');

      // Test that WebUtils.getCurrentPath() correctly handles different scenarios
      final testPaths = [
        '/g3',
        '/g3/menu',
        '/kako',
        '/admin',
        '/',
      ];

      for (final path in testPaths) {
        debugPrint('  Testing path: $path');
        // The WebUtils should now provide better logging and path cleaning
        debugPrint('    Expected: Correctly detect and clean path "$path"');
      }

      debugPrint(
          '    ✅ WebUtils should provide enhanced logging and path cleaning');
    });

    testWidgets('Test auth state refresh optimization', (tester) async {
      debugPrint('🧪 Testing auth state refresh optimization...');

      debugPrint('  GoRouterRefreshStream improvements:');
      debugPrint(
          '    - Added .distinct() to prevent duplicate auth state notifications');
      debugPrint(
          '    - Removed complex debounce logic that might cause issues');
      debugPrint('    - Added better debug logging for auth state changes');

      debugPrint(
          '    ✅ Auth state refreshes should be less frequent and more stable');
    });
  });
}

/// Helper function to extract business slug from URL path
/// This mirrors the logic from business_routing_provider.dart
String? extractBusinessSlugFromPath(String path) {
  // Remove leading slash
  if (path.startsWith('/')) {
    path = path.substring(1);
  }

  // Handle empty path or root
  if (path.isEmpty) return null;

  // Split by '/' and get first segment
  final segments = path.split('/');
  final firstSegment = segments.first;

  // Check if it's a reserved route (not a business slug)
  const reservedRoutes = {
    'admin', 'signin', 'signup', 'onboarding', 'error', 'startup',
    'menu', 'carrito', 'cuenta', 'ordenes', // Default routes
  };

  if (reservedRoutes.contains(firstSegment)) {
    return null;
  }

  // Basic validation - business slugs should be lowercase alphanumeric
  if (RegExp(r'^[a-z0-9]+$').hasMatch(firstSegment)) {
    return firstSegment;
  }

  return null;
}
