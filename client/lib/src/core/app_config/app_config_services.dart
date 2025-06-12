import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/onboarding/onboarding_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/local_storange/local_storage_service.dart';

part 'app_config_services.g.dart';

// Firebase initialization provider
final firebaseInitializationProvider = FutureProvider<FirebaseApp>((ref) async {
  if (Firebase.apps.isNotEmpty) {
    return Firebase.apps[0];
  }

  final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  ref.read(isFirebaseInitializedProvider.notifier).state = true;

  return app;
});

final isFirebaseInitializedProvider = StateProvider<bool>((ref) => false);

// Local storage initialization provider
final localStorageInitProvider = FutureProvider<void>((ref) async {
  final localStorageService = ref.read(localStorageServiceProvider);
  await localStorageService.init();

  // Note: Business ID is now handled by URL-aware routing system
  // The stored business ID is read by initBusinessIdProvider when needed
});

// Business configuration initialization provider
final businessConfigInitProvider = FutureProvider<BusinessConfig?>((ref) async {
  // Wait for Firebase to be initialized first
  await ref.watch(firebaseInitializationProvider.future);

  // Wait for local storage to be initialized
  await ref.watch(localStorageInitProvider.future);

  // Get the business ID
  final businessId = ref.read(currentBusinessIdProvider);

  // Get the business configuration
  final configService = ref.read(businessConfigServiceProvider);
  final config = await configService.getBusinessConfig(businessId);

  return config;
});

// Result class to handle setup check outcome
class AppStartupResult {
  final bool isAdmin;
  final bool showSetupScreen;
  final BusinessConfig? businessConfig;

  AppStartupResult({
    required this.isAdmin,
    required this.showSetupScreen,
    this.businessConfig,
  });
}

// This provider will hold the startup result without modifying other providers
final appStartupResultProvider =
    StateProvider<AppStartupResult?>((ref) => null);

// Remove the problematic checkSetupScreenProvider and handle setup screen state differently

// Main app startup provider - refactored to avoid modifying providers during init
@Riverpod(keepAlive: true)
Future<void> appStartup(AppStartupRef ref) async {
  ref.onDispose(() {
    // ensure dependent providers are disposed as well
    ref.invalidate(onboardingRepositoryProvider);
    ref.invalidate(businessConfigInitProvider);
    ref.invalidate(localStorageInitProvider);
  });

  try {
    // Initialize Firebase
    await ref.read(firebaseInitializationProvider.future);

    // Initialize local storage
    await ref.read(localStorageInitProvider.future);

    // Initialize business configuration
    final businessConfig = await ref.read(businessConfigInitProvider.future);

    // Check if admin, but don't directly modify providers
    final isAdmin = await ref.read(isAdminProvider.future);
    final shouldShowSetup = isAdmin && businessConfig == null;

    // Store the result so other providers can react to it
    ref.read(appStartupResultProvider.notifier).state = AppStartupResult(
      isAdmin: isAdmin,
      showSetupScreen: shouldShowSetup,
      businessConfig: businessConfig,
    );

    // Wait for all initialization code to be complete before returning
    await ref.read(onboardingRepositoryProvider.future);

    // Don't try to modify other providers during initialization
    // We'll handle the setup screen state in the UI layer
  } catch (e) {
    debugPrint('Error during app startup: $e');
    rethrow;
  }
}

// Convenience method to check if setup is complete
final isSetupCompleteProvider = Provider<bool>((ref) {
  final result = ref.watch(appStartupResultProvider);
  return result != null && result.businessConfig != null;
});

// Add a new provider that can be used in the UI to determine if setup screen should be shown
final shouldShowSetupScreenProvider = Provider<bool>((ref) {
  final result = ref.watch(appStartupResultProvider);
  return result != null && result.showSetupScreen;
});
