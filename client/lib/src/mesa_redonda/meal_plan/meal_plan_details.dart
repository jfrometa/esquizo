import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/meal_plan/meal_plan_cart.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import '../plans/plans.dart'; // Import your MealPlan model

class PlanDetailsScreen extends ConsumerWidget {
  final String planId;

  const PlanDetailsScreen({super.key, required this.planId});

  String cleanPrice(String input) {
    String cleaned = input.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.contains('.')) {
      List<String> parts = cleaned.split('.');
      cleaned = '${parts[0]}.${parts.skip(1).join('')}';
    }
    return cleaned;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mealPlans = ref.watch(mealPlansProvider);
    final mealPlan = mealPlans.firstWhere(
      (plan) => plan.id == planId,
      orElse: () => throw Exception('Plan not found'),
    );

    IconData planIcon;
    switch (mealPlan.id) {
      case 'basico':
        planIcon = Icons.emoji_food_beverage;
        break;
      case 'estandar':
        planIcon = Icons.local_cafe;
        break;
      case 'premium':
        planIcon = Icons.local_dining;
        break;
      default:
        planIcon = Icons.fastfood;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(mealPlan.title),
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              planIcon,
              size: 80,
              color: ColorsPaletteRedonda.primary,
            ),
            const SizedBox(height: 16),
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
                  Text(
                    mealPlan.longDescription,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add meal plan to meal orders
                        ref
                            .read(mealOrderProvider.notifier)
                            .addMealSubscription(
                          {
                            'id': mealPlan.id,
                            'img': '', // Provide image path if available
                            'title': mealPlan.title,
                            'description': 'Plan de comidas',
                            'pricing': cleanPrice(mealPlan.price),
                            'ingredients':
                                <String>[], // Ensure this is an empty List<String>
                            'isSpicy': false,
                            'foodType': 'Meal Plan',
                            'quantity': 1,
                          },
                          mealPlan.totalMeals,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('${mealPlan.title} añadido al carrito'),
                          ),
                        );

                        GoRouter.of(context).pop();
                        GoRouter.of(context).pop();
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
