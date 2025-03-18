// UPDATED CateringOrderForm.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';

class CateringOrderForm extends ConsumerWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onConfirm;
  
  const CateringOrderForm({
    super.key, 
    this.onEdit,
    this.onConfirm,
  });

  Widget _buildCateringOrderDetailItem(String label, String value, ThemeData theme) {
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
    final order = ref.watch(cateringOrderProvider);
    final isDesktop = MediaQuery.sizeOf(context).width > 600;

    if (order == null) {
      return const SizedBox(); // Empty state handled by parent
    }

    final items = order.dishes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order details card
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
                      'Detalles de la Orden',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCateringOrderDetailItem('Personas', '${order.peopleCount ?? 0}', theme),
                    _buildCateringOrderDetailItem('Tipo de Evento', order.eventType, theme),
                    _buildCateringOrderDetailItem(
                      'Chef Incluido',
                      order.hasChef ?? false ? 'Sí' : 'No', 
                      theme
                    ),
                    if (order.alergias.isNotEmpty)
                      _buildCateringOrderDetailItem('Alergias', order.alergias, theme),
                    if (order.preferencia.isNotEmpty)
                      _buildCateringOrderDetailItem('Preferencia', order.preferencia, theme),
                    if (order.adicionales.isNotEmpty)
                      _buildCateringOrderDetailItem('Notas', order.adicionales, theme),
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
        
        // Order items summary
        if (items.isNotEmpty)
          Card(
            elevation: 0,
            color: colorScheme.secondaryContainer.withOpacity(0.3),
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
                        'Resumen de la Orden',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${items.length} platos',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Divider(),
                  
                  // Item list with delete option
                  ...items.asMap().entries.map((entry) {
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
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.restaurant,
                                color: colorScheme.primary,
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
                                if (item.ingredients.isNotEmpty)
                                  Text(
                                    item.ingredients.join(', '),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, 
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '\$${item.pricing}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            onPressed: () {
                              ref.read(cateringOrderProvider.notifier).removeFromCart(index);
                            },
                            tooltip: 'Eliminar',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  const Divider(),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total estimado:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_calculateTotal(items)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Desktop complete order button
        if (isDesktop && items.isNotEmpty && onConfirm != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check),
              label: const Text('Completar Orden'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
      ],
    );
  }
  
  // Calculate total from items
  String _calculateTotal(List<CateringDish> items) {
    double total = 0;
    for (var item in items) {
      total += (item.pricing.toDouble() ?? 0);
    }
    return total.toStringAsFixed(2);
  }
}