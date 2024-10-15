import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/helpers/responsive_widget.dart';
import 'package:starter_architecture_flutter_firebase/helpers/unicode_emojis.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/utils/biometric_manager.dart';
import 'package:starter_architecture_flutter_firebase/utils/secure_storange_manager.dart';
import 'package:starter_architecture_flutter_firebase/utils/shared_preference_manager.dart';
import 'package:starter_architecture_flutter_firebase/widgets/animated_button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/input_field.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/input_phone.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/selector_modal.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/core/screen_representable/screen_states.dart';
import 'package:natasha/entities/countries/country.dart';
import 'package:natasha/entities/phone/phone.dart';
import 'package:natasha/entities/settings/request_update_email.dart';
import 'package:natasha/entities/settings/request_update_phone.dart';
import 'package:natasha/entities/settings/update_address.dart';
import 'package:natasha/notifiers/index.dart';
import 'package:natasha/notifiers/update_user_details_provider_notifier.dart';

// @RoutePage()
class PersonalDetailsMobileScreen extends ConsumerStatefulWidget {
  const PersonalDetailsMobileScreen({super.key});

  @override
  ConsumerState<PersonalDetailsMobileScreen> createState() =>
      _PersonalDetailsMobileScreenState();
}

class _PersonalDetailsMobileScreenState
    extends ConsumerState<PersonalDetailsMobileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _phoneLine1Controller = TextEditingController();
  final TextEditingController _emailCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryCodeTextEditingController =
      TextEditingController();
  final TextEditingController _phoneTextEditingController =
      TextEditingController();

  bool _isEditingPhone = false;
  bool _isEditingEmail = false;
  bool _isEditingAddress = false;

  bool _isReadOnlyPhone = false;
  bool _isReadOnlyEmail = false;
  bool _isReadOnlyAddress = false;

  bool _buttonEnabled = false;
  bool get _isUserEditing =>
      _isEditingPhone || _isEditingEmail || _isEditingAddress;

  String? _phoneToUpdate = '';
  String? _emailToUpdate = '';

  UpdateAddress _addressToUpdate = UpdateAddress();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _personalDetail();
        unawaited(
          ref
              .read(countriesOfResidenceNotifierProvider.notifier)
              .getCountryList(),
        );

        unawaited(
          ref.read(countryListNotifierProvider.notifier).getCountryList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryCodeTextEditingController.dispose();
    _phoneTextEditingController.dispose();
    _addressLine1Controller.dispose();
    _emailCodeController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _nationalityController.dispose();
    _phoneLine1Controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme theme = ref.watch(appThemeProvider);

    final ScreenState<List<Country>> countryList =
        ref.watch(countryListNotifierProvider);

    final List<Country> countries = countryList.maybeWhen(
      data: (list) => list.toList(),
      orElse: () => [],
    );

    final ScreenState<List<Country>> countriesOfResidence =
        ref.watch(countriesOfResidenceNotifierProvider);

    final List<Country> countriesOfResidenceList =
        countriesOfResidence.maybeWhen(
      data: (list) => list.toList(),
      orElse: () => [],
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: theme.colorsPalette.white,
        appBar: ResponsiveWidget.isDesktopScreen(context)
            ? null
            : Header(
                context: context,
                title:
                    'main_navigation.settings.secondary_navigation.settings.details.personal.my_pesonal_details.my_personal_details'
                        .t(),
                leading: IconButton(
                  icon: const Icon(ThanosIcons.buttonsBack),
                  onPressed: () async => context.router.pop(),
                ),
              ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16.0,
              right: 16.0,
              bottom: 54.0,
            ),
            child: Column(
              children: [
                _sectionTitled(
                  'main_navigation.settings.secondary_navigation.settings.details.personal.my_pesonal_details.name.tittle',
                  !_isUserEditing,
                ),
                InputField(
                  readOnly: _isUserEditing,
                  enabled: false,
                  controller: _firstNameController,
                  label: 'signup.step_3a.first_name'.t(),
                ),
                InputField(
                  readOnly: _isUserEditing,
                  enabled: false,
                  controller: _lastNameController,
                  label: 'signup.step_3a.last_name'.t(),
                ),
                InputField(
                  readOnly: _isUserEditing,
                  enabled: false,
                  controller: _fullNameController,
                  label:
                      'main_navigation.settings.secondary_navigation.settings.details.personal.my_pesonal_details.name.full_legal_name'
                          .t(),
                ),
                _sectionTitled(
                  'main_navigation.settings.secondary_navigation.settings.details.personal.my_pesonal_details.contacts',
                  _isEditingPhone || _isEditingEmail,
                ),
                Stack(
                  children: [
                    PhoneInputField(
                      readOnly: _isReadOnlyPhone,
                      enabled: _isEditingPhone,
                      countryCodeTextEditingController:
                          _countryCodeTextEditingController,
                      phoneTextEditingController: _phoneTextEditingController,
                      phoneTextController: _phoneLine1Controller,
                      countryList: countries.toList(),
                      onValueChanged: (value) {
                        _phoneToUpdate = value;
                      },
                    ),
                    _editButtonForField(
                      theme,
                      _isEditingPhone,
                      () => _updatePhoneEditingState(),
                    )
                  ],
                ),
                Stack(
                  children: [
                    InputField(
                      readOnly: _isReadOnlyEmail,
                      enabled: _isEditingEmail,
                      controller: _emailCodeController,
                      label:
                          'main_navigation.settings.secondary_navigation.settings.details.personal.my_pesonal_details.contacts.email'
                              .t(),
                      onChanged: (newEmail) {
                        _emailToUpdate = newEmail;
                      },
                    ),
                    _editButtonForField(
                      theme,
                      _isEditingEmail,
                      () => _updateEmailEditingState(),
                    )
                  ],
                ),
                Stack(
                  children: [
                    _sectionTitled(
                      'main_navigation.settings.secondary_navigation.settings.details.personal.my_pesonal_details.contacts.address.local_address',
                      _isEditingAddress,
                    ),
                    _editButtonForField(
                      theme,
                      _isEditingAddress,
                      () => _updateAddressEditingState(),
                    )
                  ],
                ),
                InputField<String>.modalItemSelector(
                  readOnly: _isReadOnlyAddress,
                  enabled: _isEditingAddress,
                  controller: _nationalityController,
                  context: context,
                  label: 'login.step_1a.country'.t(),
                  onSelected: (value) {
                    _addressToUpdate =
                        _addressToUpdate.copyWith(nationality: value.value);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Select your nationality';
                    }
                    return null;
                  },
                  customAppTheme: theme,
                  items: countriesOfResidenceList
                      .map<SelectorModalItem<String>>(
                        (country) => SelectorModalItem<String>(
                          title: country.name,
                          leading: Text(
                            flagUnicodeToString(country.flagUnicode),
                            style: const TextStyle(fontSize: 24),
                          ),
                          value: country.countryCode,
                          label:
                              '${flagUnicodeToString(country.flagUnicode)} ${country.name}',
                        ),
                      )
                      .toList(),
                  title: 'signup.step_1a.personal_tab.country'.t(),
                ),
                InputField(
                  readOnly: _isReadOnlyAddress,
                  enabled: _isEditingAddress,
                  controller: _cityController,
                  label: 'settings.my_personal_details.address.city'.t(),
                  onChanged: (input) {
                    _addressToUpdate = _addressToUpdate.copyWith(city: input);
                  },
                  scrollPadding: const EdgeInsets.only(bottom: 80),
                ),
                InputField(
                  readOnly: _isReadOnlyAddress,
                  enabled: _isEditingAddress,
                  controller: _postalCodeController,
                  label: 'kyc.step_4a.postcode'.t(),
                  onChanged: (input) {
                    _addressToUpdate =
                        _addressToUpdate.copyWith(postalCode: input);
                  },
                  scrollPadding: const EdgeInsets.only(bottom: 80),
                ),
                InputField(
                  readOnly: _isReadOnlyAddress,
                  enabled: _isEditingAddress,
                  controller: _addressLine1Controller,
                  label:
                      'main_navigation.settings.secondary_navigation.settings.details.personal.my_pesonal_details.contacts.address.local_address'
                          .t(),
                  onChanged: (input) {
                    _addressToUpdate =
                        _addressToUpdate.copyWith(addressLine1: input);
                  },
                  scrollPadding: const EdgeInsets.only(bottom: 80),
                ),
              ],
            ),
          ),
        ),
        bottomSheet: AnimatedButton(
          buttonEnabled: _buttonEnabled,
          text: Text('button.save_changes'.t()),
          onPressed: () async {
            await BiometricsManager().authenticate(
              () async {
                await _submitChangesToMyDetails();
              },
              () {
                _openSaveButton();

                ToastMessage.showToast(
                  context,
                  'Error with biometrics authentication',
                  ref.read(appThemeProvider),
                  type: ToastMessageType.negative,
                );
              },
              context,
            );
          },
        ),
      ),
    );
  }

  void _updatePhoneEditingState() {
    setState(() {
      if (!_isEditingPhone) {
        _isEditingEmail = false;
        _isEditingAddress = false;

        _isReadOnlyEmail = false;
        _isReadOnlyAddress = false;
      }

      _isReadOnlyPhone = false;
      _isEditingPhone = !_isEditingPhone;
      _isReadOnlyEmail = !_isReadOnlyEmail;
      _isReadOnlyAddress = !_isReadOnlyAddress;

      _openSaveButton();
    });
  }

  void _updateEmailEditingState() {
    setState(() {
      if (!_isEditingEmail) {
        _isEditingPhone = false;
        _isEditingAddress = false;

        _isReadOnlyPhone = false;
        _isReadOnlyAddress = false;
      }

      _isReadOnlyEmail = false;
      _isEditingEmail = !_isEditingEmail;
      _isReadOnlyPhone = !_isReadOnlyPhone;
      _isReadOnlyAddress = !_isReadOnlyAddress;

      _openSaveButton();
    });
  }

  void _updateAddressEditingState() {
    setState(() {
      if (!_isEditingAddress) {
        _isEditingEmail = false;
        _isEditingPhone = false;

        _isReadOnlyPhone = false;
        _isReadOnlyEmail = false;
      }

      _isReadOnlyAddress = false;
      _isEditingAddress = !_isEditingAddress;
      _isReadOnlyPhone = !_isReadOnlyPhone;
      _isReadOnlyEmail = !_isReadOnlyEmail;

      _openSaveButton();
    });
  }

  Phone? _splitPhoneNumber(String phoneNumber) {
    List<String> splitNumbers = phoneNumber.split(' ');
    if (splitNumbers.length != 2) {
      return null;
    }
    String callingCode = splitNumbers[0];
    String number = splitNumbers[1];

    return Phone(callingCode: callingCode, phoneNumber: number);
  }

  Future<void> _submitChangesToMyDetails() async {
    if (_isEditingPhone) {
      final phoneToUpdate = _splitPhoneNumber(_phoneToUpdate ?? '');

      final requestPhoneUpdate = RequestUpdatePhone(
        newPhone: phoneToUpdate,
      );

      await _validatePhoneFields(requestPhoneUpdate);
    }

    if (_isEditingEmail) {
      final requestEmailUpdate = RequestUpdateEmail(
        newEmail: _emailToUpdate,
      );
      await _validateEmailFields(requestEmailUpdate);
    }

    if (_isEditingAddress) {
      await _validateAddressFields(_addressToUpdate);
    }
  }

  Positioned _editButtonForField(
    CustomAppTheme theme,
    bool isEditing,
    Function onButtonPressed,
  ) {
    return Positioned(
      top: 8,
      right: isEditing ? -8 : -16,
      child: TextButton(
        onPressed: () {
          if (isEditing) {
            _personalDetail();
          }

          onButtonPressed();
        },
        child: Text(
          isEditing ? 'Cancel' : 'Edit',
          style: theme.textStyles.button.copyWith(
            decoration: TextDecoration.underline,
            color: theme.colorsPalette.black,
          ),
        ),
      ),
    );
  }

  void _personalDetail() {
    final userDetails = ref.read(clientInfoProviderNotifier)?.details;
    final email = ref.read(clientInfoProviderNotifier)?.email ?? '';
    final phone = ref.read(clientInfoProviderNotifier)?.phone;
    final firstName = userDetails?.firstName ?? '';
    final lastName = userDetails?.lastName ?? '';

    String flag =
        (userDetails?.nationality ?? '').toUpperCase().replaceAllMapped(
              RegExp(r'[A-Z]'),
              (match) =>
                  String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
            );

    final firstName0 = userDetails?.firstName ?? '';
    _firstNameController.text = firstName0;
    _firstNameController.selection =
        TextSelection.fromPosition(TextPosition(offset: firstName0.length));

    final lastName0 = userDetails?.lastName ?? '';
    _lastNameController.text = lastName0;
    _lastNameController.selection =
        TextSelection.fromPosition(TextPosition(offset: lastName0.length));

    final fullName = userDetails?.fullLegalName ?? '$firstName $lastName';
    _fullNameController.text = fullName;
    _fullNameController.selection =
        TextSelection.fromPosition(TextPosition(offset: fullName.length));

    final address = userDetails?.addressLine1 ?? '';
    _addressLine1Controller.text = address;
    _addressLine1Controller.selection =
        TextSelection.fromPosition(TextPosition(offset: address.length));

    _emailCodeController.text = email;
    _emailCodeController.selection =
        TextSelection.fromPosition(TextPosition(offset: email.length));

    final phone0 = '${phone?.callingCode ?? ''} ${phone?.phoneNumber ?? ''} ';
    _phoneToUpdate = phone0;
    _phoneLine1Controller.text = phone0;
    _phoneLine1Controller.selection = TextSelection.fromPosition(
      TextPosition(offset: phone0.length),
    );

    final countryCode = phone?.callingCode ?? '';
    _countryCodeTextEditingController.text = countryCode;
    _countryCodeTextEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: countryCode.length),
    );

    final phoneNumber = phone?.phoneNumber ?? '';
    _phoneTextEditingController.text = phoneNumber;
    _phoneTextEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneNumber.length),
    );

    final city = userDetails?.city ?? '';
    _cityController.text = city;
    _cityController.selection = TextSelection.fromPosition(
      TextPosition(offset: city.length),
    );

    final postalCode = userDetails?.postalCode ?? '';
    _postalCodeController.text = postalCode;
    _postalCodeController.selection = TextSelection.fromPosition(
      TextPosition(offset: postalCode.length),
    );

    final nationality = '$flag ${userDetails?.nationality ?? ''}';
    _nationalityController.text = nationality;
    _nationalityController.selection = TextSelection.fromPosition(
      TextPosition(offset: nationality.length),
    );
  }

  void _openSaveButton() {
    if (_isUserEditing) {
      setState(() {
        _buttonEnabled = true;
      });
    } else {
      setState(() {
        _buttonEnabled = false;
      });
    }
  }

  void _handleChange(String result) {
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
      // _requestOtpScreen();
    }
  }

  void _toggleSaveButton() {
    setState(() {
      _buttonEnabled = !_buttonEnabled;
    });
  }

  Future<void> _validateAddressFields(UpdateAddress newAddress) async {
    final userDetails = ref.read(clientInfoProviderNotifier)?.details;
    final currentNationality = userDetails?.nationality ?? '';
    final currentCity = userDetails?.city ?? '';
    final currentAddress = userDetails?.addressLine1 ?? '';
    final currentPostalCode = userDetails?.postalCode ?? '';

    final customAppTheme = ref.watch(appThemeProvider);

    final isNationalityAvailable = newAddress.nationality != null &&
        (newAddress.nationality?.isNotEmpty ?? false);
    final isAddressAvailable = newAddress.addressLine1 != null &&
        (newAddress.addressLine1?.isNotEmpty ?? false);
    final isPostalCodeAvailable = newAddress.postalCode != null &&
        (newAddress.postalCode?.isNotEmpty ?? false);
    final isCityAvailable =
        newAddress.city != null && (newAddress.city?.isNotEmpty ?? false);

    final nationality = newAddress.nationality ?? '';
    final addressLine1 = newAddress.addressLine1 ?? '';
    final postalCode = newAddress.postalCode ?? '';
    final city = newAddress.city ?? '';

    final addressDidChange =
        isNationalityAvailable && nationality != currentNationality ||
            isAddressAvailable && addressLine1 != currentAddress ||
            isPostalCodeAvailable && postalCode != currentPostalCode ||
            isCityAvailable && city != currentCity;

    if (addressDidChange) {
      await _updateAddress(newAddress, customAppTheme);
      _toggleSaveButton();

      _updateAddressEditingState();
    } else {
      ToastMessage.showToast(
        context,
        'Address fields have not been changed',
        ref.read(appThemeProvider),
        type: ToastMessageType.negative,
      );
    }
  }

  Future<void> _validatePhoneFields(RequestUpdatePhone newPhone) async {
    final phone = ref.read(clientInfoProviderNotifier)?.phone;

    final isPhoneAvailable = newPhone.newPhone != null &&
        newPhone.newPhone?.phoneNumber != null &&
        (newPhone.newPhone?.callingCode.isNotEmpty ?? false) &&
        (newPhone.newPhone?.phoneNumber.isNotEmpty ?? false);

    final newPhoneNumber = newPhone.newPhone?.phoneNumber ?? '';
    final newCountryCode = newPhone.newPhone?.callingCode ?? '';

    final phoneNumber = phone?.phoneNumber ?? '';
    final countryCode = phone?.callingCode ?? '';

    if (isPhoneAvailable && (newPhoneNumber != phoneNumber) ||
        (newCountryCode != countryCode)) {
      try {
        await ref
            .read(requestUpdatePhoneNotifierProvider.notifier)
            .requestUpdatePhone(newPhone);

        await _requestOtpForPhoneScreen(newPhone);

        _updatePhoneEditingState();
      } catch (e) {
        // _toggleSaveButton();

        ToastMessage.showToast(
          context,
          'requestUpdatePhone error: $e',
          ref.read(appThemeProvider),
          type: ToastMessageType.negative,
        );
      }
    } else {
      // _toggleSaveButton();

      ToastMessage.showToast(
        context,
        '_validatePhoneFields nothing changed, pay attention!!',
        ref.read(appThemeProvider),
        type: ToastMessageType.negative,
      );
    }
  }

  Future<void> _validateEmailFields(RequestUpdateEmail newEmail) async {
    final currentEmail = ref.read(clientInfoProviderNotifier)?.email ?? '';
    final customAppTheme = ref.watch(appThemeProvider);

    final isEmailAvailable =
        newEmail.newEmail != null && (newEmail.newEmail?.isNotEmpty ?? false);

    final email = newEmail.newEmail ?? '';

    if (isEmailAvailable && email != currentEmail) {
      try {
        await ref
            .read(requestUpdateEmailNotifierProvider.notifier)
            .requestUpdateEmail(newEmail);

        await _requestOtpForEmailScreen(newEmail);

        _updateEmailEditingState();
        return;
      } catch (error) {
        ToastMessage.showToast(
          context,
          '$error',
          customAppTheme,
          type: ToastMessageType.negative,
        );
        return;
      }
    } else {
      ToastMessage.showToast(
        context,
        '_validateEmailFields nothing changed, pay attention!!',
        ref.read(appThemeProvider),
        type: ToastMessageType.negative,
      );
    }
  }

  Future<String> _updatePhone(
    UpdatePhone newPhone,
    CustomAppTheme customAppTheme,
  ) async {
    try {
      final result = await ref
          .read(updatePhoneNotifierProvider.notifier)
          .updatePhone(newPhone);

      return result;
    } catch (error) {
      ToastMessage.showToast(
        context,
        '$error',
        customAppTheme,
        type: ToastMessageType.negative,
      );

      return error.toString();
    }
  }

  Future<void> _updateAddress(
    UpdateAddress newAddress,
    CustomAppTheme customAppTheme,
  ) async {
    try {
      await ref
          .read(updateAddressNotifierProvider.notifier)
          .updateAddress(newAddress);

      ref.watch(updateAddressNotifierProvider).maybeWhen(
            orElse: () => '',
            data: (result) async {
              await ref
                  .read(clientInfoRequestProviderNotifier.notifier)
                  .getClientInfo();

              await context.router.push(
                PersonalDetailsSuccessRoute(
                  icon: 'assets/BigCheckMark.svg',
                  message: 'address_submitted.description',
                  title: 'address_submitted.title',
                ),
              );

              return result;
            },
            error: (error) {
              ToastMessage.showToast(
                context,
                '${error?.invalidParams?.first.message ?? error} ',
                customAppTheme,
                type: ToastMessageType.negative,
              );
              return;
            },
          );
    } catch (error) {
      ToastMessage.showToast(
        context,
        'newAddress: $error',
        customAppTheme,
        type: ToastMessageType.negative,
      );
    }
  }

  Future<void> _requestOtpForEmailScreen(
    RequestUpdateEmail newEmail,
  ) async {
    await context.pushRoute(
      PersonalDetailsCheckEmailRoute(
        icon: 'assets/UpdateEmailCheck.svg',
        message: 'settings.change_email.check_email.text',
        title: 'settings.change_email.check_email.title',
        email: newEmail.newEmail ?? '',
      ),
    );
  }

  Future<void> _requestOtpForPhoneScreen(
    RequestUpdatePhone newPhone,
  ) async {
    final customAppTheme = ref.watch(appThemeProvider);

    await context.router.push(
      OTPOverlayRoute(
        customAppTheme: customAppTheme,
        phone: newPhone.newPhone!,
        onClose: () async {
          await context.router.push(
            PersonalDetailsSuccessRoute(
              icon: 'assets/BigCheckMark.svg',
              message: 'settings.change_phone.text',
              title: 'settings.change_phone.title',
              onButtonPress: () async {
                final storage = SecureStoreManager.instance;
                final prefs = SharedPreferenceManager.instance;

                await ref
                    .read(authenticationNotifierProvider.notifier)
                    .unauthenticate()
                    .then((_) async {
                  ref.read(clientInfoRequestProviderNotifier.notifier).reset();

                  await prefs.writeBiometrics(false);
                  await storage.deleteAll();

                  context.router.popUntilRoot();
                  await context.router.replaceAll([const OutOfAppRoute()]);
                });
              },
            ),
          );
        },
        onCallToAction: (otp) async {
          final updatePhone =
              UpdatePhone(newPhone: newPhone.newPhone, otpCode: otp);

          final result = await _updatePhone(updatePhone, customAppTheme);

          _handleChange(result);

          unawaited(
            ref
                .read(clientInfoRequestProviderNotifier.notifier)
                .getClientInfo(),
          );

          return result;
        },
        onResendOtp: (otp) async {
          await ref
              .read(requestUpdatePhoneNotifierProvider.notifier)
              .requestUpdatePhone(newPhone);

          // ignore: use_build_context_synchronously
          ToastMessage.showToast(
            context,
            'OTP has been re-sent',
            customAppTheme,
          );
        },
      ),
    );
  }

  Widget _sectionTitled(String title, bool isEditingCurrentSection) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 8.0,
        bottom: 16.0,
      ),
      child: Row(
        children: [
          Text(
            title.t(),
            style: _isUserEditing && !isEditingCurrentSection
                ? customAppTheme.textStyles.displayMedium
                    .copyWith(color: customAppTheme.colorsPalette.neutral3)
                : customAppTheme.textStyles.displayMedium,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
