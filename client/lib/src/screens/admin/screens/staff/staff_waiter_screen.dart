import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/table_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/table_and_order_management/table_and_order_management_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';

// Enum for waiter view modes
enum WaiterViewMode { tables, activeOrders, notifications }

// Enum for notification types
enum NotificationType {
  itemReady,
  orderComplete,
  orderDelayed,
  itemCancelled,
  customerRequest,
  kitchenAlert
}

// Kitchen notification model
class KitchenNotification {
  final String id;
  final String orderId;
  final int tableNumber;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? itemName;
  final int? itemQuantity;

  KitchenNotification({
    required this.id,
    required this.orderId,
    required this.tableNumber,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.itemName,
    this.itemQuantity,
  });

  KitchenNotification copyWith({
    String? id,
    String? orderId,
    int? tableNumber,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? itemName,
    int? itemQuantity,
  }) {
    return KitchenNotification(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      tableNumber: tableNumber ?? this.tableNumber,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      itemName: itemName ?? this.itemName,
      itemQuantity: itemQuantity ?? this.itemQuantity,
    );
  }
}

// Mock provider for kitchen notifications (replace with real implementation)
final kitchenNotificationsProvider =
    StreamProvider<List<KitchenNotification>>((ref) {
  // In a real implementation, this would connect to Firestore or another real-time database
  // For now, return a stream with mock data
  return Stream.periodic(const Duration(seconds: 5), (index) {
    final now = DateTime.now();
    return [
      KitchenNotification(
        id: 'notif_1',
        orderId: 'order_123',
        tableNumber: 5,
        type: NotificationType.itemReady,
        title: 'Item Ready for Pickup',
        message: 'Caesar Salad is ready for Table 5',
        timestamp: now.subtract(const Duration(minutes: 2)),
        itemName: 'Caesar Salad',
        itemQuantity: 1,
      ),
      KitchenNotification(
        id: 'notif_2',
        orderId: 'order_124',
        tableNumber: 3,
        type: NotificationType.orderComplete,
        title: 'Order Complete',
        message: 'All items for Table 3 are ready',
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      if (index % 3 == 0)
        KitchenNotification(
          id: 'notif_3',
          orderId: 'order_125',
          tableNumber: 7,
          type: NotificationType.orderDelayed,
          title: 'Order Delayed',
          message: 'Grilled Salmon will be delayed by 10 minutes',
          timestamp: now.subtract(const Duration(minutes: 1)),
          itemName: 'Grilled Salmon',
          itemQuantity: 2,
        ),
    ];
  });
});

class StaffWaiterTableSelectScreen extends ConsumerStatefulWidget {
  const StaffWaiterTableSelectScreen({super.key});

  @override
  ConsumerState<StaffWaiterTableSelectScreen> createState() =>
      _StaffWaiterTableSelectScreenState();
}

class _StaffWaiterTableSelectScreenState
    extends ConsumerState<StaffWaiterTableSelectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WaiterViewMode _viewMode = WaiterViewMode.tables;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _viewMode = WaiterViewMode.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiter Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.table_restaurant),
              text: 'Tables',
            ),
            Tab(
              icon: Icon(Icons.receipt_long),
              text: 'Active Orders',
            ),
            Tab(
              icon: Icon(Icons.notifications),
              text: 'Notifications',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTablesView(),
          _buildActiveOrdersView(),
          _buildNotificationsView(),
        ],
      ),
      floatingActionButton: _viewMode == WaiterViewMode.tables
          ? FloatingActionButton.extended(
              onPressed: _showNewOrderDialog,
              icon: const Icon(Icons.add),
              label: const Text('New Order'),
            )
          : null,
    );
  }

  Widget _buildTablesView() {
    final theme = Theme.of(context);
    final tablesAsync = ref.watch(tablesStatusProvider);

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Table Status:',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'all',
                        label: Text('All'),
                        icon: Icon(Icons.table_restaurant),
                      ),
                      ButtonSegment(
                        value: 'available',
                        label: Text('Available'),
                        icon: Icon(Icons.check_circle),
                      ),
                      ButtonSegment(
                        value: 'occupied',
                        label: Text('Occupied'),
                        icon: Icon(Icons.people),
                      ),
                      ButtonSegment(
                        value: 'reserved',
                        label: Text('Reserved'),
                        icon: Icon(Icons.event),
                      ),
                    ],
                    selected: {_filterStatus},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _filterStatus = selection.first;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tables grid
        Expanded(
          child: tablesAsync.when(
            data: (tables) {
              final filteredTables = _filterStatus == 'all'
                  ? tables
                  : tables
                      .where((table) => table.status.name == _filterStatus)
                      .toList();

              if (filteredTables.isEmpty) {
                return _buildEmptyState(theme);
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredTables.length,
                  itemBuilder: (context, index) {
                    final table = filteredTables[index];
                    return _buildTableCard(table, theme);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error loading tables: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(tablesStatusProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveOrdersView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: const TabBar(
              tabs: [
                Tab(text: 'Pending Orders', icon: Icon(Icons.pending)),
                Tab(text: 'In Progress', icon: Icon(Icons.restaurant)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrdersList(
                    ref.watch(ordersByStatusStringProvider('pending')),
                    'pending'),
                _buildOrdersList(
                    ref.watch(ordersByStatusStringProvider('preparing')),
                    'preparing'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(AsyncValue<List<Order>> ordersAsync, String status) {
    final theme = Theme.of(context);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'pending' ? Icons.pending : Icons.restaurant,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  status == 'pending'
                      ? 'No pending orders'
                      : 'No orders in progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
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
            return _buildOrderCard(order, theme);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading orders: $error'),
      ),
    );
  }

  Widget _buildOrderCard(Order order, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            'T${order.tableNumber ?? '?'}',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Order #${order.id.substring(0, 6)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(order.status),
                style: TextStyle(
                  color: _getStatusColor(order.status),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text('${order.items.length} items'),
                const SizedBox(width: 16),
                Icon(
                  Icons.people,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text('${order.customerCount ?? 1} guests'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Created: ${DateFormat.jm().format(order.createdAt)}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order items list
                Text(
                  'Order Items:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _addToExistingOrder(order),
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Add Items'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewOrderDetails(order),
                        icon: const Icon(Icons.receipt_long, size: 18),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                // Additional order management actions
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => _splitOrder(order),
                      icon: const Icon(Icons.call_split, size: 16),
                      label: const Text('Split'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _printOrder(order),
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Print'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _requestKitchenStatus(order),
                      icon: const Icon(Icons.kitchen, size: 16),
                      label: const Text('Kitchen'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.readyForDelivery:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.readyForDelivery:
        return 'READY';
      case OrderStatus.completed:
        return 'COMPLETED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
      default:
        return 'UNKNOWN';
    }
  }

  Widget _buildNotificationsView() {
    final theme = Theme.of(context);
    // Real-time notifications for kitchen-waiter communication
    final kitchenNotificationsAsync = ref.watch(kitchenNotificationsProvider);

    return kitchenNotificationsAsync.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ll be notified when kitchen marks items as ready',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification, theme);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error loading notifications: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(kitchenNotificationsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
      KitchenNotification notification, ThemeData theme) {
    Color typeColor;
    IconData typeIcon;

    switch (notification.type) {
      case NotificationType.itemReady:
        typeColor = Colors.green;
        typeIcon = Icons.check_circle;
        break;
      case NotificationType.orderComplete:
        typeColor = Colors.blue;
        typeIcon = Icons.done_all;
        break;
      case NotificationType.orderDelayed:
        typeColor = Colors.orange;
        typeIcon = Icons.schedule;
        break;
      case NotificationType.itemCancelled:
        typeColor = Colors.red;
        typeIcon = Icons.cancel;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.info;
    }

    return Card(
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead
          ? null
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withValues(alpha: 0.2),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight:
                      notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.table_restaurant,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Table ${notification.tableNumber}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat.jm().format(notification.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: notification.type == NotificationType.itemReady ||
                notification.type == NotificationType.orderComplete
            ? ElevatedButton(
                onPressed: () => _handleNotificationAction(notification),
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  notification.type == NotificationType.itemReady
                      ? 'Deliver'
                      : 'Complete',
                  style: const TextStyle(fontSize: 12),
                ),
              )
            : null,
        onTap: () => _markNotificationAsRead(notification),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tables found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterStatus == 'all'
                ? 'No tables have been set up yet'
                : 'No tables with status "$_filterStatus"',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(RestaurantTable table, ThemeData theme) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (table.status) {
      case TableStatusEnum.available:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Available';
        break;
      case TableStatusEnum.occupied:
        statusColor = Colors.red;
        statusIcon = Icons.people;
        statusText = 'Occupied';
        break;
      case TableStatusEnum.reserved:
        statusColor = Colors.orange;
        statusIcon = Icons.event;
        statusText = 'Reserved';
        break;
      case TableStatusEnum.maintenance:
        statusColor = Colors.grey;
        statusIcon = Icons.build;
        statusText = 'Maintenance';
        break;
      case TableStatusEnum.cleaning:
        statusColor = Colors.blue;
        statusIcon = Icons.cleaning_services;
        statusText = 'Cleaning';
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _handleTableTap(table),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Table number
              Text(
                'Table ${table.number}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Capacity
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chair,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${table.capacity} seats',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Additional info for occupied tables
              if (table.status == TableStatusEnum.occupied &&
                  table.currentOrderId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active Order',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Quick actions
              if (table.status == TableStatusEnum.occupied &&
                  table.currentOrderId != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => _addToExistingOrderByTable(table),
                      icon: const Icon(Icons.add, size: 16),
                      tooltip: 'Add Items',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _viewTableOrder(table),
                      icon: const Icon(Icons.receipt_long, size: 16),
                      tooltip: 'View Order',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Action handlers
  void _handleTableTap(RestaurantTable table) {
    switch (table.status) {
      case TableStatusEnum.available:
      case TableStatusEnum.reserved:
        // Create new order for the table
        _createNewOrder(table);
        break;
      case TableStatusEnum.occupied:
        // Show options for existing order
        _showTableOptionsDialog(table);
        break;
      case TableStatusEnum.maintenance:
        _showMaintenanceDialog(table);
        break;
      case TableStatusEnum.cleaning:
        _showCleaningDialog(table);
        break;
    }
  }

  void _createNewOrder(RestaurantTable table) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableOrderScreen(
          table: table,
          existingOrder: null,
        ),
      ),
    ).then((_) {
      // Refresh tables after navigation
      final _ = ref.refresh(tablesStatusProvider);
    });
  }

  void _addToExistingOrder(Order order) {
    // Find the table for this order
    final tablesAsync = ref.read(tablesStatusProvider);
    final businessId = ref.read(currentBusinessIdProvider);
    tablesAsync.whenData((tables) {
      final table = tables.firstWhere(
        (t) => t.currentOrderId == order.id,
        orElse: () => RestaurantTable(
          id: 'unknown',
          businessId: businessId,
          number: order.tableNumber ?? 0,
          capacity: 4,
          status: TableStatusEnum.occupied,
        ),
      );
      _addToExistingOrderByTable(table);
    });
  }

  void _addToExistingOrderByTable(RestaurantTable table) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableOrderScreen(
          table: table,
          existingOrder: null, // Will load existing order automatically
        ),
      ),
    ).then((_) {
      // Refresh tables after navigation
      final _ = ref.refresh(tablesStatusProvider);
    });
  }

  void _viewTableOrder(RestaurantTable table) {
    if (table.currentOrderId != null) {
      context.goNamed(
        AdminRoutes.nameOrderDetails,
        pathParameters: {'orderId': table.currentOrderId!},
      );
    }
  }

  void _viewOrderDetails(Order order) {
    context.goNamed(
      AdminRoutes.nameOrderDetails,
      pathParameters: {'orderId': order.id},
    );
  }

  void _showTableOptionsDialog(RestaurantTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Table ${table.number}'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addToExistingOrderByTable(table);
            },
            child: const Text('Add Items'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewTableOrder(table);
            },
            child: const Text('View Order'),
          ),
        ],
      ),
    );
  }

  void _showNewOrderDialog() {
    _showTableAssignmentDialog();
  }

  void _showMaintenanceDialog(RestaurantTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Table ${table.number}'),
        content: const Text(
          'This table is currently under maintenance and cannot be used for orders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCleaningDialog(RestaurantTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Table ${table.number}'),
        content: const Text(
          'This table is currently being cleaned and cannot be used for orders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Enhanced notification handling methods
  void _handleNotificationAction(KitchenNotification notification) {
    switch (notification.type) {
      case NotificationType.itemReady:
        _deliverItem(notification);
        break;
      case NotificationType.orderComplete:
        _completeOrder(notification);
        break;
      default:
        _markNotificationAsRead(notification);
    }
  }

  void _deliverItem(KitchenNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deliver Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Table ${notification.tableNumber}'),
            const SizedBox(height: 8),
            Text(
              '${notification.itemName} (${notification.itemQuantity ?? 1}x)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Mark this item as delivered to the customer?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markNotificationAsRead(notification);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${notification.itemName} delivered to Table ${notification.tableNumber}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delivered'),
          ),
        ],
      ),
    );
  }

  void _completeOrder(KitchenNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Table ${notification.tableNumber}'),
            const SizedBox(height: 8),
            const Text('All items are ready for delivery.'),
            const SizedBox(height: 16),
            const Text('Mark this order as completed?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markNotificationAsRead(notification);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Order for Table ${notification.tableNumber} completed'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _markNotificationAsRead(KitchenNotification notification) {
    // In a real implementation, this would update the notification status in the database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification marked as read'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Enhanced table assignment methods
  void _showTableAssignmentDialog() {
    final tablesAsync = ref.read(tablesStatusProvider);
    tablesAsync.whenData((tables) {
      final availableTables = tables
          .where((table) =>
              table.status == TableStatusEnum.available ||
              table.status == TableStatusEnum.reserved)
          .toList();

      if (availableTables.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No available tables for new orders'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Assign Table'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: Column(
              children: [
                const Text('Select a table for the new order:'),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableTables.length,
                    itemBuilder: (context, index) {
                      final table = availableTables[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                table.status == TableStatusEnum.available
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.orange.withValues(alpha: 0.2),
                            child: Text(
                              'T${table.number}',
                              style: TextStyle(
                                color: table.status == TableStatusEnum.available
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text('Table ${table.number}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${table.capacity} seats'),
                              Text(
                                table.status.name.toUpperCase(),
                                style: TextStyle(
                                  color:
                                      table.status == TableStatusEnum.available
                                          ? Colors.green
                                          : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            table.status == TableStatusEnum.available
                                ? Icons.check_circle
                                : Icons.event,
                            color: table.status == TableStatusEnum.available
                                ? Colors.green
                                : Colors.orange,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _createNewOrder(table);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    });
  }

  // Enhanced order management methods
  void _splitOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Split Order #${order.id.substring(0, 6)}'),
            const SizedBox(height: 16),
            const Text(
                'This feature allows you to split the order into multiple bills.'),
            const SizedBox(height: 8),
            const Text('Coming soon: Select items for each split.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order split feature coming soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Split'),
          ),
        ],
      ),
    );
  }

  void _printOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Print Order #${order.id.substring(0, 6)}'),
            const SizedBox(height: 16),
            const Text('Choose what to print:'),
            const SizedBox(height: 16),
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('Customer Receipt'),
                  onTap: () {
                    Navigator.pop(context);
                    _printCustomerReceipt(order);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant_menu),
                  title: const Text('Kitchen Order'),
                  onTap: () {
                    Navigator.pop(context);
                    _printKitchenOrder(order);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _printCustomerReceipt(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Printing customer receipt for Table ${order.tableNumber}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _printKitchenOrder(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing kitchen order for Table ${order.tableNumber}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _requestKitchenStatus(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kitchen Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Order #${order.id.substring(0, 6)} - Table ${order.tableNumber}'),
            const SizedBox(height: 16),
            const Text('Current kitchen status:'),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.name)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              _getItemStatusColor(item).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getItemStatusText(item),
                          style: TextStyle(
                            color: _getItemStatusColor(item),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestKitchenUpdate(order);
            },
            child: const Text('Request Update'),
          ),
        ],
      ),
    );
  }

  Color _getItemStatusColor(OrderItem item) {
    // Mock status based on item properties
    // In real implementation, this would check actual item status
    return Colors.orange; // Default to "preparing"
  }

  String _getItemStatusText(OrderItem item) {
    // Mock status based on item properties
    // In real implementation, this would check actual item status
    return 'PREPARING';
  }

  void _requestKitchenUpdate(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Requested kitchen update for Table ${order.tableNumber}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
