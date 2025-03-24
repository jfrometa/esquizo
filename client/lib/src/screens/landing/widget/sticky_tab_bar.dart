import 'package:flutter/foundation.dart';
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
    
    // Use AlwaysScrollableScrollPhysics as the default for all platforms
    const scrollPhysics = AlwaysScrollableScrollPhysics();

    return NotificationListener<ScrollNotification>(
      onNotification: widget.onScrollUpdate,
      child: CustomScrollView(
        controller: _mainScrollController,
        physics: scrollPhysics,
        slivers: [
          // Sticky header with tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              colorScheme: colorScheme,
              child: Material(
                color: colorScheme.surface,
                child: TabBar(
                  controller: widget.tabController,
                  indicator: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelColor: colorScheme.onPrimary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  dividerHeight: 0,
                  tabAlignment: TabAlignment.fill,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.restaurant_menu),
                      text: 'Menú',
                    ),
                    Tab(
                      icon: Icon(Icons.food_bank),
                      text: 'Planes',
                    ),
                    Tab(
                      icon: Icon(Icons.celebration),
                      text: 'Catering',
                    ),
                    Tab(
                      icon: Icon(Icons.event_available),
                      text: 'Eventos',
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Tab content with flexible height
          SliverToBoxAdapter(
            child: SizedBox(
              height: widget.isMobile ? 600 : 700,
              child: TabBarView(
                controller: widget.tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Menu tab
                  SingleChildScrollView(
                    physics: scrollPhysics,
                    child: MenuSection(
                      randomDishes: widget.randomDishes,
                      isMobile: widget.isMobile,
                      isTablet: widget.isTablet,
                      isDesktop: widget.isDesktop,
                    ),
                  ),

                  // Meal plans tab
                  SingleChildScrollView(
                    physics: scrollPhysics,
                    child: MealPlansSection(
                      isMobile: widget.isMobile,
                      isTablet: widget.isTablet,
                      isDesktop: widget.isDesktop,
                    ),
                  ),

                  // Catering tab
                  SingleChildScrollView(
                    physics: scrollPhysics,
                    child: CateringSection(
                      cateringPackages: widget.cateringPackages,
                      onPackageTap: widget.onCateringPackageTap,
                      isMobile: widget.isMobile,
                      isTablet: widget.isTablet,
                      isDesktop: widget.isDesktop,
                    ),
                  ),

                  // Events tab
                  SingleChildScrollView(
                    physics: scrollPhysics,
                    child: EventsSection(
                      isMobile: widget.isMobile,
                      isTablet: widget.isTablet,
                      isDesktop: widget.isDesktop,
                    ),
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

// StickyTabBarDelegate implementation
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final ColorScheme colorScheme;

  _StickyTabBarDelegate({
    required this.child,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 85.0;

  @override
  double get minExtent => 85.0;

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}