import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class CateringCartItemView extends ConsumerWidget {
  final CateringOrderItem order;
  final VoidCallback onRemoveFromCart;
  final FocusNode customPersonasFocusNode = FocusNode();
  final FocusNode customUnitsFocusNode =
      FocusNode(); // New focus node for units
  bool isCustomSelected = false;
  bool isCustomUnitsSelected = false; // New flag for units

  CateringCartItemView({
    super.key,
    required this.order,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPersonasSelected =
        order.peopleCount != null && order.peopleCount! > 0;

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
                    order.title.isEmpty ? 'Catering' : order.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ColorsPaletteRedonda.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever,size: 20, color: Colors.red),
                  onPressed: onRemoveFromCart,
                ),
              ],
            ),
            const SizedBox(height: 8), 
             Text('Personas: ${order.peopleCount}'),
            
            Text('Cheffing: ${(order.hasChef ?? false) ? ' Si ' : ' No '}'),
            Text(
                'Alergias: ${order.alergias.trim().isNotEmpty ? order.alergias : "Ninguna"}'),
            Text(
                'Evento: ${order.eventType.isEmpty ? 'Solicitud de Catering' : order.eventType}'),
            // Text('Preferencia: ${order.preferencia}'),
            if (order.adicionales.isNotEmpty)
              Text('Adicionales: ${order.adicionales}'),
            const SizedBox(height: 16),
            // Order items
            Text(
              'Platos :',
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
                                  '${dish.title} - ${dish.peopleCount} Personas',
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
            // const Divider(),
            // // Total order price
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     const Text(
            //       'Precio Total:',
            //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //     ),
            //     Text(
            //       '\$${order.totalPrice.toStringAsFixed(2)}',
            //       style: const TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //         color: ColorsPaletteRedonda.primary,
            //       ),
            //     ),
            //   ],
            // ),

            const SizedBox(height: 16),
            // Button to complete the catering order

            if (!isPersonasSelected)
              ElevatedButton(
                onPressed: !isPersonasSelected
                    ? () {
                        _showCateringForm(context, ref);
                      }
                    : null, // Disable button if personas not selected
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey; // Disabled color
                      }
                      return ColorsPaletteRedonda.orange; // Active color
                    },
                  ),
                ),
                child: const Text('Completar Orden de Catering'),
              ),
          ],
        ),
      ),
    );
  }

 void _showCateringForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.0,
            right: 20.0,
            top: 20.0,
          ),
          child: CateringForm(
            // title: 'Detalles de la Orden',
            initialData: order,
            onSubmit: (formData) {
              ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                    title: order.title,
                    img: order.img,
                    description: order.description,
                    hasChef: formData.hasChef,
                    alergias: formData.allergies.join(','),
                    eventType: formData.eventType,
                    preferencia: order.preferencia,
                    adicionales: formData.additionalNotes,
                    cantidadPersonas: formData.peopleCount,
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se actualizó el Catering'),
                  backgroundColor: Colors.brown,
                  duration: Duration(milliseconds: 500),
                ),
              );
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }


  void _finalizeAndAddToCart(
    WidgetRef ref,
    bool hasChef,
    String alergias,
    String eventType,
    String preferencia,
    String adicionales,
    int cantidadPersonas,
  ) {
    final cateringOrderProviderNotifier =
        ref.read(cateringOrderProvider.notifier);
    cateringOrderProviderNotifier.finalizeCateringOrder(
      title: 'Orden de Catering',
      img: 'assets/image.png',
      description: 'Catering',
      hasChef: hasChef,
      alergias: alergias,
      eventType: eventType,
      preferencia: preferencia,
      adicionales: adicionales,
      cantidadPersonas: cantidadPersonas, // Include units in the finalize call
    );
  }


}
