import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/presentation/pagination/paginated_list_widget.dart';
import 'package:starter_architecture_flutter_firebase/src/core/auth_services/subscription_repository.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';

class SubscriptionsList extends ConsumerWidget {
  const SubscriptionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    if (user == null) return const SizedBox();

    return PaginatedListView<Subscription>(
      provider: subscriptionsPaginationProvider(user.uid),
      emptyWidget: Center(
        child: Text(
          'No tienes suscripciones.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
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
    super.key,
  });

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Card(
          color: colorScheme.surfaceContainerHighest,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                _buildPlanIcon(colorScheme),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                  child: _buildSubscriptionDetails(context, theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanIcon(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Icon(
        _getPlanIcon(),
        size: 80,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildSubscriptionDetails(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Column(
      children: [
        Text(
          subscription.planName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Meals Remaining: ${subscription.mealsRemaining}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Order Date: ${subscription.orderDate}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        _buildPrice(context, theme),
        const SizedBox(height: 15),
        _buildActionButton(context, theme),
      ],
    );
  }

  Widget _buildPrice(BuildContext context, ThemeData theme) {
    return Text(
      'Total Price: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(subscription.totalAmount)}',
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ThemeData theme) {
    final bool canConsume =
        subscription.isActive && subscription.mealsRemaining > 0;
    final colorScheme = theme.colorScheme;

    return FilledButton(
      onPressed: canConsume ? onConsumeMeal : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        disabledBackgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        disabledForegroundColor: colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
      child: Text(
        canConsume ? 'Consume a Meal' : 'Inactive',
        style: theme.textTheme.labelLarge?.copyWith(
          color: canConsume ? colorScheme.onPrimary : null,
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
    final theme = Theme.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(color: theme.colorScheme.onInverseSurface),
      ),
      backgroundColor: theme.colorScheme.inverseSurface,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
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

  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'Hacer Pedido',
        style: theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      content: Text(
        'Estas seguro que deseas pedir un almuerzo de tu subscripcion?',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Cancelar',
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
        FilledButton(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
              elevation: 2,
              color: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                        color: colorScheme.onSurfaceVariant.withOpacity(0.1),
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
