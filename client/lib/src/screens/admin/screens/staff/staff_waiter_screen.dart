import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/table_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/admin_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/table_and_order_management/table_and_order_management_screen.dart';

class StaffWaiterTableSelectScreen extends ConsumerStatefulWidget {
  const StaffWaiterTableSelectScreen({super.key});

  @override
  ConsumerState<StaffWaiterTableSelectScreen> createState() =>
      _StaffWaiterTableSelectScreenState();
}

class _StaffWaiterTableSelectScreenState
    extends ConsumerState<StaffWaiterTableSelectScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tablesAsync = ref.watch(tablesStatusProvider);

    return Scaffold(
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Table Status:',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(width: 16),
                Expanded(
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
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
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
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tables found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _filterStatus == 'all'
                ? 'No tables have been set up yet'
                : 'No tables with status "$_filterStatus"',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
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
          color: statusColor.withOpacity(0.3),
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
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
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
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
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
            ],
          ),
        ),
      ),
    );
  }

  void _handleTableTap(RestaurantTable table) {
    switch (table.status) {
      case TableStatusEnum.available:
      case TableStatusEnum.reserved:
        // Create new order for the table
        _createNewOrder(table);
        break;
      case TableStatusEnum.occupied:
        // View or edit existing order
        if (table.currentOrderId != null) {
          _viewExistingOrder(table);
        } else {
          _createNewOrder(table);
        }
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
    // Navigate to the comprehensive order creation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableOrderScreen(
          table: table,
          existingOrder: null,
        ),
      ),
    ).then((_) {
      // Refresh tables after order creation
      final _ = ref.refresh(tablesStatusProvider);
    });
  }

  void _viewExistingOrder(RestaurantTable table) {
    // For now, navigate to order details
    // In the future, this could load the existing order and open TableOrderScreen
    context.goNamed(
      AdminRoutes.namePdOrderDetails,
      pathParameters: {'orderId': table.currentOrderId!},
    );
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
}
