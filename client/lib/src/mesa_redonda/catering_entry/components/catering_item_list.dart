// lib/src/mesa_redonda/catering_entry/widgets/items_list.dart
import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';

class ItemsList extends StatelessWidget {
  final List<CateringDish> items;
  /// Optionally indicate if this is for a quote (affecting text labels, etc.)
  final bool isQuote;
  const ItemsList({Key? key, required this.items, this.isQuote = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final dish = items[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              dish.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              dish.hasUnitSelection
                  ? 'Cantidad: ${dish.quantity}'
                  : 'Para ${dish.peopleCount} personas',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // You can pass a callback from the parent to remove the item.
              },
            ),
          ),
        );
      },
    );
  }
}