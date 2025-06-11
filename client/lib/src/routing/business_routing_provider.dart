// Business routing provider for URL-based business access
// Handles extracting business ID from URL paths like /restaurantBusinessLaBonita

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/web/web_utils.dart';

part 'business_routing_provider.g.dart';

/// Provider that extracts business ID from the current URL path
@riverpod
String? businessIdFromUrl(BusinessIdFromUrlRef ref) {
  if (!kIsWeb) return null;

  final currentPath = WebUtils.getCurrentPath();
  return extractBusinessIdFromPath(currentPath);
}

/// Extract business ID from URL path
/// Supports formats like:
/// - /restaurantBusinessLaBonita -> restaurantBusinessLaBonita
/// - /restaurantBusinessLaBonita/menu -> restaurantBusinessLaBonita
/// - /admin -> null (admin doesn't use business routing)
/// - /signin -> null (auth pages don't use business routing)
String? extractBusinessIdFromPath(String path) {
  // Remove leading slash
  if (path.startsWith('/')) {
    path = path.substring(1);
  }

  // Skip empty paths
  if (path.isEmpty) return null;

  // Extract first segment
  final segments = path.split('/');
  final firstSegment = segments.first;

  // Skip system/auth routes that don't represent business IDs
  final systemRoutes = {
    'admin',
    'signin',
    'signup',
    'onboarding',
    'error',
    'startup',
    'business-setup',
    'admin-setup',
    'menu', // For default/root access
    'carrito', // For default/root access
    'cuenta', // For default/root access
    'ordenes', // For default/root access
  };

  if (systemRoutes.contains(firstSegment)) {
    return null;
  }

  // If the first segment looks like a business ID, return it
  // Business IDs should be non-empty and not contain special chars
  if (firstSegment.isNotEmpty && _isValidBusinessId(firstSegment)) {
    return firstSegment;
  }

  return null;
}

/// Check if a string is a valid business ID format
bool _isValidBusinessId(String id) {
  // Business IDs should:
  // - Be at least 3 characters long
  // - Not contain spaces or special routing characters
  // - Not be numeric only (to avoid confusion with other IDs)
  if (id.length < 3) return false;
  if (id.contains(' ') || id.contains('?') || id.contains('#')) return false;
  if (RegExp(r'^\d+$').hasMatch(id)) return false; // Not purely numeric

  return true;
}

/// Provider for URL-aware business ID
/// This provider combines URL-based business ID with fallback to local storage
@riverpod
class UrlAwareBusinessId extends _$UrlAwareBusinessId {
  @override
  Future<String> build() async {
    // First, try to get business ID from URL
    final urlBusinessId = ref.watch(businessIdFromUrlProvider);

    if (urlBusinessId != null && urlBusinessId.isNotEmpty) {
      debugPrint('🌐 Using business ID from URL: $urlBusinessId');

      // Log root access if this is not the default business
      _logBusinessAccess(urlBusinessId);

      return urlBusinessId;
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
void _logBusinessAccess(String businessId) {
  debugPrint('📊 Business Access Log: $businessId accessed via URL routing');

  // TODO: Add analytics tracking here
  // AnalyticsService.logBusinessAccess(businessId);
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
  final urlBusinessId = ref.watch(businessIdFromUrlProvider);
  return urlBusinessId != null && urlBusinessId.isNotEmpty;
}

/// Provider to get the current business route prefix
/// Returns the business ID if accessing via business URL, null otherwise
@riverpod
String? businessRoutePrefix(BusinessRoutePrefixRef ref) {
  final isBusinessUrl = ref.watch(isBusinessUrlAccessProvider);
  if (!isBusinessUrl) return null;

  return ref.watch(businessIdFromUrlProvider);
}
