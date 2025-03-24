import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/admin_management_service.dart';


class NavigationDestinationItem {
  final IconData icon;
  final String label;
  final String path;
  
  NavigationDestinationItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}

final navigationDestinationsProvider = Provider<List<NavigationDestinationItem>>((ref) {

  final isAdmin = ref.watch(isAdminProvider).value ?? false;

  // Base destinations always shown
  final baseDestinations = [
    NavigationDestinationItem(
      icon: Icons.home,
      label: 'Inicio',
      path: '/',
    ),
    //     NavigationDestinationItem(
    //   icon: Icons.home,
    //   label: 'Local',
    //   path: '/local',
    // ),
    NavigationDestinationItem(
      icon: Icons.restaurant_menu,
      label: 'Menu',
      path: '/menu',
    ),
    NavigationDestinationItem(
      icon: Icons.shopping_cart,
      label: 'Carrito',
      path: '/carrito',
    ),
    NavigationDestinationItem(
      path: '/ordenes',  // New route
      icon: Icons.pending_actions,
      label: 'Ordenes',
    ),
    NavigationDestinationItem(
      path: '/cuenta',
      icon: Icons.person_outline,
      label: 'Cuenta',

    ),
      if (isAdmin)   NavigationDestinationItem(
        icon: Icons.admin_panel_settings,
        label: 'Admin',
        path: '/admin',
      ),
  ];

  return baseDestinations;
 
});
