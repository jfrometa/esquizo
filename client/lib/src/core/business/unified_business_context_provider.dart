// Unified business context provider that handles business slug changes and context switching
// This provider coordinates between URL routing and business data fetching

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/unified_catering_system.dart';
import 'package:starter_architecture_flutter_firebase/src/core/local_storange/local_storage_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/product_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';

part 'unified_business_context_provider.g.dart';

/// Business context state that tracks current business and slug changes
@immutable
class BusinessContext {
  const BusinessContext({
    required this.businessId,
    required this.businessSlug,
    required this.isDefault,
    required this.lastUpdated,
  });

  final String businessId;
  final String? businessSlug; // null for default business
  final bool isDefault;
  final DateTime lastUpdated;

  BusinessContext copyWith({
    String? businessId,
    String? businessSlug,
    bool? isDefault,
    DateTime? lastUpdated,
  }) {
    return BusinessContext(
      businessId: businessId ?? this.businessId,
      businessSlug: businessSlug ?? this.businessSlug,
      isDefault: isDefault ?? this.isDefault,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessContext &&
          runtimeType == other.runtimeType &&
          businessId == other.businessId &&
          businessSlug == other.businessSlug &&
          isDefault == other.isDefault;

  @override
  int get hashCode =>
      businessId.hashCode ^ businessSlug.hashCode ^ isDefault.hashCode;

  @override
  String toString() =>
      'BusinessContext(businessId: $businessId, businessSlug: $businessSlug, isDefault: $isDefault)';
}

/// Unified business context provider that watches for slug changes and manages business context
@riverpod
class UnifiedBusinessContext extends _$UnifiedBusinessContext {
  @override
  Future<BusinessContext> build() async {
    // Watch for URL-based business slug changes
    final urlBusinessSlug = ref.watch(businessSlugFromUrlProvider);

    debugPrint('🏢 Building unified business context...');
    debugPrint('🌐 URL business slug: $urlBusinessSlug');

    if (urlBusinessSlug != null && urlBusinessSlug.isNotEmpty) {
      // Business-specific routing (e.g., /g3, /kako)
      debugPrint(
          '🏢 Using business-specific routing for slug: $urlBusinessSlug');
      return await _buildBusinessContext(urlBusinessSlug);
    } else {
      // Default business routing (e.g., /, /menu, /carrito)
      debugPrint('🏠 Using default business routing');
      return await _buildDefaultContext();
    }
  }

  /// Build business context for specific business slug
  Future<BusinessContext> _buildBusinessContext(String businessSlug) async {
    try {
      debugPrint('🏢 Building business context for slug: $businessSlug');

      // Fetch business ID from slug service
      final slugService = ref.read(businessSlugServiceProvider);
      debugPrint('🔍 Fetching business ID for slug: $businessSlug');
      final businessId = await slugService.getBusinessIdFromSlug(businessSlug);

      if (businessId != null) {
        debugPrint('✅ Business ID resolved: $businessId');
        debugPrint('🏢 Resolved business ID: $businessId for slug: $businessSlug');

        // Update local storage to maintain persistence
        final localStorage = ref.read(localStorageServiceProvider);
        await localStorage.setString('businessId', businessId);

        // Create and return the business context
        return BusinessContext(
          businessId: businessId,
          businessSlug: '/$businessSlug',
          isDefault: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        debugPrint('❌ Failed to resolve business ID for slug: $businessSlug');
        debugPrint('⚠️ Business slug not found: $businessSlug, falling back to default');
        return await _buildDefaultContext();
      }
    } catch (e) {
      debugPrint('❌ Error building business context: $e');
      return await _buildDefaultContext();
    }
  }

  /// Build default business context
  Future<BusinessContext> _buildDefaultContext() async {
    try {
      debugPrint('🏢 Building default business context');

      // Get default business ID from storage or use fallback
      final storedBusinessId = await ref.read(initBusinessIdProvider.future);

      return BusinessContext(
        businessId: storedBusinessId,
        businessSlug: null,
        isDefault: true,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Error building default context: $e');
      return BusinessContext(
        businessId: 'default',
        businessSlug: null,
        isDefault: true,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Invalidate all business-dependent providers when business context changes
  Future<void> _invalidateBusinessDependentProviders() async {
    debugPrint('🔄 Invalidating business-dependent providers...');

    try {
      // Core business providers
      ref.invalidate(currentBusinessIdProvider);
      ref.invalidate(businessConfigProvider);
      ref.invalidate(urlAwareBusinessIdProvider);

      // Catalog and menu providers
      ref.invalidate(catalogItemsProvider);
      ref.invalidate(menuProductsProvider);
      ref.invalidate(menuCategoriesProvider);

      // Catering providers
      ref.invalidate(cateringItemRepositoryProvider);
      ref.invalidate(cateringCategoryRepositoryProvider);
      // ref.invalidate(allCateringItemsProvider);
      // ref.invalidate(allCateringCategoriesProvider);

      // Cart provider (business-specific cart)
      ref.invalidate(cartProvider);

      debugPrint('✅ All business-dependent providers invalidated');
    } catch (e) {
      debugPrint('⚠️ Error invalidating some providers: $e');
    }
  }

  /// Force refresh the business context (useful for manual context switching)
  void refresh() {
    ref.invalidateSelf();
  }

  /// Switch to a specific business slug
  Future<void> switchToBusiness(String businessSlug) async {
    debugPrint('🔄 Switching to business: $businessSlug');

    // This will be handled by the URL routing, but we can force a refresh
    ref.invalidateSelf();
  }

  /// Switch to default business context
  Future<void> switchToDefault() async {
    debugPrint('🔄 Switching to default business');

    // This will be handled by the URL routing, but we can force a refresh
    ref.invalidateSelf();
  }
}

/// Explicit business context provider that works with a specific business slug
/// This avoids race conditions with URL detection during navigation
@riverpod
class ExplicitBusinessContext extends _$ExplicitBusinessContext {
  @override
  Future<BusinessContext> build(String businessSlug) async {
    debugPrint('🏢 Building explicit business context for slug: $businessSlug');

    try {
      // Get business ID from slug
      final slugService = ref.read(businessSlugServiceProvider);
      final businessId = await slugService.getBusinessIdFromSlug(businessSlug);

      if (businessId != null) {
        debugPrint(
            '🏢 Resolved business ID: $businessId for slug: $businessSlug');

        // Update local storage to maintain persistence
        final localStorage = ref.read(localStorageServiceProvider);
        await localStorage.setString('businessId', businessId);

        // Invalidate all business-dependent providers
        await _invalidateBusinessDependentProviders();

        final context = BusinessContext(
          businessId: businessId,
          businessSlug: businessSlug,
          isDefault: false,
          lastUpdated: DateTime.now(),
        );

        debugPrint('✅ Explicit business context built: $context');
        return context;
      } else {
        debugPrint(
            '⚠️ Business slug not found: $businessSlug, falling back to default');
        return await _buildDefaultContext();
      }
    } catch (e) {
      debugPrint('❌ Error building explicit business context: $e');
      return await _buildDefaultContext();
    }
  }

  /// Build default business context (shared with UnifiedBusinessContext)
  Future<BusinessContext> _buildDefaultContext() async {
    try {
      debugPrint('🏢 Building default business context from explicit provider');

      // Get default business ID from storage or use fallback
      final storedBusinessId = await ref.read(initBusinessIdProvider.future);

      final context = BusinessContext(
        businessId: storedBusinessId,
        businessSlug: null,
        isDefault: true,
        lastUpdated: DateTime.now(),
      );

      debugPrint('✅ Default business context built: $context');
      return context;
    } catch (e) {
      debugPrint('❌ Error building default context: $e');
      // Fallback to hardcoded default
      return BusinessContext(
        businessId: 'default',
        businessSlug: null,
        isDefault: true,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Invalidate all business-dependent providers when business context changes
  Future<void> _invalidateBusinessDependentProviders() async {
    debugPrint('🔄 Invalidating business-dependent providers...');

    try {
      // Core business providers
      ref.invalidate(currentBusinessIdProvider);
      ref.invalidate(businessConfigProvider);
      ref.invalidate(urlAwareBusinessIdProvider);

      // Catalog and menu providers
      ref.invalidate(catalogItemsProvider);
      ref.invalidate(menuProductsProvider);
      ref.invalidate(menuCategoriesProvider);

      // Catering providers
      // ref.invalidate(cateringItemRepositoryProvider);
      // ref.invalidate(cateringCategoryRepositoryProvider);
      // ref.invalidate(allCateringItemsProvider);
      // ref.invalidate(allCateringCategoriesProvider);

      // Cart provider (business-specific cart)
      ref.invalidate(cartProvider);

      debugPrint('✅ All business-dependent providers invalidated');
    } catch (e) {
      debugPrint('⚠️ Error invalidating some providers: $e');
    }
  }

  /// Force refresh the business context (useful for manual context switching)
  void refresh() {
    ref.invalidateSelf();
  }

  /// Switch to a specific business slug
  Future<void> switchToBusiness(String businessSlug) async {
    debugPrint('🔄 Switching to business: $businessSlug');

    // This will be handled by the URL routing, but we can force a refresh
    ref.invalidateSelf();
  }

  /// Switch to default business context
  Future<void> switchToDefault() async {
    debugPrint('🔄 Switching to default business');

    // This will be handled by the URL routing, but we can force a refresh
    ref.invalidateSelf();
  }
}

/// Provider for current business ID (simplified access)
@riverpod
String currentBusinessIdFromContext(Ref ref) {
  final contextAsync = ref.watch(unifiedBusinessContextProvider);
  return contextAsync.when(
    data: (context) => context.businessId,
    loading: () => 'default',
    error: (_, __) => 'default',
  );
}

/// Provider for current business slug (simplified access)
@riverpod
String? currentBusinessSlugFromContext(Ref ref) {
  final contextAsync = ref.watch(unifiedBusinessContextProvider);
  return contextAsync.when(
    data: (context) => context.businessSlug,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Provider to check if currently using default business
@riverpod
bool isDefaultBusinessContext(Ref ref) {
  final contextAsync = ref.watch(unifiedBusinessContextProvider);
  return contextAsync.when(
    data: (context) => context.isDefault,
    loading: () => true,
    error: (_, __) => true,
  );
}

/// Provider to check if currently using business-specific context
@riverpod
bool isBusinessSpecificContext(Ref ref) {
  final contextAsync = ref.watch(unifiedBusinessContextProvider);
  return contextAsync.when(
    data: (context) => !context.isDefault,
    loading: () => false,
    error: (_, __) => false,
  );
}

/// Provider that returns the current business ID based on routing context
/// - If on business-specific route (e.g., /g3), returns the business ID for that slug
/// - If on default route (e.g., /menu), returns the default business ID
@riverpod
Future<String> currentRoutingBusinessId(Ref ref) async {
  final unifiedContext = await ref.watch(unifiedBusinessContextProvider.future);
  return unifiedContext.businessId;
}

/// Provider that checks if we're currently in business-specific routing mode
@riverpod
bool isBusinessSpecificRouting(Ref ref) {
  final urlBusinessSlug = ref.watch(businessSlugFromUrlProvider);
  return urlBusinessSlug != null && urlBusinessSlug.isNotEmpty;
}

/// Provider that returns the current business slug (null for default routing)
@riverpod
String? currentBusinessSlug(Ref ref) {
  return ref.watch(businessSlugFromUrlProvider);
}
