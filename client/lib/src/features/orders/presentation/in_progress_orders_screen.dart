import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

enum OrderStatus {
  pending('Pendiente'),
  inProgress('En preparación'),
  onTheWay('En camino'),
  arrived('Llegó'),
  delivered('Entregado');

  final String label;
  const OrderStatus(this.label);
}

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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en preparación':
        return Colors.blue;
      case 'en camino':
        return Colors.purple;
      case 'llegó':
        return Colors.green;
      case 'entregado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: isCompleted ? 'Entregado' : 'En Proceso')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Improved error handling
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar las órdenes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Por favor, revise su conexión e intente de nuevo',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        // Check if snapshot has data
        final orders = snapshot.data?.docs ?? [];

        // Empty state handling
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

        // List of orders
        return ListView.builder(
          key: PageStorageKey<bool>(isCompleted),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            // Safely extract order data
            final order = orders[index].data() as Map<String, dynamic>? ?? {};

            // Null-safe checks for critical fields
            final orderNumber = order['orderNumber']?.toString() ?? 'N/A';
            final orderType = order['orderType']?.toString() ?? 'N/A';
            final timestamp = order['timestamp'] is Timestamp
                ? (order['timestamp'] as Timestamp).toDate()
                : DateTime.now();
            final orderStatus =
                order['orderStatus']?.toString() ?? 'Desconocido';
            final paymentStatus =
                order['paymentStatus']?.toString() ?? 'No pagado';
            final totalAmount = order['totalAmount'] is num
                ? (order['totalAmount'] as num).toStringAsFixed(2)
                : '0.00';

            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              elevation: 2,
              child: ListTile(
                title: Text(
                  'Orden #$orderNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Tipo: $orderType'),
                    Text(
                      'Fecha: ${DateFormat.yMMMd().add_jm().format(timestamp)}',
                    ),
                    Row(
                      children: [
                        const Text('Estado: '),
                        Chip(
                          label: Text(orderStatus),
                          backgroundColor: _getStatusColor(orderStatus),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Pago: '),
                        Chip(
                          label: Text(paymentStatus),
                          backgroundColor:
                              paymentStatus.toLowerCase() == 'pagado'
                                  ? Colors.green
                                  : Colors.red,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Text(
                  '\$$totalAmount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
