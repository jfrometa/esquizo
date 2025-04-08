import 'package:flutter/material.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/catering-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/events-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/meal-plans-section.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/landing/sections/menu-section.dart';

class ContentSections extends StatelessWidget {
  final TabController tabController;
  final int currentTab;
  final List<CatalogItem>? randomDishes;
  final List<CateringPackage> cateringPackages;
  final Function(int) onCateringPackageTap;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const ContentSections({
    super.key,
    required this.tabController,
    required this.currentTab,
    required this.randomDishes,
    required this.cateringPackages,
    required this.onCateringPackageTap,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              dividerHeight: 0,
              isScrollable: false, // Make sure tabs are not scrollable
              tabAlignment: TabAlignment.fill, // Make tabs take up equal space
              padding: EdgeInsets.zero, // Remove padding around the TabBar
              labelPadding:
                  EdgeInsets.zero, // Remove padding around each tab label
              tabs: const [
                // Use SizedBox.expand to make the whole tab area clickable
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

          const SizedBox(height: 40),

          // Tab content
          SizedBox(
            // Fixed height makes the layout more stable
            height: isMobile ? 600 : 700,
            child: TabBarView(
              controller: tabController,
              children: [
                // Menu tab
                MenuSection(
                  randomDishes: randomDishes,
                  isMobile: isMobile,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),

                // Meal plans tab
                MealPlansSection(
                  isMobile: isMobile,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),

                // Catering tab
                CateringSection(
                  cateringPackages: cateringPackages,
                  onPackageTap: onCateringPackageTap,
                  isMobile: isMobile,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),

                // Events tab
                EventsSection(
                  isMobile: isMobile,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
