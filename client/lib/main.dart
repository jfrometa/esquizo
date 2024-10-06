import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/app.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/prompt/presentation/widgets/image_input_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';
// ignore:depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:starter_architecture_flutter_firebase/src/util/device_info.dart';
// import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:localstorage/localstorage.dart';

late final ValueNotifier<int> notifier;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // turn off the # in the URLs on the web
  usePathUrlStrategy();
  // * Register error handlers. For more info, see:
  // * https://docs.flutter.dev/testing/errors
  registerErrorHandlers();
  // * Initialize Firebase
  await initLocalStorage();
  notifier = ValueNotifier(int.parse(localStorage.getItem('counter') ?? '0'));
  notifier.addListener(() {
    localStorage.setItem('counter', notifier.value.toString());
  });

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create a ProviderContainer to read providers outside of the widget tree
  final container = ProviderContainer();
  await container.read(authRepositoryProvider).signInAnonymously();

  // * Entry point of the app

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
  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
    return true;
  };
  // * Show some error UI when any widget in the app fails to build
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
