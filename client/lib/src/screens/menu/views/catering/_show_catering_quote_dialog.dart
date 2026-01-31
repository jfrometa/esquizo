import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/manual_quote_provider.dart';

/// Model class for a new quote item
class QuoteItem {
  final String title;
  final String description;
  final int quantity;

  QuoteItem({
    required this.title,
    this.description = '',
    this.quantity = 1,
  });
}

/// Shows a dialog to add a new item to a quote
void showAddQuoteItemDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Function(QuoteItem) onItemAdded,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  final itemNameController = TextEditingController();
  final itemDescriptionController = TextEditingController();
  final quantityController = TextEditingController(text: '1');

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Agregar Nuevo Item'),
      icon: const Icon(Icons.add_circle_outline),
      iconColor: colorScheme.primary,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: itemNameController,
              decoration: InputDecoration(
                labelText: 'Nombre del Item',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: itemDescriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción (Opcional)',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () {
            // Validate input
            if (itemNameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El nombre del item es requerido'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            final quoteOrder = ref.read(manualQuoteProvider);
            if (quoteOrder == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Primero debes completar los detalles de la cotización'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            // Create and return the new item
            final item = QuoteItem(
              title: itemNameController.text.trim(),
              description: itemDescriptionController.text.trim(),
              quantity: int.tryParse(quantityController.text) ?? 1,
            );

            onItemAdded(item);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Item agregado correctamente'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: theme.colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
              ),
            );

            Navigator.pop(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Agregar Item'),
        ),
      ],
    ),
  ).then((_) {
    // Clean up controllers when dialog is dismissed
    itemNameController.dispose();
    itemDescriptionController.dispose();
    quantityController.dispose();
  });
}
