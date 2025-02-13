import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/widgets/cart_button.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/widgets/category_items_list.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/widgets/catering_tab_bar.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

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
    final cateringOptions = ref.watch(cateringProvider);
    final categorizedItems = groupCateringItemsByCategory(cateringOptions);
    _tabController = TabController(
      length: categorizedItems.keys.length,
      vsync: this,
    );
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isTabBarVisible) {
        setState(() {
          _isTabBarVisible = false; // Hide TabBar when scrolling down
        });
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isTabBarVisible) {
        setState(() {
          _isTabBarVisible = true; // Show TabBar when scrolling up
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CateringForm(
        onSubmit: (hasChef, alergias, eventType, preferencia, adicionales, cantidadPersonas) {
          _finalizeAndAddToCart(
            ref,
            hasChef,
            alergias,
            eventType,
            preferencia,
            adicionales,
            cantidadPersonas,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Se agregó el Catering al carrito'),
              backgroundColor: Colors.brown[200],
              duration: const Duration(milliseconds: 500),
            ),
          );
          GoRouter.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cateringOptions = ref.watch(cateringProvider);
    final categorizedItems = groupCateringItemsByCategory(cateringOptions);
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona los platos de tu buffet'),
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            color: ColorsPaletteRedonda.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        bottom: _isTabBarVisible ? PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: CateringTabBar(
            controller: _tabController,
            categories: categorizedItems.keys.toList(),
            maxTabWidth: TabUtils.calculateMaxTabWidth(
              context: context,
              tabTitles: categorizedItems.keys.toList(),
            ),
          ),
        ) : PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 2.0,
                ),
              ),
            ),
          ),
        ),
      ),
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
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
      ),
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
      description: 'Catering',
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
          item.category.isNotEmpty ? item.category : 'Uncategorized';
      categorizedItems.putIfAbsent(category, () => []).add(item);
    }
    return categorizedItems;
  }


  bool _handleScrollNotification(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse && _isTabBarVisible) {
      setState(() => _isTabBarVisible = false);
    } else if (notification.direction == ScrollDirection.forward && !_isTabBarVisible) {
      setState(() => _isTabBarVisible = true);
    }
    return true;
  }
}
