import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
// Replace ordering_providers import with catalog provider
import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/list_items/slide_home_menu_horizontal_item.dart';

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
    // Replace dishProvider with catalogItemsProvider
    final dishesAsync = ref.watch(catalogItemsProvider('menu'));
    final screenWidth = MediaQuery.sizeOf(context).width;

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
        // Handle AsyncValue states
        child: dishesAsync.when(
          data: (dishes) {
            // For wider screens, use a GridView; otherwise, a vertical ListView.
            return screenWidth > 600
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 1200
                          ? 3
                          : screenWidth > 900
                              ? 2
                              : 1,
                      // Adjust the childAspectRatio based on screen width to help the cards look balanced.
                      childAspectRatio: screenWidth > 1200
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
                      // Convert CatalogItem to Map for MenuDishCardHorizontal
                      final dishMap = {
                        'id': dish.id,
                        'title': dish.name,
                        'description': dish.description,
                        'pricing': 'S/ ${dish.price.toStringAsFixed(2)}',
                        'img': dish.imageUrl ??
                            'assets/images/placeholder_food.png',
                        'offertPricing':
                            dish.metadata['offertPricing']?.toString(),
                        'ingredients': dish.metadata['ingredients'] ??
                            ['Ingredient 1', 'Ingredient 2'],
                        'isSpicy': dish.metadata['isSpicy'] ?? false,
                        'foodType': dish.metadata['foodType'] ?? 'Main Course',
                        'isMealPlan': dish.metadata['isMealPlan'] ?? false,
                        'bestSeller': dish.metadata['bestSeller'] ?? false,
                        'rating': (dish.metadata['rating'] as double?) ?? 4.5,
                      };

                      return MenuDishCardHorizontal(
                        key: ValueKey('dish_$index'),
                        img: dishMap["img"],
                        title: dishMap["title"],
                        description: dishMap["description"],
                        pricing: dishMap["pricing"],
                        offertPricing: dishMap["offertPricing"],
                        ingredients: List<String>.from(dishMap["ingredients"]),
                        isSpicy: dishMap["isSpicy"],
                        foodType: dishMap["foodType"],
                        isMealPlan: dishMap["isMealPlan"],
                        index: index,
                        bestSeller: dishMap["bestSeller"],
                        rating: dishMap["rating"],
                        // Use a plus icon for the action button.
                        actionButton: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Se agregó ${dishMap['title']} al carrito'),
                                backgroundColor: Colors.brown[200],
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                            ref.read(cartProvider.notifier).addToCart(
                                  dishMap,
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
                      // Convert CatalogItem to Map for MenuDishCardHorizontal
                      final dishMap = {
                        'id': dish.id,
                        'title': dish.name,
                        'description': dish.description,
                        'pricing': 'S/ ${dish.price.toStringAsFixed(2)}',
                        'img': dish.imageUrl ?? 'assets/appIcon.png',
                        'offertPricing':
                            dish.metadata['offertPricing']?.toString(),
                        'ingredients': dish.metadata['ingredients'] ??
                            ['Ingredient 1', 'Ingredient 2'],
                        'isSpicy': dish.metadata['isSpicy'] ?? false,
                        'foodType': dish.metadata['foodType'] ?? 'Main Course',
                        'isMealPlan': dish.metadata['isMealPlan'] ?? false,
                        'bestSeller': dish.metadata['bestSeller'] ?? false,
                        'rating': (dish.metadata['rating'] as double?) ?? 4.5,
                      };

                      return MenuDishCardHorizontal(
                        key: ValueKey('dish_$index'),
                        img: dishMap["img"],
                        title: dishMap["title"],
                        description: dishMap["description"],
                        pricing: dishMap["pricing"],
                        offertPricing: dishMap["offertPricing"],
                        ingredients: List<String>.from(dishMap["ingredients"]),
                        isSpicy: dishMap["isSpicy"],
                        foodType: dishMap["foodType"],
                        isMealPlan: dishMap["isMealPlan"],
                        index: index,
                        bestSeller: dishMap["bestSeller"],
                        rating: dishMap["rating"],
                        actionButton: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Se agregó ${dishMap['title']} al carrito'),
                                backgroundColor: Colors.brown[200],
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                            ref.read(cartProvider.notifier).addToCart(
                                  dishMap,
                                  1,
                                );
                          },
                        ),
                      );
                    },
                  );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load dishes: $error'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.refresh(catalogItemsProvider('menu')),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
