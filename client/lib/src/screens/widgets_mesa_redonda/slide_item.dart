import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class SlideItem extends StatelessWidget {
  final String img;
  final String title;
  final String description;
  final String pricing;
  final String? offertPricing; // Optional pricing for offers
  final List<String> ingredients; // List of ingredients
  final bool isSpicy; // Indicates if the dish is spicy
  final String foodType; // Type of food: Vegan or Meat
  final bool isMealPlan; // Indicates if the dish is part of a meal plan
  final int index;
  final Widget? actionButton; // Custom action button (e.g., Add to Cart)
  final String id;

  const SlideItem({
    super.key,
    required this.id,
    required this.img,
    required this.title,
    required this.description,
    required this.pricing,
    this.offertPricing,
    required this.ingredients,
    required this.isSpicy,
    required this.foodType,
    this.isMealPlan = false,
    required this.index,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    double cardWidth = 300; // Fixed width for consistency
    double imageHeight = 175.0; // Fixed height

    return SizedBox(
      width: cardWidth,
      height: 400, // Fixed height for the card
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.max, // Fill the vertical space
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image Section with Overlays
            Stack(
              children: [
                // Dish Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12.0),
                  ),
                  child: Image.asset(
                    img,
                    width: cardWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                // Spicy Indicator
                if (isSpicy)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _buildLabel(
                      icon: Icons.whatshot,
                      text: 'Spicy',
                      color: Colors.red,
                    ),
                  ),
                // Food Type Indicator
                Positioned(
                  top: 10,
                  left: 10,
                  child: _buildLabel(
                    icon: foodType.toLowerCase() == 'vegan'
                        ? Icons.eco
                        : Icons.restaurant_menu,
                    text: foodType,
                    color: foodType.toLowerCase() == 'vegan'
                        ? Colors.green
                        : Colors.brown,
                  ),
                ),
                // Meal Plan Indicator
                if (isMealPlan)
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: _buildLabel(
                      icon: Icons.fastfood,
                      text: 'Meal Plan',
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
            // Information Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max, // Fill the available space
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dish Title
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        // Rating (Placeholder)
                        const Icon(Icons.star,
                            color: Colors.orangeAccent, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Description
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    // Ingredients
                    // Text(
                    //   'Ingredientes: ${ingredients.join(', ')}',
                    //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //         color: Colors.grey[600],
                    //       ),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    // const SizedBox(height: 12.0),
                    // Spacer to push the content below to the bottom
                    Expanded(child: Container()),
                    // Pricing and Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pricing
                        _buildPricing(),
                        // Custom Action Button
                        actionButton ??
                            ElevatedButton(
                              onPressed: () {
                                // Default behavior: Navigate to order screen
                                GoRouter.of(context).pushNamed(
                                  AppRoute.addToOrder.name,
                                  pathParameters: {
                                    "itemId": id,
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 42),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'Agregar',
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.fontSize,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build labels (Spicy, Vegan/Meat, Meal Plan)
  Widget _buildLabel({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build pricing section
  Widget _buildPricing() {
    if (offertPricing != null) {
      return Row(
        children: [
          Text(
            '\$$pricing',
            style: const TextStyle(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            '\$$offertPricing',
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ],
      );
    } else {
      return Text(
        '\$$pricing',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      );
    }
  }
}
