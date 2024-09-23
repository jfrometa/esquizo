import 'package:flutter/material.dart';

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
    bool? isMealPlan, // Make it nullable in the parameter list
  }) : this.isMealPlan =
            isMealPlan ?? false; // Default to false if not provided

  @override
  SlideItemState createState() => SlideItemState();
}

class SlideItemState extends State<SlideItem> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double cardWidth = 250.0; // Fixed width
    double imageHeight = 150.0; // Fixed height
    return SizedBox(
      width: cardWidth,
      child: Card(
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
                if (widget.isMealPlan ?? false)
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
            Padding(
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
                          // Text(
                          //   '${widget.rating}',
                          //   style: TextStyle(
                          //     fontSize: 14.0,
                          //     color: Colors.grey[800],
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  // Reviews Count
                  // Text(
                  //   '${widget.reviewsCount} reviews',
                  //   style: TextStyle(
                  //     fontSize: 12.0,
                  //     color: Colors.grey[600],
                  //   ),
                  // ),
                  const SizedBox(height: 8.0),
                  // Description
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyMedium,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pricing
                      _buildPricing(),
                      // Order Button
                      ElevatedButton(
                        onPressed: () {
                          // Implement order action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text(
                          'Order Now',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
