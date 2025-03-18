import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/components/catering_order/catering_order_form_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/components/catering_quote/quote_order_form_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/prompt_dialogs/new_item_dialog.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_quote/manual_quote_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

/// The complete entry screen with two tabs: one for Catering and one for Cotización.
class CateringEntryScreen extends ConsumerStatefulWidget {
  const CateringEntryScreen({super.key});

  @override
  CateringEntryScreenState createState() => CateringEntryScreenState();
}

class CateringEntryScreenState extends ConsumerState<CateringEntryScreen>
    with SingleTickerProviderStateMixin {
  // Controllers for the catering form.
  late TextEditingController eventTypeController;
  late TextEditingController customPersonasController;
  late TextEditingController adicionalesController;
  final customPersonasFocusNode = FocusNode();

  // Temporary local state values for catering form.
  bool isCustomSelected = false;
  bool tempHasChef = false;
  String tempPreferencia = 'salado';
  List<String> tempAlergiasList = [];

  // Static list for people quantity drop-down.
  final _peopleQuantity = [
    10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 1000, 2000, 5000, 10000
  ];
  
  // Tab controller
  late TabController _tabController;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _initializeCateringValues();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    customPersonasFocusNode.dispose();
    eventTypeController.dispose();
    customPersonasController.dispose();
    adicionalesController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Only rebuild if needed
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  /// Initializes the catering form from the global catering order.
  void _initializeCateringValues() {
    final cateringOrder = ref.read(cateringOrderProvider);
    tempHasChef = cateringOrder?.hasChef ?? false;
    tempPreferencia = (cateringOrder?.preferencia.isNotEmpty ?? false)
        ? cateringOrder!.preferencia
        : 'salado';
    tempAlergiasList = cateringOrder?.alergias.split(',')
        .where((item) => item.isNotEmpty)
        .toList() ?? [];
        
    final peopleCount =
        (cateringOrder?.peopleCount != null && cateringOrder!.peopleCount! > 0)
            ? cateringOrder.peopleCount
            : null;
    if (peopleCount != null && !_peopleQuantity.contains(peopleCount)) {
      isCustomSelected = true;
    }
    eventTypeController =
        TextEditingController(text: cateringOrder?.eventType ?? '');
    customPersonasController =
        TextEditingController(text: peopleCount?.toString() ?? '');
    adicionalesController =
        TextEditingController(text: cateringOrder?.adicionales ?? '');
  }

  /// -----------------------------
  /// Form Handling Methods
  /// -----------------------------

  void _showCateringForm(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final order = ref.read(cateringOrderProvider);
    
    // Create a new order if none exists
    // if (order == null) {
    //   ref.read(cateringOrderProvider.notifier).();
    // }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            title: 'Detalles de la Orden',
            initialData: ref.read(cateringOrderProvider),
            onSubmit: (formData) {
              final currentOrder = ref.read(cateringOrderProvider);
              ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                    title: currentOrder?.title ?? '',
                    img: currentOrder?.img ?? '',
                    description: currentOrder?.title ?? '',
                    hasChef: formData.hasChef,
                    alergias: formData.allergies.join(','),
                    eventType: formData.eventType,
                    preferencia: currentOrder?.preferencia ?? '',
                    adicionales: formData.additionalNotes,
                    cantidadPersonas: formData.peopleCount,
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Se actualizó el Catering'),
                  backgroundColor: colorScheme.primaryContainer,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
              setState(() {}); // Trigger UI refresh
            },
          ),
        );
      },
    );
  }

  /// Opens the bottom sheet to add/update a product for the Quote order.
  void _showQuoteForm(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quote = ref.read(manualQuoteProvider);
    
    // Create a new quote if none exists
    if (quote == null) {
      ref.read(manualQuoteProvider.notifier);
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: CateringForm(
            title: 'Detalles de la Cotización',
            initialData: ref.read(manualQuoteProvider),
            onSubmit: (formData) {
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
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Se actualizó la Cotización'),
                  backgroundColor: colorScheme.primaryContainer,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
              setState(() {}); // Trigger UI refresh
            },
          ),
        );
      },
    );
  }

  // Add method to handle FAB press based on current tab
  void _handleFabPressed() {
    if (_tabController.index == 0) {
      // Catering tab
      final order = ref.read(cateringOrderProvider);
      if (order == null || (order.peopleCount ?? 0) <= 0) {
        _showCateringForm(context, ref);
      } else {
        GoRouter.of(context).pushNamed(
          AppRoute.cateringMenu.name,
          extra: order,
        );
      }
    } else {
      // Cotización tab
      final order = ref.read(manualQuoteProvider);
      if (order == null || (order.peopleCount ?? 0) <= 0) {
        _showQuoteForm(context, ref);
      } else {
        _showNewItemDialog();
      }
    }
  }

  /// -----------------------------
  /// Confirmation Button Handlers
  /// -----------------------------
  void _confirmCateringOrder() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final order = ref.read(cateringOrderProvider);
    
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error: No hay datos de la orden'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if ((order.peopleCount ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La cantidad de personas es requerida'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (order.eventType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El tipo de evento es requerido'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    if (order.dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debe agregar al menos un item'),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    GoRouter.of(context).goNamed(AppRoute.homecart.name, extra: 'catering');
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
    
    GoRouter.of(context).goNamed(AppRoute.homecart.name, extra: 'quote');
  }

  /// -----------------------------
  /// UI Builders for Each Tab
  /// -----------------------------

  /// Builds the complete catering order form view. 
