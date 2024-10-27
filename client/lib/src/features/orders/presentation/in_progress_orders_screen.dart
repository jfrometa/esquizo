import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering.dart/catering_card.dart';
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

class InProgressOrdersScreen extends ConsumerWidget {
  const InProgressOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Ordenes'),
          bottom: TabBar(
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
          children: [
            _OrdersList(isCompleted: false),
            _OrdersList(isCompleted: true),
          ],
        ),
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
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: isCompleted ? 'pendiente' : 'entregado')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data?.docs ?? [];
        
        if (orders.isEmpty) {
          return Center(
            child: Text(
              isCompleted 
                ? 'No hay órdenes completadas' 
                : 'No hay órdenes en proceso'
            ),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data();
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  'Orden #${order['orderNumber']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Tipo: ${order['orderType']}'),
                    Text(
                      'Fecha: ${DateFormat.yMMMd().add_jm().format(order['timestamp'].toDate())}',
                    ),
                    Row(
                      children: [
                        const Text('Estado: '),
                        Chip(
                          label: Text(order['orderStatus']),
                          backgroundColor: _getStatusColor(order['orderStatus']),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Pago: '),
                        Chip(
                          label: Text(order['paymentStatus']),
                          backgroundColor: order['paymentStatus'] == 'pagado' 
                            ? Colors.green 
                            : Colors.red,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Text(
                  '\$${order['totalAmount'].toStringAsFixed(2)}',
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
