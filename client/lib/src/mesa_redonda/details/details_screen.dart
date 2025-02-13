import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  const DetailsScreen({super.key});

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  String selectedFoodType = 'All'; // Default filter to show all dishes

// Stack(
//           clipBehavior:
//               Clip.none, // Ensures the badge is visible outside the icon bounds
//           children: [
//             Icon(
//               icon,
//             ), // Base cart icon
//             if (totalQuantity > 0)
//               Positioned(
//                 top: -7, // Adjusts the vertical position of the badge
//                 right: -9, // Adjusts the horizontal position of the badge
//                 child: CircleAvatar(
//                   radius: 8,
//                   backgroundColor: Colors.red,
//                   child: Text(
//                     '$totalQuantity',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         );

  @override
  Widget build(BuildContext context) {
    final dishes = ref.watch(dishProvider);
    final cart = ref.watch(cartProvider);
    final filteredDishes = selectedFoodType == 'All'
        ? dishes
        : dishes.where((dish) => dish['foodType'] == selectedFoodType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platos'),
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    // Navigate to the cart screen
                    // context.push('/cart'); // Assuming the cart route is '/cart'
                    context.goNamed(
                      AppRoute.homecart.name,
                    );
                  },
                ),
                // if (cart.isNotEmpty)
                //   Positioned(
                //     top: 0, // Adjusts the vertical position of the badge
                //     right: 0, // Adjusts the horizontal position of the badge
                //     child: CircleAvatar(
                //       radius: 8,
                //       backgroundColor: Colors.red,
                //       child: Text(
                //         '${cart.length}',
                //         style: const TextStyle(
                //           color: Colors.white,
                //           fontSize: 10,
                //         ),
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: filteredDishes.length,
          itemBuilder: (context, index) {
            final dish = filteredDishes[index];
            return GestureDetector(
              onTap: () {
                // Navigate to the details screen
                context.goNamed(
                  AppRoute.addDishToOrder.name,
                  pathParameters: {"dishId": index.toString()},
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dish Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          dish['img'],
                          width: double.infinity,
                          height: 150.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Dish Title
                      Text(
                        dish['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColorsPaletteRedonda.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        dish['description'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Ingredients
                      Text(
                        'Ingredientes: ${dish['ingredients'].join(', ')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Price and Add to Cart Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Text(
                            '\$${dish['pricing']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorsPaletteRedonda.primary,
                            ),
                          ),
                          // Add to Cart Button
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Se agregó ${dish['title']}  al carrito'),
                                  backgroundColor: Colors.brown[
                                      200], // Light brown background color
                                  duration: const Duration(
                                      milliseconds:
                                          500), // Display for half a second
                                ),
                              );
                              // Add the dish directly to the cart
                              ref.read(cartProvider.notifier).addToCart(
                                    dish.cast<String, dynamic>(),
                                    1,
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Agregar al carrito'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
