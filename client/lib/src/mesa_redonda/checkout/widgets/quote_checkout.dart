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
        CateringCartItemView(
          order: quote,
          onRemoveFromCart: () =>
              ref.read(manualQuoteProvider.notifier).state = null,
        ),
      ],
    );
  }


}