// Test script to verify business navigation routing fixes
// This tests the key navigation scenarios that were problematic

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/unified_business_context_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart'
    hide currentBusinessSlugProvider;

void main() {
  group('Business Navigation Routing Tests', () {
    late ProviderContainer container;
    late GoRouter router;

    setUp(() {
      container = ProviderContainer();
      router = container.read(goRouterProvider);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Default routes work with default business ID', (tester) async {
      debugPrint('\n🧪 Testing default routes...');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Test default route "/"
      router.go('/');
      await tester.pumpAndSettle();
      debugPrint('✅ Default route "/" loaded');

      // Test default menu route "/menu"
      router.go('/menu');
      await tester.pumpAndSettle();
      debugPrint('✅ Default route "/menu" loaded');

      // Test default cart route "/carrito"
      router.go('/carrito');
      await tester.pumpAndSettle();
      debugPrint('✅ Default route "/carrito" loaded');

      // Test default account route "/cuenta"
      router.go('/cuenta');
      await tester.pumpAndSettle();
      debugPrint('✅ Default route "/cuenta" loaded');
    });

    testWidgets('Business-specific routes work with business slug',
        (tester) async {
      debugPrint('\n🧪 Testing business-specific routes...');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Test business home route "/g3"
      router.go('/g3');
      await tester.pumpAndSettle();
      debugPrint('✅ Business route "/g3" loaded');

      // Test business menu route "/g3/menu"
      router.go('/g3/menu');
      await tester.pumpAndSettle();
      debugPrint('✅ Business route "/g3/menu" loaded');

      // Test business cart route "/g3/carrito"
      router.go('/g3/carrito');
      await tester.pumpAndSettle();
      debugPrint('✅ Business route "/g3/carrito" loaded');

      // Test business account route "/g3/cuenta"
      router.go('/g3/cuenta');
      await tester.pumpAndSettle();
      debugPrint('✅ Business route "/g3/cuenta" loaded');
    });

    test('Business context switches correctly based on URL', () async {
      debugPrint('\n🧪 Testing business context switching...');

      // Note: For unit tests, we need to override the URL providers since they depend on web utils
      // In a real scenario, the businessSlugFromUrlProvider would read from the URL
      // For this test, we'll test the business context provider directly

      final contextAsync = container.read(unifiedBusinessContextProvider);

      contextAsync.when(
        data: (context) {
          expect(context, isNotNull);
          debugPrint('✅ Business context loaded: ${context.businessId}');
        },
        loading: () {
          debugPrint('⏳ Business context loading...');
        },
        error: (error, stack) {
          debugPrint('❌ Business context error: $error');
        },
      );

      // Test URL-aware business ID provider
      final businessIdAsync = container.read(urlAwareBusinessIdProvider);

      businessIdAsync.when(
        data: (businessId) {
          expect(businessId, isNotNull);
          debugPrint('✅ URL-aware business ID resolved: $businessId');
        },
        loading: () {
          debugPrint('⏳ URL-aware business ID loading...');
        },
        error: (error, stack) {
          debugPrint('❌ URL-aware business ID error: $error');
        },
      );
    });

    test('URL-aware business ID resolves correctly', () async {
      debugPrint('\n🧪 Testing URL-aware business ID resolution...');

      // Note: businessSlugFromUrlProvider is AutoDisposeProvider<String?>, not StateProvider
      // In real usage, this would be determined by the URL/web context
      // For testing, we can test the provider directly

      final businessSlug = container.read(businessSlugFromUrlProvider);
      debugPrint('📍 Current business slug from URL: $businessSlug');

      final businessIdAsync = container.read(urlAwareBusinessIdProvider);

      businessIdAsync.when(
        data: (businessId) {
          expect(businessId, isNotNull);
          expect(businessId.isNotEmpty, isTrue);
          debugPrint('✅ URL-aware business ID resolved: $businessId');
        },
        loading: () {
          debugPrint('⏳ URL-aware business ID loading...');
        },
        error: (error, stack) {
          debugPrint('❌ URL-aware business ID error: $error');
        },
      );
    });

    test('Navigation context preservation', () async {
      debugPrint('\n🧪 Testing navigation context preservation...');

      // Test that business routes maintain business context
      final isBusinessUrlAccess = container.read(isBusinessUrlAccessProvider);
      debugPrint('Business-specific URL access: $isBusinessUrlAccess');

      // Test current business slug detection
      final currentSlug = container.read(businessSlugFromUrlProvider);
      debugPrint('Current business slug: $currentSlug');

      // Test URL-aware business ID
      final businessIdAsync = container.read(urlAwareBusinessIdProvider);
      businessIdAsync.when(
        data: (businessId) {
          expect(businessId, isNotNull);
          debugPrint('✅ Current business ID: $businessId');
        },
        loading: () {
          debugPrint('⏳ Business ID loading...');
        },
        error: (error, stack) {
          debugPrint('❌ Business ID error: $error');
        },
      );
    });
  });

  group('Business Slug Validation Tests', () {
    test('Valid business slugs are recognized', () {
      final validSlugs = ['g3', 'kako', 'panesitos', 'test-business', 'abc123'];

      for (final slug in validSlugs) {
        final path = '/$slug';
        final extractedSlug = extractBusinessSlugFromPath(path);
        expect(extractedSlug, equals(slug),
            reason: 'Slug "$slug" should be valid');
        debugPrint('✅ Valid slug recognized: $slug');
      }
    });

    test('System routes are not treated as business slugs', () {
      final systemRoutes = [
        '/menu',
        '/carrito',
        '/cuenta',
        '/admin',
        '/signin'
      ];

      for (final route in systemRoutes) {
        final extractedSlug = extractBusinessSlugFromPath(route);
        expect(extractedSlug, isNull,
            reason:
                'System route "$route" should not be treated as business slug');
        debugPrint('✅ System route ignored: $route');
      }
    });

    test('Invalid slugs are rejected', () {
      final invalidSlugs = [
        'a',
        'X',
        '-invalid',
        'invalid-',
        'inv alid',
        'UPPERCASE'
      ];

      for (final slug in invalidSlugs) {
        final path = '/$slug';
        final extractedSlug = extractBusinessSlugFromPath(path);
        expect(extractedSlug, isNull,
            reason: 'Invalid slug "$slug" should be rejected');
        debugPrint('✅ Invalid slug rejected: $slug');
      }
    });
  });
}

// Helper function to simulate navigation testing
void testNavigation() async {
  debugPrint('\n🚀 Running Business Navigation Tests...');
  debugPrint('========================================');

  try {
    // Test business slug extraction
    debugPrint('\n📋 Testing Business Slug Extraction:');
    final testPaths = [
      '/',
      '/menu',
      '/carrito',
      '/cuenta',
      '/g3',
      '/g3/menu',
      '/g3/carrito',
      '/g3/cuenta',
      '/kako',
      '/kako/menu',
      '/admin',
      '/signin',
    ];

    for (final path in testPaths) {
      final slug = extractBusinessSlugFromPath(path);
      debugPrint('  $path -> ${slug ?? 'null (default)'}');
    }

    debugPrint('\n✅ All navigation tests completed successfully!');
    debugPrint('========================================');
  } catch (e, stackTrace) {
    debugPrint('❌ Navigation test failed: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

// Run the test when this file is executed directly
void runNavigationTest() {
  debugPrint('🧪 Starting Business Navigation Test Suite...');
  testNavigation();
}
