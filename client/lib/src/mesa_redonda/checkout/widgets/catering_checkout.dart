import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/catering_cart_item_view.dart';

class CateringCheckout extends ConsumerWidget {
  final CateringOrderItem order;
  final TextEditingController locationController;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final Function(BuildContext, TextEditingController, String) onLocationTap;
  final Function(BuildContext, TextEditingController, TextEditingController)
      onDateTimeTap;
  final Widget paymentMethodDropdown;

  const CateringCheckout({
    super.key,
    required this.order,
    required this.locationController,
    required this.dateController,
    required this.timeController,
    required this.onLocationTap,
    required this.onDateTimeTap,
    required this.paymentMethodDropdown,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildLocationField(context),
        _buildDateTimePicker(context),
        paymentMethodDropdown,
        CateringCartItemView(
          order: order,
          onRemoveFromCart: () =>
              ref.read(cateringOrderProvider.notifier).clearCateringOrder(),
        ),
      ],
    );
  }

  Widget _buildLocationField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: locationController,
        readOnly: true,
        onTap: () => onLocationTap(context, locationController, 'catering'),
        decoration: const InputDecoration(
          labelText: 'Ubicación de entrega',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          TextField(
            controller: dateController,
            readOnly: true,
            onTap: () => onDateTimeTap(context, dateController, timeController),
            decoration: const InputDecoration(
              labelText: 'Fecha de entrega',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: timeController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Hora de entrega',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

}