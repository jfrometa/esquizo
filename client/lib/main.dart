import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Import for usePathUrlStrategy
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/app.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/app_config/app_config_services.dart';

import 'package:starter_architecture_flutter_firebase/src/core/business/business_setup_manager.dart';

import 'package:starter_architecture_flutter_firebase/src/core/user_preference/user_preference_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/extensions/firebase_analitics.dart';
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';

import 'package:starter_architecture_flutter_firebase/src/utils/web/web_utils.dart';

// Using dynamic type to handle different device info types across platforms
late final dynamic deviceInfo;
late final CameraDescription? camera;

// The entry point of the application
Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // *** SIMPLIFIED URL STRATEGY INITIALIZATION ***
  // Configure URL strategy for web (use path URLs instead of hash fragments)
  if (kIsWeb) {
    // This is the FIRST thing we do to ensure it's applied before any routing happens
    usePathUrlStrategy();
    debugPrint('🌐 Path URL strategy initialized');
  }

  // Set system UI overlay style for better visual integration
  await _configureSystemUI();

  // Create a provider container for dependency injection
  // We need this before initializing Firebase to access providers
  final container = ProviderContainer();

  try {
    // Initialize Firebase first - needed for most services
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('🔥 Firebase core initialized successfully');

    // Update the Firebase initialization state in the provider container
    container.read(isFirebaseInitializedProvider.notifier).state = true;

    // Initialize Analytics (should be done early to track initialization)
    await _initializeAnalytics();

    // Initialize Crashlytics
    await _initializeCrashlytics();

    // For development only - completely bypass AppCheck if needed
    bool bypassAppCheck = kDebugMode;

    if (!bypassAppCheck) {
      // Try to initialize AppCheck with fallback
      await _initializeAppCheckWithFallback();
    } else {
      debugPrint('⚠️ Firebase AppCheck is BYPASSED in development mode');
    }

    // Initialize auth (critical for app functionality)
    await _initializeAuth(container);

    // Initialize device info (can happen after auth)
    if (!kIsWeb) {
      // Only initialize device info and camera on non-web platforms
      await _initializeDeviceInfo();
    } else {
      // Set deviceInfo to a simple flag for web
      deviceInfo = {'isWeb': true};
      camera = null;
    }

    // Initialize business configuration
    await _initializeBusinessConfig(container);

    // Run the application
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const KakoApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Log critical startup errors
    debugPrint('🚨 Critical error during app initialization: $e');

    if (!kIsWeb) {
      // Report to Crashlytics if available
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Error during app initialization',
        fatal: true,
      );
    }

    // Run a minimal error app to show the user something went wrong
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Failed to start the application'.hardcoded,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later or contact support'.hardcoded,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    if (kIsWeb) {
                      // For web, reload the page
                      WebUtils.reloadPage();
                    } else {
                      // For mobile, exit and restart
                      SystemNavigator.pop();
                    }
                  },
                  child: Text('Restart'.hardcoded),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

// Initialize Firebase Analytics
Future<void> _initializeAnalytics() async {
  try {
    // Initialize Analytics service with debug mode in development
    await AnalyticsService.instance.init(
      debugMode: kDebugMode,
    );

    // Configure Firebase Analytics settings
    final analytics = FirebaseAnalytics.instance;

    // Enable analytics collection (can be toggled based on user consent)
    await analytics.setAnalyticsCollectionEnabled(true);

    // Set default session timeout to 30 minutes
    await analytics.setSessionTimeoutDuration(const Duration(minutes: 30));

    // Log app_open event for non-web platforms (automatically tracked on mobile)
    if (!kIsWeb) {
      await analytics.logAppOpen();
    }

    // Set common user properties that apply to all users
    await AnalyticsService.instance.setUserProperty(
      name: 'app_version',
      value: '1.0.0', // Replace with your actual app version
    );

    await AnalyticsService.instance.setUserProperty(
      name: 'platform',
      value: kIsWeb ? 'web' : defaultTargetPlatform.toString().split('.').last,
    );

    debugPrint('✅ Firebase Analytics initialized successfully');
  } catch (e) {
    // Don't let analytics initialization failure crash the app
    debugPrint('⚠️ Failed to initialize Firebase Analytics: $e');
  }
}

