import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart'; 

class CateringOrderDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;
  
  const CateringOrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<CateringOrderDetailsScreen> createState() => _CateringOrderDetailsScreenState();
}

class _CateringOrderDetailsScreenState extends ConsumerState<CateringOrderDetailsScreen> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(rawCateringOrderStream(widget.orderId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'print':
                  _printOrder();
                  break;
                case 'archive':
                  _archiveOrder();
                  break;
                case 'delete':
                  _confirmDeleteOrder();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Print Order'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive),
                    SizedBox(width: 8),
                    Text('Archive Order'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Order', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: orderAsync.when(
        data: (order) => _buildOrderDetails(order, theme, colorScheme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
  
  Widget _buildOrderDetails(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(cateringOrderProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          _buildStatusCard(order, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Order Info Card
          _buildOrderInfoCard(order, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Customer Info Card
          _buildCustomerInfoCard(order, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Items Card
          _buildOrderItemsCard(order, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Event Details Card
          _buildEventDetailsCard(order, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Timing Card
          _buildTimingCard(order, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Payment Card
          _buildPaymentCard(order, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Assignment Card
          _buildAssignmentCard(order, theme, colorScheme),
          
          const SizedBox(height: 24),
          
          // Status History Card (if available)
          // _buildStatusHistoryCard(order, theme, colorScheme),
          
          const SizedBox(height: 32),
          
          if (!order.status.isTerminal)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showUpdateStatusDialog,
                icon: const Icon(Icons.update),
                label: const Text('Update Status'),
              ),
            ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
    final statusColor = order.status.color;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(
                    order.status.icon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, min(6, order.id.length))}',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          order.status.displayName,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!order.status.isTerminal)
                  IconButton(
                    onPressed: _showUpdateStatusDialog,
                    icon: const Icon(Icons.edit),
                    tooltip: 'Update Status',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              order.status.description,
              style: theme.textTheme.bodyMedium,
            ),
            if (order.lastStatusUpdate != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Last updated: ${DateFormat('MMM d, yyyy h:mm a').format(order.lastStatusUpdate!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderInfoCard(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
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
                  'Order Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Created: ${DateFormat('MMM d, yyyy').format(order.orderDate)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Order ID:',
              order.id,
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Event Type:',
              order.eventType.isEmpty ? 'Not specified' : order.eventType,
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Guest Count:',
              '${order.guestCount} people',
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            if (order.packageName != null) ...[
              _buildInfoRow(
                'Package:',
                order.packageName!,
                theme,
                colorScheme,
              ),
              const SizedBox(height: 8),
            ],
            _buildInfoRow(
              'Chef Service:',
              order.hasChef ? 'Yes' : 'No',
              theme,
              colorScheme,
            ),
            if (order.dietaryRestrictions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Dietary Restrictions:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: order.dietaryRestrictions.map((restriction) => 
                  Chip(
                    label: Text(restriction),
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ).toList(),
              ),
            ],
            if (order.specialInstructions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Special Instructions:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.specialInstructions),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildCustomerInfoCard(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
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
                  'Customer Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Customer Info',
                  onPressed: () {
                    // Edit customer info
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Name:',
              order.customerName.isEmpty ? 'Not provided' : order.customerName,
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Email:',
              order.customerEmail.isEmpty ? 'Not provided' : order.customerEmail,
              theme,
              colorScheme,
              customChild: order.customerEmail.isNotEmpty
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.customerEmail,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.email, size: 18),
                          tooltip: 'Send Email',
                          onPressed: () {
                            // Send email
                          },
                        ),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Phone:',
              order.customerPhone.isEmpty ? 'Not provided' : order.customerPhone,
              theme,
              colorScheme,
              customChild: order.customerPhone.isNotEmpty
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.customerPhone,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, size: 18),
                          tooltip: 'Call Customer',
                          onPressed: () {
                            // Call customer
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.message, size: 18),
                          tooltip: 'Send SMS',
                          onPressed: () {
                            // Send SMS
                          },
                        ),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Customer ID:',
              order.customerId,
              theme,
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderItemsCard(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final subtotal = order.items.fold<double>(
      0, 
      (sum, item) => sum + (item.price * item.quantity)
    );
    
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
                  'Order Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Items',
                  onPressed: () {
                    // Edit items
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            ...order.items.map((item) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.titleSmall,
                          ),
                          if (item.notes.isNotEmpty)
                            Text(
                              item.notes,
                              style: theme.textTheme.bodySmall,
                            ),
                          if (item.modifications.isNotEmpty)
                            Wrap(
                              spacing: 4,
                              children: item.modifications.map((mod) => 
                                Chip(
                                  label: Text(
                                    mod,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: colorScheme.surfaceVariant,
                                ),
                              ).toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(item.price),
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${currencyFormat.format(item.price * item.quantity)}',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).toList(),
            const Divider(),
            // Subtotal
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    currencyFormat.format(subtotal),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // Tax (usually ~8-10%)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tax',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    currencyFormat.format(order.total - subtotal),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // Total
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currencyFormat.format(order.total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEventDetailsCard(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
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
                  'Event Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Event Details',
                  onPressed: () {
                    // Edit event details
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Event Date:',
              DateFormat('EEEE, MMMM d, yyyy').format(order.eventDate),
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Event Time:',
              DateFormat('h:mm a').format(order.eventDate),
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Event Type:',
              order.eventType.isEmpty ? 'Not specified' : order.eventType,
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Location:',
              order.eventAddress.isEmpty ? 'Not specified' : order.eventAddress,
              theme,
              colorScheme,
              customChild: order.eventAddress.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.eventAddress,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Open maps
                          },
                          icon: const Icon(Icons.map, size: 16),
                          label: const Text('View on Map'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimingCard(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
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
                  'Timing Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Timing',
                  onPressed: () {
                    // Edit timing
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Order Placed:',
              DateFormat('MMM d, yyyy h:mm a').format(order.orderDate),
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Event Date:',
              DateFormat('MMM d, yyyy').format(order.eventDate),
              theme,
              colorScheme,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Event Time:',
              DateFormat('h:mm a').format(order.eventDate),
              theme,
              colorScheme,
            ),
            if (order.setupTime != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Setup Time:',
                DateFormat('h:mm a').format(order.setupTime!),
                theme,
                colorScheme,
              ),
            ],
            if (order.deliveryTime != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Delivery Time:',
                DateFormat('h:mm a').format(order.deliveryTime!),
                theme,
                colorScheme,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Set setup time
                    },
                    icon: const Icon(Icons.access_time),
                    label: const Text('Set Setup Time'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Set delivery time
                    },
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('Set Delivery Time'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentCard(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
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
                  'Payment Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Payment',
                  onPressed: () {
                    // Edit payment
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Total Amount:',
              currencyFormat.format(order.total),
              theme,
              colorScheme,
              valueTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Payment Status:',
              _formatPaymentStatus(order.paymentStatus),
              theme,
              colorScheme,
              customChild: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(order.paymentStatus, colorScheme).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _formatPaymentStatus(order.paymentStatus),
                  style: TextStyle(
                    color: _getPaymentStatusColor(order.paymentStatus, colorScheme),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (order.paymentId != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Payment ID:',
                order.paymentId!,
                theme,
                colorScheme,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showUpdatePaymentDialog,
                icon: const Icon(Icons.payment),
                label: const Text('Update Payment Status'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAssignmentCard(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
    final bool isAssigned = order.assignedStaffId != null;
    
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
                  'Staff Assignment',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isAssigned)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Change Assignment',
                    onPressed: _showAssignmentDialog,
                  ),
              ],
            ),
            const Divider(height: 24),
            if (isAssigned) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.person,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.assignedStaffName ?? 'Unknown Staff',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${order.assignedStaffId}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone),
                    tooltip: 'Call Staff',
                    onPressed: () {
                      // Call staff
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.message),
                    tooltip: 'Message Staff',
                    onPressed: () {
                      // Message staff
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Remove assignment
                  _showRemoveAssignmentDialog();
                },
                icon: const Icon(Icons.person_remove),
                label: const Text('Remove Assignment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_alt,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text('No staff assigned yet'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _showAssignmentDialog,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Assign Staff'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme,
    ColorScheme colorScheme, {
    TextStyle? valueTextStyle,
    Widget? customChild,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: customChild ?? Text(
            value,
            style: valueTextStyle ?? theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
  
  Color _getPaymentStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'partial':
        return Colors.blue;
      case 'refunded':
        return Colors.red;
      case 'failed':
        return Colors.redAccent;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
  
  String _formatPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Payment Pending';
      case 'partial':
        return 'Partially Paid';
      case 'refunded':
        return 'Refunded';
      case 'failed':
        return 'Payment Failed';
      default:
        return status.isNotEmpty ? status : 'Not Paid';
    }
  }
  
  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final orderAsync = ref.watch(rawCateringOrderStream(widget.orderId));
          
          return orderAsync.when(
            data: (order) {
              final allowedStatuses = order.status.allowedTransitions;
              CateringOrderStatus? selectedStatus;
              
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Update Order Status'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current status: ${order.status.displayName}'),
                        const SizedBox(height: 16),
                        const Text('Select new status:'),
                        const SizedBox(height: 8),
                        if (allowedStatuses.isEmpty)
                          const Text(
                            'No further status changes available for this order.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          )
                        else
                          SizedBox(
                            width: double.maxFinite,
                            child: DropdownButtonFormField<CateringOrderStatus>(
                              value: selectedStatus,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: allowedStatuses.map((status) => 
                                DropdownMenuItem<CateringOrderStatus>(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Icon(status.icon, color: status.color, size: 18),
                                      const SizedBox(width: 8),
                                      Text(status.displayName),
                                    ],
                                  ),
                                ),
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedStatus = value;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: selectedStatus == null
                            ? null
                            : () async {
                                Navigator.pop(context);
                                
                                setState(() {
                                  _isLoading = true;
                                });
                                
                                try {
                                  await ref.read(cateringOrderProvider.notifier)
                                      .updateOrderStatus(widget.orderId, selectedStatus!);
                                      
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Status updated to ${selectedStatus!.displayName}'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                        child: const Text('Update Status'),
                      ),
                    ],
                  );
                }
              );
            },
            loading: () => const AlertDialog(
              content: Center(
                heightFactor: 1,
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to load order: $error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showUpdatePaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final orderAsync = ref.watch(rawCateringOrderStream(widget.orderId));
          
          return orderAsync.when(
            data: (order) {
              String selectedStatus = order.paymentStatus;
              final paymentIdController = TextEditingController(text: order.paymentId);
              
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Update Payment Status'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current status: ${_formatPaymentStatus(order.paymentStatus)}'),
                        const SizedBox(height: 16),
                        const Text('Select new status:'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.maxFinite,
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: ['pending', 'paid', 'partial', 'refunded', 'failed'].map((status) => 
                              DropdownMenuItem<String>(
                                value: status,
                                child: Text(_formatPaymentStatus(status)),
                              ),
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: paymentIdController,
                          decoration: const InputDecoration(
                            labelText: 'Payment ID (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          
                          setState(() {
                            _isLoading = true;
                          });
                          
                          try {
                            await ref.read(cateringOrderProvider.notifier)
                                .updatePaymentStatus(
                                  widget.orderId, 
                                  selectedStatus,
                                  paymentIdController.text.trim(),
                                );
                                
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Payment status updated to ${_formatPaymentStatus(selectedStatus)}'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        child: const Text('Update Payment'),
                      ),
                    ],
                  );
                }
              );
            },
            loading: () => const AlertDialog(
              content: Center(
                heightFactor: 1,
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to load order: $error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showAssignmentDialog() {
    // This would typically fetch a list of staff members from a provider
    // and display them for selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Staff'),
        content: const Text('Staff assignment functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showRemoveAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Assignment'),
        content: const Text('Are you sure you want to remove the staff assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Remove assignment
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
  
  void _printOrder() {
    // Print order functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Printing order...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _archiveOrder() {
    // Archive order functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order archived'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _confirmDeleteOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Order'),
        content: const Text('Are you sure you want to delete this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // Delete order
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}