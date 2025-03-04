import 'package:flutter/material.dart';

/// A Material 3 compliant search bar that supports idle, focused and inputting states
class MaterialSearchBar extends StatelessWidget {
  /// Text controller for the search field
  final TextEditingController controller;
  
  /// Focus node to manage the search field's focus state
  final FocusNode focusNode;
  
  /// Callback when search is submitted
  final Function(String) onSubmitted;
  
  /// Callback when filter button is tapped
  final VoidCallback onFilterPressed;
  
  /// Callback when clear button is tapped
  final VoidCallback onClear;
  
  /// Whether the user is currently searching (has input)
  final bool isSearching;
  
  /// Whether to show the filter button
  final bool showFilterButton;
  
  /// Optional hint text for the search field
  final String? hintText;

  const MaterialSearchBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onFilterPressed,
    required this.onClear,
    required this.isSearching,
    this.showFilterButton = true,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      elevation: 1,
      shadowColor: Colors.black12,
      surfaceTintColor: colorScheme.surfaceTint,
      borderRadius: BorderRadius.circular(isSearching ? 16 : 28),
      clipBehavior: Clip.antiAlias,
      color: isSearching 
          ? colorScheme.surface 
          : colorScheme.surfaceVariant.withOpacity(0.9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isSearching ? 8.0 : 16.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Leading icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSearching 
                    ? Colors.transparent 
                    : colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  Icons.search,
                  color: isSearching 
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
                  size: 22,
                ),
              ),
            ),
            
            // Search field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText ?? 'Search for dishes, categories...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSubmitted,
                  cursorColor: colorScheme.primary,
                  cursorWidth: 1.5,
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
            ),
            
            // Trailing icon (clear or filter)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: isSearching
                  // Clear button
                  ? IconButton(
                      key: const ValueKey('clear'),
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Clear search',
                      style: IconButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
                        minimumSize: const Size(40, 40),
                        maximumSize: const Size(40, 40),
                      ),
                      onPressed: onClear,
                    )
                  // Filter button
                  : showFilterButton
                      ? IconButton(
                          key: const ValueKey('filter'),
                          icon: const Icon(Icons.tune),
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Filter',
                          style: IconButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            backgroundColor: colorScheme.surfaceVariant,
                            minimumSize: const Size(40, 40),
                            maximumSize: const Size(40, 40),
                          ),
                          onPressed: onFilterPressed,
                        )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}