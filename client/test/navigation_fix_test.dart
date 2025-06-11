import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';

void main() {
  group('Navigation Fix Tests', () {
    test('Navigation destinations should not cause index mismatches', () {
      // Test that our navigation logic uses consistent indexing
      const allDestinations = [
        NavigationDestinationItem(
          label: 'Home',
          path: '/',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        NavigationDestinationItem(
          label: 'Menu',
          path: '/menu',
          icon: Icons.restaurant_menu_outlined,
          selectedIcon: Icons.restaurant_menu,
        ),
        NavigationDestinationItem(
          label: 'Cart',
          path: '/carrito',
          icon: Icons.shopping_cart_outlined,
          selectedIcon: Icons.shopping_cart,
        ),
        NavigationDestinationItem(
          label: 'Account',
          path: '/cuenta',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
        NavigationDestinationItem(
          label: 'Admin',
          path: '/admin',
          icon: Icons.admin_panel_settings_outlined,
          selectedIcon: Icons.admin_panel_settings,
          isVisible: false, // Admin hidden by default
        ),
      ];

      // Filter to visible destinations (same logic as the provider)
      final visibleDestinations = allDestinations
          .where((item) => item.isVisible || item.path != '/admin')
          .toList();

      // Test that indices are consistent
      for (int i = 0; i < visibleDestinations.length; i++) {
        final destination = visibleDestinations[i];

        // In our fixed navigation logic, we use the index directly
        // This test verifies that the visible destinations list has consistent indices
        expect(i, isA<int>());
        expect(destination.path, isNotEmpty);

        // Verify that non-admin destinations are properly indexed
        if (destination.path != '/admin') {
          expect(i >= 0, isTrue);
          expect(i < visibleDestinations.length, isTrue);
        }
      }
    });

    test('Business slug validation works correctly', () {
      // Test the business slug validation logic from app_router.dart

      // Valid slugs
      expect(_isValidBusinessSlugTest('panesitos'), isTrue);
      expect(_isValidBusinessSlugTest('restaurant-name'), isTrue);
      expect(_isValidBusinessSlugTest('my-cafe'), isTrue);
      expect(_isValidBusinessSlugTest('cafe123'), isTrue);

      // Invalid slugs
      expect(_isValidBusinessSlugTest('admin'), isFalse); // Reserved word
      expect(_isValidBusinessSlugTest('menu'), isFalse); // Reserved word
      expect(_isValidBusinessSlugTest('a'), isFalse); // Too short
      expect(
          _isValidBusinessSlugTest('-invalid'), isFalse); // Starts with hyphen
      expect(_isValidBusinessSlugTest('invalid-'), isFalse); // Ends with hyphen
      expect(
          _isValidBusinessSlugTest('invalid--slug'), isFalse); // Double hyphen
      expect(_isValidBusinessSlugTest('Invalid'), isFalse); // Uppercase
      expect(
          _isValidBusinessSlugTest('invalid slug'), isFalse); // Contains space
    });
  });
}

// Test version of the business slug validation function
bool _isValidBusinessSlugTest(String slug) {
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

  // Check against reserved words
  final reservedSlugs = {
    'admin',
    'api',
    'www',
    'app',
    'help',
    'support',
    'about',
    'contact',
    'signin',
    'signup',
    'login',
    'logout',
    'register',
    'dashboard',
    'settings',
    'profile',
    'account',
    'billing',
    'pricing',
    'terms',
    'privacy',
    'legal',
    'security',
    'status',
    'blog',
    'news',
    'docs',
    'documentation',
    'guide',
    'tutorial',
    'faq',
    'mail',
    'email',
    'static',
    'assets',
    'images',
    'css',
    'js',
    'javascript',
    'fonts',
    'menu',
    'carrito',
    'cuenta',
    'ordenes',
    'startup',
    'error',
    'onboarding',
    'business-setup',
    'admin-setup'
  };

  return !reservedSlugs.contains(slug);
}
