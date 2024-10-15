import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MovementsNotFound extends ConsumerWidget {
  const MovementsNotFound({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Column(
      children: [
        SvgPicture.asset('assets/no_result_found.svg'),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'home.filters.no_result.title'.t(),
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
            'home.filters.no_result.text'.t(),
            style: customAppTheme.textStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
