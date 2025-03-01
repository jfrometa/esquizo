// DishItem.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

class DishItem extends ConsumerWidget {
  final String img;
  final String title;
  final String description;
  final String pricing;
  final List<String> ingredients;
  final bool isSpicy;
  final String foodType;
  final int index;
  final Map<String, dynamic> dishData;
  final bool hideIngredients;

  const DishItem({
    super.key,
    required this.img,
    required this.title,
    required this.description,
    required this.pricing,
    required this.ingredients,
    required this.isSpicy,
    required this.foodType,
    required this.index,
    required this.dishData,
    this.hideIngredients = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to details screen
          context.goNamed(
            AppRoute.addToOrder.name,
            pathParameters: {"itemId": index.toString()},
            extra: dishData,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if we should use horizontal layout based on available width
            final useHorizontalLayout = !isSmallScreen && constraints.maxWidth > 500;
            
            if (useHorizontalLayout) {
              return _buildHorizontalLayout(context, theme, colorScheme, constraints, ref);
            } else {
              return _buildVerticalLayout(context, theme, colorScheme, constraints, ref);
            }
          },
        ),
      ),
    );
  }
  
  // Horizontal layout for wider containers (desktop)
  Widget _buildHorizontalLayout(
    BuildContext context, 
    ThemeData theme, 
    ColorScheme colorScheme,
    BoxConstraints constraints,
    WidgetRef ref,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section (fixed width)
        SizedBox(
          width: constraints.maxWidth * 0.4,
          height: double.infinity,
          child: _buildImageSection(colorScheme, theme),
        ),
        
        // Content section (expanded)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleSection(theme, colorScheme),
                const SizedBox(height: 8),
                _buildDescriptionSection(theme, colorScheme),
                if (!hideIngredients && ingredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildIngredientsSection(theme, colorScheme),
                ],
                const Spacer(),
                _buildActionButtons(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Vertical layout for narrow containers (mobile)
  Widget _buildVerticalLayout(
    BuildContext context, 
    ThemeData theme, 
    ColorScheme colorScheme,
    BoxConstraints constraints,
    WidgetRef ref
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image section
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildImageSection(colorScheme, theme),
        ),
        
        // Content section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleSection(theme, colorScheme),
              const SizedBox(height: 8),
              _buildDescriptionSection(theme, colorScheme),
              if (!hideIngredients && ingredients.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildIngredientsSection(theme, colorScheme),
              ],
              const SizedBox(height: 16),
              _buildActionButtons(context, ref),
            ],
          ),
        ),
      ],
    );
  }
  
  // Image section with overlay and badges
  Widget _buildImageSection(ColorScheme colorScheme, ThemeData theme) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        Hero(
          tag: 'dish_image_$index',
          child: Image.asset(
            img,
            fit: BoxFit.cover,
          ),
        ),
        
        // Gradient overlay for text readability
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
              stops: const [0.7, 1.0],
            ),
          ),
        ),
        
        // Type badges (Vegan/Spicy/etc)
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            children: [
              if (isSpicy)
                _buildBadge(
                  icon: Icons.whatshot,
                  text: 'Spicy',
                  backgroundColor: Colors.red.withOpacity(0.8),
                  textColor: Colors.white,
                ),
              if (foodType.toLowerCase() == 'vegan')
                _buildBadge(
                  icon: Icons.eco,
                  text: 'Vegan',
                  backgroundColor: Colors.green.withOpacity(0.8),
                  textColor: Colors.white,
                ),
              if (foodType.toLowerCase() != 'vegan')
                _buildBadge(
                  icon: Icons.restaurant,
                  text: foodType,
                  backgroundColor: Colors.brown.withOpacity(0.8),
                  textColor: Colors.white,
                ),
            ],
          ),
        ),
        
        // Price badge
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "\$${pricing}",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Title section with dish name
  Widget _buildTitleSection(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  // Description section
  Widget _buildDescriptionSection(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  // Ingredients section
  Widget _buildIngredientsSection(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.kitchen,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            ingredients.join(', '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  // Action buttons
  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Details button
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.remove_red_eye, size: 16),
            label: const Text('Details'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () {
              context.goNamed(
                AppRoute.addToOrder.name,
                pathParameters: {"itemId": index.toString()},
                extra: dishData,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        // Add to cart button
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.add_shopping_cart, size: 16),
            label: const Text('Add'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () {
              // Add item to cart
              ref.read(cartProvider.notifier).addToCart(
                    dishData,
                    1,
                  );
              
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title added to cart'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Helper method to build badges
  Widget _buildBadge({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// DishGridView.dart (Updated responsive grid implementation)
class DishGridView extends StatelessWidget {
  final List dishes;
  final bool hideIngredients;

  const DishGridView({
    super.key,
    required this.dishes,
    this.hideIngredients = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use maximum cross-axis extent instead of fixed count
        // This allows items to take their natural size
        return GridView.builder(
          itemCount: dishes.length,
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 550, // Maximum width of each item
            mainAxisExtent: 280, // Let height be flexible based on content
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (BuildContext context, int index) {
            final dish = dishes[index];
            return RepaintBoundary(
              child: DishItem(
                img: dish["img"],
                title: dish["title"],
                description: dish["description"],
                pricing: dish["pricing"],
                ingredients: List<String>.from(dish["ingredients"]),
                isSpicy: dish["isSpicy"],
                foodType: dish["foodType"],
                key: ValueKey('dish_$index'),
                index: index,
                dishData: dish,
                hideIngredients: hideIngredients,
              ),
            );
          },
        );
      },
    );
  }
}