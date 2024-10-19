import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';

class CateringOrderDetailsScreen extends ConsumerStatefulWidget {
  const CateringOrderDetailsScreen({super.key});

  @override
  CateringOrderDetailsScreenState createState() =>
      CateringOrderDetailsScreenState();
}

class CateringOrderDetailsScreenState
    extends ConsumerState<CateringOrderDetailsScreen> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    final CateringOrderItem cateringOrders = ref.watch(cateringOrderProvider)!;

    final bool isNotWithoutDishes = (cateringOrders.dishes.isNotEmpty);
    final orders = cateringOrders.dishes.asMap().entries.map((entry) {
      int index = entry.key; // This is the index
      var dish = entry.value; // This is the dish

      // You can now use the
      return Padding(
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
            if (isEditing)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editDishDialog(context, dish),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeDish(index),
                  ),
                ],
              ),
          ],
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Order Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing; // Toggle edit mode
              });
            },
          ),
        ],
      ),
      body: isNotWithoutDishes
          ? Card(
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Orden de Catering',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildEditableTextField(
                      'Cantidad de Personas',
                      cateringOrders.cantidadPersonas.toString(),
                      (newValue) {
                        int? updatedValue = int.tryParse(newValue);
                        if (updatedValue != null) {
                          ref
                              .read(cateringOrderProvider.notifier)
                              .finalizeCateringOrder(
                                title: cateringOrders.title,
                                img: cateringOrders.img,
                                cantidadPersonas: updatedValue, // Updated value
                                apetito: cateringOrders.apetito,
                                alergias: cateringOrders.alergias,
                                eventType: cateringOrders.eventType,
                                preferencia: cateringOrders.preferencia,
                                adicionales: cateringOrders.adicionales,
                                description: cateringOrders.description,
                              );
                        }
                      },
                    ),
                    _buildEditableTextField(
                      'Apetito',
                      cateringOrders.apetito,
                      (newValue) {
                        ref
                            .read(cateringOrderProvider.notifier)
                            .finalizeCateringOrder(
                              title: cateringOrders.title,
                              img: cateringOrders.img,
                              cantidadPersonas: cateringOrders.cantidadPersonas,
                              apetito: newValue, // Updated value
                              alergias: cateringOrders.alergias,
                              eventType: cateringOrders.eventType,
                              preferencia: cateringOrders.preferencia,
                              adicionales: cateringOrders.adicionales,
                              description: cateringOrders.description,
                            );
                      },
                    ),
                    _buildEditableTextField(
                      'Alergias',
                      cateringOrders.alergias,
                      (newValue) {
                        ref
                            .read(cateringOrderProvider.notifier)
                            .finalizeCateringOrder(
                              title: cateringOrders.title,
                              img: cateringOrders.img,
                              cantidadPersonas: cateringOrders.cantidadPersonas,
                              apetito: cateringOrders.apetito,
                              alergias: newValue, // Updated value
                              eventType: cateringOrders.eventType,
                              preferencia: cateringOrders.preferencia,
                              adicionales: cateringOrders.adicionales,
                              description: cateringOrders.description,
                            );
                      },
                    ),
                    _buildEditableTextField(
                      'Evento',
                      cateringOrders.eventType,
                      (newValue) {
                        ref
                            .read(cateringOrderProvider.notifier)
                            .finalizeCateringOrder(
                              title: cateringOrders.title,
                              img: cateringOrders.img,
                              cantidadPersonas: cateringOrders.cantidadPersonas,
                              apetito: cateringOrders.apetito,
                              alergias: cateringOrders.alergias,
                              eventType: newValue, // Updated value
                              preferencia: cateringOrders.preferencia,
                              adicionales: cateringOrders.adicionales,
                              description: cateringOrders.description,
                            );
                      },
                    ),
                    _buildEditableTextField(
                      'Preferencia',
                      cateringOrders.preferencia,
                      (newValue) {
                        ref
                            .read(cateringOrderProvider.notifier)
                            .finalizeCateringOrder(
                              title: cateringOrders.title,
                              img: cateringOrders.img,
                              cantidadPersonas: cateringOrders.cantidadPersonas,
                              apetito: cateringOrders.apetito,
                              alergias: cateringOrders.alergias,
                              eventType: cateringOrders.eventType,
                              preferencia: newValue, // Updated value
                              adicionales: cateringOrders.adicionales,
                              description: cateringOrders.description,
                            );
                      },
                    ),
                    _buildEditableTextField(
                      'Adicionales',
                      cateringOrders.adicionales,
                      (newValue) {
                        ref
                            .read(cateringOrderProvider.notifier)
                            .finalizeCateringOrder(
                              title: cateringOrders.title,
                              img: cateringOrders.img,
                              cantidadPersonas: cateringOrders.cantidadPersonas,
                              apetito: cateringOrders.apetito,
                              alergias: cateringOrders.alergias,
                              eventType: cateringOrders.eventType,
                              preferencia: cateringOrders.preferencia,
                              adicionales: newValue, // Updated value
                              description: cateringOrders.description,
                            );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Items:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SingleChildScrollView(
                      child: Column(
                        children: [...orders],
                      ),
                    ),
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

  Widget _buildEditableTextField(
      String label, String value, ValueChanged<String> onChanged) {
    return isEditing
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text('$label: ', style: const TextStyle(fontSize: 16)),
                Expanded(
                  child: TextFormField(
                    initialValue: value,
                    onChanged: onChanged, // Trigger callback to update order
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Text('$label: $value', style: const TextStyle(fontSize: 16));
  }

  void _editDishDialog(BuildContext context, CateringDish dish) {
    String updatedPeopleCount = dish.peopleCount.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Dish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: updatedPeopleCount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'People Count'),
              onChanged: (value) => updatedPeopleCount = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Update dish peopleCount
                ref.read(cateringOrderProvider.notifier).addCateringItem(
                    dish.copyWith(peopleCount: int.parse(updatedPeopleCount)));
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeDish(int dishIndex) {
    setState(() {
      ref.read(cateringOrderProvider.notifier).removeFromCart(dishIndex);
    });
  }
}
