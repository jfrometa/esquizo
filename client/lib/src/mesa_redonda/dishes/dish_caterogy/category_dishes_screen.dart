import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/dish_providers.dart'; 
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/dishes/cards/dish_card.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/dishes/dish_details/dish_details_screen.dart';
import '../../QR/models/qr_code_data.dart';

// Category Dishes Screen
class CategoryDishesScreen extends ConsumerWidget {
  final int categoryId;
  final String categoryName;
  final QRCodeData tableData;
  
  const CategoryDishesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.tableData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filteredDishesAsync = ref.watch(filteredDishesProvider(categoryId));
    
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DishCard(
                  dish: dish.toJson(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DishDetailsScreen(index: 1 ),
                      ),
                    );
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
