import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TakePictureButton extends ConsumerWidget {
  const TakePictureButton({
    super.key,
    required this.onPressed,
  });
  final Function onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return SizedBox(
      height: 88,
      width: 88,
      child: Container(
        decoration: BoxDecoration(
          color: customAppTheme.colorsPalette.primary7,
          borderRadius: BorderRadius.circular(44),
        ),
        child: InkWell(
          splashColor: customAppTheme.colorsPalette.secondary,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(44),
          ),
          onTap: () {
            onPressed();
          },
          child: Center(
            child: SizedBox(
              height: 68,
              width: 68,
              child: Container(
                decoration: BoxDecoration(
                  color: customAppTheme.colorsPalette.primary,
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Center(
                  child: Icon(
                    ThanosIcons.buttonsCamera,
                    color: customAppTheme.colorsPalette.secondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
