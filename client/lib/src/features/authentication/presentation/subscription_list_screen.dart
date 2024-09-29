import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/subscription_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart';

class SubscriptionsList extends ConsumerWidget {
  const SubscriptionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);

    return subscriptionsAsync.when(
      data: (subscriptions) {
        if (subscriptions.isEmpty) {
          return const Text('You have no subscriptions.');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final subscription = subscriptions[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: Sizes.p8),
              child: ListTile(
                title: Text(subscription.planName),
                subtitle:
                    Text('Meals Remaining: ${subscription.mealsRemaining}'),
                trailing: ElevatedButton(
                  onPressed: subscription.mealsRemaining > 0
                      ? () => _consumeMeal(context, ref, subscription)
                      : null,
                  child: const Text('Consume a Meal'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        // Handle error
        return const Text('Failed to load subscriptions.');
      },
    );
  }

  Future<void> _consumeMeal(
      BuildContext context, WidgetRef ref, Subscription subscription) async {
    try {
      await ref
          .read(subscriptionsRepositoryProvider)
          .consumeMeal(subscription.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal consumed successfully!')),
      );
    } catch (e) {
      // Handle error consuming meal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to consume meal.')),
      );
    }
  }
}
