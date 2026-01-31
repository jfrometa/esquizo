import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/subscriptions/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';

// Provider for customer search
final customerSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider for filtered meal plans based on a customer
final searchedMealPlansProvider =
    FutureProvider.family<List<MealPlan>, String>((ref, customerId) async {
  if (customerId.isEmpty) return [];

  final service = ref.watch(mealPlanServiceProvider);
  try {
    final plans = await service.getMealPlansByOwner(customerId);
    // Filter only active plans
    return plans
        .where((plan) => plan.isActive && plan.mealsRemaining > 0)
        .toList();
  } catch (e) {
    return [];
  }
});

class POSMealPlanWidget extends ConsumerStatefulWidget {
  // Callback for when a meal plan item is used
  final Function(ConsumedItem) onMealPlanUsed;

  const POSMealPlanWidget({
    super.key,
    required this.onMealPlanUsed,
  });

  @override
  ConsumerState<POSMealPlanWidget> createState() => _POSMealPlanWidgetState();
}

class _POSMealPlanWidgetState extends ConsumerState<POSMealPlanWidget> {
  final _customerIdController = TextEditingController();
  final _customerNameController = TextEditingController();

  MealPlan? _selectedPlan;
  MealPlanItem? _selectedItem;

  @override
  void dispose() {
    _customerIdController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Meal Plan Payment',
            //   style: theme.textTheme.titleLarge,
            // ),
            // const SizedBox(height: 16),

            // Customer search fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _customerIdController,
                    decoration: const InputDecoration(
                      labelText: 'Customer ID',
                      border: OutlineInputBorder(),
                      hintText: 'Enter customer ID',
                    ),
                    onChanged: (value) {
                      ref.read(customerSearchQueryProvider.notifier).state =
                          value;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Enter customer name',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _searchCustomer,
                  child: const Text('Search'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Available meal plans
            Expanded(
              child: _buildMealPlansList(),
            ),

            const SizedBox(height: 16),

            // Bottom action section
            if (_selectedPlan != null) ...[
              Card(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Plan: ${_selectedPlan!.title}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Meals Remaining: ${_selectedPlan!.mealsRemaining}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Customer: ${_selectedPlan!.ownerName}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.restaurant_menu),
                            label: const Text('Use Meal'),
                            onPressed: _showItemSelectionDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlansList() {
    final customerId = ref.watch(customerSearchQueryProvider);
    final plansAsync = ref.watch(searchedMealPlansProvider(customerId));

    return plansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return Center(
            child: customerId.isEmpty
                ? const Text('Enter customer ID to search for meal plans')
                : const Text('No active meal plans found for this customer'),
          );
        }

        return ListView.builder(
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            final isSelected = _selectedPlan?.id == plan.id;

            return Card(
              elevation: isSelected ? 2 : 0,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: isSelected
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : BorderSide.none,
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPlan = plan;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Plan info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${plan.mealsRemaining} of ${plan.totalMeals} meals remaining',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            if (plan.expiryDate != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Expires: ${DateFormat.yMMMd().format(plan.expiryDate!)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Select button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedPlan = plan;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          foregroundColor: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                        ),
                        child: Text(isSelected ? 'Selected' : 'Select'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('Error loading meal plans. Please try again.'),
      ),
    );
  }

  void _searchCustomer() {
    final customerId = _customerIdController.text.trim();
    if (customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a customer ID')),
      );
      return;
    }

    // Update the provider
    ref.read(customerSearchQueryProvider.notifier).state = customerId;

    // Clear the selected plan
    setState(() {
      _selectedPlan = null;
    });
  }

  void _showItemSelectionDialog() {
    if (_selectedPlan == null) return;

    final itemsAsync = ref.read(mealPlanItemsProvider.future);

    itemsAsync.then((items) {
      if (!mounted) return;

      // Filter to only allowed items that are available
      final allowedItems = items
          .where((item) =>
              _selectedPlan!.allowedItemIds.contains(item.id) &&
              item.isAvailable)
          .toList();

      if (allowedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No available items for this meal plan')),
        );
        return;
      }

      _selectedItem = allowedItems.first;
      final notesController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Item to Use'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatefulBuilder(builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer: ${_selectedPlan!.ownerName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Plan: ${_selectedPlan!.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Meals Remaining: ${_selectedPlan!.mealsRemaining}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<MealPlanItem>(
                        initialValue: _selectedItem,
                        decoration: const InputDecoration(
                          labelText: 'Select Menu Item',
                          border: OutlineInputBorder(),
                        ),
                        items: allowedItems.map((item) {
                          return DropdownMenuItem<MealPlanItem>(
                            value: item,
                            child: Text(
                                '${item.name} - \$${item.price.toStringAsFixed(2)}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedItem = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                          hintText: 'Special requests or modifications',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedItem != null && _selectedPlan != null) {
                  final consumedItem = ConsumedItem(
                    id: '',
                    mealPlanId: _selectedPlan!.id,
                    itemId: _selectedItem!.id,
                    itemName: _selectedItem!.name,
                    consumedAt: DateTime.now(),
                    consumedBy: _selectedPlan!.ownerId,
                    notes: notesController.text.trim(),
                  );

                  Navigator.pop(context);
                  _processMealPlanUsage(consumedItem);
                }
              },
              child: const Text('Confirm Usage'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _processMealPlanUsage(ConsumedItem item) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      final itemId = await service.addConsumedItem(item);

      if (!mounted) return;

      // Pass the consumed item to the parent widget
      item = ConsumedItem(
        id: itemId,
        mealPlanId: item.mealPlanId,
        itemId: item.itemId,
        itemName: item.itemName,
        consumedAt: item.consumedAt,
        consumedBy: item.consumedBy,
        notes: item.notes,
      );

      widget.onMealPlanUsed(item);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Successfully processed ${item.itemName} using meal plan'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset the selected plan to refresh the meal count
      setState(() {
        _selectedPlan = null;
      });

      // Refresh the search to update plans
      _searchCustomer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing meal plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
