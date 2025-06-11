import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_service.dart';

void main() {
  group('BusinessSlugService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late BusinessSlugService slugService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      slugService = BusinessSlugService(firestore: fakeFirestore);
    });

    test('getBusinessIdFromSlug should return correct business ID', () async {
      // Setup test data
      await fakeFirestore.collection('businesses').doc('business123').set({
        'slug': 'panesitos',
        'isActive': true,
        'name': 'Panesitos Restaurant',
      });

      // Test slug resolution
      final businessId = await slugService.getBusinessIdFromSlug('panesitos');
      expect(businessId, equals('business123'));
    });

    test('getBusinessIdFromSlug should return null for non-existent slug',
        () async {
      final businessId =
          await slugService.getBusinessIdFromSlug('non-existent');
      expect(businessId, isNull);
    });

    test('getBusinessIdFromSlug should ignore inactive businesses', () async {
      // Setup inactive business
      await fakeFirestore.collection('businesses').doc('inactive123').set({
        'slug': 'inactive-restaurant',
        'isActive': false,
        'name': 'Inactive Restaurant',
      });

      final businessId =
          await slugService.getBusinessIdFromSlug('inactive-restaurant');
      expect(businessId, isNull);
    });

    test('getSlugFromBusinessId should return correct slug', () async {
      // Setup test data
      await fakeFirestore.collection('businesses').doc('business456').set({
        'slug': 'restaurant-name',
        'isActive': true,
        'name': 'Restaurant Name',
      });

      final slug = await slugService.getSlugFromBusinessId('business456');
      expect(slug, equals('restaurant-name'));
    });

    test('getSlugFromBusinessId should return null for non-existent business',
        () async {
      final slug = await slugService.getSlugFromBusinessId('non-existent');
      expect(slug, isNull);
    });

    test('validateSlug should validate basic format correctly', () async {
      // Valid slugs
      expect(BusinessConfig.isValidSlug('panesitos'), isTrue);
      expect(BusinessConfig.isValidSlug('restaurant-name'), isTrue);
      expect(BusinessConfig.isValidSlug('abc123'), isTrue);
      expect(BusinessConfig.isValidSlug('my-restaurant-2024'), isTrue);

      // Invalid slugs - too short
      expect(BusinessConfig.isValidSlug('a'), isFalse);
      expect(BusinessConfig.isValidSlug(''), isFalse);

      // Invalid slugs - too long (over 50 chars)
      expect(BusinessConfig.isValidSlug('a' * 51), isFalse);

      // Invalid slugs - invalid characters
      expect(BusinessConfig.isValidSlug('Restaurant Name'), isFalse); // spaces
      expect(BusinessConfig.isValidSlug('restaurant_name'),
          isFalse); // underscores
      expect(BusinessConfig.isValidSlug('restaurant.name'), isFalse); // dots
      expect(BusinessConfig.isValidSlug('restaurant@name'),
          isFalse); // special chars

      // Invalid slugs - invalid format
      expect(BusinessConfig.isValidSlug('-restaurant'),
          isFalse); // starts with hyphen
      expect(BusinessConfig.isValidSlug('restaurant-'),
          isFalse); // ends with hyphen
      expect(BusinessConfig.isValidSlug('rest--aurant'),
          isFalse); // consecutive hyphens
    });

    test('validateSlug should reject reserved words', () async {
      final reservedWords = [
        'admin',
        'api',
        'signin',
        'signup',
        'dashboard',
        'settings',
        'support',
      ];

      for (final word in reservedWords) {
        expect(BusinessConfig.isValidSlug(word), isFalse,
            reason: '$word should be rejected as a reserved word');
      }
    });

    test('isSlugAvailable should work correctly with format validation',
        () async {
      // Setup existing business
      await fakeFirestore.collection('businesses').doc('taken123').set({
        'slug': 'taken-slug',
        'isActive': true,
        'name': 'Taken Restaurant',
      });

      // Test existing slug availability
      expect(await slugService.isSlugAvailable('taken-slug'), isFalse);
      expect(await slugService.isSlugAvailable('available-slug'), isTrue);

      // Test format validation combined with availability
      expect(BusinessConfig.isValidSlug('taken-slug'),
          isTrue); // format valid but taken
      expect(BusinessConfig.isValidSlug('available-slug'),
          isTrue); // format valid and available
      expect(BusinessConfig.isValidSlug('invalid slug'),
          isFalse); // format invalid
    });

    test('getSuggestedSlugs should generate valid alternatives', () async {
      // Setup existing business to create conflicts
      await fakeFirestore.collection('businesses').doc('existing123').set({
        'slug': 'test-restaurant',
        'isActive': true,
        'name': 'Test Restaurant',
      });

      final suggestions =
          await slugService.getSuggestedSlugs('Test Restaurant');

      expect(suggestions, isNotEmpty);
      expect(suggestions.length, lessThanOrEqualTo(10));

      // All suggestions should be valid slugs
      for (final suggestion in suggestions) {
        expect(BusinessConfig.isValidSlug(suggestion), isTrue);
        expect(await slugService.isSlugAvailable(suggestion), isTrue);
      }

      // Should not include the taken slug
      expect(suggestions.contains('test-restaurant'), isFalse);
    });

    test('updateBusinessSlug should work correctly', () async {
      // Setup existing business
      await fakeFirestore.collection('businesses').doc('business789').set({
        'slug': 'old-slug',
        'isActive': true,
        'name': 'Test Business',
      });

      // Test successful update
      final success =
          await slugService.updateBusinessSlug('business789', 'new-slug');
      expect(success, isTrue);

      // Verify the slug was updated
      final doc =
          await fakeFirestore.collection('businesses').doc('business789').get();
      expect(doc.data()?['slug'], equals('new-slug'));

      // Test update to existing slug should fail
      await fakeFirestore.collection('businesses').doc('another123').set({
        'slug': 'existing-slug',
        'isActive': true,
        'name': 'Another Business',
      });

      final failure =
          await slugService.updateBusinessSlug('business789', 'existing-slug');
      expect(failure, isFalse);
    });
  });
}
