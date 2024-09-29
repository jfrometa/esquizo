import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/order_history_repository.dart';

class OrderHistoryList extends ConsumerWidget {
  const OrderHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Text('You have no order history.');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: Sizes.p8),
              child: ListTile(
                title: Text('Order #${order.orderNumber}'),
                subtitle:
                    Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                onTap: () {
                  // Navigate to order details if needed
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        // Handle error
        return const Text('Failed to load order history.');
      },
    );
  }
}
