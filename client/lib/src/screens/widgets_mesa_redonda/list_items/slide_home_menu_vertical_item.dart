import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

/// -----------------------------------------
/// MENU DISH CARD (VERTICAL)
/// -----------------------------------------
class MenuDishCard extends StatelessWidget {
  final String img;
  final String title;
  final String description;
  final String pricing;
  final String? offertPricing;
  final List<String> ingredients;
  final bool isSpicy;
  final String foodType; // e.g. "Vegan", "Meat"
  final bool isMealPlan;
  final int index;
  final Widget? actionButton;

  const MenuDishCard({
    super.key,
    required this.img,
    required this.title,
    required this.description,
    required this.pricing,
    this.offertPricing,
    required this.ingredients,
    required this.isSpicy,
    required this.foodType,
    this.isMealPlan = false,
    required this.index,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    // Enforce a minimum size for the card so it renders properly on all screens.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 300,  // Adjust as needed.
        minHeight: 250, // Adjust as needed.
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 3.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE SECTION AT THE TOP ---
            Stack(
              children: [
                // Use AspectRatio to have the image resize proportionally.
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9, // You can adjust the ratio if needed.
                    child: Image.network(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Handle favorite toggling.
                    },
                  ),
                ),
              ],
            ),
            // --- CONTENT SECTION BELOW THE IMAGE ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Optional row for labels (e.g. Spicy, Meal Plan, etc.)
                  Row(
                    children: [
                      if (isSpicy)
                        _buildLabel(Icons.whatshot, 'Spicy', Colors.red),
                      if (isMealPlan)
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: _buildLabel(Icons.fastfood, 'Meal Plan', Colors.blue),
                        ),
                      if (foodType.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: _buildLabel(
                            foodType.toLowerCase() == 'vegan'
                                ? Icons.eco
                                : Icons.restaurant,
                            foodType,
                            foodType.toLowerCase() == 'vegan' ? Colors.green : Colors.brown,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  // ---------- TITLE ----------
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  // ---------- DESCRIPTION ----------
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  // --- PRICE + ACTION BUTTON (e.g. Plus Icon) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPricing(context),
                      actionButton ??
                          IconButton(
                            icon: Icon(
                              Icons.add_circle, 
                            ),
                            onPressed: () {
                              // Default navigation: navigate to AddToOrder screen.
                              GoRouter.of(context).pushNamed(
                                AppRoute.addToOrder.name,
                                pathParameters: {"itemId": index.toString()},
                              );
                            },
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a small label.
  Widget _buildLabel(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the pricing display.
  Widget _buildPricing(BuildContext context) {
    if (offertPricing != null && offertPricing!.isNotEmpty) {
      return Row(
        children: [
          Text(
            'RD\$ $pricing',
            style: const TextStyle(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            'RD\$ $offertPricing',
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      );
    } else {
      return Text(
        'RD\$ $pricing',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      );
    }
  }
}