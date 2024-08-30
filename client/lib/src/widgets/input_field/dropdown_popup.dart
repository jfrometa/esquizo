import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/selector_modal.dart';
import 'package:starter_architecture_flutter_firebase/widgets/radio_button.dart';
import 'package:flutter/material.dart';

class DropdownPopup<T> extends PopupRoute {
  DropdownPopup({
    required this.customAppTheme,
    required this.items,
    required this.onSelected,
    this.topOffset = 0,
    this.selectedValue,
  }) : totalHeight = (items.length * 57) - 1;
  final CustomAppTheme customAppTheme;
  final List<SelectorModalItem<T>> items;
  final Function(SelectorModalItem<T>) onSelected;
  final double? topOffset;
  final T? selectedValue;
  final double totalHeight;

  @override
  Color? get barrierColor => const Color(0x00000000);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'DROPDOWN_BARRIER_LABEL';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    double topOffset;
    topOffset = topOffset;
    if (topOffset + totalHeight >= MediaQuery.of(context).size.height) {
      topOffset = MediaQuery.of(context).size.height - totalHeight - 40;
    }

    return DefaultTextStyle(
      style: customAppTheme.textStyles.bodyLarge,
      child: Padding(
        padding: EdgeInsets.only(top: topOffset),
        child: Wrap(
          children: [
            SizeTransition(
              sizeFactor: animation,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: customAppTheme.colorsPalette.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: customAppTheme.colorsPalette.secondary40,
                      )
                    ],
                  ),
                  width: double.maxFinite,
                  height: totalHeight,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) => SizedBox(
                      height: 56,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            onSelected(items[index]);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    items[index].label,
                                    style: items[index].value == selectedValue
                                        ? customAppTheme
                                            .textStyles.headlineMedium
                                        : customAppTheme.textStyles.bodyLarge
                                            .copyWith(
                                            color: customAppTheme
                                                .colorsPalette.secondary70,
                                          ),
                                  ),
                                ),
                                RadioButton(
                                  onChanged: (_) {},
                                  value: items[index].value.toString(),
                                  groupValue: selectedValue.toString(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    separatorBuilder: (_, __) => Container(
                      height: 1,
                      color: customAppTheme.colorsPalette.primary7,
                    ),
                    itemCount: items.length,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);
}
