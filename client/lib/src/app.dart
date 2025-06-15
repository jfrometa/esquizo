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
  // DISABLED: This method was causing conflicts with browser navigation
  // Browser navigation should work naturally with GoRouter and path URL strategy
  void _checkForUrlChanges() {
    if (!kIsWeb) return;

    debugPrint(
        '🧭 App lifecycle: URL check disabled to prevent navigation conflicts');

    // DISABLED: Commenting out the sync logic that was causing Flutter engine restarts
    // The GoRouter with path URL strategy should handle browser navigation naturally
    /*
    try {
      final router = ref.read(goRouterProvider);

      // Use the router's location instead of matchedLocation for full path
      final currentRouterPath = router.state.matchedLocation;
      final browserPath = WebUtils.getCurrentPath();

      debugPrint('🧭 Router state details:');
      debugPrint('  - router.location: "$currentRouterPath"');
      debugPrint('  - WebUtils.getCurrentPath(): "$browserPath"');

      // Only update if there's a significant difference and browser path is not just root
      if (browserPath != currentRouterPath &&
          browserPath.isNotEmpty &&
          browserPath != '/' &&
          currentRouterPath != '/') {
        debugPrint(
            '📌 URL changed from "$currentRouterPath" to "$browserPath", updating');
        router.go(browserPath);
      } else if (browserPath == '/' && currentRouterPath != '/') {
        debugPrint(
            '⚠️ Browser URL reset to root but router shows "$currentRouterPath" - ignoring browser change');
      }
    } catch (e) {
      debugPrint('🔥 Error checking URL changes: $e');
    }
    */
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
