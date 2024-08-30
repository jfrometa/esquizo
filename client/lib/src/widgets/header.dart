import 'package:starter_architecture_flutter_firebase/helpers/responsive_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Header extends ConsumerWidget implements PreferredSizeWidget {
  Header({
    super.key,
    customHeight,
    this.title,
    this.leading,
    this.trailing,
    this.titleWidget,
    this.leadingWidth,
    this.background,
    required this.context,
  }) : height = customHeight ?? ResponsiveWidget.isDesktopScreen(context)
            ? 108
            : 56;
  final double height;
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final Widget? trailing;
  final BuildContext context;
  final double? leadingWidth;
  final Color? background;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return ResponsiveWidget(
      mobileScreen: AppBar(
        centerTitle: true,
        title: titleWidget ??
            (title != null
                ? Text(
                    title ?? '',
                    style: customAppTheme.textStyles.headlineLarge,
                  )
                : null),
        elevation: 0,
        toolbarHeight: height,
        backgroundColor: background ?? Colors.transparent,
        iconTheme: IconThemeData(color: customAppTheme.colorsPalette.secondary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: leading,
        actions: trailing != null ? [trailing!] : null,
      ),
      desktopScreen: AppBar(
        centerTitle: false,
        title: titleWidget ??
            (title != null
                ? Text(
                    title ?? '',
                    style: customAppTheme.textStyles.displayLarge,
                  )
                : null),
        elevation: 0,
        toolbarHeight: 108,
        backgroundColor: customAppTheme.colorsPalette.primary7,
        iconTheme: IconThemeData(color: customAppTheme.colorsPalette.primary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: leading,
        leadingWidth: leadingWidth,
        automaticallyImplyLeading: false,
        titleSpacing: 48,
        actions: trailing != null ? [trailing!] : null,
      ),
    );
  }
}
