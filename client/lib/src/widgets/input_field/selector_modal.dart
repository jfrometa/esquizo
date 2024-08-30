import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/animated_button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/header.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/input_field.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/radio_button.dart';
import 'package:starter_architecture_flutter_firebase/widgets/search_bar.dart'
    as Search;
import 'package:flutter/material.dart';

class SelectorModalItem<T> {
  SelectorModalItem({
    required this.title,
    required this.value,
    this.leading,
    required this.label,
  });
  final Widget? leading;
  final String title;
  final T value;
  final String label;
}

class SelectorModal<T> extends StatefulWidget {
  const SelectorModal({
    super.key,
    required this.customAppTheme,
    required this.title,
    required this.items,
    required this.selectedValue,
    this.onSelected,
    this.otherOption = false,
  });

  final CustomAppTheme customAppTheme;
  final String title;
  final List<SelectorModalItem<T>> items;
  final T? selectedValue;
  final Function(SelectorModalItem<T> item)? onSelected;
  final bool otherOption;

  @override
  State createState() => _SelectorModalState<T>();
}

class _SelectorModalState<T> extends State<SelectorModal<T>> {
  T? _groupValue;
  late List<SelectorModalItem<T>> _items;
  final String _otherOptionValue = '!OtherOptionValue';
  bool _buttonEnabled = false;
  late TextEditingController _otherValueController;

  _select(SelectorModalItem<T> item, BuildContext context) {
    setState(() {
      _groupValue = item.value;
    });
    if (widget.onSelected != null) {
      widget.onSelected!(item);
    }
    Navigator.pop(context);
  }

  _selectOtherOption() {
    setState(() {
      _groupValue = _otherOptionValue as T;
    });
  }

  @override
  void initState() {
    super.initState();

    _otherValueController = TextEditingController();
    _items = widget.items;
    _groupValue = widget.selectedValue;
  }

  @override
  void dispose() {
    _otherValueController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.customAppTheme.colorsPalette.white,
      appBar: Header(
        context: context,
        leading: IconButton(
          icon: const Icon(ThanosIcons.buttonsBack),
          onPressed: () async {
            await context.router.pop();
          },
          color: widget.customAppTheme.colorsPalette.secondary,
        ),
        title: widget.title,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Search.SearchBar(
              search: (value) {
                setState(() {
                  _items = widget.items
                      .where(
                        (item) => item.title
                            .toLowerCase()
                            .contains(value.toLowerCase()),
                      )
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ..._items.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: InkWell(
                          onTap: () {
                            _select(entry.value, context);
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: entry.key + 1 < widget.items.length
                                  ? Border(
                                      bottom: BorderSide(
                                        color: widget.customAppTheme
                                            .colorsPalette.secondary
                                            .withOpacity(0.3),
                                        width: 0.5,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: entry.value.leading != null ? 30 : 0,
                                  child: entry.value.leading != null
                                      ? entry.value.leading!
                                      : Container(),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: entry.value.leading != null
                                          ? 24.0
                                          : 0,
                                    ),
                                    child: Semantics(
                                      label: 'country: ${entry.value.title}',
                                      child: Text(
                                        entry.value.title,
                                        style: widget.customAppTheme.textStyles
                                            .headlineLarge,
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                ),
                                RadioButton(
                                  groupValue: _groupValue.toString(),
                                  onChanged: (_) {
                                    _select(entry.value, context);
                                  },
                                  value: entry.value.value.toString(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                widget.otherOption
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: InkWell(
                          onTap: _selectOtherOption,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: widget
                                      .customAppTheme.colorsPalette.secondary
                                      .withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(),
                                    child: Text(
                                      'Other',
                                      style: widget.customAppTheme.textStyles
                                          .headlineLarge,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                RadioButton(
                                  groupValue: _groupValue.toString(),
                                  onChanged: (_) {
                                    _selectOtherOption();
                                  },
                                  value: _otherOptionValue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
                _groupValue.toString() == _otherOptionValue
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: InputField(
                          controller: _otherValueController,
                          label: widget.title,
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              setState(() {
                                _buttonEnabled = true;
                              });
                            } else {
                              setState(() {
                                _buttonEnabled = false;
                              });
                            }
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          AnimatedButton(
            buttonEnabled: _buttonEnabled,
            text: Text('button.continue'.t()),
            onPressed: () async {
              if (widget.onSelected != null) {
                widget.onSelected!(
                  SelectorModalItem(
                    title: _otherValueController.text,
                    value: _otherValueController.text as T,
                    label: _otherValueController.text,
                  ),
                );
              }
              await context.router.pop();
            },
          ),
        ],
      ),
    );
  }
}
