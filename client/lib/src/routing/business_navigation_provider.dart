// Enhanced business navigation provider for optimized routing
// Manages business navigation state and prevents unnecessary rebuilds

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/unified_business_context_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_routing_provider.dart';

part 'business_navigation_provider.g.dart';

/// Business navigation state for tracking current business navigation
class BusinessNavigationState {
  const BusinessNavigationState({
    required this.businessSlug,
    required this.currentRoute,
    required this.businessContext,
  });

  final String businessSlug;
  final String currentRoute;
  final BusinessContext businessContext;

  BusinessNavigationState copyWith({
    String? businessSlug,
    String? currentRoute,
    BusinessContext? businessContext,
  }) {
    return BusinessNavigationState(
      businessSlug: businessSlug ?? this.businessSlug,
      currentRoute: currentRoute ?? this.currentRoute,
      businessContext: businessContext ?? this.businessContext,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessNavigationState &&
        other.businessSlug == businessSlug &&
        other.currentRoute == currentRoute &&
        other.businessContext == businessContext;
  }

  @override
  int get hashCode {
    return businessSlug.hashCode ^
        currentRoute.hashCode ^
        businessContext.hashCode;
  }
}

/// Provider for optimized business navigation state
@riverpod
class BusinessNavigationController extends _$BusinessNavigationController {
  String? _currentBusinessSlug;
  String? _currentRoute;
  String?
      _activeBusinessContext; // Track active business for context persistence

  @override
  BusinessNavigationState? build() {
    return null;
  }

  /// Set the current business context and route
  Future<void> setBusinessNavigation(String businessSlug, String route) async {
    debugPrint('🔄 Setting business navigation: $businessSlug -> $route');

    // Set active business context for persistence
    _activeBusinessContext = businessSlug;

    // Check if we're already on this business/route combination
    if (_currentBusinessSlug == businessSlug && _currentRoute == route) {
      final fullPath = route == '/' ? '/$businessSlug' : '/$businessSlug$route';
      debugPrint('✅ Already on $fullPath, skipping navigation');
      return;
    }

    // Check if we're changing routes within the same business
    final isSameBusiness = _currentBusinessSlug == businessSlug;

    if (isSameBusiness) {
      debugPrint('🏢 Same business, optimizing route change: $route');

      // Just update the route without re-fetching business context
      final currentState = state;
      if (currentState != null) {
        state = currentState.copyWith(currentRoute: route);
        _currentRoute = route;
        return;
      }
    }

    // New business or first load - fetch business context
    debugPrint('🌐 Loading business context for: $businessSlug');

    try {
      final businessContext =
          await ref.read(explicitBusinessContextProvider(businessSlug).future);

      // Update the currentBusinessIdProvider to match the new business context
      ref
          .read(currentBusinessIdProvider.notifier)
          .setBusinessId(businessContext.businessId);

      state = BusinessNavigationState(
        businessSlug: businessSlug,
        currentRoute: route,
        businessContext: businessContext,
      );

      _currentBusinessSlug = businessSlug;
      _currentRoute = route;

      // Construct the proper full path for logging
      final fullPath = route == '/' ? '/$businessSlug' : '/$businessSlug$route';
      debugPrint('✅ Business navigation set: $fullPath');
    } catch (error) {
      debugPrint('❌ Error setting business navigation: $error');
      rethrow;
    }
  }

  /// Update just the route within the current business
  void updateRoute(String route) {
    final currentState = state;
    if (currentState != null) {
      debugPrint('🔄 Updating route in ${currentState.businessSlug}: $route');
      state = currentState.copyWith(currentRoute: route);
      _currentRoute = route;
    }
  }

  /// Clear navigation state
  void clear() {
    debugPrint('🧹 Clearing business navigation state');
    state = null;
    _currentBusinessSlug = null;
    _currentRoute = null;
    _activeBusinessContext = null; // Clear active context on app reload
  }

  /// Get the currently active business context for persistence
  String? get activeBusinessContext => _activeBusinessContext;

  /// Check if user is currently in a business context (not default)
  bool get hasActiveBusinessContext =>
      _activeBusinessContext != null && _activeBusinessContext != 'default';
}

/// Provider for cached business context - prevents re-fetching
/// Enhanced with TTL-based cache invalidation
@riverpod
class CachedBusinessContext extends _$CachedBusinessContext {
  final Map<String, BusinessContext> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Cache time-to-live duration
  static const Duration cacheTTL = Duration(minutes: 15);

  @override
  BusinessContext? build(String businessSlug) {
    return _cache[businessSlug];
  }

  /// Check if cache entry is stale
  bool _isStale(String businessSlug) {
    final timestamp = _cacheTimestamps[businessSlug];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > cacheTTL;
  }

  /// Get business context with caching and TTL
  Future<BusinessContext> getBusinessContext(String businessSlug,
      {bool forceRefresh = false}) async {
    // Return cached version if available and not stale
    if (!forceRefresh &&
        _cache.containsKey(businessSlug) &&
        !_isStale(businessSlug)) {
      debugPrint('📦 Using cached business context for: $businessSlug');
      return _cache[businessSlug]!;
    }

    // Check if cache is stale
    if (_cache.containsKey(businessSlug) && _isStale(businessSlug)) {
      debugPrint('⏰ Cache stale for $businessSlug, refreshing...');
    }

    // Fetch and cache
    debugPrint('🌐 Fetching business context for: $businessSlug');
    final context =
        await ref.read(explicitBusinessContextProvider(businessSlug).future);

    _cache[businessSlug] = context;
    _cacheTimestamps[businessSlug] = DateTime.now();
    state = context;

    debugPrint('📦 Cached business context for: $businessSlug');
    return context;
  }

