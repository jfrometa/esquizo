import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GuidedTourStepTwoWidget extends ConsumerWidget {
  const GuidedTourStepTwoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Column(
      children: [
        Expanded(
          child: SvgPicture.asset(
            'assets/guided_tour_step_two_image.svg',
            alignment: Alignment.bottomCenter,
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
                  'guide_tour.step_2.title'.t(),
                  style: customAppTheme.textStyles.displaySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  'guide_tour.step_2.description'.t(),
                  style: customAppTheme.textStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 62),
              ],
            ),
          ),
        )
      ],
    );
  }
}