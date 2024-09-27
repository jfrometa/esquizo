import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart'; // Import the dish provider
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/trending_item.dart';

class Trending extends ConsumerWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the dish data from the dishProvider
    final dishes = ref.watch(dishProvider);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 3.0,
        title: const Text("Nuestros Platos"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 10.0,
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10.0),
            Expanded(
              child: GridView.builder(
                itemCount: dishes.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 450, // Maximum width of each grid item
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  // Fetch each dish from the list of dishes
                  final dish = dishes[index];

                  return DishItem(
                    img: dish["img"],
                    title: dish["title"],
                    description: dish["description"],  // Use 'description' for the dish description
                    pricing: dish["pricing"],          // Use 'pricing' for the price
                    ingredients: List<String>.from(dish["ingredients"]),  // Ensure ingredients is a list of strings
                    isSpicy: dish["isSpicy"],          // Use 'isSpicy' boolean for spicy dishes
                    foodType: dish["foodType"],        // Use 'foodType' (e.g., Vegan/Meat)
                    key: Key('dish_$index'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}