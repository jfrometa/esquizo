import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/firebase_auth_repository.dart';
 
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/order_history_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_card.dart';
// Remove ColorsPaletteRedonda import
 
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart'
    as auth_models;
 
import '../../admin/models/order_status_enum.dart';


class InProgressOrdersScreen extends ConsumerStatefulWidget {
  const InProgressOrdersScreen({super.key});

  @override
  _InProgressOrdersScreenState createState() => _InProgressOrdersScreenState();
}

class _InProgressOrdersScreenState extends ConsumerState<InProgressOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Mis Ordenes'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: TabIndicator(
            radius: 16.0,
            color: colorScheme.primary,
          ),
          tabs: const [
            Tab(text: 'En Proceso'),
            Tab(text: 'Completadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrdersList(isCompleted: false),
          _OrdersList(isCompleted: true),
        ],
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  const _OrdersList({required this.isCompleted});
  final bool isCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(firebaseAuthProvider).currentUser;
    if (user == null) return const SizedBox.shrink();

    final ordersAsync = ref.watch(
      isCompleted ? completedOrdersProvider(user.uid) : activeOrdersProvider(user.uid),
    );

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, color: colorScheme.onSurfaceVariant, size: 60),
                const SizedBox(height: 16),
                Text(
                  isCompleted
                      ? 'No hay órdenes completadas'
                      : 'No hay órdenes en proceso',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(order: order);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: colorScheme.primary)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colorScheme.error, size: 60),
            const SizedBox(height: 16),
            Text(
              'Error al cargar las órdenes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final auth_models.Order order;

  const OrderCard({required this.order, Key? key}) : super(key: key);
  
  // Update the status color method to use theme colors
  Color _getStatusColor(String status, ColorScheme colorScheme) {
    final orderStatus = OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
    
    switch (orderStatus) {
      case OrderStatus.pending:
        return colorScheme.tertiary;
      case OrderStatus.paymentConfirmed:
        return colorScheme.primary;
      case OrderStatus.preparing:
        return colorScheme.secondary;
      case OrderStatus.readyForDelivery:
        return colorScheme.tertiary;
      case OrderStatus.delivering:
        return colorScheme.secondary;
      case OrderStatus.completed:
        return colorScheme.primary;
      case OrderStatus.cancelled:
        return colorScheme.error;
      case OrderStatus.inProgress:
        return colorScheme.secondary;
      case OrderStatus.ready:
        return colorScheme.tertiary;
      case OrderStatus.delivered:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 4,
      child: ExpansionTile(
        title: Text(
          'Orden #${order.orderNumber}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
        ),
        subtitle: Text(
          DateFormat.yMMMd().add_jm().format(order.timestamp.toDate()),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderDetailRow(
                  icon: Icons.attach_money,
                  label: 'Total',
                  value: '\$${order.totalAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 8),
                OrderDetailRow(
                  icon: Icons.local_shipping,
                  label: 'Estado',
                  value: order.status.name,
                  valueColor: _getStatusColor(order.status.name, colorScheme),
                ),
                const SizedBox(height: 8),
                if (order.items != null) ...[
                  Divider(color: colorScheme.outlineVariant),
                  Text(
                    'Artículos:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.items!.map((item) => ListTile(
                        dense: true,
                        title: Text(item.name),
                        trailing: Text('x${item.quantity}'),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
