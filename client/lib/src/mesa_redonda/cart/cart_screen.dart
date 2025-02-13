import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/catering_cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/meal_subscription_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/prompt_dialogs/new_item_dialog.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';

import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'cart_item_view.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key, required this.isAuthenticated});
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cateringOrder = ref.watch(cateringOrderProvider);
    final manualQuote = ref.watch(manualQuoteProvider); // Add this line
    final mealItems = ref.watch(mealOrderProvider);

    // Separate items by type for each tab
    final List<CartItem> dishes = cartItems
        .where(
            (item) => !item.isMealSubscription && item.foodType != 'Catering')
        .toList();
        
    final List<CateringOrderItem> cateringItems =
        cateringOrder != null ? [cateringOrder] : [];
  
   final List<CateringOrderItem> quoteItems =
        manualQuote != null ? [manualQuote] : [];
     
    final List<CartItem> mealSubscriptions = mealItems;

    // Create tabs dynamically based on available items
    List<String> availableTabs = [];
    final List<Widget> tabContent = [];

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

    void _showNewItemDialog() {
      NewItemDialog.show(
        context: ref.context,
        onAddItem: _addItem, 
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



  // Add this new method for manual quote tab
  Widget buildManualQuoteTab(WidgetRef ref, CateringOrderItem quote) {
    if (manualQuote == null) {
      return const Center(child: Text('No Quote items found.'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Detalles de la Cotización',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        onPressed: () => _showQuoteForm(context, ref),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever, size: 20, color: Colors.redAccent,),
                        onPressed: () => _showQuoteForm(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildQuoteDetailItem('Personas', '${quote.peopleCount ?? 0}'),
                  _buildQuoteDetailItem('Tipo de Evento', quote.eventType),
                  _buildQuoteDetailItem('Chef Incluido', quote.hasChef ?? false ? 'Sí' : 'No'),
                  if (quote.alergias.isNotEmpty)
                    _buildQuoteDetailItem('Alergias', quote.alergias),
                  if (quote.preferencia.isNotEmpty)
                    _buildQuoteDetailItem('Preferencia', quote.preferencia),
                  if (quote.adicionales.isNotEmpty)
                    _buildQuoteDetailItem('Notas', quote.adicionales),
                 
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Platos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: 20),
                        onPressed: () {
                          
                     _showNewItemDialog();
      
                        },
                      ),
                    ],
                  ),
                  // const SizedBox(height: 16),
                  if (quote.dishes.isEmpty)
                    const Center(
                      child: Text('No hay platos agregados'),
                    )
                  else
                    ...quote.dishes.map((dish) =>   Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                      color: Colors.grey.shade200,
                                      // width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      // vertical: 8.0,
                                    ),
                                    title: Text(
                                      dish.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        dish.hasUnitSelection
                                            ? '${dish.quantity} unidades'
                                            : '${quote.peopleCount} personas',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close, 
                                        color: Colors.red, 
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        final index = quote.dishes.indexOf(dish);
                                        ref.read(manualQuoteProvider.notifier).removeFromCart(index);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


    if (mealSubscriptions.isNotEmpty) {
      availableTabs.add('Subscripciones');
      tabContent.add(_buildTabWithCheckoutButton(
        context,
        ref,
        'subscriptions',
        mealSubscriptions,
        _buildSubscripcionesTab(ref, mealSubscriptions),
      ));
    }
    if (quoteItems.isNotEmpty) {
      availableTabs.add('Cotizar Catering');
      tabContent.add(_buildTabWithCheckoutButton(
        context,
        ref,
        'quote',
        quoteItems,
        buildManualQuoteTab(ref, manualQuote!),
      ));
    }

    if (cateringItems.isNotEmpty) {
      availableTabs.add('Catering');
      tabContent.add(_buildTabWithCheckoutButton(
        context,
        ref,
        'catering',
        cateringItems,
        _buildCateringTab(ref, cateringOrder),
      ));
    }
    if (dishes.isNotEmpty) {
      availableTabs.add('Platos');
      tabContent.add(_buildTabWithCheckoutButton(
        context,
        ref,
        'platos',
        dishes,
        _buildPlatosTab(ref, dishes),
      ));
    }

    if (availableTabs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('Carrito'),
        ),
        body: const Center(
          child: Text('No items in the cart.'),
        ),
      );
    }


    return DefaultTabController(
      length: availableTabs.length,
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('Carrito'),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: TabBar(
            isScrollable: true,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: ColorsPaletteRedonda.primary,
              ),
            ),
            indicatorColor: ColorsPaletteRedonda.primary,
            labelColor: ColorsPaletteRedonda.primary,
            unselectedLabelColor: Colors.black,
            tabs: availableTabs.map((title) {
              return Tab(text: title);
            }).toList(),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: tabContent,
        ),
      ),
    );
  }

  Widget _buildTabWithCheckoutButton(
    BuildContext context,
    WidgetRef ref,
    String tabTitle,
    List<dynamic> items,
    Widget tabContent,
  ) {
    double totalPrice = _calculateTabTotalPrice(items);

    return Column(
      children: [
        Expanded(child: tabContent),
       if (tabTitle != 'quote') _buildTotalSection(totalPrice, context),
        _buildCheckoutButton(context, ref, totalPrice, items, tabTitle),
      ],
    );
  }

  double _calculateTabTotalPrice(List<dynamic> items) {
    if (items.isEmpty) return 0.0;

    if (items.first is CateringOrderItem) {
      return items.fold<double>(
        0.0,
        (sum, item) => sum + (item as CateringOrderItem).dishes
          .fold(0.0, (sum, item) => sum + item.pricing * item.peopleCount),
      );
    } else {
      return items.fold<double>(
        0.0,
        (sum, item) =>
            sum +
            ((double.tryParse((item as CartItem).pricing) ?? 0.0) *
                item.quantity),
      );
    }
  }

