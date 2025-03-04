import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/QR/models/qr_code_data.dart';

// Order Screen
class OrderScreen extends StatelessWidget {
  final QRCodeData tableData;
  
  const OrderScreen({
    Key? key,
    required this.tableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Mock order data
    final orderItems = [
      {'dish': 'Caesar Salad', 'price': 12.99, 'quantity': 1},
      {'dish': 'Grilled Salmon', 'price': 24.99, 'quantity': 2},
    ];
    
    // Calculate total
    double total = 0;
    for (var item in orderItems) {
      total += (item['price'] as double) * (item['quantity'] as int);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Order - ${tableData.tableName}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Your Order',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Order items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: orderItems.length,
              separatorBuilder: (context, index) => Divider(
                color: theme.colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final item = orderItems[index];
                final itemTotal = (item['price'] as double) * (item['quantity'] as int);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        '${item['quantity']}x',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['dish'] as String,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              'S/ ${(item['price'] as double).toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'S/ ${itemTotal.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Total and checkout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        'S/ ${total.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Service charge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Service Charge (10%)',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        'S/ ${(total * 0.1).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'S/ ${(total * 1.1).toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Checkout button
                  ElevatedButton.icon(
                    onPressed: () {
                      // In a real app, this would place the order
                      _showOrderConfirmation(context);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Place Order'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showOrderConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Order Placed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been sent to the kitchen. A waiter will bring your food to ${tableData.tableName} shortly.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
