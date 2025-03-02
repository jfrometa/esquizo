import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/model/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/dish_item.dart';

class AllDishesMenuHomeScreen extends ConsumerStatefulWidget {
  const AllDishesMenuHomeScreen({super.key});

  @override
  ConsumerState<AllDishesMenuHomeScreen> createState() => _AllDishesMenuHomeScreenState();
}

class _AllDishesMenuHomeScreenState extends ConsumerState<AllDishesMenuHomeScreen> {
  String selectedFoodType = 'All'; // Default filter to show all dishes

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
                    context.goNamed(
                      AppRoute.homecart.name,
                    );
                  },
                ),
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
            
            // Use DishItem instead of custom card implementation
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DishItem(
                img: dish['img'],
                title: dish['title'],
                description: dish['description'],
                pricing: dish['pricing'],
                ingredients: List<String>.from(dish['ingredients']),
                isSpicy: dish['isSpicy'] ?? false,
                foodType: dish['foodType'] ?? 'Other',
                index: index,
                dishData: dish,
                // Don't hide ingredients in the details view
                hideIngredients: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
