import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/screens/caterig_order_details_screen.dart';  
 
class CateringOrdersScreen extends ConsumerStatefulWidget {
  const CateringOrdersScreen({super.key});

  @override
  ConsumerState<CateringOrdersScreen> createState() => _CateringOrdersScreenState();
}

class _CateringOrdersScreenState extends ConsumerState<CateringOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  CateringOrderStatus? _statusFilter;
  DateTime? _dateFilter;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Today'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Filter by Date',
            onPressed: _selectDateFilter,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by Status',
            onPressed: _showStatusFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search orders...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Filter chips
          if (_statusFilter != null || _dateFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_statusFilter != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Status: ${_statusFilter!.displayName}'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _statusFilter = null;
                          });
                        },
                      ),
                    ),
                  if (_dateFilter != null)
                    Chip(
                      label: Text('Date: ${DateFormat('MMM d, yyyy').format(_dateFilter!)}'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _dateFilter = null;
                        });
                      },
                    ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
                    onPressed: () {
                      setState(() {
                        _statusFilter = null;
                        _dateFilter = null;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Orders
                Consumer(
                  builder: (context, ref, child) {
                    final ordersAsync = ref.watch(cateringOrderStatisticsProvider);
                    return ordersAsync.when(
                      data: (orders) => _buildOrdersList(
                        applyFilters([orders]),
                        colorScheme,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Center(child: Text('Error: $error')),
                    );
                  },
                ),
                
                // Upcoming Orders
                Consumer(
                  builder: (context, ref, child) {
                    final ordersAsync = ref.watch(upcomingCateringOrdersProvider);
                    return ordersAsync.when(
                      data: (orders) => _buildOrdersList(
                        applyFilters(orders),
                        colorScheme,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Center(child: Text('Error: $error')),
                    );
                  },
                ),
                
                // Today's Orders
                Consumer(
                  builder: (context, ref, child) {
                    final ordersAsync = ref.watch(todayCateringOrdersProvider);
                    return ordersAsync.when(
                      data: (orders) => _buildOrdersList(
                        applyFilters(orders),
                        colorScheme,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Center(child: Text('Error: $error')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewOrder,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
  
  List<CateringOrder> applyFilters(List<CateringOrder> orders) {
    var filteredOrders = orders;
    
    // Apply status filter if set
    if (_statusFilter != null) {
      filteredOrders = filteredOrders
          .where((order) => order.status == _statusFilter)
          .toList();
    }
    
    // Apply date filter if set
    if (_dateFilter != null) {
      final startOfDay = DateTime(_dateFilter!.year, _dateFilter!.month, _dateFilter!.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      filteredOrders = filteredOrders
          .where((order) => 
              order.eventDate.isAfter(startOfDay) && 
              order.eventDate.isBefore(endOfDay))
          .toList();
    }
    
    // Apply search filter if set
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders
          .where((order) => 
              order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              order.eventType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              order.eventAddress.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (order.packageName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }
    
    return filteredOrders;
  }
  
  Widget _buildOrdersList(List<CateringOrder> orders, ColorScheme colorScheme) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _statusFilter != null || _dateFilter != null || _searchQuery.isNotEmpty
                  ? 'No Orders Match Your Filters'
                  : 'No Orders Available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _statusFilter != null || _dateFilter != null || _searchQuery.isNotEmpty
                  ? 'Try adjusting your filters'
                  : 'Create your first catering order',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (_statusFilter != null || _dateFilter != null || _searchQuery.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _statusFilter = null;
                    _dateFilter = null;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Clear Filters'),
              )
            else
              ElevatedButton.icon(
                onPressed: _createNewOrder,
                icon: const Icon(Icons.add),
                label: const Text('Create Order'),
              ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, colorScheme);
      },
    );
  }
  
  Widget _buildOrderCard(CateringOrder order, ColorScheme colorScheme) {
    final statusColor = order.status.color;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToOrderDetails(order.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header with status
            Container(
              color: statusColor.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          order.status.icon,
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Order #${order.id.substring(0, min(6, order.id.length))}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            order.status.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(order.eventDate),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Order details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer and package info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.customerName.isNotEmpty)
                              Text(
                                order.customerName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    order.eventType.isNotEmpty
                                        ? order.eventType
                                        : 'Event type not specified',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${order.guestCount} Guests',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getPaymentStatusColor(order.paymentStatus, colorScheme).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatPaymentStatus(order.paymentStatus),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getPaymentStatusColor(order.paymentStatus, colorScheme),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Package info
                  if (order.packageName != null && order.packageName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Package: ${order.packageName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (order.hasChef)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.restaurant,
                                    size: 12,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Chef',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Location and time
                  if (order.eventAddress.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.eventAddress,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Event Time: ${DateFormat('h:mm a').format(order.eventDate)}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action buttons
            OverflowBar(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text('View Details'),
                  onPressed: () => _navigateToOrderDetails(order.id),
                ),
                if (!order.status.isTerminal)
                  _buildStatusUpdateButton(order),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusUpdateButton(CateringOrder order) {
    final theme = Theme.of(context);
    
    // Get next logical status
    final nextStatus = order.status.allowedTransitions.isNotEmpty
        ? order.status.allowedTransitions.first
        : null;
    
    if (nextStatus == null) {
      return const SizedBox.shrink();
    }
    
    final buttonColor = nextStatus.color;
    
    return FilledButton.icon(
      icon: Icon(nextStatus.icon),
      label: Text('Mark as ${nextStatus.displayName}'),
      style: FilledButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: theme.colorScheme.surface,
      ),
      onPressed: () => _updateOrderStatus(order.id, nextStatus),
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
  
  void _navigateToOrderDetails(String orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CateringOrderDetailsScreen(orderId: orderId),
      ),
    );
  }
  
  void _updateOrderStatus(String orderId, CateringOrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update to ${newStatus.displayName}?'),
        content: Text('Are you sure you want to update this order to ${newStatus.displayName} status?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cateringOrderProvider.notifier)
                  .updateOrderStatus(orderId, newStatus);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order updated to ${newStatus.displayName}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  void _selectDateFilter() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dateFilter ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (selectedDate != null) {
      setState(() {
        _dateFilter = selectedDate;
      });
    }
  }
  
  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ...CateringOrderStatus.values.map((status) => 
                RadioListTile<CateringOrderStatus>(
                  title: Row(
                    children: [
                      Icon(status.icon, color: status.color, size: 20),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                  value: status,
                  groupValue: _statusFilter,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      _statusFilter = value;
                    });
                  },
                ),
              ),
              RadioListTile<CateringOrderStatus?>(
                title: const Text('All Statuses'),
                value: null,
                groupValue: _statusFilter,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _statusFilter = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _createNewOrder() {
    // Navigate to order creation screen
    // This would typically show a form to create a new catering order
  }
}