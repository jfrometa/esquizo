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
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'cart_item_view.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key, required this.isAuthenticated});
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cateringOrder = ref.watch(cateringOrderProvider);
    final manualQuote = ref.watch(manualQuoteProvider);
    final mealItems = ref.watch(mealOrderProvider);
    
    // Theme variables for consistent styling
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Separate items by type for each tab
    final List<CartItem> dishes = cartItems
        .where((item) => !item.isMealSubscription && item.foodType != 'Catering')
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
        quoteItems,
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
          title: const Text('Carrito'),
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Tu carrito está vacío',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega platos o servicios para comenzar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.goNamed(AppRoute.home.name),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Ver menú'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: availableTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Carrito'),
          surfaceTintColor: Colors.transparent,
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: colorScheme.outlineVariant,
            tabs: availableTabs.map((title) {
              return Tab(text: title);
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
          .fold(0.0, (sum, dish) => sum + dish.pricing * dish.peopleCount),
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

  Widget _buildCheckoutButton(
    BuildContext context, 
    WidgetRef ref,
    double totalPrice, 
    List<dynamic> items, 
    String type
  ) {
    final bool hasItemsInCurrentTab = items.isNotEmpty;
    bool isDisabled = false;
    String buttonLabel = 'Ir a Pagar';
    final theme = Theme.of(context);

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
      buttonLabel = 'Solicitar Cotización';
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton(
          onPressed: !isDisabled && hasItemsInCurrentTab
              ? () {
                  GoRouter.of(context).goNamed(AppRoute.checkout.name, extra: type);
                }
              : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(buttonLabel),
        ),
      ),
    );
  }

  Widget _buildTotalSection(double totalPrice, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Subtotal',
            style: theme.textTheme.titleMedium,
          ),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(totalPrice),
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscripcionesTab(WidgetRef ref, List<CartItem> mealItems) {
    if (mealItems.isEmpty) {
      return _buildEmptyState('No hay subscripciones');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mealItems.length,
      itemBuilder: (context, index) {
        final item = mealItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MealSubscriptionItemView(
            item: item,
            onConsumeMeal: () =>
                ref.read(mealOrderProvider.notifier).consumeMeal(item.title),
            onRemoveFromCart: () =>
                ref.read(mealOrderProvider.notifier).removeFromCart(item.id),
          ),
        );
      },
    );
  }

  Widget _buildCateringTab(WidgetRef ref, CateringOrderItem? cateringOrder) {
    if (cateringOrder == null) {
      return _buildEmptyState('No hay pedidos de catering');
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Detalles de la Orden',
            onEdit: () => _showCateringForm(ref.context, ref),
            onDelete: () => ref.read(cateringOrderProvider.notifier).clearCateringOrder(),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Personas', '${cateringOrder.peopleCount ?? 0}'),
                _buildDetailItem('Tipo de Evento', cateringOrder.eventType),
                _buildDetailItem('Chef Incluido', (cateringOrder.hasChef ?? false) ? 'Sí' : 'No'),
                if (cateringOrder.alergias.isNotEmpty)
                  _buildDetailItem('Alergias', cateringOrder.alergias),
                if (cateringOrder.preferencia.isNotEmpty)
                  _buildDetailItem('Preferencia', cateringOrder.preferencia),
                if (cateringOrder.adicionales.isNotEmpty)
                  _buildDetailItem('Notas', cateringOrder.adicionales),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDishesCard(
            ref: ref,
            items: cateringOrder.dishes,
            personCount: cateringOrder.peopleCount,
            onRemove: (index) => ref.read(cateringOrderProvider.notifier).removeFromCart(index),
            onAdd: () => {}, // This functionality needs to be implemented
          ),
        ],
      ),
    );
  }

  Widget _buildManualQuoteTab(WidgetRef ref, CateringOrderItem quote) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Detalles de la Cotización',
            onEdit: () => _showQuoteForm(ref.context, ref),
            onDelete: () => ref.read(manualQuoteProvider.notifier).clearManualQuote(),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Personas', '${quote.peopleCount ?? 0}'),
                _buildDetailItem('Tipo de Evento', quote.eventType),
                _buildDetailItem('Chef Incluido', quote.hasChef ?? false ? 'Sí' : 'No'),
                if (quote.alergias.isNotEmpty)
                  _buildDetailItem('Alergias', quote.alergias),
                if (quote.preferencia.isNotEmpty)
                  _buildDetailItem('Preferencia', quote.preferencia),
                if (quote.adicionales.isNotEmpty)
                  _buildDetailItem('Notas', quote.adicionales),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDishesCard(
            ref: ref,
            items: quote.dishes,
            personCount: quote.peopleCount,
            onRemove: (index) => ref.read(manualQuoteProvider.notifier).removeFromCart(index),
            onAdd: () => _showNewItemDialog(ref),
            isQuote: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPlatosTab(WidgetRef ref, List<CartItem> platosItems) {
    if (platosItems.isEmpty) {
      return _buildEmptyState('No hay platos en el carrito');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: platosItems.length,
      itemBuilder: (context, index) {
        final item = platosItems[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CartItemView(
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
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: colorScheme.primary),
                      tooltip: 'Editar',
                      onPressed: onEdit,
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(40, 40),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: colorScheme.error),
                      tooltip: 'Eliminar',
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(40, 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                content,
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildDishesCard({
    required WidgetRef ref,
    required List<CateringDish> items,
    required int? personCount,
    required Function(int) onRemove,
    required VoidCallback onAdd,
    bool isQuote = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Platos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar'),
                      style: FilledButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(40, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 48,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay platos agregados',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Plato'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final dish = items[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          title: Text(
                            dish.title,
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              dish.hasUnitSelection
                                  ? '${dish.quantity} unidades'
                                  : '${personCount} personas',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                            ),
                            onPressed: () => onRemove(index),
                            tooltip: 'Eliminar',
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  '$label:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildEmptyState(String message) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showNewItemDialog(WidgetRef ref) {
    void addItem(String name, String description, int? quantity) {
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

    NewItemDialog.show(
      context: ref.context,
      onAddItem: addItem,
    );
  }

  void _showQuoteForm(BuildContext context, WidgetRef ref) {
    final quote = ref.read(manualQuoteProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
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
                SnackBar(
                  content: const Text('Se actualizó la Cotización'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1500),
                ),
              );
              GoRouter.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _showCateringForm(BuildContext context, WidgetRef ref) {
    final order = ref.read(cateringOrderProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                SnackBar(
                  content: const Text('Se actualizó el Catering'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1500),
                ),
              );
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}