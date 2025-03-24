import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/app.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/firebase_auth_repository.dart';  
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user_preference/user_preference_provider.dart';
 
// Using dynamic type to handle different device info types across platforms
late final dynamic deviceInfo;
late final CameraDescription? camera;

// The entry point of the application
Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use path URL strategy for web (cleaner URLs without hashes)
  usePathUrlStrategy();
  
  // Set system UI overlay style for better visual integration
  await _configureSystemUI();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Setup Firebase App Check with proper error handling
  await _initializeAppCheck();
  
  // Create a provider container for dependency injection
  final container = ProviderContainer();
  
  // Initialize auth first (critical for app functionality)
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
  
  // Register global error handlers
  registerErrorHandlers();
   
  // Run the application
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const KakoApp(),
    ),
  );
}

// Initialize Firebase App Check with proper error handling
Future<void> _initializeAppCheck() async {
  try {
    if (kIsWeb) {
      // For web platforms
      debugPrint('Initializing AppCheck for web environment');
      
      // Make sure to use site key from Google reCAPTCHA Admin Console
      // This should be a reCAPTCHA v3 key specifically for your domain
      await FirebaseAppCheck.instance.activate(
        // Consider using debug token for development on web
        webProvider: kDebugMode 
          ? ReCaptchaEnterpriseProvider('6LeGBv4qAAAAACKUiHAJEFBsUDmbTyMPZwb-T8N6') 
          : ReCaptchaV3Provider('6LeGBv4qAAAAACKUiHAJEFBsUDmbTyMPZwb-T8N6'),
       
      );
    } else {
      // For mobile platforms
      await FirebaseAppCheck.instance.activate(
        // For Android production, consider using PlayIntegrity instead of debug
        androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        // For iOS, appAttest is good but doesn't work in simulator
        appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
        
      );
    }
    
    debugPrint('Firebase AppCheck successfully initialized');
  } catch (e) {
    // Log the error but continue app initialization
    debugPrint('Error initializing Firebase AppCheck: $e');
    // In production, you might want to show a user-friendly message or try alternative approaches
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
  // Check if the user is already signed in
  final authRepo = container.read(authRepositoryProvider);
  final currentUser = FirebaseAuth.instance.currentUser; 
 
  // Sign in anonymously if no user is signed in
  if (currentUser == null) {
    try {
      await authRepo.initialize();
    } catch (e) {
      debugPrint('Error during auth initialization: $e');
      // Consider adding fallback authentication strategy here
    }
  }
  
  // Initialize theme system from user preferences (if any)
  if (FirebaseAuth.instance.currentUser != null) {
    try {
      // Pre-fetch user preferences to initialize theme
      final prefsRepo = container.read(userPreferencesRepositoryProvider);
      await prefsRepo.getUserPreferences(FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      // Silently handle error - we'll fall back to system theme
      debugPrint('Error loading user preferences: $e');
    }
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
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = deviceInfo as IosDeviceInfo;
      hasCamera = !iosInfo.isPhysicalDevice ? false : true;
    } else {
      // Assume other platforms might have a camera
      hasCamera = true;
    }
    
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

// Register global error handlers
void registerErrorHandlers() {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  
  // Handle platform-level errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Platform error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };
  
  // Customize error widget appearance
  ErrorWidget.builder = (FlutterErrorDetails details) {
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
                    kDebugMode ? details.toString() : 'Please try again later'.hardcoded,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };
}