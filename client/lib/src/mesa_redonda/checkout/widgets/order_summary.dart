import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class OrderSummary extends ConsumerWidget {
  final double totalPrice;
  final double deliveryFee;
  final double taxRate;
  final String orderType;
  final Map<String, dynamic>? additionalInfo;

  const OrderSummary({
    super.key,
    required this.totalPrice,
    required this.deliveryFee,
    required this.taxRate,
    required this.orderType,
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double tax = totalPrice * taxRate;
    final double orderTotal = totalPrice + (orderType == 'quote' ? 0 : deliveryFee) + tax;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getOrderTypeIcon(),
                  color: ColorsPaletteRedonda.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getTitle(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ColorsPaletteRedonda.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            
            if (orderType == 'catering' || orderType == 'quote')
              ..._buildCateringDetails(ref),
            
            _buildOrderSummaryRow(
              context,
              _getItemsLabel(),
              'RD \$${totalPrice.toStringAsFixed(2)}',
            ),
            
            if (orderType != 'quote')
              _buildOrderSummaryRow(
                context,
                'Envío',
                'RD \$$deliveryFee',
                icon: Icons.local_shipping_outlined,
              ),
              
            _buildOrderSummaryRow(
              context,
              'Impuestos',
              'RD \$${tax.toStringAsFixed(2)}',
              icon: Icons.receipt_outlined,
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
            
            _buildOrderSummaryRow(
              context,
              _getTotalLabel(),
              'RD \$${orderTotal.toStringAsFixed(2)}',
              isBold: true,
              fontSize: 16,
            ),
            
            if (orderType != 'quote')
              _buildTimeEstimate(context),
          ],
        ),
      ),
    );
  }

  IconData _getOrderTypeIcon() {
    switch (orderType) {
      case 'quote':
        return Icons.request_quote_outlined;
      case 'catering':
        return Icons.dinner_dining;
      case 'subscriptions':
        return Icons.calendar_today_outlined;
      default:
        return Icons.restaurant_menu;
    }
  }

  String _getTitle() {
    switch (orderType) {
      case 'quote':
        return 'Resumen de la Cotización';
      case 'catering':
        return 'Resumen del Catering';
      case 'subscriptions':
        return 'Resumen de la Suscripción';
      default:
        return 'Resumen de la Orden';
    }
  }

  String _getItemsLabel() {
    switch (orderType) {
      case 'quote':
        return 'Cotización Base';
      case 'catering':
        return 'Platos';
      case 'subscriptions':
        return 'Plan';
      default:
        return 'Platos';
    }
  }

  String _getTotalLabel() {
    switch (orderType) {
      case 'quote':
        return 'Total Estimado';
      default:
        return 'Total de la Orden';
    }
  }

  List<Widget> _buildCateringDetails(WidgetRef ref) {
    if (additionalInfo == null) return [];

    return [
      if (additionalInfo!['peopleCount'] != null)
        _buildOrderSummaryRow(
          ref.context,
          'Cantidad de Personas',
          additionalInfo!['peopleCount'].toString(),
          icon: Icons.people_outline,
        ),
      if (additionalInfo!['hasChef'] != null)
        _buildOrderSummaryRow(
          ref.context,
          'Chef Incluido',
          additionalInfo!['hasChef'] ? 'Sí' : 'No',
          icon: Icons.restaurant,
        ),
      if (additionalInfo!['eventType']?.isNotEmpty ?? false)
        _buildOrderSummaryRow(
          ref.context,
          'Tipo de Evento',
          additionalInfo!['eventType'],
          icon: Icons.event,
        ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Divider(height: 1),
      ),
    ];
  }

  Widget _buildOrderSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    IconData? icon,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? ColorsPaletteRedonda.deepBrown1 : Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? ColorsPaletteRedonda.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeEstimate(BuildContext context) {
    String estimatedTime;
    IconData icon;
    
    switch (orderType) {
      case 'catering':
        estimatedTime = 'Confirmación dentro de 4 horas';
        icon = Icons.schedule;
        break;
      case 'subscriptions':
        estimatedTime = 'Entrega según calendario seleccionado';
        icon = Icons.calendar_today;
        break;
      default:
        estimatedTime = 'Entrega estimada: 30-45 min';
        icon = Icons.access_time;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsPaletteRedonda.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorsPaletteRedonda.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: ColorsPaletteRedonda.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              estimatedTime,
              style: TextStyle(
                fontSize: 13,
                color: ColorsPaletteRedonda.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}