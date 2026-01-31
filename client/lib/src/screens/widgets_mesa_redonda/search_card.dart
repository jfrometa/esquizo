import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.hintText,
    this.autofocus = false,
    this.controller,
    this.onClear,
    this.showClearButton = true,
  });

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

    return Card(
      color: colorScheme.surfaceContainerHighest,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Buscar platos...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search,
              color: _focusNode.hasFocus
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSearch,
                  color: colorScheme.onSurfaceVariant,
                  tooltip: 'Clear search',
                  splashRadius: 20,
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
