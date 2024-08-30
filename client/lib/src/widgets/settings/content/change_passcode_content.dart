import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
class ChangePasscodeContent extends ConsumerStatefulWidget {
  const ChangePasscodeContent({super.key});

  @override
  ConsumerState<ChangePasscodeContent> createState() =>
      _ChangePasscodeMobileContentState();
}

class _ChangePasscodeMobileContentState
    extends ConsumerState<ChangePasscodeContent>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _buttonEnabled = false;
  bool _isLoading = false;

  late TextEditingController _passcodeController;
  late TextEditingController _confirmPasscodeController;
  final _passcodeFormKey = GlobalKey<FormState>();

  String? _passcodeError;

  final _confirmPasswordFocusNode = FocusNode();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();

  RequestUpdatePasscode request = RequestUpdatePasscode();
  UpdatePasscode updateRequestValidation = UpdatePasscode();

  @override
  void initState() {
    super.initState();

    _passcodeController = TextEditingController();
    _confirmPasscodeController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    unawaited(_errorController.close());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customAppTheme = ref.read(appThemeProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 30.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: Text(
            'login_reset_passcode_error.title'.t(),
            style: customAppTheme.textStyles.displaySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _passcodeFormKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 16),
                    child: Text(
                      'signup_step_6a.create_passcode'.t(),
                      style: customAppTheme.textStyles.smallestBody.copyWith(
                        color: customAppTheme.colorsPalette.secondary70,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: PinCodeTextField(
                      controller: _passcodeController,
                      obscureText: _obscureText,
                      autoFocus: true,
                      animationType: AnimationType.none,
                      cursorColor: customAppTheme.colorsPalette.positiveAction,
                      textStyle: customAppTheme.textStyles.h1,
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                        activeColor: customAppTheme.colorsPalette.secondary
                            .withOpacity(0.5),
                        disabledColor: customAppTheme.colorsPalette.secondary
                            .withOpacity(0.5),
                        inactiveColor: customAppTheme.colorsPalette.secondary
                            .withOpacity(0.5),
                        activeFillColor: customAppTheme.colorsPalette.secondary
                            .withOpacity(0.5),
                        selectedColor:
                            customAppTheme.colorsPalette.positiveAction,
                        inactiveFillColor: customAppTheme
                            .colorsPalette.secondary
                            .withOpacity(0.5),
                        selectedFillColor:
                            customAppTheme.colorsPalette.positiveAction,
                        errorBorderColor: customAppTheme
                            .colorsPalette.negativeAction
                            .withOpacity(0.5),
                        borderWidth: 0.5,
                      ),
                      appContext: context,
                      length: 6,
                      onChanged: (value) {
                        _confirmPasscodeController.text = '';
                        request = RequestUpdatePasscode();
                        updateRequestValidation = UpdatePasscode();
                        _enableButton(request);
                      },
                      onCompleted: (value) {
                        request = RequestUpdatePasscode();
                        updateRequestValidation = UpdatePasscode();

                        _enableButton(request);
                        _confirmPasscodeController.text = '';
                        _confirmPasswordFocusNode.requestFocus();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 16),
                    child: Text(
                      'signup_step_6a.confirm_passcode'.t(),
                      style: customAppTheme.textStyles.smallestBody.copyWith(
                        color: customAppTheme.colorsPalette.secondary70,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    child: PinCodeTextField(
                      controller: _confirmPasscodeController,
                      errorTextSpace: 8,
                      errorAnimationDuration: 300,
                      errorAnimationController: _errorController,
                      obscureText: _obscureText,
                      focusNode: _confirmPasswordFocusNode,
                      animationType: AnimationType.none,
                      cursorColor: customAppTheme.colorsPalette.positiveAction,
                      textStyle: customAppTheme.textStyles.h1,
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                        activeColor: customAppTheme.colorsPalette.secondary
                            .withOpacity(0.5),
                        disabledColor: customAppTheme.colorsPalette.secondary
                            .withOpacity(0.5),
                        inactiveColor: customAppTheme.colorsPalette.secondary
                            .withOpacity(0.5),
                        activeFillColor: customAppTheme.colorsPalette.secondary
                            .withOpacity(0.5),
                        selectedColor: customAppTheme.colorsPalette.secondary
                            .withOpacity(0.5),
                        inactiveFillColor: customAppTheme
                            .colorsPalette.secondary
                            .withOpacity(0.5),
                        selectedFillColor: customAppTheme
                            .colorsPalette.secondary
                            .withOpacity(0.5),
                        errorBorderColor: customAppTheme
                            .colorsPalette.negativeAction
                            .withOpacity(0.5),
                        borderWidth: 0.5,
                      ),
                      appContext: context,
                      length: 6,
                      onChanged: (value) {
                        request = RequestUpdatePasscode();
                        _enableButton(request);
                        setState(() {
                          _passcodeError = null;
                        });
                      },
                      onCompleted: _onPasscodeChangeComplete,
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: _passcodeError != null
                        ? Text(
                            _passcodeError!,
                            style: customAppTheme.textStyles.smallBody.copyWith(
                              color:
                                  customAppTheme.colorsPalette.negativeAction,
                            ),
                          )
                        : Container(),
                  ),
                  IconButton(
                    icon: Icon(
                      _obscureText
                          ? ThanosIcons.buttonsEyeOpen
                          : ThanosIcons.buttonsEyeClosed,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedButton(
          buttonEnabled: _buttonEnabled,
          text: Text('button.save_new_passcode'.t()),
          loading: _isLoading,
          onPressed: () async {
            await _requestCreatePasscode(request, customAppTheme).then(
              (result) {
                _handleCreatePasscodeRequest(result);
              },
            );
          },
        ),
      ],
    );
  }

  _enableButton(RequestUpdatePasscode passcode) {
    final isValid = isPasswordValid(passcode.newPasscode ?? '');
    if (_passcodeError == null && passcode.newPasscode != null && isValid) {
      setState(() {
        _buttonEnabled = true;
      });
    } else {
      setState(() {
        _buttonEnabled = false;
      });
    }
  }

  void _onPasscodeChangeComplete(String value) {
    if (!isPasswordValid(value)) {
      request = RequestUpdatePasscode();
      updateRequestValidation =
          updateRequestValidation.copyWith(newPasscode: value);

      _errorController.add(ErrorAnimationType.shake);
      setState(() {
        _passcodeError = 'passcode_too_weak'.t();
      });
    } else if (value == _passcodeController.text) {
      request = request.copyWith(newPasscode: value);
      updateRequestValidation =
          updateRequestValidation.copyWith(newPasscode: value);

      setState(() {
        _enableButton(request);
      });
    } else {
      request = RequestUpdatePasscode();
      updateRequestValidation =
          updateRequestValidation.copyWith(newPasscode: value);
      _errorController.add(ErrorAnimationType.shake);

      setState(() {
        _passcodeError = 'error.signup.step_6c.passcode'.t();
      });
    }
  }

  void _handleCreatePasscodeRequest(result) {
    final customAppTheme = ref.read(appThemeProvider);
    final response = result.toLowerCase();

    final isCurrentPasscode = response.contains('conflict exception');
    final isInvalid = response.contains('invalid') || response.contains('bad');
    final otpLimit = response.contains('forbidden');

    if (isCurrentPasscode) {
      ToastMessage.showToast(
        context,
        'current_passcode_in_use'.t(),
        customAppTheme,
        type: ToastMessageType.negative,
      );
    } else if (otpLimit) {
      ToastMessage.showToast(
        context,
        'Your have reached the OTP limit',
        customAppTheme,
        type: ToastMessageType.negative,
      );
    } else if (isInvalid) {
      ToastMessage.showToast(
        context,
        'Your new pincode is invalid',
        customAppTheme,
        type: ToastMessageType.negative,
      );
    } else {
      _requestOtpScreen();
    }
  }

  void _requestOtpScreen() {
    final customAppTheme = ref.watch(appThemeProvider);
    final clientInfo = ref.read(clientInfoProviderNotifier);
    context.router.push(
      OTPOverlayRoute(
        customAppTheme: customAppTheme,
        phone: clientInfo?.phone ?? Phone(callingCode: '', phoneNumber: ''),
        onClose: () {
          context.router.push(const UpdatePasscodeSuccessMobileRoute());
        },
        onCallToAction: (otp) async {
          updateRequestValidation =
              updateRequestValidation.copyWith(otpCode: otp);

          return _updatePasscode(updateRequestValidation, customAppTheme);
        },
        onResendOtp: (otp) async {
          await _requestCreatePasscode(request, customAppTheme).then((_) {
            ToastMessage.showToast(
              context,
              'OTP has been re-sent',
              customAppTheme,
            );
          });
        },
      ),
    );
  }

  Future<String> _updatePasscode(
    UpdatePasscode newPassword,
    CustomAppTheme customAppTheme,
  ) async {
    try {
      final result = await ref
          .read(updatePasswordNotifierProvider.notifier)
          .updatePasscode(newPassword);

      return result;
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ToastMessage.showToast(
        context,
        '$error',
        customAppTheme,
        type: ToastMessageType.negative,
      );
      return error.toString();
    }
  }

  Future<String> _requestCreatePasscode(
    RequestUpdatePasscode request,
    CustomAppTheme customAppTheme,
  ) async {
    if (_passcodeFormKey.currentState!.validate()) {
      updateRequestValidation =
          UpdatePasscode(newPasscode: request.newPasscode);
      try {
        final response = await ref
            .read(requestUpdatePasswordNotifierProvider.notifier)
            .requestUpdatePasscode(request);

        return response;
      } catch (error) {
        _isLoading = false;

        ToastMessage.showToast(
          context,
          '$error',
          customAppTheme,
          type: ToastMessageType.negative,
        );

        return error.toString();
      }
    }

    return 'invalid';
  }
}

class RequestUpdatePasscode {
}
