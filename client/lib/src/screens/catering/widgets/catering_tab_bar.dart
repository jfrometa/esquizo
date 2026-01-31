import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_card.dart';

class CateringTabBar extends StatelessWidget {
  const CateringTabBar({
    super.key,
    required this.controller,
    required this.categories,
    required this.maxTabWidth,
  });

  final TabController controller;
  final List<String> categories;
  final double maxTabWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TabBar(
      controller: controller,
      dividerColor: Colors.transparent,
      isScrollable: true,
      labelStyle: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: theme.textTheme.titleSmall,
      labelColor: colorScheme.onPrimary,
      unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.7),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: TabIndicator(
        color: colorScheme.primary,
        radius: 16.0,
      ),
      tabs: categories
          .map(
            (category) => Container(
              width: maxTabWidth,
              alignment: Alignment.center,
              child: Tab(text: category),
            ),
          )
          .toList(),
    );
  }
}
