import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';

class CategoryItemsList extends ConsumerWidget {
  const CategoryItemsList({
    super.key,
    required this.items,
    required this.scrollController,
  });

  final List<CateringItem> items;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      controller: scrollController,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CateringItemCard(
          item: item,
          onAddToCart: (int quantity) {
            final order = ref.watch(cateringOrderProvider);
            ref.read(cateringOrderProvider.notifier).addCateringItem(
              CateringDish(
                title: item.title,
                peopleCount: order?.peopleCount ?? 1,
                pricePerPerson: item.pricePerUnit ?? 0.0,
                ingredients: item.ingredients,
                pricing: item.pricing,
              ),
            );
          }, sideRequestController: TextEditingController(),
        );
      },
    );
  }
}