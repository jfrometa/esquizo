import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/cart_provider.dart';

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
        _buildLocationField(context),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: locationController,
        readOnly: true,
        onTap: () => onLocationTap(context, locationController, 'regular'),
        decoration: const InputDecoration(
          labelText: 'Ubicación de entrega',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}