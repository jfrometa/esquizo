import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/subscription_repository.dart';


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart';

Future<void> _confirmAndConsumeMeal(
    BuildContext context, WidgetRef ref, Subscription subscription) async {
  // Check if subscription is active and has remaining meals
  if (!subscription.isActive || subscription.mealsRemaining <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscription is inactive or has no remaining meals.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Ask for confirmation
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm Consumption'),
      content: const Text('Do you want to consume a meal from your subscription?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );

  // If user confirmed, proceed with meal consumption
  if (confirmed == true) {
    try {
      await ref.read(subscriptionsRepositoryProvider).consumeMeal(subscription.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal consumed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Send notifications (in-app and email)
      _sendNotification(
        context,
        userEmail: subscription.id,
        message: 'You have successfully consumed a meal from your subscription!',
        subject: 'Meal Consumption Confirmation',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to consume meal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

void _sendNotification(BuildContext context, {required String userEmail, required String message, required String subject}) {
  // In-app notification
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );

  // Send email notification
  _sendEmailNotification(userEmail, subject, message);
}

Future<void> _sendEmailNotification(String userEmail, String subject, String message) async {
  const sendGridApiKey = 'YOUR_SENDGRID_API_KEY';
  const fromEmail = 'your-app-email@example.com';

  final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');
  final emailPayload = {
    'personalizations': [
      {
        'to': [
          {'email': userEmail}
        ],
        'subject': subject,
      }
    ],
    'from': {'email': fromEmail},
    'content': [
      {
        'type': 'text/plain',
        'value': message,
      }
    ],
  };

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $sendGridApiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(emailPayload),
  );

  if (response.statusCode == 202) {
    debugPrint('Email sent successfully');
  } else {
    debugPrint('Failed to send email: ${response.body}');
  }
}
class SubscriptionsList extends ConsumerWidget {
  const SubscriptionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);

    return subscriptionsAsync.when(
      data: (subscriptions) {
        if (subscriptions.isEmpty) return const Text('No tienes suscripciones.');
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subscriptions.length,
          itemBuilder: (context, index) {
            final subscription = subscriptions[index];
            IconData planIcon;

            // Assign icon based on plan name
            switch (subscription.planName.toLowerCase()) {
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

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                  color: ColorsPaletteRedonda.softBrown,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      children: [
                        // Plan Icon
                        Icon(
                          planIcon,
                          size: 80,
                          color: ColorsPaletteRedonda.primary,
                        ),
                        // Plan Information
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                          child: Column(
                            children: [
                              Text(
                                subscription.planName,
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Meals Remaining: ${subscription.mealsRemaining}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Order Date: ${subscription.orderDate}',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Total Price: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(subscription.totalAmount)}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: ColorsPaletteRedonda.orange,
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: subscription.isActive && subscription.mealsRemaining > 0
                                    ? () => _confirmAndConsumeMeal(context, ref, subscription)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsPaletteRedonda.primary,
                                  foregroundColor: ColorsPaletteRedonda.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Text(
                                  subscription.isActive && subscription.mealsRemaining > 0
                                      ? 'Consume a Meal'
                                      : 'Inactive',
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
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Text('Failed to load subscriptions.'),
    );
  }
}