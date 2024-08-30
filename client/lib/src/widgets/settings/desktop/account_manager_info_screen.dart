import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/settings/content/account_manager_info_content.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/notifiers/account_manager_provider_notifier.dart';

// @RoutePage()
class AccountManagerInfoScreen extends ConsumerStatefulWidget {
  const AccountManagerInfoScreen({super.key});

  @override
  ConsumerState<AccountManagerInfoScreen> createState() =>
      _AccountManagerInfoScreenState();
}

class _AccountManagerInfoScreenState
    extends ConsumerState<AccountManagerInfoScreen> {
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
      body: const AccountManagerInfoContent(),
    );
  }
}
