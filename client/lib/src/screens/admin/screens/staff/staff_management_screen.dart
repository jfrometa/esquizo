import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/staff/staff_kitchen_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/staff/staff_waiter_screen.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      title: 'Kitchen',
      icon: Icons.kitchen_outlined,
      selectedIcon: Icons.kitchen,
      screen: const StaffKitchenScreen(),
    ),
    _NavigationItem(
      title: 'Waiter',
      icon: Icons.room_service_outlined,
      selectedIcon: Icons.room_service,
      screen: const StaffWaiterTableSelectScreen(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 1100;
    final isTablet = size.width >= 600;

    if (isDesktop) {
      return _buildDesktopLayout(colorScheme);
    } else if (isTablet) {
      return _buildTabletLayout(colorScheme);
    } else {
      return _buildMobileLayout(colorScheme);
    }
  }

  Widget _buildDesktopLayout(ColorScheme colorScheme) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            extended: true,
            backgroundColor: colorScheme.surface,
            selectedIconTheme: IconThemeData(color: colorScheme.primary),
            selectedLabelTextStyle: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            unselectedIconTheme:
                IconThemeData(color: colorScheme.onSurfaceVariant),
            unselectedLabelTextStyle:
                TextStyle(color: colorScheme.onSurfaceVariant),
            destinations: _navigationItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.title),
                  ),
                )
                .toList(),
          ),

          // Vertical divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),

          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _navigationItems.map((item) => item.screen).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(ColorScheme colorScheme) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail (compact)
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.selected,
            backgroundColor: colorScheme.surface,
            selectedIconTheme: IconThemeData(color: colorScheme.primary),
            selectedLabelTextStyle: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            unselectedIconTheme:
                IconThemeData(color: colorScheme.onSurfaceVariant),
            unselectedLabelTextStyle:
                TextStyle(color: colorScheme.onSurfaceVariant),
            destinations: _navigationItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.title),
                  ),
                )
                .toList(),
          ),

          // Vertical divider
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colorScheme.outlineVariant,
          ),

          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _navigationItems.map((item) => item.screen).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(ColorScheme colorScheme) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _navigationItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.title,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavigationItem {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;

  const _NavigationItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}
