import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/order_details_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';

// Enum to manage kitchen tabs
enum KitchenTab { newOrders, current, upcoming, turns }

class StaffKitchenScreen extends ConsumerStatefulWidget {
  final KitchenTab initialTab;
  const StaffKitchenScreen({super.key, this.initialTab = KitchenTab.newOrders});

  @override
  ConsumerState<StaffKitchenScreen> createState() => _StaffKitchenScreenState();
}

class _StaffKitchenScreenState extends ConsumerState<StaffKitchenScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedOrderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: KitchenTab.values.length,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get orders based on the current tab
  String _getStatusForTab(KitchenTab tab) {
    switch (tab) {
      case KitchenTab.newOrders:
        return 'pending';
      case KitchenTab.current:
        return 'preparing';
      case KitchenTab.upcoming:
        return 'ready';
      case KitchenTab.turns:
        return 'all'; // Show all orders for sequence management
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'New Orders', icon: Icon(Icons.fiber_new)),
            Tab(text: 'In Progress', icon: Icon(Icons.restaurant)),
            Tab(text: 'Ready', icon: Icon(Icons.check_circle)),
            Tab(text: 'All Orders', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: KitchenTab.values.map((tab) {
          return _buildOrdersView(tab, isDesktop, theme);
        }).toList(),
      ),
    );
  }

  Widget _buildOrdersView(KitchenTab tab, bool isDesktop, ThemeData theme) {
    final status = _getStatusForTab(tab);

    return Consumer(
      builder: (context, ref, child) {
        final ordersStream = status == 'all'
            ? ref.watch(ordersByDateProvider(DateTime.now()))
            : ref.watch(ordersByStatusStringProvider(status));

        return ordersStream.when(
          data: (orders) {
            if (orders.isEmpty) {
              return _buildEmptyState(tab, theme);
            }

            if (isDesktop && _selectedOrderId != null) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildOrdersList(orders, tab, theme),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 3,
                    child: OrderDetailView(
                      orderId: _selectedOrderId!,
                      onClose: () => setState(() => _selectedOrderId = null),
                    ),
                  ),
                ],
              );
            }

            return _buildOrdersList(orders, tab, theme);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading orders: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(ordersByStatusStringProvider(status));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(KitchenTab tab, ThemeData theme) {
    String message;
    IconData icon;

    switch (tab) {
      case KitchenTab.newOrders:
        message = 'No new orders to prepare';
        icon = Icons.done_all;
        break;
      case KitchenTab.current:
        message = 'No orders currently in progress';
        icon = Icons.restaurant;
        break;
      case KitchenTab.upcoming:
        message = 'No orders ready for pickup';
        icon = Icons.check_circle;
        break;
      case KitchenTab.turns:
        message = 'No orders available';
        icon = Icons.list;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, KitchenTab tab, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildKitchenOrderCard(order, tab, theme);
      },
    );
  }

  Widget _buildKitchenOrderCard(Order order, KitchenTab tab, ThemeData theme) {
    final isSelected = _selectedOrderId == order.id;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (isDesktop) {
            setState(() => _selectedOrderId = order.id);
          } else {
            context.goNamed(
              AdminRoutes.nameOrderDetails,
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
                  // Order info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Order #${order.id.substring(0, 6)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status.name)
                                    .withOpacity(0.1),
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
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.table_restaurant,
                              size: 16,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Table ${order.tableNumber ?? 'N/A'}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat.jm().format(order.createdAt),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick action buttons for kitchen
                  if (tab != KitchenTab.turns) ...[
                    _buildQuickActionButton(order, tab, theme),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Order items summary
              if (order.items.isNotEmpty) ...[
                Text(
                  'Items (${order.items.length}):',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...order.items.take(3).map((item) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.name,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                if (order.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '... and ${order.items.length - 3} more',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],

              // Special notes
              if (order.waiterNotes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.waiterNotes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(Order order, KitchenTab tab, ThemeData theme) {
    String label;
    IconData icon;
    OrderStatus nextStatus;
    Color color;

    switch (tab) {
      case KitchenTab.newOrders:
        label = 'Start';
        icon = Icons.play_arrow;
        nextStatus = OrderStatus.inProgress;
        color = Colors.blue;
        break;
      case KitchenTab.current:
        label = 'Ready';
        icon = Icons.check;
        nextStatus = OrderStatus.ready;
        color = Colors.green;
        break;
      case KitchenTab.upcoming:
        label = 'Deliver';
        icon = Icons.delivery_dining;
        nextStatus = OrderStatus.delivered;
        color = Colors.purple;
        break;
      default:
        return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () => _updateOrderStatus(order, nextStatus),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        minimumSize: const Size(80, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  void _updateOrderStatus(Order order, OrderStatus newStatus) async {
    try {
      final orderService = ref.read(orderServiceProvider);
      final updatedOrder = order.copyWith(
        status: newStatus,
        lastUpdated: DateTime.now(),
      );

      await orderService.updateOrder(updatedOrder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Order updated to ${_capitalizeFirst(newStatus.name)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.purple;
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
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
