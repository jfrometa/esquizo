import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/screens/in_app/subscriptions/actions/actions_overlay_content.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionsModal extends ConsumerStatefulWidget {
  const ActionsModal({
    super.key,
    required this.actions,
  });
  final List<ActionData> actions;

  @override
  _ActionsModalState createState() => _ActionsModalState();
}

class _ActionsModalState extends ConsumerState<ActionsModal> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(child: Container()),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: customAppTheme.colorsPalette.white,
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    color: customAppTheme.colorsPalette.primary40,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, i) => InkWell(
                      splashColor: Colors.black,
                      onTap: () async {
                        await context.router.pop();
                        widget.actions[i].onPressed();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              widget.actions[i].icon,
                              color: widget.actions[i].color,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              widget.actions[i].label,
                              style: customAppTheme.textStyles.headlineMedium
                                  .copyWith(
                                color: widget.actions[i].color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    separatorBuilder: (context, i) =>
                        const SizedBox(height: 16),
                    itemCount: widget.actions.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
