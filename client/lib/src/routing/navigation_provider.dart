import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../src/mesa_redonda/admin/services/admin_providers.dart';

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
  // Base destinations always shown
  final baseDestinations = [
    NavigationDestinationItem(
      icon: Icons.home,
      label: 'Inicio',
      path: '/',
    ),
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
      icon: Icons.account_circle,
      label: 'Cuenta',
      path: '/cuenta',
    ),
  ];

  // Check if user is admin
  final isAdmin = ref.watch(isAdminProvider).value ?? false;

  // Add admin destination if user is admin
  if (isAdmin) {
    baseDestinations.add(
      NavigationDestinationItem(
        icon: Icons.admin_panel_settings,
        label: 'Admin',
        path: '/admin',
      ),
    );
  }

  return baseDestinations;
});