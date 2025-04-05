import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/cart/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/meal_subscription_item_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/prompt_dialogs/new_item_dialog.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'cart_item_view.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key, required this.isAuthenticated});
  final bool isAuthenticated;

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _availableTabs = [];

  @override
  void initState() {
    super.initState();
    // Initialize tabs and controller in initState
    _availableTabs = _getAvailableTabs();
    _initializeTabController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _initializeTabController() {
    if (_availableTabs.isEmpty) {
      _availableTabs = ['Platos']; // Default tab if nothing is available
    }

    // If there are available tabs, create the controller
    _tabController = TabController(length: _availableTabs.length, vsync: this);

    // Add listener only if controller is initialized
    _tabController?.addListener(() {
      // This ensures we rebuild when the tab changes
      if (_tabController?.indexIsChanging == true) {
        setState(() {});
      }
    });
  }

  List<String> _getAvailableTabs() {
    final List<String> tabs = [];
    final cartItems = ref.read(cartProvider);
    final cateringOrder = ref.read(cateringOrderProvider);
    final manualQuote = ref.read(manualQuoteProvider);
    final mealItems = ref.read(mealOrderProvider);

    // Add tabs in order of priority
    if (mealItems.isNotEmpty) tabs.add('Subscripciones');
    if (manualQuote != null) tabs.add('Cotizar Catering');
    if (cateringOrder != null) tabs.add('Catering');

    // Regular dishes should always be available as an option
    tabs.add('Platos');

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers to rebuild when they change
    final cartItems = ref.watch(cartProvider);
    final cateringOrder = ref.watch(cateringOrderProvider);
    final manualQuote = ref.watch(manualQuoteProvider);
    final mealItems = ref.watch(mealOrderProvider);

    // Theme variables for consistent styling
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Separate items by type for each tab
    final List<CartItem> dishes = cartItems.items
        .where(
            (item) => !item.isMealSubscription && item.foodType != 'Catering')
        .toList();

    final List<CateringOrderItem> cateringItems =
        cateringOrder != null ? [cateringOrder] : [];

    final List<CateringOrderItem> quoteItems =
        manualQuote != null ? [manualQuote] : [];

    final List<CartItem> mealSubscriptions = mealItems;

    // Update available tabs
    _availableTabs = _getAvailableTabs();

    // If we have no items at all, show empty state
    if (_availableTabs.isEmpty ||
        (_availableTabs.length == 1 && dishes.isEmpty)) {
      return _buildEmptyCartScreen(context);
    }

    // Check if we need to reinitialize the tab controller due to tab count change
    if (_tabController == null ||
        _tabController?.length != _availableTabs.length) {
      // Reinitialize the controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _initializeTabController();
        });
      });
      return _buildLoadingScreen();
    }

    final List<Widget> tabContent = [];

    if (mealSubscriptions.isNotEmpty) {
      tabContent.add(_buildTabWithCheckoutButton(
        context,
        ref,
        'subscriptions',
        mealSubscriptions,
        _buildSubscripcionesTab(ref, mealSubscriptions),
      ));
    }

    if (quoteItems.isNotEmpty) {
      tabContent.add(_buildTabWithCheckoutButton(
        context,
        ref,
        'quote',
        quoteItems,
        _buildManualQuoteTab(ref, manualQuote!),
      ));
    }

    if (cateringItems.isNotEmpty) {
      tabContent.add(_buildTabWithCheckoutButton(
        context,
        ref,
        'catering',
        cateringItems,
        _buildCateringTab(ref, cateringOrder),
      ));
    }

    tabContent.add(_buildTabWithCheckoutButton(
      context,
      ref,
      'platos',
      dishes,
      _buildPlatosTab(ref, dishes),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showCartOptions(context),
            tooltip: 'Opciones de carrito',
          ),
        ],
        bottom: _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: colorScheme.outlineVariant,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                tabs: _availableTabs.map((title) {
                  IconData tabIcon;
                  switch (title) {
                    case 'Subscripciones':
                      tabIcon = Icons.calendar_today;
                      break;
                    case 'Cotizar Catering':
                      tabIcon = Icons.request_quote;
                      break;
                    case 'Catering':
                      tabIcon = Icons.restaurant;
                      break;
                    case 'Platos':
                    default:
                      tabIcon = Icons.restaurant_menu;
                  }

                  return Tab(
                    icon: Icon(tabIcon),
                    text: title,
                    iconMargin: const EdgeInsets.only(bottom: 4),
                  );
                }).toList(),
              ),
      ),
      body: _errorMessage != null
          ? _buildErrorState(_errorMessage!)
          : _isLoading || _tabController == null
              ? _buildLoadingState()
              : TabBarView(
                  controller: _tabController,
                  children: tabContent,
                ),
    );
  }

