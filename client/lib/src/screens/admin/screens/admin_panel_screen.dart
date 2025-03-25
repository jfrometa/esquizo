import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/admin_panel/admin_stats_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';
import 'dart:async';

class AdminPanelScreen extends ConsumerStatefulWidget {
  final Widget child;
  final int initialIndex;

  const AdminPanelScreen({
    super.key,
    required this.child,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<AdminPanelScreen> createState() => AdminPanelScreenState();
}

class AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _refreshTimer;
  bool _isLoading = false;
  late int selectedIndex;

  // Use AdminRoutes to define navigation items
  final List<_AdminNavigationItem> _navigationItems = [
    _AdminNavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: AdminRoutes.getFullPath(AdminRoutes.dashboard),
    ),
    _AdminNavigationItem(
      title: 'Products & Menu',
      icon: Icons.restaurant_menu,
      route: AdminRoutes.getFullPath(AdminRoutes.products),
    ),
    _AdminNavigationItem(
      title: 'Orders',
      icon: Icons.receipt_long,
      route: AdminRoutes.getFullPath(AdminRoutes.orders),
    ),
    _AdminNavigationItem(
      title: 'Tables',
      icon: Icons.table_bar,
      route: AdminRoutes.getFullPath(AdminRoutes.tables),
    ),
    _AdminNavigationItem(
      title: 'Users & Staff',
      icon: Icons.people,
      route: AdminRoutes.getFullPath(AdminRoutes.users),
    ),
    _AdminNavigationItem(
      title: 'Business Settings',
      icon: Icons.settings,
      route: AdminRoutes.getFullPath(AdminRoutes.settings),
    ),
    _AdminNavigationItem(
      title: 'Analytics',
      icon: Icons.bar_chart,
      route: AdminRoutes.getFullPath(AdminRoutes.analytics),
    ),
    _AdminNavigationItem(
      title: 'Meal Plans',
      icon: Icons.lunch_dining,
      route: AdminRoutes.getFullPath(AdminRoutes.mealPlans),
      subroutes: [
        _SubRoute(
          title: 'Meal Plans Management',
          route: AdminRoutes.getFullPath(AdminRoutes.mealPlanManagement),
          icon: Icons.list,
        ),
        _SubRoute(
          title: 'Meal Plan Items',
          route: AdminRoutes.getFullPath(AdminRoutes.mealPlanItems),
          icon: Icons.restaurant_menu,
        ),
        _SubRoute(
          title: 'Analytics',
          route: AdminRoutes.getFullPath(AdminRoutes.mealPlanAnalytics),
          icon: Icons.bar_chart,
        ),
        _SubRoute(
          title: 'Export Reports',
          route: AdminRoutes.getFullPath(AdminRoutes.mealPlanExport),
          icon: Icons.download,
        ),
        _SubRoute(
          title: 'QR Scanner',
          route: AdminRoutes.getFullPath(AdminRoutes.mealPlanScanner),
          icon: Icons.qr_code_scanner,
        ),
        _SubRoute(
          title: 'POS Interface',
          route: AdminRoutes.getFullPath(AdminRoutes.mealPlanPos),
          icon: Icons.point_of_sale,
        ),
      ],
    ),
    _AdminNavigationItem(
      title: 'Catering Management',
      icon: Icons.inventory_2,
      route: AdminRoutes.getFullPath(AdminRoutes.catering),
      subroutes: [
        _SubRoute(
          title: 'Dashboard',
          route: AdminRoutes.getFullPath(AdminRoutes.cateringDashboard),
          icon: Icons.dashboard,
        ),
        _SubRoute(
          title: 'Orders',
          route: AdminRoutes.getFullPath(AdminRoutes.cateringOrders),
          icon: Icons.receipt_long,
        ),
        _SubRoute(
          title: 'Packages',
          route: AdminRoutes.getFullPath(AdminRoutes.cateringPackages),
          icon: Icons.category,
        ),
        _SubRoute(
          title: 'Items',
          route: AdminRoutes.getFullPath(AdminRoutes.cateringItems),
          icon: Icons.food_bank,
        ),
        _SubRoute(
          title: 'Categories',
          route: AdminRoutes.getFullPath(AdminRoutes.cateringCategories),
          icon: Icons.list,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Set the initial index from the widget parameter
    selectedIndex = widget.initialIndex;

    // Set up refresh timer to periodically update data
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Add a method to refresh data
  Future<void> _refreshData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Refresh providers that need real-time updates
      ref.invalidate(orderStatsProvider);
      ref.invalidate(salesStatsProvider);
      ref.invalidate(tableStatsProvider);
      ref.invalidate(recentOrdersProvider);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemSelected(int index) {
    // Update the selected index
    setState(() {
      selectedIndex = index;
    });

    // Navigate using GoRouter with routes from AdminRoutes
    context.go(_navigationItems[index].route);
  }

  void _navigateToSubroute(String route) {
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = ref.watch(isAdminProvider).value;

    // Check if user is authenticated and has admin privileges
    if (authState != AuthState.authenticated || isAdmin != null && !isAdmin) {
      return const UnauthorizedScreen();
    }

    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 1100;
    final isTablet = size.width >= 600;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          // Side navigation
          NavigationRail(
            extended: true,
            selectedIndex: selectedIndex,
            onDestinationSelected: _onItemSelected,
            destinations: _navigationItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.title),
                  ),
                )
                .toList(),
          ),

          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),

          // Main content area
          Expanded(
            child: Column(
              children: [
                _buildDesktopHeader(),

                // Main content with loading indicator
                Expanded(
                  child: Stack(
                    children: [
                      // Main content from the router
                      widget.child,

                      // Loading indicator on top
                      if (_isLoading)
                        const Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    // Similar to desktop but with collapsed NavigationRail
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          NavigationRail(
            extended: false,
            selectedIndex: selectedIndex,
            onDestinationSelected: _onItemSelected,
            destinations: _navigationItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.title),
                  ),
                )
                .toList(),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(_navigationItems[selectedIndex].title),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshData,
                      tooltip: 'Refresh Data',
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle),
                      onPressed: _showUserMenu,
                    ),
                  ],
                ),
                Expanded(
                  child: Stack(
                    children: [
                      widget.child,
                      if (_isLoading)
                        const Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_navigationItems[selectedIndex].title),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _showUserMenu,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ..._navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              // Check if this item has subroutes to render an expandable section
              final hasSubroutes =
                  item.subroutes != null && item.subroutes!.isNotEmpty;

              if (!hasSubroutes) {
                return ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.title),
                  selected: selectedIndex == index,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    _onItemSelected(index);
                  },
                );
              } else {
                // Use ExpansionTile for sections with subroutes
                return ExpansionTile(
                  leading: Icon(item.icon),
                  title: Text(item.title),
                  initiallyExpanded: selectedIndex == index,
                  children: item.subroutes!.map((subroute) {
                    return ListTile(
                      leading: Icon(subroute.icon, size: 20),
                      title: Text(subroute.title),
                      contentPadding: const EdgeInsets.only(left: 32),
                      dense: true,
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        _navigateToSubroute(subroute.route);
                      },
                    );
                  }).toList(),
                );
              }
            }),
          ],
        ),
      ),
      body: Stack(
        children: [
          widget.child,
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex > 4 ? 4 : selectedIndex,
        onTap: (index) {
          if (index == 4) {
            // More menu
            _showMoreOptions();
          } else {
            _onItemSelected(index);
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_navigationItems[0].icon),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(_navigationItems[1].icon),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(_navigationItems[2].icon),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(_navigationItems[3].icon),
            label: 'Tables',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    final item = _navigationItems[selectedIndex];
    final hasSubroutes = item.subroutes != null && item.subroutes!.isNotEmpty;

    return AppBar(
      title: Text(item.title),
      actions: [
        // Show subroute buttons if the current section has them
        if (hasSubroutes) ...[
          const SizedBox(width: 16),
          ...item.subroutes!.map((subroute) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: TextButton.icon(
                  icon: Icon(subroute.icon, size: 18),
                  label: Text(subroute.title),
                  onPressed: () => _navigateToSubroute(subroute.route),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              )),
        ],
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
          tooltip: 'Refresh Data',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: _showUserMenu,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          _buildMoreMenuTile(4), // Users & Staff
          _buildMoreMenuTile(5), // Business Settings
          _buildMoreMenuTile(6), // Analytics
          _buildMoreMenuTile(7), // Meal Plans
          if (_navigationItems[7].subroutes != null) ...[
            ...(_navigationItems[7].subroutes!.map((subroute) => ListTile(
                  leading: Icon(subroute.icon, size: 20),
                  title: Text(subroute.title),
                  contentPadding: const EdgeInsets.only(left: 48),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    _navigateToSubroute(subroute.route);
                  },
                ))),
          ],
          _buildMoreMenuTile(8), // Catering Management
          if (_navigationItems[8].subroutes != null) ...[
            ...(_navigationItems[8].subroutes!.map((subroute) => ListTile(
                  leading: Icon(subroute.icon, size: 20),
                  title: Text(subroute.title),
                  contentPadding: const EdgeInsets.only(left: 48),
                  dense: true,
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    _navigateToSubroute(subroute.route);
                  },
                ))),
          ],
        ],
      ),
    );
  }

  Widget _buildMoreMenuTile(int index) {
    final item = _navigationItems[index];
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.title),
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        _onItemSelected(index);
      },
    );
  }

  void _showUserMenu() {
    final authService = ref.read(authServiceProvider);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.sizeOf(context).width - 160,
        kToolbarHeight + 16,
        16,
        0,
      ),
      items: [
        PopupMenuItem(
          child: const Text('Profile'),
          onTap: () => context.push('/admin/profile'),
        ),
        PopupMenuItem(
          child: const Text('Help'),
          onTap: () => context.push('/admin/help'),
        ),
        PopupMenuItem(
          child: const Text('Logout'),
          onTap: () async {
            await authService.signOut();
            if (mounted) context.go('/login');
          },
        ),
      ],
    );
  }
}

class _AdminNavigationItem {
  final String title;
  final IconData icon;
  final String route;
  final List<_SubRoute>? subroutes;

  const _AdminNavigationItem({
    required this.title,
    required this.icon,
    required this.route,
    this.subroutes,
  });
}

class _SubRoute {
  final String title;
  final String route;
  final IconData icon;

  const _SubRoute({
    required this.title,
    required this.route,
    required this.icon,
  });
}

// Include bare minimum of UnauthorizedScreen to make the code complete
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),
            const Text('You do not have access to this area'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
