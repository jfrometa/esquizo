import 'package:flutter/material.dart';

/// A responsive section widget that displays different content based on screen size
class ResponsiveSection extends StatelessWidget {
  final Widget mobileBuilder;
  final Widget tabletBuilder;
  final Widget desktopBuilder;

  const ResponsiveSection({
    super.key,
    required this.mobileBuilder,
    required this.tabletBuilder,
    required this.desktopBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth <= 600) {
      return mobileBuilder;
    } else if (screenWidth <= 1024) {
      return tabletBuilder;
    } else {
      return desktopBuilder;
    }
  }
}
