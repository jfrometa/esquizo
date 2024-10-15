import 'package:starter_architecture_flutter_firebase/helpers/unicode_emojis.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/screens/signup/sign_up_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/utils/notifiers/index.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/input_field.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/selector_modal.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/entities/countries/country.dart';
import 'package:natasha/notifiers/countries_provider_notifier.dart';

class UserInputFields extends ConsumerWidget {
  const UserInputFields({
    super.key,
    required TextEditingController callingCodeController,
    required TextEditingController phoneController,
    required Function(String? callingCode) onCallingCodeTextFieldChanged,
    required Function(String? phone) onPhoneTextFieldChanged,
    required Provider<CustomAppTheme> appThemeProvider,
    required StateNotifierProvider<BooleanStateNotifier, bool> watchIsHidden,
    required StateNotifierProvider<StringStateNotifier, String>
        countryCodeValue,
  })  : _callingCodeController = callingCodeController,
        _phoneController = phoneController,
        _onCallingCodeTextFieldChanged = onCallingCodeTextFieldChanged,
        _onPhoneTextFieldChanged = onPhoneTextFieldChanged,
        _appThemeProvider = appThemeProvider,
        _watchIsHidden = watchIsHidden,
        _countryCodeValue = countryCodeValue;
  final TextEditingController _callingCodeController;
  final TextEditingController _phoneController;
  final Function(String? callingCode) _onCallingCodeTextFieldChanged;
  final Function(String? phone) _onPhoneTextFieldChanged;
  final Provider<CustomAppTheme> _appThemeProvider;
  final StateNotifierProvider<BooleanStateNotifier, bool> _watchIsHidden;
  final StateNotifierProvider<StringStateNotifier, String> _countryCodeValue;

  List<SelectorModalItem<String>> _callingCodeList(List<Country> countries) {
    final items = countries
        .map<SelectorModalItem<String>>(
          (country) => SelectorModalItem(
            leading: Text(
              flagUnicodeToString(country.flagUnicode),
              style: const TextStyle(fontSize: 24),
            ),
            value: '${country.name} (${country.callingCode})',
            label: country.callingCode,
            title: '${country.name} (${country.callingCode})',
          ),
        )
        .toList();
    return items;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data =
        ref.watch(countryListNotifierProvider).maybeWhen<List<Country>>(
              orElse: () => [],
              data: (data) => data,
            );

    final isAvailable = ref.watch(_watchIsHidden);
    final registration = ref.read(startRegistrationRequestProvider);
    final validateRegistrationRequest = ref.read(validateRegistrationRequest);
    final codeValue = ref.watch(_countryCodeValue);
    return isAvailable
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InputField<String>.pageItemSelector(
                    validator: (text) {
                      return null;
                    },
                    context: context,
                    controller: _callingCodeController,
                    label: 'signup.step_1c.country_code'.t(),
                    pageRouteInfo: SignupSelectorCountryCodeRoute(
                      controller: _callingCodeController,
                      items: _callingCodeList(data),
                      otherOption: false,
                      selectedValue: codeValue,
                      onSelected: (selectedCallingCode) {
                        var formattedCallingCode =
                            selectedCallingCode.value.substring(
                          selectedCallingCode.value.indexOf('+'),
                          selectedCallingCode.value.length - 1,
                        );

                        _onCallingCodeTextFieldChanged(
                          selectedCallingCode.value,
                        );
                        validateRegistrationRequest.callingCode =
                            formattedCallingCode;

                        ref
                            .read(_countryCodeValue.notifier)
                            .update(selectedCallingCode.value);

                        registration.callingCode = formattedCallingCode;
                      },
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: InputField(
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  label: 'Phone',
                  validator: (value) {
                    if (value != null && value.length > 7) {
                      return null;
                    }
                    return 'error';
                  },
                  onChanged: (phoneNumber) {
                    validateRegistrationRequest.phoneNumber = phoneNumber;
                    registration.phoneNumber = phoneNumber!;
                    _onPhoneTextFieldChanged(phoneNumber);
                  },
                ),
              ),
            ],
          )
        : Container();
  }
}
