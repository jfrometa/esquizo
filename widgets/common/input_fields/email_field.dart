import 'package:starter_architecture_flutter_firebase/helpers/email_verification.dart';
import 'package:starter_architecture_flutter_firebase/screens/signup/sign_up_screen.dart';
import 'package:starter_architecture_flutter_firebase/utils/notifiers/index.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/input_field.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailInputField extends ConsumerWidget {
  const EmailInputField({
    super.key,
    required TextEditingController emailController,
    required Function(String? email) onTextFieldChanged,
    required StateNotifierProvider<BooleanStateNotifier, bool> whachIsHidden,
  })  : _emailController = emailController,
        _onTextFieldChanged = onTextFieldChanged,
        _watchIsHidden = whachIsHidden;

  final TextEditingController _emailController;
  final Function(String? email) _onTextFieldChanged;
  final StateNotifierProvider<BooleanStateNotifier, bool> _watchIsHidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.read(startRegistrationRequestProvider);
    final validateRegistrationRequest = ref.read(validateRegistrationRequest);

    return ref.watch(_watchIsHidden)
        ? InputField(
            autocorrect: false,
            label: 'signup.step_1c.email'.t(),
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            onChanged: (email) {
              validateRegistrationRequest.email = email;
              registration.email = email;
              _onTextFieldChanged(email);
            },
            validator: (value) {
              if (value == null) {
                return 'error';
              }
              if (!isEmailValid(value)) {
                return 'invalid email';
              }
              return null;
            },
          )
        : Container();
  }
}
