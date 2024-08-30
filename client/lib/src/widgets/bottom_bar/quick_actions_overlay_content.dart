import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickActionData {
  QuickActionData({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
    required this.iconColor,
    this.enable = true,
  });
  IconData icon;
  Color color;
  Color iconColor;
  String label;
  Function() onPressed;
  final bool enable;
}

enum QuickActionPosition { left, middle, right }

class QuickActionsOverlayContent extends ConsumerStatefulWidget {
  const QuickActionsOverlayContent({
    super.key,
    this.left,
    this.middle,
    this.right,
  });
  final QuickActionData? left;
  final QuickActionData? middle;
  final QuickActionData? right;

  @override
  ConsumerState createState() => _QuickActionsOverlayContentState();
}

class _QuickActionsOverlayContentState
    extends ConsumerState<QuickActionsOverlayContent>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  late final Animation<double> _opacityAnimation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );

  late final Animation<double> _spinAnimation = Tween<double>(
    begin: 0,
    end: 1 / 8,
  ).animate(_animationController);

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.5),
    end: const Offset(0, 0),
  ).animate(_animationController);

  late final Animation<Offset> _textSlideAnimation = Tween<Offset>(
    begin: const Offset(0, 1.5),
    end: const Offset(0, 0),
  ).animate(_animationController);

  @override
  void initState() {
    super.initState();
    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        Navigator.pop(context);
      }
    });
  }

  List<Widget> _renderActionButton(
    CustomAppTheme customAppTheme,
    QuickActionPosition position,
    QuickActionData quickAction,
  ) {
    double bottom;
    double? left;
    double? right;

    switch (position) {
      case QuickActionPosition.left:
        bottom = 136;
        left = 60;
        right = null;
        break;
      case QuickActionPosition.middle:
        bottom = 168;
        left = MediaQuery.of(context).size.width / 2 - 32;
        right = null;
        break;
      case QuickActionPosition.right:
        bottom = 136;
        left = null;
        right = 60;
        break;
    }

    return [
      Positioned(
        bottom: bottom,
        left: left,
        right: right,
        child: SlideTransition(
          position: _slideAnimation,
          child: InkWell(
            splashColor: Colors.black,
            onTap: quickAction.enable
                ? () {
                    Navigator.pop(context);
                    quickAction.onPressed();
                  }
                : () {},
            child: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: quickAction.enable
                    ? quickAction.color
                    : customAppTheme.colorsPalette.neutral2,
              ),
              child: Center(
                child: Icon(
                  quickAction.icon,
                  color: quickAction.iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: left == null ? null : left - 60,
        bottom: bottom - 28,
        right: right == null ? null : right - 60,
        child: SlideTransition(
          position: _textSlideAnimation,
          child: SizedBox(
            width: 184,
            child: Text(
              quickAction.label,
              style: customAppTheme.textStyles.bodyMedium.copyWith(
                color: quickAction.enable
                    ? null
                    : customAppTheme.colorsPalette.neutral2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    QuickActionData defaultAction = QuickActionData(
      icon: ThanosIcons.buttonsMore,
      color: ref.watch(appThemeProvider).colorsPalette.neutral2,
      label: 'Add action',
      onPressed: () {},
      iconColor: ref
          .watch(appThemeProvider)
          .colorsPalette
          .white, //TODO: Add function to add new action
    );

    QuickActionData defaultDisableAction = QuickActionData(
      icon: ThanosIcons.buttonsMore,
      color: ref.watch(appThemeProvider).colorsPalette.primary7,
      label: 'Add action',
      enable: false,
      onPressed: () {},
      iconColor: ref
          .watch(appThemeProvider)
          .colorsPalette
          .white, //TODO: Add function to add new action
    );

    return WillPopScope(
      onWillPop: () async {
        await _animationController.reverse();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              FadeTransition(
                opacity: _opacityAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: customAppTheme.colorsPalette.white,
                  child: Stack(
                    children: [
                      ..._renderActionButton(
                        customAppTheme,
                        QuickActionPosition.left,
                        widget.left ?? defaultAction,
                      ),
                      ..._renderActionButton(
                        customAppTheme,
                        QuickActionPosition.middle,
                        widget.middle ?? defaultDisableAction,
                      ),
                      ..._renderActionButton(
                        customAppTheme,
                        QuickActionPosition.right,
                        widget.right ?? defaultDisableAction,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 28.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: customAppTheme.colorsPalette.white,
                          ),
                          child: RotationTransition(
                            turns: _spinAnimation,
                            child: Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: customAppTheme.colorsPalette.neutral2,
                                borderRadius: BorderRadius.circular(44),
                              ),
                              child: InkWell(
                                customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(44),
                                ),
                                onTap: () {
                                  _animationController.reverse();
                                },
                                child: const Center(
                                  child: Icon(ThanosIcons.buttonsMore),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
