import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/subscriptions/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/meal_plan/form/meal_plan_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';
 

class MealPlanDetailView extends ConsumerStatefulWidget {
  final String mealPlanId;
  final VoidCallback onClose;
  
  const MealPlanDetailView({
    super.key,
    required this.mealPlanId,
    required this.onClose,
  });
  
  @override
  ConsumerState<MealPlanDetailView> createState() => _MealPlanDetailViewState();
}

class _MealPlanDetailViewState extends ConsumerState<MealPlanDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealPlanAsync = ref.watch(mealPlanProvider(widget.mealPlanId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onClose,
            tooltip: 'Close',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Consumed Items'),
            Tab(text: 'Allowed Items'),
          ],
        ),
      ),
      body: mealPlanAsync.when(
        data: (mealPlan) {
          if (mealPlan == null) {
            return const Center(
              child: Text('Meal plan not found'),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(mealPlan),
              _buildConsumedItemsTab(mealPlan),
              _buildAllowedItemsTab(mealPlan),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(),
        tooltip: _tabController.index == 1 ? 'Record consumed item' : 'Add allowed item',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildOverviewTab(MealPlan mealPlan) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Header
          if (mealPlan.img.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                mealPlan.img,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Title and price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealPlan.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                    if (mealPlan.categoryName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Category: ${mealPlan.categoryName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${mealPlan.price}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (mealPlan.originalPrice > 0 &&
                      double.parse(mealPlan.price) < mealPlan.originalPrice)
                    Text(
                      '\$${mealPlan.originalPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mealPlan.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Features list
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: mealPlan.features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // How it works
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How It Works',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mealPlan.howItWorks,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Meal plan stats
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meal Plan Stats',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildStatRow(
                    icon: Icons.restaurant_menu,
                    label: 'Total Meals',
                    value: '${mealPlan.totalMeals}',
                  ),
                  
                  const Divider(height: 24),
                  
                  _buildStatRow(
                    icon: Icons.check_circle,
                    label: 'Meals Used',
                    value: '${mealPlan.totalMeals - mealPlan.mealsRemaining}',
                  ),
                  
                  const Divider(height: 24),
                  
                  _buildStatRow(
                    icon: Icons.pending_actions,
                    label: 'Meals Remaining',
                    value: '${mealPlan.mealsRemaining}',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Progress',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: mealPlan.totalMeals > 0
                            ? (mealPlan.totalMeals - mealPlan.mealsRemaining) /
                                mealPlan.totalMeals
                            : 0.0,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${((mealPlan.totalMeals - mealPlan.mealsRemaining) / mealPlan.totalMeals * 100).toStringAsFixed(1)}% Used',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Date information
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLowest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildStatRow(
                    icon: Icons.event_available,
                    label: 'Created Date',
                    value: DateFormat.yMMMd().format(mealPlan.createdAt),
                  ),
                  
                  if (mealPlan.updatedAt != null) ...[
                    const Divider(height: 24),
                    _buildStatRow(
                      icon: Icons.update,
                      label: 'Last Updated',
                      value: DateFormat.yMMMd().add_jm().format(mealPlan.updatedAt!),
                    ),
                  ],
                  
                  if (mealPlan.expiryDate != null) ...[
                    const Divider(height: 24),
                    _buildStatRow(
                      icon: Icons.event_busy,
                      label: 'Expiry Date',
                      value: DateFormat.yMMMd().format(mealPlan.expiryDate!),
                      valueColor: mealPlan.isExpired ? theme.colorScheme.error : null,
                    ),
                  ],
                  
                  const Divider(height: 24),
                  
                  _buildStatRow(
                    icon: Icons.visibility,
                    label: 'Availability',
                    value: mealPlan.isAvailable ? 'Available' : 'Unavailable',
                    valueColor: mealPlan.isAvailable ? Colors.green : Colors.red,
                  ),
                  
                  const Divider(height: 24),
                  
                  _buildStatRow(
                    icon: Icons.info,
                    label: 'Status',
                    value: mealPlan.status.name[0].toUpperCase() + 
                           mealPlan.status.name.substring(1),
                    valueColor: _getStatusColor(mealPlan.status),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Meal Plan'),
                onPressed: () => _showEditMealPlanDialog(mealPlan),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                icon: Icon(
                  mealPlan.isAvailable ? Icons.visibility_off : Icons.visibility,
                ),
                label: Text(
                  mealPlan.isAvailable ? 'Mark as Unavailable' : 'Mark as Available',
                ),
                onPressed: () => _toggleAvailability(mealPlan),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildConsumedItemsTab(MealPlan mealPlan) {
    final consumedItemsAsync = ref.watch(consumedItemsProvider(mealPlan.id));
    
    return consumedItemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text('No consumed items recorded yet'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.restaurant,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(item.itemName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consumed on: ${DateFormat.yMMMd().add_jm().format(item.consumedAt)}'),
                    if (item.notes.isNotEmpty)
                      Text('Notes: ${item.notes}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDeleteConsumedItem(item),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
  
  Widget _buildAllowedItemsTab(MealPlan mealPlan) {
    final allItemsAsync = ref.watch(mealPlanItemsProvider);
    
    return allItemsAsync.when(
      data: (allItems) {
        // Filter to get only allowed items
        final allowedItems = allItems.where(
          (item) => mealPlan.allowedItemIds.contains(item.id)
        ).toList();
        
        if (allowedItems.isEmpty) {
          return const Center(
            child: Text('No allowed items set for this meal plan'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allowedItems.length,
          itemBuilder: (context, index) {
            final item = allowedItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: item.imageUrl.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(item.imageUrl),
                        onBackgroundImageError: (_, __) => const Icon(Icons.error),
                      )
                    : CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                title: Text(item.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text('\$${item.price.toStringAsFixed(2)}', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: item.isAvailable,
                      onChanged: (value) => _toggleItemAvailability(item, value),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeAllowedItem(mealPlan, item),
                      tooltip: 'Remove from allowed items',
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
  
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
  
  Color _getStatusColor(MealPlanStatus status) {
    switch (status) {
      case MealPlanStatus.active:
        return Colors.green;
      case MealPlanStatus.inactive:
        return Colors.orange;
      case MealPlanStatus.discontinued:
        return Colors.red;
    }
  }
  
  void _showEditMealPlanDialog(MealPlan mealPlan) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: MealPlanForm(
            mealPlan: mealPlan,
            onSave: (updatedPlan) {
              Navigator.pop(context);
              _updateMealPlan(updatedPlan);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
  
  void _showAddItemDialog() {
    if (_tabController.index == 1) {
      _showAddConsumedItemDialog();
    } else if (_tabController.index == 2) {
      _showAddAllowedItemDialog();
    }
  }
  
  void _showAddConsumedItemDialog() {
    final mealPlanAsync = ref.read(mealPlanProvider(widget.mealPlanId));
    
    mealPlanAsync.whenData((mealPlan) {
      if (mealPlan == null) return;
      
      final allItemsAsync = ref.read(mealPlanItemsProvider.future);
      
      allItemsAsync.then((allItems) {
        // Filter to only show allowed items that are available
        final allowedItems = allItems.where(
          (item) => mealPlan.allowedItemIds.contains(item.id) && item.isAvailable
        ).toList();
        
        if (allowedItems.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No available items for this meal plan. Please add allowed items first.'),
            ),
          );
          return;
        }
        
        MealPlanItem? selectedItem = allowedItems.first;
        final notesController = TextEditingController();
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Record Consumed Item'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<MealPlanItem>(
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
                        selectedItem = value;
                      }
                    },
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
                    final consumedItem = ConsumedItem(
                      id: '',
                      mealPlanId: mealPlan.id,
                      itemId: selectedItem!.id,
                      itemName: selectedItem!.name,
                      consumedAt: DateTime.now(),
                      consumedBy: 'admin', // Replace with actual user ID
                      notes: notesController.text.trim(),
                    );
                    
                    Navigator.pop(context);
                    _addConsumedItem(consumedItem);
                  }
                },
                child: const Text('Record'),
              ),
            ],
          ),
        );
      });
    });
  }
  
  void _showAddAllowedItemDialog() {
    final mealPlanAsync = ref.read(mealPlanProvider(widget.mealPlanId));
    
    mealPlanAsync.whenData((mealPlan) {
      if (mealPlan == null) return;
      
      final allItemsAsync = ref.read(mealPlanItemsProvider.future);
      
      allItemsAsync.then((allItems) {
        // Filter out items that are already allowed
        final availableItems = allItems.where(
          (item) => !mealPlan.allowedItemIds.contains(item.id)
        ).toList();
        
        if (availableItems.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All items are already allowed for this meal plan.'),
            ),
          );
          return;
        }
        
        // Allow multiple selection
        final selectedItems = <MealPlanItem>[];
        
        showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add Allowed Items'),
                content: SizedBox(
                  width: 400,
                  height: 400,
                  child: ListView.builder(
                    itemCount: availableItems.length,
                    itemBuilder: (context, index) {
                      final item = availableItems[index];
                      final isSelected = selectedItems.contains(item);
                      
                      return CheckboxListTile(
                        title: Text(item.name),
                        subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedItems.add(item);
                            } else {
                              selectedItems.remove(item);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: selectedItems.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context);
                            _addAllowedItems(mealPlan, selectedItems);
                          },
                    child: Text('Add ${selectedItems.length} Items'),
                  ),
                ],
              );
            },
          ),
        );
      });
    });
  }
  
  void _confirmDeleteConsumedItem(ConsumedItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Consumed Item'),
        content: Text('Are you sure you want to delete this consumed item? '
            'This will increase the remaining meals count.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteConsumedItem(item);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  // CRUD Operations
  Future<void> _updateMealPlan(MealPlan mealPlan) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.updateMealPlan(mealPlan);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal plan updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating meal plan: $e')),
      );
    }
  }
  
  Future<void> _toggleAvailability(MealPlan mealPlan) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.toggleMealPlanAvailability(mealPlan.id, !mealPlan.isAvailable);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mealPlan.isAvailable
                ? 'Meal plan marked as unavailable'
                : 'Meal plan marked as available'
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating meal plan: $e')),
      );
    }
  }
  
  Future<void> _addConsumedItem(ConsumedItem item) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.addConsumedItem(item);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consumed item recorded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording consumed item: $e')),
      );
    }
  }
  
  Future<void> _deleteConsumedItem(ConsumedItem item) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.deleteConsumedItem(item.id, item.mealPlanId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consumed item deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting consumed item: $e')),
      );
    }
  }
  
  Future<void> _addAllowedItems(MealPlan mealPlan, List<MealPlanItem> items) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      
      final newAllowedIds = List<String>.from(mealPlan.allowedItemIds);
      for (final item in items) {
        if (!newAllowedIds.contains(item.id)) {
          newAllowedIds.add(item.id);
        }
      }
      
      final updatedMealPlan = mealPlan.copyWith(
        allowedItemIds: newAllowedIds,
      );
      
      await service.updateMealPlan(updatedMealPlan);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${items.length} items added to allowed items')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding allowed items: $e')),
      );
    }
  }
  
  Future<void> _removeAllowedItem(MealPlan mealPlan, MealPlanItem item) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      
      final newAllowedIds = List<String>.from(mealPlan.allowedItemIds);
      newAllowedIds.remove(item.id);
      
      final updatedMealPlan = mealPlan.copyWith(
        allowedItemIds: newAllowedIds,
      );
      
      await service.updateMealPlan(updatedMealPlan);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} removed from allowed items')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing allowed item: $e')),
      );
    }
  }
  
  Future<void> _toggleItemAvailability(MealPlanItem item, bool isAvailable) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.toggleMealPlanItemAvailability(item.id, isAvailable);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAvailable
                ? '${item.name} marked as available'
                : '${item.name} marked as unavailable'
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating item: $e')),
      );
    }
  }
}