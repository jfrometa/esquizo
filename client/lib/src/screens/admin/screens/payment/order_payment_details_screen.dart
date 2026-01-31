import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_models.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_providers.dart';

import 'package:go_router/go_router.dart';

class OrderPaymentDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderPaymentDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderPaymentDetailsScreen> createState() =>
      _OrderPaymentDetailsScreenState();
}

class _OrderPaymentDetailsScreenState
    extends ConsumerState<OrderPaymentDetailsScreen> {
  final currencyFormatter =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  bool _isProcessingRefund = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final paymentAsync = ref.watch(paymentByOrderIdProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Payment Details - Order #${widget.orderId.substring(0, 8)}'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(paymentByOrderIdProvider(widget.orderId));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: paymentAsync.when(
        data: (payment) {
          if (payment == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No payment found for this order'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Status Card
                _buildPaymentStatusCard(payment, colorScheme),
                const SizedBox(height: 16),

                // Payment Details Card
                _buildPaymentDetailsCard(payment, colorScheme),
                const SizedBox(height: 16),

                // Amount Breakdown Card
                _buildAmountBreakdownCard(payment, colorScheme),
                const SizedBox(height: 16),

                // Service & Tips Card
                if (payment.serviceType != null || payment.tipAmount > 0)
                  _buildServiceAndTipsCard(payment, colorScheme),

                // Discounts Card
                if (payment.appliedDiscounts.isNotEmpty)
                  _buildDiscountsCard(payment, colorScheme),

                // Refunds Card
                if (payment.refundedAmount > 0)
                  _buildRefundsCard(payment, colorScheme),

                // Actions Card
                _buildActionsCard(payment, colorScheme),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildPaymentStatusCard(Payment payment, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _buildStatusChip(payment.status, colorScheme),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transaction ID',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(payment.transactionId ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Payment Method',
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(_getMethodIcon(payment.method), size: 20),
                        const SizedBox(width: 4),
                        Text(_formatMethod(payment.method),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard(Payment payment, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', payment.customerName ?? 'Guest'),
            const SizedBox(height: 8),
            _buildDetailRow('Email', payment.customerEmail ?? 'N/A'),
            const SizedBox(height: 8),
            _buildDetailRow('Phone', payment.customerPhone ?? 'N/A'),
            const SizedBox(height: 8),
            _buildDetailRow('Created', _formatDateTime(payment.createdAt)),
            if (payment.completedAt != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                  'Completed', _formatDateTime(payment.completedAt!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBreakdownCard(Payment payment, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildAmountRow('Subtotal', payment.baseAmount),
            if (payment.taxAmount > 0)
              _buildAmountRow('Tax', payment.taxAmount),
            if (payment.serviceCharge > 0)
              _buildAmountRow('Service Charge', payment.serviceCharge),
            if (payment.tipAmount > 0)
              _buildAmountRow('Tip', payment.tipAmount, color: Colors.green),
            if (payment.discountAmount > 0)
              _buildAmountRow('Discount', -payment.discountAmount,
                  color: Colors.red),
            const Divider(),
            _buildAmountRow(
              'Total',
              payment.finalAmount,
              isTotal: true,
            ),
            if (payment.refundedAmount > 0) ...[
              const SizedBox(height: 8),
              _buildAmountRow(
                'Refunded',
                -payment.refundedAmount,
                color: Colors.orange,
              ),
              const Divider(),
              _buildAmountRow(
                'Net Amount',
                payment.finalAmount - payment.refundedAmount,
                isTotal: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceAndTipsCard(Payment payment, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (payment.serviceType != null) ...[
              _buildDetailRow(
                  'Service Type', _formatServiceType(payment.serviceType!)),
              const SizedBox(height: 8),
            ],
            if (payment.tableNumber != null) ...[
              _buildDetailRow('Table', payment.tableNumber!),
              const SizedBox(height: 8),
            ],
            if (payment.serverName != null) ...[
              _buildDetailRow('Server', payment.serverName!),
              const SizedBox(height: 8),
            ],
            if (payment.tipAmount > 0) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tip Amount'),
                  Text(
                    currencyFormatter.format(payment.tipAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _showTipDistributionDialog(payment),
                icon: const Icon(Icons.volunteer_activism),
                label: const Text('Distribute Tips'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountsCard(Payment payment, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applied Discounts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...payment.appliedDiscounts.map((discount) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discount.code,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (discount.description != null)
                            Text(
                              discount.description!,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      Text(
                        '-${currencyFormatter.format(discount.amountApplied)}',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRefundsCard(Payment payment, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refunds',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Refunded'),
                Text(
                  currencyFormatter.format(payment.refundedAmount),
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (payment.refundIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${payment.refundIds.length} refund(s) processed',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(Payment payment, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (payment.status == PaymentStatus.pending)
                  ElevatedButton.icon(
                    onPressed: () => _confirmPayment(payment),
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm Payment'),
                  ),
                if (payment.status == PaymentStatus.completed &&
                    payment.isRefundable)
                  OutlinedButton.icon(
                    onPressed: _isProcessingRefund
                        ? null
                        : () => _processRefund(payment),
                    icon: _isProcessingRefund
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.money_off),
                    label: Text(_isProcessingRefund
                        ? 'Processing...'
                        : 'Process Refund'),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _viewOrderDetails(payment.orderId),
                  icon: const Icon(Icons.receipt),
                  label: const Text('View Order'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _printReceipt(payment),
                  icon: const Icon(Icons.print),
                  label: const Text('Print Receipt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAmountRow(String label, double amount,
      {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            currencyFormatter.format(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PaymentStatus status, ColorScheme colorScheme) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case PaymentStatus.completed:
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green.shade700;
        break;
      case PaymentStatus.processing:
        backgroundColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue.shade700;
        break;
      case PaymentStatus.failed:
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red.shade700;
        break;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        backgroundColor = Colors.orange.withValues(alpha: 0.2);
        textColor = Colors.orange.shade700;
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
        _formatStatus(status),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showTipDistributionDialog(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Distribute Tips'),
        content: Text(
            'Distribute ${currencyFormatter.format(payment.tipAmount)} in tips?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement tip distribution
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tip distribution coming soon')),
              );
            },
            child: const Text('Distribute'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment(Payment payment) async {
    try {
      final paymentService = ref.read(paymentServiceProvider);
      await paymentService.completePayment(payment.id);

      ref.invalidate(paymentByOrderIdProvider(widget.orderId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment confirmed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error confirming payment: $e')),
        );
      }
    }
  }

  Future<void> _processRefund(Payment payment) async {
    setState(() => _isProcessingRefund = true);

    try {
      // TODO: Implement refund processing
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund functionality coming soon')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingRefund = false);
      }
    }
  }

  void _viewOrderDetails(String orderId) {
    context.pop();
  }

  void _printReceipt(Payment payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon')),
    );
  }

  String _formatStatus(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }

  String _formatMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
      case PaymentMethod.mealPlan:
        return 'Meal Plan';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.digitalWallet:
        return Icons.phone_android;
      case PaymentMethod.mealPlan:
        return Icons.restaurant;
      default:
        return Icons.payment;
    }
  }

  String _formatServiceType(ServiceType type) {
    switch (type) {
      case ServiceType.dineIn:
        return 'Dine In';
      case ServiceType.takeout:
        return 'Takeout';
      case ServiceType.delivery:
        return 'Delivery';
      case ServiceType.pickup:
        return 'Pickup';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y h:mm a').format(dateTime);
  }
}
