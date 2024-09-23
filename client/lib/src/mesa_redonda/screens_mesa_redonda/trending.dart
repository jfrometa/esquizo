import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/util_mesa_redonda/restaurants.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/search_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/trending_item.dart';

class Trending extends StatelessWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Trending Restaurants"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 10.0,
        ),
        child: Column(
          children: <Widget>[
            // SearchCard(
            //   onChanged: (String value) {},
            // ),
            const SizedBox(height: 10.0),
            Expanded(
              child: GridView.builder(
                itemCount: plans.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 450, // Maximum width of each grid item
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  Map restaurant = plans[index];

                  return DishItem(
                    img: restaurant["img"],
                    title: restaurant["title"],
                    description: restaurant["description"],  // Use 'description' instead of 'address'
                    pricing: restaurant["pricing"],          // Use 'pricing' for the price
                    ingredients: restaurant["ingredients"],  // Ensure 'ingredients' is a list of strings
                    isSpicy: restaurant["isSpicy"],          // Use 'isSpicy' boolean for spicy dishes
                    foodType: restaurant["foodType"],        // Use 'foodType' (e.g., Vegan/Meat)
                    key: Key('restaurant_$index'),
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
