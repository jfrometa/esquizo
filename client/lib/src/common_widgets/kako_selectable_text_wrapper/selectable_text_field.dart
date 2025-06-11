// lib/widgets/selectable_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectableTextField extends StatefulWidget {
  // CORE CONTROLLERS
  final TextEditingController controller;
  final FocusNode? focusNode;

  // DECORATION AND STYLING
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;

  // KEYBOARD AND INPUT BEHAVIOR
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool obscureText;
  final String obscuringCharacter;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;

  // FUNCTIONALITY AND INTERACTION
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final GestureTapCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final List<TextInputFormatter>? inputFormatters;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;

  const SelectableTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.decoration,
    this.style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.maxLengthEnforcement,
    this.inputFormatters,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection,
    this.scrollController,
    this.scrollPhysics,
  });

  @override
  SelectableTextFieldState createState() => SelectableTextFieldState();
}

class SelectableTextFieldState extends State<SelectableTextField> {
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    // If it should start focused, enter editing mode immediately.
    if (_focusNode.hasFocus) {
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    // Only dispose the focus node if it was created internally.
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    // A readOnly field should not enter editing mode.
    if (_focusNode.hasFocus && !_isEditing && !widget.readOnly) {
      setState(() {
        _isEditing = true;
      });
    } else if (!_focusNode.hasFocus && _isEditing) {
      setState(() {
        _isEditing = false;
      });
      // This mimics the behavior of onSubmitted when focus is lost.
      if (widget.onSubmitted != null) {
        widget.onSubmitted!(widget.controller.text);
      }
    }
  }

  // Gets the effective decoration for the display mode.
  InputDecoration get _effectiveDecoration {
    final hintText = widget.decoration?.hintText;
    // When not editing, if the text is empty, we want the hint to appear as the main text.
    // So, we create a decoration without the hint to prevent it from showing below.
    if (widget.controller.text.isEmpty && hintText != null) {
      return (widget.decoration ?? const InputDecoration())
          .copyWith(hintText: '');
    }
    return widget.decoration ?? const InputDecoration();
  }

  // Gets the effective style for the display mode.
  TextStyle? get _effectiveTextStyle {
    // If the controller is empty, use the hintStyle for the displayed text.
    if (widget.controller.text.isEmpty) {
      return widget.decoration?.hintStyle ?? widget.style;
    }
    return widget.style;
  }

  @override
  Widget build(BuildContext context) {
    // If we are in editing mode or the field is readOnly, show the actual TextField.
    if (_isEditing || widget.readOnly) {
      return TextField(
        // Pass all the properties from the widget to the TextField
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: widget.decoration,
        style: widget.style,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        textDirection: widget.textDirection,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        autocorrect: widget.autocorrect,
        obscureText: widget.obscureText,
        obscuringCharacter: widget.obscuringCharacter,
        smartDashesType: widget.smartDashesType,
        smartQuotesType: widget.smartQuotesType,
        enableSuggestions: widget.enableSuggestions,
        onChanged: widget.onChanged,
        onSubmitted: (value) {
          // Unfocus when submitted, which will trigger the switch back to display mode.
          _focusNode.unfocus();
          widget.onSubmitted?.call(value);
        },
        onEditingComplete: widget.onEditingComplete,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        inputFormatters: widget.inputFormatters,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        scrollController: widget.scrollController,
        scrollPhysics: widget.scrollPhysics,
      );
    } else {
      // Otherwise, show the selectable display version.
      return GestureDetector(
        onTap: () {
          if (widget.enabled) {
            FocusScope.of(context).requestFocus(_focusNode);
            widget.onTap?.call();
          }
        },
        child: InputDecorator(
          decoration: _effectiveDecoration,
          isFocused: _focusNode.hasFocus,
          isEmpty: widget.controller.text.isEmpty,
          child: SelectableText(
            widget.controller.text.isEmpty
                ? (widget.decoration?.hintText ?? '')
                : widget.controller.text,
            style: _effectiveTextStyle,
            textAlign: widget.textAlign,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            scrollPhysics: widget.scrollPhysics,
          ),
        ),
      );
    }
  }
}
