import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/cart/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/cart_item_view.dart';

class PlatosCheckout extends ConsumerWidget {
  final List<CartItem> items;
  final TextEditingController locationController;
  final Function(BuildContext, TextEditingController, String) onLocationTap;
  final Widget paymentMethodDropdown;

  const PlatosCheckout({
    super.key,
    required this.items,
    required this.locationController,
    required this.onLocationTap,
    required this.paymentMethodDropdown,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildLocationField(context),
        ),
        paymentMethodDropdown,
        ...items.map(
          (item) => CartItemView(
            img: item.img,
            title: item.title,
            description: item.description,
            pricing: item.pricing,
            offertPricing: item.offertPricing,
            ingredients: item.ingredients,
            isSpicy: item.isSpicy,
            foodType: item.foodType,
            quantity: item.quantity,
            onRemove: () =>
                ref.read(cartProvider.notifier).decrementQuantity(item.title),
            onAdd: () =>
                ref.read(cartProvider.notifier).incrementQuantity(item.title),
            peopleCount: 0,
            sideRequest: '',
          ),
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


}