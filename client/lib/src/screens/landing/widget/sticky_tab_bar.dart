import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/catering-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/events-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/meal-plans-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/menu-section.dart'; 

class StickyTabsContainer extends StatefulWidget {
  final TabController tabController;
  final int currentTab;
  final List<CatalogItem>? randomDishes;
  final List<CateringPackage> cateringPackages;
  final Function(int) onCateringPackageTap;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool Function(ScrollNotification) onScrollUpdate;
  final List<Widget> bottomSections;

  const StickyTabsContainer({
    Key? key,
    required this.tabController,
    required this.currentTab,
    required this.randomDishes,
    required this.cateringPackages,
    required this.onCateringPackageTap,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.onScrollUpdate,
    required this.bottomSections,
  }) : super(key: key);

  @override
  State<StickyTabsContainer> createState() => _StickyTabsContainerState();
}

class _StickyTabsContainerState extends State<StickyTabsContainer> {
  final ScrollController _mainScrollController = ScrollController();
  
  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NotificationListener<ScrollNotification>(
      onNotification: widget.onScrollUpdate ,
      child: CustomScrollView(
        controller: _mainScrollController,
        slivers: [
          // Sticky header with tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              child: Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 16 : 32,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: widget.tabController,
                    indicator: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    labelColor: colorScheme.onPrimary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    dividerHeight: 0,
                    isScrollable: false,
                    tabAlignment: TabAlignment.fill,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    tabs: const [
                      Tab(
                        child: SizedBox.expand(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu),
                              SizedBox(height: 4),
                              Text('Menú'),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox.expand(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.food_bank),
                              SizedBox(height: 4),
                              Text('Planes'),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox.expand(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.celebration),
                              SizedBox(height: 4),
                              Text('Catering'),
                            ],
                          ),
                        ),
                      ),
                      Tab(
                        child: SizedBox.expand(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available),
                              SizedBox(height: 4),
                              Text('Eventos'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              colorScheme: colorScheme,
            ),
          ),
          
          // Tab content with flexible height
          SliverToBoxAdapter(
            child: SizedBox(
              height: widget.isMobile ? 600 : 700,
              child: TabBarView(
                controller: widget.tabController,
                children: [
                  // Menu tab
                  CoordinatedScrollView(
                    child: MenuSection(
                      randomDishes: widget.randomDishes,
                      isMobile: widget.isMobile,
                      isTablet: widget.isTablet,
                      isDesktop: widget.isDesktop,
                    ),
                    mainScrollController: _mainScrollController,
                  ),

                  // Meal plans tab
                  CoordinatedScrollView(
                    child: MealPlansSection(
                      isMobile: widget.isMobile,
                      isTablet: widget.isTablet,
                      isDesktop: widget.isDesktop,
                    ),
                    mainScrollController: _mainScrollController,
                  ),

                  // Catering tab
                  CoordinatedScrollView(
                    child: CateringSection(
                      cateringPackages: widget.cateringPackages,
                      onPackageTap: widget.onCateringPackageTap,
                      isMobile: widget.isMobile,
                      isTablet: widget.isTablet,
                      isDesktop: widget.isDesktop,
                    ),
                    mainScrollController: _mainScrollController,
                  ),

                  // Events tab
                  CoordinatedScrollView(
                    child: EventsSection(
                      isMobile: widget.isMobile,
                      isTablet: widget.isTablet,
                      isDesktop: widget.isDesktop,
                    ),
                    mainScrollController: _mainScrollController,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom sections
          ...widget.bottomSections.map((section) => SliverToBoxAdapter(child: section)),
        ],
      ),
    );
  }
}

// Delegate for making the tab bar sticky
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final ColorScheme colorScheme;

  _StickyTabBarDelegate({
    required this.child,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: colorScheme.surface,
      child: child,
    );
  }

  @override
  double get maxExtent => 110; // Adjust based on your tab bar height

  @override
  double get minExtent => 110; // Keep the same height when pinned

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return true;
  }
}

// 3. Create a CoordinatedScrollView to handle the nested scrolling behavior:

class CoordinatedScrollView extends StatefulWidget {
  final Widget child;
  final ScrollController mainScrollController;

  const CoordinatedScrollView({
    Key? key,
    required this.child,
    required this.mainScrollController,
  }) : super(key: key);

  @override
  State<CoordinatedScrollView> createState() => _CoordinatedScrollViewState();
}

class _CoordinatedScrollViewState extends State<CoordinatedScrollView> {
  final ScrollController _innerScrollController = ScrollController();
  bool _isInnerScrollable = false;

  @override
  void initState() {
    super.initState();
    _innerScrollController.addListener(_handleInnerScroll);
  }

  @override
  void dispose() {
    _innerScrollController.removeListener(_handleInnerScroll);
    _innerScrollController.dispose();
    super.dispose();
  }

  void _handleInnerScroll() {
    setState(() {
      _isInnerScrollable = _innerScrollController.position.maxScrollExtent > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Handle overscroll at the top to transfer to the main scroll
        if (notification is OverscrollNotification) {
          if (notification.overscroll < 0 && _innerScrollController.position.pixels <= 0) {
            // At top and trying to scroll up more - allow main scroll to take over
            widget.mainScrollController.position.correctBy(-notification.overscroll);
            return true;
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _innerScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: widget.child,
      ),
    );
  }
}