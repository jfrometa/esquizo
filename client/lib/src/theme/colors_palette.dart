import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:starter_architecture_flutter_firebase/src/screens/providers/user_preference/user_preference_provider.dart';

class ColorsPaletteRedonda1 {
  static const Color primary1 = Color(0xFF863509); // Main brand color
  static const Color lightBrown = Color(0xFFBF8768); // Lighter brown for AppBar
  static const Color deepBrown =
      Color(0xFFA7613B); // Deeper brown for body backgrounds
  static const Color softBrown =
      Color.fromARGB(255, 241, 227, 219); // Lightest brown for backgrounds
  static const Color white = Colors.white;

  static const Color primary = Color(0xFF402e32); // Main brand color
  static const Color lightBrown1 =
      Color(0xFFfff7f0); // Lighter brown for AppBar
  static const Color deepBrown1 =
      Color(0xFF694631); // Deeper brown for body backgrounds
  static const Color background =
      Color.fromARGB(255, 249, 245, 242); // Lightest brown for backgrounds
  static const Color orange = Color(0xFFd87738);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 3,
        titleTextStyle: ThemeData.light().textTheme.headlineMedium?.copyWith(
              color: deepBrown1,
              fontWeight: FontWeight.bold,
            ), // Headline6 for AppBar title
        iconTheme: const IconThemeData(color: primary),
      ),

      // Text Theme for the whole app
      textTheme: ThemeData.light().textTheme.copyWith(
            // Display text styles for large headings
            displayLarge: ThemeData.light().textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            displayMedium: ThemeData.light().textTheme.displayMedium?.copyWith(
                  color: deepBrown1,
                  fontWeight: FontWeight.w600,
                ),
            displaySmall: ThemeData.light().textTheme.displaySmall?.copyWith(
                  color: deepBrown1,
                  fontWeight: FontWeight.w600,
                ),

            // Headline text styles for medium-large headings
            headlineLarge: ThemeData.light().textTheme.headlineMedium?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
            headlineMedium: ThemeData.light().textTheme.headlineSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
            headlineSmall: ThemeData.light().textTheme.titleLarge?.copyWith(
                  color: deepBrown1,
                  fontWeight: FontWeight.w600,
                ),

            // Titles on different surfaces (large, medium, small)
            titleLarge: ThemeData.light().textTheme.titleMedium?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w700,
                ),
            titleMedium: ThemeData.light().textTheme.titleSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
            titleSmall: ThemeData.light().textTheme.bodySmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w500,
                ),

            // Body text styles for regular text
            bodyLarge: ThemeData.light().textTheme.bodyLarge?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.normal,
                ),
            bodyMedium: ThemeData.light().textTheme.bodyMedium?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.normal,
                ),
            bodySmall: ThemeData.light().textTheme.labelSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.normal,
                ),

            // Labels and buttons
            labelLarge: ThemeData.light().textTheme.labelLarge?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
            labelMedium: ThemeData.light().textTheme.bodySmall?.copyWith(
                  color: deepBrown1,
                ),
            labelSmall: ThemeData.light().textTheme.labelSmall?.copyWith(
                  color: deepBrown1,
                ),
          ),

      // Button Theme
      buttonTheme: ButtonThemeData(
        buttonColor: primary,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primary,
          textStyle: ThemeData.light().textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: primary,
      ),

      // TabBar Theme
      tabBarTheme: TabBarTheme(
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withAlpha(140),
        labelStyle: ThemeData.light().textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        unselectedLabelStyle: ThemeData.light().textTheme.labelLarge,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: white,
        unselectedItemColor: primary,
        selectedLabelStyle: ThemeData.light().textTheme.bodySmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
        unselectedLabelStyle: ThemeData.light().textTheme.bodySmall?.copyWith(
              color: lightBrown,
            ),
        selectedIconTheme: const IconThemeData(color: white),
        unselectedIconTheme: const IconThemeData(color: primary),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        titleTextStyle: ThemeData.light().textTheme.titleLarge?.copyWith(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
        contentTextStyle: ThemeData.light().textTheme.bodyMedium?.copyWith(
              color: deepBrown1,
            ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: deepBrown1,
        thickness: 1,
      ),

      // Color Scheme
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primary,
        onPrimary: Colors.white,
        secondary: deepBrown1,
        onSecondary: Colors.white,
        surface: deepBrown,
        onSurface: Colors.white,
        error: primary,
        onError: Colors.white,
      ),
    );
  }
}

 
// App theme configuration using Material 3 design system with brand colors
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Primary color palette - Brand colors
  // PANTONE Bright Red C
  static const Color brandPrimaryDark = Color(0xFFD12D14);    // Darker variant of primary
  static const Color brandPrimary = Color(0xFFFF3A1D);        // Primary brand color #ff3a1d
  static const Color brandPrimaryMedium = Color(0xFFFF5A40);  // Medium variant
  static const Color brandPrimaryLight = Color(0xFFFF8A78);   // Light variant
  static const Color brandPrimaryLightest = Color(0xFFFFEDE9); // Lightest variant for backgrounds
  
  // Secondary color palette
  // PANTONE 151C
  static const Color brandSecondaryDark = Color(0xFFCC6800);    // Darker variant of secondary
  static const Color brandSecondary = Color(0xFFFF8300);        // Secondary brand color #ff8300
  static const Color brandSecondaryMedium = Color(0xFFFF9E3A);  // Medium variant
  static const Color brandSecondaryLight = Color(0xFFFFBB78);   // Light variant
  static const Color brandSecondaryLightest = Color(0xFFFFEFDC); // Lightest variant for backgrounds
  
  // Neutral color palette - for backgrounds and surfaces
  static const Color neutralDark = Color(0xFF1E1E1E);        // Dark neutral for text
  static const Color neutralMedium = Color(0xFF757575);      // Medium neutral for secondary text
  static const Color neutralLight = Color(0xFFE0E0E0);       // Light neutral for borders
  static const Color neutralLightest = Color(0xFFF8F8F8);    // Lightest neutral for backgrounds
  
  // Text colors
  static const Color textPrimary = Color(0xFF1E1E1E);         // Main text color
  static const Color textSecondary = Color(0xFF757575);       // Secondary text
  static const Color textOnPrimary = Colors.white;            // Text on primary
  static const Color textOnSecondary = Colors.white;          // Text on secondary
  
  // Status colors
  static const Color successColor = Color(0xFF4CAF50);        // Success
  static const Color warningColor = Color(0xFFFFC107);        // Warning
  static const Color errorColor = Color(0xFFE53935);          // Error
  static const Color infoColor = Color(0xFF2196F3);           // Info
  
  // Error and warning colors
  static const Color errorMain = Color(0xFFE53935);           // Error
  static const Color errorLight = Color(0xFFFFCDD2);          // Light error
  static const Color errorDark = Color(0xFFB71C1C);           // Dark error
  
  // Border and decoration colors
  static const Color outlineMain = Color(0xFFBDBDBD);         // Outline
  static const Color outlineLight = Color(0xFFE0E0E0);        // Light outline
  
  // System colors
  static const Color shadowColor = Color(0x40000000);         // Shadows with 25% opacity
  static const Color scrimColor = Color(0x80000000);          // Scrim with 50% opacity
  
  // Inverse colors (for dark mode/contrast)
  static const Color inverseSurface = Color(0xFF1E1E1E);
  static const Color inverseOnSurface = Color(0xFFF8F8F8);
  static const Color inversePrimary = Color(0xFFFF8A78);

  // Dark mode variants
  static const Color darkModePrimary = Color(0xFFFF8A78);
  static const Color darkModeOnPrimary = Color(0xFF690002);
  static const Color darkModePrimaryContainer = Color(0xFF930005);
  static const Color darkModeOnPrimaryContainer = Color(0xFFFFDAD5);
  
  static const Color darkModeSecondary = Color(0xFFFFB77D);
  static const Color darkModeOnSecondary = Color(0xFF4B2800);
  static const Color darkModeSecondaryContainer = Color(0xFF6B3C00);
  static const Color darkModeOnSecondaryContainer = Color(0xFFFFDCC1);
  
  static const Color darkModeBackground = Color(0xFF1E1E1E);
  static const Color darkModeOnBackground = Color(0xFFE0E0E0);
  static const Color darkModeSurface = Color(0xFF2D2D2D);
  static const Color darkModeOnSurface = Color(0xFFE0E0E0);
  static const Color darkModeSurfaceVariant = Color(0xFF3D3D3D);
  static const Color darkModeOnSurfaceVariant = Color(0xFFBDBDBD);

  /// Typography configuration - keeping Montserrat for headings and Roboto for body
  static const String fontHeadings = 'Montserrat';
  static const String fontBody = 'Roboto';
  
  // Font sizes
  static const double displayLargeSize = 57.0;
  static const double displayMediumSize = 45.0;
  static const double displaySmallSize = 36.0;
  
  static const double headlineLargeSize = 32.0;
  static const double headlineMediumSize = 28.0;
  static const double headlineSmallSize = 24.0;
  
  static const double titleLargeSize = 22.0;
  static const double titleMediumSize = 16.0;
  static const double titleSmallSize = 14.0;
  
  static const double bodyLargeSize = 16.0;
  static const double bodyMediumSize = 14.0;
  static const double bodySmallSize = 12.0;
  
  static const double labelLargeSize = 14.0;
  static const double labelMediumSize = 12.0;
  static const double labelSmallSize = 11.0;

  /// Returns the light theme configuration
  static ThemeData get lightTheme {
    return _buildThemeData(Brightness.light);
  }

  /// Returns the dark theme configuration
  static ThemeData get darkTheme {
    return _buildThemeData(Brightness.dark);
  }

  /// Builds the theme data based on the specified brightness
  // Fix the rendering issue by ensuring proper constraints in the ThemeData
  static ThemeData _buildThemeData(Brightness brightness) {
    final ColorScheme colorScheme = _getColorScheme(brightness);
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      
      // Apply text theme
      textTheme: _createTextTheme(colorScheme),
      
      // Apply component themes
      appBarTheme: _createAppBarTheme(colorScheme),
      cardTheme: _createCardTheme(),
      elevatedButtonTheme: _createElevatedButtonTheme(colorScheme),
      outlinedButtonTheme: _createOutlinedButtonTheme(colorScheme),
      textButtonTheme: _createTextButtonTheme(colorScheme),
      floatingActionButtonTheme: _createFabTheme(colorScheme),
      tabBarTheme: _createTabBarTheme(colorScheme),
      bottomNavigationBarTheme: _createBottomNavBarTheme(colorScheme),
      dialogTheme: _createDialogTheme(colorScheme),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          fontFamily: fontBody,
          color: colorScheme.onInverseSurface,
        ),
      ),
      
      // Material 3 component theming
      navigationRailTheme: _createNavigationRailTheme(colorScheme),
      chipTheme: _createChipTheme(colorScheme),
      navigationBarTheme: _createNavigationBarTheme(colorScheme),
      
      // Adaptive properties for cross-platform
      visualDensity: VisualDensity.adaptivePlatformDensity,
      
      // Scrollbars for desktop
      scrollbarTheme: const ScrollbarThemeData(
        thickness: MaterialStatePropertyAll(8.0),
        thumbVisibility: MaterialStatePropertyAll(true),
        radius: Radius.circular(8.0),
      ),
    );
  }

  /// Creates color scheme based on brightness
  static ColorScheme _getColorScheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return ColorScheme(
        brightness: Brightness.light,
        primary: brandPrimary,
        onPrimary: textOnPrimary,
        primaryContainer: brandPrimaryLight,
        onPrimaryContainer: brandPrimaryDark,
        secondary: brandSecondary,
        onSecondary: textOnSecondary,
        secondaryContainer: brandSecondaryLight,
        onSecondaryContainer: brandSecondaryDark,
        tertiary: brandSecondaryMedium,
        onTertiary: textOnSecondary,
        tertiaryContainer: brandPrimaryMedium,
        onTertiaryContainer: textOnPrimary,
        error: errorMain,
        onError: textOnPrimary,
        errorContainer: errorLight,
        onErrorContainer: errorDark,
        background: neutralLightest,
        onBackground: textPrimary,
        surface: Colors.white,
        onSurface: textPrimary,
        surfaceVariant: brandPrimaryLightest,
        onSurfaceVariant: textSecondary,
        outline: outlineMain,
        outlineVariant: outlineLight,
        shadow: shadowColor,
        scrim: scrimColor,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
        inversePrimary: inversePrimary,
      );
    } else {
      // Dark theme - use dark mode variants
      return ColorScheme(
        brightness: Brightness.dark,
        primary: darkModePrimary,
        onPrimary: darkModeOnPrimary,
        primaryContainer: darkModePrimaryContainer,
        onPrimaryContainer: darkModeOnPrimaryContainer,
        secondary: darkModeSecondary,
        onSecondary: darkModeOnSecondary,
        secondaryContainer: darkModeSecondaryContainer,
        onSecondaryContainer: darkModeOnSecondaryContainer,
        tertiary: Color(0xFFFFB77D),
        onTertiary: Color(0xFF462700),
        tertiaryContainer: Color(0xFF633B00),
        onTertiaryContainer: Color(0xFFFFDCC1),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: errorLight,
        background: darkModeBackground,
        onBackground: darkModeOnBackground,
        surface: darkModeSurface,
        onSurface: darkModeOnSurface,
        surfaceVariant: darkModeSurfaceVariant,
        onSurfaceVariant: darkModeOnSurfaceVariant,
        outline: Color(0xFF8C8C8C),
        outlineVariant: darkModeSurfaceVariant,
        shadow: shadowColor,
        scrim: scrimColor,
        inverseSurface: Color(0xFFF8F8F8),
        onInverseSurface: Color(0xFF1E1E1E),
        inversePrimary: brandPrimary,
      );
    }
  }

  /// Creates text theme based on color scheme
  static TextTheme _createTextTheme(ColorScheme colorScheme) {
    final Color textColor = colorScheme.onSurface;
    
    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontFamily: fontHeadings,
        fontSize: displayLargeSize,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontFamily: fontHeadings,
        fontSize: displayMediumSize,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0,
      ),
      displaySmall: TextStyle(
        fontFamily: fontHeadings,
        fontSize: displaySmallSize,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0,
      ),
      
      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: fontHeadings,
        fontSize: headlineLargeSize,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontHeadings,
        fontSize: headlineMediumSize,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontHeadings,
        fontSize: headlineSmallSize,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
      ),
      
      // Title styles
      titleLarge: TextStyle(
        fontFamily: fontHeadings,
        fontSize: titleLargeSize,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontFamily: fontHeadings,
        fontSize: titleMediumSize,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontFamily: fontHeadings,
        fontSize: titleSmallSize,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.1,
      ),
      
      // Body styles
      bodyLarge: TextStyle(
        fontFamily: fontBody,
        fontSize: bodyLargeSize,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontBody,
        fontSize: bodyMediumSize,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontFamily: fontBody,
        fontSize: bodySmallSize,
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.4,
      ),
      
      // Label styles
      labelLarge: TextStyle(
        fontFamily: fontBody,
        fontSize: labelLargeSize,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontFamily: fontBody,
        fontSize: labelMediumSize,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontFamily: fontBody,
        fontSize: labelSmallSize,
        fontWeight: FontWeight.w500,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Creates app bar theme
  static AppBarTheme _createAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: fontHeadings,
        fontSize: titleLargeSize,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24,
      ),
    );
  }

  /// Creates card theme
  static CardTheme _createCardTheme() {
    return const CardTheme(
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    );
  }

  /// Creates elevated button theme
  static ElevatedButtonThemeData _createElevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: TextStyle(
          fontFamily: fontBody,
          fontSize: labelLargeSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  /// Creates outlined button theme
  static OutlinedButtonThemeData _createOutlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: colorScheme.outline, width: 1),
        textStyle: TextStyle(
          fontFamily: fontBody,
          fontSize: labelLargeSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  /// Creates text button theme
  static TextButtonThemeData _createTextButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontFamily: fontBody,
          fontSize: labelLargeSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  /// Creates floating action button theme
  static FloatingActionButtonThemeData _createFabTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 6,
      highlightElevation: 12,
    );
  }

  /// Creates tab bar theme
  static TabBarTheme _createTabBarTheme(ColorScheme colorScheme) {
    return TabBarTheme(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          width: 2,
          color: colorScheme.primary,
        ),
      ),
      labelStyle: TextStyle(
        fontFamily: fontBody,
        fontSize: labelLargeSize,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontBody,
        fontSize: labelLargeSize,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  /// Creates bottom navigation bar theme
  static BottomNavigationBarThemeData _createBottomNavBarTheme(ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      selectedLabelStyle: TextStyle(
        fontFamily: fontBody,
        fontSize: labelSmallSize,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: fontBody,
        fontSize: labelSmallSize,
        fontWeight: FontWeight.w400,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  /// Creates dialog theme
  static DialogTheme _createDialogTheme(ColorScheme colorScheme) {
    return DialogTheme(
      backgroundColor: colorScheme.surface,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: TextStyle(
        fontFamily: fontHeadings,
        fontSize: headlineSmallSize,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      contentTextStyle: TextStyle(
        fontFamily: fontBody,
        fontSize: bodyMediumSize,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// Creates navigation rail theme (for tablets/desktop)
  static NavigationRailThemeData _createNavigationRailTheme(ColorScheme colorScheme) {
    return NavigationRailThemeData(
      backgroundColor: colorScheme.surface,
      selectedIconTheme: IconThemeData(
        color: colorScheme.primary,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 24,
      ),
      selectedLabelTextStyle: TextStyle(
        fontFamily: fontBody,
        fontSize: labelMediumSize,
        fontWeight: FontWeight.w500,
        color: colorScheme.primary,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontFamily: fontBody,
        fontSize: labelMediumSize,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      useIndicator: true,
      indicatorColor: colorScheme.primaryContainer,
    );
  }

  /// Creates chip theme
  static ChipThemeData _createChipTheme(ColorScheme colorScheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceVariant,
      deleteIconColor: colorScheme.onSurfaceVariant,
      disabledColor: colorScheme.surfaceVariant.withOpacity(0.5),
      selectedColor: colorScheme.primaryContainer,
      secondarySelectedColor: colorScheme.secondaryContainer,
      padding: const EdgeInsets.all(8),
      labelStyle: TextStyle(
        fontFamily: fontBody,
        fontSize: bodySmallSize,
        color: colorScheme.onSurfaceVariant,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: fontBody,
        fontSize: bodySmallSize,
        color: colorScheme.onSecondaryContainer,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Creates navigation bar theme (for bottom navigation in Material 3)
  static NavigationBarThemeData _createNavigationBarTheme(ColorScheme colorScheme) {
    return NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      height: 80,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return TextStyle(
            fontFamily: fontBody,
            fontSize: labelSmallSize,
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
          );
        }
        return TextStyle(
          fontFamily: fontBody,
          fontSize: labelSmallSize,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(
            size: 24,
            color: colorScheme.onPrimaryContainer,
          );
        }
        return IconThemeData(
          size: 24,
          color: colorScheme.onSurfaceVariant,
        );
      }),
      shadowColor: colorScheme.shadow,
      elevation: 3,
    );
  }
}

// Extension to provide theme-related utilities
extension ThemeHelpers on BuildContext {
  // Easy access to current theme
  ThemeData get theme => Theme.of(this);
  
  // Easy access to current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  // Easy access to current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

// Theme provider that integrates with UserPreferencesRepository
final appThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  
  switch (themeMode) {
    case ThemeMode.light:
      return AppTheme.lightTheme;
    case ThemeMode.dark:
      return AppTheme.darkTheme;
    case ThemeMode.system:
    default:
      // For system mode, let's determine based on platform brightness
      final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return platformBrightness == Brightness.dark 
          ? AppTheme.darkTheme 
          : AppTheme.lightTheme;
  }
});