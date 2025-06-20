import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';

import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_stats_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart'; // Use updated router
import 'dart:async';

// Define constants for the global indices (0-5) matching AdminRoutes logic - UPDATED
const int _productDashboardIndex = 0;
const int _paymentsIndex = 1; // NEW
const int _staffIndex = 2; // Shifted
const int _mealPlansIndex = 3; // Shifted
const int _cateringIndex = 4; // Shifted
const int _settingsIndex = 5; // Shifted

class AdminPanelScreen extends ConsumerStatefulWidget {
  final Widget child;
  final int initialIndex; // This index corresponds to _navigationItems (0-4)
  final String? businessSlug; // Add this parameter

  const AdminPanelScreen({
    super.key,
    required this.child,
    this.initialIndex = _productDashboardIndex,
    this.businessSlug, // Add this parameter
  });

  @override
  ConsumerState<AdminPanelScreen> createState() => AdminPanelScreenState();
}

class AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _refreshTimer;
  bool _isLoading = false;
  late int selectedIndex; // Corresponds to indices 0-4

  bool _isVerifyingIndex = false;

  // _navigationItems list based on the 6 main sections - UPDATED
  final List<_AdminNavigationItem> _navigationItems = [
    // Index 0 - Product Dashboard
    _AdminNavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: AdminRoutes.getFullPath(AdminRoutes.productDashboard),
      routeName: AdminRoutes.namePdHome,
      subroutes: [
        _SubRoute(
            title: 'Products',
            routeName: AdminRoutes.namePdProducts,
            icon: Icons.restaurant_menu,
            route: AdminRoutes.getFullPath(AdminRoutes.dashboardProducts)),
        _SubRoute(
            title: 'Orders',
            routeName: AdminRoutes.namePdOrders,
            icon: Icons.receipt_long,
            detailRouteName: AdminRoutes.namePdOrderDetails,
            route: AdminRoutes.getFullPath(AdminRoutes.dashboardOrders)),
        _SubRoute(
            title: 'Tables',
            routeName: AdminRoutes.namePdTables,
            icon: Icons.table_bar,
            detailRouteName: AdminRoutes.namePdTables,
            route: AdminRoutes.getFullPath(AdminRoutes.dashboardTables)),
        _SubRoute(
            title: 'Analytics',
            routeName: AdminRoutes.namePdAnalytics,
            icon: Icons.bar_chart,
            route: AdminRoutes.getFullPath(AdminRoutes.dashboardAnalytics)),
        // Remove payments from here - it's now a top-level section
      ],
    ),
    // Index 1 - Payments (NEW)
    _AdminNavigationItem(
      title: 'Payments',
      icon: Icons.payments,
      route: AdminRoutes.getFullPath(AdminRoutes.payments),
      routeName: AdminRoutes.namePaymentsHome,
      subroutes: [
        _SubRoute(
            title: 'Overview',
            routeName: AdminRoutes.namePaymentsOverview,
            icon: Icons.dashboard,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.payments}/${AdminRoutes.paymentsOverview}')),
        _SubRoute(
            title: 'Transactions',
            routeName: AdminRoutes.namePaymentsTransactions,
            icon: Icons.receipt,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.payments}/${AdminRoutes.paymentsTransactions}')),
        _SubRoute(
            title: 'Tips',
            routeName: AdminRoutes.namePaymentsTips,
            icon: Icons.volunteer_activism,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.payments}/${AdminRoutes.paymentsTips}')),
        _SubRoute(
            title: 'Taxes',
            routeName: AdminRoutes.namePaymentsTaxes,
            icon: Icons.account_balance,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.payments}/${AdminRoutes.paymentsTaxes}')),
        _SubRoute(
            title: 'Service Tracking',
            routeName: AdminRoutes.namePaymentsService,
            icon: Icons.track_changes,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.payments}/${AdminRoutes.paymentsService}')),
        _SubRoute(
            title: 'Order Payment Details',
            routeName: AdminRoutes.namePaymentsOrderDetails,
            icon: Icons.payment,
            isDetailRoute: true,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.payments}/${AdminRoutes.paymentsOrderDetails}')),
      ],
    ),
    // Index 2 - Staff (Shifted)
    _AdminNavigationItem(
      title: 'Staff',
      icon: Icons.people_alt_rounded,
      route: AdminRoutes.getFullPath(AdminRoutes.staff),
      routeName: AdminRoutes.nameStaffHome,
      subroutes: [
        // Kitchen management route
        _SubRoute(
            title: 'Kitchen',
            routeName: AdminRoutes.nameStaffKitchen,
            icon: Icons.kitchen,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.staff}/${AdminRoutes.staffKitchen}')),
        // Waiter management route
        _SubRoute(
            title: 'Waiter',
            routeName: AdminRoutes.nameStaffWaiter,
            icon: Icons.room_service,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.staff}/${AdminRoutes.staffWaiter}')),
        // Order entry route for waiter flow
        _SubRoute(
            title: 'Order Entry',
            routeName: AdminRoutes.nameStaffWaiterOrderEntry,
            icon: Icons.edit_note,
            isDetailRoute: true,
            detailRouteName: AdminRoutes.nameStaffWaiterOrderEntry,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.staff}/${AdminRoutes.staffWaiterOrderEntry}')),
      ],
    ),
    // Index 3 - Meal Plans (Shifted)
    _AdminNavigationItem(
      title: 'Meal Plans',
      icon: Icons.lunch_dining,
      route: AdminRoutes.getFullPath(AdminRoutes.mealPlans),
      routeName: AdminRoutes.nameMpHome,
      subroutes: [
        _SubRoute(
            title: 'Management',
            routeName: AdminRoutes.nameMpManagement,
            icon: Icons.list,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanManagement}')),
        _SubRoute(
            title: 'Items',
            routeName: AdminRoutes.nameMpItems,
            icon: Icons.restaurant_menu,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanItems}')),
        _SubRoute(
            title: 'Analytics',
            routeName: AdminRoutes.nameMpAnalytics,
            icon: Icons.bar_chart,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanAnalytics}')),
        _SubRoute(
            title: 'Export',
            routeName: AdminRoutes.nameMpExport,
            icon: Icons.download,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanExport}')),
        _SubRoute(
            title: 'Scanner',
            routeName: AdminRoutes.nameMpScanner,
            icon: Icons.qr_code_scanner,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanScanner}')),
        _SubRoute(
            title: 'POS',
            routeName: AdminRoutes.nameMpPos,
            icon: Icons.point_of_sale,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanPos}')),
        _SubRoute(
            title: 'QR Code Details',
            routeName: AdminRoutes.nameMpQr,
            icon: Icons.qr_code,
            isDetailRoute: true,
            detailRouteName: AdminRoutes.nameMpQr,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.mealPlans}/${AdminRoutes.mealPlanQr}')),
      ],
    ),
    // Index 4 - Catering (Shifted)
    _AdminNavigationItem(
      title: 'Catering',
      icon: Icons.inventory_2,
      route: AdminRoutes.getFullPath(AdminRoutes.catering),
      routeName: AdminRoutes.nameCtHome,
      subroutes: [
        _SubRoute(
            title: 'Dashboard',
            routeName: AdminRoutes.nameCtDashboard,
            icon: Icons.dashboard,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringDashboard}')),
        _SubRoute(
            title: 'Orders',
            routeName: AdminRoutes.nameCtOrders,
            icon: Icons.receipt_long,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringOrders}')),
        _SubRoute(
            title: 'Packages',
            routeName: AdminRoutes.nameCtPackages,
            icon: Icons.category,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringPackages}')),
        _SubRoute(
            title: 'Items',
            routeName: AdminRoutes.nameCtItems,
            icon: Icons.food_bank,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringItems}')),
        _SubRoute(
            title: 'Categories',
            routeName: AdminRoutes.nameCtCategories,
            icon: Icons.list,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.catering}/${AdminRoutes.cateringCategories}')),
      ],
    ),
    // Index 5 - Settings (Shifted)
    _AdminNavigationItem(
      title: 'Settings', // Shortened
      icon: Icons.settings,
      route: AdminRoutes.getFullPath(AdminRoutes.settings),
      routeName: AdminRoutes.nameSettings,
      subroutes: [
        _SubRoute(
            title: 'Users & Staff',
            routeName: AdminRoutes.nameSettingsUsers,
            icon: Icons.people,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.settings}/${AdminRoutes.settingsUsers}')),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshData();
    });
    _verifyIndexWithRoute();
  }

  @override
  void didUpdateWidget(covariant AdminPanelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      if (mounted && selectedIndex != widget.initialIndex) {
        setState(() {
          selectedIndex = widget.initialIndex;
        });
      }
    }
    _verifyIndexWithRoute();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    /* ... no change ... */
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

    // If we have a businessSlug, use business-specific route names
    if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
      // Map regular route names to business-specific ones
      final businessRouteName = _getBusinessRouteName(routeName);
      final businessParams = Map<String, String>.from(params);
      businessParams['businessSlug'] = widget.businessSlug!;

      if (currentState.name == businessRouteName &&
          currentState.pathParameters == businessParams) {
        return;
      }
      context.goNamed(businessRouteName, pathParameters: businessParams);
    } else {
      // Regular admin navigation without business context
      if (currentState.name == routeName &&
          currentState.pathParameters == params) {
        return;
      }
      context.goNamed(routeName, pathParameters: params);
    }
  }

  // Helper method to map regular route names to business-specific ones
  String _getBusinessRouteName(String routeName) {
    // Map regular admin route names to business-specific ones
    switch (routeName) {
      // Product Dashboard
      case AdminRoutes.namePdHome:
        return AdminRoutes.nameBusinessPdHome;
      case AdminRoutes.namePdProducts:
        return AdminRoutes.nameBusinessPdProducts;
      case AdminRoutes.namePdOrders:
        return AdminRoutes.nameBusinessPdOrders;
      case AdminRoutes.namePdOrderDetails:
        return AdminRoutes.nameBusinessPdOrderDetails;
      case AdminRoutes.namePdTables:
        return AdminRoutes.nameBusinessPdTables;
      case AdminRoutes.namePdAnalytics:
        return AdminRoutes.nameBusinessPdAnalytics;
      // Payments (NEW)
      case AdminRoutes.namePaymentsHome:
        return AdminRoutes.nameBusinessPaymentsHome;
      case AdminRoutes.namePaymentsOverview:
        return AdminRoutes.nameBusinessPaymentsOverview;
      case AdminRoutes.namePaymentsTransactions:
        return AdminRoutes.nameBusinessPaymentsTransactions;
      case AdminRoutes.namePaymentsTips:
        return AdminRoutes.nameBusinessPaymentsTips;
      case AdminRoutes.namePaymentsTaxes:
        return AdminRoutes.nameBusinessPaymentsTaxes;
      case AdminRoutes.namePaymentsService:
        return AdminRoutes.nameBusinessPaymentsService;
      case AdminRoutes.namePaymentsOrderDetails:
        return AdminRoutes.nameBusinessPaymentsOrderDetails;
      // Staff (shifted)
      case AdminRoutes.nameStaffHome:
        return AdminRoutes.nameBusinessStaffHome;
      case AdminRoutes.nameStaffKitchen:
        return AdminRoutes.nameBusinessStaffKitchen;
      case AdminRoutes.nameStaffWaiter:
        return AdminRoutes.nameBusinessStaffWaiter;
      case AdminRoutes.nameStaffWaiterOrderEntry:
        return AdminRoutes.nameBusinessStaffWaiterOrderEntry;
      // Meal Plans
      case AdminRoutes.nameMpHome:
        return AdminRoutes.nameBusinessMpHome;
      case AdminRoutes.nameMpManagement:
        return AdminRoutes.nameBusinessMpManagement;
      case AdminRoutes.nameMpItems:
        return AdminRoutes.nameBusinessMpItems;
      case AdminRoutes.nameMpAnalytics:
        return AdminRoutes.nameBusinessMpAnalytics;
      case AdminRoutes.nameMpExport:
        return AdminRoutes.nameBusinessMpExport;
      case AdminRoutes.nameMpScanner:
        return AdminRoutes.nameBusinessMpScanner;
      case AdminRoutes.nameMpPos:
        return AdminRoutes.nameBusinessMpPos;
      case AdminRoutes.nameMpQr:
        return AdminRoutes.nameBusinessMpQr;
      case AdminRoutes.nameMpOrders:
        return AdminRoutes.nameBusinessMpOrders;
      case AdminRoutes.nameMpOrderDetails:
        return AdminRoutes.nameBusinessMpOrderDetails;
      // Catering
      case AdminRoutes.nameCtHome:
        return AdminRoutes.nameBusinessCtHome;
      case AdminRoutes.nameCtDashboard:
        return AdminRoutes.nameBusinessCtDashboard;
      case AdminRoutes.nameCtOrders:
        return AdminRoutes.nameBusinessCtOrders;
      case AdminRoutes.nameCtOrderDetails:
        return AdminRoutes.nameBusinessCtOrderDetails;
      case AdminRoutes.nameCtPackages:
        return AdminRoutes.nameBusinessCtPackages;
      case AdminRoutes.nameCtItems:
        return AdminRoutes.nameBusinessCtItems;
      case AdminRoutes.nameCtCategories:
        return AdminRoutes.nameBusinessCtCategories;
      // Settings
      case AdminRoutes.nameSettings:
        return AdminRoutes.nameBusinessSettings;
      case AdminRoutes.nameSettingsUsers:
        return AdminRoutes.nameBusinessSettingsUsers;
      default:
        return routeName;
    }
  }

  // Helper method to map business route names back to regular ones for comparison
  String _getRegularRouteName(String? routeName) {
    if (routeName == null) return '';

    // Map business-specific route names back to regular ones
    switch (routeName) {
      // Product Dashboard
      case AdminRoutes.nameBusinessPdHome:
        return AdminRoutes.namePdHome;
      case AdminRoutes.nameBusinessPdProducts:
        return AdminRoutes.namePdProducts;
      case AdminRoutes.nameBusinessPdOrders:
        return AdminRoutes.namePdOrders;
      case AdminRoutes.nameBusinessPdOrderDetails:
        return AdminRoutes.namePdOrderDetails;
      case AdminRoutes.nameBusinessPdTables:
        return AdminRoutes.namePdTables;
      case AdminRoutes.nameBusinessPdAnalytics:
        return AdminRoutes.namePdAnalytics;
      // Payments
      case AdminRoutes.nameBusinessPaymentsHome:
        return AdminRoutes.namePaymentsHome;
      case AdminRoutes.nameBusinessPaymentsOverview:
        return AdminRoutes.namePaymentsOverview;
      case AdminRoutes.nameBusinessPaymentsTransactions:
        return AdminRoutes.namePaymentsTransactions;
      case AdminRoutes.nameBusinessPaymentsTips:
        return AdminRoutes.namePaymentsTips;
      case AdminRoutes.nameBusinessPaymentsTaxes:
        return AdminRoutes.namePaymentsTaxes;
      case AdminRoutes.nameBusinessPaymentsService:
        return AdminRoutes.namePaymentsService;
      case AdminRoutes.nameBusinessPaymentsOrderDetails:
        return AdminRoutes.namePaymentsOrderDetails;
      // Staff
      case AdminRoutes.nameBusinessStaffHome:
        return AdminRoutes.nameStaffHome;
      case AdminRoutes.nameBusinessStaffKitchen:
        return AdminRoutes.nameStaffKitchen;
      case AdminRoutes.nameBusinessStaffWaiter:
        return AdminRoutes.nameStaffWaiter;
      case AdminRoutes.nameBusinessStaffWaiterOrderEntry:
        return AdminRoutes.nameStaffWaiterOrderEntry;
      // Meal Plans
      case AdminRoutes.nameBusinessMpHome:
        return AdminRoutes.nameMpHome;
      case AdminRoutes.nameBusinessMpManagement:
        return AdminRoutes.nameMpManagement;
      case AdminRoutes.nameBusinessMpItems:
        return AdminRoutes.nameMpItems;
      case AdminRoutes.nameBusinessMpAnalytics:
        return AdminRoutes.nameMpAnalytics;
      case AdminRoutes.nameBusinessMpExport:
        return AdminRoutes.nameMpExport;
      case AdminRoutes.nameBusinessMpScanner:
        return AdminRoutes.nameMpScanner;
      case AdminRoutes.nameBusinessMpPos:
        return AdminRoutes.nameMpPos;
      case AdminRoutes.nameBusinessMpQr:
        return AdminRoutes.nameMpQr;
      case AdminRoutes.nameBusinessMpOrders:
        return AdminRoutes.nameMpOrders;
      case AdminRoutes.nameBusinessMpOrderDetails:
        return AdminRoutes.nameMpOrderDetails;
      // Catering
      case AdminRoutes.nameBusinessCtHome:
        return AdminRoutes.nameCtHome;
      case AdminRoutes.nameBusinessCtDashboard:
        return AdminRoutes.nameCtDashboard;
      case AdminRoutes.nameBusinessCtOrders:
        return AdminRoutes.nameCtOrders;
      case AdminRoutes.nameBusinessCtOrderDetails:
        return AdminRoutes.nameCtOrderDetails;
      case AdminRoutes.nameBusinessCtPackages:
        return AdminRoutes.nameCtPackages;
      case AdminRoutes.nameBusinessCtItems:
        return AdminRoutes.nameCtItems;
      case AdminRoutes.nameBusinessCtCategories:
        return AdminRoutes.nameCtCategories;
      // Settings
      case AdminRoutes.nameBusinessSettings:
        return AdminRoutes.nameSettings;
      case AdminRoutes.nameBusinessSettingsUsers:
        return AdminRoutes.nameSettingsUsers;
      default:
        return routeName;
    }
  }

  // Helper method to find which navigation item contains the current route
  _AdminNavigationItem _getNavigationItemForRoute(String? currentRouteName) {
    if (currentRouteName == null) return _navigationItems[selectedIndex];

    final normalizedRouteName = _getRegularRouteName(currentRouteName);

    // First, check if the current route is a main route (home route of a section)
    for (final item in _navigationItems) {
      if (item.routeName == normalizedRouteName) {
        return item;
      }
    }

    // Then, check if the current route is a subroute of any section
    for (final item in _navigationItems) {
      if (item.subroutes != null) {
        for (final subroute in item.subroutes!) {
          if (subroute.routeName == normalizedRouteName ||
              (subroute.detailRouteName != null &&
                  subroute.detailRouteName == normalizedRouteName)) {
            return item;
          }
        }
      }
    }

    // Fallback to current selected index if no match found
    return _navigationItems[selectedIndex];
  }

  // --- State Verification Logic ---
  void _verifyIndexWithRoute() {
    // Update _verifyIndexWithRoute to use AdminRoutes constants
    if (!mounted || _isVerifyingIndex) return;
    _isVerifyingIndex = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isVerifyingIndex = false;
        return;
      }
      var currentRoute = GoRouterState.of(context).matchedLocation;

      // Remove business slug from route if present for index calculation
      if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
        currentRoute = currentRoute.replaceFirst('/${widget.businessSlug}', '');
      }

      final correctIndex = AdminRoutes.getIndexFromRoute(currentRoute);
      if (selectedIndex != correctIndex) {
        setState(() {
          selectedIndex = correctIndex;
        });
      }
      _isVerifyingIndex = false;
    });
  }
  // --- End State Verification Logic ---

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

    _verifyIndexWithRoute(); // Ensure index is correct before build

    final currentSelectedIndex = selectedIndex;

    // Guard for invalid selectedIndex
    if (currentSelectedIndex < 0 ||
        currentSelectedIndex >= _navigationItems.length) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(
                  key: ValueKey('AdminPanelLoading'))));
    }

    final String? currentRouteName = GoRouterState.of(context).name;

    if (isDesktop) {
      return _buildDesktopLayout(
          context, currentSelectedIndex, currentRouteName);
    } else if (isTablet) {
      return _buildTabletLayout(
          context, currentSelectedIndex, currentRouteName);
    } else {
      return _buildMobileLayout(
          context, currentSelectedIndex, currentRouteName);
    }
  }

  // --- Layout Builders (Pass selectedIndex AND currentRouteName explicitly) ---

  Widget _buildDesktopLayout(BuildContext context, int currentSelectedIndex,
      String? currentRouteName) {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex:
                currentSelectedIndex, // Use passed index for highlighting
            onDestinationSelected: _onItemSelected, // Triggers navigation
            destinations: _navigationItems // Now 6 items
                .map((item) => NavigationRailDestination(
                    icon: Icon(item.icon), label: Text(item.title)))
                .toList(),
          ),
          VerticalDivider(
              width: 1, thickness: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: Column(
              children: [
                _buildDesktopHeader(context, currentSelectedIndex,
                    currentRouteName), // Pass index & name
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

  // --- Subroute Item Builder (Accepts currentRouteName) ---
  List<Widget> _buildSubrouteItems(List<_SubRoute> subroutes,
      ColorScheme colorScheme, BuildContext context, String? currentRouteName) {
    final visibleSubroutes =
        subroutes.where((sr) => !sr.isDetailRoute).toList();

    return visibleSubroutes.map((subroute) {
      bool isSelected = false;
      // Normalize currentRouteName for comparison (convert business route names to regular ones)
      final normalizedRouteName = _getRegularRouteName(currentRouteName);
      if (normalizedRouteName == subroute.routeName ||
          (subroute.detailRouteName != null &&
              normalizedRouteName == subroute.detailRouteName)) {
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
                    color:
                        isSelected ? colorScheme.primary : Colors.transparent,
                    width: 1)),
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

  Widget _buildTabletLayout(BuildContext context, int currentSelectedIndex,
      String? currentRouteName) {
    final item = _getNavigationItemForRoute(currentRouteName);
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
            selectedIndex:
                currentSelectedIndex, // Use passed index for highlighting
            onDestinationSelected: _onItemSelected, // Triggers navigation
            destinations: _navigationItems // Now 6 items
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
                  title: _buildAppBarTitle(context, currentSelectedIndex,
                      currentRouteName), // Pass index & name
                  actions: [
                    /* ... actions ... */
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
                                item.subroutes!,
                                colorScheme,
                                context,
                                currentRouteName)); // Pass name
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

  // --- AppBar Title Builder (Accepts index and route name) ---
  Widget _buildAppBarTitle(BuildContext context, int currentSelectedIndex,
      String? currentRouteName) {
    final params = GoRouterState.of(context).pathParameters;
    if (currentSelectedIndex < 0 ||
        currentSelectedIndex >= _navigationItems.length) {
      return const Text("Admin Panel");
    }
    final parentItem = _navigationItems[currentSelectedIndex];
    final mainSectionTitle = parentItem.title;
    String titleText = mainSectionTitle;
    if (currentRouteName == null) return Text(titleText);

    // Normalize the current route name for comparison
    final normalizedRouteName = _getRegularRouteName(currentRouteName);

    _SubRoute? currentSubroute;
    if (parentItem.subroutes != null && parentItem.subroutes!.isNotEmpty) {
      try {
        currentSubroute = parentItem.subroutes!.firstWhere(
          (sr) =>
              sr.routeName == normalizedRouteName ||
              sr.detailRouteName == normalizedRouteName,
        );
      } catch (e) {
        currentSubroute = null;
      }
    }
    if (normalizedRouteName != parentItem.routeName &&
        currentSubroute != null) {
      titleText = '$mainSectionTitle > ${currentSubroute.title}';
      if (normalizedRouteName == AdminRoutes.namePdOrderDetails &&
          params.containsKey('orderId')) {
        titleText += ' #${params['orderId']}';
      } else if (normalizedRouteName == AdminRoutes.nameMpQr &&
          params.containsKey('planId')) {/* Optional */}
    }
    return Text(titleText, overflow: TextOverflow.ellipsis);
  }
  // --- End AppBar Title Builder ---

  // --- Mobile Layout (Accepts index and route name) ---
  Widget _buildMobileLayout(BuildContext context, int currentSelectedIndex,
      String? currentRouteName) {
    final item = _getNavigationItemForRoute(currentRouteName);
    final visibleSubroutes =
        item.subroutes?.where((sr) => !sr.isDetailRoute).toList() ?? [];
    final hasVisibleSubroutes = visibleSubroutes.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _buildAppBarTitle(context, currentSelectedIndex,
            currentRouteName), // Pass index & name
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        actions: [
          /* ... actions ... */
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Refresh Data'),
          IconButton(
              icon: const Icon(Icons.account_circle), onPressed: _showUserMenu),
        ],
      ),
      // --- Drawer (Uses currentSelectedIndex and currentRouteName for highlighting) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              /* ... Nicer Header ... */
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.admin_panel_settings_rounded,
                      size: 48, color: theme.colorScheme.onPrimary),
                  const SizedBox(height: 8),
                  Text('Admin Panel',
                      style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text('Management Dashboard',
                      style: TextStyle(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          fontSize: 14)),
                ],
              ),
            ),
            ..._navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final navItem = entry.value;
              final isSectionActive =
                  currentSelectedIndex == index; // Use passed index
              final visibleSubroutes = navItem.subroutes
                      ?.where((sr) => !sr.isDetailRoute)
                      .toList() ??
                  [];
              final itemHasVisibleSubroutes = visibleSubroutes.isNotEmpty;

              if (!itemHasVisibleSubroutes) {
                // Simple ListTile
                return ListTile(
                  leading: Icon(navItem.icon,
                      color:
                          isSectionActive ? theme.colorScheme.primary : null),
                  title: Text(navItem.title,
                      style: TextStyle(
                          fontWeight: isSectionActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSectionActive
                              ? theme.colorScheme.primary
                              : null)),
                  selected:
                      isSectionActive, // Highlighting based on section index
                  onTap: () {
                    Navigator.pop(context);
                    _onItemSelected(index);
                  },
                );
              } else {
                // ExpansionTile
                return ExpansionTile(
                  leading: Icon(navItem.icon,
                      color:
                          isSectionActive ? theme.colorScheme.primary : null),
                  title: Text(navItem.title,
                      style: TextStyle(
                          fontWeight: isSectionActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSectionActive
                              ? theme.colorScheme.primary
                              : null)),
                  initiallyExpanded:
                      isSectionActive, // Expand based on section index
                  children: visibleSubroutes.map((subroute) {
                    bool isSubrouteSelected = false;
                    // Use passed currentRouteName for highlighting
                    if (currentRouteName == subroute.routeName ||
                        (subroute.detailRouteName != null &&
                            currentRouteName == subroute.detailRouteName)) {
                      isSubrouteSelected = true;
                    }
                    return ListTile(
                      leading: Icon(subroute.icon,
                          size: 20,
                          color: isSubrouteSelected
                              ? theme.colorScheme.primary
                              : null),
                      title: Text(subroute.title,
                          style: TextStyle(
                              fontWeight: isSubrouteSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSubrouteSelected
                                  ? theme.colorScheme.primary
                                  : null)),
                      contentPadding: const EdgeInsets.only(left: 32),
                      dense: true,
                      selected:
                          isSubrouteSelected, // Highlighting based on route name
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
          if (hasVisibleSubroutes)
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
                        _SubRoute? activeSubroute;
                        String subrouteTitle = "Overview";
                        try {
                          activeSubroute = visibleSubroutes.firstWhere(
                            (sr) =>
                                sr.routeName == currentRouteName ||
                                sr.detailRouteName == currentRouteName,
                          );
                        } catch (e) {
                          activeSubroute = null;
                        }
                        if (activeSubroute == null &&
                            currentRouteName != item.routeName) {
                          subrouteTitle = "Details";
                        } else if (activeSubroute != null) {
                          subrouteTitle = activeSubroute.title;
                        }
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
      // --- Mobile Bottom Navigation (4 Items - Modal Logic Restored) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getMobileBottomBarIndex(currentSelectedIndex),
        onTap: (tappedMobileIndex) {
          switch (tappedMobileIndex) {
            case 0:
              _onItemSelected(_productDashboardIndex);
              break;
            case 1:
              _onItemSelected(_paymentsIndex); // Direct navigation to Payments
              break;
            case 2:
              _showSubrouteOptions(_mealPlansIndex, currentRouteName);
              break;
            case 3:
              _showMoreOptions(currentRouteName);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 8.0,
        // Define the 4 items for the bottom bar
        items: [
          BottomNavigationBarItem(
              icon: Icon(_navigationItems[_productDashboardIndex].icon),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(_navigationItems[_paymentsIndex].icon),
              label: 'Payments'), // NEW
          BottomNavigationBarItem(
              icon: Icon(_navigationItems[_mealPlansIndex].icon),
              label: 'Meal Plans'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More'), // Catering, Staff & Settings
        ],
      ),
      // --- End Mobile Bottom Navigation ---
    );
  }

  // --- Helper Functions ---

  // Maps global index (0-5) to mobile bottom bar index (0-3) - UPDATED
  int _getMobileBottomBarIndex(int globalIndex) {
    switch (globalIndex) {
      case _productDashboardIndex:
        return 0; // Dashboard
      case _paymentsIndex:
        return 1; // Payments
      case _mealPlansIndex:
        return 2; // Meal Plans
      case _cateringIndex:
      case _staffIndex:
      case _settingsIndex:
        return 3; // More (Catering, Staff, Settings)
      default:
        return 0; // Fallback
    }
  }

  // REMOVED: _mapMobileIndexToGlobalIndex (Not needed for modal approach)

  // Desktop Header (Accepts index and route name)
  Widget _buildDesktopHeader(BuildContext context, int currentSelectedIndex,
      String? currentRouteName) {
    if (currentSelectedIndex < 0 ||
        currentSelectedIndex >= _navigationItems.length) {
      return AppBar(title: const Text("Admin Panel"));
    }
    final item = _getNavigationItemForRoute(currentRouteName);
    final visibleSubroutes =
        item.subroutes?.where((sr) => !sr.isDetailRoute).toList() ?? [];
    final hasVisibleSubroutes = visibleSubroutes.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AppBar(
          title: _buildAppBarTitle(
              context, currentSelectedIndex, currentRouteName),
          actions: [
            /* ... actions ... */
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
                        children: _buildSubrouteItems(item.subroutes!,
                            colorScheme, context, currentRouteName))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildSubrouteItems(item.subroutes!,
                            colorScheme, context, currentRouteName));
              },
            ),
          ),
      ],
    );
  }

  // --- Modal Bottom Sheet Logic (RESTORED & UPDATED) ---

  // Shows subroute options for Meal Plans, Catering
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
      builder: (modalContext) => Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(modalContext).size.height * 0.7),
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
                        Navigator.pop(modalContext);
                        _onItemSelected(globalIndex);
                      }),
                  const Divider(),
                  ...visibleSubroutes.map((subroute) =>
                      _buildSubrouteMoreMenuTile(
                          globalIndex, subroute, currentRouteName)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shows the More options (Staff, Settings) - UPDATED
  void _showMoreOptions(String? currentRouteName) {
    final theme = Theme.of(context);
    final cateringItem = _navigationItems[_cateringIndex];
    final staffItem = _navigationItems[_staffIndex];
    final settingsItem = _navigationItems[_settingsIndex];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (modalContext) => Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(modalContext).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetHeader(theme, 'More Options'),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // --- Catering Section ---
                  ListTile(
                    leading: Icon(cateringItem.icon),
                    title: Text(cateringItem.title),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemSelected(_cateringIndex);
                    },
                  ),
                  // Indented Catering Subroutes
                  ...cateringItem.subroutes!.map((subroute) =>
                      _buildSubrouteMoreMenuTile(
                          _cateringIndex, subroute, currentRouteName,
                          indent: true)),

                  const Divider(),

                  // --- Staff Section ---
                  ListTile(
                    leading: Icon(staffItem.icon),
                    title: Text(staffItem.title),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemSelected(_staffIndex);
                    },
                  ),
                  // Indented Staff Subroutes
                  ...staffItem.subroutes!.map((subroute) =>
                      _buildSubrouteMoreMenuTile(
                          _staffIndex, subroute, currentRouteName,
                          indent: true)),

                  const Divider(),

                  // --- Settings Section ---
                  ListTile(
                    leading: Icon(settingsItem.icon),
                    title: Text(settingsItem.title),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemSelected(_settingsIndex);
                    },
                  ),
                  // Indented Settings Subroutes (Users)
                  ...settingsItem.subroutes!.map((subroute) =>
                      _buildSubrouteMoreMenuTile(
                          _settingsIndex, subroute, currentRouteName,
                          indent: true)),
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

  // Builds tile for subroute items in modals - ADDED indent option
  Widget _buildSubrouteMoreMenuTile(
      int parentIndex, _SubRoute subroute, String? currentRouteName,
      {bool indent = false}) {
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
        // Apply indentation for 'More' modal subroutes
        contentPadding: indent ? const EdgeInsets.only(left: 48) : null,
        dense: indent, // Make indented items denser
        onTap: () {
          Navigator.pop(context);
          _navigateToSubroute(parentIndex, subroute.routeName);
        });
  }
  // --- End Modal Bottom Sheet Logic ---

  // --- User Menu ---
  void _showUserMenu() async {
    final authService = ref.read(authServiceProvider);
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    await showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
            child: const Text('Profile'),
            onTap: () {
              // Handle profile navigation with business context
              if (widget.businessSlug != null &&
                  widget.businessSlug!.isNotEmpty) {
                context.go('/${widget.businessSlug}/cuenta');
              } else {
                context.pushNamed(AdminRoutes.nameProfile);
              }
            }),
        PopupMenuItem(
            child: const Text('Help'),
            onTap: () => context.pushNamed(AdminRoutes.nameHelp)),
        PopupMenuItem(
            child: const Text('Logout'),
            onTap: () async {
              await authService.signOut();
              if (mounted) {
                // Navigate to home or landing page based on business context
                if (widget.businessSlug != null &&
                    widget.businessSlug!.isNotEmpty) {
                  context.go('/${widget.businessSlug}');
                } else {
                  context.goNamed(AdminRoutes.nameHome);
                }
              }
            }),
      ],
    );
  }

  // Trigger navigation to the primary screen of the selected section index
  void _onItemSelected(int index) {
    if (index < 0 || index >= _navigationItems.length) return;
    final targetRouteName = _navigationItems[index].routeName;

    // Use the appropriate route name based on business context
    if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
      final businessRouteName = _getBusinessRouteName(targetRouteName);
      _navigateByName(businessRouteName);
    } else {
      _navigateByName(targetRouteName);
    }
  }

  // Trigger navigation to a specific subroute
  void _navigateToSubroute(int parentIndex, String routeName,
      {Map<String, String> params = const {}}) {
    // If we have a businessSlug, ensure it's included in params
    final navParams = Map<String, String>.from(params);
    if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
      navParams['businessSlug'] = widget.businessSlug!;
    }

    _navigateByName(routeName, params: navParams);
  }
}

// --- Data Classes ---
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
  final IconData icon; // Not used in this revision's logic
  final String?
      detailRouteName; // Name of the detail route for highlighting parent
  final bool isDetailRoute; // Flag to hide from navigation lists

  const _SubRoute({
    required this.title,
    required this.route,
    required this.routeName,
    required this.icon,
    this.detailRouteName,
    this.isDetailRoute = false,
  });
}

// Unauthorized Screen
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
              onPressed: () {
                // Check if we're in a business context
                final routerState = GoRouterState.of(context);
                final businessSlug = routerState.pathParameters['businessSlug'];

                if (businessSlug != null && businessSlug.isNotEmpty) {
                  // Navigate to business home
                  context.go('/$businessSlug');
                } else {
                  // Navigate to platform home
                  context.goNamed(AdminRoutes.nameHome);
                }
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
