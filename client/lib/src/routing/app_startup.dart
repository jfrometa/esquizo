import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/local_storage_service.dart';
import '../constants/app_sizes.dart';
import '../core/onboarding/onboarding_repository.dart';
import '../../firebase_options.dart';
import '../core/providers/business/business_config_provider.dart';
import '../core/services/business_config_service.dart';

part 'app_startup.g.dart';

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
  if (businessConfig == null) {
    throw Exception('Failed to load business configuration');
  }

  // Wait for all initialization code to be complete before returning
  await ref.read(onboardingRepositoryProvider.future);
}

/// Widget class to manage asynchronous app initialization
class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key, required this.onLoaded});
  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartupProvider);
    final isFirebaseInitialized = ref.watch(isFirebaseInitializedProvider);

    return appStartupState.when(
      data: (_) => onLoaded(context),
      loading: () => const AppStartupLoadingWidget(),
      error: (e, st) => AppStartupErrorWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
    );
  }
}

class AppStartupLoadingWidget extends StatelessWidget {
  const AppStartupLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class AppStartupErrorWidget extends StatelessWidget {
  const AppStartupErrorWidget(
      {super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true,),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: Theme.of(context).textTheme.headlineSmall),
            gapH16,
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