  /// Get cache age for a business slug
  Duration? getCacheAge(String businessSlug) {
    final timestamp = _cacheTimestamps[businessSlug];
    if (timestamp == null) return null;
    return DateTime.now().difference(timestamp);
  }

  /// Clear cache for a specific business
  void clearCache(String businessSlug) {
    _cache.remove(businessSlug);
    _cacheTimestamps.remove(businessSlug);
    ref.invalidateSelf();
  }

  /// Clear all cached contexts
  void clearAllCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    ref.invalidateSelf();
  }

  /// Preload cache for multiple businesses (useful for startup)
  Future<void> preloadCache(List<String> businessSlugs) async {
    for (final slug in businessSlugs) {
      if (!_cache.containsKey(slug) || _isStale(slug)) {
        try {
          await getBusinessContext(slug);
        } catch (e) {
          debugPrint('⚠️ Failed to preload cache for $slug: $e');
        }
      }
    }
  }
}

/// Provider for current business navigation info
/// FIXED: Use ref.read for urlBusinessSlug to avoid circular dependency
@riverpod
BusinessNavigationInfo? currentBusinessNavigation(
    CurrentBusinessNavigationRef ref) {
  final navigationState = ref.watch(businessNavigationControllerProvider);

  // FIXED: Use ref.read instead of ref.watch to break circular dependency
  // This prevents: currentBusinessNavigation -> businessSlugFromUrl -> currentRouteLocation -> goRouter cycle
  final urlBusinessSlug = ref.read(businessSlugFromUrlProvider);

  if (navigationState != null) {
    return BusinessNavigationInfo(
      businessSlug: navigationState.businessSlug,
      currentRoute: navigationState.currentRoute,
      isFromUrl: urlBusinessSlug == navigationState.businessSlug,
    );
  }

  return null;
}

/// Business navigation information
class BusinessNavigationInfo {
  const BusinessNavigationInfo({
    required this.businessSlug,
    required this.currentRoute,
    required this.isFromUrl,
  });

  final String businessSlug;
  final String currentRoute;
  final bool isFromUrl;
}

/// Provider to check if navigation should be optimized (same business)
/// FIXED: Use ref.read to avoid circular dependency with currentBusinessNavigationProvider
@riverpod
bool shouldOptimizeNavigation(ShouldOptimizeNavigationRef ref,
    String targetBusinessSlug, String targetRoute) {
  // Use ref.read instead of ref.watch to avoid circular rebuilds
  // This breaks the cycle: shouldOptimizeNavigation -> currentBusinessNavigation -> businessNavigationController
  final currentNavigation = ref.read(currentBusinessNavigationProvider);

  if (currentNavigation == null) return false;

  return currentNavigation.businessSlug == targetBusinessSlug;
}

/// Helper class for business-aware routing logic
class BusinessAwareRoutingHelper {
  static String getBusinessAwarePath(WidgetRef ref, String targetPath) {
    final navigationController =
        ref.read(businessNavigationControllerProvider.notifier);

    // Check if user has an active business context
    if (navigationController.hasActiveBusinessContext) {
      final activeBusinessSlug = navigationController.activeBusinessContext!;

      // If target path doesn't have a business slug, but user is in business context
      if (!targetPath.startsWith('/$activeBusinessSlug') &&
          !_isSystemRoute(targetPath) &&
          !_hasBusinessSlug(targetPath)) {
        // Prefix with active business slug for context persistence
        final businessAwarePath = targetPath == '/'
            ? '/$activeBusinessSlug'
            : '/$activeBusinessSlug$targetPath';

        debugPrint(
            '🎯 Business-aware routing: $targetPath -> $businessAwarePath');
        return businessAwarePath;
      }
    }

    // Special handling for admin routes and all subroutes: always prefix with business slug (even for default)
    if (targetPath.startsWith('/admin') ||
        targetPath.startsWith('/admin-setup')) {
      final businessSlug =
          navigationController.activeBusinessContext ?? 'default';
      if (businessSlug == 'default') {
        return targetPath;
      }
      // If already prefixed with /<slug>/admin, do not double-prefix
      if (targetPath.startsWith('/$businessSlug/admin')) {
        return targetPath;
      }
      return '/$businessSlug$targetPath';
    }

    // Return original path if no business context or path already has business context
    return targetPath;
  }

  /// Check if a path is a system route that shouldn't be business-aware
  static bool _isSystemRoute(String path) {
    final systemRoutes = {
      '/signin',
      '/signup',
      '/onboarding',
      '/error',
      '/startup',
      '/business-setup'
      // '/admin', '/admin-setup' removed to allow business-aware admin routes
    };
    return systemRoutes.any((route) => path.startsWith(route));
  }

  /// Check if a path already has a business slug
  static bool _hasBusinessSlug(String path) {
    if (!path.startsWith('/')) return false;

    final segments = path.substring(1).split('/');
    if (segments.isEmpty) return false;

    final firstSegment = segments.first;

    // Check if first segment looks like a business slug (not a default route)
    final defaultRoutes = {
      'menu',
      'carrito',
      'cart',
      'cuenta',
      'ordenes',
      'catering-menu',
      'catering-quote',
      'subscripciones',
      'catering',
      'populares',
      'categorias',
      'platos',
      'completar-orden',
      'meal-plans'
    };

    return !defaultRoutes.contains(firstSegment) && firstSegment.length >= 2;
  }
}
