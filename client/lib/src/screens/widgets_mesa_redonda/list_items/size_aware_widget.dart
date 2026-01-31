// 1. Create a class to represent different screen sizes
import 'package:flutter/material.dart';

class ScreenSize {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMax &&
      MediaQuery.of(context).size.width < tabletMax;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;

  // Additional helper to get the current screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMax) return ScreenType.mobile;
    if (width < tabletMax) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}

// Enum for screen types
enum ScreenType { mobile, tablet, desktop }

// 2. Create a size-aware builder widget
class SizeAwareBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;

  const SizeAwareBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen type once and pass to builder
    final screenType = ScreenSize.getScreenType(context);
    return builder(context, screenType);
  }
}

// 3. Create a component that conditionally renders based on screen size
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
    return SizeAwareBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.mobile:
            return mobileBuilder;
          case ScreenType.tablet:
            return tabletBuilder;
          case ScreenType.desktop:
            return desktopBuilder;
        }
      },
    );
  }
}

// 5. Size-aware configuration for grid layouts
class GridConfig {
  final int columnCount;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;
  final int maxItems;

  const GridConfig({
    required this.columnCount,
    required this.spacing,
    this.runSpacing = 0.0, // Default to same as spacing if not specified
    required this.childAspectRatio,
    required this.maxItems,
  });

  // Factory constructors for different screen sizes
  factory GridConfig.forScreenType(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return const GridConfig(
          columnCount: 1,
          spacing: 16.0,
          childAspectRatio: 3.0, // Horizontal items
          maxItems: 4,
        );
      case ScreenType.tablet:
        return const GridConfig(
          columnCount: 2,
          spacing: 16.0,
          runSpacing: 24.0,
          childAspectRatio: 0.85,
          maxItems: 6,
        );
      case ScreenType.desktop:
        return const GridConfig(
          columnCount: 4,
          spacing: 24.0,
          runSpacing: 32.0,
          childAspectRatio: 0.75,
          maxItems: 8,
        );
    }
  }

  // Get run spacing with fallback to spacing if not specified
  double get effectiveRunSpacing => runSpacing > 0 ? runSpacing : spacing;
}

// 6. Applying the grid configuration
Widget buildOptimizedGrid(BuildContext context, List<dynamic> items,
    Widget Function(BuildContext, dynamic, int) itemBuilder) {
  return SizeAwareBuilder(
    builder: (context, screenType) {
      final config = GridConfig.forScreenType(screenType);

      // Special case for mobile - use ListView instead of grid
      if (screenType == ScreenType.mobile) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              items.length > config.maxItems ? config.maxItems : items.length,
          itemBuilder: (context, index) =>
              itemBuilder(context, items[index], index),
        );
      }

      // For tablet and desktop, use a grid layout
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: config.columnCount,
          childAspectRatio: config.childAspectRatio,
          crossAxisSpacing: config.spacing,
          mainAxisSpacing: config.effectiveRunSpacing,
        ),
        itemCount:
            items.length > config.maxItems ? config.maxItems : items.length,
        itemBuilder: (context, index) =>
            itemBuilder(context, items[index], index),
      );
    },
  );
}

// 7. Using the responsive grid in the menu section
