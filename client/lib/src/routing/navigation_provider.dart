import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_features_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/business_navigation_provider.dart';

part 'navigation_provider.g.dart';

/// Model class for navigation destination items
class NavigationDestinationItem {
  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final bool isVisible; // Add visibility control

  const NavigationDestinationItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
    this.isVisible = true, // Default to visible
  });

  // Factory to create NavigationDestination widgets
  NavigationDestination toNavigationDestination() {
    return NavigationDestination(
      label: label,
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      tooltip: label,
    );
  }

  // Create a copy with modified visibility
  NavigationDestinationItem copyWith({bool? isVisible}) {
    return NavigationDestinationItem(
      label: label,
      path: path,
      icon: icon,
      selectedIcon: selectedIcon,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// Computed provider that returns a simple boolean for admin status
/// This prevents unnecessary rebuilds when watching AsyncValue
@riverpod
bool isAdminComputed(IsAdminComputedRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  final isAuthenticated = authState.value != null;

  // Return false if not authenticated
  if (!isAuthenticated) return false;

  // Watch the cached status for immediate updates
  final isCachedAdmin = ref.watch(cachedAdminStatusProvider);

  // Still watch the async provider to trigger the check if not cached
  final adminStatusAsync = ref.watch(isAdminProvider);

  // Return true if either the cache says so or the async provider has confirmed it
  final isAdmin = isCachedAdmin ||
      adminStatusAsync.when(
        data: (isAdmin) => isAdmin,
        loading: () => false,
        error: (error, stackTrace) {
          debugPrint('[Navigation] Error in admin provider: $error');
          return false;
        },
      );

  debugPrint(
      "[Navigation] Admin status computed: $isAdmin (authenticated: $isAuthenticated, cached: $isCachedAdmin)");
  return isAdmin;
}

/// Provider for all possible navigation destinations (including admin)
@riverpod
List<NavigationDestinationItem> allNavigationDestinations(
    AllNavigationDestinationsRef ref) {
  // Define all possible destinations including admin
  return [
    const NavigationDestinationItem(
      label: 'Home',
      path: '/',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    const NavigationDestinationItem(
      label: 'Menu',
      path: '/menu',
      icon: Icons.restaurant_menu_outlined,
      selectedIcon: Icons.restaurant_menu,
    ),
    const NavigationDestinationItem(
      label: 'Cart',
      path: '/carrito',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
    ),
    const NavigationDestinationItem(
      label: 'Orders',
      path: '/ordenes',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    // Admin tab appears next to the orders icon
    const NavigationDestinationItem(
      label: 'Admin',
      path: '/admin',
      icon: Icons.admin_panel_settings_outlined,
      selectedIcon: Icons.admin_panel_settings,
      isVisible: false, // Hidden by default
    ),
    const NavigationDestinationItem(
      label: 'Account',
      path: '/cuenta',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];
}

/// Provider for visible navigation destinations (optimized)
@riverpod
List<NavigationDestinationItem> navigationDestinations(
    NavigationDestinationsRef ref) {
  // Watch the auto-check provider to ensure admin status is checked on login
  ref.watch(autoCheckAdminStatusProvider);

  // Use the computed admin status provider to avoid unnecessary rebuilds
  final isAdmin = ref.watch(isAdminComputedProvider);
  final allDestinations = ref.watch(allNavigationDestinationsProvider);

  // Get current business navigation info to identify the business
  final businessInfo = ref.watch(currentBusinessNavigationProvider);
  final String? businessSlug = businessInfo?.businessSlug;

  // Default UI settings (shown by default if no business identified)
  bool showLandingPage = true;
  bool showOrders = true;

  // If we have a business slug, use it as the business ID for feature flags
  if (businessSlug != null) {
    // Get business UI settings asynchronously if a business is identified
    final businessUIAsync = ref.watch(businessUIProvider(businessSlug));

    // Apply UI settings if data is available, otherwise use defaults
    businessUIAsync.whenData((uiSettings) {
      showLandingPage = uiSettings.landingPage;
      showOrders = uiSettings.orders;
      debugPrint(
          '[Business UI] Settings loaded - Landing page: $showLandingPage, Orders: $showOrders');
    });
  }

  debugPrint('[Navigation] Navigation Provider Update:');
  debugPrint("  - Is Admin (computed): $isAdmin");
  debugPrint("  - Business Slug: ${businessSlug ?? "None"}");
  debugPrint("  - Show Landing: $showLandingPage, Show Orders: $showOrders");

  // Update visibility for admin tab and feature-controlled tabs
  final updatedDestinations = allDestinations.map((destination) {
    // Only modify specific tabs' visibility
    if (destination.path == '/admin') {
      debugPrint('  - Admin destination visibility: $isAdmin');
      return destination.copyWith(isVisible: isAdmin);
    } else if (destination.path == '/' &&
        !showLandingPage &&
        businessSlug != null) {
      debugPrint('  - Landing page visibility: $showLandingPage');
      return destination.copyWith(isVisible: showLandingPage);
    } else if (destination.path == '/ordenes' &&
        !showOrders &&
        businessSlug != null) {
      debugPrint('  - Orders page visibility: $showOrders');
      return destination.copyWith(isVisible: showOrders);
    }
    return destination;
  }).toList();

  // Return only visible destinations
  final visibleDestinations =
      updatedDestinations.where((item) => item.isVisible).toList();
  debugPrint(
      '[Navigation] Visible destinations: ${visibleDestinations.map((d) => "${d.label}(${d.path})").join(", ")}');

  return visibleDestinations;
}

/// Provider to determine the current tab index based on a path
@riverpod
int findTabIndexFromPath(FindTabIndexFromPathRef ref, String path) {
  final destinations = ref.watch(navigationDestinationsProvider);

  // Find the index of the destination whose path is a prefix of the given path
  for (int i = 0; i < destinations.length; i++) {
    final destination = destinations[i];

    // Special case for root path
    if (destination.path == '/' && path == '/') {
      return i;
    }

    // For other paths, check if the destination path is a prefix of the given path
    if (destination.path != '/' && path.startsWith(destination.path)) {
      return i;
    }
  }

  // Special handling for admin path
  if (path.startsWith('/admin')) {
    // Check if admin tab is visible in current destinations
    final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
    if (adminIndex >= 0) {
      return adminIndex;
    }

    // If admin tab isn't visible but user is on admin path, default to home
    return 0;
  }

  // Special handling for orders path
  if (path.startsWith('/ordenes')) {
    final ordersIndex = destinations.indexWhere((d) => d.path == '/ordenes');
    if (ordersIndex >= 0) {
      return ordersIndex;
    }
  }

  // Default to home tab if no match was found
  return 0;
}

/// Provider for the current selected tab index (for StatefulShellRoute)
@riverpod
class SelectedTabIndex extends _$SelectedTabIndex {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}

/// Provider for the current selected tab path
@riverpod
String selectedTabPath(SelectedTabPathRef ref) {
  final tabIndex = ref.watch(selectedTabIndexProvider);
  final destinations = ref.watch(navigationDestinationsProvider);

  if (tabIndex >= 0 && tabIndex < destinations.length) {
    return destinations[tabIndex].path;
  }

  return '/';
}

/// Check if the current path is an admin path
@riverpod
bool isAdminPath(IsAdminPathRef ref, String path) {
  return path.startsWith('/admin');
}
