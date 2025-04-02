import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/subscription_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart'
    as auth_models;

import 'pagination/paginated_list_widget.dart';

class OrderHistoryList extends ConsumerWidget {
  const OrderHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(child: LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Container(
            //   width: double.infinity,
            //   color: ColorsPaletteRedonda.primary.withOpacity(0.1),
            //   padding: const EdgeInsets.all(16.0),
            //   child: Text(
            //     'Tus órdenes previas',
            //     style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //           fontWeight: FontWeight.bold,
            //           color: ColorsPaletteRedonda.primary,
            //         ),
            //   ),
            // ),

            Expanded(
              child: PaginatedListView<auth_models.Order>(
                provider: ordersPaginationProvider(user.uid),
                emptyWidget: const Center(
                  child: Text('No tienes historial de órdenes.'),
                ),
                itemBuilder: (context, order) {
                  return OrderHistoryCard(order: order);
                },
              ),
            ),
          ],
        );
      },
    ));
  }
}

class OrderHistoryCard extends StatelessWidget {
  final auth_models.Order order;

  const OrderHistoryCard({
    required this.order,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.p16,
        vertical: Sizes.p8,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOrderHeader(context),
            const SizedBox(height: 8.0),
            _buildOrderDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    return Text(
      'Orden #${order.orderNumber}',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        OrderDetailRow(
          icon: Icons.attach_money,
          label: 'Monto total',
          value: '\$${order.totalAmount.toStringAsFixed(2)}',
        ),
        const SizedBox(height: 8.0),
        OrderDetailRow(
          icon: Icons.location_on,
          label: 'Ubicación',
          value: order.address.isNotEmpty
              ? '${order.address}, Lat: ${order.latitude}, Long: ${order.longitude}'
              : 'N/A',
        ),
        const SizedBox(height: 8.0),
        OrderDetailRow(
          label: 'Tipo',
          value: order.orderType,
        ),
        const SizedBox(height: 8.0),
        OrderDetailRow(
          icon: Icons.payment,
          label: 'Método de pago',
          value: order.paymentMethod,
        ),
        const SizedBox(height: 8.0),
        OrderDetailRow(
          label: 'Estatus de Pago',
          value: order.paymentStatus,
          valueColor: order.paymentStatus.toLowerCase() == 'pagado'
              ? Colors.green
              : Colors.red,
        ),
        const SizedBox(height: 8.0),
        OrderDetailRow(
          icon: Icons.access_time,
          label: 'Fecha de la orden',
          value: order.formattedTimestamp,
        ),
      ],
    );
  }
}

class OrderDetailRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final Color? valueColor;

  const OrderDetailRow({
    this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8.0),
        ],
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: valueColor,
                      ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

extension OrderTimestampX on auth_models.Order {
  String get formattedTimestamp {
    try {
      return DateFormat.yMMMd().add_jm().format(timestamp.toDate());
    } catch (e) {
      debugPrint('Error formatting timestamp: $e');
      return 'Fecha no disponible';
    }
  }
}
