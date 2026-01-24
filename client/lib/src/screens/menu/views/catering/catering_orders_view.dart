import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering/_show_catering_form_sheet.dart';

/// A view displaying active catering orders
class CateringOrdersView extends ConsumerWidget {
  /// Scroll controller for the list view
  final ScrollController scrollController;

  /// Callback to add items to the order
  final VoidCallback? onAddItems;

  const CateringOrdersView({
    super.key,
    required this.scrollController,
    this.onAddItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cateringOrder = ref.watch(cateringOrderNotifierProvider);

    // No active order
    if (cateringOrder == null || cateringOrder.dishes.isEmpty) {
      return _buildEmptyState(context, theme, colorScheme);
    }

    // Active order exists
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Header
        Text(
          'Current Catering Order',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your catering items and details',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),

        // Order summary card
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with basic info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.7),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cateringOrder.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Event Type: ${cateringOrder.eventType.isNotEmpty ? cateringOrder.eventType : "Not specified"}',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer
                                  .withOpacity(0.8),
                            ),
                          ),
                          if (cateringOrder.peopleCount != null &&
                              cateringOrder.peopleCount! > 0)
                            Text(
                              'People: ${cateringOrder.peopleCount}',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _viewOrderDetails(context, ref),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Order'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(height: 1, color: colorScheme.outlineVariant),

              // Order items summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Items (${cateringOrder.dishes.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: onAddItems,
                          icon: const Icon(Icons.add),
                          label: const Text('Add More'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // List of items (limited to first 3 with "more" indicator)
                    ...cateringOrder.dishes.take(3).map((dish) =>
                        _buildOrderItemTile(context, dish, theme, colorScheme)),

                    if (cateringOrder.dishes.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton(
                          onPressed: () => _viewOrderDetails(context, ref),
                          child: Text(
                              '${cateringOrder.dishes.length - 3} more items...'),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Totals and checkout button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Total',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              '\$${cateringOrder.totalPrice.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _proceedToCheckout(context),
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Checkout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Suggestions section
        Card(
          elevation: 1,
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested Additions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSuggestionChip(context, 'Appetizers', Icons.tapas),
                    _buildSuggestionChip(context, 'Desserts', Icons.cake),
                    _buildSuggestionChip(context, 'Beverages', Icons.local_bar),
                    _buildSuggestionChip(
                        context, 'Side Dishes', Icons.dinner_dining),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.food_bank_outlined,
            size: 80,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Catering Order',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Create a catering order by selecting items or a package',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Switch to catering packages tab
                  final tabController = DefaultTabController.of(context);
                  tabController.animateTo(0);
                },
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Browse Packages'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Consumer(builder: (context, ref, _) {
                return FilledButton.icon(
                  onPressed: () {
                    showCateringFormSheet(
                      context: context,
                      ref: ref,
                      title: 'Detalles de la Orden',
                      initialFlow: 'menu',
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Select Items'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(BuildContext context, dynamic dish,
      ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${dish.quantity}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if ((dish.pricePerUnit ?? 0) > 0)
                  Text(
                    '\$${(dish.pricePerUnit ?? 0).toStringAsFixed(2)} per unit',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            '\$${((dish.pricePerUnit ?? 0) * dish.quantity).toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(
      BuildContext context, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {
        if (onAddItems != null) {
          onAddItems!();
        }
      },
    );
  }

  void _viewOrderDetails(BuildContext context, WidgetRef ref) {
    final id = ref.watch(cateringOrderNotifierProvider)?.id ?? "no id";
    // Replace Navigator.push with GoRouter navigation
    context.pushNamed(
      AppRoute.cateringOrderDetails.name,
      pathParameters: {'orderId': id},
    );
  }

  void _proceedToCheckout(BuildContext context) {
    GoRouter.of(context).pushNamed(AppRoute.homecart.name, extra: 'catering');
  }
}
