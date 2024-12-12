import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/pagination/paginated_list_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/subscription_repository.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart';

class SubscriptionsList extends ConsumerWidget {
  const SubscriptionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    if (user == null) return const SizedBox();

    return PaginatedListView<Subscription>(
      provider: subscriptionsPaginationProvider(user.uid),
      emptyWidget: const Center(
        child: Text('No tienes suscripciones.'),
      ),
      itemBuilder: (context, subscription) => _SubscriptionCard(
        subscription: subscription,
        onConsumeMeal: () => _confirmAndConsumeMeal(context, ref, subscription),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onConsumeMeal;

  const _SubscriptionCard({
    required this.subscription,
    required this.onConsumeMeal,
    Key? key,
  }) : super(key: key);

  IconData _getPlanIcon() {
    switch (subscription.planName.toLowerCase()) {
      case 'basico':
        return Icons.emoji_food_beverage;
      case 'estandar':
        return Icons.local_cafe;
      case 'premium':
        return Icons.local_dining;
      default:
        return Icons.fastfood;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildPlanIcon(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                  child: _buildSubscriptionDetails(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanIcon() {
    return Icon(
      _getPlanIcon(),
      size: 80,
      color: ColorsPaletteRedonda.primary,
    );
  }

  Widget _buildSubscriptionDetails(BuildContext context) {
    return Column(
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
        _buildPrice(context),
        const SizedBox(height: 15),
        _buildActionButton(context),
      ],
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Text(
      'Total Price: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(subscription.totalAmount)}',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: ColorsPaletteRedonda.orange,
          ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final bool canConsume =
        subscription.isActive && subscription.mealsRemaining > 0;

    return ElevatedButton(
      onPressed: canConsume ? onConsumeMeal : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsPaletteRedonda.primary,
        foregroundColor: ColorsPaletteRedonda.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Text(
        canConsume ? 'Consume a Meal' : 'Inactive',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ColorsPaletteRedonda.white,
            ),
      ),
    );
  }
}

// Notification Service
class NotificationService {
  static const _sendGridApiKey = 'YOUR_SENDGRID_API_KEY';
  static const _fromEmail = 'your-app-email@example.com';

  static void showInAppNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.brown[200],
      duration: const Duration(milliseconds: 500),
    ));
  }

  static Future<void> sendEmailNotification({
    required String userEmail,
    required String subject,
    required String message,
  }) async {
    try {
      final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {'email': userEmail}
              ],
              'subject': subject,
            }
          ],
          'from': {'email': _fromEmail},
          'content': [
            {
              'type': 'text/plain',
              'value': message,
            }
          ],
        }),
      );

      if (response.statusCode != 202) {
        throw Exception('Failed to send email: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending email notification: $e');
    }
  }
}

Future<void> _confirmAndConsumeMeal(
    BuildContext context, WidgetRef ref, Subscription subscription) async {
  if (!subscription.isActive || subscription.mealsRemaining <= 0) {
    NotificationService.showInAppNotification(
      context,
      'Subscription is inactive or has no remaining meals.',
    );
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hacer Pedido'),
      content: const Text(
        'Estas seguro que deseas pedir un almuerzo de tu subscripcion?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      await ref
          .read(subscriptionsRepositoryProvider)
          .consumeMeal(subscription.id);

      if (context.mounted) {
        NotificationService.showInAppNotification(
          context,
          'Meal consumed successfully!',
        );
      }

      await NotificationService.sendEmailNotification(
        userEmail: subscription.id,
        subject: 'Meal Consumption Confirmation',
        message:
            'You have successfully consumed a meal from your subscription!',
      );
    } catch (error) {
      if (context.mounted) {
        NotificationService.showInAppNotification(
          context,
          'Failed to consume meal. $error',
        );
      }
    }
  }
}

// Add shimmer loading effect for better UX
class SubscriptionShimmer extends StatelessWidget {
  const SubscriptionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            height: 300,
            width: 280,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (index) => Container(
                      height: index == 0 ? 80 : 20,
                      width: index == 0 ? 80 : double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
