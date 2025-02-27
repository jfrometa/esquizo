import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class SearchCard extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final String? hintText;
  final bool autofocus;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final bool showClearButton;

  const SearchCard({
    Key? key,
    required this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.hintText,
    this.autofocus = false,
    this.controller,
    this.onClear,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(_updateClearButtonVisibility);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _updateClearButtonVisibility() {
    setState(() {
      _showClearButton = _controller.text.isNotEmpty && widget.showClearButton;
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Adapt colors based on theme mode
    final Color cardColor = isDarkMode
        ? ColorsPaletteRedonda.deepBrown.withOpacity(0.1)
        : ColorsPaletteRedonda.white;

    final Color hintColor = isDarkMode ? Colors.grey[400]! : Colors.grey[500]!;

    final Color textColor =
        isDarkMode ? Colors.white : ColorsPaletteRedonda.deepBrown;

    return Card(
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        height: 56,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
          ),
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            suffixIconColor: ColorsPaletteRedonda.primary,
            focusColor: ColorsPaletteRedonda.primary,
            hintText: widget.hintText ?? 'Buscar platos...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: hintColor),
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search,
                color: _focusNode.hasFocus
                    ? ColorsPaletteRedonda.primary
                    : Colors.grey[500],
              ),
            ),
            suffixIcon: _showClearButton
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                    color: Colors.grey[500],
                    tooltip: 'Clear search',
                    splashRadius: 20,
                  )
                : null,
            filled: true,
            fillColor: cardColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: ColorsPaletteRedonda.primary,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
