import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_category_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/unified_catering_package_providers.dart'; 
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_item_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/icon_mapper.dart';
 
class CateringPackageForm extends ConsumerStatefulWidget {
  final CateringPackage? package;
  
  const CateringPackageForm({
    super.key, 
    this.package,
  });

  @override
  ConsumerState<CateringPackageForm> createState() => _CateringPackageFormState();
}

class _CateringPackageFormState extends ConsumerState<CateringPackageForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _minPeopleController;
  late TextEditingController _maxPeopleController;
  late TextEditingController _imageUrlController;
  
  List<String> _selectedCategoryIds = [];
  List<PackageItem> _packageItems = [];
  bool _isActive = false;
  bool _isPromoted = false;
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
    final package = widget.package ?? CateringPackage.empty();
    _nameController = TextEditingController(text: package.name);
    _descriptionController = TextEditingController(text: package.description);
    _priceController = TextEditingController(
      text: package.basePrice > 0 ? package.basePrice.toString() : '',
    );
    _minPeopleController = TextEditingController(
      text: package.minPeople > 0 ? package.minPeople.toString() : '',
    );
    _maxPeopleController = TextEditingController(
      text: package.maxPeople > 0 ? package.maxPeople.toString() : '',
    );
    _imageUrlController = TextEditingController(text: package.imageUrl);
    _selectedCategoryIds = List.from(package.categoryIds);
    _packageItems = List.from(package.items);
    _isActive = package.isActive;
    _isPromoted = package.isPromoted;
    _iconCodePoint = package.iconCodePoint;
    _iconFontFamily = package.iconFontFamily;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _minPeopleController.dispose();
    _maxPeopleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _savePackage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final basePrice = double.tryParse(_priceController.text) ?? 0;
        final minPeople = int.tryParse(_minPeopleController.text) ?? 0;
        final maxPeople = int.tryParse(_maxPeopleController.text) ?? 0;

        final package = (widget.package ?? CateringPackage.empty()).copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          basePrice: basePrice,
          imageUrl: _imageUrlController.text.trim(),
          categoryIds: _selectedCategoryIds,
          items: _packageItems,
          isActive: _isActive,
          isPromoted: _isPromoted,
          minPeople: minPeople,
          maxPeople: maxPeople,
          iconCodePoint: _iconCodePoint,
          iconFontFamily: _iconFontFamily,
        );

        final repository = ref.read(cateringPackageRepositoryProvider);
        
        if (package.id.isEmpty) {
          await repository.addPackage(package);
        } else {
          await repository.updatePackage(package);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                package.id.isEmpty
                    ? 'Package added successfully'
                    : 'Package updated successfully',
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
    final isEdit = widget.package != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final isDesktop = mediaQuery.size.width >= 1100;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Package' : 'New Package'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _savePackage,
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
                              IconMapper.getIconData( _iconCodePoint?.toString() ?? ''),
            
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
                        isEdit ? 'Edit Package' : 'New Package',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        'Configure your catering package details',
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
                      Tab(text: 'Items'),
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
                                  labelText: 'Package Name',
                                  hintText: 'Enter package name',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.label_outline),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a package name';
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
                                  hintText: 'Enter package description',
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
                                  labelText: 'Base Price',
                                  hintText: 'Enter base price',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a base price';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid price';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Min/Max People fields
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _minPeopleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Min People',
                                        hintText: 'Minimum',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.people_outline),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _maxPeopleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Max People',
                                        hintText: 'Maximum',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.people),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
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
                                        'Package Status',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // Active switch
                                      SwitchListTile(
                                        title: const Text('Active'),
                                        subtitle: const Text('Package is available for selection'),
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
                                      
                                      // Promoted switch
                                      SwitchListTile(
                                        title: const Text('Promoted'),
                                        subtitle: const Text('Feature this package in promotions'),
                                        value: _isPromoted,
                                        onChanged: (value) {
                                          setState(() {
                                            _isPromoted = value;
                                          });
                                        },
                                        secondary: Icon(
                                          _isPromoted ? Icons.star : Icons.star_border,
                                          color: _isPromoted ? colorScheme.primary : null,
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
                        
                        // Items Tab
                        _buildItemsTab(colorScheme),
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
                onPressed: _isLoading ? null : _savePackage,
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
                    : (isEdit ? 'Update Package' : 'Create Package')),
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
                  'Choose which categories this package belongs to',
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
                                IconMapper.getIconData( _iconCodePoint?.toString() ?? ''),
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

  Widget _buildItemsTab(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Package Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddItemDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
        ),
        Text(
          'Configure the items included in this package',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        if (_packageItems.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text('No items added to this package'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddItemDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Item'),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _packageItems.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _packageItems.removeAt(oldIndex);
                  _packageItems.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _packageItems[index];
                
                return Card(
                  key: ValueKey(item.itemId),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Row(
                      children: [
                        if (item.isRequired)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Required',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            item.description.isNotEmpty
                                ? item.description
                                : (item.pricePerUnit > 0
                                    ? '\$${item.pricePerUnit.toStringAsFixed(2)} per unit'
                                    : ''),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showEditItemDialog(item, index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                    onTap: () => _showEditItemDialog(item, index),
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

void _showAddItemDialog() {
  showDialog(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, child) {
        // Use the unified provider to access available items
        final itemsAsyncValue = ref.watch(unifiedCateringPackageRepositoryProvider.select(
          (value) => value.whenData((packages) => 
            ref.read(availableItemsProvider)
          ),
        ));
        
        return itemsAsyncValue.when(
          data: (items) {
            if (items.isEmpty) {
              return AlertDialog(
                title: const Text('No Items Available'),
                content: const Text('There are no catering items available. Please create some items first.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              );
            }
            
            return _ItemSelectionDialog(
              items: items,
              onItemSelected: (item, quantity, isRequired) {
                _addPackageItem(item, quantity, isRequired);
                Navigator.pop(context);
              },
            );
          },
          loading: () => const AlertDialog(
            content: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load items: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    ),
  );
}

void _showEditItemDialog(PackageItem item, int index) {
    final quantityController = TextEditingController(text: item.quantity.toString());
    final priceController = TextEditingController(text: item.pricePerUnit.toString());
    final descriptionController = TextEditingController(text: item.description);
    final minQuantityController = TextEditingController(
      text: item.minQuantity > 0 ? item.minQuantity.toString() : '',
    );
    final maxQuantityController = TextEditingController(
      text: item.maxQuantity > 0 ? item.maxQuantity.toString() : '',
    );
    bool isRequired = item.isRequired;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Package Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Quantity
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Price per unit
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Unit',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Min & Max quantity
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: minQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Min Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: maxQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Max Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Required switch
              StatefulBuilder(
                builder: (context, setState) {
                  return SwitchListTile(
                    title: const Text('Required Item'),
                    subtitle: const Text('Must be included in the package'),
                    value: isRequired,
                    onChanged: (value) {
                      setState(() {
                        isRequired = value;
                      });
                    },
                  );
                },
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
              final quantity = int.tryParse(quantityController.text) ?? 1;
              final price = double.tryParse(priceController.text) ?? 0.0;
              final description = descriptionController.text.trim();
              final minQuantity = int.tryParse(minQuantityController.text) ?? 0;
              final maxQuantity = int.tryParse(maxQuantityController.text) ?? 0;
              
              final updatedItem = item.copyWith(
                quantity: quantity,
                pricePerUnit: price,
                description: description,
                isRequired: isRequired,
                minQuantity: minQuantity,
                maxQuantity: maxQuantity,
              );
              
              setState(() {
                _packageItems[index] = updatedItem;
              });
              
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    ).then((_) {
      // Dispose controllers
      quantityController.dispose();
      priceController.dispose();
      descriptionController.dispose();
      minQuantityController.dispose();
      maxQuantityController.dispose();
    });
  }

  void _addPackageItem(CateringItem cateringItem, int quantity, bool isRequired) {
    final newItem = PackageItem(
      itemId: cateringItem.id,
      name: cateringItem.name,
      quantity: quantity,
      pricePerUnit: cateringItem.price,
      description: cateringItem.description,
      isRequired: isRequired,
    );
    
    setState(() {
      // Check if item already exists
      final existingIndex = _packageItems.indexWhere((item) => item.itemId == cateringItem.id);
      
      if (existingIndex >= 0) {
        // Update existing item
        final existingItem = _packageItems[existingIndex];
        _packageItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated quantity for ${cateringItem.name}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Add new item
        _packageItems.add(newItem);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${cateringItem.name} to package'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
  
  void _removeItem(int index) {
    final item = _packageItems[index];
    
    setState(() {
      _packageItems.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${item.name} from package'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _packageItems.insert(index, item);
            });
          },
        ),
      ),
    );
  }
}

class _ItemSelectionDialog extends StatefulWidget {
  final List<CateringItem> items;
  final Function(CateringItem, int, bool) onItemSelected;
  
  const _ItemSelectionDialog({
    required this.items,
    required this.onItemSelected,
  });

  @override
  _ItemSelectionDialogState createState() => _ItemSelectionDialogState();
}

class _ItemSelectionDialogState extends State<_ItemSelectionDialog> {
  String _searchQuery = '';
  int _quantity = 1;
  bool _isRequired = false;
  CateringItem? _selectedItem;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Filter items based on search
    final filteredItems = widget.items
        .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    
    return AlertDialog(
      title: const Text('Add Item to Package'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Items',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Items list
            SizedBox(
              height: 300,
              child: filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'No items found',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isSelected = _selectedItem?.id == item.id;
                        
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.restaurant_menu,
                                color: isSelected
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: isSelected
                                ? TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  )
                                : null,
                          ),
                          subtitle: Text(
                            '\$${item.price.toStringAsFixed(2)}${item.description.isNotEmpty ? ' • ${item.description}' : ''}',
                          ),
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedItem = item;
                            });
                          },
                        );
                      },
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Item options (only shown when an item is selected)
            if (_selectedItem != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Item:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _selectedItem!.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${_selectedItem!.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Quantity selector
              Row(
                children: [
                  const Text('Quantity:'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _quantity > 1
                        ? () {
                            setState(() {
                              _quantity--;
                            });
                          }
                        : null,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
              
              // Required switch
              SwitchListTile(
                title: const Text('Required Item'),
                subtitle: const Text('This item must be included in the package'),
                value: _isRequired,
                onChanged: (value) {
                  setState(() {
                    _isRequired = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedItem != null
              ? () => widget.onItemSelected(_selectedItem!, _quantity, _isRequired)
              : null,
          child: const Text('Add to Package'),
        ),
      ],
    );
  }
}