import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/helpers/scroll_bahaviour.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/QR/models/qr_code_data.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/cards/dish_card.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/dish_caterogy/category_dishes_screen.dart';

import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/reservation/reservation_screen.dart';

class CategoryView extends ConsumerWidget {
  final ScrollController scrollController;
  final QRCodeData tableData;

  const CategoryView({
    super.key,
    required this.scrollController,
    required this.tableData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(catalogCategoriesProvider('menu'));
    final dishesAsync = ref.watch(catalogItemsProvider('menu'));

    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
          ref.invalidate(catalogCategoriesProvider);
          ref.invalidate(catalogItemsProvider('menu')); // Update refresh
          HapticFeedback.mediumImpact();
        },
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 20),

            // Categories section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.goNamed(AppRoute.category.name);
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Categories list with added reservation category
            SizedBox(
              height: 140,
              child: categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(
                      child: Text('No categories available'),
                    );
                  }

                  // Rest of the categories code remains the same
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1, // +1 for reservation
                    itemBuilder: (context, index) {
                      // Special case for reservation category
                      if (index == 0) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReservationScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    size: 40,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reserve Table',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Regular categories (shifted by 1)
                      final category = categories[index - 1];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDishesScreen(
                                categoryId: category.id,
                                categoryName: category.name,
                                tableData: tableData,
                                sortIndex: category.sortOrder,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getCategoryIcon(category.sortOrder),
                                  size: 40,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load categories: $error'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(catalogCategoriesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Featured dishes section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Dishes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.goNamed(AppRoute.allDishes.name);
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Updated featured dishes section with responsive grid
            dishesAsync.when(
              data: (dishes) {
                if (dishes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text('No featured dishes available'),
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;

                    // Determine grid layout based on screen width
                    int crossAxisCount =
                        1; // Default to 1 column on small screens

                    if (screenWidth > 600) {
                      crossAxisCount =
                          2; // 2 columns on medium screens and larger
                    }

                    // Calculate main axis extent (height) for the cards
                    // Keep it fixed at 130 for all screen sizes
                    const double cardHeight = 130;

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: cardHeight, // Fixed height for cards
                      ),
                      itemCount: dishes.length,
                      itemBuilder: (context, index) {
                        final dish = dishes[index];
                        // Convert CatalogItem to Map<String, dynamic> for DishCard
                        final dishMap = <String, dynamic>{
                          'id': dish.id,
                          'title': dish.name,
                          'description': dish.description,
                          'pricing': dish.price.toString(),
                          'price': dish.price,
                          'img': dish.imageUrl ?? 'assets/appIcon.png',
                          'foodType':
                              dish.metadata['foodType'] ?? 'Main Course',
                          'isSpicy': dish.metadata['isSpicy'] ?? false,
                          'bestSeller': dish.metadata['bestSeller'] ?? false,
                          'offertPricing':
                              dish.metadata['offertPricing']?.toString(),
                          'ingredients': dish.metadata['ingredients'] ??
                              ['Ingredient 1', 'Ingredient 2'],
                          'rating': 4.5, // Default rating if not available
                        };

                        return DishCard(
                          dish: dishMap,
                          onTap: () {
                            context.pushNamed(
                              AppRoute.addDishToOrder.name,
                              pathParameters: {'dishId': dish.id},
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load dishes: $error'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            ref.refresh(catalogItemsProvider('menu')),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.lunch_dining;
      case 2:
        return Icons.dinner_dining;
      case 3:
        return Icons.cake;
      case 4:
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }
}
