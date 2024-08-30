import 'package:starter_architecture_flutter_firebase/helpers/responsive_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({
    super.key,
    this.underlineColor,
    this.backgroundColor,
    required this.tabs,
    required this.widgets,
  });
  final List<Widget> tabs;
  final List<Widget> widgets;
  final Color? underlineColor;
  final Color? backgroundColor;

  @override
  State createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final customAppTheme = ref.watch(appThemeProvider);
        return DefaultTabController(
          length: widget.tabs.length,
          child: Column(
            children: [
              ResponsiveWidget(
                mobileScreen: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableWidth =
                        ((constraints.maxWidth / widget.tabs.length) - 32) / 2;
                    return TabBar(
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: widget.underlineColor ??
                              customAppTheme.colorsPalette.primary,
                          width: 3,
                        ),
                        insets:
                            EdgeInsets.symmetric(horizontal: availableWidth),
                      ),
                      unselectedLabelColor:
                          customAppTheme.colorsPalette.neutral6,
                      labelStyle: customAppTheme.textStyles.headlineMedium,
                      tabs: widget.tabs,
                    );
                  },
                ),
                desktopScreen: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  width: double.maxFinite,
                  color: widget.backgroundColor ??
                      customAppTheme.colorsPalette.primary7,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return TabBar(
                        isScrollable: true,
                        indicator: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          color: Colors.white,
                        ),
                        unselectedLabelColor:
                            customAppTheme.colorsPalette.primary40,
                        labelStyle: customAppTheme.textStyles.headlineMedium,
                        tabs: widget.tabs,
                      );
                    },
                  ),
                ),
              ),
              ResponsiveWidget.isDesktopScreen(context)
                  ? Container()
                  : Container(
                      height: 1,
                      width: double.maxFinite,
                      color: customAppTheme.colorsPalette.primary7,
                    ),
              Expanded(
                child: TabBarView(
                  children: widget.widgets,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
