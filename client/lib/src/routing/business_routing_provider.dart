// Business routing provider for URL-based business access
// Handles extracting business slug from URL paths like /panesitos

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/local_storange/local_storage_service.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/web/web_utils.dart';

part 'business_routing_provider.g.dart';

/// Provider that gets the current route location without circular dependencies
/// OPTIMIZED: Uses direct browser URL reading instead of watching goRouter
@riverpod
String currentRouteLocation(CurrentRouteLocationRef ref) {
  if (!kIsWeb) return '/';

  // CRITICAL FIX: Get current path directly from browser instead of watching goRouter
  // This breaks the circular dependency: currentRouteLocation -> goRouter -> ... -> currentRouteLocation
  String currentPath = '/';
  try {
    currentPath = WebUtils.getCurrentPath();
    debugPrint('🧭 Current route location (direct browser): $currentPath');
  } catch (e) {
    debugPrint('⚠️ Error getting current path from browser: $e');
    // Fallback to root path
    currentPath = '/';
  }

  return currentPath;
}

/// Provider for immediate URL detection during app startup
/// This runs once at startup to capture the initial URL before routing begins
@riverpod
String initialUrlPath(Ref ref) {
  if (!kIsWeb) return '/';

  // Get the actual browser URL immediately when this provider is first accessed
  String initialPath = '/';
  try {
    initialPath = WebUtils.getCurrentPath();
    debugPrint('🌐 Initial URL path detected at startup: $initialPath');
  } catch (e) {
    debugPrint('⚠️ Error getting initial URL path: $e');
  }

  return initialPath;
}

/// Provider for early business slug detection during app startup
/// This provides immediate business context before routing is fully initialized
@riverpod
String? earlyBusinessSlug(Ref ref) {
  if (!kIsWeb) return null;

  // Get the initial URL path
  final initialPath = ref.watch(initialUrlPathProvider);

  final extractedSlug = extractBusinessSlugFromPath(initialPath);
  debugPrint(
      '🚀 Early business slug detection: $extractedSlug from initial path: $initialPath');

  return extractedSlug;
}

/// Provider that extracts business slug from the current URL path
/// Now reactive to route changes via currentRouteLocation AND detects initial URL
@riverpod
String? businessSlugFromUrl(Ref ref) {
  if (!kIsWeb) return null;

  // Watch the current route location to make this provider reactive
  final currentPath = ref.watch(currentRouteLocationProvider);

  debugPrint('🏢 Business slug detection from current path: $currentPath');

  // Determine which path to use for business slug extraction
  String pathToAnalyze = currentPath;

  // Also check browser URL directly for more reliable initial detection
  if (kIsWeb) {
    try {
      // Get the actual browser path for comparison
      final browserPath = WebUtils.getCurrentPath();
      debugPrint('🌐 Browser path: $browserPath, Current path: $currentPath');

      // Use browser path if it's different and more specific
      if (browserPath != currentPath &&
          browserPath != '/' &&
          browserPath.isNotEmpty) {
        pathToAnalyze = browserPath;
        debugPrint(
            '🔄 Using browser path for more accurate detection: $pathToAnalyze');
      }
    } catch (e) {
      debugPrint('⚠️ Error getting browser path: $e');
    }
  }

  final extractedSlug = extractBusinessSlugFromPath(pathToAnalyze);
  debugPrint(
      '🏢 Extracted business slug: $extractedSlug from path: $pathToAnalyze');

  return extractedSlug;
}

/// Extract business slug from URL path
/// Supports formats like:
/// - /panesitos -> panesitos
/// - /panesitos/menu -> panesitos
/// - /admin -> null (admin doesn't use business routing)
/// - /signin -> null (auth pages don't use business routing)
String? extractBusinessSlugFromPath(String path) {
  // Only handle paths that start with '/'
  if (!path.startsWith('/')) {
    return null;
  }

  // Remove leading slash
  path = path.substring(1);

  // Skip empty paths
  if (path.isEmpty) return null;

  // Extract first segment
  final segments = path.split('/');
  final firstSegment = segments.first;

  // Skip system/auth routes that don't represent business slugs
  // These are all the root-level paths defined in the router
  final systemRoutes = {
    // System/auth routes
    'admin',
    'signin',
    'signup',
    'onboarding',
    'error',
    'startup',
    'business-setup',
    'admin-setup',
    'authenticated-profile',

    // Default business routes (when no business slug is present)
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
    'meal-plans',

    // Admin panel routes
    'dashboard',
    'products',
    'orders',
    'settings',
  };

  if (systemRoutes.contains(firstSegment)) {
    return null;
  }

  // If the first segment looks like a business slug, return it
  // Business slugs should be non-empty and not contain special chars
  if (firstSegment.isNotEmpty && _isValidBusinessSlug(firstSegment)) {
    return firstSegment;
  }

  return null;
}

