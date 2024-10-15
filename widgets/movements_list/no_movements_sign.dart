import 'package:starter_architecture_flutter_firebase/helpers/responsive_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmptyMovementsSign extends ConsumerWidget {
  const EmptyMovementsSign({super.key, required this.onTap});
  final Function() onTap;

  Widget _content(
    BuildContext context,
    CustomAppTheme customAppTheme,
  ) {
    final fullText = 'movements.no_movements.top_up'.t();
    final List<String> initialTextArr = fullText.split('<u>').toList();
    final List<String> centerAndLastTextArr =
        initialTextArr.last.split('</u>').toList();

    return Container(
      decoration: BoxDecoration(
        color: customAppTheme.colorsPalette.primary7,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            'movements.no_movements.text'.t(),
            style: customAppTheme.textStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: RichText(
              text: TextSpan(
                style: customAppTheme.textStyles.bodyLarge,
                children: <TextSpan>[
                  TextSpan(text: initialTextArr.first),
                  TextSpan(
                    recognizer: TapGestureRecognizer()..onTap = () => onTap(),
                    text: centerAndLastTextArr.first,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(text: centerAndLastTextArr.last),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.read(appThemeProvider);

    return ResponsiveWidget(
      mobileScreen: _content(context, customAppTheme),
      desktopScreen: _content(context, customAppTheme),
    );
  }
}
