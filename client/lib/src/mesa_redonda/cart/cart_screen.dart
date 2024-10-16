import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watching each provider for separate tabs
    final cartItems = ref.watch(cartProvider);
    final cateringItems = ref.watch(cateringOrderProvider);
    final mealItems = ref.watch(mealOrderProvider);

    // Debugging output for each provider
    print('Cart Items: ${cartItems.length}');
    print('Catering Items: ${cateringItems.length}');
    print('Meal Subscription Items: ${mealItems.length}');
    mealItems.forEach((item) => print('Meal Item: ${item.title}, Quantity: ${item.quantity}'));

    final totalPrice = _calculateTotalPrice(cartItems, cateringItems, mealItems);

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
                _buildSubscripcionesTab(mealItems),
                _buildCateringTab(cateringItems),
                _buildPlatosTab(cartItems),
              ],
            ),
          ),
          _buildTotalSection(totalPrice, context),
          _buildCheckoutButton(context, totalPrice),
        ],
      ),
    );
  }

  // Subscription tab builder
  Widget _buildSubscripcionesTab(List<CartItem> mealItems) {
    if (mealItems.isEmpty) {
      return Center(child: Text('No meal subscriptions found.'));
    }
    return ListView.builder(
      itemCount: mealItems.length,
      itemBuilder: (context, index) {
        final item = mealItems[index];
        print('Rendering meal item: ${item.title} with quantity ${item.quantity}');
        return MealSubscriptionItemView(
          item: item,
          onConsumeMeal: () {
            print('Consuming meal: ${item.title}');
            ref.read(mealOrderProvider.notifier).consumeMeal(item.title);
          },
          onRemoveFromCart: () {
            print('Removing meal subscription: ${item.title}');
            ref.read(mealOrderProvider.notifier).removeFromCart(item.id);
          },
        );
      },
    );
  }

  // Catering tab builder using the CateringOrderProvider
  Widget _buildCateringTab(List<CateringOrderItem> cateringItems) {
    if (cateringItems.isEmpty) {
      return Center(child: Text('No catering items found.'));
    }
    return ListView.builder(
      itemCount: cateringItems.length,
      itemBuilder: (context, index) {
        final item = cateringItems[index];
        return CateringCartItemView(
          order: item,
          onRemoveFromCart: () {
            print('Removing catering item: ${item}');
            ref.read(cateringOrderProvider.notifier).removeFromCart(index);
          },
        );
      },
    );
  }

  // Platos tab builder for dish items using CartItemView
  Widget _buildPlatosTab(List<CartItem> platosItems) {
    if (platosItems.isEmpty) {
      return Center(child: Text('No dishes found.'));
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
          onRemove: () => ref.read(cartProvider.notifier).decrementQuantity(item.title),
          onAdd: () => ref.read(cartProvider.notifier).incrementQuantity(item.title),
          peopleCount: item.peopleCount,
          sideRequest: item.sideRequest,
        );
      },
    );
  }

  double _calculateTotalPrice(List<CartItem> cartItems, List<CateringOrderItem> cateringItems, List<CartItem> mealItems) {
    double cartTotal = cartItems.fold(0.0, (sum, item) => sum + (double.tryParse(item.pricing) ?? 0.0) * item.quantity);
    double cateringTotal = cateringItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    double mealTotal = mealItems.fold(0.0, (sum, item) => sum + (double.tryParse(item.pricing) ?? 0.0) * item.quantity);
    return cartTotal + cateringTotal + mealTotal;
  }

  Widget _buildTotalSection(double totalPrice, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Subtotal: ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color.fromARGB(255, 235, 66, 15),
                ),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(totalPrice),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorsPaletteRedonda.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          if (totalPrice <= 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Debe agregar artículos al carrito antes de realizar el pedido.'),
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            Navigator.pushNamed(context, AppRoute.checkout.name);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsPaletteRedonda.primary,
          foregroundColor: ColorsPaletteRedonda.white,
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Text(
          'Realizar pedido',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
          ),
        ),
      ),
    );
  }
}