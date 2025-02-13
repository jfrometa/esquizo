import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/catering_cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildLocationField(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildDateTimePicker(context),
        ),
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
        decoration: InputDecoration(
                labelText: 'Ubicación de entrega',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorsPaletteRedonda.primary,
                    width: 1.5,
                  ),
                ),
      ),
    
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: dateController,
              readOnly: true,
              onTap: () => onDateTimeTap(context, dateController, timeController),
              decoration: InputDecoration(
                labelText: 'Fecha de entrega',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorsPaletteRedonda.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: timeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Hora de entrega',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: ColorsPaletteRedonda.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}