/// Check if a string is a valid business slug format
bool _isValidBusinessSlug(String slug) {
  // Business slugs should:
  // - Be at least 2 characters long
  // - Not contain spaces or special routing characters
  // - Only contain lowercase letters, numbers, and hyphens
  // - Not start or end with hyphens
  if (slug.length < 2 || slug.length > 50) return false;
  if (slug.contains(' ') || slug.contains('?') || slug.contains('#'))
    return false;
  if (slug.startsWith('-') || slug.endsWith('-')) return false;
  if (slug.contains('--')) return false; // No consecutive hyphens

  // Check valid pattern: lowercase letters, numbers, and hyphens only
  final validPattern = RegExp(r'^[a-z0-9-]+$');
  if (!validPattern.hasMatch(slug)) return false;

  return true;
}

/// Provider for URL-aware business ID
/// This provider combines URL-based business slug with fallback to local storage
/// OPTIMIZED: Reduces unnecessary rebuilds by using ref.read for services
@riverpod
class UrlAwareBusinessId extends _$UrlAwareBusinessId {
  String? _lastProcessedSlug;
  String? _lastResolvedBusinessId;

  @override
  Future<String> build() async {
    debugPrint('🔄 URL-aware business ID provider building...');

    // First, try to get business slug from URL (reactive detection)
    final urlBusinessSlug = ref.watch(businessSlugFromUrlProvider);

    // Always fetch when slug changes (including null -> slug or slug -> null transitions)
    final slugChanged = _lastProcessedSlug != urlBusinessSlug;

    if (slugChanged) {
      debugPrint(
          '🔄 Business slug changed: ${_lastProcessedSlug} -> $urlBusinessSlug');
      _lastProcessedSlug = urlBusinessSlug;
    }

    if (urlBusinessSlug != null && urlBusinessSlug.isNotEmpty) {
      debugPrint('🌐 Found business slug in URL: $urlBusinessSlug');

      // OPTIMIZED: Use ref.read for services to avoid unnecessary rebuilds
      final slugService = ref.read(businessSlugServiceProvider);
      final businessId =
          await slugService.getBusinessIdFromSlug(urlBusinessSlug);

      if (businessId != null) {
        debugPrint(
            '✅ Business ID resolved: $businessId for slug: $urlBusinessSlug');

        // OPTIMIZED: Store to localStorage asynchronously to avoid blocking build
        _storeBusinessIdAsync(businessId);

        _lastResolvedBusinessId = businessId;
        _logBusinessAccess(urlBusinessSlug, businessId);
        return businessId;
      } else {
        debugPrint(
            '⚠️ Slug "$urlBusinessSlug" not found, falling back to storage');
      }
    }

    // Fallback to local storage business ID
    final storedBusinessId = await ref.read(initBusinessIdProvider.future);
    debugPrint('💾 Using business ID from storage: $storedBusinessId');

    // Update tracking if business ID changed
    if (_lastResolvedBusinessId != storedBusinessId) {
      debugPrint(
          '💾 Business ID from storage: $_lastResolvedBusinessId -> $storedBusinessId');
      _lastResolvedBusinessId = storedBusinessId;
    }

    // Log default/root access
    if (storedBusinessId == 'default') {
      _logRootAccess();
    }

    return storedBusinessId;
  }

  /// OPTIMIZED: Store business ID asynchronously to avoid blocking the build method
  void _storeBusinessIdAsync(String businessId) {
    Future.microtask(() async {
      try {
        final localStorage = ref.read(localStorageServiceProvider);
        await localStorage.setString('businessId', businessId);
        debugPrint('💾 Business ID stored to localStorage: $businessId');
      } catch (e) {
        debugPrint('⚠️ Failed to store business ID to localStorage: $e');
      }
    });
  }

  /// Force refresh the business ID (useful when URL changes)
  void refresh() {
    _lastProcessedSlug = null;
    _lastResolvedBusinessId = null;
    ref.invalidateSelf();
  }
}

/// Log business access for analytics/monitoring
void _logBusinessAccess(String businessSlug, String businessId) {
  debugPrint(
      '📊 Business Access Log: $businessSlug ($businessId) accessed via URL routing');

  // TODO: Add analytics tracking here
  // AnalyticsService.logBusinessAccess(businessSlug, businessId);
}

/// Log root/default access for analytics/monitoring
void _logRootAccess() {
  debugPrint(
      '📊 Root Access Log: Default business accessed (no URL business ID)');

  // TODO: Add analytics tracking here
  // AnalyticsService.logRootAccess();
}

/// Provider to check if current access is via business-specific URL
@riverpod
bool isBusinessUrlAccess(IsBusinessUrlAccessRef ref) {
  final urlBusinessSlug = ref.watch(businessSlugFromUrlProvider);
  return urlBusinessSlug != null && urlBusinessSlug.isNotEmpty;
}

/// Provider to get the current business route prefix (slug)
/// Returns the business slug if accessing via business URL, null otherwise
@riverpod
String? businessRoutePrefix(BusinessRoutePrefixRef ref) {
  final isBusinessUrl = ref.watch(isBusinessUrlAccessProvider);
  if (!isBusinessUrl) return null;

  return ref.watch(businessSlugFromUrlProvider);
}

/// Provider to get the current business slug from URL
/// This is an alias for businessSlugFromUrlProvider for clearer usage
@riverpod
String? currentBusinessSlug(Ref ref) {
  return ref.watch(businessSlugFromUrlProvider);
}
