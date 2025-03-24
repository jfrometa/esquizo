import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/onboarding/onboarding_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/setup/setup_screen_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/business_config_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/local_storage_service.dart';
 

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
  
  // Load business ID from local storage if available
  final storedBusinessId = await localStorageService.getString('businessId');
  if (storedBusinessId != null && storedBusinessId.isNotEmpty) {
    ref.read(currentBusinessIdProvider.notifier).state = storedBusinessId;
  }
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

// https://codewithandrea.com/articles/robust-app-initialization-riverpod/
@Riverpod(keepAlive: true)
Future<void> appStartup(AppStartupRef ref) async {
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
  
  // Check if admin and if example data should be initialized
  final isAdmin = await ref.read(isAdminProvider.future);
  if (isAdmin && businessConfig == null) {
    // This is an admin with no business config - show setup screen
    ref.read(showSetupScreenProvider.notifier).state = true;
  }

  // Wait for all initialization code to be complete before returning
  await ref.read(onboardingRepositoryProvider.future);
}