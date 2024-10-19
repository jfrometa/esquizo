import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class CateringCartItemView extends StatelessWidget {
  final CateringOrderItem order;
  final VoidCallback onRemoveFromCart;

  const CateringCartItemView({
    super.key,
    required this.order,
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
            // Order title and removal button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.title,
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
            // Order details
            Text(order.description),
            const SizedBox(height: 8),
            Text('Apetito: ${order.apetito}'),
            Text(
                'Alergias: ${order.alergias.isNotEmpty ? order.alergias : "Ninguna"}'),
            Text('Evento: ${order.eventType}'),
            Text('Preferencia: ${order.preferencia}'),
            if (order.adicionales.isNotEmpty)
              Text('Adicionales: ${order.adicionales}'),
            const SizedBox(height: 16),
            // Order items
            Text(
              'Items del Catering:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...order.dishes.map((dish) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${dish.title} - ${dish.peopleCount} personas',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                '\$${(dish.peopleCount * dish.pricePerPerson).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const Divider(),
            // Total order price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Precio Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorsPaletteRedonda.primary,
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
