import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_selection_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/widgets/catering_selection/catering_enhanced_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding for FAB
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        
        // Check if this item is already in the order
        final order = ref.watch(cateringOrderProvider);
        final isSelected = order?.dishes.any((dish) => dish.title == item.title) ?? false;
        
        // Get quantity if already selected
        int currentQuantity = 0;
        if (isSelected) {
          currentQuantity = order!.dishes
              .where((dish) => dish.title == item.title)
              .length;
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
  
  void _handleQuantityChange(WidgetRef ref, CateringItem item, int newQuantity, int currentQuantity) {
    final orderNotifier = ref.read(cateringOrderProvider.notifier);
    final order = ref.read(cateringOrderProvider);
    
    if (newQuantity > currentQuantity) {
      // Add more items
      for (int i = 0; i < (newQuantity - currentQuantity); i++) {
        orderNotifier.addCateringItem(
          CateringDish(
            title: item.title,
            peopleCount: order?.peopleCount ?? 1,
            pricePerPerson: item.pricePerUnit ?? 0.0,
            ingredients: item.ingredients,
            pricing: item.pricing,
          ),
        );
      }
    } else if (newQuantity < currentQuantity) {
      // Remove items
      final dishIndex = order?.dishes.indexWhere((dish) => dish.title == item.title);
        if (dishIndex != null && dishIndex != -1) {
          orderNotifier.removeFromCart(dishIndex);
        }
    }
    
    // Update item count in the UI
    ref.read(localCateringItemCountProvider.notifier).state = 
        ref.read(cateringOrderProvider)?.dishes.length ?? 0;
  }
}
