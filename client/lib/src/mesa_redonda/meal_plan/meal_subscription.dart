import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/plans/plans.dart';

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
        title: const Text('Meal Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart screen (implement separately)
              context.goNamed('homecart');  // Example: Navigate to the cart page
            },
          ),
        ],
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Plans')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('8 Meal Plan'),
            subtitle: const Text('8 meals over 40 days'),
            trailing: ElevatedButton(
              onPressed: () {
                final dish = {
                  'img': 'assets/meal_plan_8.jpeg',
                  'title': '8 Meal Plan',
                  'description': '8 meals over 40 days',
                  'pricing': '3500',
                  'offertPricing': null,
                  'ingredients': [],
                  'isSpicy': false,
                  'foodType': 'Subscription',
                };

                // Add meal plan to the cart
                ref.read(cartProvider.notifier).addToCart(dish, 1, isMealSubscription: true, totalMeals: 8);
              },
              child: const Text('Subscribe'),
            ),
          ),
          ListTile(
            title: const Text('10 Meal Plan'),
            subtitle: const Text('10 meals over 40 days'),
            trailing: ElevatedButton(
              onPressed: () {
                final dish = {
                  'img': 'assets/meal_plan_10.jpeg',
                  'title': '10 Meal Plan',
                  'description': '10 meals over 40 days',
                  'pricing': '4500',
                  'offertPricing': null,
                  'ingredients': [],
                  'isSpicy': false,
                  'foodType': 'Subscription',
                };

                // Add meal plan to the cart
                ref.read(cartProvider.notifier).addToCart(dish, 1, isMealSubscription: true, totalMeals: 10);
              },
              child: const Text('Subscribe'),
            ),
          ),
        ],
      ),
    );
  }
