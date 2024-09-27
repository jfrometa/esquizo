import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';
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
                  color: ColorsPaletteRedonda.deepBrown1); // Unselected icon color
            },
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: List.generate(4, (index) => _buildDestination(index)),
        ),
      ),
    );
  }

  NavigationDestination _buildDestination(int index) {
    IconData icon;
    String label;
    switch (index) {
      case 0:
        icon = Icons.home;
        label = 'Inicio';
        break;
      case 1:
        icon = Icons.shopping_cart;
        label = 'Carrito';
        break;
      case 2:
        icon = Icons.checklist_rtl;
        label = 'Confirmar';
        break;
      case 3:
        icon = Icons.account_circle;
        label = 'Cuenta';
        break;
      default:
        icon = Icons.home;
        label = 'Inicio';
        break;
    }

    return NavigationDestination(
      icon: Icon(icon),
      label: label,
    );
  }
}

class ScaffoldWithNavigationRail extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            destinations:
                List.generate(4, (index) => _buildRailDestination(index)),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }

  NavigationRailDestination _buildRailDestination(int index) {
    IconData icon;
    String label;
    switch (index) {
      case 0:
        icon = Icons.home;
        label = 'Inicio'.hardcoded;
        break;
      case 1:
        icon = Icons.shopping_cart;
        label = 'Carrito'.hardcoded;
        break;
      case 2:
        icon = Icons.checklist_rtl;
        label = 'Confirmar'.hardcoded;
        break;
      case 3:
        icon = Icons.account_circle;
        label = 'Cuenta'.hardcoded;
        break;
      default:
        icon = Icons.home;
        label = 'Inicio'.hardcoded;
        break;
    }
    return NavigationRailDestination(icon: Icon(icon), label: Text(label));
  }
}
