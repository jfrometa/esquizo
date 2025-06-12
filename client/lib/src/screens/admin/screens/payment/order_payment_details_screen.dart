import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart'; // Assuming Order model is here

class OrderPaymentDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderPaymentDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details - Order #${orderId.substring(0, 6)}'),
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found.'));
          }
          return _buildPaymentDetails(context, order, currencyFormatter);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading order: $error'),
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => ref.refresh(orderByIdProvider(orderId)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(BuildContext context, Order order, NumberFormat currencyFormatter) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // --- Calculations ---
    final double subtotal = order.subtotal ?? 0.0;
    final double taxAmount = order.taxAmount ?? 0.0;
    // Assume tipAmount exists in the Order model, default to 0 if not
    final double tipAmount = order.tipAmount ?? 0.0;
    final double totalAmount = order.totalAmount; // Should always exist

    // Calculate the 10% of tax for waiter distribution
    const double waiterTaxDistributionRate = 0.10; // 10%
    final double waiterTaxCut = taxAmount * waiterTaxDistributionRate;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Make card wrap content
            children: [
              Text(
                'Payment Summary',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(
                context,
                label: 'Subtotal',
                value: currencyFormatter.format(subtotal),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                label: 'Tax (${((order.tax ?? 0) * 100).toStringAsFixed(2)}%)', // Assuming taxRate exists
                value: currencyFormatter.format(taxAmount),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                label: 'Tip',
                value: currencyFormatter.format(tipAmount),
              ),
              const Divider(height: 30, thickness: 1),
              _buildDetailRow(
                context,
                label: 'Total Amount',
                value: currencyFormatter.format(totalAmount),
                isTotal: true,
              ),
              const Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
              // --- Waiter Tax Distribution ---
              Text(
                'Waiter Tax Distribution (10% of Tax)',
                 style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.secondary),
              ),
               const SizedBox(height: 10),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                 decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                 ),
                child: _buildDetailRow(
                  context,
                  label: 'Amount for Waiters',
                  value: currencyFormatter.format(waiterTaxCut),
                   labelStyle: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                  valueStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    final defaultLabelStyle = Theme.of(context).textTheme.titleMedium;
    final defaultValueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final totalStyle = Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? totalStyle : (labelStyle ?? defaultLabelStyle),
        ),
        Text(
          value,
          style: isTotal ? totalStyle : (valueStyle ?? defaultValueStyle),
        ),
      ],
    );
  }
}

// --- Helper: Navigation Argument Class (Optional but recommended) ---
// You might want to create a simple class to pass arguments if needed later
// class OrderPaymentDetailsArgs {
//   final String orderId;
//   OrderPaymentDetailsArgs(this.orderId);
// }

