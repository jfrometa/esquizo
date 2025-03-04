import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/menu/menu_providers.dart';

class MenuTabBar extends ConsumerStatefulWidget {
  final TabController tabController;
  final Function(int) onTabChanged;

  const MenuTabBar({
    Key? key,
    required this.tabController,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  MenuTabBarState createState() => MenuTabBarState();
}

class MenuTabBarState extends ConsumerState<MenuTabBar> {
  // Cache tab items to avoid rebuilding them frequently
  late final List<Widget> _tabItems;
  
  @override
  void initState() {
    super.initState();
    _initTabItems();
    
    // Listen for tab controller changes to update active state
    widget.tabController.addListener(_handleTabChange);
  }
  
  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    super.dispose();
  }
  
  void _handleTabChange() {
    if (!widget.tabController.indexIsChanging) {
      // Force rebuild only when tab changes
      setState(() {});
    }
  }
  
  void _initTabItems() {
    _tabItems = [
      _buildTabItem(Icons.restaurant, 'Dishes', 0),
      _buildTabItem(Icons.lunch_dining, 'Meal Plans', 1),
      _buildTabItem(Icons.food_bank, 'Catering', 2),
      _buildTabItem(Icons.star, 'Special', 3),
    ];
  }

  Widget _buildTabItem(IconData icon, String label, int index) {
    return Tab(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final enabled = ref.watch(tabsEnabledProvider);
    
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: TabBar(
          controller: widget.tabController,
          onTap: (index) {
            if (enabled) {
              widget.onTabChanged(index);
              HapticFeedback.selectionClick();
            }
          },
          tabs: _tabItems,
          dividerHeight: 0,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: enabled ? colorScheme.primary : colorScheme.surfaceVariant,
            boxShadow: enabled 
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
          ),
          labelColor: enabled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant.withOpacity(0.5),
          unselectedLabelColor: colorScheme.onSurfaceVariant.withOpacity(enabled ? 1.0 : 0.5),
          labelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: theme.textTheme.labelLarge,
          indicatorSize: TabBarIndicatorSize.tab,
          padding: const EdgeInsets.all(4),
          splashBorderRadius: BorderRadius.circular(100),
          labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          tabAlignment: TabAlignment.fill,
          overlayColor: MaterialStateProperty.resolveWith(
            (states) {
              if (!enabled) return Colors.transparent;
              if (states.contains(MaterialState.hovered)) {
                return colorScheme.primary.withOpacity(0.1);
              }
              if (states.contains(MaterialState.pressed)) {
                return colorScheme.primary.withOpacity(0.2);
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}