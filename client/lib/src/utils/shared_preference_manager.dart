import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/constants.dart';

class SharedPreferenceManager {
  static final SharedPreferenceManager instance = SharedPreferenceManager();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> writeBiometrics(bool canUseBiometrics) async {
    final prefs = await _prefs;
    await prefs.setBool(CAN_USE_BIO, canUseBiometrics);
  }

  Future<bool> readBiometrics() async {
    final prefs = await _prefs;
    final isBiometricsEnabled = prefs.getBool(CAN_USE_BIO);
    return isBiometricsEnabled ?? false;
  }

  Future<void> writeItsConfirmedUser(bool confirmation) async {
    final prefs = await _prefs;
    await prefs.setBool(ITS_CONFIRMED_USER, confirmation);
  }

  Future<bool> readItsConfirmedUser() async {
    final prefs = await _prefs;
    return prefs.getBool(ITS_CONFIRMED_USER) ?? false;
  }

  Future<void> writeItsEmailVeryfied(bool isFirst) async {
    final prefs = await _prefs;

    await prefs.setBool(ITS_VERYFIED_EMAIL, isFirst);
  }

  Future<bool> readItsEmailVeryfied() async {
    final prefs = await _prefs;
    final itsVeryfiedEmail = prefs.getBool(ITS_VERYFIED_EMAIL);
    return itsVeryfiedEmail ?? true;
  }

  Future<void> writeItsFirstLogin(bool itsVeryfiedEmail) async {
    final prefs = await _prefs;

    await prefs.setBool(ITS_FIRST_LOGIN, itsVeryfiedEmail);
  }

  Future<bool> readItsFirstLogin() async {
    final prefs = await _prefs;
    final itsFirstLogin = prefs.getBool(ITS_FIRST_LOGIN);
    return itsFirstLogin ?? true;
  }

  Future<void> writeEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(EMAIL, email);
  }

  Future<String> readEmail() async {
    final prefs = await _prefs;
    return prefs.getString(EMAIL) ?? 'email_key_not_found';
  }

  Future<void> clearAllPreferences() async {
    final prefs = await _prefs;
    await prefs.setString(EMAIL, '');
    await writeItsFirstLogin(true);
    await writeItsConfirmedUser(false);
    await writeBiometrics(false);
  }
}
