import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/catering_cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/meal_subscription_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'cart_item_view.dart'; // Import the CartItemView here

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key, required this.isAuthenticated});
  final bool isAuthenticated;

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends ConsumerState<CartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Three tabs
    // Add listener to track the current tab index
    _tabController.addListener(() {
      setState(() {
        // Update the state whenever the tab changes
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cateringOrder = ref.watch(cateringOrderProvider);
    final mealItems = ref.watch(mealOrderProvider);

    // Separate items by type for each tab
    final List<CartItem> dishes = cartItems
        .where(
            (item) => !item.isMealSubscription && item.foodType != 'Catering')
        .toList();
    final List<CateringOrderItem> cateringItems =
        cateringOrder != null ? [cateringOrder] : [];
    final List<CartItem> mealSubscriptions = mealItems;

    // Determine which items are in the current tab
    List<dynamic> currentTabItems;
    int currentTabIndex = _tabController.index;

    if (currentTabIndex == 0) {
      currentTabItems = mealSubscriptions;
    } else if (currentTabIndex == 1) {
      currentTabItems = cateringItems;
    } else {
      currentTabItems = dishes;
    }

    // Calculate total price only for the current tab's items
    final double totalPrice = _calculateTabTotalPrice(currentTabItems);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 3,
        title: const Text('Carrito'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Subscripciones'),
            Tab(text: 'Catering'),
            Tab(text: 'Platos'),
          ],
          labelColor: ColorsPaletteRedonda.primary,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubscripcionesTab(mealSubscriptions),
                _buildCateringTab(cateringOrder),
                _buildPlatosTab(dishes),
              ],
            ),
          ),
          _buildTotalSection(totalPrice, context),
          // Pass all item lists (dishes, cateringItems, mealSubscriptions) to the button
          _buildCheckoutButton(
              context, totalPrice, dishes, cateringItems, mealSubscriptions),
        ],
      ),
    );
  }

  // Total price calculator for the active tab
  double _calculateTabTotalPrice(List<dynamic> items) {
    if (items.isEmpty) return 0.0;

    if (items.first is CateringOrderItem) {
      return items.fold<double>(
        0.0,
        (sum, item) => (item as CateringOrderItem).totalPrice,
      );
    } else {
      return items.fold<double>(
        0.0,
        (sum, item) =>
            sum +
            ((double.tryParse((item as CartItem).pricing) ?? 0.0) *
                item.quantity),
      );
    }
  }

  Widget _buildCheckoutButton(
      BuildContext context,
      double totalPrice,
      List<CartItem> dishes,
      List<CateringOrderItem> cateringItems,
      List<CartItem> mealSubscriptions) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: totalPrice > 0
            ? () {
                // Get the current tab index
                int currentTabIndex = _tabController.index;
                List<dynamic> currentTabItems;

                if (currentTabIndex == 0) {
                  currentTabItems = mealSubscriptions;
                } else if (currentTabIndex == 1) {
                  currentTabItems = cateringItems;
                } else {
                  currentTabItems = dishes;
                }

                // Navigate to CheckoutScreen using GoRouter and pass the current tab's items
                GoRouter.of(context).pushNamed(
                  AppRoute.checkout.name,
                  extra:
                      currentTabItems, // Pass the current tab's items to the CheckoutScreen
                );
              }
            : null, // Disable if no items to checkout
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsPaletteRedonda.primary,
          foregroundColor: ColorsPaletteRedonda.white,
          minimumSize: const Size(double.infinity, 56),
        ),
        child: const Text('Realizar pedido'),
      ),
    );
  }

  // Subscription tab builder
  Widget _buildSubscripcionesTab(List<CartItem> mealItems) {
    if (mealItems.isEmpty) {
      return const Center(child: Text('No meal subscriptions found.'));
    }
    return ListView.builder(
      itemCount: mealItems.length,
      itemBuilder: (context, index) {
        final item = mealItems[index];
        return MealSubscriptionItemView(
          item: item,
          onConsumeMeal: () =>
              ref.read(mealOrderProvider.notifier).consumeMeal(item.title),
          onRemoveFromCart: () =>
              ref.read(mealOrderProvider.notifier).removeFromCart(item.id),
        );
      },
    );
  }

  // Catering tab builder
  Widget _buildCateringTab(CateringOrderItem? cateringItems) {
    if (cateringItems == null) {
      return const Center(child: Text('No catering items found.'));
    }
    return SingleChildScrollView(
      child: CateringCartItemView(
        order: cateringItems,
        onRemoveFromCart: () =>
            ref.read(cateringOrderProvider.notifier).clearCateringOrder(),
      ),
    );
  }

  // Platos tab builder
  Widget _buildPlatosTab(List<CartItem> platosItems) {
    if (platosItems.isEmpty) {
      return const Center(child: Text('No dishes found.'));
    }
    return ListView.builder(
      itemCount: platosItems.length,
      itemBuilder: (context, index) {
        final item = platosItems[index];
        return CartItemView(
          img: item.img,
          title: item.title,
          description: item.description,
          pricing: item.pricing,
          offertPricing: item.offertPricing,
          ingredients: item.ingredients,
          isSpicy: item.isSpicy,
          foodType: item.foodType,
          quantity: item.quantity,
          onRemove: () =>
              ref.read(cartProvider.notifier).decrementQuantity(item.title),
          onAdd: () =>
              ref.read(cartProvider.notifier).incrementQuantity(item.title),
        );
      },
    );
  }

  Widget _buildTotalSection(double totalPrice, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Subtotal: ',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: const Color.fromARGB(255, 235, 66, 15)),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                .format(totalPrice),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: ColorsPaletteRedonda.primary),
          ),
        ],
      ),
    );
  }
}