// Initialize Crashlytics
Future<void> _initializeCrashlytics() async {
  if (kIsWeb) {
    // Crashlytics is not available for web
    debugPrint('📊 Crashlytics not available for web platform');
    return;
  }

  try {
    // Set Crashlytics collection enabled (disable during development if needed)
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    // Pass all Flutter errors to Crashlytics
    FlutterError.onError = (FlutterErrorDetails details) {
      // Report to console in debug mode
      if (kDebugMode) {
        // Print to console
        FlutterError.presentError(details);
        debugPrint(details.toString());
      }

      // Report to Crashlytics
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      // Report to console in debug mode
      if (kDebugMode) {
        debugPrint('Platform error: $error');
        debugPrint('Stack trace: $stack');
      }

      // Report to Crashlytics
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('✅ Crashlytics initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize Crashlytics: $e');
  }
}

// Initialize Firebase App Check with proper error handling and fallback
Future<void> _initializeAppCheckWithFallback() async {
  try {
    if (kIsWeb) {
      debugPrint('🔒 Initializing Firebase AppCheck for web');

      // Try using enterprise provider first
      try {
        await FirebaseAppCheck.instance.activate(
          webProvider: ReCaptchaEnterpriseProvider(
              '6LeGBv4qAAAAACKUiHAJEFBsUDmbTyMPZwb-T8N6'),
        );
        debugPrint(
            '✅ Firebase AppCheck initialized with ReCaptchaEnterpriseProvider');
        return; // Early return if successful
      } catch (enterpriseError) {
        debugPrint('⚠️ ReCaptchaEnterpriseProvider failed: $enterpriseError');
        // Fall through to try V3 provider
      }

      // Try V3 provider if enterprise failed
      try {
        await FirebaseAppCheck.instance.activate(
          webProvider:
              ReCaptchaV3Provider('6LeGBv4qAAAAACKUiHAJEFBsUDmbTyMPZwb-T8N6'),
        );
        debugPrint('✅ Firebase AppCheck initialized with ReCaptchaV3Provider');
        return; // Early return if successful
      } catch (v3Error) {
        debugPrint('⚠️ ReCaptchaV3Provider failed: $v3Error');
        // Fall through to try debug provider
      }

      // Final fallback for dev environments - use debug provider
      if (kDebugMode) {
        try {
          // For web in debug mode, try with debug provider as last resort
          await FirebaseAppCheck.instance.activate(
            // Use debug provider for web - requires debug token
            webProvider:
                ReCaptchaV3Provider('6LeGBv4qAAAAACKUiHAJEFBsUDmbTyMPZwb-T8N6'),
          );
          debugPrint(
              '✅ Firebase AppCheck initialized with debug configuration');
        } catch (debugError) {
          // If debug mode also fails, log and proceed without AppCheck
          debugPrint(
              '❌ All AppCheck providers failed. Proceeding without AppCheck: $debugError');
        }
      }
    } else {
      // For mobile platforms - try with appropriate debug provider first
      if (kDebugMode) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );
        debugPrint(
            '✅ Firebase AppCheck initialized with debug providers for mobile');
      } else {
        // For production mobile
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.deviceCheck,
        );
        debugPrint(
            '✅ Firebase AppCheck initialized with production providers for mobile');
      }
    }
  } catch (e) {
    // Global error handler - if all attempts fail, log error and proceed without AppCheck
    debugPrint('❌ Firebase AppCheck failed completely: $e');
    debugPrint('⚠️ Proceeding without Firebase AppCheck');
  }
}

// Configure system UI appearance
Future<void> _configureSystemUI() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light, // iOS
    ),
  );

  // Lock orientation to portrait mode for mobile (not on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
}

