import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_item_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_selection_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/widgets/catering_selection/catering_enhanced_item.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart';

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
      padding: const EdgeInsets.fromLTRB(
          16, 16, 16, 80), // Added bottom padding for FAB
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        // Check if this item is already in the order
        final order = ref.watch(cateringOrderNotifierProvider);
        final isSelected =
            order?.dishes.any((dish) => dish.title == item.name) ?? false;

        // Get quantity if already selected
        int currentQuantity = 0;
        if (isSelected) {
          currentQuantity =
              order!.dishes.where((dish) => dish.title == item.name).length;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: EnhancedCateringItemCard(
            item: item,
            isSelected: isSelected,
            currentQuantity: currentQuantity,
            onQuantityChanged: (newQuantity) {
              _handleQuantityChange(ref, item, newQuantity, currentQuantity);
            },
            sideRequestController: TextEditingController(),
          ),
        );
      },
    );
  }

  void _handleQuantityChange(
      WidgetRef ref, CateringItem item, int newQuantity, int currentQuantity) {
    final orderNotifier = ref.read(cateringOrderNotifierProvider.notifier);
    final order = ref.read(cateringOrderNotifierProvider);

    if (newQuantity > currentQuantity) {
      // Add more items
      for (int i = 0; i < (newQuantity - currentQuantity); i++) {
        orderNotifier.addCateringItem(
          CateringDish(
            title: item.name,
            peopleCount: order?.peopleCount ?? 1,
            pricePerPerson: item.pricePerUnit ?? 0.0,
            ingredients:
                item.ingredients.map((toElement) => toElement.name).toList(),
            pricing: item.price,
          ),
        );
      }
    } else if (newQuantity < currentQuantity) {
      // Remove items
      final dishIndex =
          order?.dishes.indexWhere((dish) => dish.title == item.name);
      if (dishIndex != null && dishIndex != -1) {
        orderNotifier.removeFromCart(dishIndex);
      }
    }

    // Update item count in the UI
    ref.read(localCateringItemCountProvider.notifier).state =
        ref.read(cateringOrderNotifierProvider)?.dishes.length ?? 0;
  }
}
