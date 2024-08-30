import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/text_styles.dart';

class AppTheme {
  static ColorsPalette lightColorsPalette = ColorsPalette.light;
  static ColorsPalette darkColorsPalette = ColorsPalette.dark;

  static TextStyles textStyles =
      TextStyles.fromColorsPalette(lightColorsPalette);

  static ColorScheme lightColorScheme = ThemeData().colorScheme.copyWith(
        primary: lightColorsPalette.primary,
        onPrimary: lightColorsPalette.white,
        primaryContainer: lightColorsPalette.primary40,
        onPrimaryContainer: lightColorsPalette.black,
        secondary: lightColorsPalette.secondary,
        onSecondary: lightColorsPalette.white,
        secondaryContainer: lightColorsPalette.secondary40,
        onSecondaryContainer: lightColorsPalette.black,
        tertiary: lightColorsPalette.tertiary,
        onTertiary: lightColorsPalette.white,
        tertiaryContainer: lightColorsPalette.ternary20,
        onTertiaryContainer: lightColorsPalette.black,
        error: lightColorsPalette.negativeAction,
        onError: lightColorsPalette.white,
        errorContainer: lightColorsPalette.negativeActionSoft,
        onErrorContainer: lightColorsPalette.black,
        surface: lightColorsPalette.white,
        onSurface: lightColorsPalette.neutral9,
        surfaceContainerHighest: lightColorsPalette.neutral4,
        onSurfaceVariant: lightColorsPalette.neutral7,
        surfaceTint: lightColorsPalette.primary,
        outline: lightColorsPalette.neutral6,
        shadow: lightColorsPalette.black,
        inversePrimary: lightColorsPalette.primary70,
        inverseSurface: lightColorsPalette.neutral9,
        onInverseSurface: lightColorsPalette.neutral1,
        // inverseBackground: colorsPalette.darkBG,
        brightness: Brightness.light,
      );

  static ColorScheme darkColorScheme = ThemeData().colorScheme.copyWith(
        primary: darkColorsPalette.primary,
        onPrimary: darkColorsPalette.black,
        primaryContainer: darkColorsPalette.primary40,
        onPrimaryContainer: darkColorsPalette.white,
        secondary: darkColorsPalette.secondary,
        onSecondary: darkColorsPalette.black,
        secondaryContainer: darkColorsPalette.secondary40,
        onSecondaryContainer: darkColorsPalette.white,
        tertiary: darkColorsPalette.tertiary,
        onTertiary: darkColorsPalette.black,
        tertiaryContainer: darkColorsPalette.ternary20,
        onTertiaryContainer: darkColorsPalette.white,
        error: darkColorsPalette.negativeAction,
        onError: darkColorsPalette.black,
        errorContainer: darkColorsPalette.negativeActionSoft,
        onErrorContainer: darkColorsPalette.white,
        surface: darkColorsPalette.darkBG,
        onSurface: darkColorsPalette.neutral9,
        surfaceContainerHighest: darkColorsPalette.neutral4,
        onSurfaceVariant: darkColorsPalette.neutral7,
        surfaceTint: darkColorsPalette.primary,
        outline: darkColorsPalette.neutral6,
        shadow: darkColorsPalette.black,
        inversePrimary: darkColorsPalette.primary70,
        inverseSurface: darkColorsPalette.neutral9,
        onInverseSurface: darkColorsPalette.neutral1,
        brightness: Brightness.dark,
      );
  static ThemeData getLight() => ThemeData(
        useMaterial3: true,
        cardColor: CustomAppTheme(
          colorsPalette: ColorsPalette.light,
        ).colorsPalette.primary,
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: lightColorsPalette.secondary,
        ),
        primaryColor: lightColorsPalette.white,
        focusColor: lightColorsPalette.secondary,
        colorScheme: lightColorScheme,
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0.0,
          // backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          color: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: textStyles.displayLarge,
          displayMedium: textStyles.displayMedium,
          displaySmall: textStyles.displaySmall,
          headlineLarge: textStyles.headlineLarge,
          headlineMedium: textStyles.headlineMedium,
          headlineSmall: textStyles.headlineSmall,
          titleLarge: textStyles.titleLarge,
          titleMedium: textStyles.titleMedium,
          titleSmall: textStyles.titleSmall,
          bodyLarge: textStyles.bodyLarge,
          bodyMedium: textStyles.bodyMedium,
          bodySmall: textStyles.bodySmall,
          labelLarge: textStyles.labelLarge,
          labelMedium: textStyles.labelMedium,
          labelSmall: textStyles.labelSmall,
          // button: textStyles.textButton,
          // caption: textStyles.labelMedium, // Added for completeness
          // overline: textStyles.labelSmall, // Added for completeness
        ),
      );
  static ThemeData getDark() => ThemeData(
        useMaterial3: true,
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: darkColorsPalette.primary,
        ),
        primaryColor: darkColorsPalette.white,
        focusColor: darkColorsPalette.secondary,
        colorScheme: darkColorScheme,
        textTheme: TextTheme(
          displayLarge: textStyles.displayLarge,
          displayMedium: textStyles.displayMedium,
          displaySmall: textStyles.displaySmall,
          headlineLarge: textStyles.headlineLarge,
          headlineMedium: textStyles.headlineMedium,
          headlineSmall: textStyles.headlineSmall,
          titleLarge: textStyles.titleLarge,
          titleMedium: textStyles.titleMedium,
          titleSmall: textStyles.titleSmall,
          bodyLarge: textStyles.bodyLarge,
          bodyMedium: textStyles.bodyMedium,
          bodySmall: textStyles.bodySmall,
          labelLarge: textStyles.labelLarge,
          labelMedium: textStyles.labelMedium,
          labelSmall: textStyles.labelSmall,
        ),
      );
}

