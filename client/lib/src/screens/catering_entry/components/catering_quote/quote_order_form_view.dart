// UPDATED QuoteOrderFormView.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/catering/manual_quote_provider.dart';

class QuoteOrderFormView extends ConsumerWidget {
  final CateringOrderItem quote;
  final VoidCallback? onEdit;
  final VoidCallback? onConfirm;
  
  const QuoteOrderFormView({
    super.key, 
    required this.quote,
    this.onEdit,
    this.onConfirm,
  });

  Widget _buildQuoteDetailItem(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.sizeOf(context).width > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quote details card
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de la Cotización',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuoteDetailItem('Personas', '${quote.peopleCount ?? 0}', theme),
                    _buildQuoteDetailItem('Tipo de Evento', quote.eventType, theme),
                    _buildQuoteDetailItem(
                      'Chef Incluido',
                      quote.hasChef ?? false ? 'Sí' : 'No', 
                      theme
                    ),
                    if (quote.alergias.isNotEmpty)
                      _buildQuoteDetailItem('Alergias', quote.alergias, theme),
                    if (quote.preferencia.isNotEmpty)
                      _buildQuoteDetailItem('Preferencia', quote.preferencia, theme),
                    if (quote.adicionales.isNotEmpty)
                      _buildQuoteDetailItem('Notas', quote.adicionales, theme),
                  ],
                ),
              ),
              if (onEdit != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: colorScheme.primary,
                    ),
                    onPressed: onEdit,
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Quote items summary
        if (quote.dishes.isNotEmpty)
          Card(
            elevation: 0,
            color: colorScheme.tertiaryContainer.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detalle de Productos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${quote.dishes.length} ítems',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Divider(),
                  
                  // Item list
                  ...quote.dishes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.tertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.description,
                                color: colorScheme.tertiary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Cantidad: ${item.quantity ?? 1}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                            ),
                            onPressed: () {
                              ref.read(manualQuoteProvider.notifier).removeFromCart(index);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Desktop complete quote button
        if (isDesktop && quote.dishes.isNotEmpty && onConfirm != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check),
              label: const Text('Finalizar Cotización'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
      ],
    );
  }
}

