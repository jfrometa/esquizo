// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/helpers/constants.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:natasha/notifiers/wallet_controller_provider_notififer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuidedTourStepFourWidget extends ConsumerWidget {
  const GuidedTourStepFourWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.topCenter,
                child: Text(
                  'guide_tour.final_step.welcome_message'.t(),
                  style: customAppTheme.textStyles.outPlatformTitle,
                  textAlign: TextAlign.center,
                ),
              ),
              Lottie.asset(
                'assets/adobe-after-effects-confeti-animation.json',
                fit: BoxFit.cover,
              ),
              SvgPicture.asset(
                'assets/two_guys_one_cup.svg',
              ),
            ],
          ),
        ),
        Container(
          width: double.maxFinite,
          alignment: Alignment.center,
          color: customAppTheme.colorsPalette.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  'guide_tour.final_step.title'.t(),
                  style: customAppTheme.textStyles.displaySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  'guide_tour.final_step.description'.t(),
                  style: customAppTheme.textStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Button(
                  rounded: true,
                  text: Text('guide_tour.final_step.action_button'.t()),
                  wrap: true,
                  onPressed: () async {
                    // TODO: - Add to SharedPreferenceManager
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    await prefs.setBool(IS_GUIDED_TOUR_DONE_KEY, true);
                    await ref
                        .read(clientWalletStateNotifierProvider.notifier)
                        .clientWallet();

                    context.router.popUntilRouteWithName(InAppRouterRoute.name);
                  },
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
