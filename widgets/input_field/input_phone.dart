import 'package:starter_architecture_flutter_firebase/helpers/unicode_emojis.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/input_field.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/selector_modal.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/entities/countries/country.dart';
import 'package:natasha/notifiers/index.dart';

class PhoneInputField extends ConsumerWidget {
  const PhoneInputField({
    super.key,
    required countryCodeTextEditingController,
    required phoneTextEditingController,
    required phoneTextController,
    required readOnly,
    required enabled,
    required this.countryList,
    required this.onValueChanged,
  })  : _countryCodeTextEditingController = countryCodeTextEditingController,
        _phoneTextEditingController = phoneTextEditingController,
        _phoneTextController = phoneTextController,
        _isReadOnlyPhone = readOnly,
        _isEditingPhone = enabled;

  final TextEditingController _countryCodeTextEditingController;
  final TextEditingController _phoneTextEditingController;
  final TextEditingController _phoneTextController;

  final Function(String value) onValueChanged;
  final List<Country> countryList;
  final bool _isReadOnlyPhone;
  final bool _isEditingPhone;

  @override
  Widget build(BuildContext context, ref) {
    final phone = ref.read(clientInfoProviderNotifier)?.phone;

    return _isEditingPhone
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Semantics(
                    textField: true,
                    label: 'login.step_1a.country'.t(),
                    child: InputField<String>.pageItemSelector(
                      label: 'login.step_1a.country'.t(),
                      controller: _countryCodeTextEditingController,
                      context: context,
                      pageRouteInfo: LoginCountryCodeModalRoute(
                        controller: _countryCodeTextEditingController,
                        selectedValue: phone?.callingCode,
                        onSelected: (item) {
                          _countryCodeTextEditingController.text = item.value;
                          final editedNumber =
                              '${_countryCodeTextEditingController.text} ${_phoneTextEditingController.text}';
                          _phoneTextController.text = editedNumber;

                          onValueChanged(editedNumber);
                        },
                        items: countryList
                            .map<SelectorModalItem<String>>(
                              (country) => SelectorModalItem(
                                title:
                                    '${flagUnicodeToString(country.flagUnicode)}  ${country.name} (${country.callingCode})',
                                value: country.callingCode,
                                label: country.callingCode,
                              ),
                            )
                            .toList(),
                        otherOption: false,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Semantics(
                  textField: true,
                  label: 'login.step_1a.phone'.t(),
                  child: InputField(
                    controller: _phoneTextEditingController,
                    keyboardType: TextInputType.number,
                    onChanged: (editedNumber) {
                      final phoneNumber =
                          '${_countryCodeTextEditingController.text} $editedNumber';
                      _phoneTextController.text = phoneNumber;

                      onValueChanged(phoneNumber);
                    },
                    label: 'login.step_1a.phone'.t(),
                  ),
                ),
              ),
            ],
          )
        : InputField(
            readOnly: _isReadOnlyPhone,
            enabled: _isEditingPhone,
            controller: _phoneTextController,
            label:
                'main_navigation.settings.secondary_navigation.settings.details.personal.my_pesonal_details.contacts.phone_number'
                    .t(),
          );
  }
}
