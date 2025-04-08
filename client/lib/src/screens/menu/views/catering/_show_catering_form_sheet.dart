import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/widgets/catering_form.dart';

/// Shows a modal bottom sheet with a catering form
void showCateringFormSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  Map<String, dynamic>? package,
  Function(Map<String, dynamic>)? onSuccess,
  bool isQuote = false,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: colorScheme.surface,
    enableDrag: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
              left: 24.0,
              right: 24.0,
              top: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: CateringForm(
                    title: title,
                    initialData: isQuote 
                        ? ref.read(manualQuoteProvider)
                        : ref.read(cateringOrderProvider),
                    onSubmit: (formData) {
                      if (isQuote) {
                        // Handle quote submission
                        final currentQuote = ref.read(manualQuoteProvider);
                        ref.read(manualQuoteProvider.notifier).finalizeManualQuote(
                              title: currentQuote?.title ?? 'Cotización',
                              img: currentQuote?.img ?? '',
                              description: currentQuote?.description ?? '',
                              hasChef: formData.hasChef,
                              alergias: formData.allergies.join(','),
                              eventType: formData.eventType,
                              preferencia: currentQuote?.preferencia ?? '',
                              adicionales: formData.additionalNotes,
                              cantidadPersonas: formData.peopleCount,
                            );
                        
                        _showSuccessSnackBar(
                          context: context, 
                          message: 'Se actualizó la Cotización',
                          colorScheme: colorScheme,
                        );
                      } else {
                        // Handle package submission
                        final currentOrder = ref.read(cateringOrderProvider);
                        ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                              title: package?['title'] ?? '',
                              img: '',
                              description: package?['description'] ?? '',
                              hasChef: formData.hasChef,
                              alergias: formData.allergies.join(','),
                              eventType: formData.eventType,
                              preferencia: currentOrder?.preferencia ?? 'salado',
                              adicionales: formData.additionalNotes,
                              cantidadPersonas: formData.peopleCount,
                            );
                        
                        if (onSuccess != null && package != null) {
                          onSuccess(package);
                        }
                        
                        _showSuccessSnackBar(
                          context: context, 
                          message: 'Paquete ${package?['title'] ?? 'de catering'} añadido',
                          colorScheme: colorScheme,
                        );
                        
                        GoRouter.of(context).pushNamed(AppRoute.homecart.name, extra: 'catering');
                      }
                      
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showSuccessSnackBar({
  required BuildContext context,
  required String message,
  required ColorScheme colorScheme,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Text(message),
        ],
      ),
      backgroundColor: colorScheme.primaryContainer,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}