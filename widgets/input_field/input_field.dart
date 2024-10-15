import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/icons/thanos_icons.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/date_picker_modal_screen.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/dropdown_popup.dart';
import 'package:starter_architecture_flutter_firebase/widgets/input_field/selector_modal.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

class InputField<T> extends StatefulWidget {
  const InputField({
    super.key,
    required this.label,
    this.validator,
    this.controller,
    this.focusNode,
    this.onEditingComplete,
    this.onChanged,
    this.isPassword = false,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.suffixIcon,
    this.successText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.isSelector = false,
    this.scrollPadding = const EdgeInsets.only(bottom: 8),
  });
  factory InputField.dateSelector({
    required String label,
    String? Function(String?)? validator,
    required TextEditingController controller,
    required BuildContext context,
    required CustomAppTheme customAppTheme,
    Function(DateTime)? onSelected,
    bool Function(DateTime)? dateValidator,
  }) {
    return InputField(
      isSelector: true,
      suffixIcon: const Icon(ThanosIcons.buttonsCalendar),
      controller: controller,
      validator: validator,
      onTap: () async => context.router.push(
        DatePickerModalRoute(
          controller: DatePickerController(
            initialYear: DateTime.now().year,
            initialMonth: DateTime.now().month,
            initialDay: DateTime.now().day,
          ),
          validator: dateValidator,
          onSelect: (date) {
            controller.text =
                "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
            if (onSelected != null) {
              onSelected(date);
            }
          },
          customAppTheme: customAppTheme,
          label: label,
          description: 'signup.step_3b.dob_text'.t(),
        ),
      ),
      label: label,
    );
  }

  factory InputField.selector({
    required GlobalKey? key,
    required String label,
    required String title,
    required TextEditingController controller,
    required BuildContext context,
    required CustomAppTheme customAppTheme,
    required List<SelectorModalItem<T>> items,
    T? selectedValue,
    Function(SelectorModalItem<T> item)? onSelected,
    bool otherOption = false,
  }) {
    if (items.length > 6) {
      return InputField<T>.modalItemSelector(
        label: label,
        title: title,
        controller: controller,
        context: context,
        customAppTheme: customAppTheme,
        items: items,
        onSelected: onSelected,
        otherOption: otherOption,
        selectedValue: selectedValue,
      );
    }
    return InputField<T>.dropdownSelector(
      key: key,
      label: label,
      controller: controller,
      context: context,
      customAppTheme: customAppTheme,
      items: items,
      onSelected: onSelected,
      selectedValue: selectedValue,
    );
  }

  factory InputField.dropdownSelector({
    required GlobalKey? key,
    required String label,
    String? Function(String?)? validator,
    required TextEditingController controller,
    required BuildContext context,
    required CustomAppTheme customAppTheme,
    required List<SelectorModalItem<T>> items,
    T? selectedValue,
    Function(SelectorModalItem<T> item)? onSelected,
  }) {
    return InputField<T>(
      key: key,
      isSelector: true,
      suffixIcon: const Icon(ThanosIcons.buttonsDropdown),
      label: label,
      readOnly: true,
      controller: controller,
      validator: validator,
      onTap: () async => Navigator.push(
        context,
        DropdownPopup<T>(
          customAppTheme: customAppTheme,
          items: items,
          selectedValue: selectedValue,
          topOffset: key != null ? key.globalPaintBounds?.top : 0,
          onSelected: (item) {
            controller.text = item.label;
            if (onSelected != null) {
              onSelected(item);
            }
          },
        ),
      ),
    );
  }

  factory InputField.pageItemSelector({
    required String label,
    bool readOnly = false,
    String? Function(String?)? validator,
    required TextEditingController controller,
    required BuildContext context,
    required PageRouteInfo pageRouteInfo,
  }) {
    return InputField<T>(
      isSelector: true,
      suffixIcon: const Icon(ThanosIcons.buttonsDropdown),
      label: label,
      readOnly: readOnly,
      controller: controller,
      validator: validator,
      onTap: () async => context.router.push(pageRouteInfo),
    );
  }

