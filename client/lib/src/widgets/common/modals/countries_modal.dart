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

class CountriesModal extends ConsumerWidget {
  const CountriesModal({
    super.key,
    required TextEditingController countryOfResidenceController,
    required Function(SelectorModalItem<Country?> countrySelect)
        onCountrySelected,
    required String? Function(String? string) onValidationTriggered,
    required Provider<CustomAppTheme> appThemeProvider,
    required List<Country> countryList,
    required StateNotifierProvider<CountryStateNotifier, Country?>
        countryStateNotifier,
  })  : _countryOfResidenceController = countryOfResidenceController,
        _onCountrySelected = onCountrySelected,
        _onValidationTriggered = onValidationTriggered,
        _appThemeProvider = appThemeProvider,
        _countryList = countryList,
        _countryStateNotifier = countryStateNotifier;
  final TextEditingController _countryOfResidenceController;
  final Function(SelectorModalItem<Country?> countrySelect) _onCountrySelected;
  final String? Function(String? string) _onValidationTriggered;
  final Provider<CustomAppTheme> _appThemeProvider;
  final List<Country> _countryList;
  final StateNotifierProvider<CountryStateNotifier, Country?>
      _countryStateNotifier;

  void action(WidgetRef ref, SelectorModalItem<Country> country) {
    final publishSelectedCountry = ref.read(_countryStateNotifier.notifier);
    publishSelectedCountry.update(country.value);
    _onCountrySelected(country);
    final registration = ref.read(startRegistrationRequestProvider);
    registration.countryOfResidence = country.value.countryCode;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCountry = ref.watch(_countryStateNotifier);

    return InputField<Country>.pageItemSelector(
      label: 'signup.step_1a.personal_tab.country'.t(),
      controller: _countryOfResidenceController,
      context: context,
      validator: _onValidationTriggered,
      pageRouteInfo: SignupSelectorResidenceRoute(
        controller: _countryOfResidenceController,
        items: _countryList
            .map<SelectorModalItem<Country>>(
              (selectedCountry) => SelectorModalItem(
                leading: Text(
                  flagUnicodeToString(selectedCountry.flagUnicode),
                  style: const TextStyle(fontSize: 24),
                ),
                value: selectedCountry,
                label:
                    '${flagUnicodeToString(selectedCountry.flagUnicode)}  ${selectedCountry.name}',
                title: selectedCountry.name,
              ),
            )
            .toList(),
        onSelected: (country) => action(ref, country),
        otherOption: false,
        selectedValue: selectedCountry,
      ),
    );
  }
}
