import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/QR/screens/order/order_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/dish_details/dish_details_screen.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/dishes/cards/dish_card.dart';
import '../models/qr_code_data.dart';
import '../../dishes/dish_caterogy/category_dishes_screen.dart';

// Table Menu Screen (after scanning)
class TableMenuScreen extends ConsumerWidget {
  final QRCodeData tableData;

  const TableMenuScreen({
    super.key,
    required this.tableData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu - ${tableData.tableName}'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are at ${tableData.tableName}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse our menu and place your order',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Categories
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Categories list
          SizedBox(
            height: 120,
            child: Consumer(
              builder: (context, ref, child) {
                final categoriesAsync =
                    ref.watch(catalogCategoriesProvider('menu'));

                return categoriesAsync.when(
                  data: (categories) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: InkWell(
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
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(category.sortOrder),
                                    size: 32,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
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
                    child: Text('Error loading categories: $error'),
                  ),
                );
              },
            ),
          ),

          // Popular dishes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Popular Dishes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Popular dishes list
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final dishesAsync = ref.watch(catalogItemsProvider('menu'));

                return dishesAsync.when(
                  data: (dishes) {
                    // Sort dishes by rating
                    // TODO: Implement sorting logic
                    final popularDishes = dishes
                        .where((dish) => dish.isAvailable)
                        .take(5)
                        .toList();

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: popularDishes.length,
                      itemBuilder: (context, index) {
                        final dish = popularDishes[index];
                        return DishCard(
                          dish: dish.toFirestore(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DishDetailsScreen(id: dish.id)),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text('Error loading dishes: $error'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Order button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderScreen(tableData: tableData),
            ),
          );
        },
        label: const Text('View Order'),
        icon: const Icon(Icons.shopping_cart),
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
