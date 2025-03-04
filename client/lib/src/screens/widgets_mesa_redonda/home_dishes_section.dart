import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/list_items/slide_home_menu_horizontal_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
 
/// -----------------------------------------
/// HOME DISHES SECTION
/// -----------------------------------------
class HomeDishesSection extends ConsumerWidget {
  const HomeDishesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 10.0),
        _buildDishList(context, ref),
      ],
    );
  }


Widget _buildDishList(BuildContext context, WidgetRef ref) {
  final dishes = ref.watch(dishProvider);
  final screenWidth = MediaQuery.of(context).size.width;

  return Focus(
    onKeyEvent: (FocusNode node, KeyEvent event) {
      // Optional arrow key logic for keyboard navigation
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          node.nextFocus();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          node.previousFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    },
    child: ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      // For wider screens, use a GridView; otherwise, a vertical ListView.
      child: screenWidth > 600
          ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:  
                    screenWidth > 1200
                    ? 3
                    
                    : screenWidth > 900
                        ? 2
                        : 1,
                // Adjust the childAspectRatio based on screen width to help the cards look balanced.
                childAspectRatio: 
                 
                screenWidth > 1200
                    ? 2
                    : screenWidth > 900
                        ? 2.3
                        : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: dishes.length,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (BuildContext context, int index) {
                final dish = dishes[index];
                return MenuDishCardHorizontal(
                  key: ValueKey('dish_$index'),
                  img: dish["img"],
                  title: dish["title"],
                  description: dish["description"],
                  pricing: dish["pricing"],
                  offertPricing: dish["offertPricing"],
                  ingredients: List<String>.from(dish["ingredients"]),
                  isSpicy: dish["isSpicy"],
                  foodType: dish["foodType"],
                  isMealPlan: dish["isMealPlan"] ?? false,
                  index: index,
                  bestSeller: dish["bestSeller"] ?? false,
                  rating: dish["rating"],
                  // Use a plus icon for the action button.
                  actionButton: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Se agregó ${dish['title']} al carrito'),
                          backgroundColor: Colors.brown[200],
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                      ref.read(cartProvider.notifier).addToCart(
                        dish.cast<String, dynamic>(),
                        1,
                      );
                    },
                  ),
                );
              },
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dishes.length,
              // padding: const EdgeInsets.symmetric(horizontal: 10.0),
              itemBuilder: (BuildContext context, int index) {
                final dish = dishes[index];
                return MenuDishCardHorizontal(
                  key: ValueKey('dish_$index'),
                  img: dish["img"],
                  title: dish["title"],
                  description: dish["description"],
                  pricing: dish["pricing"],
                  offertPricing: dish["offertPricing"],
                  ingredients: List<String>.from(dish["ingredients"]),
                  isSpicy: dish["isSpicy"],
                  foodType: dish["foodType"],
                  isMealPlan: dish["isMealPlan"] ?? false,
                  index: index,
                  bestSeller: dish["bestSeller"] ?? false,
                  rating: dish["rating"],
                  actionButton: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Se agregó ${dish['title']} al carrito'),
                          backgroundColor: Colors.brown[200],
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                      ref.read(cartProvider.notifier).addToCart(
                        dish.cast<String, dynamic>(),
                        1,
                      );
                    },
                  ),
                );
              },
            ),
    ),
  );
}
}