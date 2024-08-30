import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/utils/biometric_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

class BiometricOverlayContent extends ConsumerStatefulWidget {
  const BiometricOverlayContent({
    super.key,
    required this.onAuthenticate,
    required this.onCancelOrFail,
  });
  final Function onAuthenticate;
  final Function onCancelOrFail;

  @override
  ConsumerState createState() => _BiometricOverlayContentState();
}

class _BiometricOverlayContentState
    extends ConsumerState<BiometricOverlayContent> {
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();

    unawaited(_authenticateWithBiometrics());
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = await BiometricsManager().authenticateWithBiometrics();

    if (authenticated) {
      widget.onAuthenticate();
    } else {
      widget.onCancelOrFail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Text(
              //   'login.step_2.fingerprint_title'.t(),
              //   style: customAppTheme.textStyles.displaySmall.copyWith(
              //     color: customAppTheme.colorsPalette.white,
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 10.0, bottom: 48.0),
              //   child: Text(
              //     'login.step_2.fingerprint_text'.t(),
              //     style: customAppTheme.textStyles.body.copyWith(
              //       color: customAppTheme.colorsPalette.white,
              //     ),
              //   ),
              // ),
              TextButton(
                onPressed: () async {
                  await AutoRouter.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: customAppTheme.textStyles.button.copyWith(
                    color: customAppTheme.colorsPalette.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              )
              //   child: InkWell(
              //     borderRadius: BorderRadius.circular(40),
              //     onLongPress: () async {
              //       await _authenticateWithBiometrics();
              //     },
              //     child: SizedBox(
              //       height: 72,
              //       width: 72,
              //       child: SvgPicture.asset(
              //         'assets/finger_print_icon.svg',
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
