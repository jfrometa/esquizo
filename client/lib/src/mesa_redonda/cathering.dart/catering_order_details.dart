import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';

class CateringOrderDetailsScreen extends ConsumerWidget {
  const CateringOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cateringOrders = ref.watch(cateringOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Order Details'),
      ),
      body: cateringOrders.isNotEmpty
          ? ListView.builder(
              itemCount: cateringOrders.length,
              itemBuilder: (context, index) {
                final order = cateringOrders[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(order.description),
                        const SizedBox(height: 8),
                        Text('Apetito: ${order.apetito}'),
                        Text('Alergias: ${order.alergias}'),
                        Text('Evento: ${order.eventType}'),
                        Text('Preferencia: ${order.preferencia}'),
                        Text('Adicionales: ${order.adicionales}'),
                        const SizedBox(height: 16),
                        Text('Items:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ...order.dishes.map((dish) => ListTile(
                              title: Text(dish.title),
                              subtitle: Text('${dish.peopleCount} personas - \$${dish.pricePerPerson} por persona'),
                              trailing: Text('Total: \$${(dish.peopleCount * dish.pricePerPerson).toStringAsFixed(2)}'),
                            )),
                        const Divider(),
                        Text('Total Order Price: \$${order.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(child: Text('No catering orders available')),
    );
  }
}