import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final mealPlansProvider = Provider<List<MealPlan>>((ref) {
  return [
    MealPlan(
      title: "Basic",
      price: "\$9.99 / month",
      features: [
        "1 user",
        "2 meals per day",
        "Simple recipes",
        "Email support"
      ],
    ),
    MealPlan(
      title: "Standard",
      price: "\$19.99 / month",
      features: [
        "2 users",
        "3 meals per day",
        "Advanced recipes",
        "Priority support"
      ],
      isBestValue: true,
    ),
    MealPlan(
      title: "Premium",
      price: "\$29.99 / month",
      features: [
        "5 users",
        "5 meals per day",
        "Exclusive recipes",
        "Personal coaching"
      ],
    ),
  ];
});

class MealPlan {
  final String title;
  final String price;
  final List<String> features;
  final bool isBestValue;

  MealPlan({
    required this.title,
    required this.price,
    required this.features,
    this.isBestValue = false,
  });
}

class MealPlanCard extends StatelessWidget {
  final MealPlan mealPlan;

  const MealPlanCard({super.key, required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 450,
        maxHeight: 550, // Maximum height for the card
      ),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
            color: mealPlan.isBestValue ? Colors.green : Colors.grey.shade300,
            width: mealPlan.isBestValue ? 3 : 1.5,
          ),
        ),
        color: mealPlan.isBestValue ? Colors.green.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mealPlan.isBestValue)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Best Value',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color:
                        mealPlan.isBestValue ? Colors.green : Colors.blueAccent,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      mealPlan.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 28, // Increased font size for title
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.blueAccent,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    mealPlan.price,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.featured_play_list,
                    color: Colors.blueAccent,
                    size: 25,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Features:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mealPlan.features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              // Delivery Info
              Row(
                children: [
                  const Icon(Icons.local_shipping, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(
                    'Delivery expenses will be added',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle button actions
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mealPlan.isBestValue
                        ? Colors.green.shade700
                        : Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    mealPlan.isBestValue ? 'Try for free' : 'Buy now',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
              // Handle cart action
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
