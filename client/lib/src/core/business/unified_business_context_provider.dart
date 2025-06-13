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
  // Track the last processed business slug to prevent unnecessary rebuilds
  String? _lastProcessedSlug;
  String? _lastProcessedBusinessId;
  BusinessContext? _cachedContext;

  @override
  Future<BusinessContext> build() async {
    // Watch for URL-based business slug changes
    final urlBusinessSlug = ref.watch(businessSlugFromUrlProvider);

    // ⚠️ OPTIMIZATION: Check if context needs to be rebuilt
    // Always rebuild if slug changed OR if business ID might have changed
    final slugChanged = _lastProcessedSlug != urlBusinessSlug;

    if (!slugChanged && _cachedContext != null) {
      // Even if slug hasn't changed, we need to check if business ID might have changed
      // This handles cases where we go from default -> business or business -> business
      final currentBusinessId =
          await ref.watch(urlAwareBusinessIdProvider.future);

      if (_lastProcessedBusinessId == currentBusinessId) {
        debugPrint(
            '⚡ Using cached context for ${urlBusinessSlug ?? 'default'} (ID: $currentBusinessId)');
        return _cachedContext!;
      } else {
        debugPrint(
            '🔄 Business ID changed: $_lastProcessedBusinessId -> $currentBusinessId, rebuilding context');
        _lastProcessedBusinessId = currentBusinessId;
      }
    }

    debugPrint('🏢 Building unified business context...');
    debugPrint('🌐 URL business slug: $urlBusinessSlug');
    debugPrint('🔄 Slug changed from $_lastProcessedSlug to $urlBusinessSlug');

    _lastProcessedSlug = urlBusinessSlug;
    final context = await _buildContextForSlug(urlBusinessSlug);
    _cachedContext = context;

    // Update business ID tracking
    _lastProcessedBusinessId = context.businessId;

    return context;
  }

  /// Build context for the given slug (or null for default)
  Future<BusinessContext> _buildContextForSlug(String? urlBusinessSlug) async {
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

  /// Check if providers should be invalidated based on business ID change
  Future<bool> _shouldInvalidateProviders(String newBusinessId) async {
    try {
      // Always invalidate when business ID changes from/to default
      if (newBusinessId == 'default' ||
          _cachedContext?.businessId == 'default') {
        debugPrint(
            '🔄 Business change involves default, invalidating providers');
        return true;
      }

      // Check if we have a cached context with a different business ID
      if (_cachedContext != null &&
          _cachedContext!.businessId != newBusinessId) {
        debugPrint(
            '🔄 Business ID changed in cache: ${_cachedContext!.businessId} -> $newBusinessId');
        return true;
      }

      // Check local storage for the current business ID
      final localStorage = ref.read(localStorageServiceProvider);
      final storedBusinessId = localStorage.getString('businessId');

      // Also check the current business ID provider to detect any changes
      final currentBusinessId = ref.read(currentBusinessIdProvider);

      final hasChanged = storedBusinessId != newBusinessId ||
          currentBusinessId != newBusinessId;

      if (hasChanged) {
        debugPrint(
            '🔄 Business ID changed: $currentBusinessId (current) / $storedBusinessId (stored) -> $newBusinessId');
      }

      return hasChanged;
    } catch (e) {
      debugPrint('⚠️ Error checking if providers should be invalidated: $e');
      return true; // When in doubt, invalidate to be safe
    }
  }

  /// Build business context for specific business slug
  Future<BusinessContext> _buildBusinessContext(String businessSlug) async {
    try {
      debugPrint('🏢 Building context for business slug: $businessSlug');

      // Always fetch business ID from slug service to ensure fresh data
      final slugService = ref.read(businessSlugServiceProvider);
      final businessId = await slugService.getBusinessIdFromSlug(businessSlug);

      if (businessId != null) {
        debugPrint(
            '🏢 Resolved business ID: $businessId for slug: $businessSlug');

        // Check if business ID has actually changed to decide on provider invalidation
        final shouldInvalidate = await _shouldInvalidateProviders(businessId);

        if (shouldInvalidate) {
          // Update local storage to maintain persistence
          final localStorage = ref.read(localStorageServiceProvider);
          await localStorage.setString('businessId', businessId);

          // Invalidate all business-dependent providers when business changes
          await _invalidateBusinessDependentProviders();
          debugPrint('🔄 Providers invalidated due to business change');
        } else {
          debugPrint('⚡ Business ID unchanged, skipping provider invalidation');
        }

        final context = BusinessContext(
          businessId: businessId,
          businessSlug: businessSlug,
          isDefault: false,
          lastUpdated: DateTime.now(),
        );

        debugPrint('✅ Business context built: $context');
        return context;
      } else {
        debugPrint(
            '⚠️ Business slug not found: $businessSlug, falling back to default');
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

      // IMPORTANT: Always use 'default' business when accessing routes without business slugs
      // This ensures that accessing '/', '/menu', '/carrito', etc. always fetches the 'default' business
      const defaultBusinessId = 'default';

      // Check if business ID has changed to decide on provider invalidation
      final shouldInvalidate =
          await _shouldInvalidateProviders(defaultBusinessId);

      if (shouldInvalidate) {
        // Update local storage to maintain persistence only if needed
        final localStorage = ref.read(localStorageServiceProvider);
        await localStorage.setString('businessId', defaultBusinessId);

        // Invalidate all business-dependent providers when business changes
        await _invalidateBusinessDependentProviders();
        debugPrint(
            '🔄 Providers invalidated due to business change to default');
      }

      final context = BusinessContext(
        businessId: defaultBusinessId,
        businessSlug: null,
        isDefault: true,
        lastUpdated: DateTime.now(),
      );

      debugPrint(
          '✅ Default business context built: $context (always using "default")');
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
  /// OPTIMIZED: Avoid invalidating core providers to prevent circular rebuilds
  Future<void> _invalidateBusinessDependentProviders() async {
    debugPrint('🔄 Invalidating business-dependent providers...');

    try {
      // ⚠️ CRITICAL: Don't invalidate core business providers to avoid circular rebuilds
      // These providers manage their own state and don't need to be invalidated:
      // - currentBusinessIdProvider (now uses StateNotifier pattern)
      // - urlAwareBusinessIdProvider (manages its own caching)
      // - businessConfigProvider (commented out to prevent theme rebuilds)

      // Data providers - these should be invalidated for business changes
      ref.invalidate(catalogItemsProvider);
      ref.invalidate(menuProductsProvider);
      ref.invalidate(menuCategoriesProvider);

      // Catering providers
      ref.invalidate(cateringItemRepositoryProvider);
      ref.invalidate(cateringCategoryRepositoryProvider);

      // Cart provider (business-specific cart)
      ref.invalidate(cartProvider);

      debugPrint('✅ Business-dependent providers invalidated successfully');
    } catch (e) {
      debugPrint('⚠️ Error invalidating some providers: $e');
    }
  }

  /// Force refresh the business context (useful for manual context switching)
  void refresh() {
    // Clear cache to force rebuild on next access
    _lastProcessedSlug = null;
    _lastProcessedBusinessId = null;
    _cachedContext = null;
    ref.invalidateSelf();
  }

  /// Switch to a specific business slug
  Future<void> switchToBusiness(String businessSlug) async {
    debugPrint('🔄 Switching to business: $businessSlug');
    // Clear cache and let the URL routing handle the change
    _lastProcessedSlug = null;
    _lastProcessedBusinessId = null;
    _cachedContext = null;
  }

  /// Switch to default business context
  Future<void> switchToDefault() async {
    debugPrint('🔄 Switching to default business');
    // Clear cache and let the URL routing handle the change
    _lastProcessedSlug = null;
    _lastProcessedBusinessId = null;
    _cachedContext = null;
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

        // Check if business ID has actually changed to avoid unnecessary invalidations
        final shouldInvalidate =
            await _shouldInvalidateProvidersExplicit(businessId);

        if (shouldInvalidate) {
          // Update local storage to maintain persistence
          final localStorage = ref.read(localStorageServiceProvider);
          await localStorage.setString('businessId', businessId);

          // Invalidate all business-dependent providers only if business actually changed
          await _invalidateBusinessDependentProviders();
          debugPrint(
              '🔄 Providers invalidated due to business change (explicit)');
        } else {
          debugPrint(
              '⚡ Business ID unchanged, skipping provider invalidation (explicit)');
        }

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

  /// Check if providers should be invalidated based on business ID change (explicit context)
  Future<bool> _shouldInvalidateProvidersExplicit(String newBusinessId) async {
    try {
      // Always invalidate when business ID changes from/to default
      if (newBusinessId == 'default') {
        debugPrint(
            '🔄 Business change to default (explicit), invalidating providers');
        return true;
      }

      // Check local storage for the current business ID
      final localStorage = ref.read(localStorageServiceProvider);
      final storedBusinessId = localStorage.getString('businessId');

      // Also check the current business ID provider to detect any changes
      final currentBusinessId = ref.read(currentBusinessIdProvider);

      final hasChanged = storedBusinessId != newBusinessId ||
          currentBusinessId != newBusinessId;

      if (hasChanged) {
        debugPrint(
            '🔄 Business ID changed (explicit): $currentBusinessId (current) / $storedBusinessId (stored) -> $newBusinessId');
      }

      return hasChanged;
    } catch (e) {
      debugPrint(
          '⚠️ Error checking if providers should be invalidated (explicit): $e');
      return true; // When in doubt, invalidate to be safe
    }
  }

  /// Build default business context (shared with UnifiedBusinessContext)
  Future<BusinessContext> _buildDefaultContext() async {
    try {
      debugPrint('🏢 Building default business context from explicit provider');

      // IMPORTANT: Always use 'default' business when accessing routes without business slugs
      // This ensures that accessing '/', '/menu', '/carrito', etc. always fetches the 'default' business
      const defaultBusinessId = 'default';

      // Check if business ID has changed to decide on provider invalidation
      final shouldInvalidate =
          await _shouldInvalidateProvidersExplicit(defaultBusinessId);

      if (shouldInvalidate) {
        // Update local storage to maintain persistence only if needed
        final localStorage = ref.read(localStorageServiceProvider);
        await localStorage.setString('businessId', defaultBusinessId);

        // Invalidate all business-dependent providers when business changes
        await _invalidateBusinessDependentProviders();
        debugPrint(
            '🔄 Providers invalidated due to business change to default (explicit)');
      }

      final context = BusinessContext(
        businessId: defaultBusinessId,
        businessSlug: null,
        isDefault: true,
        lastUpdated: DateTime.now(),
      );

      debugPrint(
          '✅ Default business context built: $context (always using "default")');
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

  /// Invalidate all business-dependent providers when business context changes (explicit)
  /// OPTIMIZED: Avoid invalidating core providers to prevent circular rebuilds
  Future<void> _invalidateBusinessDependentProviders() async {
    debugPrint('🔄 Invalidating business-dependent providers (explicit)...');

    try {
      // ⚠️ CRITICAL: Don't invalidate core business providers to avoid circular rebuilds
      // These providers manage their own state and don't need to be invalidated:
      // - currentBusinessIdProvider (now uses StateNotifier pattern)
      // - urlAwareBusinessIdProvider (manages its own caching)
      // - businessConfigProvider (commented out to prevent theme rebuilds)

      // Data providers - these should be invalidated for business changes
      ref.invalidate(catalogItemsProvider);
      ref.invalidate(menuProductsProvider);
      ref.invalidate(menuCategoriesProvider);

      // Cart provider (business-specific cart)
      ref.invalidate(cartProvider);

      debugPrint(
          '✅ Business-dependent providers invalidated successfully (explicit)');
    } catch (e) {
      debugPrint('⚠️ Error invalidating some providers (explicit): $e');
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
