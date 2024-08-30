import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/utils/secure_storange_manager.dart';
import 'package:starter_architecture_flutter_firebase/utils/shared_preference_manager.dart';
import 'package:starter_architecture_flutter_firebase/widgets/button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:natasha/notifiers/authentication_provider_notifier.dart';
import 'package:natasha/notifiers/index.dart';

class UpdatePersonalDetailsSuccessContent extends ConsumerWidget {
  const UpdatePersonalDetailsSuccessContent({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onButtonPress,
  });

  final String icon;
  final String title;
  final String message;
  final Function? onButtonPress;

  static const String path = 'success';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      appBar: onButtonPress == null
          ? Header(
              context: context,
              leading: Container(),
              trailing: IconButton(
                icon: const Icon(ThanosIcons.buttonsClose),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 160, 0, 40),
                  child: SvgPicture.asset(icon),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title.t(),
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
                    message.t(),
                    style: customAppTheme.textStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                onButtonPress != null
                    ? SizedBox(
                        height: 55,
                        width: 212,
                        child: Button.primary(
                          text: Text('passcode_changed.button'.t()),
                          wrap: true,
                          rounded: true,
                          onPressed: () async {
                            onButtonPress!();
                          },
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
