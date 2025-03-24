import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/slide_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
// Remove ColorsPaletteRedonda import

class HomeDishesSection extends StatelessWidget {
  final List<dynamic>? dishes;
  const HomeDishesSection({super.key, this.dishes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final availableDishes = dishes;
    
    if (availableDishes == null || availableDishes.isEmpty) {
      return Center(
        child: Text(
          "No dishes available.",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        context.goNamed(
          AppRoute.addToOrder.name,
          pathParameters: {"itemId": dish['id']},
          extra: dish,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        child: SlideItem(
          key: Key('dish_$index'),
          id: dish["id"],
          index: index,
          img: dish["img"],
          title: dish["title"],
          description: dish["description"],
          pricing: dish["pricing"],
          offertPricing: dish["offertPricing"],
          ingredients: (dish["ingredients"] as List<dynamic>).cast<String>(),
          isSpicy: dish["isSpicy"],
          foodType: dish["foodType"],
          actionButton: FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Se agregó ${dish['title']} al carrito',
                    style: TextStyle(color: colorScheme.onSecondaryContainer),
                  ),
                  backgroundColor: colorScheme.secondaryContainer,
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