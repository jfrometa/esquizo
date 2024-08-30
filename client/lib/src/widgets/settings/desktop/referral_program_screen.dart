import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/helpers/responsive_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// @RoutePage()
class ReferralProgramScreen extends ConsumerStatefulWidget {
  const ReferralProgramScreen({super.key});

  @override
  ConsumerState<ReferralProgramScreen> createState() =>
      _ReferralProgramScreenState();
}

class _ReferralProgramScreenState extends ConsumerState<ReferralProgramScreen> {
  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: customAppTheme.colorsPalette.white,
      appBar: ResponsiveWidget.isDesktopScreen(context)
          ? null
          : Header(
              context: context,
              leading: IconButton(
                icon: const Icon(ThanosIcons.buttonsBack),
                onPressed: () => context.router.pop(),
              ),
            ),
      body: const Center(
        child: Text('ReferralProgramScreen'),
      ),
    );
  }
}
