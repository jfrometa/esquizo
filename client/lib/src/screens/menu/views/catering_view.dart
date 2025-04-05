import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/widgets/catering_packages_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering/_show_catering_form_sheet.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering/_show_catering_quote_dialog.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering/catering_orders_view.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering/custom_quote_view.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/catering/manual_quote_provider.dart';

class CateringView extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const CateringView({super.key, required this.scrollController});

  @override
  ConsumerState<CateringView> createState() => _CateringViewState();
}

class _CateringViewState extends ConsumerState<CateringView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Only rebuild if needed
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _onScroll() {
    if (widget.scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        _showFab) {
      setState(() => _showFab = false);
    } else if (widget.scrollController.position.userScrollDirection ==
            ScrollDirection.forward &&
        !_showFab) {
      setState(() => _showFab = true);
    }
  }

  Widget? _getFAB(BuildContext context, ColorScheme colorScheme) {
    // Only show FAB on specific tabs
    if (_tabController.index == 1) {
      // Catering Orders tab
      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFab ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            heroTag: 'add_catering_item',
            onPressed: () {
              // Navigate to catering selection screen

              _showCateringForm(context, ref);

              GoRouter.of(context).pushNamed(AppRoute.cateringMenu.name);
            },
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            icon: const Icon(Icons.add),
            label: const Text('Add Items'),
          ),
        ),
      );
    } else if (_tabController.index == 2) {
      // Custom Quote tab
      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showFab ? 1.0 : 0.0,
          child: Consumer(
            builder: (context, ref, _) {
              return FloatingActionButton.extended(
                heroTag: 'add_quote_item',
                onPressed: () {
                  // Show add item dialog
                  showAddQuoteItemDialog(
                    context: context,
                    ref: ref,
                    onItemAdded: (item) {
                      // Add item to quote
                      final quoteOrder = ref.read(manualQuoteProvider);
                      if (quoteOrder == null) return;

                      ref.read(manualQuoteProvider.notifier).addManualItem(
                            CateringDish(
                              title: item.title,
                              quantity: item.quantity,
                              hasUnitSelection: false,
                              peopleCount: quoteOrder.peopleCount ?? 0,
                              pricePerUnit: 0,
                              pricePerPerson: 0,
                              ingredients: [],
                              pricing: 0,
                            ),
                          );
                    },
                  );
                },
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              );
            },
          ),
        ),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Services'),
        scrolledUnderElevation: 2,
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
              icon: Icon(Icons.food_bank),
              text: 'Catering Orders',
            ),
            Tab(
              icon: Icon(Icons.request_quote),
              text: 'Custom Quote',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Catering Packages tab
          CateringPackagesView(
            scrollController: widget.scrollController,
            onPackageSelected: (package) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected: ${package['title']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onCreateCustomQuote: () {
              // Switch to custom quote tab
              _tabController.animateTo(2);
            },
          ),

          // Catering Orders tab
          CateringOrdersView(
            scrollController: widget.scrollController,
            onAddItems: () {
              GoRouter.of(context).pushNamed(AppRoute.cateringMenu.name);
            },
          ),

          // Custom Quote tab
          CustomQuoteView(
            scrollController: widget.scrollController,
            onQuoteSubmitted: (quote) {
              // Navigate to cart with quote
              GoRouter.of(context)
                  .pushNamed(AppRoute.homecart.name, extra: 'quote');
            },
          ),
        ],
      ),
      floatingActionButton: _getFAB(context, colorScheme),
    );
  }

  void _showCateringForm(
    BuildContext context,
    WidgetRef ref,
  ) {
    showCateringFormSheet(
      context: context,
      ref: ref,
      title: 'Detalles de la Orden',
      onSuccess: (updatedPackage) {},
    );
  }
}
