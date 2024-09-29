import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/plans/plans.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
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

class MealPlanCard extends StatelessWidget {
  final MealPlan mealPlan;

  const MealPlanCard({super.key, required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        color: ColorsPaletteRedonda.softBrown,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Column(
          children: [
            // Plan Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                mealPlan.img,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Plan Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                children: [
                  Text(
                    mealPlan.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mealPlan.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mealPlan.price,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: ColorsPaletteRedonda.orange,
                        ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the plan details screen
                      GoRouter.of(context).goNamed(
                        AppRoute.planDetails.name,
                        pathParameters: {'planId': mealPlan.id},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsPaletteRedonda.primary,
                      foregroundColor: ColorsPaletteRedonda.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'Seleccionar Plan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: ColorsPaletteRedonda.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
