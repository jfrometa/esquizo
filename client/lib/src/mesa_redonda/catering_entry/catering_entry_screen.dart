import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering_entry/components/catering_order/catering_order_form_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering_entry/components/catering_quote/quote_order_form_view.dart';
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

class CateringEntryScreenState extends ConsumerState<CateringEntryScreen> {
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

  @override
  void initState() {
    super.initState();
    _initializeCateringValues();
  }

  /// Initializes the catering form from the global catering order.
  void _initializeCateringValues() {
    final cateringOrder = ref.read(cateringOrderProvider);
    tempHasChef = cateringOrder?.hasChef ?? false;
    tempPreferencia = (cateringOrder?.preferencia.isNotEmpty ?? false)
        ? cateringOrder!.preferencia
        : 'salado';
    tempAlergiasList = cateringOrder?.alergias.split(',') ?? [];
    final peopleCount = (cateringOrder?.peopleCount != null &&
            cateringOrder!.peopleCount! > 0)
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

  @override
  void dispose() {
    customPersonasFocusNode.dispose();
    eventTypeController.dispose();
    customPersonasController.dispose();
    adicionalesController.dispose();
    super.dispose();
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



  /// Opens the bottom sheet to add/update a product for the Catering order.
  void _showCateringForm1(BuildContext context, WidgetRef ref) {
    final order = ref.read(cateringOrderProvider);
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
            initialData: order,
            onSubmit: (formData) {
              ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                    title: order?.title ?? 'Orden de Catering',
                    img: order?.img ?? 'assets/image.png',
                    description: order?.description ?? 'Catering',
                    hasChef: formData.hasChef,
                    alergias: formData.allergies.join(','),
                    eventType: formData.eventType,
                    preferencia: order?.preferencia ?? 'salado',
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La cantidad de personas es requerida')));
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
    GoRouter.of(context)
        .goNamed(AppRoute.homecart.name, extra: 'catering');
  }

  void _confirmQuoteOrder() {
    final quote = ref.read(manualQuoteProvider);
    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No hay datos de la cotización')));
      return;
    }
    if ((quote.peopleCount ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La cantidad de personas es requerida')));
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
    GoRouter.of(context).goNamed(AppRoute.homecart.name, extra: 'quote');
  }

  /// -----------------------------
  /// UI Builders for Each Tab
  /// -----------------------------

  /// Builds the complete catering order form view.
  Widget _buildCateringOrderForm() {
    final cateringOrder = ref.watch(cateringOrderProvider);
    final items = cateringOrder?.dishes ?? [];
    final itemsCard =    Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             CateringOrderForm(),
       
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCateringForm(context, ref),
              child: const Text('Agregar Producto'),
            ),
          ], 
     
    );

    return SingleChildScrollView(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // eventDetailsCard,
            // const SizedBox(height: 24),
            itemsCard,
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _confirmCateringOrder,
              child: const Text('Completar Orden'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the complete quote order form view.
  Widget _buildQuoteOrderForm() {
    final quote = ref.watch(manualQuoteProvider);
    if (quote == null) {
      return Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: ColorsPaletteRedonda.orange,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () async {
            // Navigate to manual quote screen to create a new quote.
            final manualOrder = await GoRouter.of(context)
                .pushNamed<CateringOrderItem>(AppRoute.manualQuote.name);
            if (manualOrder != null) {
              ref.read(manualQuoteProvider.notifier).state = manualOrder;
            }
          },
          child: const Text('Cotización Manual'),
        ),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuoteOrderFormView(quote: quote,),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showQuoteForm(context, ref),
              child: const Text('Agregar Producto'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _confirmQuoteOrder,
              child: const Text('Finalizar Cotización'),
            ),
          ],
        ),
      ),
    );
  }

  
  /// Builds the list of items added to the order.
  Widget _buildItemsList(List<CateringDish> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          child: ListTile(
            title: Text(
              item.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: item.title.isNotEmpty
                ? Text(
                    item.title,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => ref
                  .read(cateringOrderProvider.notifier)
                  .removeFromCart(items.indexOf(item)),
            ),
          ),
        );
      },
    );
  }

  /// Adds a new dish to the catering order.
  void _addItem(String name, String description, int? quantity) {
    if (name.trim().isEmpty) return;
   final quoteOrder  = ref.watch(manualQuoteProvider);

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
   
    // Use a DefaultTabController with two tabs.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catering'),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            indicatorColor: ColorsPaletteRedonda.primary,
            labelColor: ColorsPaletteRedonda.primary,
            unselectedLabelColor: Colors.black,
            tabs: [
              Tab(text: 'Catering'),
              Tab(text: 'Cotización'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
             _buildCateringOrderForm(),
             _buildQuoteOrderForm(),
          //  if (quote != null)  QuoteOrderFormView(quote: quote,),
     
          ],
        ),
      ),
    );
  }
}