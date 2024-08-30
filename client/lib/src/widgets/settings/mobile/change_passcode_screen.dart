import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/settings/content/change_passcode_content.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @RoutePage()
class ChangePasscodeMobileScreen extends ConsumerStatefulWidget {
  const ChangePasscodeMobileScreen({super.key});

  @override
  ConsumerState<ChangePasscodeMobileScreen> createState() =>
      _ChangePasscodeMobileScreenState();
}

class _ChangePasscodeMobileScreenState
    extends ConsumerState<ChangePasscodeMobileScreen> {
  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      appBar: Header(
        context: context,
        title: 'Change passcode',
        leading: IconButton(
          onPressed: () async => context.router.pop(),
          icon: const Icon(ThanosIcons.buttonsBack),
        ),
      ),
      body: const ChangePasscodeContent(),
    );
  }
}
