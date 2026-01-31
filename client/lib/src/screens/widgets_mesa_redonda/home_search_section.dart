import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/search_card.dart';

class HomeSearchSection extends StatefulWidget {
  final Function(String) onSearch;
  final List<String> recentSearches;
  final Function(String) onRecentSearchTap;
  final VoidCallback? onFilterTap;
  final bool showRecentSearches;

  const HomeSearchSection({
    super.key,
    required this.onSearch,
    this.recentSearches = const [],
    required this.onRecentSearchTap,
    this.onFilterTap,
    this.showRecentSearches = true,
  });

  @override
  State<HomeSearchSection> createState() => _HomeSearchSectionState();
}

class _HomeSearchSectionState extends State<HomeSearchSection>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SearchCard(
                  onChanged: widget.onSearch,
                  focusNode: _focusNode,
                  onSubmitted: (value) {
                    widget.onSearch(value);
                    FocusScope.of(context).unfocus();
                    HapticFeedback.lightImpact();
                  },
                  hintText: "Search for dishes, caterers, or cuisines...",
                ),
              ),
              if (widget.onFilterTap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () {
                        widget.onFilterTap!();
                        HapticFeedback.mediumImpact();
                      },
                      tooltip: 'Filters',
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Recent searches section with slide animation
        if (widget.showRecentSearches && widget.recentSearches.isNotEmpty)
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Searches',
                          style: theme.textTheme.titleSmall!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Implement clear recent searches
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Clear',
                              style: TextStyle(color: colorScheme.primary)),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.recentSearches.map((search) {
                      return InkWell(
                        onTap: () {
                          widget.onRecentSearchTap(search);
                          HapticFeedback.selectionClick();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                search,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
