import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

/// A modular widget that provides catering service functionality
/// with custom quotes and package selection options.
class CateringServiceWidget extends ConsumerStatefulWidget {
  /// Optional custom title for the widget
  final String? title;

  /// Optional description text
  final String? description;

  /// Callback when a quote is submitted
  final Function(dynamic)? onQuoteSubmitted;

  /// Callback when a package is selected
  final Function(Map<String, dynamic>)? onPackageSelected;

  const CateringServiceWidget({
    super.key,
    this.title,
    this.description,
    this.onQuoteSubmitted,
    this.onPackageSelected,
  });

  @override
  ConsumerState<CateringServiceWidget> createState() =>
      _CateringServiceWidgetState();
}

class _CateringServiceWidgetState extends ConsumerState<CateringServiceWidget> {
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Catering packages data
  final List<Map<String, dynamic>> _cateringPackages = [
    {
      'title': 'Cocktail Party',
      'description': 'Perfect for small gatherings and celebrations',
      'price': 'S/ 500.00',
      'icon': Icons.wine_bar,
    },
    {
      'title': 'Corporate Lunch',
      'description': 'Ideal for business meetings and office events',
      'price': 'S/ 1000.00',
      'icon': Icons.business_center,
    },
    {
      'title': 'Wedding Reception',
      'description':
          'Make your special day unforgettable with our gourmet service',
      'price': 'S/ 1500.00',
      'icon': Icons.celebration,
    },
    {
      'title': 'Custom Package',
      'description':
          'Tell us your requirements for a personalized catering experience',
      'price': 'Starting at S/ 2000.00',
      'icon': Icons.settings,
    },
  ];

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _quantityController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showCateringForm(
      BuildContext context, WidgetRef ref, Map<String, dynamic> package) {
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
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: CateringForm(
                      title: 'Detalles del ${package['title']}',
                      initialData: ref.read(cateringOrderNotifierProvider),
                      onSubmit: (formData) {
                        final currentOrder =
                            ref.read(cateringOrderNotifierProvider);
                        ref
                            .read(cateringOrderNotifierProvider.notifier)
                            .finalizeCateringOrder(
                              title: package['title'],
                              img: '',
                              description: package['description'],
                              hasChef: formData.hasChef,
                              alergias: formData.allergies.join(','),
                              eventType: formData.eventType,
                              preferencia:
                                  currentOrder?.preferencia ?? 'salado',
                              adicionales: formData.additionalNotes,
                              cantidadPersonas: formData.peopleCount,
                            );

                        if (widget.onPackageSelected != null) {
                          widget.onPackageSelected!(package);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: colorScheme.onPrimaryContainer),
                                const SizedBox(width: 12),
                                Text('Paquete ${package['title']} añadido'),
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
                        Navigator.pop(context);
                        GoRouter.of(context).pushNamed(AppRoute.homecart.name,
                            extra: 'catering');
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

  void _showQuoteForm(BuildContext context, WidgetRef ref) {
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
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: CateringForm(
                      title: 'Detalles de la Cotización',
                      initialData: ref.read(manualQuoteProvider),
                      onSubmit: (formData) {
                        final currentQuote = ref.read(manualQuoteProvider);
                        ref
                            .read(manualQuoteProvider.notifier)
                            .finalizeManualQuote(
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

                        if (widget.onQuoteSubmitted != null) {
                          widget
                              .onQuoteSubmitted!(ref.read(manualQuoteProvider));
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: colorScheme.onPrimaryContainer),
                                const SizedBox(width: 12),
                                const Text('Se actualizó la Cotización'),
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
                        Navigator.pop(context);
                        setState(() {});
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

  void _showAddItemDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Item',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _itemDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Cantidad (Opcional)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
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
              _addItem();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar Item'),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    if (_itemNameController.text.trim().isEmpty) return;

    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final quoteOrder = ref.read(manualQuoteProvider);

    if (quoteOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Primero debes completar los detalles de la cotización'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(manualQuoteProvider.notifier).addManualItem(
          CateringDish(
            title: _itemNameController.text.trim(),
            quantity: quantity,
            hasUnitSelection: false,
            peopleCount: quoteOrder.peopleCount ?? 0,
            pricePerUnit: 0,
            pricePerPerson: 0,
            ingredients: [],
            pricing: 0,
          ),
        );

    // Clear the controllers
    _itemNameController.clear();
    _itemDescriptionController.clear();
    _quantityController.clear();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item agregado correctamente'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _confirmQuoteOrder() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quote = ref.read(manualQuoteProvider);

    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error: No hay datos de la cotización'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if ((quote.peopleCount ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La cantidad de personas es requerida'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (quote.eventType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El tipo de evento es requerido'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (quote.dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debe agregar al menos un item'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (widget.onQuoteSubmitted != null) {
      widget.onQuoteSubmitted!(quote);
    }

    GoRouter.of(context).goNamed(AppRoute.homecart.name, extra: 'quote');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    // Get the appropriate quote object based on the tab
    final manualQuote = ref.watch(manualQuoteProvider);

    final hasActiveQuote = manualQuote != null &&
        ((manualQuote.dishes.isNotEmpty) ||
            ((manualQuote.peopleCount ?? 0) > 0 &&
                manualQuote.eventType.isNotEmpty));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom quote section (top)
              _buildQuoteSection(
                  colorScheme, theme, hasActiveQuote, manualQuote),

              const SizedBox(height: 24),

              // Divider with "OR" in the middle
              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                ],
              ),

              const SizedBox(height: 24),

              // Catering packages section (bottom)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.title ?? 'Catering Packages',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.description ??
                      'Choose from our pre-designed packages for your event',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Catering packages grid or list
              isTablet
                  ? _buildTabletPackagesGrid(theme, colorScheme)
                  : _buildMobilePackagesList(theme, colorScheme),

              // Bottom padding
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuoteSection(ColorScheme colorScheme, ThemeData theme,
      bool hasQuoteItems, dynamic quote) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Add quote button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom Quote',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasQuoteItems)
                FilledButton.icon(
                  onPressed: _confirmQuoteOrder,
                  icon: const Icon(Icons.check),
                  label: const Text('Finalizar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Quote content or empty state
          if (quote == null)
            // Empty state
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create a custom catering order for your specific needs',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Quote request box
                GestureDetector(
                  onTap: () => _showQuoteForm(context, ref),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_note,
                            size: 28,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start a Quote Request',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tell us about your event details',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            // Quote content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote summary card
                Card(
                  elevation: 0,
                  color: colorScheme.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quote header with edit button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Quote Details',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => _showQuoteForm(context, ref),
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit quote details',
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // Quote info - Handle both types of objects safely
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Check for different quote object structures and use properties safely
                            _buildInfoRow(
                              theme,
                              'Event Type:',
                              _getEventType(quote),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              theme,
                              'People Count:',
                              _getPeopleCount(quote),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              theme,
                              'Chef Required:',
                              _getHasChef(quote) ? 'Yes' : 'No',
                            ),

                            // Only show allergies if they exist
                            if (_getAllergies(quote).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                theme,
                                'Allergies:',
                                _getAllergies(quote),
                              ),
                            ],

                            // Only show notes if they exist
                            if (_getAdditionalNotes(quote).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                theme,
                                'Notes:',
                                _getAdditionalNotes(quote),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Items list if any
                      if (_getDishes(quote).isNotEmpty) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Items (${_getDishes(quote).length})',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _showAddItemDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Item'),
                                    style: TextButton.styleFrom(
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...quote.dishes
                                  .asMap()
                                  .entries
                                  .map((entry) => _buildDishItem(
                                        entry.value,
                                        theme,
                                        entry.key,
                                        colorScheme,
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ] else ...[
                        // No items yet
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 32,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No items added yet',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: _showAddItemDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Item'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        colorScheme.secondaryContainer,
                                    foregroundColor:
                                        colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Safe property getter methods that handle both types of objects
  String _getEventType(dynamic quote) {
    try {
      if (quote is CateringOrderItem) {
        // For CateringOrderItem objects
        return quote.eventType.isEmpty ? 'Not specified' : quote.eventType;
      } else {
        // For ManualQuoteItem or other objects
        final eventType = quote.eventType;
        return eventType?.isEmpty ?? true ? 'Not specified' : eventType;
      }
    } catch (e) {
      return 'Not specified';
    }
  }

  String _getPeopleCount(dynamic quote) {
    try {
      if (quote is CateringOrderItem) {
        // For CateringOrderItem objects
        return (quote.peopleCount ?? 0) == 0
            ? 'Not specified'
            : '${quote.peopleCount}';
      } else {
        // For ManualQuoteItem or other objects
        final peopleCount = quote.peopleCount ?? 0;
        return peopleCount <= 0 ? 'Not specified' : '$peopleCount';
      }
    } catch (e) {
      return 'Not specified';
    }
  }

  bool _getHasChef(dynamic quote) {
    try {
      if (quote is CateringOrderItem) {
        // For CateringOrderItem objects
        return quote.hasChef ?? false;
      } else {
        // For ManualQuoteItem or other objects
        return quote.hasChef ?? false;
      }
    } catch (e) {
      return false;
    }
  }

  String _getAllergies(dynamic quote) {
    try {
      if (quote is CateringOrderItem) {
        // For CateringOrderItem objects
        return quote.alergias;
      } else {
        // For ManualQuoteItem or other objects with allergies property
        try {
          return quote.allergies ?? '';
        } catch (e) {
          try {
            return quote.alergias ?? '';
          } catch (e) {
            return '';
          }
        }
      }
    } catch (e) {
      return '';
    }
  }

  String _getAdditionalNotes(dynamic quote) {
    try {
      if (quote is CateringOrderItem) {
        // For CateringOrderItem objects
        return quote.adicionales;
      } else {
        // For ManualQuoteItem or other objects
        try {
          return quote.adicionales ?? '';
        } catch (e) {
          try {
            return quote.additionalNotes ?? '';
          } catch (e) {
            return '';
          }
        }
      }
    } catch (e) {
      return '';
    }
  }

  List<CateringDish> _getDishes(dynamic quote) {
    try {
      if (quote is CateringOrderItem) {
        // For CateringOrderItem objects
        return []; // CateringOrderItem might not have dishes
      } else {
        // For ManualQuoteItem or other objects
        return quote.dishes ?? [];
      }
    } catch (e) {
      return [];
    }
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildDishItem(
      CateringDish dish, ThemeData theme, int index, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
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
            IconButton(
              onPressed: () {
                ref.read(manualQuoteProvider.notifier).removeFromCart(index);
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Remove item',
              style: IconButton.styleFrom(
                backgroundColor:
                    colorScheme.errorContainer.withValues(alpha: 0.1),
                foregroundColor: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletPackagesGrid(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: _cateringPackages.length,
        itemBuilder: (context, index) {
          final package = _cateringPackages[index];

          return Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => _showCateringForm(context, ref, package),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primaryContainer.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        package['icon'],
                        size: 36,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      package['title'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      package['description'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      package['price'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () => _showCateringForm(context, ref, package),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Select Package'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobilePackagesList(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _cateringPackages.length,
      itemBuilder: (context, index) {
        final package = _cateringPackages[index];

        return Card(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => _showCateringForm(context, ref, package),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      package['icon'],
                      size: 28,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package['title'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package['description'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          package['price'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () => _showCateringForm(context, ref, package),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Select'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