class CustomAppTheme {
  CustomAppTheme({required this.colorsPalette}) {
    textStyles = TextStyles.fromColorsPalette(colorsPalette);
  }
  ColorsPalette colorsPalette;
  late TextStyles textStyles;
}

final appThemeProvider = Provider<CustomAppTheme>(
  (ref) => CustomAppTheme(
    colorsPalette: ColorsPalette.light,
  ),
);

abstract class MarketplaceTheme {
  static ThemeData theme = ThemeData(
    fontFamily: GoogleFonts.lexend().fontFamily,
    textTheme: GoogleFonts.lexendTextTheme().copyWith().apply(
        bodyColor: const Color(0xff000000),
        displayColor: const Color(0xff000000)),
    colorScheme: const ColorScheme.light(
      primary: Color(0xffA2E3F6),
      secondary: Color(0xff4FAD85),
      tertiary: Color(0xffDE7A60),
      scrim: Color(0xffFFABC7),
      surface: Color(0xffFDF7F0),
      onSecondary: Color(0xff000000),
      shadow: Color(0xffAEAEAE),
      onPrimary: Color(0xffFFFFFF),
    ),
    useMaterial3: true,
    canvasColor: Colors.transparent,
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: const Color(0xffA2E3F6),
      indicatorShape: CircleBorder(
        side: BorderSide.lerp(
            const BorderSide(
              color: Color(0xff000000),
              width: 2,
            ),
            const BorderSide(
              color: Color(0xff000000),
              width: 2,
            ),
            1),
      ),
    ),
  );

  static const Color primary = Color(0xffA2E3F6);
  static const Color scrim = Color(0xffFFABC7);
  static const Color tertiary = Color(0xffDE7A60);
  static const Color secondary = Color(0xff4FAD85);
  static const Color borderColor = Colors.black12;
  static const Color focusedBorderColor = Colors.black45;

  static const double defaultBorderRadius = 16;

  static const double defaultTextSize = 16;

  static const Color defaultTextColor = Colors.black87;

  static TextStyle get heading1 => theme.textTheme.headlineLarge!.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        //height: 36,
        color: theme.colorScheme.onSecondary,
      );

  static TextStyle get heading2 => theme.textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        //height: 32,
        color: theme.colorScheme.onSecondary,
      );

  static TextStyle get heading3 => theme.textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        //height: 24,
        color: theme.colorScheme.onSecondary,
      );

  static TextStyle get subheading1 => theme.textTheme.bodyLarge!.copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 18,
        //height: 20,
        color: theme.colorScheme.onSecondary,
      );

  static TextStyle get subheading2 => theme.textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        //height: 18,
        color: theme.colorScheme.onSecondary,
      );
  static TextStyle get paragraph => theme.textTheme.bodySmall!.copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        //height: 18,
        color: theme.colorScheme.onSecondary,
      );

  static TextStyle get label => theme.textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        //height: 16,
        color: theme.colorScheme.onSecondary,
      );

  static TextStyle get dossierParagraph => GoogleFonts.anonymousPro().copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        //height: 18,
        color: theme.colorScheme.onSecondary,
      );

  static TextStyle get dossierSubheading => GoogleFonts.anonymousPro().copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 18,
        //height: 18,
        color: theme.colorScheme.onSecondary,
      );

  static TextStyle get dossierHeading => GoogleFonts.anonymousPro().copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        //height: 18,
        color: theme.colorScheme.onSecondary,
      );

  static const double _spacingUnit = 8;
  static const double spacing8 = _spacingUnit / 2;
  static const double spacing7 = _spacingUnit;
  static const double spacing6 = _spacingUnit * 1.5;
  static const double spacing5 = _spacingUnit * 2;
  static const double spacing4 = _spacingUnit * 2.5;
  static const double spacing3 = _spacingUnit * 3;
  static const double spacing2 = _spacingUnit * 3.5;
  static const double spacing1 = _spacingUnit * 4;

  static double lineWidth = 1;

  static const Widget verticalSpacer = SizedBox(height: spacing5);
}
