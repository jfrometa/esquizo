import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/manual_quote_provider.dart';

/// A card representing a single dish item in a catering quote
class QuoteItemCard extends ConsumerWidget {
  /// The dish to display
  final CateringDish dish;
  
  /// Index of the dish in the list
  final int index;
  
  /// Callback to edit this item
  final Function(CateringDish, int)? onEdit;
  
  /// Callback to remove this item
  final Function(int)? onRemove;

  const QuoteItemCard({
    super.key,
    required this.dish,
    required this.index,
    this.onEdit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onEdit != null ? () => onEdit!(dish, index) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Quantity circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${dish.quantity}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((dish.pricePerUnit ?? 0) > 0 || dish.pricePerPerson > 0)
                      Text(
                        'Price: ${dish.pricing > 0 ? '\$${dish.pricing.toStringAsFixed(2)}' : 'TBD'}',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              
              // Delete button
              if (onRemove != null)
                IconButton(
                  onPressed: () => onRemove!(index),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: 'Remove item',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer.withOpacity(0.1),
                    foregroundColor: colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Dialog to edit a dish's quantity
  static void showEditDialog(
    BuildContext context, 
    WidgetRef ref,
    CateringDish dish, 
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    String updatedValue = dish.hasUnitSelection 
        ? dish.pricePerUnit.toString()
        : dish.quantity.toString();
        
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar', style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: updatedValue,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: dish.hasUnitSelection ? 'Unidades' : 'Cantidad',
                labelStyle: TextStyle(color: colorScheme.onSurface),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
              onChanged: (value) => updatedValue = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: colorScheme.primary)),
          ),
          FilledButton(
            onPressed: () {
              // Update the dish quantity
              final parsedValue = int.tryParse(updatedValue) ?? 1;
              final updatedDish = dish.copyWith(quantity: parsedValue);
              
              // Update the dish in the provider
              ref.read(manualQuoteProvider.notifier).addManualItem( updatedDish);
              
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}