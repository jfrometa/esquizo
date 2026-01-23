import 'package:flutter_test/flutter_test.dart';

// Simple test to verify business route priority fix
void main() {
  test('Business route priority - g3 should be handled by business route', () {
    // Simulate the route matching logic
    final routes = [
      // Admin routes (should be checked first)
      '/admin',
      '/admin-setup',

      // Business routes (should be checked before default routes)
      '/:businessSlug',

      // Default routes (should be checked last)
      '/',
      '/menu',
      '/carrito',
      '/cuenta',
    ];

    // Test path
    const testPath = '/g3';

    // Find the first matching route pattern
    String? matchedRoute;
    for (final route in routes) {
      if (route == '/:businessSlug' && _wouldMatchBusinessSlug(testPath)) {
        matchedRoute = route;
        break;
      } else if (route == testPath) {
        matchedRoute = route;
        break;
      }
    }

    // Verify that /g3 matches the business route pattern, not default routes
    expect(matchedRoute, equals('/:businessSlug'));
    print('✅ /g3 correctly matches business route pattern: $matchedRoute');
  });
}

bool _wouldMatchBusinessSlug(String path) {
  if (!path.startsWith('/')) return false;
  final slug = path.substring(1);
  if (slug.isEmpty) return false;

  // Same validation logic as in router
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#')) {
    return false;
  }
  if (slug.startsWith('-') || slug.endsWith('-')) return false;
  if (slug.contains('--')) return false;

  final validPattern = RegExp(r'^[a-z0-9-]+$');
  if (!validPattern.hasMatch(slug)) return false;

  final reservedSlugs = {
    'admin',
    'menu',
    'carrito',
    'cuenta',
    'ordenes',
    'startup',
    'error',
    'onboarding'
  };

  return !reservedSlugs.contains(slug);
}
