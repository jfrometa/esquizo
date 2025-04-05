import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/app_config/app_config_services.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/onboarding/onboarding_repository.dart';
import 'setup_screen_provider.dart';

part 'app_config_services.g.dart';

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
    ref.read(showSetupScreenProvider.notifier).show();
  }

  // Wait for all initialization code to be complete before returning
  await ref.read(onboardingRepositoryProvider.future);
}