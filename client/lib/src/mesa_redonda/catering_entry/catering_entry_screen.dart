import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering_entry/components/catering_order/catering_order_form_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering_entry/components/catering_quote/quote_order_form_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/prompt_dialogs/new_item_dialog.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering_quote/manual_quote_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

/// The complete entry screen with two tabs: one for Catering and one for Cotización.
class CateringEntryScreen extends ConsumerStatefulWidget {
  const CateringEntryScreen({Key? key}) : super(key: key);

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
    10,
    20,
    30,
    40,
    50,
    100,
    200,
    300,
    400,
    500,
    1000,
    2000,
    5000,
    10000
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeCateringValues();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Force rebuild when tab changes
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {
      setState(() {});
    });
    _tabController.dispose();
    customPersonasFocusNode.dispose();
    eventTypeController.dispose();
    customPersonasController.dispose();
    adicionalesController.dispose();
    super.dispose();
  }

  /// Initializes the catering form from the global catering order.
  void _initializeCateringValues() {
    final cateringOrder = ref.read(cateringOrderProvider);
    tempHasChef = cateringOrder?.hasChef ?? false;
    tempPreferencia = (cateringOrder?.preferencia.isNotEmpty ?? false)
        ? cateringOrder!.preferencia
        : 'salado';
    tempAlergiasList = cateringOrder?.alergias.split(',') ?? [];
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
  /// Bottom Sheet Forms for Adding Products
  /// -----------------------------

  void _showCateringForm(BuildContext context, WidgetRef ref) {
    final order = ref.read(cateringOrderProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.0,
            right: 20.0,
            top: 20.0,
          ),
          child: CateringForm(
            title: 'Detalles de la Orden',
            initialData: order,
            onSubmit: (formData) {
              ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                    title: order?.title ?? '',
                    img: order?.img ?? '',
                    description: order?.title ?? '',
                    hasChef: formData.hasChef,
                    alergias: formData.allergies.join(','),
                    eventType: formData.eventType,
                    preferencia: order?.preferencia ?? '',
                    adicionales: formData.additionalNotes,
                    cantidadPersonas: formData.peopleCount,
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se actualizó el Catering'),
                  backgroundColor: Colors.brown,
                  duration: Duration(milliseconds: 500),
                ),
              );
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  /// Opens the bottom sheet to add/update a product for the Quote order.
  void _showQuoteForm(BuildContext context, WidgetRef ref) {
    final quote = ref.read(manualQuoteProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: CateringForm(
            title: 'Detalles de la Cotizacion',
            initialData: quote,
            onSubmit: (formData) {
              ref.read(manualQuoteProvider.notifier).finalizeManualQuote(
                    title: quote?.title ?? 'Cotización',
                    img: quote?.img ?? '',
                    description: quote?.description ?? '',
                    hasChef: formData.hasChef,
                    alergias: formData.allergies.join(','),
                    eventType: formData.eventType,
                    preferencia: quote?.preferencia ?? '',
                    adicionales: formData.additionalNotes,
                    cantidadPersonas: formData.peopleCount,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se actualizó la Cotización'),
                  backgroundColor: Colors.brown,
                  duration: Duration(milliseconds: 500),
                ),
              );
              GoRouter.of(context).pop(context);
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
    final order = ref.read(cateringOrderProvider);
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No hay datos de la orden')));
      return;
    }
    if ((order.peopleCount ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('La cantidad de personas es requerida')));
      return;
    }
    if (order.eventType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El tipo de evento es requerido')));
      return;
    }
    if (order.dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe agregar al menos un item')));
      return;
    }
    // For catering, navigate to the catering selection screen.
    // Navigator.of(context).pop();

    GoRouter.of(context).goNamed(AppRoute.homecart.name, extra: 'catering');
  }

  void _confirmQuoteOrder() {
    final quote = ref.read(manualQuoteProvider);
    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error: No hay datos de la cotización')));
      return;
    }
    if ((quote.peopleCount ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('La cantidad de personas es requerida')));
      return;
    }
    if (quote.eventType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El tipo de evento es requerido')));
      return;
    }
    if (quote.dishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debe agregar al menos un item')));
      return;
    }
    // For quotes, navigate accordingly (e.g. to a quote summary screen).
    // GoRouter.of(context).pop(context);
    GoRouter.of(context).goNamed(AppRoute.homecart.name, extra: 'quote');
  }

  /// -----------------------------
  /// UI Builders for Each Tab
  /// -----------------------------

  /// Builds the complete catering order form view.
  Widget _buildCateringOrderForm() {
    final cateringOrder = ref.watch(cateringOrderProvider);
    final items = cateringOrder?.dishes ?? [];
    final itemsCard = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CateringOrderForm(
          onEdit: () {
            _showCateringForm(context, ref);
          },
        ),
      ],
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // eventDetailsCard,
            // const SizedBox(height: 24),
            itemsCard,
            const SizedBox(height: 24),
            if (MediaQuery.of(context).size.width > 600 &&
                items.isNotEmpty) // Only show on desktop with dishes
              ElevatedButton(
                onPressed: _confirmCateringOrder,
                child: const Text('Completar Orden'),
              ),
          ],
        ),
      ),
    );
  }

// In your screen/widget:
  void _showNewItemDialog() {
    NewItemDialog.show(
      context: context,
      onAddItem: _addItem,
    );
  }

  /// Builds the complete quote order form view.
  Widget _buildQuoteOrderForm() {
    final quote = ref.watch(manualQuoteProvider);
    if (quote == null) {
      return const Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No hay orden iniciada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Inicia una orden agregando los detalles del evento',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuoteOrderFormView(
              quote: quote,
              onEdit: () {
                _showQuoteForm(context, ref);
              },
            ),
            const SizedBox(height: 16),
            if (MediaQuery.of(context).size.width > 600 &&
                quote.dishes.isNotEmpty) // Only show on desktop
              ElevatedButton(
                onPressed: _confirmQuoteOrder,
                child: const Text('Finalizar Cotización'),
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
            quantity: quantity ?? 0,
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
    final cateringOrder = ref.watch(cateringOrderProvider);
    final quoteOrder = ref.watch(manualQuoteProvider);
    final currentOrder = _tabController.index == 0 ? cateringOrder : quoteOrder;
    final hasItems = currentOrder != null;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Catering'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (hasItems)
            FilledButton.icon(
              onPressed: () {
                if (_tabController.index == 0) {
                  _confirmCateringOrder();
                } else {
                  _confirmQuoteOrder();
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Finalizar'),
            ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 2.0,
              color: ColorsPaletteRedonda.primary,
            ),
          ),
          indicatorColor: ColorsPaletteRedonda.primary,
          labelColor: ColorsPaletteRedonda.primary,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'Nuestro Menu'),
            Tab(text: 'Cotización'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // Add the controller here
        physics:
            const NeverScrollableScrollPhysics(), // Optional: prevents swipe between tabs
        children: [
          _buildCateringOrderForm(),
          _buildQuoteOrderForm(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'completar orden',
        onPressed: _handleFabPressed,
        backgroundColor: ColorsPaletteRedonda.primary,
        icon: Icon(
          (!hasItems ? Icons.start : Icons.add_shopping_cart),
          color: Colors.white,
        ),
        label: Text((!hasItems ? 'Iniciar Orden' : 'Agregar plato')),
      ),
    );
  }
}
