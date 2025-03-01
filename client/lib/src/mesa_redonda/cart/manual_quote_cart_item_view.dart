import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class ManualQuoteCartItemView extends ConsumerWidget {
  final CateringOrderItem quote;
  final VoidCallback? onRemove;

  const ManualQuoteCartItemView({
    super.key,
    required this.quote,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cotización Manual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorsPaletteRedonda.primary,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever,size: 20, color: Colors.red),
                  onPressed: () {
                    ref.read(manualQuoteProvider.notifier).clearManualQuote();
                    if (onRemove != null) onRemove!();
                  },
                ),
              ],
            ),
            const Divider(),
            ...quote.dishes.map((dish) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${dish.quantity}x ${dish.title}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        'RD\$ ${(dish.pricing * dish.quantity).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                )),
            if (quote.hasChef ?? false) ...[
              const Divider(),
              Text(
                'Chef incluido',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorsPaletteRedonda.primary,
                    ),
              ),
            ],
            const Divider(),
            Text(
              'Personas: ${quote.peopleCount ?? 0}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}