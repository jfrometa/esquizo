import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class CateringOrderDetailsScreen extends ConsumerStatefulWidget {
  const CateringOrderDetailsScreen({super.key});

  @override
  CateringOrderDetailsScreenState createState() =>
      CateringOrderDetailsScreenState();
}

class CateringOrderDetailsScreenState
    extends ConsumerState<CateringOrderDetailsScreen> {
  bool isEditing = false;

  // Temporary variables to store changes before applying
  late bool temphasChef;
  late String tempAlergias;
  late String tempEventType;
  late String tempPreferencia;
  late String tempAdicionales;
  late int tempCantidadPersonas;

  @override
  void initState() {
    super.initState();
    final cateringOrders = ref.read(cateringOrderProvider)!;

    // Initialize temporary values with the existing order values
    temphasChef = cateringOrders.hasChef ?? false;
    tempAlergias = cateringOrders.alergias;
    tempEventType = cateringOrders.eventType;
    tempPreferencia = cateringOrders.preferencia;
    tempAdicionales = cateringOrders.adicionales;
    tempCantidadPersonas = cateringOrders.cantidadPersonas ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final CateringOrderItem cateringOrders = ref.watch(cateringOrderProvider)!;
    final bool isNotWithoutDishes = cateringOrders.dishes.isNotEmpty;
    final orders = cateringOrders.dishes.asMap().entries.map((entry) {
      int index = entry.key;
      var dish = entry.value;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                dish.title,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              '\$${(dish.peopleCount * tempCantidadPersonas).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isEditing)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: ColorsPaletteRedonda.deepBrown1),
                    onPressed: () => _editDishDialog(context, dish),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: ColorsPaletteRedonda.orange),
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
        forceMaterialTransparency: true,
        title: const Text('Detalles de la Orden'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (isEditing) {
                // Save changes to the provider only when the checkmark is hit
                ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                      title: cateringOrders.title,
                      img: cateringOrders.img,
                      cantidadPersonas: tempCantidadPersonas, // Updated value
                      hasChef: temphasChef, // Updated value
                      alergias: tempAlergias, // Updated value
                      eventType: tempEventType, // Updated value
                      preferencia: tempPreferencia, // Updated value
                      adicionales: tempAdicionales, // Updated value
                      description: cateringOrders.description,
                    );
              }

              setState(() {
                isEditing = !isEditing; // Toggle edit mode
              });
            },
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                // Cancel editing, revert values, and pop the screen
                setState(() {
                  temphasChef = cateringOrders.hasChef ?? false;
                  tempAlergias = cateringOrders.alergias;
                  tempEventType = cateringOrders.eventType;
                  tempPreferencia = cateringOrders.preferencia;
                  tempAdicionales = cateringOrders.adicionales;
                  tempCantidadPersonas =
                      cateringOrders.cantidadPersonas ?? 0; // Revert values
                  isEditing = false;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: isNotWithoutDishes
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
                        tempCantidadPersonas.toString(),
                        (newValue) {
                          int? updatedValue = int.tryParse(newValue);
                          if (updatedValue != null) {
                            setState(() {
                              tempCantidadPersonas = updatedValue;
                            });
                          }
                        },
                      ),
                      _buildEditableTextField(
                        'hasChef',
                        temphasChef,
                        (newValue) {
                          setState(() {
                            temphasChef = newValue;
                          });
                        },
                      ),
                      _buildEditableTextField(
                        'Alergias',
                        tempAlergias,
                        (newValue) {
                          setState(() {
                            tempAlergias = newValue;
                          });
                        },
                      ),
                      _buildEditableTextField(
                        'Evento',
                        tempEventType,
                        (newValue) {
                          setState(() {
                            tempEventType = newValue;
                          });
                        },
                      ),
                      _buildEditableTextField(
                        'Preferencia',
                        tempPreferencia,
                        (newValue) {
                          setState(() {
                            tempPreferencia = newValue;
                          });
                        },
                      ),
                      _buildEditableTextField(
                        'Adicionales',
                        tempAdicionales,
                        (newValue) {
                          setState(() {
                            tempAdicionales = newValue;
                          });
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
      ),
    );
  }

  Widget _buildEditableTextField(
      String label, dynamic value, Function(dynamic) onChanged) {
    if (value is bool) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Text('$label: ${value ? ' Si ' : ' No '}', style: const TextStyle(fontSize: 16)),
            Spacer(),
           isEditing ? Switch(
              inactiveTrackColor: ColorsPaletteRedonda.deepBrown,
              activeColor: ColorsPaletteRedonda.primary,
              value: value,
              onChanged: isEditing ? (bool newValue) => onChanged(newValue) : null,
            ) : SizedBox(),
          ],
        ),
      );
    }
    
    return isEditing
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text('$label: ', style: const TextStyle(fontSize: 16)),
                Expanded(
                  child: TextFormField(
                    initialValue: value.toString(),
                    onChanged: onChanged,
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
        title: const Text('Editar'),
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
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                ref.read(cateringOrderProvider.notifier).addCateringItem(
                    dish.copyWith(peopleCount: int.parse(updatedPeopleCount)));
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
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
