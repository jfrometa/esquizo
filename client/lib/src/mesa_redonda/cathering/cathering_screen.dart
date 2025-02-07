import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/catering_order_details.dart'
    as orderDetails;
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/cathering_order_item.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/widgets/cart_button.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/widgets/category_items_list.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/widgets/catering_form.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/cathering/widgets/catering_tab_bar.dart';
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
    final cateringItemCount = ref.watch(localCateringItemCountProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tu buffet'),
        forceMaterialTransparency: true,
        actions: [
          CartButton(itemCount: cateringItemCount),
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
      floatingActionButton: cateringItemCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => _showCateringForm(context),
              label: const Text('Completar Orden'),
              icon: Icon(Icons.shopping_cart_checkout, color: ColorsPaletteRedonda.primary),
              backgroundColor: ColorsPaletteRedonda.primary,
            )
          : null,
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

  // @override
  // Widget build(BuildContext context) {
  //   final cateringOptions = ref.watch(cateringProvider);
  //   final categorizedItems = groupCateringItemsByCategory(cateringOptions);
  //   // Inside the build method where the button is rendered
  //   final cateringItemCount = ref.watch(localCateringItemCountProvider);

  //   // Retrieve the current catering order from the provider
  //   // final cateringOrder = ref.read(cateringOrderProvider);
  //   final cateringOrderUpdate = ref.watch(cateringOrderProvider);
  //   // Set initial values, using provider values if available
  //   int? cantidadPersonas = cateringOrderUpdate?.peopleCount;
  //   final double maxTabWidth = TabUtils.calculateMaxTabWidth(
  //     context: context,
  //     tabTitles: categorizedItems.keys.toList(),
  //   );

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Selecciona tu buffet'),
  //       forceMaterialTransparency: true,
  //       actions: [
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Stack(
  //             children: [
  //               IconButton(
  //                 icon: const Icon(Icons.library_books),
  //                 onPressed: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (_) =>
  //                             const orderDetails.CateringOrderDetailsScreen()),
  //                   );
  //                 },
  //               ),
  //               cateringItemCount > 0
  //                   ? Positioned(
  //                       top: 0,
  //                       right: 0,
  //                       child: CircleAvatar(
  //                         radius: 8,
  //                         backgroundColor: Colors.red,
  //                         child: Text(
  //                           '$cateringItemCount',
  //                           style: const TextStyle(
  //                               color: Colors.white, fontSize: 10),
  //                         ),
  //                       ),
  //                     )
  //                   : const SizedBox.shrink()
  //             ],
  //           ),
  //         ),
  //       ],
  //       bottom: _isTabBarVisible
  //           ? TabBar(
  //               controller: _tabController,
  //               dividerColor: Colors.transparent,
  //               isScrollable: true,
  //               labelStyle: Theme.of(context).textTheme.titleSmall,
  //               unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
  //               labelColor: ColorsPaletteRedonda.white,
  //               unselectedLabelColor: ColorsPaletteRedonda.deepBrown1,
  //               indicatorSize: TabBarIndicatorSize.tab,
  //               indicator: TabIndicator(
  //                 color: ColorsPaletteRedonda
  //                     .primary, // Background color of the selected tab
  //                 radius: 16.0, // Radius for rounded corners
  //               ),
  //               tabs: categorizedItems.keys
  //                   .map(
  //                     (category) => Container(
  //                       width: maxTabWidth, // Set fixed width for each tab
  //                       alignment: Alignment.center,
  //                       child: Tab(text: category),
  //                     ),
  //                   )
  //                   .toList(),
  //             )
  //           : null,
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(height: 8),
  //           Expanded(
  //             child: NotificationListener<UserScrollNotification>(
  //               onNotification: _handleScrollNotification,
  //               child: TabBarView(
  //                 controller: _tabController,
  //                 children: categorizedItems.keys.map((category) {
  //                   return CategoryItemsList(
  //                     items: categorizedItems[category]!,
  //                     scrollController: _scrollController,
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //           // if (cateringItemCount > 0) // Conditionally render the button
  //           //   Padding(
  //           //     padding: const EdgeInsets.all(16.0),
  //           //     child: Center(
  //           //       child: SizedBox(
  //           //         height: 48,
  //           //         width: double.infinity,
  //           //         child: ElevatedButton(
  //           //           style: ButtonStyle(
  //           //             backgroundColor: WidgetStateProperty.all(
  //           //               cantidadPersonas == null || cantidadPersonas < 1
  //           //                   ? ColorsPaletteRedonda
  //           //                       .orange // Default color when no people count is set
  //           //                   : Colors
  //           //                       .white, // White background when people count is set
  //           //             ),
  //           //             foregroundColor: WidgetStateProperty.all(
  //           //               cantidadPersonas == null || cantidadPersonas < 1
  //           //                   ? Colors
  //           //                       .white // White text when no people count is set
  //           //                   : Theme.of(context)
  //           //                       .primaryColor, // Primary color for text when people count is set
  //           //             ),
  //           //             side: WidgetStateProperty.all(
  //           //               cantidadPersonas == null || cantidadPersonas < 1
  //           //                   ? BorderSide
  //           //                       .none // No border when no people count is set
  //           //                   : BorderSide(
  //           //                       color: Colors
  //           //                           .white, // Primary color border when people count is set
  //           //                     ),
  //           //             ),
  //           //           ),
  //           //           onPressed: () {
  //           //             _showCateringForm(context, ref);
  //           //           },
  //           //           child: Text(
  //           //             cantidadPersonas == null || cantidadPersonas < 1
  //           //                 ? 'Completar Orden' // Text when no people count is set
  //           //                 : 'Actualizar Catering', // Text when people count is set
  //           //           ),
  //           //         ),
  //           //       ),
  //           //     ),
  //           //   ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  bool _handleScrollNotification(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse && _isTabBarVisible) {
      setState(() => _isTabBarVisible = false);
    } else if (notification.direction == ScrollDirection.forward && !_isTabBarVisible) {
      setState(() => _isTabBarVisible = true);
    }
    return true;
  }
}
