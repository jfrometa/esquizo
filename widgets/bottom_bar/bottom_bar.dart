import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/bottom_bar/bottom_bar_item.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/bottom_bar/quick_action_button.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/bottom_bar/quick_actions_overlay.dart';
import 'package:starter_architecture_flutter_firebase/src/widgets/bottom_bar/quick_actions_overlay_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomBar extends ConsumerWidget {
  const BottomBar({
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
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);
    return SizedBox(
      height: 90,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 34),
            child: Container(
              clipBehavior: Clip.antiAlias,
              height: 56,
              decoration: BoxDecoration(
                color: customAppTheme.colorsPalette.white,
                border: Border(
                  top: BorderSide(
                    color: customAppTheme.colorsPalette.primary7,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  items.isNotEmpty
                      ? BottomBarItem(
                          data: items[0],
                          selected: selectedIndex == 0,
                        )
                      : Expanded(child: Container()),
                  items.length > 1
                      ? BottomBarItem(
                          data: items[1],
                          selected: selectedIndex == 1,
                        )
                      : Expanded(child: Container()),
                  const SizedBox(width: 68),
                  items.length > 2
                      ? BottomBarItem(
                          data: items[2],
                          selected: selectedIndex == 2,
                        )
                      : Expanded(child: Container()),
                  items.length > 3
                      ? BottomBarItem(
                          data: items[3],
                          selected: selectedIndex == 3,
                        )
                      : Expanded(child: Container()),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QuickActionButton(
                onPressed: () async {
                  // if (ref.watch(clientInfoProviderNotifier)?.kycStatus ==
                  //     KYCStatusType.APPROVED) {
                  await Navigator.push(
                    context,
                    QuickActionsOverlay(
                      left: quickActionLeft,
                      middle: quickActionMiddle,
                      right: quickActionRight,
                    ),
                  );
                  // } else {
                  //   ToastMessage.showToast(
                  //     context,
                  //     "KYC approval is still pending",
                  //     ref.read(appThemeProvider),
                  //     type: ToastMessageType.negative,
                  //   );
                  // }
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
