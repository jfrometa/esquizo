import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';
 
class MealPlanItemsScreen extends ConsumerStatefulWidget {
  const MealPlanItemsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MealPlanItemsScreen> createState() => _MealPlanItemsScreenState();
}

class _MealPlanItemsScreenState extends ConsumerState<MealPlanItemsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildCategoryFilter(),
              ],
            ),
          ),
          
          // Items list
          Expanded(
            child: _buildItemsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildCategoryFilter() {
    final categoriesAsync = ref.watch(mealPlanCategoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        final activeCategories = categories.where((c) => c.isActive).toList();
        
        return DropdownButton<String?>(
          value: _selectedCategoryId,
          hint: const Text('Filter by Category'),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Categories'),
            ),
            ...activeCategories.map((category) => DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            )),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading categories'),
    );
  }
  
  Widget _buildItemsList() {
    final itemsAsync = ref.watch(mealPlanItemsProvider);
    
    return itemsAsync.when(
      data: (items) {
        // Apply filters
        final filteredItems = items.where((item) {
          final matchesSearch = _searchQuery.isEmpty || 
            item.name.toLowerCase().contains(_searchQuery) ||
            item.description.toLowerCase().contains(_searchQuery);
            
          final matchesCategory = _selectedCategoryId == null || 
            item.categoryId == _selectedCategoryId;
            
          return matchesSearch && matchesCategory;
        }).toList();
        
        if (filteredItems.isEmpty) {
          return const Center(
            child: Text('No items found'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
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
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
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
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditItemDialog(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteItem(item),
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
  
  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    String selectedCategoryId = '';
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Meal Plan Item'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer(
                        builder: (context, ref, _) {
                          final categoriesAsync = ref.watch(mealPlanCategoriesProvider);
                          
                          return categoriesAsync.when(
                            data: (categories) {
                              if (categories.isEmpty) {
                                return const Text('No categories available. Please create a category first.');
                              }
                              
                              if (selectedCategoryId.isEmpty && categories.isNotEmpty) {
                                // Initialize with first category
                                selectedCategoryId = categories.first.id;
                              }
                              
                              return DropdownButtonFormField<String>(
                                value: selectedCategoryId.isNotEmpty ? selectedCategoryId : null,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                ),
                                items: categories.map((category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                )).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedCategoryId = value;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a category';
                                  }
                                  return null;
                                },
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const Text('Error loading categories'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    if (priceController.text.trim().isEmpty) return;
                    if (selectedCategoryId.isEmpty) return;
                    
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    
                    final item = MealPlanItem(
                      id: '',
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      price: price,
                      categoryId: selectedCategoryId,
                      imageUrl: imageUrlController.text.trim(),
                      isAvailable: true,
                    );
                    
                    Navigator.pop(context);
                    _createItem(item);
                  },
                  child: const Text('Add Item'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  void _showEditItemDialog(MealPlanItem item) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    final imageUrlController = TextEditingController(text: item.imageUrl);
    String selectedCategoryId = item.categoryId;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Meal Plan Item'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer(
                        builder: (context, ref, _) {
                          final categoriesAsync = ref.watch(mealPlanCategoriesProvider);
                          
                          return categoriesAsync.when(
                            data: (categories) {
                              if (categories.isEmpty) {
                                return const Text('No categories available.');
                              }
                              
                              return DropdownButtonFormField<String>(
                                value: selectedCategoryId.isNotEmpty ? selectedCategoryId : null,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                ),
                                items: categories.map((category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                )).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedCategoryId = value;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a category';
                                  }
                                  return null;
                                },
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const Text('Error loading categories'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    if (priceController.text.trim().isEmpty) return;
                    if (selectedCategoryId.isEmpty) return;
                    
                    final price = double.tryParse(priceController.text) ?? 0.0;
                    
                    final updatedItem = MealPlanItem(
                      id: item.id,
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      price: price,
                      categoryId: selectedCategoryId,
                      imageUrl: imageUrlController.text.trim(),
                      isAvailable: item.isAvailable,
                    );
                    
                    Navigator.pop(context);
                    _updateItem(updatedItem);
                  },
                  child: const Text('Update Item'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  void _confirmDeleteItem(MealPlanItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(item.id);
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
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meal Plan Items Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'About Meal Plan Items',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Meal plan items are the dishes or products that can be consumed as part of a meal plan. When creating a meal plan, you can specify which items are available for that plan.',
              ),
              SizedBox(height: 16),
              Text(
                'Managing Items',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                '• Create new items with the + button\n'
                '• Edit items by clicking the edit icon\n'
                '• Toggle availability to make items available or unavailable\n'
                '• Filter items by category or search for specific items',
              ),
              SizedBox(height: 16),
              Text(
                'Usage in Meal Plans',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'When a customer uses a meal plan, they can only redeem items that are allowed in their specific plan. Make sure to add the relevant items to each meal plan.'
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
  
  // CRUD Operations
  Future<void> _createItem(MealPlanItem item) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.createMealPlanItem(item);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating item: $e')),
        );
      }
    }
  }
  
  Future<void> _updateItem(MealPlanItem item) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.updateMealPlanItem(item);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteItem(String id) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.deleteMealPlanItem(id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
    }
  }
  
  Future<void> _toggleItemAvailability(MealPlanItem item, bool isAvailable) async {
    try {
      final service = ref.read(mealPlanServiceProvider);
      await service.toggleMealPlanItemAvailability(item.id, isAvailable);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAvailable
                  ? '${item.name} marked as available'
                  : '${item.name} marked as unavailable'
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }
}