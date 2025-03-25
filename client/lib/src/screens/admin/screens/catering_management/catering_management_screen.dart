import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_category_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_dashboard_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_item_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_order_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/catering_package_screen.dart';

class CateringManagementScreen extends ConsumerStatefulWidget {
  const CateringManagementScreen({super.key});

  @override
  ConsumerState<CateringManagementScreen> createState() =>
      _CateringManagementScreenState();
}

class _CateringManagementScreenState
    extends ConsumerState<CateringManagementScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      screen: const CateringDashboardScreen(),
    ),
    _NavigationItem(
      title: 'Orders',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      screen: const CateringOrdersScreen(),
    ),
    _NavigationItem(
      title: 'Packages',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      screen: const CateringPackageScreen(),
    ),
    _NavigationItem(
      title: 'Items',
      icon: Icons.restaurant_menu_outlined,
      selectedIcon: Icons.restaurant_menu,
      screen: const CateringItemScreen(),
    ),
    _NavigationItem(
      title: 'Categories',
      icon: Icons.category_outlined,
      selectedIcon: Icons.category,
      screen: const CateringCategoryScreen(),
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
          // // Navigation rail
          // NavigationRail(
          //   selectedIndex: _selectedIndex,
          //   onDestinationSelected: _onItemTapped,
          //   extended: true,
          //   backgroundColor: colorScheme.surface,
          //   selectedIconTheme: IconThemeData(color: colorScheme.primary),
          //   selectedLabelTextStyle: TextStyle(
          //     color: colorScheme.primary,
          //     fontWeight: FontWeight.bold,
          //   ),
          //   unselectedIconTheme:
          //       IconThemeData(color: colorScheme.onSurfaceVariant),
          //   unselectedLabelTextStyle:
          //       TextStyle(color: colorScheme.onSurfaceVariant),
          //   destinations: _navigationItems
          //       .map(
          //         (item) => NavigationRailDestination(
          //           icon: Icon(item.icon),
          //           selectedIcon: Icon(item.selectedIcon),
          //           label: Text(item.title),
          //         ),
          //       )
          //       .toList(),
          // ),

          // // Vertical divider
          // VerticalDivider(
          //   width: 1,
          //   thickness: 1,
          //   color: colorScheme.outlineVariant,
          // ),

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
          // NavigationRail(
          //   selectedIndex: _selectedIndex,
          //   onDestinationSelected: _onItemTapped,
          //   labelType: NavigationRailLabelType.selected,
          //   backgroundColor: colorScheme.surface,
          //   selectedIconTheme: IconThemeData(color: colorScheme.primary),
          //   selectedLabelTextStyle: TextStyle(
          //     color: colorScheme.primary,
          //     fontWeight: FontWeight.bold,
          //   ),
          //   unselectedIconTheme:
          //       IconThemeData(color: colorScheme.onSurfaceVariant),
          //   unselectedLabelTextStyle:
          //       TextStyle(color: colorScheme.onSurfaceVariant),
          //   destinations: _navigationItems
          //       .map(
          //         (item) => NavigationRailDestination(
          //           icon: Icon(item.icon),
          //           selectedIcon: Icon(item.selectedIcon),
          //           label: Text(item.title),
          //         ),
          //       )
          //       .toList(),
          // ),

          // // Vertical divider
          // VerticalDivider(
          //   width: 1,
          //   thickness: 1,
          //   color: colorScheme.outlineVariant,
          // ),

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
