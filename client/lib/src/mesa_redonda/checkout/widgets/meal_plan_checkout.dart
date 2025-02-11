import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/meal_subscription_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/meal_plan/meal_plan_cart.dart';

class MealPlanCheckout extends ConsumerWidget {
  final List<CartItem> items;
  final TextEditingController locationController;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final Function(BuildContext, TextEditingController, String) onLocationTap;
  final Function(BuildContext, TextEditingController, TextEditingController)
      onDateTimeTap;
  final Widget paymentMethodDropdown;

  const MealPlanCheckout({
    super.key,
    required this.items,
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
        ...items.map(
          (item) => MealSubscriptionItemView(
            item: item,
            onConsumeMeal: () =>
                ref.read(mealOrderProvider.notifier).consumeMeal(item.title),
            onRemoveFromCart: () =>
                ref.read(mealOrderProvider.notifier).removeFromCart(item.id),
          ),
        ),
      ],
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