import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/constants.dart';

// TODO: - Add to SharedPreferenceManager
Future<bool> isGuidedTourDone() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(IS_GUIDED_TOUR_DONE_KEY) ?? false;
}

Future<bool> isOnboardingDone() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(IS_ONBOARDING_DONE_KEY) ?? false;
}