Widget _buildCheckoutButton(BuildContext context, WidgetRef ref,
    double totalPrice, List<dynamic> items, String type) {
  final bool hasItemsInCurrentTab = items.isNotEmpty;
  bool isDisabled = false;
  String buttonLabel = 'Ir a Pagar';

  if (type.toLowerCase() == 'catering') {
    final cateringOrder = ref.watch(cateringOrderProvider);
    final isPersonasSelected = cateringOrder?.peopleCount != null &&
        ((cateringOrder!.peopleCount ?? 0) > 0);
    isDisabled = !isPersonasSelected;

  }

    if (type.toLowerCase() == 'quote') {
    final cateringQuote = ref.watch(manualQuoteProvider);
    final isPersonasSelected = cateringQuote?.peopleCount != null &&
        ((cateringQuote!.peopleCount ?? 0) > 0);
    isDisabled = !isPersonasSelected;
  }

  return Container(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton(
      onPressed: !isDisabled && hasItemsInCurrentTab
          ? () {
                // For other types, keep the normal behavior.
                GoRouter.of(context).goNamed(AppRoute.checkout.name, extra: type);
              // }
            }
          : null,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey; // Disabled button color.
            }
            return ColorsPaletteRedonda.primary; // Enabled button color.
          },
        ),
        foregroundColor: WidgetStateProperty.all(ColorsPaletteRedonda.white),
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
      ),
      child: Text(buttonLabel),
    ),
  );
}

  Widget _buildTotalSection(double totalPrice, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Subtotal: ',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: const Color.fromARGB(255, 235, 66, 15)),
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                .format(totalPrice),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: ColorsPaletteRedonda.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscripcionesTab(WidgetRef ref, List<CartItem> mealItems) {
    if (mealItems.isEmpty) {
      return const Center(child: Text('No meal subscriptions found.'));
    }
    return ListView.builder(
      itemCount: mealItems.length,
      itemBuilder: (context, index) {
        final item = mealItems[index];
        return MealSubscriptionItemView(
          item: item,
          onConsumeMeal: () =>
              ref.read(mealOrderProvider.notifier).consumeMeal(item.title),
          onRemoveFromCart: () =>
              ref.read(mealOrderProvider.notifier).removeFromCart(item.id),
        );
      },
    );
  }

  Widget _buildCateringTab(WidgetRef ref, CateringOrderItem? cateringOrder) {
    if (cateringOrder == null) {
      return const Center(child: Text('No catering items found.'));
    }
      return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child:  
             Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    Card( child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:  Column(
                        children: [
                          Row(children: [
                              const Text(
                                'Detalles de la Orden',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showCateringForm(ref.context, ref),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_forever, size: 20, color: Colors.redAccent,),
                                onPressed: () => ref.read(cateringOrderProvider.notifier).clearCateringOrder(),
                              ),
                            ],
                          ),
                                      const SizedBox(height: 16),
                      _buildQuoteDetailItem('Personas', '${cateringOrder.peopleCount ?? 0}'),
                      _buildQuoteDetailItem('Tipo de Evento', cateringOrder.eventType),
                      _buildQuoteDetailItem('Cheffin Incluido', (cateringOrder.hasChef ?? false) ? 'Sí' : 'No'),
                      
         
                  if (cateringOrder.alergias.isNotEmpty)
                    _buildQuoteDetailItem('Alergias', cateringOrder.alergias),
                  if (cateringOrder.preferencia.isNotEmpty)
                    _buildQuoteDetailItem('Preferencia', cateringOrder.preferencia),
                  if (cateringOrder.adicionales.isNotEmpty)
                    _buildQuoteDetailItem('Notas', cateringOrder.adicionales),
                        
                        ],
                      ),
                    ),
                    ),  
       

       
                Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with title and add icon.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Platos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () => {}
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // If no dishes added, show a placeholder text.
                  if (cateringOrder.dishes.isEmpty)
                    const Center(child: Text('No hay platos agregados'))
                  else
                    ...cateringOrder.dishes.map((dish) => Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                            title: Text(
                              dish.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                dish.hasUnitSelection
                                    ? '${dish.quantity} unidades'
                                    : '${cateringOrder.peopleCount} personas',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                final index = cateringOrder.dishes.indexOf(dish);
                                ref.read(cateringOrderProvider.notifier).removeFromCart(index);
                              },
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
      
      );
  }

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


  Widget _buildPlatosTab(WidgetRef ref, List<CartItem> platosItems) {
    if (platosItems.isEmpty) {
      return const Center(child: Text('No dishes found.'));
    }
    return ListView.builder(
      padding:  const EdgeInsets.only(bottom: 8.0),
      itemCount: platosItems.length,
      itemBuilder: (context, index) {
        final item = platosItems[index];
        
        return CartItemView(
          img: item.img,
          title: item.title,
          description: item.description,
          pricing: item.pricing,
          offertPricing: item.offertPricing,
          ingredients: item.ingredients,
          isSpicy: item.isSpicy,
          foodType: item.foodType,
          quantity: item.quantity,
          onRemove: () =>
              ref.read(cartProvider.notifier).decrementQuantity(item.title),
          onAdd: () =>
              ref.read(cartProvider.notifier).incrementQuantity(item.title),
        );
      },
    );
  }

  

  Widget _buildQuoteDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
