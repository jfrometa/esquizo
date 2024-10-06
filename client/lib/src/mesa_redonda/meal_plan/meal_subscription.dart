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
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    // Navigate to the cart screen
                    // context.push('/cart'); // Assuming the cart route is '/cart'
                    context.goNamed(
                      AppRoute.homecart.name,
                    );
                  },
                ),
                if (cart.isNotEmpty)
                  Positioned(
                    top: 0, // Adjusts the vertical position of the badge
                    right: 0, // Adjusts the horizontal position of the badge
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cart.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
    IconData planIcon;
    switch (mealPlan.id) {
      case 'basico':
        planIcon = Icons.emoji_food_beverage; // Represents basic plan
        break;
      case 'estandar':
        planIcon = Icons.local_cafe; // Represents standard plan
        break;
      case 'premium':
        planIcon = Icons.local_dining; // Represents premium plan
        break;
      default:
        planIcon = Icons.fastfood;
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        color: ColorsPaletteRedonda.softBrown,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              // Plan Image
              // Plan Icon
              Icon(
                planIcon,
                size: 80,
                color: ColorsPaletteRedonda.primary,
              ),
              // Plan Information
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
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
      ),
    );
  }
}
