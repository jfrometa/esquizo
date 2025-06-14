// Business API Routing Demonstration
// This script shows how the app automatically uses the correct business ID for API calls
// based on the URL path.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';

void main() {
  group('Business API Routing Demo', () {
    test('URL path extraction works correctly', () {
      // Test different URL patterns
      final testCases = [
        // [url_path, expected_business_slug]
        ['/', null], // Default business
        ['/menu', null], // Default business
        ['/carrito', null], // Default business
        ['/kako', 'kako'], // Kako business
        ['/kako/menu', 'kako'], // Kako business - menu page
        ['/kako/carrito', 'kako'], // Kako business - cart page
        ['/g3', 'g3'], // G3 business
        ['/g3/admin', 'g3'], // G3 business - admin page
        ['/admin', null], // System route, not business
        ['/signin', null], // System route, not business
      ];

      for (final testCase in testCases) {
        final path = testCase[0] as String;
        final expectedSlug = testCase[1] as String?;
        final actualSlug = extractBusinessSlugFromPath(path);

        debugPrint('Path: "$path" → Business Slug: "$actualSlug"');
        expect(actualSlug, equals(expectedSlug),
            reason: 'Failed for path: $path');
      }
    });

    test('Business slug validation works correctly', () {
      final validSlugs = [
        'kako',
        'g3',
        'restaurant-123',
        'my-business',
        'cafe2024',
      ];

      final invalidSlugs = [
        'a', // Too short
        'admin', // System route
        'menu', // System route
        'My Business', // Contains spaces
        'test@business', // Invalid characters
        '-invalid', // Starts with hyphen
        'invalid-', // Ends with hyphen
        'test--double', // Double hyphens
      ];

      for (final slug in validSlugs) {
        final isValid = _isValidBusinessSlug(slug);
        debugPrint('Valid slug: "$slug" → $isValid');
        expect(isValid, isTrue, reason: 'Should be valid: $slug');
      }

      for (final slug in invalidSlugs) {
        final isValid = _isValidBusinessSlug(slug);
        debugPrint('Invalid slug: "$slug" → $isValid');
        expect(isValid, isFalse, reason: 'Should be invalid: $slug');
      }
    });

    test('API path construction demonstration', () {
      final businessCases = [
        ['default', 'Default Business'],
        ['abc123', 'Kako Restaurant'],
        ['def456', 'G3 Business'],
      ];

      for (final businessCase in businessCases) {
        final businessId = businessCase[0] as String;
        final businessName = businessCase[1] as String;

        debugPrint('\n=== $businessName (ID: $businessId) ===');
        debugPrint('Menu Items: businesses/$businessId/menu_items');
        debugPrint('Categories: businesses/$businessId/menu_categories');
        debugPrint('Orders: businesses/$businessId/orders');
        debugPrint('Cart: businesses/$businessId/carts/{userId}');
        debugPrint('Config: businesses/$businessId');
        debugPrint('Theme: businesses/$businessId/theme');
      }
    });
  });
}

// Helper function from the actual business routing provider
bool _isValidBusinessSlug(String slug) {
  // Business slugs should:
  // - Be at least 2 characters long
  // - Not contain spaces or special routing characters
  // - Only contain lowercase letters, numbers, and hyphens
  // - Not start or end with hyphens
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#'))
    return false;
  if (slug.startsWith('-') || slug.endsWith('-')) return false;
  if (slug.contains('--')) return false; // No consecutive hyphens

  // Check valid pattern: lowercase letters, numbers, and hyphens only
  final validPattern = RegExp(r'^[a-z0-9-]+$');
  if (!validPattern.hasMatch(slug)) return false;

  // Skip system/auth routes that don't represent business slugs
  final systemRoutes = {
    'admin',
    'signin',
    'signup',
    'onboarding',
    'error',
    'startup',
    'business-setup',
    'admin-setup',
    'menu', // For default/root access
    'carrito', // For default/root access
    'cuenta', // For default/root access
    'ordenes', // For default/root access
  };

  return !systemRoutes.contains(slug);
}
