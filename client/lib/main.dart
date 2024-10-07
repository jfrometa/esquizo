import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/app.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/prompt/presentation/widgets/image_input_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:starter_architecture_flutter_firebase/src/util/device_info.dart';
import 'package:localstorage/localstorage.dart';

late final ValueNotifier<int> notifier;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  registerErrorHandlers();

  await initLocalStorage();
  notifier = ValueNotifier(int.parse(localStorage.getItem('counter') ?? '0'));
  notifier.addListener(() {
    localStorage.setItem('counter', notifier.value.toString());
  });

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final container = ProviderContainer();

  // Check if the user is already signed in
  final authRepo = container.read(authRepositoryProvider);
  final currentUser = FirebaseAuth.instance.currentUser;

  // Sign in anonymously if no user is signed in
  if (currentUser == null) {
    await authRepo.signInAnonymously();
  }

  deviceInfo = await DeviceInfo.initialize(DeviceInfoPlugin());
  if (DeviceInfo.isPhysicalDeviceWithCamera(deviceInfo)) {
    final cameras = await availableCameras();
    camera = cameras.first;
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

void registerErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 3,
        backgroundColor: Colors.red,
        title: Text('An error occurred'.hardcoded),
      ),
      body: Center(child: Text(details.toString())),
    );
  };
}