import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickActionButton extends ConsumerWidget {
  const QuickActionButton({
    super.key,
    required this.onPressed,
  });
  final Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return SizedBox(
      height: 68,
      width: 68,
      child: Container(
        decoration: BoxDecoration(
          color: customAppTheme.colorsPalette.primary7,
          borderRadius: BorderRadius.circular(44),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(44),
          ),
          onTap: onPressed,
          child: Center(
            child: SizedBox(
              height: 56,
              width: 56,
              child: Container(
                decoration: BoxDecoration(
                  color: customAppTheme.colorsPalette.primary,
                  borderRadius: BorderRadius.circular(34),
                ),
                child: const Center(
                  // child: Icon(
                  //   ThanosIcons.bottomBarQuickActions,
                  //   color: customAppTheme.colorsPalette.white,
                  // ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
