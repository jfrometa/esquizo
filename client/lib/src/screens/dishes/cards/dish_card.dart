import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/cart/cart_service.dart';
import 'package:starter_architecture_flutter_firebase/src/extensions/firebase_analitics.dart';

class DishCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> dish;
  final VoidCallback? onTap;

  const DishCard({
    super.key,
    required this.dish,
    this.onTap,
  });

  @override
  ConsumerState<DishCard> createState() => _DishCardState();
}

class _DishCardState extends ConsumerState<DishCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    isHovered ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate if dish is popular (rating >= 4.5)
    final isPopular = (widget.dish['rating'] != null &&
        (widget.dish['rating'] is double || widget.dish['rating'] is int) &&
        widget.dish['rating'] >= 4.5);

    // Check if dish has bestSeller flag
    final isBestSeller = widget.dish['bestSeller'] ?? false;

    // Handle image source - could be 'image' or 'img' key
    final imageUrl = widget.dish['image'] ?? widget.dish['img'];

    // Handle price - could be 'price' or 'pricing' key
    final price = widget.dish['price'] ?? widget.dish['pricing'] ?? 0.00;
    final formattedPrice =
        price is double ? price.toStringAsFixed(2) : price.toString();

    // Handle offer pricing if available
    final hasOffer = widget.dish['offertPricing'] != null;
    final offerPrice =
        hasOffer ? widget.dish['offertPricing'].toString() : null;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: () {
          // Track view item analytics event
          AnalyticsService.instance.logViewItem(
            itemId: widget.dish['id'] ?? '',
            itemName: widget.dish['title'] ?? '',
            price: double.tryParse(formattedPrice) ?? 0.0,
            itemCategory: widget.dish['foodType'] ?? '',
          );

          // Call the onTap callback
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left side: Image container
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Food image
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 40,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.restaurant,
                                  size: 40,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),

                      // Badge: Popular or Best Seller
                      if (isPopular || isBestSeller)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isBestSeller
                                  ? colorScheme.tertiary
                                  : colorScheme.secondary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isBestSeller
                                      ? Icons.workspace_premium
                                      : Icons.local_fire_department,
                                  size: 12,
                                  color: isBestSeller
                                      ? colorScheme.onTertiary
                                      : colorScheme.onSecondary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  isBestSeller ? 'Best Seller' : 'Popular',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isBestSeller
                                        ? colorScheme.onTertiary
                                        : colorScheme.onSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Right side: Content container
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and rating row
                        Row(
                          children: [
                            // Dish name
                            Expanded(
                              child: Text(
                                widget.dish['title'] ?? 'Sin título',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Rating badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${widget.dish['rating'] ?? "4.5"}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Description
                        Text(
                          widget.dish['description'] ?? 'Sin descripción',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Spacer(),

                        // Price and add to cart row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price section with possible discount
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasOffer)
                                  Text(
                                    'S/ $formattedPrice',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Text(
                                  'S/ ${offerPrice ?? formattedPrice}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            // Add to cart button
                            InkWell(
                              onTap: () {
                                // Add to cart
                                ref.read(cartProvider.notifier).addToCart(
                                      widget.dish,
                                      1,
                                    );

                                // Track add to cart analytics
                                AnalyticsService.instance.logAddToCart(
                                  items: [
                                    AnalyticsEventItem(
                                      itemId: widget.dish['id'] ?? '',
                                      itemName: widget.dish['title'] ?? '',
                                      itemCategory:
                                          widget.dish['foodType'] ?? '',
                                      price: double.tryParse(formattedPrice) ??
                                          0.0,
                                      quantity: 1,
                                    ),
                                  ],
                                  value: double.tryParse(formattedPrice) ?? 0.0,
                                );

                                // Show confirmation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${widget.dish['title']} Agregado al carrito'),
                                    duration: const Duration(milliseconds: 700),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isHovered
                                      ? colorScheme.primary
                                      : colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _isHovered
                                        ? Colors.transparent
                                        : colorScheme.primary,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add_shopping_cart,
                                      size: 16,
                                      color: _isHovered
                                          ? colorScheme.onPrimary
                                          : colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Agregar",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _isHovered
                                            ? colorScheme.onPrimary
                                            : colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
