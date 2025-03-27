import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/admin_panel/admin_stats_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart'; // Use updated router
import 'dart:async';

// Define constants for the global indices (0-3) matching AdminRoutes logic
const int _productDashboardIndex = 0;
const int _settingsIndex = 1;
const int _mealPlansIndex = 2;
const int _cateringIndex = 3;

class AdminPanelScreen extends ConsumerStatefulWidget {
  final Widget child;
  final int initialIndex; // This index corresponds to _navigationItems (0-3)

  const AdminPanelScreen({
    super.key,
    required this.child,
    this.initialIndex = _productDashboardIndex, // Default to Product Dashboard
  });

  @override
  ConsumerState<AdminPanelScreen> createState() => AdminPanelScreenState();
}

class AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _refreshTimer;
  bool _isLoading = false;
  // Make selectedIndex nullable initially
  int? _selectedIndexInternal;

  // Getter for selectedIndex, defaulting to initialIndex if null
  int get selectedIndex => _selectedIndexInternal ?? widget.initialIndex;

  // Flag to prevent reentry during state sync
  bool _isSyncingIndex = false;

  // _navigationItems list based on the 4 main sections
  // Ensure routeName matches GoRouter names, and route has the correct full path
  final List<_AdminNavigationItem> _navigationItems = [
    // Index 0 - Product Dashboard
    _AdminNavigationItem(
      title: 'Product Dashboard',
      icon: Icons.dashboard,
      route: AdminRoutes.getFullPath(AdminRoutes.productDashboard), // /admin
      routeName: AdminRoutes.namePdHome,
      subroutes: [
        _SubRoute(
            title: 'Products & Menu',
            route: AdminRoutes.getFullPath(AdminRoutes
                .dashboardProducts), // /admin/product-dashboard/products
            routeName: AdminRoutes.namePdProducts,
            icon: Icons.restaurant_menu),
        _SubRoute(
            title: 'Orders',
            route: AdminRoutes.getFullPath(
                AdminRoutes.dashboardOrders), // /admin/product-dashboard/orders
            routeName: AdminRoutes.namePdOrders,
            icon: Icons.receipt_long,
            detailRouteName:
                AdminRoutes.namePdOrderDetails), // For highlighting parent
        _SubRoute(
            title: 'Tables',
            route: AdminRoutes.getFullPath(
                AdminRoutes.dashboardTables), // /admin/product-dashboard/tables
            routeName: AdminRoutes.namePdTables,
            icon: Icons.table_bar),
        _SubRoute(
            title: 'Analytics',
            route: AdminRoutes.getFullPath(AdminRoutes
                .dashboardAnalytics), // /admin/product-dashboard/analytics
            routeName: AdminRoutes.namePdAnalytics,
            icon: Icons.bar_chart),
      ],
    ),
    // Index 1 - Settings
    _AdminNavigationItem(
      title: 'Business Settings',
      icon: Icons.settings,
      route: AdminRoutes.getFullPath(AdminRoutes.settings), // /admin/settings
      routeName: AdminRoutes.nameSettings,
      subroutes: [
        _SubRoute(
            title: 'Users & Staff',
            // Construct full path correctly for subroute under /admin/settings
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.settings}/${AdminRoutes.settingsUsers}'), // /admin/settings/users
            routeName: AdminRoutes.nameSettingsUsers,
            icon: Icons.people),
      ],
    ),
    // Index 2 - Meal Plans
    _AdminNavigationItem(
      title: 'Meal Plans',
      icon: Icons.lunch_dining,
      route:
          AdminRoutes.getFullPath(AdminRoutes.mealPlans), // /admin/meal-plans
      routeName: AdminRoutes.nameMpHome,
      subroutes: [
        _SubRoute(
            title: 'Management', // Changed title for clarity
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanManagement}'), // /admin/meal-plans/management
            routeName: AdminRoutes.nameMpManagement,
            icon: Icons.list),
        _SubRoute(
            title: 'Items',
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanItems}'), // /admin/meal-plans/items
            routeName: AdminRoutes.nameMpItems,
            icon: Icons.restaurant_menu),
        _SubRoute(
            title: 'Analytics',
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanAnalytics}'), // /admin/meal-plans/analytics
            routeName: AdminRoutes.nameMpAnalytics,
            icon: Icons.bar_chart),
        _SubRoute(
            title: 'Export', // Changed title for clarity
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanExport}'), // /admin/meal-plans/export
            routeName: AdminRoutes.nameMpExport,
            icon: Icons.download),
        _SubRoute(
            title: 'Scanner',
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanScanner}'), // /admin/meal-plans/scanner
            routeName: AdminRoutes.nameMpScanner,
            icon: Icons.qr_code_scanner),
        _SubRoute(
            title: 'POS', // Changed title for clarity
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanPos}'), // /admin/meal-plans/pos
            routeName: AdminRoutes.nameMpPos,
            icon: Icons.point_of_sale),
        // SubRoute for QR Detail - used for highlighting logic, not direct nav
        _SubRoute(
            title: 'QR Code Details',
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanQr}'), // Base pattern
            routeName: AdminRoutes.nameMpQr, // Matches detail route name
            icon: Icons.qr_code, // Placeholder icon
            isDetailRoute: true,
            detailRouteName:
                AdminRoutes.nameMpQr // Explicitly match detail name
            ),
      ],
    ),
    // Index 3 - Catering Management
    _AdminNavigationItem(
      title: 'Catering', // Shortened title
      icon: Icons.inventory_2,
      route: AdminRoutes.getFullPath(AdminRoutes.catering), // /admin/catering
      routeName: AdminRoutes.nameCtHome,
      subroutes: [
        _SubRoute(
            title: 'Dashboard',
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringDashboard}'), // /admin/catering/dashboard
            routeName: AdminRoutes.nameCtDashboard,
            icon: Icons.dashboard),
        _SubRoute(
            title: 'Orders',
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringOrders}'), // /admin/catering/orders
            routeName: AdminRoutes.nameCtOrders,
            icon: Icons.receipt_long),
        _SubRoute(
            title: 'Packages',
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringPackages}'), // /admin/catering/packages
            routeName: AdminRoutes.nameCtPackages,
            icon: Icons.category),
        _SubRoute(
            title: 'Items',
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringItems}'), // /admin/catering/items
            routeName: AdminRoutes.nameCtItems,
            icon: Icons.food_bank),
        _SubRoute(
            title: 'Categories',
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringCategories}'), // /admin/catering/categories
            routeName: AdminRoutes.nameCtCategories,
            icon: Icons.list),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndexInternal = widget.initialIndex;
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshData();
    });
  }

  @override
  void didUpdateWidget(covariant AdminPanelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      if (mounted && _selectedIndexInternal != widget.initialIndex) {
        _syncIndexWithRoute();
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
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

  // Navigate using named routes
  void _navigateByName(String routeName,
      {Map<String, String> params = const {}}) {
    final currentState = GoRouterState.of(context);
    if (currentState.name == routeName &&
        currentState.pathParameters == params) {
      return;
    }
    context.goNamed(routeName, pathParameters: params);
  }

  // Trigger navigation to the primary screen of the selected section index
  void _onItemSelected(int index) {
    if (index < 0 || index >= _navigationItems.length) return;
    final targetRouteName = _navigationItems[index].routeName;
    _navigateByName(targetRouteName);
    // State update is handled by _syncIndexWithRoute
  }

  // Trigger navigation to a specific subroute
  void _navigateToSubroute(int parentIndex, String routeName,
      {Map<String, String> params = const {}}) {
    final currentRouteName = GoRouterState.of(context).name;
    final currentParams = GoRouterState.of(context).pathParameters;
    if (currentRouteName == routeName && currentParams == params) return;
    // State update is handled by _syncIndexWithRoute
    _navigateByName(routeName, params: params);
  }

  // --- State Synchronization Logic ---
  void _syncIndexWithRoute() {
    if (!mounted || _isSyncingIndex) return;
    _isSyncingIndex = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isSyncingIndex = false;
        return;
      }

      final currentRoute = GoRouterState.of(context).matchedLocation;
      final correctIndex = AdminRoutes.getIndexFromRoute(currentRoute);

      if (_selectedIndexInternal != correctIndex) {
        setState(() {
          _selectedIndexInternal = correctIndex;
        });
      }
      _isSyncingIndex = false;
    });
  }
  // --- End State Synchronization Logic ---

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isAdmin = ref.watch(isAdminProvider).value;

    if (authState != AuthState.authenticated || isAdmin != null && !isAdmin) {
      return const UnauthorizedScreen();
    }

    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 1100;
    final isTablet = size.width >= 600;

    // Trigger index synchronization after build
    _syncIndexWithRoute();

    // Use the getter `selectedIndex` which handles the nullable internal state
    final currentSelectedIndex = selectedIndex;

    // Guard for invalid selectedIndex before building layouts
    if (currentSelectedIndex < 0 ||
        currentSelectedIndex >= _navigationItems.length) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(
                  key: ValueKey('AdminPanelLoading'))));
    }

    if (isDesktop) {
      return _buildDesktopLayout(context, currentSelectedIndex);
    } else if (isTablet) {
      return _buildTabletLayout(context, currentSelectedIndex);
    } else {
      return _buildMobileLayout(context, currentSelectedIndex);
    }
  }

  // --- Layout Builders (Pass selectedIndex explicitly) ---

  Widget _buildDesktopLayout(BuildContext context, int currentSelectedIndex) {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: currentSelectedIndex,
            onDestinationSelected: _onItemSelected,
            destinations: _navigationItems
                .map((item) => NavigationRailDestination(
                    icon: Icon(item.icon), label: Text(item.title)))
                .toList(),
          ),
          VerticalDivider(
              width: 1, thickness: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: Column(
              children: [
                _buildDesktopHeader(context, currentSelectedIndex),
                Expanded(
                  child: Stack(
                    children: [
                      widget.child,
                      if (_isLoading)
                        const Positioned.fill(
                            child: Center(child: CircularProgressIndicator())),
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

  // --- Subroute Item Builder ---
  List<Widget> _buildSubrouteItems(List<_SubRoute> subroutes,
      ColorScheme colorScheme, BuildContext context) {
    final state = GoRouterState.of(context);
    final currentRouteName = state.name;

    final visibleSubroutes =
        subroutes.where((sr) => !sr.isDetailRoute).toList();

    return visibleSubroutes.map((subroute) {
      bool isSelected = false;
      if (currentRouteName == subroute.routeName ||
          (subroute.detailRouteName != null &&
              currentRouteName == subroute.detailRouteName)) {
        isSelected = true;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: InkWell(
          onTap: () {
            int parentIndex = _navigationItems.indexWhere((item) =>
                item.subroutes
                    ?.any((sr) => sr.routeName == subroute.routeName) ??
                false);
            if (parentIndex != -1) {
              _navigateToSubroute(parentIndex, subroute.routeName);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(subroute.icon,
                    size: 16,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(subroute.title,
                    style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
  // --- End Subroute Item Builder ---

  Widget _buildTabletLayout(BuildContext context, int currentSelectedIndex) {
    final item = _navigationItems[currentSelectedIndex];
    final visibleSubroutes =
        item.subroutes?.where((sr) => !sr.isDetailRoute).toList() ?? [];
    final hasVisibleSubroutes = visibleSubroutes.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          NavigationRail(
            extended: false,
            selectedIndex: currentSelectedIndex,
            onDestinationSelected: _onItemSelected,
            destinations: _navigationItems
                .map((item) => NavigationRailDestination(
                    icon: Icon(item.icon), label: Text(item.title)))
                .toList(),
          ),
          VerticalDivider(
              width: 1, thickness: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: _buildAppBarTitle(context, currentSelectedIndex),
                  actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshData,
                        tooltip: 'Refresh Data'),
                    IconButton(
                        icon: const Icon(Icons.account_circle),
                        onPressed: _showUserMenu),
                  ],
                ),
                if (hasVisibleSubroutes)
                  Container(
                    height: 48,
                    color: colorScheme.surface,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: _buildSubrouteItems(
                                item.subroutes!, colorScheme, context));
                      },
                    ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      widget.child,
                      if (_isLoading)
                        const Positioned.fill(
                            child: Center(child: CircularProgressIndicator())),
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

  // --- AppBar Title Builder (Accepts index) ---
  Widget _buildAppBarTitle(BuildContext context, int currentSelectedIndex) {
    final state = GoRouterState.of(context);
    final String? currentRouteName = state.name;
    final params = state.pathParameters;

    if (currentSelectedIndex < 0 ||
        currentSelectedIndex >= _navigationItems.length) {
      return const Text("Admin Panel");
    }
    final parentItem = _navigationItems[currentSelectedIndex];
    final mainSectionTitle = parentItem.title;

    String titleText = mainSectionTitle;

    if (currentRouteName == null) return Text(titleText);

    _SubRoute? currentSubroute;
    if (parentItem.subroutes != null && parentItem.subroutes!.isNotEmpty) {
      try {
        currentSubroute = parentItem.subroutes!.firstWhere(
          (sr) =>
              sr.routeName == currentRouteName ||
              sr.detailRouteName == currentRouteName,
        );
      } catch (e) {
        currentSubroute = null;
      }
    }

    if (currentRouteName != parentItem.routeName && currentSubroute != null) {
      titleText = '$mainSectionTitle > ${currentSubroute.title}';
      if (currentRouteName == AdminRoutes.namePdOrderDetails &&
          params.containsKey('orderId')) {
        titleText += ' #${params['orderId']}';
      } else if (currentRouteName == AdminRoutes.nameMpQr &&
          params.containsKey('planId')) {
        // Optional: Append plan ID
      }
    }

    return Text(titleText, overflow: TextOverflow.ellipsis);
  }
  // --- End AppBar Title Builder ---

  // --- Mobile Layout (Accepts index) ---
  Widget _buildMobileLayout(BuildContext context, int currentSelectedIndex) {
    final item = _navigationItems[currentSelectedIndex];
    final visibleSubroutes =
        item.subroutes?.where((sr) => !sr.isDetailRoute).toList() ?? [];
    final hasVisibleSubroutes = visibleSubroutes.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final state = GoRouterState.of(context);
    final currentRouteName = state.name;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _buildAppBarTitle(context, currentSelectedIndex),
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Refresh Data'),
          IconButton(
              icon: const Icon(Icons.account_circle), onPressed: _showUserMenu),
        ],
      ),
      // --- Drawer (Uses currentSelectedIndex) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings_rounded,
                      size: 48, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(height: 8),
                  Text('Admin Panel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text('Management Dashboard',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.8),
                          fontSize: 14)),
                ],
              ),
            ),
            ..._navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final navItem = entry.value;
              final isSectionActive = currentSelectedIndex == index;
              final visibleSubroutes = navItem.subroutes
                      ?.where((sr) => !sr.isDetailRoute)
                      .toList() ??
                  [];
              final itemHasVisibleSubroutes = visibleSubroutes.isNotEmpty;

              if (!itemHasVisibleSubroutes) {
                // Simple ListTile
                return ListTile(
                  leading: Icon(navItem.icon,
                      color: isSectionActive
                          ? Theme.of(context).colorScheme.primary
                          : null),
                  title: Text(navItem.title,
                      style: TextStyle(
                          fontWeight: isSectionActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSectionActive
                              ? Theme.of(context).colorScheme.primary
                              : null)),
                  selected: isSectionActive,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemSelected(index);
                  },
                );
              } else {
                // ExpansionTile
                return ExpansionTile(
                  leading: Icon(navItem.icon,
                      color: isSectionActive
                          ? Theme.of(context).colorScheme.primary
                          : null),
                  title: Text(navItem.title,
                      style: TextStyle(
                          fontWeight: isSectionActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSectionActive
                              ? Theme.of(context).colorScheme.primary
                              : null)),
                  initiallyExpanded: isSectionActive,
                  children: visibleSubroutes.map((subroute) {
                    bool isSubrouteSelected = false;
                    // Use the captured currentRouteName from the outer scope
                    if (currentRouteName == subroute.routeName ||
                        (subroute.detailRouteName != null &&
                            currentRouteName == subroute.detailRouteName)) {
                      isSubrouteSelected = true;
                    }
                    return ListTile(
                      leading: Icon(subroute.icon,
                          size: 20,
                          color: isSubrouteSelected
                              ? Theme.of(context).colorScheme.primary
                              : null),
                      title: Text(subroute.title,
                          style: TextStyle(
                              fontWeight: isSubrouteSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSubrouteSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null)),
                      contentPadding: const EdgeInsets.only(left: 32),
                      dense: true,
                      selected: isSubrouteSelected,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToSubroute(index, subroute.routeName);
                      },
                    );
                  }).toList(),
                );
              }
            }),
          ],
        ),
      ),
      // --- End Drawer ---
      body: Column(
        children: [
          // --- Subroute Bar ---
          if (hasVisibleSubroutes && currentRouteName != item.routeName)
            Container(
              height: 40,
              color: colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(item.title,
                      style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.7))),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_right, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        // Use captured currentRouteName
                        _SubRoute? activeSubroute = visibleSubroutes.firstWhere(
                          (sr) =>
                              sr.routeName == currentRouteName ||
                              sr.detailRouteName == currentRouteName,
                        );
                        String subrouteTitle =
                            activeSubroute?.title ?? "Details";
                        return Text(subrouteTitle,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary),
                            overflow: TextOverflow.ellipsis);
                      },
                    ),
                  ),
                ],
              ),
            ),
          // --- End Subroute Bar ---
          Expanded(
            child: Stack(
              children: [
                widget.child,
                if (_isLoading)
                  const Positioned.fill(
                      child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ),
        ],
      ),
      // Mobile Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getMobileBottomBarIndex(currentSelectedIndex),
        onTap: (tappedMobileIndex) {
          // CAPTURE current route name BEFORE showing modal
          final String? routeNameForModal =
              GoRouterState.of(context).name; // Use valid context

          switch (tappedMobileIndex) {
            case 0:
              _showSubrouteOptions(_productDashboardIndex, routeNameForModal);
              break; // Pass it
            case 1:
              _showSubrouteOptions(_mealPlansIndex, routeNameForModal);
              break; // Pass it
            case 2:
              _showSubrouteOptions(_cateringIndex, routeNameForModal);
              break; // Pass it
            case 3:
              _showSettingsOptions(routeNameForModal);
              break; // Pass it
          }
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(_navigationItems[_productDashboardIndex].icon),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(_navigationItems[_mealPlansIndex].icon),
              label: _navigationItems[_mealPlansIndex].title),
          BottomNavigationBarItem(
              icon: Icon(_navigationItems[_cateringIndex].icon),
              label: 'Catering'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  // --- Helper Functions ---

  // Maps global index (0-3) to mobile bottom bar index (0-3)
  int _getMobileBottomBarIndex(int globalIndex) {
    switch (globalIndex) {
      case _productDashboardIndex:
        return 0;
      case _mealPlansIndex:
        return 1;
      case _cateringIndex:
        return 2;
      case _settingsIndex:
        return 3; // Settings is under 'More'
      default:
        return 0;
    }
  }

  // Desktop Header (Accepts index)
  Widget _buildDesktopHeader(BuildContext context, int currentSelectedIndex) {
    if (currentSelectedIndex < 0 ||
        currentSelectedIndex >= _navigationItems.length)
      return AppBar(title: const Text("Admin Panel"));
    final item = _navigationItems[currentSelectedIndex];
    final visibleSubroutes =
        item.subroutes?.where((sr) => !sr.isDetailRoute).toList() ?? [];
    final hasVisibleSubroutes = visibleSubroutes.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AppBar(
          title: _buildAppBarTitle(context, currentSelectedIndex),
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshData,
                tooltip: 'Refresh Data'),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: _showUserMenu),
            const SizedBox(width: 16),
          ],
        ),
        if (hasVisibleSubroutes)
          Container(
            height: 48,
            color: colorScheme.surface,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemCount = visibleSubroutes.length;
                final estimatedItemWidth = 150.0;
                final needsScrolling =
                    estimatedItemWidth * itemCount > availableWidth;
                return needsScrolling
                    ? ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: _buildSubrouteItems(
                            item.subroutes!, colorScheme, context))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildSubrouteItems(
                            item.subroutes!, colorScheme, context));
              },
            ),
          ),
      ],
    );
  }

  // --- Modal Bottom Sheet Logic ---

  // Shows subroute options for Product Dashboard, Meal Plans, Catering
  // ACCEPTS currentRouteName
  void _showSubrouteOptions(int globalIndex, String? currentRouteName) {
    final theme = Theme.of(context);
    if (globalIndex < 0 || globalIndex >= _navigationItems.length) return;
    final item = _navigationItems[globalIndex];
    final visibleSubroutes =
        item.subroutes?.where((sr) => !sr.isDetailRoute).toList() ?? [];
    if (visibleSubroutes.isEmpty) {
      _onItemSelected(globalIndex);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHeader(theme, item.title),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                      leading: Icon(item.icon),
                      title: Text('${item.title} Home'),
                      selected: currentRouteName == item.routeName,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemSelected(globalIndex);
                      }), // Use passed name
                  const Divider(),
                  ...visibleSubroutes
                      .map((subroute) => _buildSubrouteMoreMenuTile(
                          globalIndex, subroute, currentRouteName))
                      .toList(), // Pass name
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shows the Settings options (including Users) under 'More'
  // ACCEPTS currentRouteName
  void _showSettingsOptions(String? currentRouteName) {
    final theme = Theme.of(context);
    final settingsItem = _navigationItems[_settingsIndex];
    final usersSubroute = settingsItem.subroutes?.firstWhere(
      (sr) => sr.routeName == AdminRoutes.nameSettingsUsers,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHeader(theme, 'More Options'),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                      leading: Icon(settingsItem.icon),
                      title: Text(settingsItem.title),
                      selected: selectedIndex == _settingsIndex &&
                          currentRouteName == settingsItem.routeName,
                      onTap: () {
                        Navigator.pop(context);
                        _onItemSelected(_settingsIndex);
                      }), // Use passed name
                  if (usersSubroute != null)
                    ListTile(
                        leading: Icon(usersSubroute.icon),
                        title: Text(usersSubroute.title),
                        selected: selectedIndex == _settingsIndex &&
                            currentRouteName == usersSubroute.routeName,
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToSubroute(
                              _settingsIndex, usersSubroute.routeName);
                        }), // Use passed name
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds modal sheet header
  Widget _buildBottomSheetHeader(ThemeData theme, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
      child: Column(
        children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Builds tile for subroute items in modals
  // ACCEPTS currentRouteName
  Widget _buildSubrouteMoreMenuTile(
      int parentIndex, _SubRoute subroute, String? currentRouteName) {
    final theme = Theme.of(context);
    bool isSelected = false;
    // Use the PASSED currentRouteName for comparison
    if (currentRouteName == subroute.routeName ||
        (subroute.detailRouteName != null &&
            currentRouteName == subroute.detailRouteName)) {
      isSelected = true;
    }

    return ListTile(
        leading: Icon(subroute.icon,
            size: 20, color: isSelected ? theme.colorScheme.primary : null),
        title: Text(subroute.title,
            style: TextStyle(
                fontSize: 14,
                color: isSelected ? theme.colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null)),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
        onTap: () {
          Navigator.pop(context);
          _navigateToSubroute(parentIndex, subroute.routeName);
        });
  }

  // --- User Menu ---
  void _showUserMenu() {
    final authService = ref.read(authServiceProvider);
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final RenderBox? button = context.findRenderObject() as RenderBox?;
    RelativeRect position;
    if (button != null && overlay != null) {
      position = RelativeRect.fromRect(
              Rect.fromPoints(
                  button.localToGlobal(Offset.zero, ancestor: overlay),
                  button.localToGlobal(button.size.bottomRight(Offset.zero),
                      ancestor: overlay)),
              Offset.zero & overlay.size)
          .shift(const Offset(0, 8));
    } else {
      position = RelativeRect.fromLTRB(
          MediaQuery.sizeOf(context).width - 160, kToolbarHeight + 16, 16, 0);
    }
    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
            child: const Text('Profile'),
            onTap: () => context.pushNamed(AdminRoutes.nameProfile)),
        PopupMenuItem(
            child: const Text('Help'),
            onTap: () => context.pushNamed(AdminRoutes.nameHelp)),
        PopupMenuItem(
            child: const Text('Logout'),
            onTap: () async {
              await authService.signOut();
              if (mounted) context.goNamed(AdminRoutes.nameLogin);
            }),
      ],
    );
  }
}

// --- Data Classes (Keep as defined in the prompt) ---
class _AdminNavigationItem {
  final String title;
  final IconData icon;
  final String route; // Full Path
  final String routeName; // Named route
  final List<_SubRoute>? subroutes;

  const _AdminNavigationItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.routeName,
    this.subroutes,
  });
}

class _SubRoute {
  final String title;
  final String route; // Full Path
  final String routeName; // Named route
  final IconData icon;
  final String? detailRoutePattern; // Not used in this revision's logic
  final String?
      detailRouteName; // Name of the detail route for highlighting parent
  final bool isDetailRoute; // Flag to hide from navigation lists

  const _SubRoute({
    required this.title,
    required this.route,
    required this.routeName,
    required this.icon,
    this.detailRoutePattern,
    this.detailRouteName,
    this.isDetailRoute = false,
  });
}

// Unauthorized Screen (Keep as defined in the prompt)
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
              onPressed: () =>
                  context.goNamed(AdminRoutes.nameHome), // Use named route
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
