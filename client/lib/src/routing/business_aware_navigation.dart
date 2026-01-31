// Business-aware navigation helper for maintaining business context persistence
// This provides UI-level navigation that maintains business context

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_navigation_provider.dart';

/// Business-aware navigation helper for maintaining context persistence
class BusinessAwareNavigation {
  /// Navigate to a path while maintaining business context if active
  /// If user is in a business context (/kako), navigation to /menu becomes /kako/menu
  static void go(BuildContext context, WidgetRef ref, String targetPath) {
    final businessAwarePath =
        BusinessAwareRoutingHelper.getBusinessAwarePath(ref, targetPath);

    debugPrint(
        '🎯 Business-aware navigation: $targetPath -> $businessAwarePath');
    context.go(businessAwarePath);
  }

  /// Push a route while maintaining business context if active
  static void push(BuildContext context, WidgetRef ref, String targetPath) {
    final businessAwarePath =
        BusinessAwareRoutingHelper.getBusinessAwarePath(ref, targetPath);

    debugPrint('🎯 Business-aware push: $targetPath -> $businessAwarePath');
    context.push(businessAwarePath);
  }

  /// Replace current route while maintaining business context if active
  static void pushReplacement(
      BuildContext context, WidgetRef ref, String targetPath) {
    final businessAwarePath =
        BusinessAwareRoutingHelper.getBusinessAwarePath(ref, targetPath);

    debugPrint('🎯 Business-aware replace: $targetPath -> $businessAwarePath');
    context.pushReplacement(businessAwarePath);
  }

  /// Get the business-aware path without navigating
  static String getBusinessAwarePath(WidgetRef ref, String targetPath) {
    return BusinessAwareRoutingHelper.getBusinessAwarePath(ref, targetPath);
  }

  /// Check if user is currently in a business context
  static bool hasActiveBusinessContext(WidgetRef ref) {
    final navigationController =
        ref.read(businessNavigationControllerProvider.notifier);
    return navigationController.hasActiveBusinessContext;
  }

  /// Get the current active business slug (null if default business)
  static String? getActiveBusinessSlug(WidgetRef ref) {
    final navigationController =
        ref.read(businessNavigationControllerProvider.notifier);
    return navigationController.activeBusinessContext;
  }

  /// Clear business context (useful for logout or switching to default business)
  static void clearBusinessContext(WidgetRef ref) {
    final navigationController =
        ref.read(businessNavigationControllerProvider.notifier);
    navigationController.clear();
  }
}

/// Extension on BuildContext for easier business-aware navigation
extension BusinessAwareNavigationExtension on BuildContext {
  /// Navigate with business context awareness
  void goBusinessAware(WidgetRef ref, String targetPath) {
    BusinessAwareNavigation.go(this, ref, targetPath);
  }

  /// Push with business context awareness
  void pushBusinessAware(WidgetRef ref, String targetPath) {
    BusinessAwareNavigation.push(this, ref, targetPath);
  }

  /// Replace with business context awareness
  void pushReplacementBusinessAware(WidgetRef ref, String targetPath) {
    BusinessAwareNavigation.pushReplacement(this, ref, targetPath);
  }
}
