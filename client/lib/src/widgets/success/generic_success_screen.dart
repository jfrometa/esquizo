import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

// @RoutePage()
class GenericSuccessScreen extends ConsumerWidget {
  const GenericSuccessScreen({
    super.key,
    required this.title,
    required this.description,
    required this.leaveFlow,
    required this.buttonText,
    this.headerTitle,
    this.icon,
    this.showCloseButton = false,
  });

  final String title;
  final String description;
  final Function() leaveFlow;
  final String buttonText;
  final String? headerTitle;
  final String? icon;
  final bool showCloseButton;

  static const String path = 'success';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      appBar: Header(
        context: context,
        leading: Container(),
        leadingWidth: 0,
        trailing: showCloseButton
            ? IconButton(
                onPressed: () => context.router.pop(),
                icon: const Icon(ThanosIcons.buttonsClose),
              )
            : null,
        title: headerTitle,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? SvgPicture.asset(icon!)
                : SvgPicture.asset('assets/big_checkmark_green.svg'),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                title,
                style: customAppTheme.textStyles.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  description,
                  style: customAppTheme.textStyles.bodyLarge,
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 64),
            Button(
              onPressed: () {
                leaveFlow();
              },
              rounded: true,
              wrap: true,
              text: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
