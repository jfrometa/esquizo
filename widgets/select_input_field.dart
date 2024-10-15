import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectInputField<T> extends StatefulWidget {
  const SelectInputField({
    super.key,
    this.label,
    required this.items,
    this.initialValue,
    this.value,
    this.validator,
    this.focusNode,
    this.onChanged,
  });

  final String? label;
  final T? initialValue;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final String? Function(dynamic)? validator;
  final FocusNode? focusNode;
  final dynamic Function(dynamic)? onChanged;

  @override
  State createState() => _SelectInputFieldState<T>();
}

class _SelectInputFieldState<T> extends State<SelectInputField> {
  T? value;

  @override
  void initState() {
    super.initState();

    value = widget.initialValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      value = widget.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        value = widget.value;
        final customAppTheme = ref.watch(appThemeProvider);
        return SizedBox(
          height: 80,
          child: DropdownButtonFormField<T>(
            icon: Container(),
            focusNode: widget.focusNode,
            validator: widget.validator,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: customAppTheme.colorsPalette.secondary,
                ),
              ),
              suffixIcon: const Icon(ThanosIcons.buttonsDropdown),
              labelText: widget.label,
              alignLabelWithHint: true,
              labelStyle: customAppTheme.textStyles.headlineLarge.copyWith(
                height: 0.3,
                color: customAppTheme.colorsPalette.secondary40,
              ),
            ),
            style: customAppTheme.textStyles.headlineLarge,
            value: value,
            onChanged: (T? newValue) {
              setState(() {
                value = newValue;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(newValue);
              }
            },
            items: widget.items! as List<DropdownMenuItem<T>>,
          ),
        );
      },
    );
  }
}
