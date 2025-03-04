import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/providers/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';

 
/// A unified food item card component.
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

  final String? offertPricing;
  final bool isMealPlan;
  final bool hideIngredients;
  final bool useHorizontalLayout;
  final double? fixedWidth;
  final double? fixedHeight;
  final VoidCallback? onAddToCart;
  final VoidCallback? onViewDetails;
  final bool showAddButton;
  final bool showDetailsButton;
  final bool useHeroAnimation;

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
    this.offertPricing,
    this.isMealPlan = false,
    this.hideIngredients = false,
    this.useHorizontalLayout = false,
    this.fixedWidth,
    this.fixedHeight,
    this.onAddToCart,
    this.onViewDetails,
    this.showAddButton = true,
    this.showDetailsButton = true,
    this.useHeroAnimation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    final cardContent = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surface,
      shadowColor: colorScheme.shadow.withOpacity(0.3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetails ?? () => _navigateToDetails(context),
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine if the incoming constraints are unbounded in height.
              final bool isUnbounded = constraints.maxHeight == double.infinity;
              // If fixedHeight is provided, use it; otherwise default to 280.
              final double effectiveHeight = fixedHeight ?? 280;
              final double boundedHeight = isUnbounded ? effectiveHeight : constraints.maxHeight;
              final useHorizontal = useHorizontalLayout || (!isSmallScreen && constraints.maxWidth > 400);
              return useHorizontal
                  ? _buildHorizontalLayout(context, theme, colorScheme, constraints, ref)
                  : SizedBox(
                      height: boundedHeight,
                      child: _buildVerticalLayout(context, theme, colorScheme, ref, boundedHeight),
                    );
            },
          ),
        ),
      ),
    );

    // If a fixedHeight is provided (desktop usage), force that height.
    // Otherwise, allow the widget to grow (for mobile ListView).
    return fixedHeight != null
        ? SizedBox(
            width: fixedWidth,
            height: fixedHeight,
            child: cardContent,
          )
        : Container(
            width: fixedWidth,
            constraints: BoxConstraints(minHeight: 280),
            child: cardContent,
          );
  }

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
        Container(
          width: constraints.maxWidth * 0.4,
          height: constraints.maxHeight,
          child: _buildImageSection(colorScheme, theme),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(theme, colorScheme),
                const SizedBox(height: 8),
                _buildDescriptionSection(theme, colorScheme),
                if (!hideIngredients && ingredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildIngredientsSection(theme, colorScheme),
                ],
                const Spacer(),
                _buildPricingSection(theme, colorScheme),
                const SizedBox(height: 12),
                _buildActionButtons(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    WidgetRef ref,
    double totalHeight,
  ) {
    final imageHeight = (totalHeight * (16 / 9)) / (1 + (16 / 9));
    final contentHeight = totalHeight - imageHeight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildImageSection(colorScheme, theme),
        ),
        SizedBox(
          // Let the content area grow if needed.
          height: contentHeight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(theme, colorScheme),
                const SizedBox(height: 8),
                _buildDescriptionSection(theme, colorScheme),
                if (!hideIngredients && ingredients.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildIngredientsSection(theme, colorScheme),
                ],
                const SizedBox(height: 8),
                _buildPricingSection(theme, colorScheme),
                const SizedBox(height: 12),
                _buildActionButtons(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(ColorScheme colorScheme, ThemeData theme) {
    final imageWidget = Image.asset(
      img,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: colorScheme.surfaceVariant,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 48,
            ),
          ),
        );
      },
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        useHeroAnimation
            ? Hero(tag: 'dish_image_$index', child: imageWidget)
            : imageWidget,
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
              stops: const [0.6, 1.0],
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSpicy)
                _buildBadge(
                  icon: Icons.whatshot,
                  text: 'Spicy',
                  backgroundColor: colorScheme.error.withOpacity(0.8),
                  textColor: colorScheme.onError,
                ),
              _buildBadge(
                icon: foodType.toLowerCase() == 'vegan' ? Icons.eco : Icons.restaurant,
                text: foodType,
                backgroundColor: foodType.toLowerCase() == 'vegan'
                    ? colorScheme.tertiary.withOpacity(0.8)
                    : colorScheme.secondary.withOpacity(0.8),
                textColor: foodType.toLowerCase() == 'vegan'
                    ? colorScheme.onTertiary
                    : colorScheme.onSecondary,
              ),
              if (isMealPlan)
                _buildBadge(
                  icon: Icons.fastfood,
                  text: 'Plan',
                  backgroundColor: colorScheme.primaryContainer.withOpacity(0.8),
                  textColor: colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

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

  Widget _buildIngredientsSection(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.kitchen, size: 16, color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            ingredients.join(', '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection(ThemeData theme, ColorScheme colorScheme) {
    if (offertPricing != null) {
      return Row(
        children: [
          Text(
            '\$$pricing',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$$offertPricing',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Text(
        '\$$pricing',
        style: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    if (!showDetailsButton && !showAddButton) return const SizedBox.shrink();
    return Row(
      children: [
        if (showDetailsButton)
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.remove_red_eye, size: 16),
              label: const Text('Detalles'),
              onPressed: onViewDetails ?? () => _navigateToDetails(context),
            ),
          ),
        if (showDetailsButton && showAddButton) const SizedBox(width: 8),
        if (showAddButton)
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.add_shopping_cart, size: 16),
              label: const Text('Agregar'),
              onPressed: onAddToCart ?? () => _addItemToCart(context, ref),
            ),
          ),
      ],
    );
  }

  void _navigateToDetails(BuildContext context) {
    GoRouter.of(context).goNamed(
      AppRoute.addToOrder.name,
      pathParameters: {"itemId": index.toString()},
      extra: dishData,
    );
  }

  void _addItemToCart(BuildContext context, WidgetRef ref) {
    ref.read(cartProvider.notifier).addToCart(dishData, 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title agregado al carrito'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

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

/// A horizontal scrollable food list
class HorizontalDishList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String title;
  final VoidCallback? onViewAll;
  final double itemWidth;
  final double itemHeight;
  final bool hideIngredients;
  
  const HorizontalDishList({
    super.key,
    required this.items,
    required this.title,
    this.onViewAll,
    this.itemWidth = 300,
    this.itemHeight = 350,
    this.hideIngredients = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with title and "View All" button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'Ver Todos',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Container with fixed height to ensure proper layout
        Container(
          height: itemHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              // Wrap in Container with fixed width
              return Container(
                margin: const EdgeInsets.only(right: 16),
                width: itemWidth,
                height: itemHeight,
                child: DishItem(
                  img: item["img"] ?? '',
                  title: item["title"] ?? 'Unknown Item',
                  description: item["description"] ?? '',
                  pricing: item["pricing"] ?? '0',
                  offertPricing: item["offertPricing"],
                  ingredients: item["ingredients"] != null 
                      ? List<String>.from(item["ingredients"]) 
                      : [],
                  isSpicy: item["isSpicy"] ?? false,
                  foodType: item["foodType"] ?? 'Regular',
                  isMealPlan: item["isMealPlan"] ?? false,
                  key: ValueKey('horizontal_item_$index'),
                  index: index,
                  dishData: item,
                  hideIngredients: hideIngredients,
                  fixedWidth: itemWidth,
                  fixedHeight: itemHeight,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Helper for displaying dishes in a horizontal slider with proper titles
class DishSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final VoidCallback? onViewAll;
  final double height;
  
  const DishSection({
    super.key,
    required this.title,
    required this.items,
    this.onViewAll,
    this.height = 350,
  });
  
  @override
  Widget build(BuildContext context) {
    // Explicitly sized container to prevent layout issues
    return Container(
      width: double.infinity,
      height: height + 70, // Account for header
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HorizontalDishList(
            title: title,
            items: items,
            onViewAll: onViewAll,
            itemHeight: height,
          ),
        ],
      ),
    );
  }
}

/// Fixed widget for displaying dish items in a vertical list
/// This solves the error with Padding in ListView items
class DishListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final EdgeInsetsGeometry padding;
  final double height;
  
  const DishListItem({
    super.key,
    required this.item,
    required this.index,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.height = 280,
  });
  
  @override
  Widget build(BuildContext context) {
    // Using SizedBox with fixed height to prevent layout issues
    return SizedBox(
      height: height,
      child: Padding(
        padding: padding,
        child: DishItem(
          img: item["img"] ?? '',
          title: item["title"] ?? 'Unknown Item',
          description: item["description"] ?? '',
          pricing: item["pricing"] ?? '0',
          offertPricing: item["offertPricing"],
          ingredients: item["ingredients"] != null 
              ? List<String>.from(item["ingredients"]) 
              : [],
          isSpicy: item["isSpicy"] ?? false,
          foodType: item["foodType"] ?? 'Regular',
          isMealPlan: item["isMealPlan"] ?? false,
          key: ValueKey('dish_list_item_$index'),
          index: index,
          dishData: item,
          fixedHeight: height,
        ),
      ),
    );
  }
}