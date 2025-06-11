import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/theme/business_setup_detector.dart';
import 'package:starter_architecture_flutter_firebase/src/core/theme/business_theme_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/user_preference/user_preference_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/business_settings/business_setup_screen.dart';

import 'package:starter_architecture_flutter_firebase/src/utils/web/web_utils.dart';

/// The main app widget that initializes the app with routing
class KakoApp extends ConsumerStatefulWidget {
  const KakoApp({super.key});

  @override
  ConsumerState<KakoApp> createState() => _KakoAppState();
}

class _KakoAppState extends ConsumerState<KakoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && kIsWeb) {
      // When the app is resumed in web, check if we need to update router path
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUrlChanges();
      });
    }
  }

  // Check if the browser URL has changed while app was in background
  void _checkForUrlChanges() {
    if (!kIsWeb) return;

    try {
      final router = ref.read(goRouterProvider);

      final currentRouterPath = router.state.matchedLocation;
      final browserPath = WebUtils.getCurrentPath();

      debugPrint('🧭 Router state details:');
      debugPrint('  - router.location: "$currentRouterPath"');
      debugPrint('  - WebUtils.getCurrentPath(): "$browserPath"');

      // If URL changed while app was inactive, navigate to new path
      if (browserPath != currentRouterPath && browserPath.isNotEmpty) {
        debugPrint(
            '📌 URL changed from "$currentRouterPath" to "$browserPath", updating');
        router.go(browserPath);
      }
    } catch (e) {
      debugPrint('🔥 Error checking URL changes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the auto-check admin status provider
    // This ensures admin status is checked whenever auth state changes
    ref.watch(autoCheckAdminStatusProvider);

    // Get GoRouter configuration
    final goRouter = ref.watch(goRouterProvider);

    // Get theme mode - combine user preferences with business theme
    final userThemeMode = ref.watch(themeProvider);

    // Watch for router errors
    ref.listen<String?>(routerErrorNotifierProvider, (previous, current) {
      if (current != null && mounted && previous != current) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Show a snackbar for router errors
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Navigation error: $current'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {
                  ref.read(routerErrorNotifierProvider.notifier).state = null;
                },
              ),
            ),
          );
        });
      }
    });

    // Get theme data from business config
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    return BusinessSetupDetector(
      // The setup screen when business is NOT set up
      setupScreen: MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: userThemeMode,
        debugShowCheckedModeBanner: false,
        title: 'Business Setup',
        home: const BusinessSetupScreen(),
      ),
      // The main app content when business IS set up
      child: MaterialApp.router(
        routerConfig: goRouter,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: userThemeMode,
        debugShowCheckedModeBanner: false,
        title: 'KakoApp',
        restorationScopeId: 'app',
        // Error widget for Flutter framework errors
        builder: (context, child) {
          // Add your global error handling widgets here
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            // In debug mode, use Flutter's default error widget
            if (kDebugMode) {
              return ErrorWidget(errorDetails.exception);
            }
            // In release mode, use a custom error widget
            return Material(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please try again',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Try to restart the app or navigate home
                          if (kIsWeb) {
                            WebUtils.reloadPage();
                          } else {
                            goRouter.go('/');
                          }
                        },
                        child: const Text('Restart'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };

          // Return the child with any additional wrappers
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
