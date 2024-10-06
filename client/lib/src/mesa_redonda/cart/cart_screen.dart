import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/plans/plans.dart';
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

    // Calculate the total price for both regular dishes and meal subscriptions
    double totalPrice = cartItems.fold(
      0.0,
      (sum, item) {
        if (item.isMealSubscription) {
          // Include the price of meal subscription in the total
          double price = double.tryParse(cleanPrice(item.pricing)) ?? 0.0;
          return sum + price;
        } else {
          // Calculate regular dish price
          return sum + (double.tryParse(item.pricing) ?? 0.0) * item.quantity;
        }
      },
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
                        return MealSubscriptionItemView(
                          item: item,
                          onConsumeMeal: () {
                            // Consume a meal from the subscription
                            ref
                                .read(cartProvider.notifier)
                                .consumeMeal(item.title);
                          },
                          onRemoveFromCart: () {
                            ref
                                .read(cartProvider.notifier)
                                .removeFromCart(item.id);
                          },
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
                    // Check if the cart is empty
                    if (cartItems.isEmpty) {
                      // Show a Snackbar if the cart is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Debe agregar artículos al carrito antes de realizar el pedido.'),
                          duration: Duration(seconds: 3), // Snackbar duration
                        ),
                      );
                    } else {
                      // Navigate to the checkout screen if cart has items
                      GoRouter.of(context).pushNamed(
                        AppRoute.checkout.name,
                      );
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
                      fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // Clean price function for subtotal calculation
  String cleanPrice(String input) {
    return input.replaceAll(RegExp(r'[^\d.]'), '');
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
            NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                .format(totalPrice),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ColorsPaletteRedonda.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class MealSubscriptionItemView extends ConsumerStatefulWidget {
  final CartItem item;
  final VoidCallback onConsumeMeal;
  final VoidCallback onRemoveFromCart; // New callback for removal action

  const MealSubscriptionItemView({
    super.key,
    required this.item,
    required this.onConsumeMeal,
    required this.onRemoveFromCart, // Include callback for removing from cart
  });

  @override
  _MealSubscriptionItemViewState createState() =>
      _MealSubscriptionItemViewState();
}

class _MealSubscriptionItemViewState
    extends ConsumerState<MealSubscriptionItemView> {
  bool isLoading = false; // To manage the button loading state

  @override
  Widget build(BuildContext context) {
    // Map plan ids to appropriate icons
    IconData planIcon;
    switch (widget.item.id) {
      case 'basico':
        planIcon = Icons.emoji_food_beverage; // Represents basic plan
        break;
      case 'estandar':
        planIcon = Icons.local_cafe; // Represents standard plan
        break;
      case 'premium':
        planIcon = Icons.local_dining; // Represents premium plan
        break;
      default:
        planIcon = Icons.fastfood;
    }

    // Get the plan description from the provider
    final mealPlans = ref.watch(mealPlansProvider);
    final plan = mealPlans.firstWhere(
      (plan) => plan.id == widget.item.id,
      orElse: () => MealPlan(
        id: '',
        longDescription: 'Plan no encontrado',
        howItWorks: '',
        totalMeals: 0,
        mealsRemaining: '',
        img: '',
        title: 'Plan desconocido',
        price: '',
        features: [],
        description: 'Este plan no está disponible o fue removido.',
      ),
    );

    // Clean the price
    String cleanedPrice = cleanPrice(plan.price);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: ColorsPaletteRedonda.softBrown,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with trash icon and plan icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Plan Icon and Name
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          planIcon,
                          size: 48,
                          color: ColorsPaletteRedonda.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            plan.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: ColorsPaletteRedonda
                          .orange, // Trash icon color set to orange
                      size: 28,
                    ),
                    onPressed: widget.onRemoveFromCart, // Handle removal
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Plan Description
              Text(
                plan.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              // Plan Price
              Text(
                'Precio: \$${cleanedPrice}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorsPaletteRedonda.primary,
                    ),
              ),
              const SizedBox(height: 8),
              // Remaining Meals and Expiration Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comidas restantes: ${widget.item.remainingMeals}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: ColorsPaletteRedonda.deepBrown1,
                        ),
                  ),
                  Text(
                    'Expira: ${DateFormat('dd/MM/yyyy').format(widget.item.expirationDate)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to clean the price string and leave only numbers
  String cleanPrice(String input) {
    // Use RegExp to replace all non-digit and non-decimal characters
    String cleaned = input.replaceAll(RegExp(r'[^\d.]'), '');
    return cleaned;
  }
}
