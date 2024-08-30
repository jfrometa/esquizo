import 'package:flutter/material.dart';

// Width in px (inclusive)
const int maxMobileScreenWidth = 1024;

class ResponsiveWidget extends StatelessWidget {

  const ResponsiveWidget({
    super.key,
    required this.mobileScreen,
    required this.desktopScreen,
  });
  final Widget mobileScreen;
  final Widget desktopScreen;

  static bool isMobileScreen(BuildContext context) {
    return MediaQuery.of(context).size.width <=
        maxMobileScreenWidth;
  }

  static bool isDesktopScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >
        maxMobileScreenWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isDesktopScreen(context)) {
          return desktopScreen;
        } else {
          return mobileScreen;
        }
      },
    );
  }
}