// Empty cart action button handlers
  void _handleEmptyCartAction(String type) {
    if (type.toLowerCase() == 'catering') {
      _showCateringForm(context, ref);
    } else if (type.toLowerCase() == 'quote') {
      _showQuoteForm(context, ref);
    }
  }

  void _showNewItemDialog(WidgetRef ref) {
    void addItem(String name, String description, int? quantity) {
      if (name.trim().isEmpty) return;
      final quoteOrder = ref.read(manualQuoteProvider);

      if (quoteOrder == null) {
        // Create a new quote if none exists
        ref.read(manualQuoteProvider.notifier).createEmptyQuote();
      }

      ref.read(manualQuoteProvider.notifier).addManualItem(
            CateringDish(
              title: name.trim(),
              quantity: quantity ?? 1,
              hasUnitSelection: false,
              peopleCount: quoteOrder?.peopleCount ?? 0,
              pricePerUnit: 0,
              pricePerPerson: 0,
              ingredients: [],
              pricing: 0,
            ),
          );

      // Force a UI refresh
      setState(() {});
    }

    NewItemDialog.show(
      context: context,
      onAddItem: addItem,
    );
  }

  Widget _buildEmptyCartScreen(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu carrito está vacío',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Agrega platos, servicios de catering o solicita una cotización para comenzar',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.goNamed(AppRoute.home.name),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Explorar Menú'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _handleEmptyCartAction('catering'),
              icon: const Icon(Icons.event_available),
              label: const Text('Ver Servicios de Catering'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(milliseconds: 800));
              setState(() => _isLoading = false);
              // Could add actual data refresh logic here if needed
            },
            child: tabContent,
          ),
        ),
        if (tabTitle != 'quote') _buildTotalSection(totalPrice, context),
        _buildCheckoutButton(context, ref, totalPrice, items, tabTitle),
      ],
    );
  }

  double _calculateTabTotalPrice(List<dynamic> items) {
    if (items.isEmpty) return 0.0;

    try {
      if (items.first is CateringOrderItem) {
        return items.fold<double>(
          0.0,
          (sum, item) =>
              sum +
              (item as CateringOrderItem).dishes.fold(
                  0.0, (sum, dish) => sum + (dish.pricing * dish.quantity)),
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
    } catch (e) {
      // Handle calculation errors gracefully
      debugPrint('Error calculating price: $e');
      return 0.0;
    }
  }

  Widget _buildCheckoutButton(BuildContext context, WidgetRef ref,
      double totalPrice, List<dynamic> items, String type) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool hasItemsInCurrentTab = items.isNotEmpty;
    bool isDisabled = false;
    String buttonLabel = 'Ir a Pagar';
    IconData buttonIcon = Icons.payment;
    Color buttonColor = colorScheme.primary;

    if (type.toLowerCase() == 'catering') {
      final cateringOrder = ref.read(cateringOrderProvider);
      final isPersonasSelected = cateringOrder?.peopleCount != null &&
          ((cateringOrder!.peopleCount ?? 0) > 0);
      isDisabled = !isPersonasSelected;
      buttonIcon = Icons.room_service;
    }

    if (type.toLowerCase() == 'quote') {
      final cateringQuote = ref.read(manualQuoteProvider);
      final isPersonasSelected = cateringQuote?.peopleCount != null &&
          ((cateringQuote!.peopleCount ?? 0) > 0);
      isDisabled = !isPersonasSelected;
      buttonLabel = 'Solicitar Cotización';
      buttonIcon = Icons.request_quote;
      buttonColor = colorScheme.secondary;
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: !isDisabled && hasItemsInCurrentTab
              ? () => _proceedToCheckout(context, type)
              : null,
          icon: Icon(buttonIcon),
          label: Text(buttonLabel),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: buttonColor,
            disabledBackgroundColor: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, String type) {
    try {
      // Show loading indicator
      setState(() => _isLoading = true);

      // Add a small delay to show animation
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => _isLoading = false);
        GoRouter.of(context).goNamed(AppRoute.checkout.name, extra: type);
      });
    } catch (e) {
      // Handle navigation errors
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Error al proceder al pago. Por favor, inténtalo de nuevo.';
      });

      // Clear error after delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _errorMessage = null);
        }
      });
    }
  }

  Widget _buildTotalSection(double totalPrice, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subtotal',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                'Sin impuestos ni envío',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            NumberFormat.currency(symbol: 'S/ ', decimalDigits: 2)
                .format(totalPrice),
            style: theme.textTheme.headlineSmall?.copyWith(
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
      return _buildEmptyTabState(
        'No hay subscripciones activas',
        'Adquiere un plan de comidas para disfrutar de nuestros platillos regularmente',
        Icons.calendar_today,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mealItems.length,
      itemBuilder: (context, index) {
        final item = mealItems[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, 0, 0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: MealSubscriptionItemView(
              item: item,
              onConsumeMeal: () =>
                  ref.read(mealOrderProvider.notifier).consumeMeal(item.title),
              onRemoveFromCart: () =>
                  ref.read(mealOrderProvider.notifier).removeFromCart(item.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCateringTab(WidgetRef ref, CateringOrderItem? cateringOrder) {
    if (cateringOrder == null) {
      return _buildEmptyTabState(
        'No hay pedidos de catering',
        'Crea una orden para tus eventos especiales',
        Icons.food_bank_outlined,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Detalles de la Orden',
            onEdit: () => _showCateringForm(context, ref),
            onDelete: () => _confirmDelete(
              context,
              'orden de catering',
              () =>
                  ref.read(cateringOrderProvider.notifier).clearCateringOrder(),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(
                    'Personas', '${cateringOrder.peopleCount ?? 0}'),
                _buildDetailItem('Tipo de Evento', cateringOrder.eventType),
                _buildDetailItem('Chef Incluido',
                    (cateringOrder.hasChef ?? false) ? 'Sí' : 'No'),
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
            onRemove: (index) =>
                ref.read(cateringOrderProvider.notifier).removeFromCart(index),
            onAdd: () => _handleAddItemPressed('catering'),
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
            onEdit: () => _showQuoteForm(context, ref),
            onDelete: () => _confirmDelete(
              context,
              'cotización',
              () => ref.read(manualQuoteProvider.notifier).clearManualQuote(),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Personas', '${quote.peopleCount ?? 0}'),
                _buildDetailItem('Tipo de Evento', quote.eventType),
                _buildDetailItem(
                    'Chef Incluido', quote.hasChef ?? false ? 'Sí' : 'No'),
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
            onRemove: (index) =>
                ref.read(manualQuoteProvider.notifier).removeFromCart(index),
            onAdd: () => _handleAddItemPressed('quote'),
            isQuote: true,
          ),

          // Additional info card for quote process
          const SizedBox(height: 16),
          _buildInformationCard(
            title: 'Información de Cotización',
            description:
                'Tu solicitud será enviada a nuestro equipo para generar un presupuesto detallado. Te contactaremos en un plazo de 24-48 horas.',
            icon: Icons.info_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildPlatosTab(WidgetRef ref, List<CartItem> platosItems) {
    if (platosItems.isEmpty) {
      return _buildEmptyTabState(
        'No hay platos en el carrito',
        'Agrega platos de nuestro menú para comenzar tu pedido',
        Icons.restaurant_menu,
      );
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
    return Builder(builder: (context) {
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
    });
  }

  Widget _buildInformationCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Card(
        elevation: 0,
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            colorScheme.onSecondaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDishesCard({
    required WidgetRef ref,
    required List<CateringDish> items,
    required int? personCount,
    required Function(int) onRemove,
    required VoidCallback onAdd,
    bool isQuote = false,
  }) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final accentColor = isQuote ? colorScheme.secondary : colorScheme.primary;

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
                    items.isEmpty
                        ? 'Agregar Platos'
                        : 'Platos (${items.length})',
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
                      backgroundColor: accentColor.withOpacity(0.1),
                      foregroundColor: accentColor,
                      minimumSize: const Size(40, 40),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
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
                          style: FilledButton.styleFrom(
                            backgroundColor: accentColor,
                          ),
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
                      color:
                          colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: accentColor.withOpacity(0.2),
                          foregroundColor: accentColor,
                          child: Text(
                            '${dish.quantity}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          dish.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            dish.hasUnitSelection
                                ? '${dish.quantity} unidades'
                                : '$personCount personas',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (dish.pricing > 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Text(
                                  'S/ ${(dish.pricing * dish.quantity).toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: colorScheme.error,
                              ),
                              onPressed: () => onRemove(index),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailItem(String label, String value) {
    return Builder(builder: (context) {
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
    });
  }

  Widget _buildEmptyTabState(
      String message, String description, IconData icon) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildLoadingState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando carrito...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Ha ocurrido un error',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = false;
                  });
                },
                child: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _handleAddItemPressed(String type) {
    if (type.toLowerCase() == 'catering') {
      final order = ref.read(cateringOrderProvider);
      if (order == null || (order.peopleCount ?? 0) <= 0) {
        // Show catering form first
        _showCateringForm(context, ref);
      } else {
        // Allow adding items
        GoRouter.of(context).pushNamed(AppRoute.cateringMenu.name);
      }
    } else if (type.toLowerCase() == 'quote') {
      final quote = ref.read(manualQuoteProvider);
      if (quote == null || (quote.peopleCount ?? 0) <= 0) {
        // Show quote form first
        _showQuoteForm(context, ref);
      } else {
        // Allow adding items
        _showNewItemDialog(ref);
      }
    }
  }

  void _showQuoteForm(BuildContext context, WidgetRef ref) {
    final quote = ref.read(manualQuoteProvider);
    if (quote == null) {
      // Create empty quote first
      ref.read(manualQuoteProvider.notifier).createEmptyQuote();
    }

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
            bottom: MediaQuery.viewInsetsOf(context).bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: CateringForm(
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
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 1500),
                ),
              );
              Navigator.pop(context);

              // Force a UI refresh
              setState(() {});
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
                Navigator.pop(context);

                // Force a UI refresh
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
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
  }

  void _showCartOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('Vaciar carrito'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmClearCart(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Ver historial de pedidos'),
                onTap: () {
                  Navigator.pop(context);
                  // Add navigation to order history
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Ayuda con mi pedido'),
                onTap: () {
                  Navigator.pop(context);
                  // Add help functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmClearCart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar todos los items de tu carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancelar', style: TextStyle(color: colorScheme.primary)),
          ),
          FilledButton(
            onPressed: () {
              // Clear all cart items
              ref.read(cartProvider.notifier).clearCart();
              ref.read(cateringOrderProvider.notifier).clearCateringOrder();
              ref.read(manualQuoteProvider.notifier).clearManualQuote();
              ref.read(mealOrderProvider.notifier).clearCart();

              Navigator.pop(context);

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Carrito vaciado con éxito'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.secondary,
                ),
              );

              // Force a UI refresh and reset tab controller
              setState(() {});
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Vaciar carrito'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, String itemType, VoidCallback onConfirm) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar $itemType'),
        content: Text('¿Estás seguro de que deseas eliminar esta $itemType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancelar', style: TextStyle(color: colorScheme.primary)),
          ),
          FilledButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$itemType eliminada'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.secondary,
                ),
              );

              // Force a UI refresh
              setState(() {});
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
