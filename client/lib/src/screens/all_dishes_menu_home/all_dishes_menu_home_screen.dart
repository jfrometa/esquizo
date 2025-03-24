import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/cart/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catalog/catalog_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/catalog_service.dart';  
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/dish_item.dart';

class AllDishesMenuHomeScreen extends ConsumerStatefulWidget {
  const AllDishesMenuHomeScreen({super.key});

  @override
  ConsumerState<AllDishesMenuHomeScreen> createState() => _AllDishesMenuHomeScreenState();
}
 
class _AllDishesMenuHomeScreenState extends ConsumerState<AllDishesMenuHomeScreen> {
  String selectedFoodType = 'All'; // Default filter to show all dishes

  @override
  Widget build(BuildContext context) {
    final dishesAsync = ref.watch(catalogItemsProvider('menu'));
    final cart = ref.watch(cartProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platos'),
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    context.goNamed(
                      AppRoute.homecart.name,
                    );
                  },
                ),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${cart.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: dishesAsync.when(
          data: (dishes) {
            // Apply filter when we have the data
            final filteredDishes = selectedFoodType == 'All'
                ? dishes
                : dishes.where((dish) => 
                    dish.metadata['foodType'] == selectedFoodType).toList();
            
            if (filteredDishes.isEmpty) {
              return Center(
                child: Text(
                  'No dishes available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }
            
            return Column(
              children: [
                // Filter chips for food types (only show if we have dishes)
                if (dishes.isNotEmpty) _buildFoodTypeFilters(dishes),
                
                // Dishes list
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredDishes.length,
                    itemBuilder: (context, index) {
                      final dish = filteredDishes[index];
                      
                      // Convert CatalogItem to the format DishItem expects
                      final dishData = {
                        'id': dish.id,
                        'title': dish.name,
                        'description': dish.description,
                        'pricing': 'S/ ${dish.price.toStringAsFixed(2)}',
                        'img': dish.imageUrl,
                        'ingredients': dish.metadata['ingredients'] ?? <String>[],
                        'isSpicy': dish.metadata['spicy'] ?? false,
                        'foodType': dish.metadata['foodType'] ?? 'Other',
                      };
                      
                      // Use DishItem with the converted data
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DishItem(
                          img: dishData['img'],
                          title: dishData['title'],
                          description: dishData['description'],
                          pricing: dishData['pricing'],
                          ingredients: List<String>.from(dishData['ingredients']),
                          isSpicy: dishData['isSpicy'],
                          foodType: dishData['foodType'],
                          index: index,
                          dishData: dishData,
                          hideIngredients: true,
                          showAddButton: true,
                          key: ValueKey(dish.id),
                        ),
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
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading dishes: ${error.toString()}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(catalogItemsProvider('menu')),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Build filter chips for food types
  Widget _buildFoodTypeFilters(List<CatalogItem> dishes) {
    // Extract unique food types from dishes
    final foodTypes = <String>{'All'};
    for (final dish in dishes) {
      final foodType = dish.metadata['foodType'];
      if (foodType != null && foodType is String) {
        foodTypes.add(foodType);
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: foodTypes.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(type),
                selected: selectedFoodType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      selectedFoodType = type;
                    });
                  }
                },
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