  factory InputField.modalItemSelector({
    required String label,
    required String title,
    String? Function(String?)? validator,
    bool enabled = true,
    bool readOnly = false,
    required TextEditingController controller,
    required BuildContext context,
    required CustomAppTheme customAppTheme,
    required List<SelectorModalItem<T>> items,
    T? selectedValue,
    Function(SelectorModalItem<T> item)? onSelected,
    bool otherOption = false,
  }) {
    return InputField<T>(
      isSelector: true,
      enabled: enabled,
      suffixIcon: const Icon(ThanosIcons.buttonsDropdown),
      label: label,
      readOnly: readOnly,
      controller: controller,
      validator: validator,
      onTap: () async => showModalBottomSheet(
        barrierColor: customAppTheme.colorsPalette.white,
        useSafeArea: true,
        useRootNavigator: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => SelectorModal<T>(
          selectedValue: selectedValue,
          customAppTheme: customAppTheme,
          title: title,
          items: items,
          onSelected: (item) {
            controller.text = item.label;
            if (onSelected != null) {
              onSelected(item);
            }
          },
          otherOption: otherOption,
        ),
      ),
    );
  }
  final bool? autocorrect;
  final bool isSelector;
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final EdgeInsets scrollPadding;
  final FocusNode? focusNode;
  final void Function()? onEditingComplete;
  final void Function(String?)? onChanged;
  final bool isPassword;
  final void Function()? onTap;
  final bool enabled;
  final bool readOnly;
  final Icon? suffixIcon;
  final String? successText;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;

  @override
  State createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();

    _isObscure = widget.isPassword;
  }

  Widget? _renderSuffixIcon(CustomAppTheme customAppTheme) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _isObscure
              ? ThanosIcons.buttonsEyeOpen
              : ThanosIcons.buttonsEyeClosed,
        ),
        onPressed: () {
          setState(() {
            _isObscure = !_isObscure;
          });
        },
      );
    }
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }
    if (widget.successText != null) {
      return Icon(
        ThanosIcons.inputFieldSuccess,
        color: customAppTheme.colorsPalette.positiveAction,
      );
    }
    if (widget.errorText != null) {
      return Icon(
        ThanosIcons.inputFieldError,
        color: customAppTheme.colorsPalette.negativeAction,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final customAppTheme = ref.watch(appThemeProvider);

        final style = widget.readOnly
            ? customAppTheme.textStyles.headlineLarge
                .copyWith(color: customAppTheme.colorsPalette.neutral3)
            : customAppTheme.textStyles.headlineLarge;

        final floatingStyle = widget.readOnly
            ? customAppTheme.textStyles.headlineLarge
                .copyWith(color: customAppTheme.colorsPalette.neutral3)
            : null;

        return SizedBox(
          height: 84,
          child: TextFormField(
            scrollPadding: widget.scrollPadding,
            keyboardType: widget.keyboardType,
            textInputAction: TextInputAction.done,
            readOnly: widget.isSelector ? true : widget.readOnly,
            enabled: widget.enabled,
            onTap: widget.onTap,
            style: style,
            controller: widget.controller,
            focusNode: widget.focusNode,
            validator: widget.validator,
            cursorColor: customAppTheme.colorsPalette.secondary,
            decoration: InputDecoration(
              floatingLabelStyle: floatingStyle,
              focusedErrorBorder: widget.successText != null
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: customAppTheme.colorsPalette.positiveAction,
                      ),
                    )
                  : null,
              errorBorder: widget.successText != null
                  ? UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: customAppTheme.colorsPalette.positiveAction,
                      ),
                    )
                  : null,
              errorStyle: widget.successText != null
                  ? customAppTheme.textStyles.bodyMedium.copyWith(
                      color: customAppTheme.colorsPalette.positiveAction,
                    )
                  : null,
              errorText: widget.successText ?? widget.errorText,
              suffixIcon: _renderSuffixIcon(customAppTheme),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: customAppTheme.colorsPalette.secondary,
                ),
              ),
              labelText: widget.label,
              alignLabelWithHint: true,
              labelStyle: customAppTheme.textStyles.headlineLarge
                  .copyWith(color: customAppTheme.colorsPalette.secondary40),
            ),
            onEditingComplete: widget.onEditingComplete,
            onChanged: widget.onChanged,
            obscureText: _isObscure,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization!,
            autocorrect: widget.autocorrect!,
          ),
        );
      },
    );
  }
}
