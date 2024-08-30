
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/button.dart';


class GenericErrorScreen extends ConsumerWidget {
  const GenericErrorScreen({
    super.key,
    this.message,
    required this.tryAgain,
    required this.leaveFlow,
  });
  final String? message;
  final Function() tryAgain;
  final Function() leaveFlow;

  static const String path = 'error';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 92.0, bottom: 32.0),
              child: SvgPicture.asset('assets/big_icon_error.svg'),
            ),
            Text(
              'An error has ocurred',
              style: customAppTheme.textStyles.displaySmall,
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: message != null
                    ? Text(
                        message!,
                        style: customAppTheme.textStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      )
                    : Container(),
              ),
            ),
            Button.primary(
              onPressed: () {
                Navigator.pop(context);
                tryAgain();
              },
              rounded: true,
              text: const Text('Let me try again'),
              wrap: true,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 40.0),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  leaveFlow();
                },
                child: Text(
                  'Leave flow',
                  style: customAppTheme.textStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
