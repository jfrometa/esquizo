import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catalog/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/widgets_mesa_redonda/dish_item.dart';

class MenuSection extends ConsumerWidget {
  final List<CatalogItem>? randomDishes;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const MenuSection({
    super.key,
    required this.randomDishes,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (randomDishes == null || randomDishes!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Cargando platos...',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'Nuestros Platos',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Descubra nuestra deliciosa selección de platos preparados con ingredientes frescos y de alta calidad',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Use the fully responsive grid for all screen sizes
          _buildResponsiveMenuGrid(context),

          const SizedBox(height: 32),

          // View all button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => context.goToBusinessHome(),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Ver Menú Completo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Your existing _buildResponsiveMenuGrid method with updates to use CatalogItem
  Widget _buildResponsiveMenuGrid(BuildContext context) {
    // Convert CatalogItem to the format expected by DishItem
    Map<String, dynamic> convertToDishData(CatalogItem item) {
      return {
        'title': item.name,
        'description': item.description,
        'pricing': 'S/ ${item.price.toStringAsFixed(2)}',
        'img': item.imageUrl,
        'ingredients': item.metadata['ingredients'] ?? <String>[],
        'isSpicy': item.metadata['spicy'] ?? false,
        'foodType': item.metadata['type'] ?? 'Main',
      };
    }

    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      int columnCount;
      double spacing;
      int itemCount;

      // Determine column count and spacing based on available width
      if (screenWidth > 1200) {
        columnCount = 4; // Desktop - 4 columns
        spacing = 24;
        itemCount = randomDishes!.length > 8 ? 8 : randomDishes!.length;
      } else if (screenWidth > 800) {
        columnCount = 3; // Large tablet - 3 columns
        spacing = 20;
        itemCount = randomDishes!.length > 6 ? 6 : randomDishes!.length;
      } else if (screenWidth > 600) {
        columnCount = 2; // Tablet - 2 columns
        spacing = 16;
        itemCount = randomDishes!.length > 4 ? 4 : randomDishes!.length;
      } else {
        // For mobile, we use a more efficient ListView
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: randomDishes!.length > 4 ? 4 : randomDishes!.length,
          itemBuilder: (context, index) {
            final dish = randomDishes![index];
            final dishData = convertToDishData(dish);

            // Use RepaintBoundary to optimize painting performance
            return RepaintBoundary(
              // Add key for more efficient reconciliation
              key: ValueKey('dish_item_$index'),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DishItem(
                  key: Key('dish_$index'),
                  index: index,
                  img: dishData['img'],
                  title: dishData['title'],
                  description: dishData['description'],
                  pricing: dishData['pricing'],
                  ingredients: List<String>.from(dishData['ingredients']),
                  isSpicy: dishData['isSpicy'],
                  foodType: dishData['foodType'],
                  dishData: dishData,
                  hideIngredients: true,
                  showDetailsButton: true,
                  showAddButton: true,
                  useHorizontalLayout: true,
                ),
              ),
            );
          },
        );
      }

      // Create an efficient grid using LayoutBuilder + Wrap for larger screens
      // This is more performant than GridView in some cases
      final totalSpacingWidth = spacing * (columnCount - 1);
      final cardWidth = (screenWidth - totalSpacingWidth) / columnCount;

      // Precalculate indices to avoid repeated calculations
      final indices = List<int>.generate(itemCount, (i) => i);

      return Column(
        // Using Column instead of Container for cleaner hierarchy
        children: [
          Wrap(
            spacing: spacing,
            runSpacing: spacing * 1.5,
            children: indices.map((index) {
              final dish = randomDishes![index];
              final dishData = convertToDishData(dish);

              // Use RepaintBoundary to optimize painting
              return RepaintBoundary(
                key: ValueKey('dish_grid_item_$index'),
                child: SizedBox(
                  width: cardWidth,
                  child: DishItem(
                    key: Key('dish_$index'),
                    index: index,
                    img: dishData['img'],
                    title: dishData['title'],
                    description: dishData['description'],
                    pricing: dishData['pricing'],
                    ingredients: List<String>.from(dishData['ingredients']),
                    isSpicy: dishData['isSpicy'],
                    foodType: dishData['foodType'],
                    dishData: dishData,
                    hideIngredients: screenWidth <
                        800, // Hide ingredients on smaller screens
                    showDetailsButton: true,
                    showAddButton: true,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
