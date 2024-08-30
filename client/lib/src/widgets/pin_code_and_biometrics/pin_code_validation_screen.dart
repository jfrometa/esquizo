import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/utils/biometric_manager.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCodeValidationScreen extends ConsumerStatefulWidget {
  const PinCodeValidationScreen({
    super.key,
    required this.onValidationCompleted,
  });
  static const String path = 'login-pin-validation';
  final bool Function(bool) onValidationCompleted;

  @override
  ConsumerState<PinCodeValidationScreen> createState() =>
      _PincodeValidationScreen();
}

class _PincodeValidationScreen extends ConsumerState<PinCodeValidationScreen> {
  late TextEditingController _pinController;
  final bool _isLoading = false;

  @override
  void initState() {
    _pinController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CustomAppTheme theme = ref.read(appThemeProvider);
    const int pinLenght = 6;

    final Padding title = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Text(
        'login_passcode.title'.t(),
        style: theme.textStyles.displaySmall,
      ),
    );
    final Header appBar = Header(
      context: context,
      title: 'Login to Safebrok',
      leading: IconButton(
        icon: const Icon(ThanosIcons.buttonsBack),
        onPressed: () async {
          await context.router.pop();
        },
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                const SizedBox(
                  height: 32,
                ),
                title,
                const SizedBox(
                  height: 48,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: PinCodeTextField(
                    pinTheme: PinTheme(
                      activeColor: theme.colorsPalette.primary.withOpacity(0.5),
                      disabledColor:
                          theme.colorsPalette.primary.withOpacity(0.5),
                      inactiveColor:
                          theme.colorsPalette.primary.withOpacity(0.5),
                      activeFillColor:
                          theme.colorsPalette.primary.withOpacity(0.5),
                      selectedColor: theme.colorsPalette.positiveAction,
                      inactiveFillColor:
                          theme.colorsPalette.primary.withOpacity(0.5),
                      selectedFillColor: theme.colorsPalette.positiveAction,
                      errorBorderColor:
                          theme.colorsPalette.negativeAction.withOpacity(0.5),
                      borderWidth: 0.5,
                    ),
                    controller: _pinController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]+')),
                    ],
                    onChanged: double.parse,
                    obscureText: true,
                    appContext: context,
                    length: pinLenght,
                    onCompleted: _requestPinCodeValidation,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SizedBox(
        height: 96,
        child: TextButton(
          child: Text(
            'login_passcode.forgot_passcode'.t(),
            style: theme.textStyles.button,
          ),
          onPressed: () async {
            await AutoRouter.of(context).pop();
          },
        ),
      ),
    );
  }

  void _requestPinCodeValidation(String pincode) {
    final storedCode = BiometricsManager().storedPinCode;
    final isValidPincode = storedCode == pincode;

    widget.onValidationCompleted(isValidPincode);
    unawaited(context.router.pop());
  }
}

class PinCodeValidationOverlay extends ModalRoute {
  PinCodeValidationOverlay({
    required this.customAppTheme,
    required this.onValidationCompleted,
  });
  final CustomAppTheme customAppTheme;
  final bool Function(bool) onValidationCompleted;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => 'Pin validaiton';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return PinCodeValidationScreen(
      onValidationCompleted: onValidationCompleted,
    );
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor =>
      customAppTheme.colorsPalette.primary.withOpacity(0.95);
}
