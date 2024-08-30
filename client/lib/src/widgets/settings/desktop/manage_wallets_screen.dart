import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/settings/content/manage_wallets_contet.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @RoutePage()
class ManageWalletsScreen extends ConsumerStatefulWidget {
  const ManageWalletsScreen({super.key});

  @override
  ConsumerState<ManageWalletsScreen> createState() =>
      _ManageWalletsScreenState();
}

class _ManageWalletsScreenState extends ConsumerState<ManageWalletsScreen> {
  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      body: const ManageWalletsContent(),
    );
  }
}
