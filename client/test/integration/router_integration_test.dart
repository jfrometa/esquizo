import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/routing/business_routing_provider.dart';

void main() {
  group('Router Integration Tests', () {
    group('Default Business Routes (No Slug)', () {
      test('Root path should not redirect to business setup', () {
        // Root path should be accessible without redirects
        final extractedSlug = extractBusinessSlugFromPath('/');
        expect(extractedSlug, isNull,
            reason: 'Root path should not have a business slug');
      });

      test('Default business routes should be accessible', () {
        final testPaths = [
          '/',
          '/menu',
          '/carrito',
          '/cuenta',
          '/ordenes',
        ];

        for (final path in testPaths) {
          // Extract slug from path - should be null for default routes
          final extractedSlug = extractBusinessSlugFromPath(path);
          expect(extractedSlug, isNull,
              reason: 'Default route $path should not have a business slug');
        }
      });

      test('Admin routes should be accessible for default business', () {
        final adminPaths = [
          '/admin',
          '/admin/dashboard',
          '/admin/settings',
          '/admin/reports',
        ];

        for (final path in adminPaths) {
          // Admin routes should not be treated as business slugs
          final extractedSlug = extractBusinessSlugFromPath(path);
          expect(extractedSlug, isNull,
              reason: 'Admin route $path should not have a business slug');
        }
      });
    });

    group('Slug-Based Business Routes', () {
      test('Valid business slug routes should be recognized', () {
        final testCases = [
          {'path': '/panesitos', 'expectedSlug': 'panesitos'},
          {'path': '/panesitos/menu', 'expectedSlug': 'panesitos'},
          {'path': '/panesitos/carrito', 'expectedSlug': 'panesitos'},
          {'path': '/panesitos/cuenta', 'expectedSlug': 'panesitos'},
          {'path': '/panesitos/ordenes', 'expectedSlug': 'panesitos'},
          {'path': '/cafe-central', 'expectedSlug': 'cafe-central'},
          {'path': '/cafe-central/menu', 'expectedSlug': 'cafe-central'},
          {'path': '/la-cocina-criolla', 'expectedSlug': 'la-cocina-criolla'},
          {
            'path': '/la-cocina-criolla/admin',
            'expectedSlug': 'la-cocina-criolla'
          },
        ];

        for (final testCase in testCases) {
          final path = testCase['path'] as String;
          final expectedSlug = testCase['expectedSlug'] as String;

          final extractedSlug = extractBusinessSlugFromPath(path);
          expect(extractedSlug, expectedSlug,
              reason: 'Path $path should extract slug $expectedSlug');
        }
      });

      test('System routes should not be treated as business slugs', () {
        final systemPaths = [
          '/signin',
          '/signup',
          '/business-setup',
          '/admin-setup',
          '/dashboard',
          '/settings',
          '/api',
          '/api/businesses',
          '/auth',
          '/auth/callback',
        ];

        for (final path in systemPaths) {
          final extractedSlug = extractBusinessSlugFromPath(path);
          expect(extractedSlug, isNull,
              reason:
                  'System route $path should not be treated as a business slug');
        }
      });

      test('Invalid slug formats should not be recognized', () {
        final invalidPaths = [
          '/123', // Too short numbers only
          '/a', // Too short
          '/-invalid', // Starts with hyphen
          '/invalid-', // Ends with hyphen
          '/invalid--slug', // Double hyphen
          '/invalid_slug', // Underscore
          '/Invalid-Slug', // Uppercase
          '/invalid slug', // Space
          '/invalid@slug', // Special character
        ];

        for (final path in invalidPaths) {
          final extractedSlug = extractBusinessSlugFromPath(path);
          expect(extractedSlug, isNull,
              reason: 'Invalid path $path should not extract a business slug');
        }
      });
    });

    group('Business Context Resolution', () {
      test('Default business context should use "default" ID', () {
        final defaultPaths = [
          '/',
          '/menu',
          '/carrito',
          '/cuenta',
          '/ordenes',
          '/admin'
        ];

        for (final path in defaultPaths) {
          final businessSlug = extractBusinessSlugFromPath(path);
          expect(businessSlug, isNull);

          // When no slug is found, the business context should default to "default"
          final businessId = businessSlug ?? 'default';
          expect(businessId, 'default');
        }
      });

      test('Slug-based business context should use extracted slug', () {
        final slugPaths = {
          '/panesitos': 'panesitos',
          '/panesitos/menu': 'panesitos',
          '/cafe-central': 'cafe-central',
          '/la-cocina-criolla/carrito': 'la-cocina-criolla',
        };

        for (final entry in slugPaths.entries) {
          final path = entry.key;
          final expectedSlug = entry.value;

          final businessSlug = extractBusinessSlugFromPath(path);
          expect(businessSlug, expectedSlug);

          // The business ID should be the extracted slug
          final businessId = businessSlug ?? 'default';
          expect(businessId, expectedSlug);
        }
      });
    });

    group('Navigation Consistency', () {
      test(
          'Navigation destinations should support both default and slug routing',
          () {
        final destinations = [
          {'route': 'menu', 'label': 'Menú'},
          {'route': 'carrito', 'label': 'Carrito'},
          {'route': 'cuenta', 'label': 'Cuenta'},
          {'route': 'ordenes', 'label': 'Órdenes'},
        ];

        for (final destination in destinations) {
          final route = destination['route'] as String;

          // Default business navigation (no slug)
          final defaultPath = '/$route';
          final defaultSlug = extractBusinessSlugFromPath(defaultPath);
          expect(defaultSlug, isNull);

          // Slug-based business navigation
          final slugPath = '/panesitos/$route';
          final extractedSlug = extractBusinessSlugFromPath(slugPath);
          expect(extractedSlug, 'panesitos');
        }
      });
    });

    group('Edge Cases', () {
      test('Empty and malformed paths should be handled gracefully', () {
        final edgeCases = [
          '',
          '/',
          '//',
          '////',
          '/   ',
          '/\t',
          '/\n',
        ];

        for (final path in edgeCases) {
          expect(() {
            extractBusinessSlugFromPath(path);
          }, returnsNormally,
              reason: 'Path "$path" should not throw an exception');
        }
      });

      test('Very long paths should be handled gracefully', () {
        final longSlug = 'a' * 100;
        final longPath = '/$longSlug/menu';

        expect(() {
          extractBusinessSlugFromPath(longPath);
        }, returnsNormally,
            reason: 'Very long paths should not throw exceptions');
      });

      test('Paths with query parameters should extract slug correctly', () {
        final pathsWithQuery = {
          '/panesitos?tab=appetizers': 'panesitos',
          '/cafe-central/menu?category=drinks': 'cafe-central',
          '/la-cocina-criolla/carrito?item=123': 'la-cocina-criolla',
        };

        for (final entry in pathsWithQuery.entries) {
          final path = entry.key;
          final expectedSlug = entry.value;

          final extractedSlug = extractBusinessSlugFromPath(path);
          expect(extractedSlug, expectedSlug,
              reason:
                  'Path with query $path should extract slug $expectedSlug');
        }
      });

      test('Paths with fragments should extract slug correctly', () {
        final pathsWithFragment = {
          '/panesitos#section1': 'panesitos',
          '/cafe-central/menu#drinks': 'cafe-central',
          '/la-cocina-criolla/carrito#checkout': 'la-cocina-criolla',
        };

        for (final entry in pathsWithFragment.entries) {
          final path = entry.key;
          final expectedSlug = entry.value;

          final extractedSlug = extractBusinessSlugFromPath(path);
          expect(extractedSlug, expectedSlug,
              reason:
                  'Path with fragment $path should extract slug $expectedSlug');
        }
      });
    });
  });
}
