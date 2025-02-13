import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:intl/intl.dart';

class CartItemView extends StatelessWidget {
  final String img;
  final String title;
  final String description;
  final String pricing;
  final String? offertPricing;
  final List<String> ingredients;
  final bool isSpicy;
  final String foodType;
  final int quantity;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  // Catering-specific fields
  final int peopleCount;
  final String sideRequest;

  const CartItemView({
    super.key,
    required this.img,
    required this.title,
    required this.description,
    required this.pricing,
    this.offertPricing,
    required this.ingredients,
    required this.isSpicy,
    required this.foodType,
    required this.quantity,
    required this.onRemove,
    required this.onAdd,
    this.peopleCount = 0,
    this.sideRequest = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0), // Reduced margin
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Image & Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    img,
                    fit: BoxFit.cover,
                    width: 80, // Reduced image size
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 30),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16.0, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: ColorsPaletteRedonda.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      // Description
                      Text(
                        description,
                        style: const TextStyle(fontSize: 10.0, color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      // Catering-specific info
                      if (foodType == 'Catering')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'People: $peopleCount',
                              style: const TextStyle(fontSize: 10),
                            ),
                            if (sideRequest.isNotEmpty)
                              Text(
                                'Side Request: $sideRequest',
                                style: const TextStyle(fontSize: 10),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            // Ingredients Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ingredients: ${ingredients.join(', ')}',
                    style: const TextStyle(fontSize: 10.0, color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2.0),
            // Food Type and Spicy Indicator
            Row(
              children: [
                Text(
                  foodType,
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: ColorsPaletteRedonda.primary,
                  ),
                ),
                if (isSpicy)
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Text(
                      '🌶️ Spicy',
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Quantity & Total Price Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Controls
                Row(
                  children: [
                    IconButton(
                      color: ColorsPaletteRedonda.primary,
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: ColorsPaletteRedonda.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      color: ColorsPaletteRedonda.primary,
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: onAdd,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                // Total Price
                Text(
                  NumberFormat.currency(locale: 'en_US', symbol: '\$')
                      .format((double.tryParse(pricing) ?? 0.0) * quantity),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}