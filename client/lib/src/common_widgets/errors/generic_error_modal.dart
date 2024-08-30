import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/button.dart';

class GenericErrorModal extends ModalRoute {
  GenericErrorModal({
    required this.customAppTheme,
    this.message,
    required this.tryAgain,
    required this.leaveFlow,
  });
  final CustomAppTheme customAppTheme;
  final String? message;
  final Function() tryAgain;
  final Function() leaveFlow;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'Error Modal';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
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

  @override
  bool get opaque => true;

  @override
  Duration get transitionDuration => const Duration();

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => customAppTheme.colorsPalette.white;
}
