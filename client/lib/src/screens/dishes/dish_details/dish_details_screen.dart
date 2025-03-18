import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:starter_architecture_flutter_firebase/src/core/providers/cart/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catalog/catalog_provider.dart'; // Add this import
import 'package:starter_architecture_flutter_firebase/src/core/services/catalog_service.dart'; 
import 'package:flutter_animate/flutter_animate.dart';

/// Enhanced Dish Details Screen with system theming support
class DishDetailsScreen extends ConsumerStatefulWidget {
  const DishDetailsScreen({super.key, required this.index});
  final int index;

  @override
  ConsumerState<DishDetailsScreen> createState() => _DishDetailsScreenState();
}

class _DishDetailsScreenState extends ConsumerState<DishDetailsScreen> {
  Map<String, dynamic>? selectedItem;
  int quantity = 1;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // We'll handle loading in the build method with AsyncValue
  }

  // Format price as currency
  String _formatPrice(dynamic price) {
    try {
      final double numPrice = double.tryParse(price.toString()) ?? 0.0;
      return '\$${numPrice.toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }

  // Calculate total price
  String _calculateTotal() {
    try {
      if (selectedItem == null) return '\$0.00';
      final double itemPrice = double.tryParse(selectedItem!['pricing'].toString()) ?? 0.0;
      return '\$${(itemPrice * quantity).toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }

  // Convert CatalogItem to Map<String, dynamic>
  Map<String, dynamic> _catalogItemToMap(CatalogItem item) {
    return {
      'id': item.id,
      'title': item.name,
      'description': item.description,
      'pricing': item.price,
      'img': item.imageUrl.isEmpty ? 'assets/appIcon.png' : item.imageUrl,
      'foodType': item.metadata['foodType'] ?? 'Main Course',
      'isSpicy': item.metadata['isSpicy'] ?? false,
      'ingredients': item.metadata['ingredients'] ?? ['Ingredient 1', 'Ingredient 2'],
      'nutritionalInfo': item.metadata['nutritionalInfo'],
    };
  }

  @override
  Widget build(BuildContext context) {
    // Access theme for colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Use catalogItemsProvider instead of dishProvider
    final dishesAsync = ref.watch(catalogItemsProvider('menu'));
    
    // Check for active subscriptions in the cart
    final cartItems = ref.watch(cartProvider);
    bool hasActiveSubscription = cartItems.items.any((item) => 
        item.isMealSubscription && item.remainingMeals > 0);

    return Scaffold(
      body: dishesAsync.when(
        data: (dishes) {
          if (dishes.isEmpty || widget.index >= dishes.length) {
            return _buildErrorState(theme, 'Dish not found. Please try again later.');
          }
          
          // Set the selected item
          selectedItem = _catalogItemToMap(dishes[widget.index]);
          
          return _buildDetailContent(hasActiveSubscription, theme);
        },
        loading: () => _buildLoadingState(colorScheme),
        error: (error, stackTrace) => _buildErrorState(
          theme, 
          'Error loading dish details: $error'
        ),
      ),
      bottomSheet: dishesAsync.maybeWhen(
        data: (dishes) {
          if (dishes.isEmpty || widget.index >= dishes.length) {
            return null;
          }
          return _buildBottomActionBar(hasActiveSubscription, theme);
        },
        orElse: () => null,
      ),
    );
  }

  // Loading state UI
  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: CircularProgressIndicator(
        color: colorScheme.primary,
      ),
    );
  }

  // Error state UI
  Widget _buildErrorState(ThemeData theme, [String? message]) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: theme.colorScheme.error,
            ).animate().scale(duration: 400.ms),
            const SizedBox(height: 16),
            Text(
              message ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Force refresh the provider
                ref.refresh(catalogItemsProvider('menu'));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Main detail content
  Widget _buildDetailContent(bool hasActiveSubscription, ThemeData theme) {
    if (selectedItem == null) {
      return _buildErrorState(theme, 'Dish information not available');
    }
    
    return CustomScrollView(
      slivers: [
        // App bar with image
        _buildSliverAppBar(theme),
        
        // Details content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100), // Space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and price section
                _buildTitlePriceSection(theme),
                
                // Description
                _buildDescriptionSection(theme),
                
                // Food type and spicy info
                _buildFoodTypeSection(theme),
                
                // Ingredients
                _buildIngredientsSection(theme),
                
                // Nutritional info (if available)
                if (selectedItem?.containsKey('nutritionalInfo') ?? false)
                  _buildNutritionalInfoSection(theme),
                
                // Serving suggestion
                _buildServingSuggestion(theme),
                
                // Reviews section
                _buildReviewsSection(theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Sliver app bar with dish image
  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'dish_image_${widget.index}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                selectedItem?['img'] ?? 'assets/images/placeholder_food.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      size: 50,
                    ),
                  );
                },
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Price badge
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatPrice(selectedItem?['pricing']),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.white, // Keep this white for visibility against image
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          color: Colors.white, // Keep this white for visibility against image
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Added to favorites'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: theme.colorScheme.secondary,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          color: Colors.white, // Keep this white for visibility against image
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Sharing not implemented'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: theme.colorScheme.secondary,
              ),
            );
          },
        ),
      ],
    );
  }

  // Title and price section
  Widget _buildTitlePriceSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedItem?['title'] ?? 'Untitled Dish',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(selectedItem?['pricing']),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          // Quantity selector
          Card(
            elevation: 2,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: theme.colorScheme.primary),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      quantity.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: theme.colorScheme.primary),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Description section
  Widget _buildDescriptionSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Descripción",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedItem?['description'] ?? 'No description available',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 200.ms)
    .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms);
  }

  // Food type section
  Widget _buildFoodTypeSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 18,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  selectedItem?['foodType'] ?? 'Unknown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (selectedItem?['isSpicy'] == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.whatshot,
                    size: 18,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Picante",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 300.ms)
    .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms);
  }

  // Ingredients section
  Widget _buildIngredientsSection(ThemeData theme) {
    final ingredients = selectedItem?['ingredients'] as List<dynamic>? ?? [];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Ingredientes",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List<Widget>.generate(
              ingredients.length,
              (index) => _buildIngredientChip(
                ingredients[index].toString(),
                index,
                theme,
              ),
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 400.ms)
    .moveY(begin: 20, end: 0, delay: 400.ms, duration: 400.ms);
  }

  // Ingredient chip
  Widget _buildIngredientChip(String ingredient, int index, ThemeData theme) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: Icon(
          Icons.check_circle,
          color: theme.colorScheme.tertiary,
          size: 16,
        ),
      ),
      label: Text(ingredient),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    )
    .animate()
    .fadeIn(delay: (50 * index).ms + 400.ms, duration: 400.ms)
    .scale(delay: (50 * index).ms + 400.ms, duration: 400.ms, begin: const Offset(0.8, 0.8));
  }

  // Nutritional info section (if available)
  Widget _buildNutritionalInfoSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Información Nutricional",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sample nutritional info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem('Calorías', '350 kcal', theme),
              _buildNutritionItem('Proteínas', '12g', theme),
              _buildNutritionItem('Grasas', '8g', theme),
              _buildNutritionItem('Carbos', '45g', theme),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 500.ms)
    .moveY(begin: 20, end: 0, delay: 500.ms, duration: 400.ms);
  }

  // Nutrition info item
  Widget _buildNutritionItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // Serving suggestion
  Widget _buildServingSuggestion(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Sugerencia de Servicio",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Este plato se sirve mejor caliente y puede acompañarse con una ensalada fresca o arroz para complementar.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 600.ms)
    .moveY(begin: 20, end: 0, delay: 600.ms, duration: 400.ms);
  }

  // Reviews section
  Widget _buildReviewsSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Opiniones de Clientes",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all reviews action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('View all reviews'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  );
                },
                child: Text(
                  "Ver Todas",
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Sample review
          _buildReviewItem(
            name: "María G.",
            rating: 5,
            comment: "Excelente plato, los ingredientes frescos y la presentación impecable. Lo recomiendo ampliamente.",
            date: "Hace 2 días",
            theme: theme,
          ),
          Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
          _buildReviewItem(
            name: "Carlos R.",
            rating: 4,
            comment: "Muy bueno, aunque podría tener un poco más de sabor. La porción es generosa.",
            date: "Hace 1 semana",
            theme: theme,
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms, delay: 700.ms)
    .moveY(begin: 20, end: 0, delay: 700.ms, duration: 400.ms);
  }

  // Review item
  Widget _buildReviewItem({
    required String name,
    required int rating,
    required String comment,
    required String date,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                radius: 16,
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom action bar
  Widget _buildBottomActionBar(bool hasActiveSubscription, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price and total
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _calculateTotal(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Add to cart or use subscription button
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () {
                  if (hasActiveSubscription) {
                    // Consume from subscription
                    ref.read(cartProvider.notifier).consumeMeal(selectedItem?['title'] ?? 'Unknown Item');
                  } else {
                    // Add to cart
                    ref.read(cartProvider.notifier).addToCart(selectedItem!, quantity);
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        hasActiveSubscription
                            ? 'Se consumió ${selectedItem?['title']} del plan'
                            : 'Se agregó ${selectedItem?['title']} al carrito',
                      ),
                      backgroundColor: theme.colorScheme.tertiary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                  
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  hasActiveSubscription ? 'Consumir del plan' : 'Agregar al carrito',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 500.ms, delay: 200.ms)
    .moveY(begin: 50, end: 0, delay: 200.ms, duration: 500.ms);
  }
}