import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/bottom_bar/bottom_bar_item.dart';
import 'package:starter_architecture_flutter_firebase/widgets/bottom_bar/quick_actions_overlay_content.dart';
import 'package:starter_architecture_flutter_firebase/widgets/desktop_navigation_bar/desktop_navigation_bar_item.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class DesktopNavigationBar extends ConsumerStatefulWidget {
  const DesktopNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.quickActionLeft,
    this.quickActionMiddle,
    this.quickActionRight,
  });

  final List<BottomBarItemData> items;
  final int selectedIndex;
  final QuickActionData? quickActionLeft;
  final QuickActionData? quickActionMiddle;
  final QuickActionData? quickActionRight;

  @override
  ConsumerState<DesktopNavigationBar> createState() =>
      _DesktopNavigationBarState();
}

class _DesktopNavigationBarState extends ConsumerState<DesktopNavigationBar> {
  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);
    final items = widget.items;

    return Container(
      width: 240,
      height: double.maxFinite,
      color: customAppTheme.colorsPalette.primary,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
              child: SvgPicture.asset(
                'assets/logo_text.svg',
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                'main_navigation'.t(),
                style: customAppTheme.textStyles.labelMedium.copyWith(
                  color: customAppTheme.colorsPalette.white.withOpacity(.3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            items.isNotEmpty
                ? DesktopNavigationBarItem(
                    data: items[0],
                    selected: widget.selectedIndex == 0,
                  )
                : Expanded(child: Container()),
            items.length > 1
                ? DesktopNavigationBarItem(
                    data: items[1],
                    selected: widget.selectedIndex == 1,
                  )
                : Expanded(child: Container()),
            items.length > 2
                ? DesktopNavigationBarItem(
                    data: items[2],
                    selected: widget.selectedIndex == 2,
                  )
                : Expanded(child: Container()),
            items.length > 3
                ? DesktopNavigationBarItem(
                    data: items[3],
                    selected: widget.selectedIndex == 3,
                  )
                : Expanded(child: Container()),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                'quick_actions'.t(),
                style: customAppTheme.textStyles.labelMedium.copyWith(
                  color: customAppTheme.colorsPalette.white.withOpacity(.3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            widget.quickActionLeft != null
                ? DesktopNavigationBarItem(
                    data: BottomBarItemData(
                      icon: widget.quickActionLeft!.icon,
                      label: widget.quickActionLeft!.label,
                      onPressed: widget.quickActionLeft!.onPressed,
                    ),
                  )
                : Container(),
            widget.quickActionMiddle != null
                ? DesktopNavigationBarItem(
                    data: BottomBarItemData(
                      icon: widget.quickActionMiddle!.icon,
                      label: widget.quickActionMiddle!.label,
                      onPressed: widget.quickActionMiddle!.onPressed,
                    ),
                  )
                : Container(),
            widget.quickActionRight != null
                ? DesktopNavigationBarItem(
                    data: BottomBarItemData(
                      icon: widget.quickActionRight!.icon,
                      label: widget.quickActionRight!.label,
                      onPressed: widget.quickActionRight!.onPressed,
                    ),
                  )
                : Container(),
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                'main_navigation.text'.t(),
                style: customAppTheme.textStyles.bodySmall.copyWith(
                  color: customAppTheme.colorsPalette.white.withOpacity(.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 17),
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'main_navigation.term_conditions'.t(),
                  style: customAppTheme.textStyles.button.copyWith(
                    color: customAppTheme.colorsPalette.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'main_navigation.privacy_policy'.t(),
                      style: customAppTheme.textStyles.button.copyWith(
                        color: customAppTheme.colorsPalette.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'main_navigation.help'.t(),
                      style: customAppTheme.textStyles.button.copyWith(
                        color: customAppTheme.colorsPalette.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
