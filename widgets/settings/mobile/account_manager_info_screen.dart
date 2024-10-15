import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/settings/content/account_manager_info_content.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/notifiers/account_manager_provider_notifier.dart';

// @RoutePage()
class AccountManagerInfoMobileScreen extends ConsumerStatefulWidget {
  const AccountManagerInfoMobileScreen({super.key});

  @override
  ConsumerState<AccountManagerInfoMobileScreen> createState() =>
      _AccountManagerInfoMobileScreenState();
}

class _AccountManagerInfoMobileScreenState
    extends ConsumerState<AccountManagerInfoMobileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountManagerPhotoNotifierProvider.notifier).getPhoto();
    });
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      appBar: Header(
        context: context,
        title: 'settings.account_manager.header.title'.t(),
        leading: IconButton(
          icon: const Icon(ThanosIcons.buttonsBack),
          onPressed: () {
            context.router.pop();
          },
        ),
      ),
      body: const AccountManagerInfoContent(),
    );
  }
}
