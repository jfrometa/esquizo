import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';

void main() {
  group('Business Routing Tests', () {
    test('extractBusinessSlugFromPath should extract correct slug', () {
      // Test basic slug extraction
      expect(extractBusinessSlugFromPath('/panesitos'), equals('panesitos'));
      expect(extractBusinessSlugFromPath('/restaurant-name'),
          equals('restaurant-name'));
      expect(
          extractBusinessSlugFromPath('/panesitos/menu'), equals('panesitos'));
      expect(extractBusinessSlugFromPath('/restaurant-name/cart'),
          equals('restaurant-name'));

      // Test system routes (should return null)
      expect(extractBusinessSlugFromPath('/admin'), isNull);
      expect(extractBusinessSlugFromPath('/signin'), isNull);
      expect(extractBusinessSlugFromPath('/signup'), isNull);
      expect(extractBusinessSlugFromPath('/onboarding'), isNull);
      expect(extractBusinessSlugFromPath('/business-setup'), isNull);

      // Test edge cases
      expect(extractBusinessSlugFromPath('/'), isNull);
      expect(extractBusinessSlugFromPath(''), isNull);

      // Test nested admin routes
      expect(extractBusinessSlugFromPath('/admin/dashboard'), isNull);
      expect(extractBusinessSlugFromPath('/admin/business-settings'), isNull);
    });

    test('extractBusinessSlugFromPath should handle various formats', () {
      // With leading slash
      expect(extractBusinessSlugFromPath('/panesitos'), equals('panesitos'));

      // Without leading slash
      expect(extractBusinessSlugFromPath('panesitos'), equals('panesitos'));

      // With subdirectories
      expect(extractBusinessSlugFromPath('/panesitos/menu/appetizers'),
          equals('panesitos'));
      expect(extractBusinessSlugFromPath('/restaurant-name/catering/packages'),
          equals('restaurant-name'));
    });

    test('extractBusinessSlugFromPath should handle reserved routes correctly',
        () {
      final reservedRoutes = [
        'admin',
        'signin',
        'signup',
        'onboarding',
        'error',
        'startup',
        'business-setup',
        'admin-setup',
        'menu', // For default/root access
      ];

      for (final route in reservedRoutes) {
        expect(extractBusinessSlugFromPath('/$route'), isNull,
            reason:
                'Route /$route should be treated as reserved and return null');
        expect(extractBusinessSlugFromPath('/$route/subpath'), isNull,
            reason:
                'Route /$route/subpath should be treated as reserved and return null');
      }
    });
  });
}
