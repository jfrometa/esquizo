import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';

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
    tempCantidadPersonas = cateringOrders.peopleCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final CateringOrderItem cateringOrders = ref.watch(cateringOrderProvider)!;
    final bool isNotWithoutDishes = cateringOrders.dishes.isNotEmpty;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              // Update price calculation based on hasUnitSelection
              '\$${(dish.hasUnitSelection ? dish.quantity : dish.peopleCount * tempCantidadPersonas).toStringAsFixed(2)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isEditing)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit,
                        color: colorScheme.secondary),
                    onPressed: () => _editDishDialog(context, dish),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever, 
                        size: 20, 
                        color: colorScheme.error),
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
                      cateringOrders.peopleCount ?? 0; // Revert values
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
                      Text('Orden de Catering',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
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
                        'Tipo de evento',
                        tempEventType,
                        (newValue) {
                          setState(() {
                            tempEventType = newValue;
                          });
                        },
                      ),
                      // _buildEditableTextField(
                      //   'Preferencia',
                      //   tempPreferencia,
                      //   (newValue) {
                      //     setState(() {
                      //       tempPreferencia = newValue;
                      //     });
                      //   },
                      // ),
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
                      Text('Items:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                      SingleChildScrollView(
                        child: Column(
                          children: [...orders],
                        ),
                      ),
                      Divider(color: colorScheme.outline),
                      Text(
                          'Total Order Price: \$${cateringOrders.totalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              )
            : Center(
                child: Text(
                  'No catering orders available',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
      ),
    );
  }

  Widget _buildEditableTextField(
      String label, dynamic value, Function(dynamic) onChanged) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (value is bool) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Text(
              '$label: ${value ? ' Si ' : ' No '}', 
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            if (isEditing) 
              Switch(
                inactiveTrackColor: colorScheme.surfaceVariant,
                activeColor: colorScheme.primary,
                value: value,
                onChanged: isEditing ? (bool newValue) => onChanged(newValue) : null,
              ) 
            else 
              const SizedBox(),
          ],
        ),
      );
    }
    
    return isEditing
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text('$label: ', style: theme.textTheme.bodyMedium),
                Expanded(
                  child: TextFormField(
                    initialValue: value.toString(),
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Text('$label: $value', style: theme.textTheme.bodyMedium);
  }

  void _editDishDialog(BuildContext context, CateringDish dish) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    String updatedValue = dish.hasUnitSelection 
        ? dish.pricePerUnit.toString()
        : dish.peopleCount.toString();
        
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar', style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: updatedValue,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: dish.hasUnitSelection ? 'Unidades' : 'Cantidad por Persona',
                labelStyle: TextStyle(color: colorScheme.onSurface),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
              onChanged: (value) => updatedValue = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: colorScheme.primary)),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                final parsedValue = int.parse(updatedValue);
                if (dish.hasUnitSelection) {
                  ref.read(cateringOrderProvider.notifier).addCateringItem(
                    dish.copyWith(quantity: parsedValue)
                  );
                } else {
                  ref.read(cateringOrderProvider.notifier).addCateringItem(
                    dish.copyWith(peopleCount: parsedValue)
                  );
                }
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
