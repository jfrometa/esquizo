import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

// Enum for badge positioning
enum BadgePosition { topLeft, topRight }

class DishCardSmall extends StatelessWidget {
  final Map<dynamic, dynamic> dish;
  final VoidCallback? onAddToCart;

  const DishCardSmall({
    super.key,
    required this.dish,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Extract dish properties once at the beginning
    final title = dish['title'] ?? 'Untitled Dish';
    final description = dish['description'] ?? 'No description available';
    final price = dish['pricing'] ?? '0.00';
    final offerPrice = dish['offertPricing'];
    final isSpicy = dish['isSpicy'] ?? false;
    final foodType = dish['foodType'] ?? '';
    final bestSeller = dish['bestSeller'] ?? false;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.goNamedSafe(
            AppRoute.addToOrder.name,
            pathParameters: {"itemId": "0"},
            extra: dish,
          );
        },
        child: SizedBox(
          width: double.infinity,
          // Use ConstrainedBox to ensure the card doesn't overflow
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image container with badges
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      if (bestSeller)
                        _buildBadge(
                          theme: theme,
                          text: 'Best Seller',
                          color: colorScheme.secondary,
                          textColor: colorScheme.onSecondary,
                          position: BadgePosition.topLeft,
                        ),
                      if (isSpicy) _buildSpicyIndicator(theme),
                    ],
                  ),
                ),

                // Dish details - use fixed heights to prevent overflow
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleRow(theme, title, foodType),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 32, // Reduced height to prevent overflow
                        child: Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPriceRow(theme, price, offerPrice),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extract repeated widgets to methods for better readability and maintenance
  Widget _buildTitleRow(ThemeData theme, String title, String foodType) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (foodType.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              foodType,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceRow(ThemeData theme, String price, dynamic offerPrice) {
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (offerPrice != null)
              Text(
                'S/ $price',
                style: theme.textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            Text(
              'S/ ${offerPrice ?? price}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.add_circle,
            color: colorScheme.primary,
          ),
          onPressed: onAddToCart,
          tooltip: 'Add to cart',
        ),
      ],
    );
  }

  Widget _buildBadge({
    required ThemeData theme,
    required String text,
    required Color color,
    required Color textColor,
    required BadgePosition position,
  }) {
    return Positioned(
      top: 8,
      left: position == BadgePosition.topLeft ? 8 : null,
      right: position == BadgePosition.topRight ? 8 : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSpicyIndicator(ThemeData theme) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.whatshot,
          color: theme.colorScheme.error,
          size: 16,
        ),
      ),
    );
  }
}
