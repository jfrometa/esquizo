// lib/src/mesa_redonda/catering_entry/widgets/quote_order_form_view.dart
import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering_entry/components/catering_item_list.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
 import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

class QuoteOrderFormView extends StatelessWidget {
  final CateringOrderItem? quote;
  const QuoteOrderFormView({super.key, required this.quote});

  Widget _buildQuoteDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quote == null) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 48,
                  color: ColorsPaletteRedonda.deepBrown1,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay cotización iniciada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia una cotización manual para ver los detalles',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalles de la Cotización',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildQuoteDetailItem('Personas', '${quote!.peopleCount ?? 0}'),
                _buildQuoteDetailItem('Tipo de Evento', quote!.eventType),
                _buildQuoteDetailItem('Chef Incluido', quote!.hasChef ?? false ? 'Sí' : 'No'),
                if (quote!.alergias.isNotEmpty)
                  _buildQuoteDetailItem('Alergias', quote!.alergias),
                if (quote!.preferencia.isNotEmpty)
                  _buildQuoteDetailItem('Preferencia', quote!.preferencia),
                if (quote!.adicionales.isNotEmpty)
                  _buildQuoteDetailItem('Notas', quote!.adicionales),
              ],
            ),
          ),
        ),
        // const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: quote!.dishes.isEmpty
                ? const Center(child: Text('No hay items agregados'))
                : ItemsList(items: quote!.dishes, isQuote: true),
          ),
        ),
      ],
    );
  }
}