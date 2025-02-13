import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/navigation_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';



// Update the provider to include both catering and manual orders
final cateringItemCountProvider = StateProvider<int>((ref) {
  final cateringOrder = ref.watch(cateringOrderProvider);
  final manualQuote = ref.watch(manualQuoteProvider);
  
  final hasCateringOrder = (cateringOrder?.dishes.length ?? 0) > 0 ? 1 : 0;
  final hasManualQuote = (manualQuote?.dishes.length ?? 0) > 0 ? 1 : 0;
  
  return hasCateringOrder + hasManualQuote;
});

/// --------------------------------------------------------------------------
/// 1. Computed Provider to Lazily Calculate the Total Cart Quantity
/// --------------------------------------------------------------------------
final totalCartQuantityProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  final mealItems = ref.watch(mealOrderProvider);
  final cateringCount = ref.watch(cateringItemCountProvider);
  final cartTotal = cartItems.fold(0, (total, item) => total + item.quantity);
  final mealTotal = mealItems.length;
  return cartTotal + mealTotal + cateringCount;
});

/// --------------------------------------------------------------------------
/// 2. A Separate Widget for the Cart Badge to Limit Rebuilds
/// --------------------------------------------------------------------------
class CartBadge extends ConsumerWidget {
  final IconData icon;
  const CartBadge({Key? key, required this.icon}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalQuantity = ref.watch(totalCartQuantityProvider);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
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
  }
}

/// --------------------------------------------------------------------------
/// 3. ScaffoldWithNestedNavigation
/// --------------------------------------------------------------------------
class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 450
        ? ScaffoldWithNavigationBar(
            body: navigationShell,
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
          )
        : ScaffoldWithNavigationRail(
            body: navigationShell,
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
          );
  }
}

/// --------------------------------------------------------------------------
/// 4. ScaffoldWithNavigationBar (ConsumerStatefulWidget)
/// --------------------------------------------------------------------------
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

    // Listen to scroll events to hide/show the navigation bar (except for the "Cuenta" tab).
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
      // Ensure the navigation bar is visible on tab "Cuenta" (assumed index 3)
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
    final totalQuantity = ref.watch(totalCartQuantityProvider);

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
          destinations: destinations.map((dest) {
            return _buildDestination(dest, totalQuantity, destinations.indexOf(dest));
          }).toList(),
        ),
      ),
    );
  }

  NavigationDestination _buildDestination(
    NavigationDestinationItem destination,
    int totalQuantity,
    int index,
  ) {
    Widget iconWidget;
    if (destination.icon == Icons.shopping_cart) {
      // Use CartBadge for the shopping cart.
      iconWidget = const CartBadge(icon: Icons.shopping_cart);
    } else {
      iconWidget = Icon(destination.icon);
    }
    return NavigationDestination(
      icon: iconWidget,
      label: destination.label,
    );
  }
}

/// --------------------------------------------------------------------------
/// 5. ScaffoldWithNavigationRail (ConsumerWidget)
/// --------------------------------------------------------------------------
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
    final totalQuantity = ref.watch(totalCartQuantityProvider);

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
              fontWeight: FontWeight.bold,
            ),
            unselectedIconTheme:
                const IconThemeData(color: ColorsPaletteRedonda.deepBrown1),
            unselectedLabelTextStyle: const TextStyle(
              color: ColorsPaletteRedonda.deepBrown1,
              fontWeight: FontWeight.bold,
            ),
            destinations: destinations
                .map((dest) => _buildRailDestination(
                      dest,
                      totalQuantity,
                      destinations.indexOf(dest),
                    ))
                .toList(),
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
    int index,
  ) {
    Widget iconWidget;
    if (destination.icon == Icons.shopping_cart) {
      iconWidget = const CartBadge(icon: Icons.shopping_cart);
    } else {
      iconWidget = Icon(destination.icon);
    }
    return NavigationRailDestination(
      icon: iconWidget,
      label: Text(destination.label),
    );
  }
}