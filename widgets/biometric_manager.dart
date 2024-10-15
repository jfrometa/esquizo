// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/secure_storange_manager.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/shared_preference_manager.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/pin_code_and_biometrics/biometric_overlay.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/pin_code_and_biometrics/pin_code_validation_screen.dart';

class BiometricsManager {
  factory BiometricsManager() {
    return _instance;
  }

  BiometricsManager._build();
  static final BiometricsManager _instance = BiometricsManager._build();

  WidgetRef? _ref;
  bool _isInitialized = false;
  BuildContext? _context;

  final LocalAuthentication _localAuth = LocalAuthentication();
  final SharedPreferenceManager _prefs = SharedPreferenceManager.instance;
  final SecureStoreManager _secureStorange = SecureStoreManager.instance;

  void init(BuildContext context, WidgetRef ref) {
    if (_isInitialized) {
      return;
    }

    if (!_isInitialized) {
      _context = context;
      _ref = ref;

      unawaited(_isBiometricAvailableFuture());
    }

    isBiometricAvailable;
    storedPinCode;
    _isInitialized = true;

    return;
  }

  String get storedPinCode => _ref?.watch(passcodeProvider) ?? '';
  bool get isBiometricAvailable {
    unawaited(_isBiometricAvailableFuture());

    return _ref?.watch(isBiometricAvailableProvider) ?? false;
  }

  Future<void> authenticate(Function onAuthCompleted, Function onAuthFailed,
      BuildContext context) async {
    bool isAuthenticated = false;

    if (isBiometricAvailable) {
      isAuthenticated = await _authenticateWithBiometricsOverlay(context);
    }

    if (!isBiometricAvailable) {
      isAuthenticated = await _authenticateWithPinCode(context);
    }

    if (isAuthenticated) {
      onAuthCompleted();
    } else {
      onAuthFailed();
    }
  }

/////// functions to handle biometric and PIN code authentication: /////////

  Future<bool> _authenticateWithBiometricsOverlay(BuildContext context) async {
    CustomAppTheme customAppTheme = _ref!.read(appThemeProvider);
    bool isAuthenticated = false;

    await Navigator.of(context).push(
      BiometricOverlay(
        customAppTheme: customAppTheme,
        onAuthenticate: () {
          isAuthenticated = true;
          Navigator.of(context).pop();
        },
        onCancelOrFail: () {
          isAuthenticated = false;
          Navigator.of(context).pop();
        },
      ),
    );

    return isAuthenticated;
  }

  Future<bool> _authenticateWithPinCode(BuildContext context) async {
    bool isAuthenticate = false;
    CustomAppTheme customAppTheme = _ref!.watch(appThemeProvider);
    try {
      await Navigator.of(context).push(
        PinCodeValidationOverlay(
          onValidationCompleted: (isAuthenticated) {
            isAuthenticate = isAuthenticated;
            return isAuthenticated;
          },
          customAppTheme: customAppTheme,
        ),
      );
    } catch (g) {
      log(g.toString());
    }

    return isAuthenticate;
  }

///////// function to get the user's stored preference for the authentication

  Future<void> requestBiometricsLoginOptions(String pin) {
    if (_context == null) {
      return Future.value();
    }

    return showDialog<void>(
      context: _context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Biometrics!'),
          content: const Text(
            'by enabling the biometrics youll be able to login without using your password',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Not right now'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _applyBiometricOptionsAndNavigateToApp(
                  context,
                  pin,
                  false,
                );
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('yes i want it!'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _applyBiometricOptionsAndNavigateToApp(
                  context,
                  pin,
                  true,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> toggleBiometrics(bool option) async {
    await _prefs.writeBiometrics(option);
    unawaited(_isBiometricAvailableFuture());
    return option;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'login.step_2.fingerprint_text'.t(),
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      return authenticated;
    } on PlatformException catch (exception) {
      log('_authenticateWithBiometrics PlatformException error: $exception ');

      await _localAuth.stopAuthentication();
      return false;
    } catch (error) {
      log('_authenticateWithBiometrics error: $error ');

      await _localAuth.stopAuthentication();
      return false;
    }
  }

  Future<void> _securePinCode(String pinCode) async {
    if (pinCode.isEmpty) {
      return;
    }

    await _secureStorange.write(
      SECURE_PIN,
      pinCode,
    );
  }

  Future<void> _itsFirstLogin(bool option) async {
    await _prefs.writeItsFirstLogin(option);
  }

  Future<void> _applyBiometricOptionsAndNavigateToApp(
    BuildContext context,
    String pin,
    bool canUseBiometrics,
  ) async {
    await toggleBiometrics(canUseBiometrics);
    _ref?.read(isBiometricAvailableProvider.notifier).update(canUseBiometrics);

    await _securePinCode(pin);
    await _itsFirstLogin(false);

    if (_context != null) {
      await _navigateToInAppRoute();
    }
  }

  Future<void> _navigateToInAppRoute() async {
    await AutoRouter.of(_context!).pop();

    await _context!.router.push(const InAppRouterRoute());
  }

  Future<void> _isBiometricAvailableFuture() async {
    bool isSupported = false;

    final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    final bool isUserBiometricOptionEnabled = await _prefs.readBiometrics();

    if (!kIsWeb) {
      isSupported = await _localAuth.isDeviceSupported();
    }

    final isBiometricAvailable =
        isSupported & isUserBiometricOptionEnabled & canCheckBiometrics;

    _ref
        ?.read(isBiometricAvailableProvider.notifier)
        .update(isBiometricAvailable);
  }
}
