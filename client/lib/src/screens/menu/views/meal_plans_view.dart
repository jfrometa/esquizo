import 'package:flutter/material.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/subscriptions/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/widgets/meal_plan_card.dart';

// MEAL PLANS VIEW
class MealPlansView extends ConsumerWidget {
  final ScrollController scrollController;

  const MealPlansView({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mealPlansAsync = ref.watch(mealPlansProvider);
    
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Header
        Text(
          'Nuestros Planes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Comidas saludables y balanceadas entregadas a tu puerta',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        
        // Meal plans list
        mealPlansAsync.when(
          data: (mealPlans) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mealPlans.length,
              itemBuilder: (context, index) {
                final plan = mealPlans[index];
                return MealPlanCard(plan: plan);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Center(
            child: Text('Failed to load meal plans: $error'),
          ),
        ),
      ],
    );
  }
}
