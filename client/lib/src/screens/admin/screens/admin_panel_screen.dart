import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/admin_panel/admin_stats_provider.dart';
import 'dart:async';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => AdminPanelScreenState();
}

class AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _refreshTimer;
  bool _isLoading = false;
  int selectedIndex = 0;

  final List<_AdminNavigationItem> _navigationItems = [
    _AdminNavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/admin',
    ),
    _AdminNavigationItem(
      title: 'Products & Menu',
      icon: Icons.restaurant_menu,
      route: '/admin/products',
    ),
    _AdminNavigationItem(
      title: 'Orders',
      icon: Icons.receipt_long,
      route: '/admin/orders',
    ),
    _AdminNavigationItem(
      title: 'Tables',
      icon: Icons.table_bar,
      route: '/admin/tables',
    ),
    _AdminNavigationItem(
      title: 'Users & Staff',
      icon: Icons.people,
      route: '/admin/users',
    ),
    _AdminNavigationItem(
      title: 'Business Settings',
      icon: Icons.settings,
      route: '/admin/settings',
    ),
    _AdminNavigationItem(
      title: 'Analytics',
      icon: Icons.bar_chart,
      route: '/admin/analytics',
    ),
    _AdminNavigationItem(
        title: 'Meal Plans',
        icon: Icons.lunch_dining,
        route: '/admin/meal-plans',
        subroutes: [
          _SubRoute(
              title: 'Meal Plans Management',
              route: '/admin/meal-plans/management',
              icon: Icons.list),
          _SubRoute(
              title: 'Meal Plan Items',
              route: '/admin/meal-plans/items',
              icon: Icons.restaurant_menu),
          _SubRoute(
              title: 'Analytics',
              route: '/admin/meal-plans/analytics',
              icon: Icons.bar_chart),
          _SubRoute(
              title: 'Export Reports',
              route: '/admin/meal-plans/export',
              icon: Icons.download),
          _SubRoute(
              title: 'QR Scanner',
              route: '/admin/meal-plans/scanner',
              icon: Icons.qr_code_scanner),
          _SubRoute(
              title: 'POS Interface',
              route: '/admin/meal-plans/pos',
              icon: Icons.point_of_sale),
        ]),
    _AdminNavigationItem(
        title: 'Catering Management',
        icon: Icons.inventory_2,
        route: '/admin/catering',
        subroutes: [
          _SubRoute(
              title: 'Dashboard',
              route: '/admin/catering/dashboard',
              icon: Icons.dashboard),
          _SubRoute(
              title: 'Orders',
              route: '/admin/catering/orders',
              icon: Icons.receipt_long),
          _SubRoute(
              title: 'Packages',
              route: '/admin/catering/packages',
              icon: Icons.category),
          _SubRoute(
              title: 'Items',
              route: '/admin/catering/items',
              icon: Icons.food_bank),
          _SubRoute(
              title: 'Categories',
              route: '/admin/catering/categories',
              icon: Icons.list),
        ]),
  ];

  @override
  void initState() {
    super.initState();

    // Set up refresh timer to periodically update data
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshData();
    });

    // Set initial selectedIndex based on route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouterState.of(context).fullPath ?? '';
      final index = _findIndexForRoute(location);
      if (index != selectedIndex) {
        setState(() {
          selectedIndex = index;
        });
      }
    });
  }

  int _findIndexForRoute(String route) {
    for (int i = 0; i < _navigationItems.length; i++) {
      if (route.startsWith(_navigationItems[i].route)) {
        return i;
      }
    }
    return 0; // Default to dashboard
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
    // Don't navigate if already on that screen
    if (index == selectedIndex) return;

    setState(() {
      selectedIndex = index;
    });

    // Navigate using GoRouter
    context.go(_navigationItems[index].route);
  }

  void _navigateToSubroute(String route) {
    context.go(route);
  }

  void _navigateToMealPlanSection(String subRoute) {
    _navigateToSubroute('/admin/meal-plans/$subRoute');
  }

  void _navigateToCateringSection() {
    context.goNamed(AppRoute.cateringManagement.name);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = ref.watch(isAdminProvider).value;

    // Check if user is authenticated and has admin privileges
    if (authState != AuthState.authenticated || isAdmin != null && !isAdmin) {
      return const UnauthorizedScreen();
    }

    final size = MediaQuery.of(context).size;
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
                      // Main content - this will be populated by the GoRouter
                      const RouterOutlet(),

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

  // The tablet and mobile layouts would follow a similar pattern
  // with appropriate modifications for screen size

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
                      const RouterOutlet(),
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
          const RouterOutlet(),
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
        MediaQuery.of(context).size.width - 160,
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

class RouterOutlet extends StatelessWidget {
  const RouterOutlet({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
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
