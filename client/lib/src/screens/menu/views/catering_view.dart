import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering_entry/components/catering_quote/quote_order_form_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class CateringView extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const CateringView({super.key, required this.scrollController});

  @override
  ConsumerState<CateringView> createState() => _CateringViewState();
}

class _CateringViewState extends ConsumerState<CateringView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool _showFab = true;

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
      'description': 'Make your special day unforgettable with our gourmet service',
      'price': 'S/ 1500.00',
      'icon': Icons.celebration,
    },
    {
      'title': 'Custom Package',
      'description': 'Tell us your requirements for a personalized catering experience',
      'price': 'Starting at S/ 2000.00',
      'icon': Icons.settings,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Only rebuild if needed
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _onScroll() {
    if (widget.scrollController.position.userScrollDirection == ScrollDirection.reverse && _showFab) {
      setState(() => _showFab = false);
    } else if (widget.scrollController.position.userScrollDirection == ScrollDirection.forward && !_showFab) {
      setState(() => _showFab = true);
    }
  }

  void _showCateringForm(BuildContext context, WidgetRef ref, Map<String, dynamic> package) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
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
            title: 'Detalles del ${package['title']}',
            initialData: ref.read(cateringOrderProvider),
            onSubmit: (formData) {
              final currentOrder = ref.read(cateringOrderProvider);
              ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
                    title: package['title'],
                    img: '',
                    description: package['description'],
                    hasChef: formData.hasChef,
                    alergias: formData.allergies.join(','),
                    eventType: formData.eventType,
                    preferencia: currentOrder?.preferencia ?? 'salado',
                    adicionales: formData.additionalNotes,
                    cantidadPersonas: formData.peopleCount,
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Paquete ${package['title']} añadido'),
                  backgroundColor: colorScheme.primaryContainer,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
              GoRouter.of(context).pushNamed(AppRoute.homecart.name, extra: 'catering');
            },
          ),
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
              setState(() {});
            },
          ),
        );
      },
    );
  }
  
  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Item',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _itemDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad (Opcional)',
                  border: OutlineInputBorder(),
                  filled: true,
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
          ElevatedButton(
            onPressed: () {
              _addItem();
              Navigator.pop(context);
            },
            child: const Text('Agregar Item'),
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
        SnackBar(
          content: const Text('Primero debes completar los detalles de la cotización'),
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

  // Builds the menu packages tab content
  Widget _buildCateringPackagesTab() {
    final theme = Theme.of(context);
    
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Header
        Text(
          'Catering Services',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Perfect for events, parties, and corporate meetings',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        
        // Catering packages grid
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 600 ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: screenWidth > 600 ? 0.85 : 1.2,
              ),
              itemCount: _cateringPackages.length,
              itemBuilder: (context, index) {
                final package = _cateringPackages[index];
                
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _showCateringForm(context, ref, package),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            package['icon'],
                            size: 48,
                            color: theme.colorScheme.primary,
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
                          const Text(
                            'Starting from',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            package['price'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => _showCateringForm(context, ref, package),
                            child: const Text('Request Quote'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        ),
        
        const SizedBox(height: 30),
        
        // Custom catering form teaser
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Something Custom?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tell us about your event and we\'ll create the perfect menu',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Switch to the quote tab
                    _tabController.animateTo(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Create Custom Order'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Builds the custom quote tab content
  Widget _buildQuoteTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quote = ref.watch(manualQuoteProvider);
    
    if (quote == null) {
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
                  color: colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.request_quote,
                  size: 40,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay cotización iniciada',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Inicia una cotización agregando los detalles del evento',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _showQuoteForm(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Iniciar Cotización'),
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
    
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        QuoteOrderFormView(
          quote: quote,
          onEdit: () => _showQuoteForm(context, ref),
          onConfirm: _confirmQuoteOrder,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final quoteOrder = ref.watch(manualQuoteProvider);
    final hasQuoteItems = quoteOrder != null && 
                         ((quoteOrder.dishes.isNotEmpty) || 
                         ((quoteOrder.peopleCount ?? 0) > 0 && !quoteOrder.eventType.isEmpty));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        title: const Text('Catering Services'),
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
              text: 'Catering Packages',
            ),
            Tab(
              icon: Icon(Icons.request_quote),
              text: 'Custom Quote',
            ),
          ],
        ),
        actions: [
          if (_tabController.index == 1 && hasQuoteItems)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FilledButton.icon(
                onPressed: _confirmQuoteOrder,
                icon: const Icon(Icons.check),
                label: const Text('Finalizar'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCateringPackagesTab(),
          _buildQuoteTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1 && hasQuoteItems
          ? AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _showFab ? const Offset(0, 0) : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showFab ? 1.0 : 0.0,
                child: FloatingActionButton.extended(
                  heroTag: 'add_quote_item',
                  onPressed: _showAddItemDialog,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Item'),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}