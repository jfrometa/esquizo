import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/order_history_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart'
    as auth_models;
// Create a provider for active orders pagination
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/models/order_status.dart';

// Update the providers to use enum values
final activeOrdersProvider = StreamProvider.family<List<auth_models.Order>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .where('status', whereIn: [
        OrderStatus.pending.name,
        OrderStatus.paymentConfirmed.name,
        OrderStatus.preparing.name,
        OrderStatus.readyForDelivery.name,
        OrderStatus.delivering.name,
      ])
      .orderBy('orderDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => auth_models.Order.fromFirestore(doc))
          .toList());
});

// Create a provider for completed orders pagination
final completedOrdersProvider = StreamProvider.family<List<auth_models.Order>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('orders')
      .where('userId', isEqualTo: userId)
      .where('status', whereIn: ['delivered', 'cancelled'])
      .orderBy('orderDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => auth_models.Order.fromFirestore(doc))
          .toList());
});

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
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Mis Ordenes'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorsPaletteRedonda.white,
          unselectedLabelColor: ColorsPaletteRedonda.deepBrown1,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: TabIndicator(
            radius: 16.0,
            color: ColorsPaletteRedonda.primary,
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
                const Icon(Icons.inbox_outlined, color: Colors.grey, size: 60),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
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
  // Update the status color method
  Color _getStatusColor(String status) {
    final orderStatus = OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.pending,
    );
    
    switch (orderStatus) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paymentConfirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.indigo;
      case OrderStatus.readyForDelivery:
        return Colors.teal;
      case OrderStatus.delivering:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                color: ColorsPaletteRedonda.primary,
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
                  value: order.status,
                  valueColor: _getStatusColor(order.status),
                ),
                const SizedBox(height: 8),
                if (order.items != null) ...[
                  const Divider(),
                  const Text(
                    'Artículos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...order.items!.map((item) => ListTile(
                        dense: true,
                        title: Text(item.title),
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
