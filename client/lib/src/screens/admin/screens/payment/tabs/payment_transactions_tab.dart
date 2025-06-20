import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_models.dart';
import 'package:starter_architecture_flutter_firebase/src/core/payment/payment_service.dart';
import 'package:go_router/go_router.dart';

class PaymentTransactionsTab extends ConsumerStatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String searchQuery;

  const PaymentTransactionsTab({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.searchQuery,
  });

  @override
  ConsumerState<PaymentTransactionsTab> createState() => _PaymentTransactionsTabState();
}

class _PaymentTransactionsTabState extends ConsumerState<PaymentTransactionsTab> {
  PaymentStatus? _filterStatus;
  PaymentMethod? _filterMethod;
  final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final paymentService = ref.watch(paymentServiceProvider);

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PaymentStatus?>(
                  value: _filterStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Status')),
                    ...PaymentStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(_formatStatus(status)),
                    )),
                  ],
                  onChanged: (value) => setState(() => _filterStatus = value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<PaymentMethod?>(
                  value: _filterMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Methods')),
                    ...PaymentMethod.values.map((method) => DropdownMenuItem(
                      value: method,
                      child: Text(_formatMethod(method)),
                    )),
                  ],
                  onChanged: (value) => setState(() => _filterMethod = value),
                ),
              ),
            ],
          ),
        ),
        
        // Transactions List
        Expanded(
          child: StreamBuilder<List<Payment>>(
            stream: paymentService.getPaymentsStream(
              startDate: widget.startDate,
              endDate: widget.endDate,
              status: _filterStatus,
              method: _filterMethod,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              var payments = snapshot.data!;
              
              // Apply search filter
              if (widget.searchQuery.isNotEmpty) {
                payments = payments.where((payment) => 
                  payment.orderId.toLowerCase().contains(widget.searchQuery) ||
                  payment.customerName?.toLowerCase().contains(widget.searchQuery) == true ||
                  payment.customerEmail?.toLowerCase().contains(widget.searchQuery) == true ||
                  payment.transactionId?.toLowerCase().contains(widget.searchQuery) == true
                ).toList();
              }
              
              if (payments.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No transactions found'),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: payments.length,
                itemBuilder: (context, index) => _buildTransactionCard(payments[index], colorScheme),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Payment payment, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/admin/orders/${payment.orderId}/payment');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${payment.orderId.substring(0, 8)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (payment.transactionId != null)
                        Text(
                          'Transaction: ${payment.transactionId}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  _buildStatusChip(payment.status, colorScheme),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(_getMethodIcon(payment.method), size: 20),
                  const SizedBox(width: 8),
                  Text(_formatMethod(payment.method)),
                  const Spacer(),
                  Text(
                    currencyFormatter.format(payment.finalAmount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    payment.customerName ?? 'Guest',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    _formatDateTime(payment.createdAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              if (payment.serviceType != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _getServiceTypeIcon(payment.serviceType!),
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatServiceType(payment.serviceType!),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (payment.serverName != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        payment.serverName!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ],
              if (payment.tipAmount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Tip: ${currencyFormatter.format(payment.tipAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(PaymentStatus status, ColorScheme colorScheme) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case PaymentStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green.shade700;
        break;
      case PaymentStatus.processing:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue.shade700;
        break;
      case PaymentStatus.failed:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red.shade700;
        break;
      case PaymentStatus.refunded:
      case PaymentStatus.partiallyRefunded:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange.shade700;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
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

  IconData _getServiceTypeIcon(ServiceType type) {
    switch (type) {
      case ServiceType.dineIn:
        return Icons.restaurant;
      case ServiceType.takeout:
        return Icons.takeout_dining;
      case ServiceType.delivery:
        return Icons.delivery_dining;
      case ServiceType.pickup:
        return Icons.shopping_bag;
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
