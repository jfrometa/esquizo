import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/catering_cart_item_view.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: locationController,
        readOnly: true,
        onTap: () => onLocationTap(context, locationController, 'catering'),
        decoration: InputDecoration(
          labelText: 'Ubicación de entrega',
          prefixIcon: Icon(Icons.location_on_outlined, color: colorScheme.primary),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: colorScheme.outline,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: colorScheme.outline,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2.0,
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
                prefixIcon: Icon(Icons.access_time, color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2.0,
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