import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';

void main() {
  group('Business Slug Detection', () {
    test('should detect valid business slugs', () {
      // Valid business slugs
      expect(extractBusinessSlugFromPath('/kako'), equals('kako'));
      expect(extractBusinessSlugFromPath('/kako/menu'), equals('kako'));
      expect(extractBusinessSlugFromPath('/g3'), equals('g3'));
      expect(extractBusinessSlugFromPath('/panesitos'), equals('panesitos'));
      expect(extractBusinessSlugFromPath('/mi-restaurante'),
          equals('mi-restaurante'));
      expect(extractBusinessSlugFromPath('/restaurante123'),
          equals('restaurante123'));
    });

    test('should NOT detect system routes as business slugs', () {
      // System routes should not be treated as business slugs
      expect(extractBusinessSlugFromPath('/admin'), isNull);
      expect(extractBusinessSlugFromPath('/signin'), isNull);
      expect(extractBusinessSlugFromPath('/signup'), isNull);
      expect(extractBusinessSlugFromPath('/onboarding'), isNull);
      expect(extractBusinessSlugFromPath('/error'), isNull);
      expect(extractBusinessSlugFromPath('/startup'), isNull);
      expect(extractBusinessSlugFromPath('/business-setup'), isNull);
      expect(extractBusinessSlugFromPath('/admin-setup'), isNull);
      expect(extractBusinessSlugFromPath('/authenticated-profile'), isNull);

      // Default business routes (no business context)
      expect(extractBusinessSlugFromPath('/menu'), isNull);
      expect(extractBusinessSlugFromPath('/carrito'), isNull);
      expect(extractBusinessSlugFromPath('/cart'), isNull);
      expect(extractBusinessSlugFromPath('/cuenta'), isNull);
      expect(extractBusinessSlugFromPath('/ordenes'), isNull);
      expect(extractBusinessSlugFromPath('/catering-menu'), isNull);
      expect(extractBusinessSlugFromPath('/catering-quote'), isNull);
      expect(extractBusinessSlugFromPath('/subscripciones'), isNull);
      expect(extractBusinessSlugFromPath('/catering'), isNull);
      expect(extractBusinessSlugFromPath('/populares'), isNull);
      expect(extractBusinessSlugFromPath('/categorias'), isNull);
      expect(extractBusinessSlugFromPath('/platos'), isNull);
      expect(extractBusinessSlugFromPath('/completar-orden'), isNull);
      expect(extractBusinessSlugFromPath('/meal-plans'), isNull);

      // Admin panel routes
      expect(extractBusinessSlugFromPath('/dashboard'), isNull);
      expect(extractBusinessSlugFromPath('/products'), isNull);
      expect(extractBusinessSlugFromPath('/orders'), isNull);
      expect(extractBusinessSlugFromPath('/settings'), isNull);
    });

    test('should handle invalid business slug formats', () {
      // Invalid slug formats
      expect(extractBusinessSlugFromPath('/A'), isNull); // Too short
      expect(extractBusinessSlugFromPath('/UPPERCASE'), isNull); // Uppercase
      expect(extractBusinessSlugFromPath('/with space'), isNull); // Space
      expect(extractBusinessSlugFromPath('/with?query'), isNull); // Query param
      expect(extractBusinessSlugFromPath('/with#hash'), isNull); // Hash
      expect(
          extractBusinessSlugFromPath('/-start'), isNull); // Starts with hyphen
      expect(extractBusinessSlugFromPath('/end-'), isNull); // Ends with hyphen
      expect(extractBusinessSlugFromPath('/double--hyphen'),
          isNull); // Double hyphen
    });

    test('should handle edge cases', () {
      // Edge cases
      expect(extractBusinessSlugFromPath('/'), isNull);
      expect(extractBusinessSlugFromPath(''), isNull);
      expect(extractBusinessSlugFromPath('no-slash'), isNull);
    });

    test('should validate business slug format correctly', () {
      // Test the internal validation function via the public interface
      expect(extractBusinessSlugFromPath('/valid-slug-123'),
          equals('valid-slug-123'));
      expect(
          extractBusinessSlugFromPath('/ab'), equals('ab')); // Minimum length
      expect(
          extractBusinessSlugFromPath(
              '/this-is-a-very-long-slug-name-that-is-definitely-over-fifty-characters-long'),
          isNull); // Too long (>50 chars)
    });

    test('should distinguish between business routes and default routes', () {
      // Business-specific routes (should extract business slug)
      expect(extractBusinessSlugFromPath('/kako/menu'), equals('kako'));
      expect(extractBusinessSlugFromPath('/g3/carrito'), equals('g3'));
      expect(
          extractBusinessSlugFromPath('/panesitos/admin'), equals('panesitos'));
      expect(extractBusinessSlugFromPath('/mi-negocio/subscripciones'),
          equals('mi-negocio'));

      // Default routes (should not extract business slug)
      expect(extractBusinessSlugFromPath('/menu'), isNull);
      expect(extractBusinessSlugFromPath('/carrito'), isNull);
      expect(extractBusinessSlugFromPath('/admin'), isNull);
      expect(extractBusinessSlugFromPath('/subscripciones'), isNull);
    });
  });
}
