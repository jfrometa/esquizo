import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';
 
 

// Provider for customer's meal plans - change to StreamProvider
final customerMealPlansProvider = StreamProvider<List<MealPlan>>((ref) {
  final service = ref.watch(mealPlanServiceProvider);
  final customerId = ref.watch(currentUserIdProvider) ?? 'no ide';
  return service.getMealPlansByOwner(customerId).asStream();
});

class CustomerMealPlanScreen extends ConsumerStatefulWidget {
  const CustomerMealPlanScreen({super.key});

  @override
  ConsumerState<CustomerMealPlanScreen> createState() => _CustomerMealPlanScreenState();
}

class _CustomerMealPlanScreenState extends ConsumerState<CustomerMealPlanScreen> {
  String? _selectedMealPlanId;

  @override
  Widget build(BuildContext context) {
    final customerPlansAsync = ref.watch(customerMealPlansProvider);
    // Use a StreamProvider for the selected meal plan instead of a FutureProvider
    final  selectedPlanAsync = _selectedMealPlanId != null
        ? ref.watch(mealPlanProvider(_selectedMealPlanId!))
        : const AsyncValue.loading();
    
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Meal Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: customerPlansAsync.when(
        data: (plans) {
          if (plans.isEmpty) {
            return const Center(
              child: Text('You don\'t have any active meal plans'),
            );
          }
          
          if (_selectedMealPlanId == null && plans.isNotEmpty) {
            // Auto-select the first meal plan
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedMealPlanId = plans.first.id;
              });
            });
          }
          
          return isDesktop
              ? Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: _buildMealPlansList(plans),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _selectedMealPlanId != null
                          ? _buildMealPlanDetails(selectedPlanAsync as AsyncValue<MealPlan>)
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant_menu,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Select a meal plan to view details',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                )
              : _selectedMealPlanId == null
                  ? _buildMealPlansList(plans)
                  : _buildMealPlanDetails(selectedPlanAsync as AsyncValue<MealPlan>);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: SelectableText('Error: $error')),
      ),
    );
  }
  
  Widget _buildMealPlansList(List<MealPlan> plans) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Meal Plans',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Plans list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final isSelected = plan.id == _selectedMealPlanId;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                elevation: isSelected ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isSelected
                      ? BorderSide(color: theme.colorScheme.primary, width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMealPlanId = plan.id;
                    });
                    
                    // If on mobile, navigate to detail view
                    if (!ResponsiveLayout.isDesktop(context)) {
                      // Use a mobile-specific navigation approach
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                plan.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? theme.colorScheme.primary : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(plan).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _getStatusColor(plan)),
                              ),
                              child: Text(
                                _getStatusText(plan),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _getStatusColor(plan),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Progress indicator
                        LinearProgressIndicator(
                          value: plan.usagePercentage / 100,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        
                        // Usage stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${plan.mealsRemaining} meals remaining',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              '${plan.usagePercentage.toStringAsFixed(0)}% used',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        
                        if (plan.expiryDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 14,
                                color: plan.isExpired
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Expires: ${DateFormat.yMMMd().format(plan.expiryDate!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: plan.isExpired
                                        ? theme.colorScheme.error
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildMealPlanDetails(AsyncValue<MealPlan> planAsync) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return planAsync.when(
      data: (plan) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDesktop)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _selectedMealPlanId = null;
                        });
                      },
                    ),
                  
                  // Image and header
                  if (plan.img.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        plan.img,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    plan.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Usage summary card
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Usage Summary',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${plan.mealsRemaining} of ${plan.totalMeals} remaining',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          LinearProgressIndicator(
                            value: plan.usagePercentage / 100,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${plan.usagePercentage.toStringAsFixed(0)}% used',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (plan.expiryDate != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.event,
                                      size: 14,
                                      color: plan.isExpired
                                          ? Theme.of(context).colorScheme.error
                                          : null,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Expires: ${DateFormat.yMMMd().format(plan.expiryDate!)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: plan.isExpired
                                            ? Theme.of(context).colorScheme.error
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // About this plan
                  Text(
                    'About This Plan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(plan.longDescription),
                  
                  const SizedBox(height: 24),
                  
                  // How it works
                  Text(
                    'How It Works',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(plan.howItWorks),
                  
                  const SizedBox(height: 24),
                  
                  // Features
                  Text(
                    'Features',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ...plan.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Recent consumption
                  Consumer(
                    builder: (context, ref, _) {
                      final consumedItemsAsync = ref.watch(consumedItemsProvider(plan.id));
                      
                      return consumedItemsAsync.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('No items consumed yet'),
                              ),
                            );
                          }
                          
                          // Show only the 5 most recent consumed items
                          final recentItems = items.take(5).toList();
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent Usage',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Card(
                                elevation: 0,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: recentItems.length,
                                  separatorBuilder: (context, index) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final item = recentItems[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        child: Icon(
                                          Icons.restaurant,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      title: Text(item.itemName),
                                      subtitle: Text(
                                        DateFormat.yMMMd().add_jm().format(item.consumedAt),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error loading consumption history'),
                      );
                    },
                  ),
                  
                  // Add space at bottom for floating button
                  const SizedBox(height: 80),
                ],
              ),
            ),
            
            // Use meal button
            if (plan.isActive)
              Positioned(
                bottom: 16,
                right: 16,
                left: 16,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Use Meal Plan'),
                  onPressed: () => _showUseItemDialog(plan),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
  
  void _showUseItemDialog(MealPlan plan) {
    if (plan.mealsRemaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No meals remaining in this plan')),
      );
      return;
    }
    
    if (plan.isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This meal plan has expired')),
      );
      return;
    }
    
    final itemsAsync = ref.read(mealPlanItemsProvider.future);
    
    itemsAsync.then((items) {
      // Filter to only allowed items that are available
      final allowedItems = items.where(
        (item) => plan.allowedItemIds.contains(item.id) && item.isAvailable
      ).toList();
      
      if (allowedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No available items for this meal plan')),
        );
        return;
      }
      
      MealPlanItem? selectedItem = allowedItems.first;
      final notesController = TextEditingController();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Use Meal Plan'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meals Remaining: ${plan.mealsRemaining}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButtonFormField<MealPlanItem>(
                      value: selectedItem,
                      decoration: const InputDecoration(
                        labelText: 'Select Item',
                        border: OutlineInputBorder(),
                      ),
                      items: allowedItems.map((item) {
                        return DropdownMenuItem<MealPlanItem>(
                          value: item,
                          child: Text(item.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedItem = value;
                          });
                        }
                      },
                    );
                  }
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
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
                if (selectedItem != null) {
                  final customerId = ref.watch(currentUserIdProvider) ?? 'no ide';
                  
                  final consumedItem = ConsumedItem(
                    id: '',
                    mealPlanId: plan.id,
                    itemId: selectedItem!.id,
                    itemName: selectedItem!.name,
                    consumedAt: DateTime.now(),
                    consumedBy: customerId, 
                    notes: notesController.text.trim(),
                  );
                  
                  Navigator.pop(context);
                  _consumeItem(consumedItem);
                }
              },
              child: const Text('Use Meal'),
            ),
          ],
        ),
      );
    });
  }
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meal Plan Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Using Your Meal Plans',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Your meal plans allow you to enjoy meals at our restaurant at a discounted rate. Each plan includes a specific number of meals that you can redeem.',
              ),
              SizedBox(height: 16),
              Text(
                'How to Use',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '1. Select a meal plan from your list\n'
                '2. Click the "Use Meal Plan" button\n'
                '3. Select the item you want to consume\n'
                '4. Add any special notes or requests\n'
                '5. Show this to the staff who will confirm your purchase',
              ),
              SizedBox(height: 16),
              Text(
                'Important Notes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Meals cannot be refunded once consumed\n'
                '• Check the expiration date of your plan\n'
                '• Some items may not be available with certain plans\n'
                '• Contact our staff if you have any questions',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(MealPlan plan) {
    if (plan.isExpired) {
      return Colors.red;
    }
    
    if (!plan.isAvailable) {
      return Colors.grey;
    }
    
    if (plan.mealsRemaining <= 0) {
      return Colors.orange;
    }
    
    return Colors.green;
  }
  
  String _getStatusText(MealPlan plan) {
    if (plan.isExpired) {
      return 'Expired';
    }
    
    if (!plan.isAvailable) {
      return 'Unavailable';
    }
    
    if (plan.mealsRemaining <= 0) {
      return 'Depleted';
    }
    
    return 'Active';
  }
  
  Future<void> _consumeItem(ConsumedItem item) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.addConsumedItem(item);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully used ${item.itemName}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}