import 'package:flutter/material.dart';

class ColorsPalette {
  const ColorsPalette({
    required this.ternary20,
    required this.primary,
    required this.primary70,
    required this.primary7,
    required this.primary40,
    required this.neutral1,
    required this.neutral2,
    required this.neutral3,
    required this.neutral4,
    required this.neutral5,
    required this.neutral6,
    required this.neutral7,
    required this.neutral8,
    required this.neutral9,
    required this.darkBG,
    required this.positiveAction,
    required this.positiveActionSoft,
    required this.secondary,
    required this.secondary70,
    required this.secondary40,
    required this.secondary7,
    required this.secondarySoft,
    required this.tertiary,
    required this.negativeAction,
    required this.negativeActionSoft,
    required this.alert,
    required this.alertSoft,
    required this.white,
    required this.black,
  });

  final Color primary;
  final Color primary70;
  final Color primary40;
  final Color primary7;

  final Color darkBG;

  final Color positiveAction;
  final Color positiveActionSoft;

  final Color secondary;
  final Color secondary70;
  final Color secondary40;
  final Color secondary7;
  final Color secondarySoft;

  final Color negativeAction;
  final Color negativeActionSoft;

  final Color alert;
  final Color alertSoft;

  final Color tertiary;
  final Color ternary20;

  final Color white;
  final Color black;

  final Color neutral1;
  final Color neutral2;
  final Color neutral3;
  final Color neutral4;
  final Color neutral5;
  final Color neutral6;
  final Color neutral7;
  final Color neutral8;
  final Color neutral9;

//add these colors as these are the brand colors: #863509, #f3d2c0, #bf8768, #a7613b
  static ColorsPalette get light {
    return const ColorsPalette(
      alert: Color(0xFF863509), // updated to brand color
      alertSoft: Color(0xFFF3D2C0), // updated to brand color
      negativeAction:
          Color(0xFFA7613B), // darker brand tone for important actions
      negativeActionSoft:
          Color(0xFFBF8768), // softer tone for less priority actions
      darkBG: Color(0xFFF3D2C0), // lightest brand color for backgrounds
      positiveAction: Color(0xFF863509), // contrast color for positive actions
      positiveActionSoft:
          Color(0xFFF3D2C0), // soft background for positive hints
      primary7: Color(0xFF863509),
      primary40: Color.fromRGBO(134, 53, 9, 0.4),
      primary70: Color.fromRGBO(134, 53, 9, 0.7),
      primary: Color.fromRGBO(134, 53, 9, 0.07), // main brand color
      secondary: Color(0xFFA7613B), // secondary brand color
      secondary40: Color.fromRGBO(167, 97, 59, 0.4),
      secondary70: Color.fromRGBO(167, 97, 59, 0.7),
      secondary7: Color.fromRGBO(167, 97, 59, 0.07),
      secondarySoft: Color(0xFFF3D2C0), // softest brand color
      neutral1: Color(0xFFF8F9FA),
      neutral2: Color(0xFFF1F3F5),
      neutral3: Color(0xFFE9ECEF),
      neutral4: Color(0xFFDEE2E6),
      neutral5: Color(0xFFCED4DA),
      neutral6: Color(0xFFADB5BD),
      neutral7: Color(0xFF6A7076),
      neutral8: Color(0xFF4F575E),
      neutral9: Color(0xFF272B30),
      tertiary: Color(0xFFA7613B),
      black: Color(0xFF000000),
      white: Color(0xFFFFFFFF),
      ternary20: Color(0xFFCDE2E3), // adjusted to match brand aesthetic
    );
  }

  static ColorsPalette get dark {
    return const ColorsPalette(
      alert: Color(0xFF863509), // maintained brand color for consistency
      alertSoft: Color(0xFF693526), // darker variant for soft alert
      negativeAction:
          Color(0xFFA7613B), // darker brand tone for negative actions
      negativeActionSoft: Color(0xFFBF8768), // soft negative actions
      darkBG: Color(0xFF2C2C2C), // darker background
      positiveAction:
          Color(0xFF98D3AE), // lighter positive action for dark theme
      positiveActionSoft: Color(0xFF303F36), // dark green for background hints
      primary7: Color.fromRGBO(134, 53, 9, 0.07),
      primary40: Color.fromRGBO(134, 53, 9, 0.4),
      primary70: Color.fromRGBO(134, 53, 9, 0.7),
      primary: Color(0xFF863509), // main brand color
      secondary: Color(0xFFA7613B), // secondary brand color
      secondary40: Color.fromRGBO(167, 97, 59, 0.4),
      secondary70: Color.fromRGBO(167, 97, 59, 0.7),
      secondary7: Color.fromRGBO(167, 97, 59, 0.07),
      secondarySoft: Color(0xFF693526), // darker soft color for overlays
      neutral1: Color(0xFF212121),
      neutral2: Color(0xFF373737),
      neutral3: Color(0xFF555555),
      neutral4: Color(0xFF787878),
      neutral5: Color(0xFF919191),
      neutral6: Color(0xFFAFAFAF),
      neutral7: Color(0xFFC8C8C8),
      neutral8: Color(0xFFDCDCDC),
      neutral9: Color(0xFFF5F5F5),
      tertiary: Color(0xFF616161),
      black: Color(0xFF000000),
      white: Color(0xFFFFFFFF),
      ternary20: Color(0xFF69BECA), // adjusted blue for dark theme accents
    );
  }
}

class ColorsPaletteRedonda {
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
