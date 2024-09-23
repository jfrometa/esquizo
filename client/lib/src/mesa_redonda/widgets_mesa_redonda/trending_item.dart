import 'package:flutter/material.dart';

class DishItem extends StatefulWidget {
  final String img;
  final String title;
  final String description;
  final String pricing;
  final List<String> ingredients; // List of ingredients
  final bool isSpicy; // Indicates if the dish is spicy
  final String foodType; // Type of food: Vegan or Meat

  const DishItem({
    super.key,
    required this.img,
    required this.title,
    required this.description,
    required this.pricing,
    required this.ingredients,
    required this.isSpicy,
    required this.foodType,
  });

  @override
  DishItemState createState() => DishItemState();
}

class DishItemState extends State<DishItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: SizedBox(
        height: 400, // Adjust height
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: Colors.white, // Set the background color to white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 3.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 300, // Set minimum height
              minWidth: 250,  // Set minimum width
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Image Section
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      widget.img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                // Title and Pricing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "\$${widget.pricing}",
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5.0),
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5.0),
                // Ingredients and Indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      // Spicy Indicator
                      if (widget.isSpicy)
                        _buildLabel(
                          icon: Icons.whatshot,
                          text: 'Spicy',
                          color: Colors.redAccent,
                        ),
                      // Food Type Indicator (Vegan or Meat)
                      _buildLabel(
                        icon: widget.foodType.toLowerCase() == 'vegan'
                            ? Icons.eco
                            : Icons.restaurant,
                        text: widget.foodType,
                        color: widget.foodType.toLowerCase() == 'vegan'
                            ? Colors.green
                            : Colors.brown,
                      ),
                      // Ingredients
                      Expanded(
                        child: Text(
                          'Ingredients: ${widget.ingredients.join(', ')}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build labels (Spicy, Vegan/Meat)
  Widget _buildLabel({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14.0),
          const SizedBox(width: 4.0),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}