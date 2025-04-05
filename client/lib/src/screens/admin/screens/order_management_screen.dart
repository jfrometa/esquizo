import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/create_order.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/order_details_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import '../widgets/responsive_layout.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() =>
      _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> {
  String _selectedStatus = 'all';
  String _searchQuery = '';
  DateTime? _selectedDate;
  bool _showFilters = false;

  final TextEditingController _searchController = TextEditingController();
  final List<String> _statusFilters = [
    'all',
    'pending',
    'preparing',
    'ready',
    'delivering',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final selectedOrderId = ref.watch(activeOrderIdProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            child: isDesktop && selectedOrderId != null
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildOrdersList(),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        flex: 3,
                        child: OrderDetailView(
                          orderId: selectedOrderId,
                          onClose: () => ref
                              .read(activeOrderIdProvider.notifier)
                              .state = null,
                        ),
                      ),
                    ],
                  )
                : _buildOrdersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOrderDialog,
        tooltip: 'Create Order',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showFilters ? 180 : 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
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
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon:
                    Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                tooltip: _showFilters ? 'Hide filters' : 'Show filters',
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 16),
            Text(
              'Filter by Status:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(
                        status == 'all' ? 'All' : _capitalizeFirst(status),
                      ),
                      selected: _selectedStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? status : 'all';
                        });
                      },
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedColor: _getStatusColor(status).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _selectedStatus == status
                            ? _getStatusColor(status)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Filter by Date:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _selectedDate != null
                        ? DateFormat.yMMMd().format(_selectedDate!)
                        : 'Select Date',
                  ),
                  onPressed: () => _selectDate(context),
                ),
                if (_selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                    tooltip: 'Clear date filter',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    final ordersStream = _selectedStatus == 'all'
        ? ref.watch(ordersByDateProvider(_selectedDate))
        : ref.watch(ordersByStatusStringProvider(_selectedStatus));

    return ordersStream.when(
      data: (orders) {
        // Apply search filter
        final filteredOrders = orders.where((order) {
          if (_searchQuery.isEmpty) return true;

          // Search by order ID
          if (order.id.toLowerCase().contains(_searchQuery)) return true;

          // Search by table number or customer name
          final resourceId = order.id.toLowerCase();
          final userName = order.customerName?.toLowerCase() ?? '';

          return resourceId.contains(_searchQuery) ||
              userName.contains(_searchQuery);
        }).toList();

        if (filteredOrders.isEmpty) {
          return const Center(
            child: Text('No orders found'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return _buildOrderCard(order);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildOrderCard(Order order) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final activeOrderId = ref.watch(activeOrderIdProvider);
    final isSelected = order.id == activeOrderId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (isDesktop) {
            // For desktop, set active order for side view
            ref.read(activeOrderIdProvider.notifier).state = order.id;
          } else {
            // For mobile, navigate to detail page using named route
            context.goNamed(
              AdminRoutes.namePdOrderDetails,
              pathParameters: {'orderId': order.id},
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                children: [
                  // Order ID
                  Text(
                    'Order #${order.id.substring(0, 6)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Order status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(order.status.name).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _capitalizeFirst(order.status.name),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(order.status.name),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Order date/time
                  Text(
                    DateFormat.yMMMd().add_jm().format(order.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Order details
              Row(
                children: [
                  // Resource (table/delivery) info
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          order.isDelivery
                              ? Icons.delivery_dining
                              : Icons.table_restaurant,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.isDelivery
                              ? 'Delivery'
                              : 'Table ${order.id ?? 'N/A'}',
                        ),
                      ],
                    ),
                  ),

                  // Items count
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text('${order.items.length} items'),
                      ],
                    ),
                  ),

                  // Total amount
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View details button
                  OutlinedButton.icon(
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                    onPressed: () {
                      if (isDesktop) {
                        ref.read(activeOrderIdProvider.notifier).state =
                            order.id;
                      } else {
                        context.push('/admin/orders/${order.id}');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Status update button
                  if (order.status != 'completed' &&
                      order.status != 'cancelled')
                    ElevatedButton.icon(
                      icon: const Icon(Icons.update, size: 16),
                      label: Text(_getNextStatusLabel(order.status.name)),
                      onPressed: () => _updateOrderStatus(order),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCreateOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: CreateOrderForm(
            onSuccess: (order) {
              Navigator.pop(context);
              context.goNamed(
                AdminRoutes.namePdOrderDetails,
                pathParameters: {'orderId': order.id},
              );
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(Order order) async {
    try {
      final orderService = ref.read(orderServiceProvider);
      await orderService.updateOrderStatus(order.id, order.status);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Order status updated to ${_capitalizeFirst(order.status.name)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating order status: $e')),
        );
      }
    }
  }

  String _getNextStatusLabel(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return 'Mark Preparing';
      case 'preparing':
        return 'Mark Ready';
      case 'ready':
        return 'Mark Delivering';
      case 'delivering':
        return 'Mark Completed';
      default:
        return 'Update Status';
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
      case 'all':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

