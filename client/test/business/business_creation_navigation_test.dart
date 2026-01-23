import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_service.dart';

void main() {
  group('Business Creation Navigation Flow Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late BusinessSlugService slugService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      slugService = BusinessSlugService(firestore: fakeFirestore);
    });

    test('business creation should generate valid slug and enable navigation',
        () async {
      // Test business creation with typical restaurant names
      final testBusinessNames = [
        'Panesitos Restaurant',
        'La Cocina Criolla',
        'Bistro 42',
        'Café Central',
        'The Food Corner',
      ];

      for (final businessName in testBusinessNames) {
        // 1. Generate slug from business name
        final expectedSlug = BusinessConfig.generateSlug(businessName);

        // 2. Validate the generated slug
        expect(BusinessConfig.isValidSlug(expectedSlug), isTrue,
            reason: 'Generated slug for "$businessName" should be valid');

        // 3. Check slug availability (should be available for new business)
        expect(await slugService.isSlugAvailable(expectedSlug), isTrue,
            reason: 'Generated slug for "$businessName" should be available');

        // 4. Simulate business creation in Firestore
        final businessId = 'business_${DateTime.now().millisecondsSinceEpoch}';
        await fakeFirestore.collection('businesses').doc(businessId).set({
          'name': businessName,
          'slug': expectedSlug,
          'isActive': true,
          'type': 'restaurant',
          'createdAt': DateTime.now().toIso8601String(),
        });

        // 5. Verify slug-to-ID resolution works
        final resolvedBusinessId =
            await slugService.getBusinessIdFromSlug(expectedSlug);
        expect(resolvedBusinessId, equals(businessId),
            reason: 'Slug should resolve to correct business ID');

        // 6. Verify ID-to-slug resolution works
        final resolvedSlug =
            await slugService.getSlugFromBusinessId(businessId);
        expect(resolvedSlug, equals(expectedSlug),
            reason: 'Business ID should resolve to correct slug');

        // 7. Verify slug is no longer available
        expect(await slugService.isSlugAvailable(expectedSlug), isFalse,
            reason: 'Slug should not be available after business creation');
      }
    });

    test('navigation flow should handle edge cases gracefully', () async {
      // Test case 1: Business name with special characters
      final businessWithSpecialChars = 'Café & Restaurante "El Patrón"';
      final slugSpecial = BusinessConfig.generateSlug(businessWithSpecialChars);
      expect(BusinessConfig.isValidSlug(slugSpecial), isTrue);
      expect(slugSpecial, equals('cafe-restaurante-el-patron'));

      // Test case 2: Very long business name
      final longBusinessName =
          'This is a very long restaurant name that exceeds normal length limits for business names in most systems';
      final slugLong = BusinessConfig.generateSlug(longBusinessName);
      expect(BusinessConfig.isValidSlug(slugLong), isTrue);
      expect(slugLong.length, lessThanOrEqualTo(50));

      // Test case 3: Business name with numbers
      final businessWithNumbers = 'Restaurant 123 & Café 2024';
      final slugNumbers = BusinessConfig.generateSlug(businessWithNumbers);
      expect(BusinessConfig.isValidSlug(slugNumbers), isTrue);
      expect(slugNumbers, equals('restaurant-123-cafe-2024'));

      // Test case 4: Empty or minimal business name
      final minimalName = 'AB';
      final slugMinimal = BusinessConfig.generateSlug(minimalName);
      expect(BusinessConfig.isValidSlug(slugMinimal), isTrue);
      expect(slugMinimal, equals('ab'));
    });

    test('slug conflict resolution should work correctly', () async {
      // Create initial business
      await fakeFirestore
          .collection('businesses')
          .doc('original-business')
          .set({
        'name': 'Test Restaurant',
        'slug': 'test-restaurant',
        'isActive': true,
        'type': 'restaurant',
      });

      // Test that suggestions exclude the taken slug
      final suggestions =
          await slugService.getSuggestedSlugs('Test Restaurant');
      expect(suggestions, isNotEmpty);
      expect(suggestions.contains('test-restaurant'), isFalse);

      // All suggestions should be valid and available
      for (final suggestion in suggestions) {
        expect(BusinessConfig.isValidSlug(suggestion), isTrue);
        expect(await slugService.isSlugAvailable(suggestion), isTrue);
      }
    });

    test('inactive business handling in navigation flow', () async {
      // Create an inactive business
      await fakeFirestore
          .collection('businesses')
          .doc('inactive-business')
          .set({
        'name': 'Inactive Restaurant',
        'slug': 'inactive-restaurant',
        'isActive': false,
        'type': 'restaurant',
      });

      // Slug should not resolve to business ID for inactive business
      final businessId =
          await slugService.getBusinessIdFromSlug('inactive-restaurant');
      expect(businessId, isNull);

      // Slug should be available for reuse since business is inactive
      expect(await slugService.isSlugAvailable('inactive-restaurant'), isTrue);

      // Create new active business with same slug
      await fakeFirestore
          .collection('businesses')
          .doc('new-active-business')
          .set({
        'name': 'New Active Restaurant',
        'slug': 'inactive-restaurant',
        'isActive': true,
        'type': 'restaurant',
      });

      // Now slug should resolve to new active business
      final newBusinessId =
          await slugService.getBusinessIdFromSlug('inactive-restaurant');
      expect(newBusinessId, equals('new-active-business'));
    });

    test('business setup completion navigation should work', () async {
      // Simulate a completed business setup
      const businessId = 'completed-business-123';
      const businessSlug = 'completed-restaurant';

      await fakeFirestore.collection('businesses').doc(businessId).set({
        'name': 'Completed Restaurant',
        'slug': businessSlug,
        'isActive': true,
        'type': 'restaurant',
        'setupCompleted': true,
      });

      // Verify that the completion screen can get the slug for navigation
      final retrievedSlug = await slugService.getSlugFromBusinessId(businessId);
      expect(retrievedSlug, equals(businessSlug));

      // Verify the slug is valid for navigation
      expect(BusinessConfig.isValidSlug(retrievedSlug!), isTrue);

      // Verify slug resolves back to business ID
      final resolvedBusinessId =
          await slugService.getBusinessIdFromSlug(retrievedSlug);
      expect(resolvedBusinessId, equals(businessId));
    });

    test('reserved slug protection should prevent navigation conflicts',
        () async {
      final reservedSlugs = [
        'admin',
        'signin',
        'signup',
        'business-setup',
        'admin-setup',
        'dashboard',
        'settings'
      ];

      for (final reservedSlug in reservedSlugs) {
        // Reserved slugs should not be valid for businesses
        expect(BusinessConfig.isValidSlug(reservedSlug), isFalse,
            reason: '$reservedSlug should be reserved');

        // Even if somehow created in database, they should be treated as available
        // (since they can't be used for businesses anyway)
        expect(await slugService.isSlugAvailable(reservedSlug), isTrue);
      }
    });

    test('business slug updates should maintain navigation consistency',
        () async {
      // Create initial business
      const initialBusinessId = 'update-test-business';
      const initialSlug = 'old-restaurant-name';
      const newSlug = 'new-restaurant-name';

      await fakeFirestore.collection('businesses').doc(initialBusinessId).set({
        'name': 'Old Restaurant Name',
        'slug': initialSlug,
        'isActive': true,
        'type': 'restaurant',
      });

      // Verify initial state
      expect(await slugService.getBusinessIdFromSlug(initialSlug),
          equals(initialBusinessId));
      expect(await slugService.isSlugAvailable(newSlug), isTrue);

      // Update business slug
      final updateSuccess =
          await slugService.updateBusinessSlug(initialBusinessId, newSlug);
      expect(updateSuccess, isTrue);

      // Verify updated state
      expect(await slugService.getBusinessIdFromSlug(newSlug),
          equals(initialBusinessId));
      expect(await slugService.getBusinessIdFromSlug(initialSlug), isNull);
      expect(await slugService.isSlugAvailable(initialSlug), isTrue);
      expect(await slugService.isSlugAvailable(newSlug), isFalse);
    });
  });
}