// Initialize authentication
Future<void> _initializeAuth(ProviderContainer container) async {
  try {
    // Check if the user is already signed in
    final authRepo = container.read(authRepositoryProvider);
    final currentUser = FirebaseAuth.instance.currentUser;

    // Sign in anonymously if no user is signed in
    if (currentUser == null) {
      await authRepo.initialize();
    } else {
      // Log login event if user is already signed in
      AnalyticsService.instance.logLogin(method: 'auto');

      // Set user ID for analytics if available
      if (currentUser.uid.isNotEmpty) {
        AnalyticsService.instance.setUserId(currentUser.uid);
      }
    }

    // Initialize theme system from user preferences (if any)
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        // Pre-fetch user preferences to initialize theme
        final prefsRepo = container.read(userPreferencesRepositoryProvider);
        final prefs = await prefsRepo
            .getUserPreferences(FirebaseAuth.instance.currentUser!.uid);

        // Track user preferences as user properties for analytics segmentation
        await AnalyticsService.instance.setUserProperty(
          name: 'preferred_theme',
          value: prefs.themeMode.toString().split('.').last,
        );
      } catch (e) {
        // Silently handle error - we'll fall back to system theme
        debugPrint('Error loading user preferences: $e');
      }
    }
  } catch (e) {
    debugPrint('❌ Error during authentication initialization: $e');
    // Continue anyway - anonymous auth might fail but app should still work
  }
}

// Initialize business configuration
Future<void> _initializeBusinessConfig(ProviderContainer container) async {
  try {
    // Check if business configuration exists
    final businessSetupManager = container.read(businessSetupManagerProvider);
    final isBusinessSetup = await businessSetupManager.isBusinessSetup();
    
    debugPrint('🏢 Business configuration check: isSetup = $isBusinessSetup');
    
    // Initialize the business setup detector state
    container.read(isBusinessSetupProvider);
    
  } catch (e) {
    debugPrint('❌ Error checking business setup: $e');
    // Continue anyway - business setup might not be critical for initial launch
  }
}

// Initialize device info
Future<void> _initializeDeviceInfo() async {
  try {
    // Get device info
    final deviceInfoPlugin = DeviceInfoPlugin();

    // Get appropriate device info based on platform
    if (kIsWeb) {
      deviceInfo = await deviceInfoPlugin.webBrowserInfo;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      deviceInfo = await deviceInfoPlugin.androidInfo;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      deviceInfo = await deviceInfoPlugin.iosInfo;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      deviceInfo = await deviceInfoPlugin.macOsInfo;
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      deviceInfo = await deviceInfoPlugin.windowsInfo;
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      deviceInfo = await deviceInfoPlugin.linuxInfo;
    } else {
      deviceInfo = {'unsupported': true};
    }

    // Initialize camera if available on a physical device
    bool hasCamera = false;

    // Check if device has camera based on platform
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = deviceInfo as AndroidDeviceInfo;
      hasCamera = !androidInfo.isPhysicalDevice ? false : true;

      // Set device properties for analytics
      await AnalyticsService.instance.setUserProperty(
        name: 'device_model',
        value: androidInfo.model,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = deviceInfo as IosDeviceInfo;
      hasCamera = !iosInfo.isPhysicalDevice ? false : true;

      // Set device properties for analytics
      await AnalyticsService.instance.setUserProperty(
        name: 'device_model',
        value: iosInfo.model,
      );
    } else {
      // Assume other platforms might have a camera
      hasCamera = true;
    }

    // Set has_camera property for segmentation
    await AnalyticsService.instance.setUserProperty(
      name: 'has_camera',
      value: hasCamera ? 'true' : 'false',
    );

    if (hasCamera) {
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          camera = cameras.first;
        } else {
          camera = null;
        }
      } catch (e) {
        debugPrint('Error initializing camera: $e');
        camera = null;
      }
    } else {
      camera = null;
    }
  } catch (e) {
    // Handle any errors by setting defaults
    debugPrint('Error initializing device info: $e');
    deviceInfo = {'error': true};
    camera = null;
  }
}

// Custom error widget - Will be shown when an error occurs in the app UI
class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorWidget({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Log error to analytics
    AnalyticsService.instance.logCustomEvent(
      eventName: 'ui_error',
      parameters: {
        'error_message': errorDetails.exception.toString(),
        'error_location': errorDetails.library ?? 'unknown',
      },
    );

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        backgroundColor: Colors.red,
        title: Text('An error occurred'.hardcoded),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Something went wrong'.hardcoded,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    kDebugMode
                        ? errorDetails.toString()
                        : 'Please try again later'.hardcoded,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Try to navigate to home page or restart the app
                  try {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (route) => false);
                  } catch (_) {
                    if (kIsWeb) {
                      WebUtils.goToHomePage();
                    }
                  }
                },
                child: Text('Go to Home'.hardcoded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}