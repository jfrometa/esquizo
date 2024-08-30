
import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';

enum ToastMessageType {
  postive,
  negative,
}

class ToastMessage {
  ToastMessage._();

  static showToast(
    BuildContext context,
    String message,
    CustomAppTheme customAppTheme, {
    ToastMessageType type = ToastMessageType.postive,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: type == ToastMessageType.negative
                          ? customAppTheme.colorsPalette.negativeAction
                              .withOpacity(0.7)
                          : customAppTheme.colorsPalette.positiveAction
                              .withOpacity(0.7),
                    ),
                    child: Text(
                      message,
                      style: customAppTheme.textStyles.smallBody
                          .copyWith(color: customAppTheme.colorsPalette.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    });
  }
}
