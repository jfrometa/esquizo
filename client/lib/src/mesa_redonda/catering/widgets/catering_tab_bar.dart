import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

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
    return TabBar(
      controller: controller,
      dividerColor: Colors.transparent,
      isScrollable: true,
      labelStyle: Theme.of(context).textTheme.titleSmall,
      unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
      labelColor: ColorsPaletteRedonda.white,
      unselectedLabelColor: ColorsPaletteRedonda.deepBrown1,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: TabIndicator(
        color: ColorsPaletteRedonda.primary,
        radius: 16.0,
      ),
      tabs: categories.map(
        (category) => Container(
          width: maxTabWidth,
          alignment: Alignment.center,
          child: Tab(text: category),
        ),
      ).toList(),
    );
  }
}