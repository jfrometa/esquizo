import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';

/// Helper class for navigating to the admin setup screen
class AdminSetupNavigation {
  /// Navigate to the admin setup screen if business config is missing
  static void navigateToSetupIfNeeded(BuildContext context, WidgetRef ref) {
    final businessConfig = ref.read(businessConfigProvider);
    
    businessConfig.when(
      data: (config) {
        if (config == null) {
          // No business configuration exists, navigate to setup
          context.goNamed('adminSetup');
        }
      },
      loading: () {
        // Wait for data to load
      },
      error: (_, __) {
        // Could show an error or still navigate to setup
        context.goNamed('adminSetup');
      },
    );
  }
  
  /// Force navigation to admin setup screen
  static void navigateToSetup(BuildContext context) {
    context.goNamed('adminSetup');
  }
  
  /// Check if business config exists and return result
  static Future<bool> hasBusinessConfig(WidgetRef ref) async {
    final businessConfig = await ref.read(businessConfigProvider.future);
    return businessConfig != null;
  }
}