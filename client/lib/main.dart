import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/app.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/data/firebase_auth_repository.dart';  
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/user_preference/user_preference_provider.dart';

// Shared variables
late final ValueNotifier<int> notifier;
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
  
  // Initialize notifier
  notifier = ValueNotifier<int>(0);
  
  // Run the application
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const KakoApp(),
    ),
  );
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
    await authRepo.signInAnonymously();
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