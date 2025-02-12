import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/catering_cart_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cart/meal_subscription_item_view.dart';
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
        cateringItems,
        _buildManualQuoteTab(ref, manualQuote!),
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

    final double maxTabWidth = TabUtils.calculateMaxTabWidth(
      context: context,
      tabTitles: availableTabs,
      extraWidth: 20.0,
    );

    return DefaultTabController(
      length: availableTabs.length,
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('Carrito'),
          bottom: TabBar(
            isScrollable: true,
            labelStyle: Theme.of(context).textTheme.titleSmall,
            unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
            labelColor: ColorsPaletteRedonda.white,
            unselectedLabelColor: ColorsPaletteRedonda.deepBrown1,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: TabIndicator(
              radius: 16.0,
              color: ColorsPaletteRedonda.primary,
            ),
            tabs: availableTabs.map((title) {
              return Container(
                width: maxTabWidth, // Set fixed width for each tab
                alignment: Alignment.center,
                child: Tab(text: title),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
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
        _buildTotalSection(totalPrice, context),
        _buildCheckoutButton(context, ref, totalPrice, items, tabTitle),
      ],
    );
  }

  double _calculateTabTotalPrice(List<dynamic> items) {
    if (items.isEmpty) return 0.0;

    if (items.first is CateringOrderItem) {
      return items.fold<double>(
        0.0,
        (sum, item) => sum + (item as CateringOrderItem).totalPrice,
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
  String buttonLabel = 'Realizar pedido';

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

    // If this catering order is a quote, change the label and action.
    if (cateringQuote != null && cateringQuote.isQuote) {
      buttonLabel = 'Guardar cotización';
      // You might want to disable the pricing check:
      isDisabled = !isPersonasSelected; // Or adjust if needed.
    }
  }
  return Container(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton(
      onPressed: !isDisabled && hasItemsInCurrentTab
          ? () {
              // if (type.toLowerCase() == 'quote') {
              //   final cateringQuote = ref.read(manualQuoteProvider);
              //   if (cateringQuote != null && cateringQuote.isQuote) {
                
              //     showDialog(
              //       context: context,
              //       builder: (context) => AlertDialog(
              //         title: const Text('Cotización Guardada'),
              //         content: const Text('La cotización se ha guardado correctamente.'),
              //         actions: [
              //           TextButton(
              //             onPressed: () {
              //               // Navigator.of(context).pop();
              //               // Optionally, clear the order from the provider
              //               // ref.read(cateringOrderProvider.notifier).state = null;
              //             },
              //             child: const Text('OK'),
              //           ),
              //         ],
              //       ),
              //     );
              //   } else {
              //     // Normal catering order flow.
              //     GoRouter.of(context).goNamed(AppRoute.checkout.name, extra: type);
              //   }
              // } else {
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
      child: CateringCartItemView(
        order: cateringOrder,
        onRemoveFromCart: () =>
            ref.read(cateringOrderProvider.notifier).clearCateringOrder(),
      ),
    );
  }

  Widget _buildPlatosTab(WidgetRef ref, List<CartItem> platosItems) {
    if (platosItems.isEmpty) {
      return const Center(child: Text('No dishes found.'));
    }
    return ListView.builder(
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

  // Add this new method for manual quote tab
  Widget _buildManualQuoteTab(WidgetRef ref, CateringOrderItem quote) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalles de la Cotización',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                        'Items Solicitados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Replace Navigator.pop with GoRouter navigation
                          // GoRouter.of(ref.context).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (quote.dishes.isEmpty)
                    const Center(
                      child: Text('No hay items agregados'),
                    )
                  else
                    ...quote.dishes.map((dish) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              dish.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dish.title.isNotEmpty)
                                  Text(dish.title),
                                Text(
                                  dish.hasUnitSelection
                                      ? '${dish.quantity} unidades'
                                      : '${quote.peopleCount} personas',
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                final index = quote.dishes.indexOf(dish);
                                ref.read(manualQuoteProvider.notifier).removeFromCart(index);
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
