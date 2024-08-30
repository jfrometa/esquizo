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

  static ColorsPalette get light {
    return const ColorsPalette(
      alert: Color.fromRGBO(247, 165, 0, 1),
      alertSoft: Color.fromRGBO(254, 241, 217, 1),
      negativeAction: Color.fromRGBO(211, 85, 73, 1),
      negativeActionSoft: Color.fromRGBO(251, 238, 237, 1),
      darkBG: Color.fromRGBO(52, 70, 62, 1),
      positiveAction: Color.fromRGBO(98, 217, 146, 1),
      positiveActionSoft: Color.fromRGBO(230, 245, 239, 1),
      primary7: Color.fromRGBO(2, 196, 178, 0.07),
      primary40: Color.fromRGBO(2, 196, 178, 0.40),
      primary70: Color.fromRGBO(2, 196, 178, 0.7),
      primary: Color.fromRGBO(2, 196, 178, 1),
      secondary: Color.fromRGBO(41, 48, 64, 1),
      secondary40: Color.fromRGBO(41, 48, 64, 0.40),
      secondary70: Color.fromRGBO(41, 48, 64, 0.7),
      secondary7: Color.fromRGBO(41, 48, 64, 0.07),
      secondarySoft: Color.fromRGBO(255, 250, 234, 1),
      neutral1: Color.fromRGBO(248, 249, 250, 1),
      neutral2: Color.fromRGBO(241, 243, 245, 1),
      neutral3: Color.fromRGBO(233, 236, 239, 1),
      neutral4: Color.fromRGBO(222, 226, 230, 1),
      neutral5: Color.fromRGBO(206, 212, 218, 1),
      neutral6: Color.fromRGBO(173, 181, 189, 1),
      neutral7: Color.fromRGBO(106, 113, 120, 1),
      neutral8: Color.fromRGBO(79, 87, 94, 1),
      neutral9: Color.fromRGBO(39, 43, 48, 1),
      tertiary: Color.fromRGBO(6, 110, 114, 1),
      black: Color.fromRGBO(0, 0, 0, 1),
      white: Color.fromRGBO(255, 255, 255, 1),
      ternary20: Color.fromRGBO(205, 226, 227, 1),
    );
  }

  static ColorsPalette get dark {
    return const ColorsPalette(
      alert: Color.fromRGBO(255, 183, 77, 1),
      alertSoft: Color.fromRGBO(69, 42, 0, 1),
      negativeAction: Color.fromRGBO(239, 83, 80, 1),
      negativeActionSoft: Color.fromRGBO(79, 20, 20, 1),
      darkBG: Color.fromRGBO(18, 18, 18, 1),
      positiveAction: Color.fromRGBO(76, 175, 80, 1),
      positiveActionSoft: Color.fromRGBO(19, 42, 19, 1),
      primary7: Color.fromRGBO(0, 229, 255, 0.07),
      primary40: Color.fromRGBO(0, 229, 255, 0.40),
      primary70: Color.fromRGBO(0, 229, 255, 0.7),
      primary: Color.fromRGBO(0, 229, 255, 1),
      secondary: Color.fromRGBO(225, 190, 231, 1),
      secondary40: Color.fromRGBO(81, 45, 168, 0.40),
      secondary70: Color.fromRGBO(81, 45, 168, 0.7),
      secondary7: Color.fromRGBO(81, 45, 168, 0.07),
      secondarySoft: Color.fromRGBO(29, 17, 53, 1),
      neutral1: Color.fromRGBO(33, 33, 33, 1),
      neutral2: Color.fromRGBO(55, 55, 55, 1),
      neutral3: Color.fromRGBO(85, 85, 85, 1),
      neutral4: Color.fromRGBO(120, 120, 120, 1),
      neutral5: Color.fromRGBO(145, 145, 145, 1),
      neutral6: Color.fromRGBO(175, 175, 175, 1),
      neutral7: Color.fromRGBO(200, 200, 200, 1),
      neutral8: Color.fromRGBO(220, 220, 220, 1),
      neutral9: Color.fromRGBO(245, 245, 245, 1),
      tertiary: Color.fromRGBO(97, 97, 97, 1),
      black: Color.fromRGBO(0, 0, 0, 1),
      white: Color.fromRGBO(255, 255, 255, 1),
      ternary20: Color.fromRGBO(105, 190, 210, 1),
    );
  }
}
