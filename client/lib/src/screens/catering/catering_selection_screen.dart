import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_item_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_item_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/widgets/catering_selection/category_items_list.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';

final localCateringItemCountProvider = StateProvider<int>((ref) {
  final cateringOrder = ref.watch(cateringOrderProvider);
  return cateringOrder?.dishes.length ?? 0;
});

class CateringSelectionScreen extends ConsumerStatefulWidget {
  const CateringSelectionScreen({super.key});

  @override
  CateringScreenState createState() => CateringScreenState();
}

class CateringScreenState extends ConsumerState<CateringSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isTabBarVisible = true;
  bool _showFAB = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateItemCount(ref);
    });
  }

  // Update the item count whenever the screen is shown
  void _updateItemCount(WidgetRef ref) {
    final cateringOrder = ref.read(cateringOrderProvider);
    final itemCount = cateringOrder?.dishes.length ?? 0;
    ref.read(localCateringItemCountProvider.notifier).state = itemCount;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cateringOptions = ref.watch(cateringItemRepositoryProvider).valueOrNull;
    final categorizedItems = groupCateringItemsByCategory(cateringOptions ?? []) ;
    _tabController = TabController(
      length: categorizedItems.keys.length,
      vsync: this,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isTabBarVisible) {
        setState(() {
          _isTabBarVisible = false; // Hide TabBar when scrolling down
          _showFAB = false; // Hide FAB when scrolling down
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isTabBarVisible) {
        setState(() {
          _isTabBarVisible = true; // Show TabBar when scrolling up
          _showFAB = true; // Show FAB when scrolling up
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showCateringForm(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
     final order = ref.read(cateringOrderProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => 
      
 CateringForm(
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
  }

  @override
  Widget build(BuildContext context) {
    final cateringOptions = ref.watch(cateringItemRepositoryProvider).valueOrNull;
    final categorizedItems = groupCateringItemsByCategory(cateringOptions ?? []);
    final itemCount = ref.watch(localCateringItemCountProvider);
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
 
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona tus platos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Crea un buffet personalizado',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        scrolledUnderElevation: 3,
        centerTitle: false,
        actions: [
          Badge(
            isLabelVisible: itemCount > 0,
            label: Text(itemCount.toString()),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'Ver selecciones',
              onPressed: () {
                if (itemCount > 0) {
                  // Navigate to cart or show selections
                  _showCateringForm(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Selecciona algunos platos primero'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: _isTabBarVisible ? PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              tabs: categorizedItems.keys.map((category) {
                return Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ) : null,
      ),
      
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: _handleScrollNotification,
                child: TabBarView(
                  controller: _tabController,
                  children: categorizedItems.keys.map((category) {
                    return CategoryItemsList(
                      items: categorizedItems[category]!,
                      scrollController: _scrollController,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFAB ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFAB ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: itemCount > 0 ? () => context.pop() : () => _showCateringForm(context),
            backgroundColor: itemCount > 0 
                ? colorScheme.primaryContainer 
                : colorScheme.surfaceContainerHighest,
            foregroundColor: itemCount > 0 
                ? colorScheme.onPrimaryContainer 
                : colorScheme.onSurfaceVariant,
            label: Text(itemCount > 0
                ? 'Continuar ($itemCount)' 
                : 'Selecciona platos',
            ),
            icon: const Icon(Icons.restaurant_menu),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _finalizeAndAddToCart(
      WidgetRef ref,
      bool hasChef,
      String alergias,
      String eventType,
      String preferencia,
      String adicionales,
      int cantidadPersonas) {
    final cateringOrderProviderNotifier =
        ref.read(cateringOrderProvider.notifier);
    
    cateringOrderProviderNotifier.finalizeCateringOrder(
      title: 'Orden de Catering',
      img: 'assets/image.png',
      description: 'Buffet personalizado • $eventType • $preferencia',
      hasChef: hasChef,
      alergias: alergias,
      eventType: eventType,
      preferencia: preferencia,
      adicionales: adicionales,
      cantidadPersonas: cantidadPersonas,
    );
  }

  Map<String, List<CateringItem>> groupCateringItemsByCategory(
      List<CateringItem> items) {
    Map<String, List<CateringItem>> categorizedItems = {};
    for (var item in items) {
      String category =
          item.id.isNotEmpty ? item.id : 'Uncategorized';
      categorizedItems.putIfAbsent(category, () => []).add(item);
    }
    return categorizedItems;
  }

  bool _handleScrollNotification(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse && _isTabBarVisible) {
      setState(() {
        _isTabBarVisible = false;
        _showFAB = false;
      });
    } else if (notification.direction == ScrollDirection.forward && !_isTabBarVisible) {
      setState(() {
        _isTabBarVisible = true;
        _showFAB = true;
      });
    }
    return true;
  }
}