import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/plans/plans.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';

import '../cart/cart_item.dart';

class MealPlansScreen extends ConsumerWidget {
  const MealPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlans = ref.watch(mealPlansProvider);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('Subscripciones'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.shopping_cart),
        //     onPressed: () {
        //       // Navigate to cart screen (implement separately)
        //       // context.goNamed('carrito'); // Example: Navigate to the cart page
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200, // Set the max width for the grid or list
              minWidth: 300, // Set a minimum width to prevent overflow issues
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Larger Screen Layout - GridView
                  return _buildPlansGrid(context, mealPlans);
                } else {
                  // Smaller Screen Layout - ListView
                  return _buildPlansList(context, mealPlans);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlansGrid(BuildContext context, List<MealPlan> mealPlans) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: mealPlans.length,
      itemBuilder: (context, index) {
        final mealPlan = mealPlans[index];
        return MealPlanCard(mealPlan: mealPlan);
      },
    );
  }

  Widget _buildPlansList(BuildContext context, List<MealPlan> mealPlans) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mealPlans.length,
      itemBuilder: (context, index) {
        final mealPlan = mealPlans[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: MealPlanCard(mealPlan: mealPlan),
        );
      },
    );
  }
}

class MealPlanCard extends ConsumerWidget {
  final MealPlan mealPlan;

  const MealPlanCard({super.key, required this.mealPlan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 250,
        maxWidth: 300,
        maxHeight: 300,
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: mealPlan.isBestValue
                ? ColorsPaletteRedonda.primary
                : ColorsPaletteRedonda.softBrown,
            width: mealPlan.isBestValue ? 2 : 1.0,
          ),
        ),
        color: mealPlan.isBestValue
            ? ColorsPaletteRedonda.softBrown
            : ColorsPaletteRedonda.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mealPlan.isBestValue)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: ColorsPaletteRedonda.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Mejor Valor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                mealPlan.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorsPaletteRedonda.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                mealPlan.price,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorsPaletteRedonda.primary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mealPlan.features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: ColorsPaletteRedonda.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: ColorsPaletteRedonda.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addToCart(
                      {
                        'img': '',
                        'title': mealPlan.title,
                        'description': 'Plan de comidas',
                        'pricing': mealPlan.price,
                        'offertPricing': null,
                        'ingredients': [],
                        'isSpicy': false,
                        'foodType': 'Meal Plan'
                      },
                      1,
                      isMealSubscription: true,
                      totalMeals: mealPlan.features.contains('13 comidas')
                          ? 13
                          : mealPlan.features.contains('10 comidas')
                              ? 10
                              : 8,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${mealPlan.title} añadido al carrito'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPaletteRedonda.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Agregar al carrito',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
