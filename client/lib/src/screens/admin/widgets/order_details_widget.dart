import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/order/order_provider.dart';
 
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';

class OrderDetailView extends ConsumerStatefulWidget {
  final String orderId;
  final VoidCallback? onClose;
  
  const OrderDetailView({
    Key? key,
    required this.orderId,
    this.onClose,
  }) : super(key: key);

  @override
  ConsumerState<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends ConsumerState<OrderDetailView> {
  bool _isUpdatingStatus = false;
  bool _isPrinting = false;
  
  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderByIdProvider(widget.orderId));
    
    return orderAsync.when(
      data: (order) {
        if (order == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Order not found'),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: () {
                    ref.refresh(orderByIdProvider(widget.orderId));
                  },
                ),
              ],
            ),
          );
        }
        
        return _buildOrderDetails(order);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () {
                ref.refresh(orderByIdProvider(widget.orderId));
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderDetails(Order order) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 6)}'),
        actions: [
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onClose,
              tooltip: 'Close',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card with action buttons
            _buildStatusCard(order),
            const SizedBox(height: 24),
            
            // Order info and customer details in a row on desktop, or stacked on mobile
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Side by side for larger screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildOrderInfoCard(order),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildCustomerCard(order),
                      ),
                    ],
                  );
                } else {
                  // Stacked for smaller screens
                  return Column(
                    children: [
                      _buildOrderInfoCard(order),
                      const SizedBox(height: 16),
                      _buildCustomerCard(order),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            
            // Order items card
            _buildOrderItemsCard(order),
            const SizedBox(height: 24),
            
            // Order totals card
            _buildOrderTotalsCard(order),
            const SizedBox(height: 32),
            
            // Additional actions buttons at the bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.print),
                  label: const Text('Print Receipt'),
                  onPressed: _isPrinting ? null : () => _printReceipt(order),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text('Email Receipt'),
                  onPressed: () => _emailReceipt(order),
                ),
                if (order.status != 'cancelled' && order.status != 'completed') ...[
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Order'),
                    onPressed: () => _confirmCancelOrder(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusCard(Order order) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status.name);
    
    // Available next statuses based on current status
    final nextStatuses = _getNextPossibleStatuses(order.status.name);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Current status with colored badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _capitalizeFirst(order.status.name),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(
                  DateFormat.yMMMd().add_jm().format(order.createdAt),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            
            if (nextStatuses.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Update status actions
              Row(
                children: [
                  const Text('Update Status:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _isUpdatingStatus
                        ? const Center(child: CircularProgressIndicator())
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: nextStatuses.map((status) {
                              return OutlinedButton(
                                onPressed: () => _updateOrderStatus(order, status),
                                child: Text(_getStatusActionText(status)),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderInfoCard(Order order) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Order ID
            _buildInfoRow(
              label: 'Order ID',
              value: '#${order.id.substring(0, 8)}',
            ),
            const SizedBox(height: 8),
            
            // Order date
            _buildInfoRow(
              label: 'Date',
              value: DateFormat.yMMMd().format(order.createdAt),
            ),
            const SizedBox(height: 8),
            
            // Order time
            _buildInfoRow(
              label: 'Time',
              value: DateFormat.jm().format(order.createdAt),
            ),
            const SizedBox(height: 8),
            
            // Resource (table/delivery)
            _buildInfoRow(
              label: order.isDelivery ? 'Delivery to' : 'Table',
              value: order.isDelivery 
                  ? 'Address: ${order.address ?? 'N/A'}'
                  : order.id ?? 'N/A',
            ),
            const SizedBox(height: 8),
            
            // Person count
            _buildInfoRow(
              label: 'People',
              value: '${order.customerCount}',
            ),
            
            // if (order.specialInstructions != null && order.specialInstructions!.isNotEmpty) ...[
            //   const SizedBox(height: 16),
            //   const Divider(),
            //   const SizedBox(height: 8),
              
            //   Text(
            //     'Special Instructions',
            //     style: theme.textTheme.titleSmall,
            //   ),
            //   const SizedBox(height: 4),
            //   Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: theme.colorScheme.surfaceVariant,
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //     child: Text(order.specialInstructions!),
            //   ),
            // ],
          
          ],
        ),
      ),
    );
  }
  
  Widget _buildCustomerCard(Order order) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Customer name
            _buildInfoRow(
              label: 'Name',
              value: order.customerName ?? 'N/A',
              icon: Icons.person,
            ),
            const SizedBox(height: 8),
            
            // Customer phone
            _buildInfoRow(
              label: 'Phone',
              value:   'N/A',
              icon: Icons.phone,
            ),
            const SizedBox(height: 8),
            
            // Customer email
            _buildInfoRow(
              label: 'Email',
              value: order.email ?? 'N/A',
              icon: Icons.email,
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // Customer ID
            _buildInfoRow(
              label: 'Customer ID',
              value: order.userId.substring(0, 8),
              icon: Icons.badge,
            ),
            const SizedBox(height: 8),
            
            // Loyalty points or other customer metadata could go here
            
            // View customer details button
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_search, size: 18),
                label: const Text('View Customer Details'),
                onPressed: () => _viewCustomerDetails(order.userId),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderItemsCard(Order order) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Items',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Items list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return _buildOrderItemRow(item);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderTotalsCard(Order order) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Subtotal
            _buildSummaryRow(
              label: 'Subtotal',
              value: '\$${order.subtotal?.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            
            // Tax
            _buildSummaryRow(
              label: 'Tax',
              value: '\$${order.taxAmount?.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            
            // Discount (if applicable)
            if (0 > 0) ...[
              _buildSummaryRow(
                label: 'Discount',
                value: '-\$${order.taxAmount?.toStringAsFixed(2)}',
                valueColor: const Color.fromARGB(255, 208, 208, 208),
              ),
              const SizedBox(height: 8),
            ],
            
            // Delivery fee (if applicable)
            if (order.isDelivery && 200 > 0) ...[
              _buildSummaryRow(
                label: 'Delivery Fee',
                value: '\$ 200.00',
              ),
              const SizedBox(height: 8),
            ],
            
            // Divider before total
            const Divider(),
            const SizedBox(height: 8),
            
            // Total
            _buildSummaryRow(
              label: 'Total',
              value: '\$${order.totalAmount.toStringAsFixed(2)}',
              labelStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              valueStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            
            // Payment method (if available)
            if (order.paymentMethod != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                label: 'Payment Method',
                value: _capitalizeFirst(order.paymentMethod!),
                icon: Icons.payment,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
        ],
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildOrderItemRow(OrderItem item) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity with circular background
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${item.quantity}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.titleSmall,
                ),
                
                // Item options
                // if (item.options.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 4.0),
                //     child: Wrap(
                //       spacing: 8,
                //       children: item.options.entries.map((option) {
                //         return Container(
                //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                //           decoration: BoxDecoration(
                //             color: theme.colorScheme.surfaceVariant,
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //           child: Text(
                //             '${option.key}: ${option.value}',
                //             style: TextStyle(
                //               fontSize: 12,
                //               color: theme.colorScheme.onSurfaceVariant,
                //             ),
                //           ),
                //         );
                //       }).toList(),
                //     ),
                //   ),
                
                // Item notes
                if (item.notes != null && item.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Note: ${item.notes}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Item price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall,
              ),
              if (item.quantity > 1)
                Text(
                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: valueStyle ?? theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    setState(() {
      _isUpdatingStatus = true;
    });
    
    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(order.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${_capitalizeFirst(newStatus)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order status: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdatingStatus = false;
      });
    }
  }
  
  Future<void> _confirmCancelOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel Order'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _updateOrderStatus(order, 'cancelled');
    }
  }
  
  Future<void> _printReceipt(Order order) async {
    setState(() {
      _isPrinting = true;
    });
    
    try {
      // In a real app, implement printing logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulate printing
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt printed successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing receipt: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }
  
  void _emailReceipt(Order order) {
    // In a real app, implement email sending logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt sent to ${order.customerName ?? 'customer email'}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _viewCustomerDetails(String userId) {
    // Navigate to customer details screen
    Navigator.of(context).pushNamed('/admin/customers/$userId');
  }
  
  List<String> _getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['preparing'];
      case 'preparing':
        return ['ready'];
      case 'ready':
        return ['delivering', 'completed'];
      case 'delivering':
        return ['completed'];
      case 'completed':
        return [];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }
  
  String _getStatusActionText(String status) {
    switch (status) {
      case 'preparing':
        return 'Start Preparing';
      case 'ready':
        return 'Mark as Ready';
      case 'delivering':
        return 'Start Delivery';
      case 'completed':
        return 'Mark as Completed';
      default:
        return _capitalizeFirst(status);
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'delivering':
        return Colors.cyan;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

// Extension to make this a standalone screen if needed
class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrderDetailView(
      orderId: orderId,
    );
  }
}