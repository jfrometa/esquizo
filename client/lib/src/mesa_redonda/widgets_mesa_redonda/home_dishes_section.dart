import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/slide_item.dart';

import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class HomeDishesSection extends ConsumerWidget {
  final List dishes;

  const HomeDishesSection({super.key, required this.dishes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildDishRow(context),
        const SizedBox(height: 10.0),
        _buildDishList(context, ref),
      ],
    );
  }

  Widget _buildDishRow(BuildContext context) {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Populares',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            child: const Text(
              "Ver todos",
              style: TextStyle(
                color: ColorsPaletteRedonda.deepBrown1,
              ),
            ),
            onPressed: () {
              context.goNamed(AppRoute.trending.name);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDishList(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 380,
      child: Focus(
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dishes.length,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            itemBuilder: (BuildContext context, int index) {
              Map dish = dishes[index];

              return GestureDetector(
                onTap: () {
                  context.goNamed(
                    AppRoute.addToOrder.name,
                    pathParameters: {
                      "itemId": index.toString(),
                    },
                    extra: dish,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 300,
                      minWidth: 250,
                    ),
                    child: SlideItem(
                      key: ValueKey('dish_$index'),
                      index: index,
                      img: dish["img"],
                      title: dish["title"],
                      description: dish["description"],
                      pricing: dish["pricing"],
                      offertPricing: dish["offertPricing"],
                      ingredients: List<String>.from(dish["ingredients"]),
                      isSpicy: dish["isSpicy"],
                      foodType: dish["foodType"],
                      actionButton: ElevatedButton(
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
                              1);
                        },
                        child: const Text('Agregar al carrito'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        onKeyEvent: (FocusNode node, KeyEvent event) {
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
      ),
    );
  }
}