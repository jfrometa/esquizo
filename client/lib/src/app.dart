import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/user_preference/user_preference_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
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
      if (router == null) return;

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
    final goRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);

    // Listen for router errors
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

    return MaterialApp.router(
      routerConfig: goRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
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
    );
  }
}
