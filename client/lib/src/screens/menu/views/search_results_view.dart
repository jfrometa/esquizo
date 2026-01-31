import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/cards/dish_card_small.dart';

// SEARCH RESULTS VIEW
class SearchResultsView extends ConsumerWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const SearchResultsView({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Replace dishProvider with catalogItemsProvider
    final dishesAsync = ref.watch(catalogItemsProvider('menu'));

    return dishesAsync.when(
      data: (dishes) {
        // Filter dishes based on search query
        final filteredDishes = dishes.where((dish) {
          final title = dish.name.toLowerCase();
          final description = dish.description.toLowerCase();
          final category =
              dish.metadata['foodType']?.toString().toLowerCase() ?? '';

          final query = searchQuery.toLowerCase();
          return title.contains(query) ||
              description.contains(query) ||
              category.contains(query);
        }).toList();

        // If no results found
        if (filteredDishes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$searchQuery"',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onClearSearch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Clear Search'),
                ),
              ],
            ),
          );
        }

        // Show results
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Results for "$searchQuery"',
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredDishes.length} found',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 800
                          ? 4
                          : screenWidth > 600
                              ? 3
                              : 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredDishes.length,
                    itemBuilder: (context, index) {
                      final dish = filteredDishes[index];
                      // Convert CatalogItem to Map for DishCardSmall
                      final dishMap = {
                        'id': dish.id,
                        'title': dish.name,
                        'description': dish.description,
                        'pricing': dish.price,
                        'img': dish.imageUrl,
                        'foodType': dish.metadata['foodType'] ?? 'Main Course',
                        'isSpicy': dish.metadata['isSpicy'] ?? false,
                      };

                      return DishCardSmall(
                        dish: dishMap,
                        onAddToCart: () {
                          ref.read(cartProvider.notifier).addToCart(
                                dishMap,
                                1,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${dish.name} added to cart'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading dishes: $error',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.refresh(catalogItemsProvider('menu')),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
