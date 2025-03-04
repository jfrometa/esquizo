import 'package:flutter/material.dart';

class Constants {
  static String appName = "Foody Bite";

  //Colors for theme
  static Color lightPrimary = const Color(0xfffcfcff);
  static Color darkPrimary = Colors.black;
  static Color lightAccent = const Color(0xff5563ff);
  static Color darkAccent = const Color(0xff5563ff);
  static Color lightBG = const Color(0xfffcfcff);
  static Color darkBG = Colors.black;
  static Color? ratingBG = Colors.yellow[600];

  static ThemeData lightTheme = ThemeData(
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBG,
    appBarTheme: AppBarTheme(
      elevation: 3,
      toolbarTextStyle: TextTheme(
        titleLarge: TextStyle(
          color: darkBG,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ).bodyMedium,
      titleTextStyle: TextTheme(
        titleLarge: TextStyle(
          color: darkBG,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ).titleLarge,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: lightAccent),
    colorScheme: ColorScheme(
      primary: Colors.blue, // Primary color of the app
      secondary: Colors.amber, // Secondary color
      surface: darkBG, // Background color
      error: Colors.red, // Error color
      onPrimary: Colors.white, // Color to use on primary surfaces
      onSecondary: Colors.black, // Color to use on secondary surfaces
      onSurface: Colors.white, // Color to use on backgrounds
      onError: Colors.white, // Color to use on error surfaces
      brightness: Brightness.dark, // Overall brightness of the color scheme
    ),
  );

  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBG,
      appBarTheme: AppBarTheme(
        toolbarTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: lightBG,
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
          ),
        ).bodyMedium,
        titleTextStyle: TextTheme(
          titleLarge: TextStyle(
            color: lightBG,
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
          ),
        ).titleLarge,
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: darkAccent),
      colorScheme: ColorScheme(
        primary: Colors.blue, // Primary color of the app
        secondary: Colors.amber, // Secondary color
        surface: darkBG, // Background color
        error: Colors.red, // Error color
        onPrimary: Colors.white, // Color to use on primary surfaces
        onSecondary: Colors.black, // Color to use on secondary surfaces
        onSurface: Colors.white, // Color to use on backgrounds
        onError: Colors.white, // Color to use on error surfaces
        brightness: Brightness.dark, // Overall brightness of the color scheme
      ));
}
