// Unified business context provider that handles business slug changes and context switching
// This provider coordinates between URL routing and business data fetching
// REFACTORED: Consolidated UnifiedBusinessContext and ExplicitBusinessContext into single provider

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_constants.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/unified_catering_system.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/product_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/table_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_stats_provider.dart'
    as admin_stats;

part 'unified_business_context_provider.g.dart';

// =============================================================================
// Business Context State
// =============================================================================

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

// =============================================================================
// Shared Helper Functions (extracted to avoid duplication)
// =============================================================================

/// Build default business context
Future<BusinessContext> buildDefaultBusinessContext({
  required Ref ref,
  required bool shouldInvalidate,
  bool fullInvalidation = true,
}) async {
  try {
    debugPrint('🏢 Building default business context');

    final defaultBusinessId = BusinessConstants.defaultBusinessId;

    if (shouldInvalidate) {
      await invalidateBusinessProviders(ref,
          fullInvalidation: fullInvalidation);
      debugPrint('🔄 Providers invalidated due to business change to default');
    }

    return BusinessContext(
      businessId: defaultBusinessId,
      businessSlug: null,
      isDefault: true,
      lastUpdated: DateTime.now(),
    );
  } catch (e) {
    debugPrint('❌ Error building default context: $e');
    return BusinessContext(
      businessId: BusinessConstants.defaultBusinessId,
      businessSlug: null,
      isDefault: true,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Invalidate business-dependent providers
/// [fullInvalidation] - if true, invalidates all 20+ providers; if false, only core data providers
Future<void> invalidateBusinessProviders(Ref ref,
    {bool fullInvalidation = true}) async {
  debugPrint(
      '🔄 Invalidating business-dependent providers (full: $fullInvalidation)...');

  try {
    // Core data providers - always invalidated
    ref.invalidate(catalogItemsProvider);
    ref.invalidate(menuProductsProvider);
    ref.invalidate(menuCategoriesProvider);
    ref.invalidate(cartProvider);

    if (fullInvalidation) {
      // Catering providers
      ref.invalidate(cateringItemRepositoryProvider);
      ref.invalidate(cateringCategoryRepositoryProvider);

      // Order providers
      ref.invalidate(activeOrdersStreamProvider);
      ref.invalidate(allOrdersStreamProvider);
      ref.invalidate(pendingOrdersProvider);
      ref.invalidate(preparingOrdersProvider);
      ref.invalidate(readyOrdersProvider);
      ref.invalidate(admin_stats.orderStatsProvider);

      // Table management providers
      ref.invalidate(tablesStreamProvider);
      ref.invalidate(activeTablesProvider);
      ref.invalidate(availableTablesProvider);

      // Admin stats providers
      ref.invalidate(admin_stats.combinedAdminStatsProvider);
      ref.invalidate(admin_stats.tableStatsProvider);
      ref.invalidate(admin_stats.productStatsProvider);
      ref.invalidate(admin_stats.recentOrdersProvider);
      ref.invalidate(admin_stats.salesStatsProvider);

      // Restaurant service providers
      ref.invalidate(tableServiceProvider);
      ref.invalidate(orderServiceProvider);

      // Business configuration providers
      ref.invalidate(businessConfigProvider);
      ref.invalidate(businessTypeProvider);
      ref.invalidate(businessNameProvider);
      ref.invalidate(businessFeaturesProvider);
      ref.invalidate(businessSettingsProvider);
    }

    debugPrint('✅ Business-dependent providers invalidated successfully');
  } catch (e) {
    debugPrint('⚠️ Error invalidating some providers: $e');
  }
}

// =============================================================================
// Unified Business Context Provider (URL-based, automatic)
// =============================================================================

/// Unified business context provider that watches for slug changes and manages business context
@riverpod
class UnifiedBusinessContext extends _$UnifiedBusinessContext {
  String? _lastProcessedSlug;
  String? _lastProcessedBusinessId;
  BusinessContext? _cachedContext;

  @override
  Future<BusinessContext> build() async {
    final urlBusinessSlug = ref.watch(businessSlugFromUrlProvider);

    final slugChanged = _lastProcessedSlug != urlBusinessSlug;

    if (!slugChanged && _cachedContext != null) {
      final currentBusinessId =
          await ref.watch(urlAwareBusinessIdProvider.future);

      if (_lastProcessedBusinessId == currentBusinessId) {
        debugPrint(
            '⚡ Using cached context for ${urlBusinessSlug ?? 'default'} (ID: $currentBusinessId)');
        return _cachedContext!;
      } else {
        debugPrint(
            '🔄 Business ID changed: $_lastProcessedBusinessId -> $currentBusinessId');
        _lastProcessedBusinessId = currentBusinessId;
      }
    }

    debugPrint('🏢 Building unified business context...');
    debugPrint('🌐 URL business slug: $urlBusinessSlug');

    _lastProcessedSlug = urlBusinessSlug;
    final context = await _buildContextForSlug(urlBusinessSlug);
    _cachedContext = context;
    _lastProcessedBusinessId = context.businessId;

    return context;
  }

  Future<BusinessContext> _buildContextForSlug(String? urlBusinessSlug) async {
    if (urlBusinessSlug != null && urlBusinessSlug.isNotEmpty) {
      return await _buildBusinessContext(urlBusinessSlug);
    } else {
      final shouldInvalidate =
          await _shouldInvalidateProviders(BusinessConstants.defaultBusinessId);
      return await buildDefaultBusinessContext(
        ref: ref,
        shouldInvalidate: shouldInvalidate,
        fullInvalidation: true,
      );
    }
  }

  Future<bool> _shouldInvalidateProviders(String newBusinessId) async {
    try {
      if (newBusinessId == BusinessConstants.defaultBusinessId ||
          _cachedContext?.businessId == BusinessConstants.defaultBusinessId) {
        return true;
      }

      if (_cachedContext != null &&
          _cachedContext!.businessId != newBusinessId) {
        return true;
      }

      final currentBusinessId = ref.read(currentBusinessIdProvider);
      return currentBusinessId != newBusinessId;
    } catch (e) {
      debugPrint('⚠️ Error checking if providers should be invalidated: $e');
      return true;
    }
  }

  Future<BusinessContext> _buildBusinessContext(String businessSlug) async {
    try {
      debugPrint('🏢 Building context for business slug: $businessSlug');

      final slugService = ref.read(businessSlugServiceProvider);
      final businessId = await slugService.getBusinessIdFromSlug(businessSlug);

      if (businessId != null) {
        debugPrint(
            '🏢 Resolved business ID: $businessId for slug: $businessSlug');

        final shouldInvalidate = await _shouldInvalidateProviders(businessId);

        if (shouldInvalidate) {
          await invalidateBusinessProviders(ref, fullInvalidation: true);
          debugPrint('🔄 Providers invalidated due to business change');
        }

        return BusinessContext(
          businessId: businessId,
          businessSlug: businessSlug,
          isDefault: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        debugPrint(
            '⚠️ Business slug not found: $businessSlug, falling back to default');
        return await buildDefaultBusinessContext(
          ref: ref,
          shouldInvalidate: true,
          fullInvalidation: true,
        );
      }
    } catch (e) {
      debugPrint('❌ Error building business context: $e');
      return await buildDefaultBusinessContext(
        ref: ref,
        shouldInvalidate: false,
        fullInvalidation: true,
      );
    }
  }

  void refresh() {
    _lastProcessedSlug = null;
    _lastProcessedBusinessId = null;
    _cachedContext = null;
    ref.invalidateSelf();
  }
}

// =============================================================================
// Explicit Business Context Provider (slug-based, programmatic)
// =============================================================================

/// Explicit business context provider that works with a specific business slug
/// Use this during programmatic navigation to avoid race conditions with URL detection
@riverpod
class ExplicitBusinessContext extends _$ExplicitBusinessContext {
  @override
  Future<BusinessContext> build(String businessSlug) async {
    debugPrint('🏢 Building explicit business context for slug: $businessSlug');

    try {
      final slugService = ref.read(businessSlugServiceProvider);
      final businessId = await slugService.getBusinessIdFromSlug(businessSlug);

      if (businessId != null) {
        debugPrint(
            '🏢 Resolved business ID: $businessId for slug: $businessSlug');

        final currentBusinessId = ref.read(currentBusinessIdProvider);
        final shouldInvalidate = currentBusinessId != businessId;

        if (shouldInvalidate) {
          await invalidateBusinessProviders(ref, fullInvalidation: false);
          debugPrint('🔄 Providers invalidated (explicit)');
        }

        return BusinessContext(
          businessId: businessId,
          businessSlug: businessSlug,
          isDefault: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        debugPrint(
            '⚠️ Business slug not found: $businessSlug, falling back to default');
        return await buildDefaultBusinessContext(
          ref: ref,
          shouldInvalidate: true,
          fullInvalidation: false,
        );
      }
    } catch (e) {
      debugPrint('❌ Error building explicit business context: $e');
      return await buildDefaultBusinessContext(
        ref: ref,
        shouldInvalidate: false,
        fullInvalidation: false,
      );
    }
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

// =============================================================================
// Derived Providers (simplified access)
// =============================================================================

/// Provider for current business ID (simplified access)
@riverpod
String currentBusinessIdFromContext(Ref ref) {
  final contextAsync = ref.watch(unifiedBusinessContextProvider);
  return contextAsync.when(
    data: (context) => context.businessId,
    loading: () => BusinessConstants.defaultBusinessId,
    error: (_, __) => BusinessConstants.defaultBusinessId,
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
