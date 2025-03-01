// lib/src/mesa_redonda/catering_entry/widgets/items_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/manual_quote_provider.dart';

class ItemsList extends ConsumerWidget {
  final List<CateringDish> items;
  final bool isQuote;
  const ItemsList({super.key, required this.items, this.isQuote = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      reverse: true,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final dish = items[index];
        return    ListTile(
            title: Text(
              dish.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            subtitle: Text(
              dish.hasUnitSelection
                  ? 'Cantidad: ${dish.quantity}'
                  : 'Para ${dish.peopleCount} personas',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close,size: 20, color: Colors.red),
              onPressed: () {
                if (isQuote) {
                  ref.read(manualQuoteProvider.notifier).removeFromCart(index);
                } else {
                  ref.read(cateringOrderProvider.notifier).removeFromCart(index);
                }
              },
            ), 
        );
      },
    );
  }
}