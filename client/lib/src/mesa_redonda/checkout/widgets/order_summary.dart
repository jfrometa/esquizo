import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class OrderSummary extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final double tax = totalPrice * taxRate;
    final double orderTotal = totalPrice + (orderType == 'quote' ? 0 : deliveryFee) + tax;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 150),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTitle(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorsPaletteRedonda.primary,
                    ),
              ),
              const SizedBox(height: 16.0),
              if (orderType == 'catering' || orderType == 'quote')
                ..._buildCateringDetails(),
              _buildOrderSummaryRow(
                context,
                _getItemsLabel(),
                'RD \$${totalPrice.toStringAsFixed(2)}',
              ),
              if (orderType != 'quote')
                _buildOrderSummaryRow(
                  context,
                  'Envio',
                  'RD \$$deliveryFee',
                ),
              _buildOrderSummaryRow(
                context,
                'Impuestos',
                'RD \$${tax.toStringAsFixed(2)}',
              ),
              const Divider(),
              _buildOrderSummaryRow(
                context,
                _getTotalLabel(),
                'RD \$${orderTotal.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ),
      ),
    );
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
        return 'Items';
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

  List<Widget> _buildCateringDetails() {
    if (additionalInfo == null) return [];

    return [
      if (additionalInfo!['peopleCount'] != null)
        _buildOrderSummaryRow(
          null,
          'Cantidad de Personas',
          additionalInfo!['peopleCount'].toString(),
        ),
      if (additionalInfo!['hasChef'] != null)
        _buildOrderSummaryRow(
          null,
          'Chef Incluido',
          additionalInfo!['hasChef'] ? 'Sí' : 'No',
        ),
      if (additionalInfo!['eventType']?.isNotEmpty ?? false)
        _buildOrderSummaryRow(
          null,
          'Tipo de Evento',
          additionalInfo!['eventType'],
        ),
      const SizedBox(height: 8.0),
    ];
  }

  Widget _buildOrderSummaryRow(
    BuildContext? context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    final textStyle = context != null
        ? Theme.of(context).textTheme.bodyLarge
        : const TextStyle(fontSize: 16);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: textStyle?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black,
              ),
            ),
            Text(
              value,
              style: textStyle?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: ColorsPaletteRedonda.deepBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}