import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/utils/secure_storange_manager.dart';
import 'package:starter_architecture_flutter_firebase/utils/shared_preference_manager.dart';
import 'package:starter_architecture_flutter_firebase/widgets/button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:natasha/notifiers/authentication_provider_notifier.dart';
import 'package:natasha/notifiers/index.dart';

class UpdatePasscodeSuccessContent extends ConsumerWidget {
  const UpdatePasscodeSuccessContent({super.key});

  static const String path = 'success';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);
    final storage = SecureStoreManager.instance;
    final SharedPreferenceManager prefs = SharedPreferenceManager.instance;

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 160, 0, 40),
                  child: SvgPicture.asset('assets/BigIconBigCheckGreen.svg'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'passcode_changed.title'.t(),
                    style: customAppTheme.textStyles.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 16.0,
                    left: 16.0,
                    bottom: 64.0,
                  ),
                  child: Text(
                    'passcode_changed.description'.t(),
                    style: customAppTheme.textStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 55,
                  width: 212,
                  child: Button.primary(
                    text: Text('passcode_changed.button'.t()),
                    wrap: true,
                    rounded: true,
                    onPressed: () async {
                      await ref
                          .read(authenticationNotifierProvider.notifier)
                          .unauthenticate()
                          .then((_) async {
                        ref
                            .read(clientInfoRequestProviderNotifier.notifier)
                            .reset();

                        await prefs.writeBiometrics(false);
                        await storage.deleteAll();

                        // ignore: use_build_context_synchronously
                        context.router.popUntilRoot();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
