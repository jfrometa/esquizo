import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/slide_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class HomeDishesSection extends StatelessWidget {
  final List<dynamic>? dishes;
  const HomeDishesSection({super.key, this.dishes});

  @override
  Widget build(BuildContext context) {
    final availableDishes = dishes;
    // For performance, if no dishes available, show a placeholder.
    if (availableDishes == null || availableDishes.isEmpty) {
      return const Center(child: Text("No dishes available."));
    }

    // Use LayoutBuilder to decide mobile vs desktop layout.
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width greater than 800, show grid view.
        if (constraints.maxWidth > 800) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: availableDishes.length,
            itemBuilder: (context, index) {
              final dish = availableDishes[index];
              return _buildDishCard(context, dish, index);
            },
          );
        } else {
          // On mobile, use horizontal ListView.
          return SizedBox(
            height: 380,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableDishes.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final dish = availableDishes[index];
                return _buildDishCard(context, dish, index);
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildDishCard(BuildContext context, Map dish, int index) {
    return GestureDetector(
      onTap: () {
        context.goNamed(
          AppRoute.addToOrder.name,
          pathParameters: {"itemId": index.toString()},
          extra: dish,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        child: SlideItem(
          key: Key('dish_$index'),
          index: index,
          img: dish["img"],
          title: dish["title"],
          description: dish["description"],
          pricing: dish["pricing"],
          offertPricing: dish["offertPricing"],
          ingredients: (dish["ingredients"] as List<dynamic>).cast<String>(),
          isSpicy: dish["isSpicy"],
          foodType: dish["foodType"],
          actionButton: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Se agregó ${dish['title']} al carrito'),
                  backgroundColor: ColorsPaletteRedonda.primary,
                  duration: const Duration(milliseconds: 500),
                ),
              );
              // Add dish to cart (implementation assumed in cartProvider)
              // ref.read(cartProvider.notifier).addToCart(dish, 1);
            },
            child: const Text('Agregar al carrito'),
          ),
        ),
      ),
    );
  }
}