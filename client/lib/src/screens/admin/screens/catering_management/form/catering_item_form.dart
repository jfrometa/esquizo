import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_item_model.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_item_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_category_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/icon_mapper.dart';

class CateringItemForm extends ConsumerStatefulWidget {
  final CateringItem? item;
  
  const CateringItemForm({
    super.key, 
    this.item,
  });

  @override
  ConsumerState<CateringItemForm> createState() => _CateringItemFormState();
}

class _CateringItemFormState extends ConsumerState<CateringItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _prepTimeController;
  late TextEditingController _allergenInfoController;
  late TextEditingController _imageUrlController;
  late TextEditingController _tagsController;
  
  List<String> _selectedCategoryIds = [];
  List<IngredientItem> _ingredients = [];
  bool _isActive = false;
  bool _isHighlighted = false;
  ItemUnitType _unitType = ItemUnitType.perPerson;
  int? _iconCodePoint;
  String? _iconFontFamily;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'Restaurant', 'icon': Icons.restaurant},
    {'name': 'Dinner', 'icon': Icons.dinner_dining},
    {'name': 'Coffee', 'icon': Icons.coffee},
    {'name': 'Food Bank', 'icon': Icons.food_bank},
    {'name': 'Liquor', 'icon': Icons.liquor},
    {'name': 'Bakery', 'icon': Icons.bakery_dining},
    {'name': 'Local Bar', 'icon': Icons.local_bar},
    {'name': 'Celebration', 'icon': Icons.celebration},
    {'name': 'Cake', 'icon': Icons.cake},
    {'name': 'Egg', 'icon': Icons.egg},
    {'name': 'Rice Bowl', 'icon': Icons.rice_bowl},
    {'name': 'Set Meal', 'icon': Icons.set_meal},
    {'name': 'Fastfood', 'icon': Icons.fastfood},
    {'name': 'Local Pizza', 'icon': Icons.local_pizza},
    {'name': 'Tapas', 'icon': Icons.tapas},
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.item ?? CateringItem.empty();
    _nameController = TextEditingController(text: item.name);
    _descriptionController = TextEditingController(text: item.description);
    _priceController = TextEditingController(
      text: item.price > 0 ? item.price.toString() : '',
    );
    _prepTimeController = TextEditingController(
      text: item.preparationTimeMinutes > 0 ? item.preparationTimeMinutes.toString() : '',
    );
    _allergenInfoController = TextEditingController(text: item.allergenInfo ?? '');
    _imageUrlController = TextEditingController(text: item.imageUrl);
    _tagsController = TextEditingController(text: item.tags.join(', '));
    _selectedCategoryIds = List.from(item.categoryIds);
    _ingredients = List.from(item.ingredients);
    _isActive = item.isActive;
    _isHighlighted = item.isHighlighted;
    _unitType = item.unitType;
    _iconCodePoint = item.iconCodePoint;
    _iconFontFamily = item.iconFontFamily;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    _allergenInfoController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final price = double.tryParse(_priceController.text) ?? 0;
        final prepTime = int.tryParse(_prepTimeController.text) ?? 0;
        final tags = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

        final item = (widget.item ?? CateringItem.empty()).copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          preparationTimeMinutes: prepTime,
          allergenInfo: _allergenInfoController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          isActive: _isActive,
          isHighlighted: _isHighlighted,
          tags: tags,
          categoryIds: _selectedCategoryIds,
          ingredients: _ingredients,
          unitType: _unitType,
          iconCodePoint: _iconCodePoint,
          iconFontFamily: _iconFontFamily,
        );

        final repository = ref.read(cateringItemRepositoryProvider.notifier);
        
        if (item.id.isEmpty) {
          await repository.addItem(item);
        } else {
          await repository.updateItem(item);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                item.id.isEmpty
                    ? 'Item added successfully'
                    : 'Item updated successfully',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Item' : 'New Item'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveItem,
            icon: const Icon(Icons.save),
            label: Text(_isLoading ? 'Saving...' : 'Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header with icon selection
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showIconSelector,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _iconCodePoint != null
                          ? Icon( 
                              IconMapper.getIconData(_iconCodePoint.toString()),
                              size: 40,
                              color: colorScheme.onPrimaryContainer,
                            )
                          : Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: colorScheme.onPrimaryContainer,
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Item' : 'New Item',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        'Configure your catering item details',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Choose Icon'),
                            onPressed: _showIconSelector,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Tab view for different sections
            DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Basic Info'),
                      Tab(text: 'Categories'),
                      Tab(text: 'Ingredients'),
                    ],
                  ),
                  SizedBox(
                    height: 500, // Fixed height for tab content
                    child: TabBarView(
                      children: [
                        // Basic Info Tab
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basic Information',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Name field
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Item Name',
                                  hintText: 'Enter item name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.label_outline),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter an item name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Description field
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  hintText: 'Enter item description',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.description_outlined),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 3,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                              const SizedBox(height: 16),
                              
                              // Price field
                              TextFormField(
                                controller: _priceController,
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  hintText: 'Enter price',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a price';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid price';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Unit Type
                              DropdownButtonFormField<ItemUnitType>(
                                value: _unitType,
                                decoration: const InputDecoration(
                                  labelText: 'Unit Type',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.category_outlined),
                                ),
                                items: ItemUnitType.values.map((type) {
                                  return DropdownMenuItem<ItemUnitType>(
                                    value: type,
                                    child: Text(_formatUnitType(type)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _unitType = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Prep Time field
                              TextFormField(
                                controller: _prepTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Preparation Time (minutes)',
                                  hintText: 'Enter preparation time',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.timer),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              
                              // Allergen Info field
                              TextFormField(
                                controller: _allergenInfoController,
                                decoration: const InputDecoration(
                                  labelText: 'Allergen Information',
                                  hintText: 'E.g., Contains nuts, dairy, gluten',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.warning_amber_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Tags field
                              TextFormField(
                                controller: _tagsController,
                                decoration: const InputDecoration(
                                  labelText: 'Tags',
                                  hintText: 'Enter tags separated by commas',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.tag),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Image URL field
                              TextFormField(
                                controller: _imageUrlController,
                                decoration: const InputDecoration(
                                  labelText: 'Image URL (optional)',
                                  hintText: 'Enter image URL',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.image_outlined),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Status toggles
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Item Status',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // Active switch
                                      SwitchListTile(
                                        title: const Text('Active'),
                                        subtitle: const Text('Item is available for selection'),
                                        value: _isActive,
                                        onChanged: (value) {
                                          setState(() {
                                            _isActive = value;
                                          });
                                        },
                                        secondary: Icon(
                                          _isActive
                                              ? Icons.toggle_on_outlined
                                              : Icons.toggle_off_outlined,
                                          color: _isActive ? colorScheme.primary : null,
                                        ),
                                      ),
                                      
                                      // Highlighted switch
                                      SwitchListTile(
                                        title: const Text('Highlighted'),
                                        subtitle: const Text('Feature this item in promotions'),
                                        value: _isHighlighted,
                                        onChanged: (value) {
                                          setState(() {
                                            _isHighlighted = value;
                                          });
                                        },
                                        secondary: Icon(
                                          _isHighlighted ? Icons.star : Icons.star_border,
                                          color: _isHighlighted ? colorScheme.primary : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Categories Tab
                        _buildCategoriesTab(colorScheme),
                        
                        // Ingredients Tab
                        _buildIngredientsTab(colorScheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _saveItem,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading
                    ? 'Saving...'
                    : (isEdit ? 'Update Item' : 'Create Item')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(ColorScheme colorScheme) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsyncValue = ref.watch(cateringCategoryRepositoryProvider);
        
        return categoriesAsyncValue.when(
          data: (categories) {
            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 48,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text('No categories available'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to category management
                      },
                      child: const Text('Manage Categories'),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    'Select Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Choose which categories this item belongs to',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _selectedCategoryIds.contains(category.id);
                      
                      return CheckboxListTile(
                        title: Text(category.name),
                        subtitle: Text(
                          category.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondary: category.iconName != null
                            ? Icon(
                            IconMapper.getIconData(_iconCodePoint.toString()),
                            color: isSelected ? colorScheme.onPrimary : null,
                              )
                            : null,
                        value: isSelected,
                        activeColor: colorScheme.primary,
                        onChanged: (selected) {
                          setState(() {
                            if (selected!) {
                              _selectedCategoryIds.add(category.id);
                            } else {
                              _selectedCategoryIds.remove(category.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  Widget _buildIngredientsTab(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddIngredientDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Ingredient'),
              ),
            ],
          ),
        ),
        Text(
          'List of ingredients used in this item',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (_ingredients.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text('No ingredients added yet'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddIngredientDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Ingredient'),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _ingredients.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _ingredients.removeAt(oldIndex);
                  _ingredients.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final ingredient = _ingredients[index];
                
                return Card(
                  key: ValueKey(ingredient.name),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(ingredient.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ingredient.amount.isNotEmpty || ingredient.unit.isNotEmpty)
                          Text('${ingredient.amount} ${ingredient.unit}'),
                        if (ingredient.isOptional)
                          Text(
                            'Optional',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showEditIngredientDialog(ingredient, index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeIngredient(index),
                        ),
                      ],
                    ),
                    onTap: () => _showEditIngredientDialog(ingredient, index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showIconSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Select Icon',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemCount: _iconOptions.length,
                    itemBuilder: (context, index) {
                      final iconOption = _iconOptions[index];
                      final iconData = iconOption['icon'] as IconData;
                      final iconName = iconOption['name'] as String;
                      final isSelected = _iconCodePoint == iconData.codePoint;
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _iconCodePoint = iconData.codePoint;
                            _iconFontFamily = iconData.fontFamily;
                          });
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                iconData,
                                size: 32,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                iconName,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddIngredientDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final unitController = TextEditingController();
    bool isOptional = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Ingredient'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient Name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Optional Ingredient'),
                    value: isOptional,
                    onChanged: (value) {
                      setState(() {
                        isOptional = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    return;
                  }
                  
                  final newIngredient = IngredientItem(
                    name: nameController.text.trim(),
                    amount: amountController.text.trim(),
                    unit: unitController.text.trim(),
                    isOptional: isOptional,
                  );
                  
                  setState(() {
                    _ingredients.add(newIngredient);
                  });
                  
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        }
      ),
    ).then((_) {
      // Dispose controllers
      nameController.dispose();
      amountController.dispose();
      unitController.dispose();
    });
  }
  
  void _showEditIngredientDialog(IngredientItem ingredient, int index) {
    final nameController = TextEditingController(text: ingredient.name);
    final amountController = TextEditingController(text: ingredient.amount);
    final unitController = TextEditingController(text: ingredient.unit);
    bool isOptional = ingredient.isOptional;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Ingredient'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingredient Name',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: unitController,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Optional Ingredient'),
                    value: isOptional,
                    onChanged: (value) {
                      setState(() {
                        isOptional = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    return;
                  }
                  
                  final updatedIngredient = IngredientItem(
                    name: nameController.text.trim(),
                    amount: amountController.text.trim(),
                    unit: unitController.text.trim(),
                    isOptional: isOptional,
                  );
                  
                  setState(() {
                    _ingredients[index] = updatedIngredient;
                  });
                  
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          );
        }
      ),
    ).then((_) {
      // Dispose controllers
      nameController.dispose();
      amountController.dispose();
      unitController.dispose();
    });
  }
  
  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }
  
  String _formatUnitType(ItemUnitType type) {
    switch (type) {
      case ItemUnitType.perPerson:
        return 'Per Person';
      case ItemUnitType.perUnit:
        return 'Per Unit';
      case ItemUnitType.perWeight:
        return 'Per Weight';
      case ItemUnitType.perVolume:
        return 'Per Volume';
      case ItemUnitType.wholeItem:
        return 'Whole Item';
    }
  }
}