import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/user_preference/user_preference_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class KakoApp extends ConsumerWidget {
  const KakoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    
    // Watch the theme mode from our provider
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Use the theme mode from our provider
      debugShowCheckedModeBanner: false, // Let's remove the debug banner in production
    );
  }
}