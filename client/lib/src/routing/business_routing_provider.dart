// Business routing provider for URL-based business access
// Handles extracting business slug from URL paths like /panesitos

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_slug_service.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/web/web_utils.dart';

part 'business_routing_provider.g.dart';

/// Provider that extracts business slug from the current URL path
@riverpod
String? businessSlugFromUrl(BusinessSlugFromUrlRef ref) {
  if (!kIsWeb) return null;

  final currentPath = WebUtils.getCurrentPath();
  return extractBusinessSlugFromPath(currentPath);
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
@riverpod
class UrlAwareBusinessId extends _$UrlAwareBusinessId {
  @override
  Future<String> build() async {
    // First, try to get business slug from URL
    final urlBusinessSlug = ref.watch(businessSlugFromUrlProvider);

    if (urlBusinessSlug != null && urlBusinessSlug.isNotEmpty) {
      debugPrint('🌐 Found business slug in URL: $urlBusinessSlug');

      // Resolve slug to business ID using the slug service
      final slugService = ref.watch(businessSlugServiceProvider);
      final businessId =
          await slugService.getBusinessIdFromSlug(urlBusinessSlug);

      if (businessId != null) {
        debugPrint('🌐 Using business ID from URL slug: $businessId');
        _logBusinessAccess(urlBusinessSlug, businessId);
        return businessId;
      } else {
        debugPrint(
            '⚠️ Slug "$urlBusinessSlug" not found, falling back to storage');
      }
    }

    // Fallback to local storage business ID
    final storedBusinessId = await ref.watch(initBusinessIdProvider.future);
    debugPrint('💾 Using business ID from storage: $storedBusinessId');

    // Log default/root access
    if (storedBusinessId == 'default') {
      _logRootAccess();
    }

    return storedBusinessId;
  }

  /// Force refresh the business ID (useful when URL changes)
  void refresh() {
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
String? currentBusinessSlug(CurrentBusinessSlugRef ref) {
  return ref.watch(businessSlugFromUrlProvider);
}
