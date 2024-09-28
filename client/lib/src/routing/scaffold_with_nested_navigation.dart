import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 450
        ? ScaffoldWithNavigationBar(
            body: navigationShell,
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch)
        : ScaffoldWithNavigationRail(
            body: navigationShell,
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch);
  }
}

// Helper function to calculate total quantity
int getTotalCartQuantity(List<CartItem> cartItems) {
  return cartItems.fold(0, (total, item) => total + item.quantity);
}

class ScaffoldWithNavigationBar extends ConsumerWidget {
  const ScaffoldWithNavigationBar({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the total quantity from cartProvider
    final cartItems = ref.watch(cartProvider);
    final totalQuantity = getTotalCartQuantity(cartItems);

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: ColorsPaletteRedonda.primary,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                    color: ColorsPaletteRedonda.primary,
                    fontWeight: FontWeight.bold); // Selected label color
              }
              return const TextStyle(
                  color: ColorsPaletteRedonda.deepBrown1,
                  fontWeight: FontWeight.bold); // Unselected label color
            },
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                    color: Colors.white); // Selected icon color
              }
              return const IconThemeData(
                  color:
                      ColorsPaletteRedonda.deepBrown1); // Unselected icon color
            },
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: List.generate(
              4, (index) => _buildDestination(index, totalQuantity)),
        ),
      ),
    );
  }

  NavigationDestination _buildDestination(int index, int totalQuantity) {
    IconData icon;
    String label;
    Widget iconWidget;

    switch (index) {
      case 0:
        icon = Icons.home;
        label = 'Inicio';
        iconWidget = Icon(icon);
        break;
      case 1:
        icon = Icons.restaurant_menu;
        label = 'Menu';
        iconWidget = Icon(icon);
        break;

      case 2:
        icon = Icons.shopping_cart;
        label = 'Carrito';
        iconWidget = Stack(
          clipBehavior:
              Clip.none, // Ensures the badge is visible outside the icon bounds
          children: [
            Icon(icon), // Base cart icon
            if (totalQuantity > 0)
              Positioned(
                top: -7, // Adjusts the vertical position of the badge
                right: -9, // Adjusts the horizontal position of the badge
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    '$totalQuantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        );
        break;

      case 3:
        icon = Icons.account_circle;
        label = 'Cuenta';
        iconWidget = Icon(icon);
        break;
      default:
        icon = Icons.home;
        label = 'Inicio';
        iconWidget = Icon(icon);
        break;
    }

    return NavigationDestination(
      icon: iconWidget,
      label: label,
    );
  }
}

class ScaffoldWithNavigationRail extends ConsumerWidget {
  const ScaffoldWithNavigationRail({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the total quantity from cartProvider
    final cartItems = ref.watch(cartProvider);
    final totalQuantity = getTotalCartQuantity(cartItems);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            indicatorColor: ColorsPaletteRedonda.primary,
            backgroundColor: Colors.white,
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: Colors.white),
            selectedLabelTextStyle: const TextStyle(
                color: ColorsPaletteRedonda.primary,
                fontWeight: FontWeight.bold),
            unselectedIconTheme:
                const IconThemeData(color: ColorsPaletteRedonda.deepBrown1),
            unselectedLabelTextStyle: const TextStyle(
                color: ColorsPaletteRedonda.deepBrown1,
                fontWeight: FontWeight.bold),
            destinations: List.generate(
                4, (index) => _buildRailDestination(index, totalQuantity)),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  // Updated destination to include badge for the cart icon
  NavigationRailDestination _buildRailDestination(
      int index, int totalQuantity) {
    IconData icon;
    String label;
    Widget iconWidget;

    switch (index) {
      case 0:
        icon = Icons.home;
        label = 'Inicio'.hardcoded;
        iconWidget = Icon(icon);
        break;
      case 1:
        icon = Icons.restaurant_menu;
        label = 'Menu'.hardcoded;
        iconWidget = Icon(icon);
        break;

      case 2:
        icon = Icons.shopping_cart;
        label = 'Carrito'.hardcoded;
        iconWidget = Stack(
          clipBehavior:
              Clip.none, // Ensures the badge is visible outside the icon bounds
          children: [
            Icon(
              icon,
            ), // Base cart icon
            if (totalQuantity > 0)
              Positioned(
                top: -7, // Adjusts the vertical position of the badge
                right: -9, // Adjusts the horizontal position of the badge
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    '$totalQuantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        );
        break;

      case 3:
        icon = Icons.account_circle;
        label = 'Cuenta'.hardcoded;
        iconWidget = Icon(icon);
        break;
      default:
        icon = Icons.home;
        label = 'Inicio'.hardcoded;
        iconWidget = Icon(icon);
        break;
    }

    return NavigationRailDestination(icon: iconWidget, label: Text(label));
  }
}
