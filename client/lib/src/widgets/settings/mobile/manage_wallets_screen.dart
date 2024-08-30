import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/settings/content/manage_wallets_contet.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @RoutePage()
class ManageWalletsMobileScreen extends ConsumerStatefulWidget {
  const ManageWalletsMobileScreen({super.key});

  @override
  ConsumerState<ManageWalletsMobileScreen> createState() =>
      _ManageWalletsMobileScreenState();
}

class _ManageWalletsMobileScreenState
    extends ConsumerState<ManageWalletsMobileScreen> {
  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      appBar: Header(
        context: context,
        title: 'settings_personal.section.manage_wallets.section.78'.t(),
        leading: IconButton(
          onPressed: () async => context.router.pop(),
          icon: const Icon(ThanosIcons.buttonsBack),
        ),
      ),
      body: const ManageWalletsContent(),
    );
  }
}
