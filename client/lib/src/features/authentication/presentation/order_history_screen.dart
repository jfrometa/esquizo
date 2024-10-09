import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/order_history_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class OrderHistoryList extends ConsumerWidget {
  const OrderHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Text('No tienes historial de órdenes.');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders.reversed.toList()[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: Sizes.p8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orden #${order.orderNumber}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ColorsPaletteRedonda.primary,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Monto total: \$${order.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              '${order.address}, Lat: ${order.latitude}, Long: ${order.longitude}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Tipo: ${order.orderType}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.payment, color: Colors.grey),
                          const SizedBox(width: 8.0),
                          Text(
                            'Metodo de pago: ${order.paymentMethod}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Estatus de PAgo: ${order.paymentStatus}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: order.paymentStatus == 'pagado'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey),
                          const SizedBox(width: 8.0),
                          Text(
                            'Fecha de la orden: ${DateFormat.yMMMd().add_jm().format(order.timestamp.toDate())}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Text('Failed to load order history.'),
    );
  }
}
