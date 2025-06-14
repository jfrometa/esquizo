import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';

/// Test to verify "kako" business navigation flow after creation
void main() {
  group('Kako Business Navigation Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late BusinessSlugService slugService;
    late ProviderContainer container;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      slugService = BusinessSlugService(firestore: fakeFirestore);

      // Create provider container with overrides
      container = ProviderContainer(
        overrides: [
          businessSlugServiceProvider.overrideWithValue(slugService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should create kako business and verify navigation flow', () async {
      print('🧪 Testing "kako" business creation and navigation...');

      // 1. Create the "kako" business in fake Firestore
      const businessId = 'kako-business-001';
      await fakeFirestore.collection('businesses').doc(businessId).set({
        'name': 'Kako Restaurant',
        'type': 'restaurant',
        'slug': 'kako',
        'logoUrl': '',
        'coverImageUrl': '',
        'description': 'Kako Restaurant - A delicious dining experience',
        'contactInfo': {
          'email': 'contact@kako.com',
          'phone': '+1-555-KAKO',
          'website': 'https://kako.com'
        },
        'address': {
          'street': '123 Main Street',
          'city': 'City',
          'state': 'State',
          'postalCode': '12345',
          'country': 'USA'
        },
        'hours': {
          'monday': {'open': '09:00', 'close': '22:00'},
          'tuesday': {'open': '09:00', 'close': '22:00'},
          'wednesday': {'open': '09:00', 'close': '22:00'},
          'thursday': {'open': '09:00', 'close': '22:00'},
          'friday': {'open': '09:00', 'close': '23:00'},
          'saturday': {'open': '10:00', 'close': '23:00'},
          'sunday': {'open': '10:00', 'close': '21:00'}
        },
        'settings': {
          'currency': 'USD',
          'taxRate': 0.08,
          'serviceCharge': 0.1,
          'primaryColor': '#FF5722',
          'secondaryColor': '#FFC107',
          'darkMode': false,
          'allowReservations': true,
          'allowOnlineOrders': true
        },
        'features': [
          'menu',
          'tables',
          'reservations',
          'takeout',
          'delivery',
          'staff_management',
          'inventory'
        ],
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Created "kako" business in fake Firestore');

      // 2. Test slug-to-business-ID resolution
      final resolvedBusinessId =
          await slugService.getBusinessIdFromSlug('kako');
      expect(resolvedBusinessId, equals(businessId));
      print('✅ Slug resolution: "kako" -> "$businessId"');

      // 3. Test reverse lookup (business-ID-to-slug)
      final resolvedSlug = await slugService.getSlugFromBusinessId(businessId);
      expect(resolvedSlug, equals('kako'));
      print('✅ Reverse lookup: "$businessId" -> "kako"');

      // 4. Test slug availability
      final isAvailable = await slugService.isSlugAvailable('kako');
      expect(isAvailable, isFalse); // Should not be available since it's taken
      print('✅ Slug availability: "kako" is correctly marked as taken');

      // 5. Test URL path extraction
      final extractedSlug1 = extractBusinessSlugFromPath('/kako');
      expect(extractedSlug1, equals('kako'));
      print('✅ URL extraction: "/kako" -> "kako"');

      final extractedSlug2 = extractBusinessSlugFromPath('/kako/menu');
      expect(extractedSlug2, equals('kako'));
      print('✅ URL extraction: "/kako/menu" -> "kako"');

      final extractedSlug3 = extractBusinessSlugFromPath('/kako/cart');
      expect(extractedSlug3, equals('kako'));
      print('✅ URL extraction: "/kako/cart" -> "kako"');

      // 6. Test that system routes are still ignored
      final systemRoute = extractBusinessSlugFromPath('/admin');
      expect(systemRoute, isNull);
      print('✅ System route handling: "/admin" correctly returns null');

      // 7. Test business context provider (simulate URL access)
      // Note: This would require mocking the WebUtils.getCurrentPath() method
      // For now, we'll test the core logic

      print('');
      print('🎉 All "kako" business navigation tests passed!');
      print('');
      print('📋 Test Results Summary:');
      print('   ✅ Business creation in database');
      print('   ✅ Slug-to-business-ID resolution');
      print('   ✅ Business-ID-to-slug reverse lookup');
      print('   ✅ Slug availability checking');
      print('   ✅ URL path extraction for all routes');
      print('   ✅ System route protection');
      print('');
      print('🔗 Verified URL Patterns:');
      print('   /kako -> Resolves to Kako Restaurant');
      print('   /kako/menu -> Resolves to Kako Restaurant');
      print('   /kako/cart -> Resolves to Kako Restaurant');
      print('   /admin -> Correctly ignored (system route)');
    });

    test('should handle multiple business slugs correctly', () async {
      print('🧪 Testing multiple business slug handling...');

      // Create multiple businesses
      final businesses = [
        {'id': 'kako-business-001', 'slug': 'kako', 'name': 'Kako Restaurant'},
        {'id': 'g3-business-001', 'slug': 'g3', 'name': 'G3 Restaurant'},
        {
          'id': 'panesitos-business-001',
          'slug': 'panesitos',
          'name': 'Panesitos Restaurant'
        },
      ];

      for (final business in businesses) {
        await fakeFirestore.collection('businesses').doc(business['id']!).set({
          'name': business['name'],
          'slug': business['slug'],
          'type': 'restaurant',
          'isActive': true,
          'logoUrl': '',
          'coverImageUrl': '',
          'description': '${business['name']} - A delicious dining experience',
          'contactInfo': {},
          'address': {},
          'hours': {},
          'settings': {},
          'features': ['menu', 'tables'],
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      print('✅ Created multiple businesses in fake Firestore');

      // Test each business slug resolution
      for (final business in businesses) {
        final resolvedId =
            await slugService.getBusinessIdFromSlug(business['slug']!);
        expect(resolvedId, equals(business['id']));
        print('✅ ${business['slug']} -> ${business['id']}');

        final resolvedSlug =
            await slugService.getSlugFromBusinessId(business['id']!);
        expect(resolvedSlug, equals(business['slug']));
        print('✅ ${business['id']} -> ${business['slug']}');
      }

      // Test URL extraction for different patterns
      final testPaths = [
        '/kako/menu',
        '/g3/cart',
        '/panesitos/ordenes',
        '/kako',
        '/g3',
        '/panesitos',
      ];

      for (final path in testPaths) {
        final extractedSlug = extractBusinessSlugFromPath(path);
        final expectedSlug = path.split('/')[1];
        expect(extractedSlug, equals(expectedSlug));
        print('✅ Path "$path" -> slug "$expectedSlug"');
      }

      print('');
      print('🎉 Multiple business slug handling test passed!');
    });

    test('should handle inactive businesses correctly', () async {
      print('🧪 Testing inactive business handling...');

      // Create an inactive "kako" business
      await fakeFirestore.collection('businesses').doc('inactive-kako').set({
        'name': 'Inactive Kako Restaurant',
        'slug': 'kako',
        'type': 'restaurant',
        'isActive': false, // This business is inactive
        'logoUrl': '',
        'coverImageUrl': '',
        'description': 'Inactive restaurant',
        'contactInfo': {},
        'address': {},
        'hours': {},
        'settings': {},
        'features': [],
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Should not resolve inactive business
      final resolvedId = await slugService.getBusinessIdFromSlug('kako');
      expect(resolvedId, isNull);
      print('✅ Inactive business correctly ignored');

      // Slug should be available for reuse
      final isAvailable = await slugService.isSlugAvailable('kako');
      expect(isAvailable, isTrue);
      print('✅ Slug available for reuse after inactive business');

      // Now create an active business with the same slug
      await fakeFirestore.collection('businesses').doc('active-kako').set({
        'name': 'Active Kako Restaurant',
        'slug': 'kako',
        'type': 'restaurant',
        'isActive': true,
        'logoUrl': '',
        'coverImageUrl': '',
        'description': 'Active restaurant',
        'contactInfo': {},
        'address': {},
        'hours': {},
        'settings': {},
        'features': ['menu'],
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Should now resolve to the active business
      final activeResolvedId = await slugService.getBusinessIdFromSlug('kako');
      expect(activeResolvedId, equals('active-kako'));
      print('✅ Active business correctly resolved');

      // Slug should no longer be available
      final noLongerAvailable = await slugService.isSlugAvailable('kako');
      expect(noLongerAvailable, isFalse);
      print('✅ Slug correctly marked as taken by active business');

      print('');
      print('🎉 Inactive business handling test passed!');
    });
  });
}

/// Helper function to simulate business navigation flow
Future<void> simulateNavigationFlow(
    ProviderContainer container, String urlPath) async {
  print('🔄 Simulating navigation to: $urlPath');

  // Extract slug from path
  final slug = extractBusinessSlugFromPath(urlPath);
  print('   Extracted slug: $slug');

  if (slug != null) {
    // This would normally be handled by the urlAwareBusinessIdProvider
    final slugService = container.read(businessSlugServiceProvider);
    final businessId = await slugService.getBusinessIdFromSlug(slug);

    if (businessId != null) {
      print('   ✅ Resolved to business ID: $businessId');
      print('   ✅ Business context established');
    } else {
      print('   ❌ Business not found, falling back to default');
    }
  } else {
    print('   ℹ️ No business slug in path, using default context');
  }
}
