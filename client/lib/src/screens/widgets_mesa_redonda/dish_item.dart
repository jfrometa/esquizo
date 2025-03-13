import 'package:flutter/material.dart';

class DishItem extends StatelessWidget {
  final Key? key;
  final int index;
  final String img;
  final String title;
  final String description;
  final String pricing;
  final List<String> ingredients;
  final bool isSpicy;
  final String foodType;
  final Map<String, dynamic> dishData;
  final bool hideIngredients;
  final bool showDetailsButton;
  final bool showAddButton;
  final bool useHorizontalLayout;

  const DishItem({
    required this.key,
    required this.index,
    required this.img,
    required this.title,
    required this.description,
    required this.pricing,
    required this.ingredients,
    required this.isSpicy,
    required this.foodType,
    required this.dishData,
    this.hideIngredients = false,
    this.showDetailsButton = false,
    this.showAddButton = false,
    this.useHorizontalLayout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Define the card content - using LayoutBuilder to get constraints
    Widget cardContent = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Title and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    pricing,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                description,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Ingredients if not hidden
              if (!hideIngredients) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: ingredients.map((ingredient) {
                    return Chip(
                      label: Text(
                        ingredient,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                        ),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
                    );
                  }).toList(),
                ),
              ],
              
              // Buttons - no Spacer in scrollable column
              SizedBox(height: 12),
              
              // Buttons
              if (showDetailsButton || showAddButton) ...[
                Row(
                  children: [
                    if (showDetailsButton)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Detalles'),
                        ),
                      ),
                    if (showDetailsButton && showAddButton)
                      const SizedBox(width: 8),
                    if (showAddButton)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Pedir'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      }
    );
    
    // Use a different layout for horizontal mode
    if (useHorizontalLayout) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 120),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image on the left
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 24,
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Content on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Important to prevent expansion
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Text(
                            pricing,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        description,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // const Spacer(),
                      const SizedBox(height: 12,),
                      
                      // Action buttons
                      if (showAddButton)
                        SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.add_shopping_cart, size: 14),
                            label: const Text('Pedir'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Regular card layout for vertical layout
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: hideIngredients ? 260 : 320,
          maxHeight: hideIngredients ? 320 : 400,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: cardContent,
        ),
      ),
    );
  }
}