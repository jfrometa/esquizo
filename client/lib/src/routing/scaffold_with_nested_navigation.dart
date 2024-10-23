import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

final cateringItemCountProvider = StateProvider<int>((ref) {
  final cateringOrder = ref.watch(cateringOrderProvider);
  return (cateringOrder?.dishes.length ?? 0) > 0 ? 1 : 0;
});




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
// int getTotalCartQuantity(List<CartItem> cartItems) {
//   return cartItems.fold(0, (total, item) => total + item.quantity);
// }

// Helper function to calculate total quantity from multiple providers
int getTotalQuantity(
    List<CartItem> cartItems, List<CartItem> mealItems, int cateringCount) {
  final cartTotal = cartItems.fold(0, (total, item) => total + item.quantity);
  final mealTotal = mealItems.length;
  return cartTotal + mealTotal + cateringCount;
}

class ScaffoldWithNavigationBar extends ConsumerStatefulWidget {
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
  ScaffoldWithNavigationBarState createState() =>
      ScaffoldWithNavigationBarState();
}

class ScaffoldWithNavigationBarState
    extends ConsumerState<ScaffoldWithNavigationBar> {
  bool _isVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Add scroll listener to hide/show the navigation bar on all tabs except "Cuenta"
    _scrollController.addListener(() {
      if (widget.currentIndex != 3) {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_isVisible) {
            setState(() {
              _isVisible = false;
            });
          }
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!_isVisible) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
    });
  }

  void _goBranch(int index) {
    setState(() {
      // Show the navigation bar when navigating, and keep it visible on "Cuenta" tab
      _isVisible = index == 3 ? true : _isVisible;
    });
    widget.onDestinationSelected(index);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(navigationDestinationsProvider);
    final cartItems = ref.watch(cartProvider);
    // final totalQuantity = getTotalCartQuantity(cartItems);

    final mealItems = ref.watch(mealOrderProvider);
    final cateringCount = ref.watch(cateringItemCountProvider);

    // Calculating the total quantity
    final totalQuantity = getTotalQuantity(cartItems, mealItems, cateringCount);

    return Scaffold(
      body: widget.body,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: ColorsPaletteRedonda.primary,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: ColorsPaletteRedonda.primary,
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(
              color: ColorsPaletteRedonda.deepBrown1,
              fontWeight: FontWeight.bold,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? const IconThemeData(color: Colors.white)
                : const IconThemeData(color: ColorsPaletteRedonda.deepBrown1);
          }),
        ),
        child: NavigationBar(
          selectedIndex: widget.currentIndex,
          onDestinationSelected: _goBranch,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: destinations.map((dest) => 
            _buildDestination(
              dest,
              totalQuantity,
              destinations.indexOf(dest)
            )
          ).toList(),
        ),
      ),
    );
  }


  NavigationDestination _buildDestination(
    NavigationDestinationItem destination,
    int totalQuantity,
    int index
  ) {
    Widget iconWidget;

    if (destination.icon == Icons.shopping_cart) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(destination.icon),
          if (totalQuantity > 0)
            Positioned(
              top: -7,
              right: -9,
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
    } else {
      iconWidget = Icon(destination.icon);
    }

    return NavigationDestination(
      icon: iconWidget,
      label: destination.label,
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
    final destinations = ref.watch(navigationDestinationsProvider);
    // Get the total quantity from cartProvider
    final cartItems = ref.watch(cartProvider);
    // final totalQuantity = getTotalCartQuantity(cartItems);

    final mealItems = ref.watch(mealOrderProvider);
    final cateringCount = ref.watch(cateringOrderProvider)?.dishes.length ?? 0;

    // Calculating the total quantity
    final totalQuantity = getTotalQuantity(cartItems, mealItems, cateringCount);

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
            destinations: destinations.map((dest) =>
              _buildRailDestination(
                dest,
                totalQuantity,
                destinations.indexOf(dest)
              )
            ).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }


  NavigationRailDestination _buildRailDestination(
    NavigationDestinationItem destination,
    int totalQuantity,
    int index
  ) {
    Widget iconWidget;

    if (destination.icon == Icons.shopping_cart) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(destination.icon),
          if (totalQuantity > 0)
            Positioned(
              top: -7,
              right: -9,
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
    } else {
      iconWidget = Icon(destination.icon);
    }

    return NavigationRailDestination(
      icon: iconWidget,
      label: Text(destination.label),
    );
  }
}
