import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/menu/menu_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/search/material_search_bar.dart';

// Extract placeholder to a separate const widget for better performance
class _EmptySearchPlaceholder extends StatelessWidget {
  const _EmptySearchPlaceholder();
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Search for dishes, categories, or ingredients',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted drag handle as a const widget
const _DragHandle = Padding(
  padding: EdgeInsets.symmetric(vertical: 12),
  child: Center(
    child: SizedBox(
      width: 40,
      height: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
      ),
    ),
  ),
);

class MenuSearchInterface extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmitted;
  final VoidCallback onFilterPressed;
  final VoidCallback onClear;
  final bool isSearching;
  final Widget? searchResults;

  // Constructor with const for optimization
  const MenuSearchInterface({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onFilterPressed,
    required this.onClear,
    required this.isSearching,
    this.searchResults,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);
    
    // Only watch recent searches when needed
    final bool hasFocus = focusNode.hasFocus;
    final List<String> recentSearches = hasFocus && !isSearching 
        ? ref.watch(menuRecentSearchesProvider)
        : [];
    
    // Use memoization for the title row to avoid rebuilds
    final titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Search Menu',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
      ],
    );
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle - extracted to a const widget
          _DragHandle,
          
          // Title and close button - pre-built above
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: titleRow,
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: MaterialSearchBar(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: onSubmitted,
              onFilterPressed: onFilterPressed,
              onClear: onClear,
              isSearching: isSearching,
              showFilterButton: !isSearching,
              // autofocus: true,
            ),
          ),
          
          // Recent searches - conditionally rendered
          if (recentSearches.isNotEmpty)
            _buildRecentSearches(context, theme, recentSearches, ref),
          
          // Content area - reuse existing child when possible
          if (searchResults != null)
            Expanded(child: searchResults!)
          else
            const Expanded(
              child: _EmptySearchPlaceholder(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildRecentSearches(BuildContext context, ThemeData theme, List<String> recentSearches, WidgetRef ref) {
    // Pre-calculate button style to avoid recalculation during layout
    final buttonStyle = TextButton.styleFrom(
      visualDensity: VisualDensity.compact,
      foregroundColor: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      minimumSize: const Size(40, 24),
    );
    
    // Pre-calculate text style
    final titleStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: titleStyle),
              TextButton.icon(
                onPressed: () {
                  ref.read(menuRecentSearchesProvider.notifier).clearSearches();
                  HapticFeedback.selectionClick();
                },
                style: buttonStyle,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSearchChips(theme, recentSearches),
        ],
      ),
    );
  }
  
  // Extracted method to build search chips for better organization
  Widget _buildSearchChips(ThemeData theme, List<String> recentSearches) {
    // Pre-calculate chip appearance for consistency
    final chipShadowColor = theme.colorScheme.shadow.withOpacity(0.2);
    final chipSurfaceTint = theme.colorScheme.surfaceTint;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: recentSearches.map((search) {
        return InputChip(
          label: Text(search),
          onPressed: () {
            controller.text = search;
            onSubmitted(search);
          },
          avatar: const Icon(
            Icons.history,
            size: 16,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: 0,
          shadowColor: chipShadowColor,
          surfaceTintColor: chipSurfaceTint,
        );
      }).toList(),
    );
  }
}