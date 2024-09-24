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
  static const Color primary = Color(0xFF863509); // Main brand color
  static const Color lightBrown = Color(0xFFBF8768); // Lighter brown for AppBar
  static const Color deepBrown = Color(0xFFA7613B); // Deeper brown for body backgrounds
  static const Color softBrown = Color(0xFFF3D2C0); // Lightest brown for backgrounds
  static const Color white = Colors.white;

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: lightBrown,
      scaffoldBackgroundColor: lightBrown,
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        foregroundColor: primary, // Ensures AppBar title is white
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontSize: 34.0, ),
        displayMedium: TextStyle(color: Colors.white, fontSize: 28.0),
        displaySmall: TextStyle(color: Colors.white, fontSize: 24.0),
        headlineLarge: TextStyle(color: Colors.white, fontSize: 20.0),
        headlineMedium: TextStyle(color: Colors.white, fontSize: 16.0),
        headlineSmall: TextStyle(color: Colors.white, fontSize: 14.0),
        titleLarge: TextStyle(color: deepBrown, fontSize: 20.0, fontWeight: FontWeight.bold), // Titles on white backgrounds
        titleMedium: TextStyle(color: deepBrown, fontSize: 18.0),
        titleSmall: TextStyle(color: deepBrown, fontSize: 16.0),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16.0),
        bodyMedium: TextStyle(color: Colors.white, fontSize: 14.0),
        bodySmall: TextStyle(color: Colors.white, fontSize: 12.0),
        labelLarge: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
        labelMedium: TextStyle(color: Colors.white, fontSize: 12.0),
        labelSmall: TextStyle(color: Colors.white, fontSize: 10.0),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white, // Icons throughout the app
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primary, // Buttons use the primary brand color
        textTheme: ButtonTextTheme.primary,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white, // Active tab text color
        unselectedLabelColor: Colors.white.withAlpha(140), // Inactive tab text color, slightly transparent
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.white, width: 2.0), // Underline tab indicator in white
        ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: lightBrown,
        onPrimary: Colors.white,
        secondary: softBrown,
        onSecondary: Colors.white,
        surface: deepBrown,
        onSurface: Colors.white,
        error: primary,
        onError: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: white,
        unselectedItemColor: primary,
        selectedLabelStyle: TextStyle(color: primary),
        unselectedLabelStyle: TextStyle(color: lightBrown),
        selectedIconTheme: IconThemeData(color: white),
        unselectedIconTheme: IconThemeData(color: primary),
      ),
    );
  }
}
