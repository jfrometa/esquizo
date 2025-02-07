import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/slide_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';

class HomeSearchResults extends ConsumerWidget {
  final List filteredDishes;

  const HomeSearchResults({super.key, required this.filteredDishes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filteredDishes.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron platos.',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      itemCount: filteredDishes.length,
      itemBuilder: (context, index) {
        final dish = filteredDishes[index];
        return GestureDetector(
          onTap: () {
            context.goNamed(
              AppRoute.addToOrder.name,
              pathParameters: {"itemId": index.toString()},
              extra: dish,
            );
          },
          child: Container(
            height: 400,
            margin: const EdgeInsets.symmetric(vertical: 5.0),
            child: SlideItem(
              index: index,
              img: dish["img"],
              title: dish["title"],
              description: dish["description"],
              pricing: dish["pricing"],
              offertPricing: dish["offertPricing"],
              ingredients: dish["ingredients"],
              isSpicy: dish["isSpicy"],
              foodType: dish["foodType"],
              key: Key('dish_$index'),
              actionButton: ElevatedButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).addToCart(
                      dish.cast<String, dynamic>(),
                      1);
                },
                child: const Text('Agregar al carrito'),
              ),
            ),
          ),
        );
      },
    );
  }
}