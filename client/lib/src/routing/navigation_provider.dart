import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_panel/admin_management_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/auth_providers.dart';

part 'navigation_provider.g.dart';

/// Model class for navigation destination items
class NavigationDestinationItem {
  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationDestinationItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
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
}

/// Provider for navigation destinations - customize this based on your app's requirements
@riverpod
List<NavigationDestinationItem> navigationDestinations(
    NavigationDestinationsRef ref) {
  final isAdmin = ref.watch(cachedAdminStatusProvider);
  final authState = ref.watch(authStateChangesProvider);
  final isAuthenticated = authState.value != null;

  final baseDestinations = [
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
      label: 'Account',
      path: '/cuenta',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  // Add admin destination if the user is an admin
  if (isAdmin && isAuthenticated) {
    return [
      ...baseDestinations,
      const NavigationDestinationItem(
        label: 'Admin',
        path: '/admin',
        icon: Icons.admin_panel_settings_outlined,
        selectedIcon: Icons.admin_panel_settings,
      ),
    ];
  }

  return baseDestinations;
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

  // Special handling for admin and other paths
  if (path.startsWith('/admin')) {
    // Find admin tab index if it exists
    final adminIndex = destinations.indexWhere((d) => d.path == '/admin');
    if (adminIndex >= 0) {
      return adminIndex;
    }
  }

  if (path.startsWith('/ordenes')) {
    // Find orders tab index if it exists
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
