import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';

class MealPlanCard extends StatelessWidget {
  final MealPlan plan;

  const MealPlanCard({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getPlanIcon(plan.status),
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'S/ ${plan.price}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              plan.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Navigate to plan details
                    context.goNamed(
                      AppRoute.planDetails.name,
                      pathParameters: {'planId': plan.id},
                    );
                  },
                  child: const Text('View Details'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to customer meal plan screen
                      context.goNamed(
                        AppRoute.mealPlan.name,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text('Subscribe'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getPlanIcon(MealPlanStatus plan) {
    switch (plan) {
      case MealPlanStatus.active:
        return Icons.emoji_food_beverage;
      case MealPlanStatus.discontinued:
        return Icons.local_cafe;
      case MealPlanStatus.inactive:
        return Icons.local_dining;
      // default:
      //   return Icons.food_bank;
    }
  }
}