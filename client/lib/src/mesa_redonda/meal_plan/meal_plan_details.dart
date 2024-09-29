import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import '../plans/plans.dart'; // Import your MealPlan model
import '../cart/cart_item.dart'; // Import your cart provider

class PlanDetailsScreen extends ConsumerWidget {
  final String planId;

  const PlanDetailsScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mealPlans = ref.watch(mealPlansProvider);
    final mealPlan = mealPlans.firstWhere(
      (plan) => plan.id == planId,
      orElse: () => throw Exception('Plan not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(mealPlan.title),
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Plan Image
            Image.asset(
              mealPlan.img,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            // Plan Title and Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealPlan.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorsPaletteRedonda.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mealPlan.price,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: ColorsPaletteRedonda.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Plan Description
                  Text(
                    mealPlan.longDescription,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  // How It Works Section
                  Text(
                    '¿Cómo funciona?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mealPlan.howItWorks,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  // Features List
                  Text(
                    'Características:',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: mealPlan.features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: ColorsPaletteRedonda.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add meal plan to cart
                        ref.read(cartProvider.notifier).addToCart(
                          {
                            'img': mealPlan.img,
                            'title': mealPlan.title,
                            'description': 'Plan de comidas',
                            'pricing': mealPlan.price,
                            'offertPricing': null,
                            'ingredients': [],
                            'isSpicy': false,
                            'foodType': 'Meal Plan',
                          },
                          1,
                          isMealSubscription: true,
                          totalMeals: mealPlan.totalMeals,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${mealPlan.title} añadido al carrito'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsPaletteRedonda.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Agregar al carrito',
                        style: TextStyle(
                          color: ColorsPaletteRedonda.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
