import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';

// Provider for meal plan order details
final mealPlanOrderProvider =
    FutureProvider.family<Order?, String>((ref, orderId) async {
  final orderService = ref.watch(orderServiceProvider);
  try {
    // Get order and filter for meal plan orders
    final order = await orderService.getOrderById(orderId);

    // Check if this is a meal plan order by looking at the items
    if (order != null &&
        order.items.any((item) =>
            item.isMealSubscription == true || item.isMealPlanDish == true)) {
      return order;
    }

    return null;
  } catch (e) {
    debugPrint('Error fetching meal plan order: $e');
    rethrow;
  }
});

class MealPlanOrderDetailScreen extends ConsumerWidget {
  const MealPlanOrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlanOrderAsync = ref.watch(mealPlanOrderProvider(orderId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan Order Details'),
      ),
      body: mealPlanOrderAsync.when(
        data: (order) => order != null
            ? _buildOrderDetails(context, order)
            : const Center(child: Text('Order not found')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, Order order) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order #${order.id.substring(0, 8)}',
                          style: textTheme.headlineSmall),
                      _buildStatusChip(order.status.name, colorScheme),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Customer: ${order.customerName ?? 'Guest'}',
                      style: textTheme.titleMedium),
                  Text('Email: ${order.email}', style: textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text('Created: ${_formatDateTime(order.createdAt)}',
                      style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Meal Plan Items Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meal Plan Items', style: textTheme.titleLarge),
                  const Divider(),
                  ..._buildMealPlanItems(order.items, textTheme),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Totals Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: textTheme.titleLarge),
                  const Divider(),
                  _buildTotalRow('Subtotal', order.subtotal ?? 0, textTheme),
                  if ((order.tax ?? 0) > 0)
                    _buildTotalRow('Tax', order.tax ?? 0, textTheme),
                  if ((order.deliveryFee ?? 0) > 0)
                    _buildTotalRow(
                        'Delivery Fee', order.deliveryFee ?? 0, textTheme),
                  const Divider(),
                  _buildTotalRow('Total', order.total ?? 0, textTheme,
                      isTotal: true),
                ],
              ),
            ),
          ),

          // Additional Information
          if (order.specialInstructions != null &&
              order.specialInstructions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Special Instructions', style: textTheme.titleLarge),
                    const Divider(),
                    Text(order.specialInstructions!,
                        style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildMealPlanItems(List<OrderItem> items, TextTheme textTheme) {
    final widgets = <Widget>[];

    for (final item in items) {
      final isMealSubscription = item.isMealSubscription ?? false;
      final isMealPlanDish = item.isMealPlanDish ?? false;

      if (isMealSubscription || isMealPlanDish) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title ??
                            item.name, // Use title first, fallback to name
                        style: textTheme.titleMedium,
                      ),
                      if (item.description != null &&
                          item.description!.isNotEmpty)
                        Text(
                          item.description!,
                          style: textTheme.bodySmall,
                        ),
                      if (isMealSubscription)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meal Subscription',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item.totalMeals != null)
                                Text(
                                  'Total Meals: ${item.totalMeals}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.blue,
                                  ),
                                ),
                              if (item.remainingMeals != null)
                                Text(
                                  'Remaining: ${item.remainingMeals}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.blue,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      Text(
                        'Qty: ${item.quantity ?? 1}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_formatPrice(item.pricing ?? item.price)}',
                      style: textTheme.titleMedium,
                    ),
                    if (item.offertPricing != null &&
                        item.offertPricing!.isNotEmpty &&
                        item.offertPricing != '0')
                      Text(
                        '\$${_formatPrice(item.offertPricing)}',
                        style: textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    }

    if (widgets.isEmpty) {
      widgets.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No meal plan items found',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildTotalRow(String label, double amount, TextTheme textTheme,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : textTheme.bodyMedium,
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                : textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colorScheme) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.withValues(alpha: 0.2);
        textColor = Colors.orange.shade700;
        break;
      case 'confirmed':
      case 'ready':
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green.shade700;
        break;
      case 'delivered':
      case 'completed':
        backgroundColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue.shade700;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red.shade700;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.2);
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';

    if (price is num) {
      return price.toStringAsFixed(2);
    }

    final priceStr = price.toString();
    final parsed = double.tryParse(priceStr);
    if (parsed != null) {
      return parsed.toStringAsFixed(2);
    }

    return '0.00';
  }
}
