import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';

class CateringOrderDetailsScreen extends ConsumerWidget {
  const CateringOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CateringOrderItem cateringOrders = ref.watch(cateringOrderProvider)!;

    final bool isNotWithoutDishes = (cateringOrders.dishes.isNotEmpty);
    final orders = cateringOrders.dishes
        .map((dish) => Padding(
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Order Details'),
      ),
      body: isNotWithoutDishes
          ? Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Orden de Catering',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(cateringOrders!.description),
                    const SizedBox(height: 8),
                    Text('Apetito: ${cateringOrders.apetito}'),
                    Text('Alergias: ${cateringOrders.alergias}'),
                    Text('Evento: ${cateringOrders.eventType}'),
                    Text('Preferencia: ${cateringOrders.preferencia}'),
                    Text('Adicionales: ${cateringOrders.adicionales}'),
                    const SizedBox(height: 16),
                    Text('Items:',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SingleChildScrollView(child: !isNotWithoutDishes
                        ? Column(
                            children: [Text("No catering order available")],
                          )
                        : Column(
                            children: [...orders],
                          ),),
                    const Divider(),
                    Text(
                        'Total Order Price: \$${cateringOrders.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          : const Center(child: Text('No catering orders available')),
    );
  }
}
