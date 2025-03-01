import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/ordering_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/widgets_mesa_redonda/trending_item.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class AllDishesScreen extends ConsumerWidget {
  final bool hideIngredients; // New parameter
  
  const AllDishesScreen({
    super.key,
    this.hideIngredients = false, // Default to false
  });

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
            hideIngredients: hideIngredients, // Pass the parameter
          ),
        ),
      ),
    );
  }
}

class DishGridView extends StatelessWidget {
  final List dishes;
  final bool hideIngredients; // New parameter

  const DishGridView({
    super.key,
    required this.dishes,
    this.hideIngredients = true, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust cross axis count based on screen width
        final crossAxisCount = constraints.maxWidth > 900 
            ? 3 
            : constraints.maxWidth > 600 
                ? 2 
                : 1;
        
        // Adjust aspect ratio based on screen width
        final aspectRatio = constraints.maxWidth > 900 
            ? 0.8 
            : constraints.maxWidth > 600 
                ? 0.75 
                : 0.9;
        
        return GridView.builder(
          itemCount: dishes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
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
                // Wrap with ClipRect to prevent overflow
                child: ClipRect(
                  child: DishItem(
                    img: dish["img"],
                    title: dish["title"],
                    description: dish["description"],
                    pricing: dish["pricing"],
                    ingredients: List<String>.from(dish["ingredients"]),
                    isSpicy: dish["isSpicy"],
                    foodType: dish["foodType"],
                    key: ValueKey('dish_$index'),
                    index: index,
                    dishData: dish,
                    hideIngredients: hideIngredients, // Pass the parameter
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}