Widget _buildCateringOrderForm() {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final cateringOrder = ref.watch(cateringOrderProvider);
  
  if (cateringOrder == null) {
    return _buildEmptyState(
      icon: Icons.restaurant_menu,
      title: 'No hay orden iniciada',
      message: 'Inicia una orden agregando los detalles del evento',
      onInitialize: () => _handleFabPressed(),
    );
  }

  return NotificationListener<ScrollNotification>(
    onNotification: (notification) {
      if (notification is ScrollUpdateNotification) {
        if (notification.scrollDelta != null && notification.scrollDelta! > 0 && _showFab) {
          setState(() => _showFab = false);
        } else if (notification.scrollDelta != null && notification.scrollDelta! < 0 && !_showFab) {
          setState(() => _showFab = true);
        }
      }
      return false;
    },
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: CateringOrderForm(
          onEdit: () => _showCateringForm(context, ref),
          onConfirm: _confirmCateringOrder,
        ),
      ),
    ),
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

// In your screen/widget:
  void _showNewItemDialog() {
    NewItemDialog.show(
      context: context,
      onAddItem: _addItem,
    );
  }

// UPDATED _buildQuoteOrderForm method for CateringEntryScreen
/// Builds the quote order form view.
Widget _buildQuoteOrderForm() {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final quote = ref.watch(manualQuoteProvider);
  
  if (quote == null) {
    return _buildEmptyState(
      icon: Icons.request_quote,
      title: 'No hay cotización iniciada',
      message: 'Inicia una cotización agregando los detalles del evento',
      onInitialize: () => _handleFabPressed(),
    );
  }

  return NotificationListener<ScrollNotification>(
    onNotification: (notification) {
      if (notification is ScrollUpdateNotification) {
        if (notification.scrollDelta != null && notification.scrollDelta! > 0 && _showFab) {
          setState(() => _showFab = false);
        } else if (notification.scrollDelta != null && notification.scrollDelta! < 0 && !_showFab) {
          setState(() => _showFab = true);
        }
      }
      return false;
    },
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: QuoteOrderFormView(
          quote: quote,
          onEdit: () => _showQuoteForm(context, ref),
          onConfirm: _confirmQuoteOrder,
        ),
      ),
    ),
  );
}
  // Empty state builder with initialize button
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required VoidCallback onInitialize,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onInitialize,
              icon: const Icon(Icons.add),
              label: const Text('Iniciar Orden'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Adds a new dish to the catering order.
  void _addItem(String name, String description, int? quantity) {
    if (name.trim().isEmpty) return;
    final quoteOrder = ref.watch(manualQuoteProvider);

    ref.read(manualQuoteProvider.notifier).addManualItem(
          CateringDish(
            title: name.trim(),
            quantity: quantity ?? 1,
            hasUnitSelection: false,
            peopleCount: quantity ?? quoteOrder?.peopleCount ?? 0,
            pricePerUnit: 0,
            pricePerPerson: 0,
            ingredients: [],
            pricing: 0,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final cateringOrder = ref.watch(cateringOrderProvider);
    final quoteOrder = ref.watch(manualQuoteProvider);
    final currentOrder = _tabController.index == 0 ? cateringOrder : quoteOrder;
    final hasItems = currentOrder != null && 
                     ((currentOrder.dishes.isNotEmpty) || 
                     ((currentOrder.peopleCount ?? 0) > 0 && currentOrder.eventType.isNotEmpty));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        title: const Text('Catering'),
        actions: [
          if (hasItems)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FilledButton.icon(
                onPressed: () {
                  if (_tabController.index == 0) {
                    _confirmCateringOrder();
                  } else {
                    _confirmQuoteOrder();
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('Finalizar'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          dividerColor: colorScheme.outline.withOpacity(0.2),
          labelStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant_menu),
              text: 'Nuestro Menu',
            ),
            Tab(
              icon: Icon(Icons.request_quote),
              text: 'Cotización',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildCateringOrderForm(),
          _buildQuoteOrderForm(),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFab ? const Offset(0, 0) : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFab ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            heroTag: 'completar orden',
            onPressed: _handleFabPressed,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            icon: Icon(hasItems ? Icons.add_shopping_cart : Icons.start),
            label: Text(hasItems ? 'Agregar plato' : 'Iniciar Orden'),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}