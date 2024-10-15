import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/bottom_bar/bottom_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopNavigationBarItem extends ConsumerWidget {
  const DesktopNavigationBarItem({
    super.key,
    this.selected = false,
    required this.data,
  });
  final bool selected;
  final BottomBarItemData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: data.onPressed,
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected
                ? customAppTheme.colorsPalette.white.withOpacity(.05)
                : Colors.transparent,
          ),
          height: 56,
          child: Row(
            children: [
              Icon(
                selected ? data.icon : (data.unselectedIcon ?? data.icon),
                color: selected
                    ? customAppTheme.colorsPalette.secondary
                    : customAppTheme.colorsPalette.white.withOpacity(.5),
              ),
              const SizedBox(width: 19),
              Text(
                data.label,
                style: customAppTheme.textStyles.headlineMedium.copyWith(
                  color: selected
                      ? customAppTheme.colorsPalette.white
                      : customAppTheme.colorsPalette.white.withOpacity(.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
