import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart'; 
import 'package:starter_architecture_flutter_firebase/src/screens/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart'; 
 
class CateringCartItemView extends ConsumerWidget {
  final CateringOrderItem order;
  final VoidCallback onRemoveFromCart;
  final FocusNode customPersonasFocusNode = FocusNode();
  final FocusNode customUnitsFocusNode = FocusNode(); // New focus node for units
  bool isCustomSelected = false;
  bool isCustomUnitsSelected = false; // New flag for units

  CateringCartItemView({
    super.key,
    required this.order,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPersonasSelected = order.peopleCount != null && order.peopleCount! > 0;

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order title and removal button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.title.isEmpty ? 'Catering' : order.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 24,
                    color: colorScheme.error,
                  ),
                  onPressed: onRemoveFromCart,
                  tooltip: 'Eliminar orden',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Order details in a styled container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    'Personas',
                    '${order.peopleCount ?? "No especificado"}',
                    Icons.people_outline,
                  ),
                  const SizedBox(height: 8),
                  
                  _buildInfoRow(
                    context,
                    'Chef en sitio',
                    (order.hasChef ?? false) ? 'Sí' : 'No',
                    Icons.restaurant,
                  ),
                  const SizedBox(height: 8),
                  
                  _buildInfoRow(
                    context,
                    'Alergias',
                    order.alergias.trim().isNotEmpty ? order.alergias : "Ninguna",
                    Icons.health_and_safety_outlined,
                  ),
                  const SizedBox(height: 8),
                  
                  _buildInfoRow(
                    context,
                    'Tipo de evento',
                    order.eventType.isEmpty ? 'Solicitud de Catering' : order.eventType,
                    Icons.event_outlined,
                  ),
                  
                  if (order.adicionales.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      'Adicionales',
                      order.adicionales,
                      Icons.note_outlined,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Order items section
            Text(
              'Platos seleccionados',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            
            // Dishes list with better styling
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.dishes.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant,
                ),
                itemBuilder: (context, index) {
                  final dish = order.dishes[index];
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dish.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${dish.peopleCount} Personas',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(dish.peopleCount * dish.pricePerPerson).toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            
            // Total price section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total estimado:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_calculateTotal(order).toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            
            // Button to complete the catering order
            if (!isPersonasSelected)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showCateringForm(context, ref),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Completar detalles del catering'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateTotal(CateringOrderItem order) {
    double total = 0;
    for (var dish in order.dishes) {
      total += dish.peopleCount * dish.pricePerPerson;
    }
    return total;
  }

  void _showCateringForm(BuildContext context, WidgetRef ref) {
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
              left: 20.0,
              right: 20.0,
              top: 20.0,
            ),
            child: CateringForm(
              initialData: order,
              onSubmit: (formData) {
                try {
                  ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                        title: order.title,
                        img: order.img,
                        description: order.description,
                        hasChef: formData.hasChef,
                        alergias: formData.allergies.join(','),
                        eventType: formData.eventType,
                        preferencia: order.preferencia,
                        adicionales: formData.additionalNotes,
                        cantidadPersonas: formData.peopleCount,
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Se actualizó el Catering'),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Error al actualizar el catering'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing catering form: $e');
    }
  }

  void _finalizeAndAddToCart(
    WidgetRef ref,
    bool hasChef,
    String alergias,
    String eventType,
    String preferencia,
    String adicionales,
    int cantidadPersonas,
  ) {
    try {
      final cateringOrderProviderNotifier =
          ref.read(cateringOrderProvider.notifier);
      cateringOrderProviderNotifier.finalizeCateringOrder(
        title: 'Orden de Catering',
        img: 'assets/image.png',
        description: 'Catering',
        hasChef: hasChef,
        alergias: alergias,
        eventType: eventType,
        preferencia: preferencia,
        adicionales: adicionales,
        cantidadPersonas: cantidadPersonas,
      );
    } catch (e) {
      debugPrint('Error finalizing catering order: $e');
    }
  }
}
