import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class SlideItem extends StatefulWidget {
  final String img;
  final String title;
  final String description;
  final String pricing;
  final String? offertPricing; // Optional pricing for offers
  final List<String> ingredients; // List of ingredients
  final bool isSpicy; // Indicates if the dish is spicy
  final String foodType; // Type of food: Vegan or Meat
  final bool
      isMealPlan; // Indicates if the dish is part of a meal plan, default is false
  final int index;

  const SlideItem({
    super.key,
    required this.img,
    required this.title,
    required this.description,
    required this.pricing,
    this.offertPricing,
    required this.ingredients,
    required this.isSpicy,
    required this.foodType,
    bool? isMealPlan,
    required this.index, // Make it nullable in the parameter list
  }) : isMealPlan = isMealPlan ?? false; // Default to false if not provided

  @override
  SlideItemState createState() => SlideItemState();
}

class SlideItemState extends State<SlideItem> {
  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    double cardWidth = MediaQuery.of(context).size.width; // Fixed width
    double imageHeight = 175.0; // Fixed height
    return SizedBox(
      width: cardWidth,
      child: Card(
        color: Colors.white, // Set the b
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
        child: Column(
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
                    widget.img,
                    width: cardWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                // Spicy Indicator
                if (widget.isSpicy)
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
                    icon: widget.foodType.toLowerCase() == 'vegan'
                        ? Icons.eco
                        : Icons.restaurant_menu,
                    text: widget.foodType,
                    color: widget.foodType.toLowerCase() == 'vegan'
                        ? Colors.green
                        : Colors.brown,
                  ),
                ),
                // Meal Plan Indicator
                if (widget.isMealPlan)
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dish Title
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        // Rating
                        const Row(
                          children: [
                            Icon(Icons.star,
                                color: Colors.orangeAccent, size: 16),
                            SizedBox(width: 4.0),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Description
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    // Ingredients
                    Text(
                      'Ingredients: ${widget.ingredients.join(', ')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 12.0),
                    // Pricing and Order Button
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pricing
                        _buildPricing(),
                        // Order Button
                        // ElevatedButton(
                        //   onPressed: () {
                        //     // Implement order action
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor:
                        //         Theme.of(context).primaryColorLight,
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 20.0, vertical: 12.0),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(8.0),
                        //     ),
                        //     textStyle: const TextStyle(
                        //       fontSize: 16.0,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        //   child: const Text(
                        //     'Agregar al carrito',
                        //   ),
                        // ),

                        SizedBox(
                          width: 150,
                          // padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to the checkout screen
                              GoRouter.of(context).pushNamed(
                                AppRoute.addToOrder.name,
                                pathParameters: {
                                  "itemId": widget.index.toString(),
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsPaletteRedonda.primary,
                              foregroundColor: ColorsPaletteRedonda.white,
                              minimumSize: const Size(double.infinity, 42),
                            ),
                            child: Text(
                              'Agregar',
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.fontSize,
                                // color: Theme.of(context).colorScheme.primary,
                              ),
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
  Widget _buildLabel(
      {required IconData icon, required String text, required Color color}) {
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
    if (widget.offertPricing != null) {
      return Row(
        children: [
          Text(
            '\$${widget.pricing}',
            style: const TextStyle(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            '\$${widget.offertPricing}',
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
        '\$${widget.pricing}',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      );
    }
  }
}
