import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:starter_architecture_flutter_firebase/src/core/providers/catalog/catalog_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catalog/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/cards/dish_card.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/dishes/dish_details/dish_details_screen.dart';
import '../../QR/models/qr_code_data.dart';

// Create a provider that filters catalog items by category
final filteredCatalogItemsProvider = Provider.family<AsyncValue<List<CatalogItem>>, String>(
  (ref, categoryId) {
    final catalogItemsAsyncValue = ref.watch(catalogItemsProvider('menu'));
    return catalogItemsAsyncValue.when(
      data: (items) {
        final filtered = items.where((item) {
          // Log item IDs for debugging
          debugPrint('Filtering - Item ID: ${item.id}, Category ID: $categoryId, Match: ${item.id == categoryId}');
          return item.categoryId == categoryId;
        }).toList();
        return AsyncValue.data(filtered);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  },
);

// Category Dishes Screen
class CategoryDishesScreen extends ConsumerWidget {
  final String categoryId;
  final int sortIndex;
  final String categoryName;
  final QRCodeData tableData;
  
  const CategoryDishesScreen( {
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.tableData,
    required this.sortIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Use the new filteredCatalogItemsProvider instead of filteredDishesProvider
    final filteredDishesAsync = ref.watch(filteredCatalogItemsProvider(categoryId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
        elevation: 0,
      ),
      body: filteredDishesAsync.when(
        data: (dishes) {
          if (dishes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.no_food,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No dishes available in this category',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dishes.length,
            itemBuilder: (context, index) {
              final dish = dishes[index];
              // Convert CatalogItem to Map for DishCard
              final dishMap = {
                'id': dish.id,
                'title': dish.name,
                'description': dish.description,
                'pricing': dish.price,
                'img': dish.imageUrl ?? 'assets/images/placeholder_food.png',
                'foodType': dish.metadata['foodType'] ?? 'Main Course',
                'isSpicy': dish.metadata['isSpicy'] ?? false,
                'ingredients': dish.metadata['ingredients'] ?? ['Ingredient 1', 'Ingredient 2'],
                'nutritionalInfo': dish.metadata['nutritionalInfo'],
              };
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DishCard(
                  dish: dishMap,
                  onTap: () {
                    // Find the index of this dish in the full catalog
                    ref.read(catalogItemsProvider('menu')).whenData((allDishes) {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DishDetailsScreen(id: dish.id),
                        ),
                      );
                    });
                  },
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
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading dishes',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
