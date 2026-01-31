import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/app_config/app_config_services.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/onboarding/onboarding_repository.dart';
import 'setup_screen_provider.dart';

part 'app_config_services.g.dart';

@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  debugPrint('🚀 Starting app initialization...');

  ref.onDispose(() {
    // ensure dependent providers are disposed as well
    ref.invalidate(onboardingRepositoryProvider);
    ref.invalidate(businessConfigInitProvider);
    ref.invalidate(localStorageInitProvider);
  });

  // Initialize Firebase
  await ref.read(firebaseInitializationProvider.future);

  // Initialize local storage
  await ref.read(localStorageInitProvider.future);

  // Initialize business configuration
  final businessConfig = await ref.read(businessConfigInitProvider.future);

  // Check for current user and explicitly check admin status
  final auth = ref.read(firebaseAuthProvider);
  final currentUser = auth.currentUser;

  if (currentUser != null) {
    debugPrint('👤 User is logged in: ${currentUser.uid}');

    // Check admin status directly using the admin service
    final adminService = ref.read(unifiedAdminServiceProvider);
    final isAdmin = await adminService.isCurrentUserAdmin();

    // Update the cached admin status
    if (isAdmin) {
      debugPrint('🔐 User is an admin, updating cached status');
      ref.read(cachedAdminStatusProvider.notifier).updateStatus(true);
    } else {
      debugPrint('👤 User is not an admin');
      ref.read(cachedAdminStatusProvider.notifier).updateStatus(false);
    }
  } else {
    debugPrint('👤 No user logged in');
    // Ensure admin status is false when no user is logged in
    ref.read(cachedAdminStatusProvider.notifier).updateStatus(false);
  }

  // Check if admin and if example data should be initialized
  final isAdmin = await ref.read(isAdminProvider.future);
  if (isAdmin && businessConfig == null) {
    // This is an admin with no business config - show setup screen
    ref.read(showSetupScreenProvider.notifier).show();
  }

  // Wait for all initialization code to be complete before returning
  await ref.read(onboardingRepositoryProvider.future);

  debugPrint('✅ App initialization complete');
}

/// Provider for checking admin status eagerly (helping with UI updates)
@riverpod
Future<bool> eagerAdminStatus(Ref ref) async {
  // First check the cached status for immediate response
  final cachedStatus = ref.read(cachedAdminStatusProvider);
  if (cachedStatus) return true;

  // If not in cache, do an actual check
  final adminService = ref.read(unifiedAdminServiceProvider);
  final isAdmin = await adminService.isCurrentUserAdmin();

  // Update the cache with the result
  if (isAdmin) {
    ref.read(cachedAdminStatusProvider.notifier).updateStatus(true);
  }

  return isAdmin;
}
