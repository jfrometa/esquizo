import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/catering_cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/manual_quote_provider.dart';

class QuoteCheckout extends ConsumerWidget {
  final CateringOrderItem quote;
  final TextEditingController locationController;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final Function(BuildContext, TextEditingController, String) onLocationTap;
  final Function(BuildContext, TextEditingController, TextEditingController)
      onDateTimeTap;
  final Widget paymentMethodDropdown;

  const QuoteCheckout({
    super.key,
    required this.quote,
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
          child: Column(
            children: [
              _buildLocationField(context),
              _buildDateTimePicker(context),
            ],
          ),
        ),
        paymentMethodDropdown,
        CateringCartItemView(
          order: quote,
          onRemoveFromCart: () =>
              ref.read(manualQuoteProvider.notifier).state = null,
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
        onTap: () => onLocationTap(context, locationController, 'quote'),
        decoration: InputDecoration(
          labelText: 'Ubicación del evento',
          prefixIcon: Icon(Icons.location_on_outlined, color: colorScheme.primary),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
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
                labelText: 'Fecha del evento',
                prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
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
                labelText: 'Hora del evento',
                prefixIcon: Icon(Icons.access_time, color: colorScheme.primary),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
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