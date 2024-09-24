import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    // try {
    //   ref.read(firebaseAuthProvider).signInAnonymously();
    // } catch (e) {
    //   print("signInAnonymously did fail");
    // } finally {}

    return MaterialApp.router(
      routerConfig: goRouter,
      theme: ColorsPaletteRedonda.themeData,
      debugShowCheckedModeBanner: false,
    );
  }
}
