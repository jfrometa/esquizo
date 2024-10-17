import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';

class MealSubscriptionItemView extends StatelessWidget {
  final CartItem item;
  final VoidCallback onConsumeMeal;
  final VoidCallback onRemoveFromCart;

  const MealSubscriptionItemView({
    super.key,
    required this.item,
    required this.onConsumeMeal,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and remove button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorsPaletteRedonda.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemoveFromCart,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(item.description),
            const SizedBox(height: 8),
            // Remaining Meals and Expiration Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comidas restantes: ${item.remainingMeals} / ${item.totalMeals}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Expira: ${DateFormat('dd/MM/yyyy').format(item.expirationDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Price and Action Button to consume a meal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Precio: \$${item.pricing}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorsPaletteRedonda.primary,
                      ),
                ),
                // ElevatedButton(
                //   onPressed: onConsumeMeal,
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: ColorsPaletteRedonda.primary,
                //     minimumSize: const Size(120, 36),
                //   ),
                //   child: const Text('Ordenar'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}