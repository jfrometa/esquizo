import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class TextStyles {
  TextStyles({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.button,
    required this.outPlatformTitle,
  });

  factory TextStyles.fromColorsPalette(ColorsPalette colorsPalette) {
    return TextStyles(
      displayLarge: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 30,
          height: 1.26,
        ),
      ),
      displayMedium: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          height: 1.416,
        ),
      ),
      displaySmall: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          height: 1.2,
        ),
      ),
      headlineLarge: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          height: 1.375,
        ),
      ),
      headlineMedium: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.375,
        ),
      ),
      headlineSmall: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1.375,
        ),
      ),
      titleLarge: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.714,
        ),
      ),
      titleMedium: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary70,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.667,
        ),
      ),
      titleSmall: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary70,
          fontWeight: FontWeight.w400,
          fontSize: 11,
          height: 1.636,
        ),
      ),
      bodyLarge: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary70,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.714,
        ),
      ),
      bodyMedium: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary70,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.667,
        ),
      ),
      bodySmall: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary70,
          fontWeight: FontWeight.w400,
          fontSize: 11,
          height: 1.636,
        ),
      ),
      labelLarge: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary70,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.667,
        ),
      ),
      labelMedium: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary70,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1.667,
        ),
      ),
      labelSmall: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary70,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          height: 1.5,
        ),
      ),
      button: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: colorsPalette.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1.5,
        ),
        decoration: TextDecoration.underline,
      ),
      outPlatformTitle: GoogleFonts.ebGaramond(
        textStyle: TextStyle(
          color: colorsPalette.secondary,
          fontWeight: FontWeight.w700,
          fontSize: 30,
          height: 1.4,
        ),
      ),
    );
  }

  TextStyle displayLarge;
  TextStyle displayMedium;
  TextStyle displaySmall;
  TextStyle headlineLarge;
  TextStyle headlineMedium;
  TextStyle headlineSmall;
  TextStyle titleLarge;
  TextStyle titleMedium;
  TextStyle titleSmall;
  TextStyle bodyLarge;
  TextStyle bodyMedium;
  TextStyle bodySmall;
  TextStyle labelLarge;
  TextStyle labelMedium;
  TextStyle labelSmall;
  TextStyle button;
  TextStyle outPlatformTitle;
}
