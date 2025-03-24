import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final double tax = totalPrice * taxRate;
    final double orderTotal = totalPrice + (orderType == 'quote' ? 0 : deliveryFee) + tax;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getOrderTypeIcon(),
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant),
            
            if (orderType == 'catering' || orderType == 'quote')
              ..._buildCateringDetails(context, ref),
            
            _buildOrderSummaryRow(
              context,
              _getItemsLabel(),
              'RD \$${totalPrice.toStringAsFixed(2)}',
            ),
            
            if (orderType != 'quote')
              _buildOrderSummaryRow(
                context,
                'Envío',
                'RD \$${deliveryFee.toStringAsFixed(2)}',
                icon: Icons.local_shipping_outlined,
              ),
              
            _buildOrderSummaryRow(
              context,
              'Impuestos',
              'RD \$${tax.toStringAsFixed(2)}',
              icon: Icons.receipt_outlined,
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: colorScheme.outlineVariant),
            ),
            
            _buildOrderSummaryRow(
              context,
              _getTotalLabel(),
              'RD \$${orderTotal.toStringAsFixed(2)}',
              isBold: true,
              fontSize: 18,
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

  List<Widget> _buildCateringDetails(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (additionalInfo == null) return [];

    return [
      if (additionalInfo!['peopleCount'] != null)
        _buildOrderSummaryRow(
          context,
          'Cantidad de Personas',
          additionalInfo!['peopleCount'].toString(),
          icon: Icons.people_outline,
        ),
      if (additionalInfo!['hasChef'] != null)
        _buildOrderSummaryRow(
          context,
          'Chef Incluido',
          additionalInfo!['hasChef'] ? 'Sí' : 'No',
          icon: Icons.restaurant,
        ),
      if (additionalInfo!['eventType']?.isNotEmpty ?? false)
        _buildOrderSummaryRow(
          context,
          'Tipo de Evento',
          additionalInfo!['eventType'],
          icon: Icons.event,
        ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Divider(color: colorScheme.outlineVariant),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: (isBold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)?.copyWith(
                fontSize: fontSize,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: (isBold ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)?.copyWith(
              fontSize: fontSize,
              color: isBold ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeEstimate(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              estimatedTime,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}