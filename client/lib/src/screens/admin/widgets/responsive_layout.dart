import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 600) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Helper class for building responsive grids
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Calculate how many items can fit per row based on screen width
    // For simplicity, we'll use fixed card widths
    final cardWidth = 300.0;
    final horizontalPadding = 32.0; // 16.0 padding on each side
    final availableWidth = width - horizontalPadding;
    final crossAxisCount = (availableWidth / (cardWidth + spacing)).floor();
    
    return SingleChildScrollView(
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: children,
      ),
    );
  }
}


// Helper class for responsive wrapping of widgets
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: alignment,
        runAlignment: runAlignment,
        children: children,
      ),
    );
  }
}

// Helper class for responsive container sizes
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double mobileWidth;
  final double tabletWidth;
  final double desktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth = double.infinity,
    this.tabletWidth = 600,
    this.desktopWidth = 800,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
  });

  @override
  Widget build(BuildContext context) {
    double width;
    double? height;

    if (ResponsiveLayout.isDesktop(context)) {
      width = desktopWidth;
      height = desktopHeight;
    } else if (ResponsiveLayout.isTablet(context)) {
      width = tabletWidth;
      height = tabletHeight;
    } else {
      width = mobileWidth;
      height = mobileHeight;
    }

    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}