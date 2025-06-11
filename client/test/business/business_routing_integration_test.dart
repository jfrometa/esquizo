import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_service.dart';

void main() {
  group('Business Routing Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late BusinessSlugService slugService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      slugService = BusinessSlugService(firestore: fakeFirestore);
    });

    test('complete business routing flow should work end-to-end', () async {
      // 1. Setup a business in Firestore
      await fakeFirestore
          .collection('businesses')
          .doc('test-business-123')
          .set({
        'slug': 'panesitos',
        'isActive': true,
        'name': 'Panesitos Restaurant',
        'type': 'restaurant',
      });

      // 2. Test URL path extraction
      expect(extractBusinessSlugFromPath('/panesitos'), equals('panesitos'));
      expect(
          extractBusinessSlugFromPath('/panesitos/menu'), equals('panesitos'));
      expect(
          extractBusinessSlugFromPath('/panesitos/cart'), equals('panesitos'));

      // 3. Test that system routes are ignored
      expect(extractBusinessSlugFromPath('/admin'), isNull);
      expect(extractBusinessSlugFromPath('/signin'), isNull);
      expect(extractBusinessSlugFromPath('/business-setup'), isNull);

      // 4. Test slug to business ID resolution
      final businessId = await slugService.getBusinessIdFromSlug('panesitos');
      expect(businessId, equals('test-business-123'));

      // 5. Test reverse lookup (business ID to slug)
      final slug = await slugService.getSlugFromBusinessId('test-business-123');
      expect(slug, equals('panesitos'));

      // 6. Test slug validation
      expect(BusinessConfig.isValidSlug('panesitos'), isTrue);
      expect(BusinessConfig.isValidSlug('admin'), isFalse); // reserved word
      expect(BusinessConfig.isValidSlug('invalid slug'), isFalse); // spaces

      // 7. Test slug availability
      expect(await slugService.isSlugAvailable('panesitos'), isFalse); // taken
      expect(await slugService.isSlugAvailable('new-restaurant'),
          isTrue); // available
    });

    test('business slug suggestions should work correctly', () async {
      // Setup existing businesses
      await fakeFirestore.collection('businesses').doc('existing1').set({
        'slug': 'test-restaurant',
        'isActive': true,
        'name': 'Test Restaurant',
      });

      await fakeFirestore.collection('businesses').doc('existing2').set({
        'slug': 'test-restaurant-1',
        'isActive': true,
        'name': 'Test Restaurant 1',
      });

      // Get suggestions for a conflicting name
      final suggestions =
          await slugService.getSuggestedSlugs('Test Restaurant');

      expect(suggestions, isNotEmpty);

      // Should not suggest taken slugs
      expect(suggestions.contains('test-restaurant'), isFalse);
      expect(suggestions.contains('test-restaurant-1'), isFalse);

      // All suggestions should be valid and available
      for (final suggestion in suggestions) {
        expect(BusinessConfig.isValidSlug(suggestion), isTrue);
        expect(await slugService.isSlugAvailable(suggestion), isTrue);
      }
    });

    test('business slug update should work correctly', () async {
      // Setup existing business
      await fakeFirestore.collection('businesses').doc('business-update').set({
        'slug': 'old-name',
        'isActive': true,
        'name': 'Old Business Name',
      });

      // Test successful update
      final updateResult =
          await slugService.updateBusinessSlug('business-update', 'new-name');
      expect(updateResult, isTrue);

      // Verify the slug was updated
      final updatedSlug =
          await slugService.getSlugFromBusinessId('business-update');
      expect(updatedSlug, equals('new-name'));

      // Verify old slug is now available
      expect(await slugService.isSlugAvailable('old-name'), isTrue);

      // Verify new slug is now taken
      expect(await slugService.isSlugAvailable('new-name'), isFalse);
    });

    test('URL path extraction should handle edge cases', () {
      // Test various URL formats
      expect(extractBusinessSlugFromPath(''), isNull);
      expect(extractBusinessSlugFromPath('/'), isNull);
      expect(extractBusinessSlugFromPath('panesitos'),
          equals('panesitos')); // no leading slash
      expect(extractBusinessSlugFromPath('/panesitos/'),
          equals('panesitos')); // trailing slash
      expect(extractBusinessSlugFromPath('/panesitos/menu/appetizers'),
          equals('panesitos')); // deep path

      // Test reserved routes
      final reservedRoutes = [
        '/admin',
        '/admin/dashboard',
        '/signin',
        '/signup',
        '/onboarding',
        '/business-setup',
        '/admin-setup',
        '/error',
        '/startup'
      ];

      for (final route in reservedRoutes) {
        expect(extractBusinessSlugFromPath(route), isNull,
            reason: 'Route $route should not be treated as business slug');
      }
    });

    test('inactive businesses should be ignored', () async {
      // Setup inactive business
      await fakeFirestore
          .collection('businesses')
          .doc('inactive-business')
          .set({
        'slug': 'inactive-restaurant',
        'isActive': false,
        'name': 'Inactive Restaurant',
      });

      // Should not resolve to business ID
      final businessId =
          await slugService.getBusinessIdFromSlug('inactive-restaurant');
      expect(businessId, isNull);

      // Slug should be available since inactive business is ignored
      expect(await slugService.isSlugAvailable('inactive-restaurant'), isTrue);
    });

    test('slug format validation should be comprehensive', () {
      // Valid slugs
      final validSlugs = [
        'panesitos',
        'restaurant-name',
        'abc123',
        'my-restaurant-2024',
        'coffee-shop',
        'la-cocina',
        'bistro-42'
      ];

      for (final slug in validSlugs) {
        expect(BusinessConfig.isValidSlug(slug), isTrue,
            reason: '$slug should be valid');
      }

      // Invalid slugs - format issues
      final invalidFormatSlugs = [
        '', // empty
        'a', // too short
        'a' * 51, // too long
        'Restaurant Name', // spaces
        'restaurant_name', // underscores
        'restaurant.name', // dots
        'restaurant@name', // special chars
        '-restaurant', // starts with hyphen
        'restaurant-', // ends with hyphen
        'rest--aurant', // consecutive hyphens
        'RESTAURANT', // uppercase
        'café', // accented characters
      ];

      for (final slug in invalidFormatSlugs) {
        expect(BusinessConfig.isValidSlug(slug), isFalse,
            reason: '$slug should be invalid');
      }

      // Invalid slugs - reserved words
      final reservedSlugs = [
        'admin',
        'api',
        'signin',
        'signup',
        'dashboard',
        'settings',
        'support',
        'about',
        'contact',
        'profile',
        'account',
        'menu'
      ];

      for (final slug in reservedSlugs) {
        expect(BusinessConfig.isValidSlug(slug), isFalse,
            reason: '$slug should be reserved');
      }
    });
  });
}
