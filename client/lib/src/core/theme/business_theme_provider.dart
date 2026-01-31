// // File: lib/src/core/theme/business_theme_provider.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:ui';

// import '../business/business_config_provider.dart';
// import '../business/business_config_service.dart';

// /// Provides theme data based on business configuration
// class BusinessThemeManager {
//   /// Convert hex string to Color
//   static Color _hexToColor(String? hex) {
//     if (hex == null || hex.isEmpty) {
//       return Colors.deepPurple;
//     }

//     hex = hex.replaceAll('#', '');
//     if (hex.length == 6) {
//       hex = 'FF$hex';
//     }

//     try {
//       return Color(int.parse(hex, radix: 16));
//     } catch (e) {
//       debugPrint('Error parsing color: $e');
//       return Colors.deepPurple; // Fallback color
//     }
//   }

//   /// Get color scheme from business settings
//   static ColorScheme _getColorScheme(
//     Map<String, dynamic> settings,
//     Brightness brightness,
//   ) {
//     final primaryColor = _hexToColor(settings['primaryColor'] as String?);
//     final secondaryColor = _hexToColor(settings['secondaryColor'] as String?);
//     final tertiaryColor = _hexToColor(settings['tertiaryColor'] as String?);
//     final accentColor = _hexToColor(settings['accentColor'] as String?);

//     return ColorScheme.fromSeed(
//       seedColor: primaryColor,
//       brightness: brightness,
//       primary: primaryColor,
//       secondary: secondaryColor,
//       tertiary: tertiaryColor,
//       error: accentColor,
//     );
//   }

//   /// Get theme data from business config
//   static ThemeData getThemeData(
//     BusinessConfig? config,
//     Brightness brightness,
//   ) {
//     if (config == null) {
//       // Default theme if no business config is available
//       return ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.deepPurple,
//           brightness: brightness,
//         ),
//         useMaterial3: true,
//       );
//     }

//     final colorScheme = _getColorScheme(config.settings, brightness);

//     return ThemeData(
//       colorScheme: colorScheme,
//       useMaterial3: true,
//       appBarTheme: AppBarTheme(
//         backgroundColor: colorScheme.surface,
//         foregroundColor: colorScheme.onSurface,
//         elevation: 0,
//       ),
//       cardTheme: CardTheme(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           elevation: 2,
//           padding: const EdgeInsets.symmetric(
//             horizontal: 24,
//             vertical: 12,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 24,
//             vertical: 12,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         filled: true,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//       ),
//     );
//   }
// }

// /// Provider for light theme
// final lightThemeProvider = Provider<ThemeData>((ref) {
//   final businessConfig = ref.watch(businessConfigProvider).value;
//   return BusinessThemeManager.getThemeData(businessConfig, Brightness.light);
// });

// /// Provider for dark theme
// final darkThemeProvider = Provider<ThemeData>((ref) {
//   final businessConfig = ref.watch(businessConfigProvider).value;
//   return BusinessThemeManager.getThemeData(businessConfig, Brightness.dark);
// });

// /// Provider to check if the app should use dark mode
// final useDarkModeProvider = StateProvider<bool>((ref) {
//   final businessConfig = ref.watch(businessConfigProvider).valueOrNull;
//   final settings = businessConfig?.settings ?? {};

//   // Check if we have a dark mode setting, or use system default
//   final useSystemTheme = settings['useSystemTheme'] as bool? ?? true;
//   if (useSystemTheme) {
//     // Use system theme
//     final window = PlatformDispatcher.instance;
//     return window.platformBrightness == Brightness.dark;
//   } else {
//     // Use app setting
//     return settings['darkMode'] as bool? ?? false;
//   }
// });

// /// Provider for current theme based on dark mode preference
// final currentThemeProvider = Provider<ThemeData>((ref) {
//   final useDarkMode = ref.watch(useDarkModeProvider);
//   return useDarkMode
//       ? ref.watch(darkThemeProvider)
//       : ref.watch(lightThemeProvider);
// });

// File: lib/src/core/theme/business_theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../business/business_config_provider.dart';
import '../user_preference/user_preference_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';

/// Generates theme data based on business settings
class BusinessThemeManager {
  // Create a light theme based on business colors
  static ThemeData createLightTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color tertiaryColor,
    required Color accentColor,
  }) {
    // Create color scheme from colors
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      error: accentColor,
    );

    // Create and return theme data
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  // Create a dark theme based on business colors
  static ThemeData createDarkTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color tertiaryColor,
    required Color accentColor,
  }) {
    // Create a dark color scheme from colors
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      error: accentColor,
    );

    // Create and return theme data
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

/// Provider for light theme
final lightThemeProvider = Provider<ThemeData>((ref) {
  // Get colors from business config or use defaults
  final primaryColor = ref.watch(primaryColorProvider);
  final secondaryColor = ref.watch(secondaryColorProvider);
  final tertiaryColor = ref.watch(tertiaryColorProvider);
  final accentColor = ref.watch(accentColorProvider);

  // Check if we have a business configuration
  final hasBusinessConfig = ref.watch(businessConfigProvider).hasValue &&
      ref.watch(businessConfigProvider).valueOrNull != null;

  // If we have a business config, use it to create the theme
  if (hasBusinessConfig) {
    return BusinessThemeManager.createLightTheme(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      accentColor: accentColor,
    );
  }

  // Otherwise use the default app theme
  return AppTheme.lightTheme;
});

/// Provider for dark theme
final darkThemeProvider = Provider<ThemeData>((ref) {
  // Get colors from business config or use defaults
  final primaryColor = ref.watch(primaryColorProvider);
  final secondaryColor = ref.watch(secondaryColorProvider);
  final tertiaryColor = ref.watch(tertiaryColorProvider);
  final accentColor = ref.watch(accentColorProvider);

  // Check if we have a business configuration
  final hasBusinessConfig = ref.watch(businessConfigProvider).hasValue &&
      ref.watch(businessConfigProvider).valueOrNull != null;

  // If we have a business config, use it to create the theme
  if (hasBusinessConfig) {
    return BusinessThemeManager.createDarkTheme(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      tertiaryColor: tertiaryColor,
      accentColor: accentColor,
    );
  }

  // Otherwise use the default app theme
  return AppTheme.darkTheme;
});

/// ThemeMode provider - combines user preference and business settings
final themeModeProvider = Provider<ThemeMode>((ref) {
  // Check if business settings say to use system theme
  final useSystemTheme = ref.watch(useSystemThemeProvider);

  // If using system theme, return system
  if (useSystemTheme) {
    return ThemeMode.system;
  }

  // Otherwise, check if business settings specify dark mode
  final isDarkMode = ref.watch(isDarkModeEnabledProvider);

  // Return theme mode based on business setting
  return isDarkMode ? ThemeMode.dark : ThemeMode.light;
});

/// Merged theme mode provider - gives priority to user preferences
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  // Get user preference from user_preference_provider
  final userTheme = ref.watch(themeProvider);

  // Get business theme mode
  final businessThemeMode = ref.watch(themeModeProvider);

  // User theme takes precedence if it's not set to system
  if (userTheme != ThemeMode.system) {
    return userTheme;
  }

  // Otherwise, use business theme mode
  return businessThemeMode;
});
