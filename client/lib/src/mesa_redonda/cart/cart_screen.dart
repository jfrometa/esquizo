import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'cart_item_view.dart'; // Import the CartItem widget here

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key, required this.isAuthenticated});
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the cart items from the CartProvider
    final cartItems = ref.watch(cartProvider);

    // Calculate the total price for only regular dishes (exclude meal subscriptions)
    double totalPrice = cartItems.fold(
      0.0,
      (sum, item) => item.isMealSubscription
          ? sum // Skip meal subscriptions from the price calculation
          : sum + (double.tryParse(item.pricing) ?? 0.0) * item.quantity,
    );

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 3,
        title: const Text('Carrito'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = cartItems[index];

                      // Check if the item is a meal subscription
                      if (item.isMealSubscription) {
                        return ListTile(
                          leading: Image.asset(item.img),
                          title: Text(item.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remaining Meals: ${item.remainingMeals}',
                              ),
                              Text(
                                'Expires on: ${item.expirationDate.toLocal().toString().split(' ')[0]}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          trailing: item.remainingMeals > 0
                              ? ElevatedButton(
                                  onPressed: () {
                                    // Consume a meal from the subscription
                                    ref
                                        .read(cartProvider.notifier)
                                        .consumeMeal(item.title);
                                  },
                                  child: const Text('Consume Meal'),
                                )
                              : null, // Disable button if no meals remain
                        );
                      }

                      // Render regular dish items
                      return CartItemView(
                        img: item.img,
                        title: item.title,
                        description: item.description,
                        pricing: item.pricing.toString(),
                        offertPricing: item.offertPricing,
                        ingredients: item.ingredients,
                        isSpicy: item.isSpicy,
                        foodType: item.foodType,
                        quantity: item.quantity,
                        peopleCount: item.peopleCount,
                        onRemove: () {
                          ref
                              .read(cartProvider.notifier)
                              .decrementQuantity(item.title);
                        },
                        onAdd: () {
                          ref
                              .read(cartProvider.notifier)
                              .incrementQuantity(item.title);
                        },
                      );
                    },
                  ),
                ),
              ),
              _buildTotalSection(totalPrice, context),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the checkout screen
                    GoRouter.of(context).pushNamed(
                      AppRoute.checkout.name,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPaletteRedonda.primary,
                    foregroundColor: ColorsPaletteRedonda.white,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(
                    'Realizar pedido',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalSection(double totalPrice, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Subtotal (${totalPrice > 0 ? 'Items' : 'No Regular Items'}): ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color.fromARGB(255, 235, 66, 15),
                ),
          ),
          Text(
            '\$${totalPrice.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorsPaletteRedonda.primary,
                ),
          ),
        ],
      ),
    );
  }
}
