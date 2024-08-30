import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomBarItemData {
  BottomBarItemData({
    required this.icon,
    this.unselectedIcon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final IconData? unselectedIcon;
  final String label;
  final Function() onPressed;
}

class BottomBarItem extends ConsumerWidget {
  const BottomBarItem({
    super.key,
    this.selected = false,
    required this.data,
  });
  final bool selected;
  final BottomBarItemData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Expanded(
      child: SizedBox(
        height: 56,
        child: InkWell(
          onTap: data.onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? data.icon : (data.unselectedIcon ?? data.icon),
                color: selected
                    ? customAppTheme.colorsPalette.primary
                    : customAppTheme.colorsPalette.neutral6,
              ),
              Text(
                data.label,
                style: customAppTheme.textStyles.bodyLarge.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 10,
                  height: 1.8,
                  color: selected
                      ? customAppTheme.colorsPalette.primary
                      : customAppTheme.colorsPalette.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
