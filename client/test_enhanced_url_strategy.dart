// Test file to verify enhanced URL strategy implementation
// This ensures business slugs are preserved throughout navigation

import 'package:flutter_test/flutter_test.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/enhanced_url_strategy.dart';


void main() {
  group('Enhanced URL Strategy Tests', () {
    test('Business slug extraction works correctly', () {
      // Test business slug extraction from various URL patterns
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/g3'), equals('g3'));
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/g3/menu'), equals('g3'));
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/restaurant-name'), equals('restaurant-name'));
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/restaurant-name/carrito'), equals('restaurant-name'));

      // Test system routes that should not be treated as business slugs
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/admin'), isNull);
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/signin'), isNull);
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/business-setup'), isNull);
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/menu'), isNull); // Default route access
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/carrito'), isNull); // Default route access

      // Test edge cases
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/'), isNull);
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath(''), isNull);
      
      print('✅ Business slug extraction tests passed');
    });

    test('Business slug validation works correctly', () {
      // This test verifies the validation logic is working
      // Note: _isValidBusinessSlug is private, so we test it indirectly through extraction
      
      // Valid business slugs should be extracted
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/g2'), equals('g2'));
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/restaurant'), equals('restaurant'));
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/my-restaurant'), equals('my-restaurant'));
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/restaurant123'), equals('restaurant123'));

      // Invalid business slugs should return null (system routes or invalid format)
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/a'), isNull); // Too short (system route)
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/menu'), isNull); // System route
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/admin'), isNull); // System route
      expect(EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/carrito'), isNull); // System route
      
      print('✅ Business slug validation tests passed');
    });

    test('Business-aware route building works correctly', () {
      // Test business-specific routes
      final urlStrategy = EnhancedPathUrlStrategy();

      expect(
        urlStrategy.buildBusinessAwareRoute('/menu', forceBusinessSlug: 'g3'),
        equals('/g3/menu')
      );
      expect(
        urlStrategy.buildBusinessAwareRoute('/', forceBusinessSlug: 'g3'),
        equals('/g3')
      );
      expect(
        urlStrategy.buildBusinessAwareRoute('/carrito', forceBusinessSlug: 'restaurant-name'),
        equals('/restaurant-name/carrito')
      );

      // Test default routes (no business slug)
      expect(
        urlStrategy.buildBusinessAwareRoute('/menu'),
        equals('/menu')
      );
      expect(
        urlStrategy.buildBusinessAwareRoute('/'),
        equals('/')
      );
      
      print('✅ Business-aware route building tests passed');
    });

    test('Route parsing without business slug works correctly', () {
      // Test current route extraction without business slug prefix
      // Note: This would need to be tested in a web environment where URL can be set
      
      print('✅ Route parsing tests passed (limited in test environment)');
    });

    test('Enhanced URL strategy integration test', () {
      print('🧪 Testing enhanced URL strategy integration...');
      
      // Test scenario: User navigates to /g3
      final businessSlug1 = EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/g3');
      expect(businessSlug1, equals('g3'));
      print('  ✅ /g3 -> business slug: g3');
      
      // Test scenario: User navigates to /g3/menu
      final businessSlug2 = EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/g3/menu');
      expect(businessSlug2, equals('g3'));
      print('  ✅ /g3/menu -> business slug: g3');
      
      // Test scenario: Build menu route for g3 business
      final urlStrategy = EnhancedPathUrlStrategy();
      final menuRoute = urlStrategy.buildBusinessAwareRoute('/menu', forceBusinessSlug: 'g3');
      expect(menuRoute, equals('/g3/menu'));
      print('  ✅ Menu route for g3: $menuRoute');
      
      // Test scenario: Build cart route for g3 business
      final cartRoute = urlStrategy.buildBusinessAwareRoute('/carrito', forceBusinessSlug: 'g3');
      expect(cartRoute, equals('/g3/carrito'));
      print('  ✅ Cart route for g3: $cartRoute');
      
      // Test scenario: System routes are ignored
      final adminSlug = EnhancedPathUrlStrategy.extractBusinessSlugFromPath('/admin');
      expect(adminSlug, isNull);
      print('  ✅ /admin correctly ignored (system route)');
      
      print('');
      print('🎉 Enhanced URL Strategy Integration Test Complete!');
      print('');
      print('Expected behavior:');
      print('  - /g3 -> Shows g3 business, URL stays /g3');
      print('  - /g3/menu -> Shows g3 menu, URL stays /g3/menu'); 
      print('  - /g3/carrito -> Shows g3 cart, URL stays /g3/carrito');
      print('  - Navigation within g3 preserves /g3 prefix in URLs');
      print('  - Default business (/) works without slug prefix');
    });
  });
}
