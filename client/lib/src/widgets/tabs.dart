import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Tabs extends StatefulWidget {
  const Tabs({
    super.key,
    this.controller,
    this.indicatorColor,
    this.backgroundColor,
    this.indicatorBorder,
    this.height = 40,
    this.onTap,
    required this.tabs,
  });
  final TabController? controller;
  final List<Widget> tabs;
  final Color? indicatorColor;
  final BoxBorder? indicatorBorder;
  final Color? backgroundColor;
  final double? height;
  final Function(int)? onTap;
  @override
  State createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final customAppTheme = ref.read(appThemeProvider);

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                customAppTheme.colorsPalette.secondary7,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: TabBar(
                onTap: (index) =>
                    widget.onTap != null ? widget.onTap!(index) : null,
                labelColor: customAppTheme.colorsPalette.secondary,
                labelStyle: customAppTheme.textStyles.labelMedium,
                labelPadding: const EdgeInsets.all(0),
                unselectedLabelColor: customAppTheme.colorsPalette.neutral6,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: widget.indicatorBorder,
                  color: widget.indicatorColor ??
                      customAppTheme.colorsPalette.secondarySoft,
                ),
                tabs: widget.tabs,
                controller: _controller,
              ),
            ),
          ),
        );
      },
    );
  }
}

class BrandedTabs extends StatefulWidget {
  const BrandedTabs({
    super.key,
    this.controller,
    this.indicatorColor,
    this.backgroundColor,
    this.indicatorBorder,
    this.height = 40,
    this.onTap,
    required this.tabs,
  });
  final TabController? controller;
  final List<Widget> tabs;
  final Color? indicatorColor;
  final BoxBorder? indicatorBorder;
  final Color? backgroundColor;
  final double? height;
  final Function(int)? onTap;
  @override
  State createState() => _BrandedTabsState();
}

class _BrandedTabsState extends State<BrandedTabs> {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final customAppTheme = ref.read(appThemeProvider);

        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: customAppTheme.colorsPalette.neutral3),
            color: widget.backgroundColor ?? customAppTheme.colorsPalette.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Theme(
              data: ThemeData(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: TabBar(
                onTap: (index) =>
                    widget.onTap != null ? widget.onTap!(index) : null,
                labelColor: customAppTheme.colorsPalette.white,
                labelStyle: customAppTheme.textStyles.labelMedium,
                unselectedLabelColor: customAppTheme.colorsPalette.primary,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: widget.indicatorBorder,
                  color: widget.indicatorColor ??
                      customAppTheme.colorsPalette.primary,
                ),
                tabs: widget.tabs,
                controller: _controller,
              ),
            ),
          ),
        );
      },
    );
  }
}
