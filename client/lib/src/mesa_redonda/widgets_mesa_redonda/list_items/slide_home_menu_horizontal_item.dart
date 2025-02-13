import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

/// -----------------------------------------
/// MENU DISH CARD (HORIZONTAL)
/// -----------------------------------------
class MenuDishCardHorizontal extends StatelessWidget {
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

  // Optional fields for "Más vendido" and rating
  final bool bestSeller;
  final double? rating; // e.g. 80 for "80% (24)"

  const MenuDishCardHorizontal({
    Key? key,
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
    this.bestSeller = false,
    this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the entire card in a ConstrainedBox to ensure a minimum size,
    // then wrap the Row in IntrinsicHeight so that both children have a bounded height.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 300,  // Adjust as needed for legibility.
        minHeight: 150, // Adjust as needed.
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 2.0,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // ---------- TEXT SECTION (LEFT) ----------
              Expanded(
                flex: 3,
                child: _buildTextSection(context),
              ),
              // ---------- IMAGE SECTION (RIGHT) ----------
              Expanded(
                flex: 2,
                child: _buildImageSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- TOP ROW: "Más vendido" + Rating ----------
          Row(
            children: [
              if (bestSeller)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorsPaletteRedonda.primary,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Text(
                    'Más vendido',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (bestSeller && rating != null) const SizedBox(width: 8),
              if (rating != null)
                Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rating!.toStringAsFixed(0)}% (24)', // e.g. "80% (24)"
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 6.0),
          // ---------- TITLE ----------
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6.0),
          // ---------- DESCRIPTION ----------
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10.0),
          // ---------- PRICE + (Optional) OFFER PRICE + ACTION BUTTON ----------
          Row(
            children: [
              _buildPricing(context),
              const Spacer(),
              if (actionButton != null) actionButton!,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    // Using a ConstrainedBox ensures the image doesn't get too narrow.
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: Stack(
        children: [
          // The ClipRRect now wraps an image that uses SizedBox.expand()
          // to fill its parent's (the row's) available height.
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
            ),
            child: SizedBox.expand(
              child: Image.network(
                img,
                fit: BoxFit.cover,
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
                // handle "favorite" logic
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricing(BuildContext context) {
    if (offertPricing != null && offertPricing!.isNotEmpty) {
      return Row(
        children: [
          Text(
            'RD\$ $pricing',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'RD\$ $offertPricing',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Text(
        'RD\$ $pricing',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}