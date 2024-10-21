import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class AddToOrderScreen extends ConsumerStatefulWidget {
  const AddToOrderScreen({super.key, required this.index});
  final int index; // Index passed from the previous screen

  @override
  ConsumerState<AddToOrderScreen> createState() => _AddToOrderScreenState();
}

class _AddToOrderScreenState extends ConsumerState<AddToOrderScreen> {
  late final Map<String, dynamic> selectedItem; // The selected dish
  int quantity = 1; // Default quantity set to 1

  @override
  void initState() {
    super.initState();
    // Fetch the dish data from the dishProvider based on the index
    selectedItem = ref.read(dishProvider)[widget.index];
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the current cart state to check for active subscriptions
    final cartItems = ref.watch(cartProvider);
    bool hasActiveSubscription = false;

    // Check if any meal subscription is active and has remaining meals
    for (var item in cartItems) {
      if (item.isMealSubscription && item.remainingMeals > 0) {
        hasActiveSubscription = true;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        forceMaterialTransparency: true,
        title: Text(
          selectedItem['title'],
        ),
        leading: IconButton(
          style: IconButton.styleFrom(elevation: 3),
          icon:
              const Icon(Icons.arrow_back, color: ColorsPaletteRedonda.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300, // Image max height
                    width: double.infinity,
                    child: Image.asset(selectedItem['img'], fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      selectedItem['title'],
                      style: const TextStyle(
                        color: ColorsPaletteRedonda.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "\$${(double.tryParse(selectedItem['pricing'].toString())?.toStringAsFixed(2) ?? '0.00')}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.orangeAccent[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      selectedItem['description'],
                      style: const TextStyle(
                        color: ColorsPaletteRedonda.deepBrown,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Tipo: ${selectedItem['foodType']}",
                          style: const TextStyle(
                            color: ColorsPaletteRedonda.deepBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        if (selectedItem['isSpicy'])
                          const Text(
                            "Picante 🌶️",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Ingredientes:",
                      style: TextStyle(
                        color: ColorsPaletteRedonda.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: selectedItem['ingredients']
                          .map<Widget>((ingredient) => Chip(
                                side: BorderSide.none,
                                label: Text(
                                  ingredient,
                                  style: const TextStyle(
                                      color: ColorsPaletteRedonda.white,
                                      fontStyle: FontStyle.normal),
                                ),
                                backgroundColor: ColorsPaletteRedonda.primary,
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quantity section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                style: IconButton.styleFrom(elevation: 3),
                icon: const Icon(Icons.remove,
                    color: ColorsPaletteRedonda.lightBrown),
                onPressed: () {
                  setState(() {
                    if (quantity > 1) {
                      quantity--; // Decrease quantity
                    }
                  });
                },
              ),
              Text(
                quantity.toString(), // Display the current quantity
                style: const TextStyle(
                    fontSize: 24, color: ColorsPaletteRedonda.primary),
              ),
              IconButton(
                icon: const Icon(Icons.add,
                    color: ColorsPaletteRedonda.lightBrown),
                onPressed: () {
                  setState(() {
                    quantity++; // Increase quantity
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Check if there is an active subscription
                  if (hasActiveSubscription) {
                    // Consume the meal from the subscription
                    ref
                        .read(cartProvider.notifier)
                        .consumeMeal(selectedItem['title']);
                  } else {
                    // Otherwise, add the item to the cart
                    ref
                        .read(cartProvider.notifier)
                        .addToCart(selectedItem, quantity);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Se agregó ${selectedItem['title']}  al carrito'),
                      backgroundColor:
                          Colors.brown[200], // Light brown background color
                      duration: const Duration(
                          milliseconds: 500), // Display for half a second
                    ),
                  );
                  // Navigate to the cart screen
                  GoRouter.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsPaletteRedonda.primary,
                  elevation: 3,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  hasActiveSubscription
                      ? 'Consumir del plan'
                      : 'Agregar al carrito',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                    color: ColorsPaletteRedonda.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
