import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/subscriptions/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';

class AdminMealPlanCard extends ConsumerWidget {
  final MealPlan mealPlan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminMealPlanCard({
    super.key,
    required this.mealPlan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status indicator
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      mealPlan.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusIndicator(context),
                ],
              ),
            ),

            // Image
            if (mealPlan.img.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  mealPlan.img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 32),
                    ),
                  ),
                ),
              )
            else
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and best value tag
                  Row(
                    children: [
                      Text(
                        '\$${mealPlan.price}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (mealPlan.originalPrice > 0 &&
                          double.parse(mealPlan.price) < mealPlan.originalPrice)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '\$${mealPlan.originalPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (mealPlan.isBestValue)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Best Value',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    mealPlan.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 16),

                  // Meal count
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${mealPlan.totalMeals} meals total',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Category
                  if (mealPlan.categoryName.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mealPlan.categoryName,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Owner info if available
                  if (mealPlan.ownerName.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mealPlan.ownerName,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Expiry date if set
                  if (mealPlan.expiryDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: mealPlan.isExpired
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expires: ${DateFormat.yMMMd().format(mealPlan.expiryDate!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: mealPlan.isExpired
                                ? theme.colorScheme.error
                                : null,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Progress bar for meals used
                  _buildMealProgressBar(context),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Toggle availability button
                      IconButton(
                        icon: Icon(
                          mealPlan.isAvailable
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: mealPlan.isAvailable
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                        ),
                        onPressed: () => _toggleAvailability(context, ref),
                        tooltip: mealPlan.isAvailable
                            ? 'Mark as unavailable'
                            : 'Mark as available',
                      ),

                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onEdit,
                        tooltip: 'Edit',
                      ),

                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final String statusText;
    final Color statusColor;

    if (!mealPlan.isAvailable) {
      statusText = 'Unavailable';
      statusColor = Colors.grey;
    } else if (mealPlan.isExpired) {
      statusText = 'Expired';
      statusColor = Colors.red;
    } else {
      switch (mealPlan.status) {
        case MealPlanStatus.active:
          statusText = 'Active';
          statusColor = Colors.green;
          break;
        case MealPlanStatus.inactive:
          statusText = 'Inactive';
          statusColor = Colors.orange;
          break;
        case MealPlanStatus.discontinued:
          statusText = 'Discontinued';
          statusColor = Colors.red;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMealProgressBar(BuildContext context) {
    final theme = Theme.of(context);
    final totalMeals = mealPlan.totalMeals;
    final usedMeals = mealPlan.totalMeals - mealPlan.mealsRemaining;
    final progress = totalMeals > 0 ? usedMeals / totalMeals : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meals remaining: ${mealPlan.mealsRemaining}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '$usedMeals/$totalMeals used',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Future<void> _toggleAvailability(BuildContext context, WidgetRef ref) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.toggleMealPlanAvailability(
          mealPlan.id, !mealPlan.isAvailable);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mealPlan.isAvailable
              ? 'Meal plan marked as unavailable'
              : 'Meal plan marked as available'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating meal plan: $e')),
      );
    }
  }
}
