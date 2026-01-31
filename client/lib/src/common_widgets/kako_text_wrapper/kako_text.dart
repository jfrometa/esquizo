// lib/widgets/my_app_text.dart

import 'package:flutter/material.dart';

/// This is the default text widget for the entire application.
/// It acts as a drop-in replacement for `Text`, but uses
/// `SelectableText` to ensure that all text is selectable by default.
class KakoText extends StatelessWidget {
  // The text to display.
  final String data;

  // Pass-through all the properties of the standard Text widget.
  @override
  final Key? key;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const KakoText(
    this.data, {
    this.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return a SelectableText widget, passing all the properties through.
    return SelectableText(
      data,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      // The 'locale' and 'softWrap' properties are not available on SelectableText
      // so we omit them. 'overflow' is handled by 'maxLines'.
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionControls: MaterialTextSelectionControls(), // Or Cupertino...
    );
  }
}
