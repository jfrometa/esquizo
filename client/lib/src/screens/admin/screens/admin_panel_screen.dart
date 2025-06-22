import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Add for performance scheduling
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';

import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_stats_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart'; // Use updated router

// Define constants for the global indices (0-5) matching AdminRoutes logic - OPTION 1
const int _dashboardIndex = 0;
const int _paymentsIndex = 1;
const int _staffIndex = 2;
const int _mealPlansIndex = 3;
const int _cateringIndex = 4;
const int _settingsIndex = 5;

class AdminPanelScreen extends ConsumerStatefulWidget {
  final Widget child;
  final int initialIndex; // This index corresponds to _navigationItems (0-4)
  final String? businessSlug; // Add this parameter

  const AdminPanelScreen({
    super.key,
    required this.child,
    this.initialIndex = _dashboardIndex,
    this.businessSlug, // Add this parameter
  });

  @override
  ConsumerState<AdminPanelScreen> createState() => AdminPanelScreenState();
}

class AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _refreshTimer;
  bool _isLoading = false;
  late int selectedIndex; // Corresponds to indices 0-5

  bool _isVerifyingIndex = false;

  // _navigationItems list based on the 10 main sections - OPTION 2
  final List<_AdminNavigationItem> _navigationItems = [
    // Index 0 - Dashboard (Main section with subroutes)
    _AdminNavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: AdminRoutes.getFullPath(AdminRoutes.dashboard),
      routeName: AdminRoutes.nameDashboard,
      subroutes: [
        _SubRoute(
            title: 'Products',
            routeName: AdminRoutes.nameProducts,
            icon: Icons.restaurant_menu,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.dashboard}/${AdminRoutes.products}')),
        _SubRoute(
            title: 'Orders',
            routeName: AdminRoutes.nameOrders,
            icon: Icons.receipt_long,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.dashboard}/${AdminRoutes.orders}')),
        _SubRoute(
            title: 'Order Details',
            routeName: AdminRoutes.nameOrderDetails,
            icon: Icons.info,
            isDetailRoute: true,
            detailRouteName: AdminRoutes.nameOrderDetails,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.dashboard}/${AdminRoutes.orders}/:orderId')),
        _SubRoute(
            title: 'Tables',
            routeName: AdminRoutes.nameTables,
            icon: Icons.table_bar,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.dashboard}/${AdminRoutes.tables}')),
        _SubRoute(
            title: 'Analytics',
            routeName: AdminRoutes.nameAnalytics,
            icon: Icons.bar_chart,
            route: AdminRoutes.getFullPath(
                '${AdminRoutes.dashboard}/${AdminRoutes.analytics}')),
      ],
    ),
    // Index 1 - Payments
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
    // Index 2 - Staff
    _AdminNavigationItem(
      title: 'Staff',
      icon: Icons.people_alt_rounded,
      route: AdminRoutes.getFullPath(AdminRoutes.staff),
      routeName: AdminRoutes.nameStaffHome,
      subroutes: [
        // Overview route for Staff section
        _SubRoute(
            title: 'Overview',
            routeName: AdminRoutes.nameStaffOverview,
            icon: Icons.dashboard,
            route: AdminRoutes.getFullPath('${AdminRoutes.staff}/overview')),
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
    // Index 3 - Meal Plans
    _AdminNavigationItem(
      title: 'Meal Plans',
      icon: Icons.lunch_dining,
      route: AdminRoutes.getFullPath(AdminRoutes.mealPlans),
      routeName: AdminRoutes.nameMpHome,
      subroutes: [
        // Overview route for Meal Plans section
        _SubRoute(
            title: 'Overview',
            routeName: AdminRoutes.nameMpOverview,
            icon: Icons.dashboard,
            route:
                AdminRoutes.getFullPath('${AdminRoutes.mealPlans}/overview')),
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
    // Index 4 - Catering
    _AdminNavigationItem(
      title: 'Catering',
      icon: Icons.inventory_2,
      route: AdminRoutes.getFullPath(AdminRoutes.catering),
      routeName: AdminRoutes.nameCtHome,
      subroutes: [
        // Overview route for Catering section
        _SubRoute(
            title: 'Overview',
            routeName: AdminRoutes.nameCtOverview,
            icon: Icons.dashboard,
            route: AdminRoutes.getFullPath('${AdminRoutes.catering}/overview')),
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
    // Index 5 - Settings
    _AdminNavigationItem(
      title: 'Settings',
      icon: Icons.settings,
      route: AdminRoutes.getFullPath(AdminRoutes.settings),
      routeName: AdminRoutes.nameSettings,
      subroutes: [
        // Overview route for Settings section
        _SubRoute(
            title: 'Overview',
            routeName: AdminRoutes.nameSettingsOverview,
            icon: Icons.dashboard,
            route: AdminRoutes.getFullPath('${AdminRoutes.settings}/overview')),
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

    // Handle widget updates (route changes, etc.)
    if (widget.initialIndex != oldWidget.initialIndex) {
      if (mounted && selectedIndex != widget.initialIndex) {
        setState(() {
          selectedIndex = widget.initialIndex;
        });
      }
    }

    // Also handle business slug changes
    if (widget.businessSlug != oldWidget.businessSlug) {
      // Business context changed, re-verify the index
      _verifyIndexWithRoute();
    } else {
      // Always verify index with route for consistency
      _verifyIndexWithRoute();
    }
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
      // Dashboard (Overview only)
      case AdminRoutes.nameDashboard:
        return AdminRoutes.nameBusinessDashboard;
      // Products (NEW top-level section)
      case AdminRoutes.nameProducts:
        return AdminRoutes.nameBusinessProducts;
      // Orders (NEW top-level section)
      case AdminRoutes.nameOrders:
        return AdminRoutes.nameBusinessOrders;
      case AdminRoutes.nameOrderDetails:
        return AdminRoutes.nameBusinessOrderDetails;
      // Tables (NEW top-level section)
      case AdminRoutes.nameTables:
        return AdminRoutes.nameBusinessTables;
      // Analytics (NEW top-level section)
      case AdminRoutes.nameAnalytics:
        return AdminRoutes.nameBusinessAnalytics;
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
      case AdminRoutes.nameStaffOverview:
        return AdminRoutes.nameBusinessStaffOverview;
      case AdminRoutes.nameStaffKitchen:
        return AdminRoutes.nameBusinessStaffKitchen;
      case AdminRoutes.nameStaffWaiter:
        return AdminRoutes.nameBusinessStaffWaiter;
      case AdminRoutes.nameStaffWaiterOrderEntry:
        return AdminRoutes.nameBusinessStaffWaiterOrderEntry;
      // Meal Plans
      case AdminRoutes.nameMpHome:
        return AdminRoutes.nameBusinessMpHome;
      case AdminRoutes.nameMpOverview:
        return AdminRoutes.nameBusinessMpOverview;
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
      case AdminRoutes.nameCtOverview:
        return AdminRoutes.nameBusinessCtOverview;
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
      case AdminRoutes.nameSettingsOverview:
        return AdminRoutes.nameBusinessSettingsOverview;
      case AdminRoutes.nameSettingsUsers:
        return AdminRoutes.nameBusinessSettingsUsers;
      default:
        return routeName;
    }
  }

  // Helper method to find which navigation item contains the current route
  _AdminNavigationItem _getNavigationItemForRoute(String? currentRoutePath) {
    if (currentRoutePath == null) {
      // If no route path, use the first item as fallback
      return _navigationItems.isNotEmpty
          ? _navigationItems[0]
          : _navigationItems[selectedIndex];
    }

    // Remove business slug from path if present for consistent matching
    String normalizedPath = currentRoutePath;
    if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
      normalizedPath =
          normalizedPath.replaceFirst('/${widget.businessSlug}', '');
    }

    // Normalize both the path and item routes by removing leading slashes for comparison
    String cleanNormalizedPath = normalizedPath.startsWith('/')
        ? normalizedPath.substring(1)
        : normalizedPath;

    // First, check if the current path matches a main route (home route of a section)
    for (final item in _navigationItems) {
      String cleanItemRoute =
          item.route.startsWith('/') ? item.route.substring(1) : item.route;
      if (cleanItemRoute == cleanNormalizedPath ||
          normalizedPath == item.route ||
          (cleanNormalizedPath.isEmpty && cleanItemRoute.isEmpty)) {
        return item;
      }
    }

    // Then, check if the current path matches a subroute of any section
    for (final item in _navigationItems) {
      if (item.subroutes != null) {
        for (final subroute in item.subroutes!) {
          String cleanSubrouteRoute = subroute.route.startsWith('/')
              ? subroute.route.substring(1)
              : subroute.route;
          // Check if the path starts with the subroute path (for detail routes with parameters)
          if (cleanNormalizedPath == cleanSubrouteRoute ||
              normalizedPath == subroute.route ||
              cleanNormalizedPath.startsWith('$cleanSubrouteRoute/') ||
              normalizedPath.startsWith('${subroute.route}/')) {
            return item;
          }
        }
      }
    }

    // Use AdminRoutes.getIndexFromRoute to determine the section
    final index = AdminRoutes.getIndexFromRoute(normalizedPath);
    if (index >= 0 && index < _navigationItems.length) {
      return _navigationItems[index];
    }

    // Final fallback to the item at the current selectedIndex, or first item if selectedIndex is invalid
    if (selectedIndex >= 0 && selectedIndex < _navigationItems.length) {
      return _navigationItems[selectedIndex];
    }
    return _navigationItems.isNotEmpty
        ? _navigationItems[0]
        : _navigationItems[selectedIndex];
  }

  // Helper method to get the current route path correctly based on context
  String? _getCurrentRoutePath() {
    final routerState = GoRouterState.of(context);
    // For business routes, use uri.path to get the full path including business slug
    // For regular admin routes, use matchedLocation
    return widget.businessSlug != null && widget.businessSlug!.isNotEmpty
        ? routerState.uri.path
        : routerState.matchedLocation;
  }

  // Helper method to get the correct index based on current route path
  int _getIndexFromRoutePath(String? currentRoutePath) {
    if (currentRoutePath == null) return selectedIndex;

    // Remove business slug from path if present for consistent matching
    String normalizedPath = currentRoutePath;
    debugPrint(
        '🔧 [getIndexFromRoutePath] Original path: $currentRoutePath, businessSlug: ${widget.businessSlug}');

    // Try both matchedLocation and uri.path to see which one gives us the correct path
    final routerState = GoRouterState.of(context);
    final uriPath = routerState.uri.path;
    debugPrint(
        '🔧 [getIndexFromRoutePath] matchedLocation: ${routerState.matchedLocation}');
    debugPrint('🔧 [getIndexFromRoutePath] uri.path: $uriPath');

    // Use uri.path instead of matchedLocation for business routes
    if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
      normalizedPath = uriPath.replaceFirst('/${widget.businessSlug}', '');
    }
    debugPrint(
        '🔧 [getIndexFromRoutePath] Normalized path after slug removal: $normalizedPath');

    // Use the existing AdminRoutes.getIndexFromRoute method which works with paths
    final index = AdminRoutes.getIndexFromRoute(normalizedPath);
    debugPrint('🔧 [getIndexFromRoutePath] Computed index: $index');
    return index;
  }

  // --- Initial Subroute Redirection Logic ---
  void _handleInitialSubrouteRedirection() {
    if (!mounted) return;

    final String? currentRoutePath = _getCurrentRoutePath();
    if (currentRoutePath == null) return;

    // Normalize the path using the same logic as _getIndexFromRoutePath
    String normalizedPath = currentRoutePath;

    // Remove business slug if this is a business route
    if (widget.businessSlug != null &&
        normalizedPath.startsWith('/${widget.businessSlug}')) {
      normalizedPath =
          normalizedPath.replaceFirst('/${widget.businessSlug}', '');
    }

    // Check if we're on a section root and need to redirect to first subroute
    for (int i = 0; i < _navigationItems.length; i++) {
      final item = _navigationItems[i];
      final itemRoute = item.route;

      // Normalize item route by removing leading slash for comparison
      String cleanItemRoute =
          itemRoute.startsWith('/') ? itemRoute.substring(1) : itemRoute;
      String cleanNormalizedPath = normalizedPath.startsWith('/')
          ? normalizedPath.substring(1)
          : normalizedPath;

      // If we're exactly on a section root (no subroute) and the section has subroutes
      if ((cleanNormalizedPath == cleanItemRoute ||
              normalizedPath == itemRoute) &&
          item.subroutes != null &&
          item.subroutes!.isNotEmpty) {
        final firstSubroute = item.subroutes![0];

        // Get the business slug if we're on a business route
        final businessSlug = _getBusinessSlugFromPath(currentRoutePath);
        final redirectPath = businessSlug != null
            ? '/$businessSlug${firstSubroute.route}'
            : firstSubroute.route;

        debugPrint(
            'AdminPanel: Redirecting from section root "$normalizedPath" to first subroute "$redirectPath"');

        // Navigate to the first subroute
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(redirectPath);
          }
        });
        return;
      }
    }
  }

  // Helper to extract business slug from path
  String? _getBusinessSlugFromPath(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    // Check if this is a business route (e.g., /slug/admin/...)
    if (segments.length >= 2 && segments[1] == 'admin') {
      return segments[0];
    }

    return null;
  }
  // --- End Initial Subroute Redirection Logic ---

  // --- State Verification Logic ---
  void _verifyIndexWithRoute() {
    if (!mounted || _isVerifyingIndex) return;
    _isVerifyingIndex = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _isVerifyingIndex = false;
        return;
      }

      // First, handle initial subroute redirection if needed
      _handleInitialSubrouteRedirection();

      // Get the current route path - use helper method for consistency
      final String? currentRoutePath = _getCurrentRoutePath();
      final correctIndex = _getIndexFromRoutePath(currentRoutePath);

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

    // Watch the GoRouter state to ensure rebuilds on route changes
    final routerState = GoRouterState.of(context);
    final currentRoutePath =
        widget.businessSlug != null && widget.businessSlug!.isNotEmpty
            ? routerState.uri.path
            : routerState.matchedLocation;

    // Compute correct index based on current route
    final correctIndex = _getIndexFromRoutePath(currentRoutePath);
    debugPrint(
        '🏗️ [build] Current selectedIndex: $selectedIndex, correctIndex: $correctIndex, currentRoutePath: $currentRoutePath');
    debugPrint(
        '🏗️ [build] About to pass currentSelectedIndex to navigation: will be determined below');

    // Use the correct index from the route - trust the getIndexFromRoute method
    int currentSelectedIndex = correctIndex;

    // Update selectedIndex if it's different
    if (selectedIndex != correctIndex) {
      debugPrint(
          '🏗️ [build] Index mismatch detected! Updating selectedIndex from $selectedIndex to $correctIndex');
      selectedIndex = correctIndex;

      // Schedule a setState to ensure proper widget lifecycle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            // State is already updated above, this just ensures proper rebuild
          });
        }
      });
    }

    debugPrint(
        '🏗️ [build] FINAL: currentSelectedIndex that will be passed to navigation: $currentSelectedIndex');

    // Guard for invalid selectedIndex
    if (currentSelectedIndex < 0 ||
        currentSelectedIndex >= _navigationItems.length) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(
                  key: ValueKey('AdminPanelLoading'))));
    }

    if (isDesktop) {
      return _buildDesktopLayout(
          context, currentSelectedIndex, currentRoutePath);
    } else if (isTablet) {
      return _buildTabletLayout(
          context, currentSelectedIndex, currentRoutePath);
    } else {
      return _buildMobileLayout(
          context, currentSelectedIndex, currentRoutePath);
    }
  }

  // --- Layout Builders (Pass selectedIndex AND currentRouteName explicitly) ---

  Widget _buildDesktopLayout(BuildContext context, int currentSelectedIndex,
      String? currentRoutePath) {
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
                    currentRoutePath), // Pass index & name
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

  // --- Subroute Item Builder (Accepts currentRoutePath) ---
  List<Widget> _buildSubrouteItems(List<_SubRoute> subroutes,
      ColorScheme colorScheme, BuildContext context, String? currentRoutePath) {
    final visibleSubroutes =
        subroutes.where((sr) => !sr.isDetailRoute).toList();

    return visibleSubroutes.map((subroute) {
      bool isSelected = false;

      if (currentRoutePath != null) {
        // Remove business slug from path if present for consistent matching
        String normalizedPath = currentRoutePath;
        if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
          normalizedPath =
              normalizedPath.replaceFirst('/${widget.businessSlug}', '');
        }

        // Normalize both paths by removing leading slashes for comparison
        String cleanNormalizedPath = normalizedPath.startsWith('/')
            ? normalizedPath.substring(1)
            : normalizedPath;
        String cleanSubrouteRoute = subroute.route.startsWith('/')
            ? subroute.route.substring(1)
            : subroute.route;

        // Check if current path matches the subroute path
        if (cleanNormalizedPath == cleanSubrouteRoute ||
            normalizedPath == subroute.route ||
            cleanNormalizedPath.startsWith('$cleanSubrouteRoute/') ||
            normalizedPath.startsWith('${subroute.route}/')) {
          isSelected = true;
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: InkWell(
          onTap: () {
            int parentIndex = _navigationItems.indexWhere((item) =>
                item.subroutes
                    ?.any((sr) => sr.routeName == subroute.routeName) ??
                false);
            debugPrint(
                '🔍 [SubrouteClick] Searching for parent of subroute: ${subroute.routeName}');
            debugPrint('🔍 [SubrouteClick] Found parentIndex: $parentIndex');
            if (parentIndex != -1) {
              _navigateToSubroute(parentIndex, subroute.routeName);
            } else {
              debugPrint(
                  '❌ [SubrouteClick] ERROR: Could not find parent section for subroute: ${subroute.routeName}');
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
      String? currentRoutePath) {
    final item = _getNavigationItemForRoute(currentRoutePath);
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
                      currentRoutePath), // Pass index & name
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
                                currentRoutePath)); // Pass name
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

  // --- AppBar Title Builder (Accepts index and route path) ---
  Widget _buildAppBarTitle(BuildContext context, int currentSelectedIndex,
      String? currentRoutePath) {
    final params = GoRouterState.of(context).pathParameters;
    if (currentSelectedIndex < 0 ||
        currentSelectedIndex >= _navigationItems.length) {
      return const Text("Admin Panel");
    }
    final parentItem = _navigationItems[currentSelectedIndex];
    final mainSectionTitle = parentItem.title;
    String titleText = mainSectionTitle;
    if (currentRoutePath == null) return Text(titleText);

    // Normalize the current route path for comparison
    String normalizedPath = currentRoutePath;
    if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
      normalizedPath =
          normalizedPath.replaceFirst('/${widget.businessSlug}', '');
    }

    _SubRoute? currentSubroute;
    if (parentItem.subroutes != null && parentItem.subroutes!.isNotEmpty) {
      try {
        // Normalize both paths for comparison
        String cleanNormalizedPath = normalizedPath.startsWith('/')
            ? normalizedPath.substring(1)
            : normalizedPath;

        currentSubroute = parentItem.subroutes!.firstWhere(
          (sr) {
            String cleanSubrouteRoute =
                sr.route.startsWith('/') ? sr.route.substring(1) : sr.route;
            return cleanNormalizedPath.startsWith(cleanSubrouteRoute) ||
                normalizedPath.startsWith(sr.route) ||
                (sr.detailRouteName != null &&
                    normalizedPath.contains(sr.detailRouteName!));
          },
        );
      } catch (e) {
        currentSubroute = null;
      }
    }
    if (normalizedPath != parentItem.route && currentSubroute != null) {
      titleText = '$mainSectionTitle > ${currentSubroute.title}';
      if (normalizedPath.contains('/orders/') &&
          params.containsKey('orderId')) {
        titleText += ' #${params['orderId']}';
      } else if (normalizedPath.contains('/qr/') &&
          params.containsKey('planId')) {/* Optional */}
    }
    return Text(titleText, overflow: TextOverflow.ellipsis);
  }
  // --- End AppBar Title Builder ---

  // --- Mobile Layout (Accepts index and route path) ---
  Widget _buildMobileLayout(BuildContext context, int currentSelectedIndex,
      String? currentRoutePath) {
    final item = _getNavigationItemForRoute(currentRoutePath);
    final visibleSubroutes =
        item.subroutes?.where((sr) => !sr.isDetailRoute).toList() ?? [];
    final hasVisibleSubroutes = visibleSubroutes.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _buildAppBarTitle(context, currentSelectedIndex,
            currentRoutePath), // Pass index & path
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
                    // Use passed currentRoutePath for highlighting with path-based matching
                    if (currentRoutePath != null) {
                      // Normalize the current path
                      String normalizedPath = currentRoutePath;
                      if (widget.businessSlug != null &&
                          widget.businessSlug!.isNotEmpty) {
                        normalizedPath = normalizedPath.replaceFirst(
                            '/${widget.businessSlug}', '');
                      }

                      // Normalize both paths for comparison
                      String cleanNormalizedPath =
                          normalizedPath.startsWith('/')
                              ? normalizedPath.substring(1)
                              : normalizedPath;
                      String cleanSubrouteRoute = subroute.route.startsWith('/')
                          ? subroute.route.substring(1)
                          : subroute.route;

                      // Check if current path matches this subroute
                      isSubrouteSelected =
                          cleanNormalizedPath.startsWith(cleanSubrouteRoute) ||
                              normalizedPath.startsWith(subroute.route) ||
                              (subroute.detailRouteName != null &&
                                  normalizedPath
                                      .contains(subroute.detailRouteName!));
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
                        debugPrint(
                            '🔍 [DrawerSubrouteClick] Using parent index: $index for subroute: ${subroute.routeName}');
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

                        // Normalize the current path for comparison
                        String? normalizedPath = currentRoutePath;
                        if (normalizedPath != null &&
                            widget.businessSlug != null &&
                            widget.businessSlug!.isNotEmpty) {
                          normalizedPath = normalizedPath.replaceFirst(
                              '/${widget.businessSlug}', '');
                        }

                        try {
                          if (normalizedPath != null) {
                            activeSubroute = visibleSubroutes.firstWhere(
                              (sr) =>
                                  normalizedPath!.startsWith(sr.route) ||
                                  (sr.detailRouteName != null &&
                                      normalizedPath
                                          .contains(sr.detailRouteName!)),
                            );
                          }
                        } catch (e) {
                          activeSubroute = null;
                        }
                        if (activeSubroute == null &&
                            normalizedPath != item.route) {
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
              _onItemSelected(_dashboardIndex);
              break;
            case 1:
              _onItemSelected(_paymentsIndex); // Direct navigation to Payments
              break;
            case 2:
              _showMoreOptions(
                  currentRoutePath); // Staff/Meal Plans/Catering/Settings
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
        // Define the 3 items for the bottom bar (Option 1)
        items: [
          BottomNavigationBarItem(
              icon: Icon(_navigationItems[_dashboardIndex].icon),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(_navigationItems[_paymentsIndex].icon),
              label: 'Payments'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More'), // Staff/Meal Plans/Catering/Settings
        ],
      ),
      // --- End Mobile Bottom Navigation ---
    );
  }

  // --- Helper Functions ---

  // Maps global index (0-5) to mobile bottom bar index (0-2) - OPTION 1
  int _getMobileBottomBarIndex(int globalIndex) {
    switch (globalIndex) {
      case _dashboardIndex:
        return 0; // Dashboard (and its subroutes)
      case _paymentsIndex:
        return 1; // Payments
      case _staffIndex:
      case _mealPlansIndex:
      case _cateringIndex:
      case _settingsIndex:
        return 2; // Staff/Meal Plans/Catering/Settings → "More"
      default:
        return 0; // Fallback
    }
  }

  // Desktop Header (Accepts index and route path)
  Widget _buildDesktopHeader(BuildContext context, int currentSelectedIndex,
      String? currentRoutePath) {
    if (currentSelectedIndex < 0 ||
        currentSelectedIndex >= _navigationItems.length) {
      return AppBar(title: const Text("Admin Panel"));
    }
    final item = _getNavigationItemForRoute(currentRoutePath);
    final visibleSubroutes =
        item.subroutes?.where((sr) => !sr.isDetailRoute).toList() ?? [];
    final hasVisibleSubroutes = visibleSubroutes.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        AppBar(
          title: _buildAppBarTitle(
              context, currentSelectedIndex, currentRoutePath),
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
                            colorScheme, context, currentRoutePath))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildSubrouteItems(item.subroutes!,
                            colorScheme, context, currentRoutePath));
              },
            ),
          ),
      ],
    );
  }

  // --- Modal Bottom Sheet Logic (RESTORED & UPDATED) ---

  // Helper method to check if current route path matches an item route
  bool _isCurrentRoutePathForItem(String? currentRoutePath, String itemRoute) {
    if (currentRoutePath == null) return false;

    // Normalize the current path
    String normalizedPath = currentRoutePath;
    if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
      normalizedPath =
          normalizedPath.replaceFirst('/${widget.businessSlug}', '');
    }

    // Normalize both paths for comparison
    String cleanNormalizedPath = normalizedPath.startsWith('/')
        ? normalizedPath.substring(1)
        : normalizedPath;
    String cleanItemRoute =
        itemRoute.startsWith('/') ? itemRoute.substring(1) : itemRoute;

    return cleanNormalizedPath.startsWith(cleanItemRoute) ||
        normalizedPath.startsWith(itemRoute);
  }

  // Shows the More options (Staff, Meal Plans, Catering, Settings) - OPTION 1
  void _showMoreOptions(String? currentRoutePath) {
    final theme = Theme.of(context);
    final mealPlansItem = _navigationItems[_mealPlansIndex];
    final staffItem = _navigationItems[_staffIndex];
    final cateringItem = _navigationItems[_cateringIndex];
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
                  // --- Meal Plans Section ---
                  ListTile(
                    leading: Icon(mealPlansItem.icon),
                    title: Text(mealPlansItem.title),
                    selected: _isCurrentRoutePathForItem(
                        currentRoutePath, mealPlansItem.route),
                    selectedTileColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.2),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemSelected(_mealPlansIndex);
                    },
                  ),
                  // Indented Meal Plans Subroutes
                  ...mealPlansItem.subroutes!.map((subroute) =>
                      _buildSubrouteMoreMenuTile(
                          _mealPlansIndex, subroute, currentRoutePath,
                          indent: true)),

                  const Divider(),

                  // --- Staff Section ---
                  ListTile(
                    leading: Icon(staffItem.icon),
                    title: Text(staffItem.title),
                    selected: _isCurrentRoutePathForItem(
                        currentRoutePath, staffItem.route),
                    selectedTileColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.2),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemSelected(_staffIndex);
                    },
                  ),
                  // Indented Staff Subroutes
                  ...staffItem.subroutes!.map((subroute) =>
                      _buildSubrouteMoreMenuTile(
                          _staffIndex, subroute, currentRoutePath,
                          indent: true)),

                  const Divider(),

                  // --- Catering Section ---
                  ListTile(
                    leading: Icon(cateringItem.icon),
                    title: Text(cateringItem.title),
                    selected: _isCurrentRoutePathForItem(
                        currentRoutePath, cateringItem.route),
                    selectedTileColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.2),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemSelected(_cateringIndex);
                    },
                  ),
                  // Indented Catering Subroutes
                  ...cateringItem.subroutes!.map((subroute) =>
                      _buildSubrouteMoreMenuTile(
                          _cateringIndex, subroute, currentRoutePath,
                          indent: true)),

                  const Divider(),

                  // --- Settings Section ---
                  ListTile(
                    leading: Icon(settingsItem.icon),
                    title: Text(settingsItem.title),
                    selected: _isCurrentRoutePathForItem(
                        currentRoutePath, settingsItem.route),
                    selectedTileColor:
                        theme.colorScheme.primaryContainer.withOpacity(0.2),
                    onTap: () {
                      Navigator.pop(context);
                      _onItemSelected(_settingsIndex);
                    },
                  ),
                  // Indented Settings Subroutes
                  ...settingsItem.subroutes!.map((subroute) =>
                      _buildSubrouteMoreMenuTile(
                          _settingsIndex, subroute, currentRoutePath,
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
      int parentIndex, _SubRoute subroute, String? currentRoutePath,
      {bool indent = false}) {
    final theme = Theme.of(context);
    bool isSelected = false;

    // Use path-based matching instead of route name comparison
    if (currentRoutePath != null) {
      // Remove business slug from path if present for consistent matching
      String normalizedPath = currentRoutePath;
      if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
        normalizedPath =
            normalizedPath.replaceFirst('/${widget.businessSlug}', '');
      }

      // Normalize both paths by removing leading slashes for comparison
      String cleanNormalizedPath = normalizedPath.startsWith('/')
          ? normalizedPath.substring(1)
          : normalizedPath;
      String cleanSubrouteRoute = subroute.route.startsWith('/')
          ? subroute.route.substring(1)
          : subroute.route;

      // Check if current path matches the subroute path
      if (cleanNormalizedPath == cleanSubrouteRoute ||
          normalizedPath == subroute.route ||
          cleanNormalizedPath.startsWith('$cleanSubrouteRoute/') ||
          normalizedPath.startsWith('${subroute.route}/') ||
          (subroute.detailRouteName != null &&
              normalizedPath.contains(subroute.detailRouteName!))) {
        isSelected = true;
      }
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
          debugPrint(
              '🔍 [ModalSubrouteClick] Using parent index: $parentIndex for subroute: ${subroute.routeName}');
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

    // Update selectedIndex immediately to ensure UI responsiveness
    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });
    }

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
    debugPrint(
        '🚀 [_navigateToSubroute] Called with parentIndex: $parentIndex, routeName: $routeName');
    debugPrint(
        '🚀 [_navigateToSubroute] Current selectedIndex before: $selectedIndex');

    // Update selectedIndex to the parent section immediately for UI responsiveness
    if (selectedIndex != parentIndex &&
        parentIndex >= 0 &&
        parentIndex < _navigationItems.length) {
      setState(() {
        selectedIndex = parentIndex;
      });
      debugPrint(
          '🚀 [_navigateToSubroute] Updated selectedIndex to: $selectedIndex');
    }

    // If we have a businessSlug, ensure it's included in params
    final navParams = Map<String, String>.from(params);
    if (widget.businessSlug != null && widget.businessSlug!.isNotEmpty) {
      navParams['businessSlug'] = widget.businessSlug!;
    }

    debugPrint(
        '🚀 [_navigateToSubroute] About to navigate to route: $routeName with params: $navParams');
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
