// lib/src/mesa_redonda/catering_entry/widgets/catering_order_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering_entry/components/catering_item_list.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
 import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
 

class CateringOrderForm extends ConsumerWidget {
  final VoidCallback? onEdit;
  const CateringOrderForm({super.key, this.onEdit});

  Widget _buildCateringOrderDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

Widget _buildOrderDetails(CateringOrderItem? order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles de la Orden',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildCateringOrderDetailItem('Personas', '${order?.peopleCount ?? 0}'),
        _buildCateringOrderDetailItem('Tipo de Evento', order?.eventType ?? ''),
        _buildCateringOrderDetailItem('Chef Incluido', order?.hasChef ?? false ? 'Sí' : 'No'),
        if ((order?.alergias ?? '').isNotEmpty)
          _buildCateringOrderDetailItem('Alergias', order?.alergias ?? ''),
        if ((order?.adicionales ?? '').isNotEmpty)
          _buildCateringOrderDetailItem('Notas', order?.adicionales ?? 'No adicionales'),
      ],
    );
  }
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(cateringOrderProvider); 

    if (order == null) {
      return const Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No hay orden iniciada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Inicia una orden agregando los detalles del evento',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildOrderDetails(order)],
                  ),
                ),
                if (onEdit != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                  ),
              ],
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: order.dishes.isEmpty
                  ? const Center(child: Text('No hay items agregados'))
                  : ItemsList(items: order.dishes, isQuote: false),
            ),
          ),
        ],
      ),
    );
  }
}