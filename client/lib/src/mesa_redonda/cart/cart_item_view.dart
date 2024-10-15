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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    img,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: ColorsPaletteRedonda.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        description,
                        style: const TextStyle(
                            fontSize: 12.0, color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      if (foodType == 'Catering')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('People: $peopleCount'),
                            if (sideRequest.isNotEmpty)
                              Text('Side Request: $sideRequest'),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ingredients: ${ingredients.join(', ')}',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Text(
                  foodType,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: ColorsPaletteRedonda.primary,
                  ),
                ),
                if (isSpicy)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      '🌶️ Spicy',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12.0),
            // Quantity and Total Price Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Control
                Row(
                  children: [
                    IconButton(
                      color: ColorsPaletteRedonda.primary,
                      icon: const Icon(Icons.remove),
                      onPressed: onRemove,
                    ),
                    Text(
                      quantity.toString(),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: ColorsPaletteRedonda.primary,
                            fontSize: 20,
                          ),
                    ),
                    IconButton(
                      color: ColorsPaletteRedonda.primary,
                      icon: const Icon(Icons.add),
                      onPressed: onAdd,
                    ),
                  ],
                ),
                // Total Price

                Text(
                  NumberFormat.currency(locale: 'en_US', symbol: '\$').format((double.tryParse(pricing) ?? 0.0) * quantity),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.deepOrange,
                        fontSize: 20,
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
