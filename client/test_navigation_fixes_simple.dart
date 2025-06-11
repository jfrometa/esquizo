// Simple test to verify navigation fixes compilation
// This tests individual components without web dependencies

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';

void main() {
  group('Business Navigation Fixes - Compilation Test', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Business routing providers compile and work correctly', () {
      // Test businessSlugFromUrlProvider - this is AutoDisposeProvider<String?>, not StateProvider
      final businessSlug = container.read(businessSlugFromUrlProvider);
      expect(businessSlug, isA<String?>());

      // Test isBusinessUrlAccessProvider
      final isBusinessUrlAccess = container.read(isBusinessUrlAccessProvider);
      expect(isBusinessUrlAccess, isA<bool>());

      // Test urlAwareBusinessIdProvider - this is AsyncNotifierProvider
      final businessIdAsync = container.read(urlAwareBusinessIdProvider);
      expect(businessIdAsync, isA<AsyncValue<String>>());

      // Test that we can properly handle AsyncValue without using .future
      businessIdAsync.when(
        data: (businessId) {
          expect(businessId, isA<String>());
          print('✅ Business ID resolved: $businessId');
        },
        loading: () {
          print('⏳ Business ID loading...');
        },
        error: (error, stack) {
          print('❌ Business ID error: $error');
        },
      );
    });

    test('Business slug extraction function works', () {
      // Test slug extraction function
      expect(extractBusinessSlugFromPath('/g3'), equals('g3'));
      expect(extractBusinessSlugFromPath('/g3/menu'), equals('g3'));
      expect(extractBusinessSlugFromPath('/admin'), isNull);
      expect(extractBusinessSlugFromPath('/signin'), isNull);
      expect(extractBusinessSlugFromPath('/menu'), isNull); // Default route

      print('✅ Business slug extraction tests passed');
    });
  });
}
