import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/manual_quote_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_order_details.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering/_show_catering_form_sheet.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/menu/views/catering/_show_catering_quote_dialog.dart';

/// A view for creating and managing custom catering quotes
class CustomQuoteView extends ConsumerStatefulWidget {
  /// Scroll controller for the list view
  final ScrollController scrollController;

  /// Callback when a quote is submitted
  final Function(dynamic)? onQuoteSubmitted;

  const CustomQuoteView({
    super.key,
    required this.scrollController,
    this.onQuoteSubmitted,
  });

  @override
  ConsumerState<CustomQuoteView> createState() => _CustomQuoteViewState();
}

class _CustomQuoteViewState extends ConsumerState<CustomQuoteView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quote = ref.watch(manualQuoteProvider);

    // No active quote or no dishes
    if (quote == null || quote.dishes.isEmpty) {
      return _buildEmptyState(context, ref, theme, colorScheme);
    }

    // Active quote exists
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Header
        Text(
          'Current Quote Request',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your custom catering quote details',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),

        // Quote summary card
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
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.7),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.title.isNotEmpty
                                ? quote.title
                                : 'Custom Quote',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Event Type: ${quote.eventType.isNotEmpty ? quote.eventType : "Not specified"}',
                            style: TextStyle(
                              color: colorScheme.onSecondaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                          if (quote.peopleCount != null &&
                              quote.peopleCount! > 0)
                            Text(
                              'People: ${quote.peopleCount}',
                              style: TextStyle(
                                color: colorScheme.onSecondaryContainer
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            showCateringFormSheet(
                              context: context,
                              ref: ref,
                              title: 'Detalles de la Cotización',
                              isQuote: true,
                              onSuccess: (data) {
                                // Force UI refresh
                                setState(() {});
                              },
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Quote'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(height: 1, color: colorScheme.outlineVariant),

              // Quote items summary
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quote Items (${quote.dishes.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddItemDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // List of items (limited to first 3 with "more" indicator)
                    ...quote.dishes.take(3).map((dish) =>
                        _buildQuoteItemTile(context, dish, theme, colorScheme)),

                    if (quote.dishes.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton(
                          onPressed: () => _viewQuoteDetails(context, ref),
                          child:
                              Text('${quote.dishes.length - 3} more items...'),
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
                              'Quote Total',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              // Calculate total price from dishes or show TBD
                              quote.dishes.isNotEmpty
                                  ? '\$${_calculateTotalPrice(quote).toStringAsFixed(2)}'
                                  : 'TBD',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _proceedToCheckout(context, ref),
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Request Quote'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
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

        // Chef service option
        Card(
          elevation: 1,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            title: Row(
              children: [
                Icon(Icons.restaurant, color: colorScheme.secondary),
                const SizedBox(width: 12),
                const Text('Chef Service Required'),
              ],
            ),
            subtitle:
                const Text('Professional chef will prepare and serve the food'),
            value: quote.hasChef ?? false,
            onChanged: (value) {
              // Update hasChef property
              final currentQuote = ref.read(manualQuoteProvider);
              if (currentQuote == null) return;

              ref.read(manualQuoteProvider.notifier).finalizeManualQuote(
                    title: currentQuote.title,
                    img: currentQuote.img,
                    description: currentQuote.description,
                    hasChef: value,
                    alergias: currentQuote.alergias,
                    eventType: currentQuote.eventType,
                    preferencia: currentQuote.preferencia,
                    adicionales: currentQuote.adicionales,
                    cantidadPersonas: currentQuote.peopleCount ?? 1,
                  );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Suggestions section
        Card(
          elevation: 1,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                    _buildSuggestionChip(
                        context, ref, 'Appetizers', Icons.tapas),
                    _buildSuggestionChip(context, ref, 'Desserts', Icons.cake),
                    _buildSuggestionChip(
                        context, ref, 'Beverages', Icons.local_bar),
                    _buildSuggestionChip(
                        context, ref, 'Side Dishes', Icons.dinner_dining),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, ThemeData theme,
      ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.request_quote_outlined,
            size: 80,
            color: colorScheme.secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Quote Request',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Create a custom quote by adding your event details and items',
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
              FilledButton.icon(
                onPressed: () {
                  showCateringFormSheet(
                    context: context,
                    ref: ref,
                    title: 'Detalles de la Cotización',
                    isQuote: true,
                    initialFlow: 'custom',
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Start Quote'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteItemTile(BuildContext context, CateringDish dish,
      ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${dish.quantity}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
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
      BuildContext context, WidgetRef ref, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {
        _showAddItemDialog(context, ref, label);
      },
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref,
      [String? categoryName]) {
    showAddQuoteItemDialog(
      context: context,
      ref: ref,
      onItemAdded: (item) {
        final quoteOrder = ref.read(manualQuoteProvider);
        if (quoteOrder == null) return;

        // If category was provided, add it to the title
        String itemTitle = item.title;
        if (categoryName != null &&
            !itemTitle.toLowerCase().contains(categoryName.toLowerCase())) {
          itemTitle = '$categoryName: $itemTitle';
        }

        ref.read(manualQuoteProvider.notifier).addManualItem(
              CateringDish(
                title: itemTitle,
                quantity: item.quantity,
                hasUnitSelection: false,
                peopleCount: quoteOrder.peopleCount ?? 0,
                pricePerUnit: 0,
                pricePerPerson: 0,
                ingredients: [],
                pricing: 0,
              ),
            );

        // Force UI to refresh
        setState(() {});
      },
    );
  }

  void _viewQuoteDetails(BuildContext context, WidgetRef ref) {
    // Show a detailed view of the quote
    // Using a similar screen as order details, but could be customized further
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CateringOrderDetailsScreen(
          orderId: '',
        ), // TODO: Replace with actual order ID
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, WidgetRef ref) {
    // Validate quote
    final quote = ref.read(manualQuoteProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (quote == null) {
      _showErrorSnackBar(
          context, 'Error: No hay datos de la cotización', colorScheme);
      return;
    }

    if ((quote.peopleCount ?? 0) <= 0) {
      _showErrorSnackBar(
          context, 'La cantidad de personas es requerida', colorScheme);
      return;
    }

    if (quote.eventType.isEmpty) {
      _showErrorSnackBar(
          context, 'El tipo de evento es requerido', colorScheme);
      return;
    }

    if (quote.dishes.isEmpty) {
      _showErrorSnackBar(context, 'Debe agregar al menos un item', colorScheme);
      return;
    }

    // All validation passed, submit the quote
    if (widget.onQuoteSubmitted != null) {
      widget.onQuoteSubmitted!(quote);
    }

    // Navigate to cart with quote
    GoRouter.of(context).pushNamed(AppRoute.homecart.name, extra: 'quote');
  }

  double _calculateTotalPrice(dynamic quote) {
    double total = 0;

    // Sum up the prices of all dishes
    try {
      if (quote.dishes is List) {
        for (var dish in quote.dishes) {
          total += (dish.pricePerUnit ?? 0) * dish.quantity;
        }
      }
    } catch (e) {
      // If there's an error in calculation, return 0
      return 0;
    }

    return total;
  }

  void _showErrorSnackBar(
      BuildContext context, String message, ColorScheme colorScheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
