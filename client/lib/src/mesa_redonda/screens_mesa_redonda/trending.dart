import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/trending_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class Trending extends ConsumerWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 3.0,
        title: const Text("Nuestros Platos"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 10.0,
          ),
          child: DishGridView(
            dishes: ref.watch(dishProvider),
          ),
        ),
      ),
    );
  }
}

class DishGridView extends StatelessWidget {
  final List dishes;

  const DishGridView({
    super.key,
    required this.dishes,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
        
        return GridView.builder(
          itemCount: dishes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            final dish = dishes[index];
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
              child: RepaintBoundary(
                child: DishItem(
                  img: dish["img"],
                  title: dish["title"],
                  description: dish["description"],
                  pricing: dish["pricing"],
                  ingredients: List<String>.from(dish["ingredients"]),
                  isSpicy: dish["isSpicy"],
                  foodType: dish["foodType"],
                  key: ValueKey('dish_$index'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}