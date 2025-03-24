import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/meal_plan_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/plans/plans.dart';
import 'package:uuid/uuid.dart'; 

class MealPlanForm extends ConsumerStatefulWidget {
  final MealPlan? mealPlan;
  final Function(MealPlan) onSave;
  final VoidCallback onCancel;

  const MealPlanForm({
    Key? key,
    this.mealPlan,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  ConsumerState<MealPlanForm> createState() => _MealPlanFormState();
}

class _MealPlanFormState extends ConsumerState<MealPlanForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _longDescriptionController = TextEditingController();
  final _howItWorksController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _totalMealsController = TextEditingController();
  final _mealsRemainingController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerIdController = TextEditingController();
  
  List<TextEditingController> _featureControllers = [];
  
  String _selectedCategoryId = '';
  MealPlanStatus _status = MealPlanStatus.active;
  bool _isAvailable = true;
  bool _isBestValue = false;
  DateTime? _expiryDate;
  
  final bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.mealPlan != null;

    if (_isEditMode) {
      // Populate form fields with existing meal plan data
      _titleController.text = widget.mealPlan!.title;
      _priceController.text = widget.mealPlan!.price;
      _originalPriceController.text = widget.mealPlan!.originalPrice.toString();
      _descriptionController.text = widget.mealPlan!.description;
      _longDescriptionController.text = widget.mealPlan!.longDescription;
      _howItWorksController.text = widget.mealPlan!.howItWorks;
      _imageUrlController.text = widget.mealPlan!.img;
      _totalMealsController.text = widget.mealPlan!.totalMeals.toString();
      _mealsRemainingController.text = widget.mealPlan!.mealsRemaining.toString();
      _ownerNameController.text = widget.mealPlan!.ownerName;
      _ownerIdController.text = widget.mealPlan!.ownerId;
      
      _selectedCategoryId = widget.mealPlan!.categoryId;
      _status = widget.mealPlan!.status;
      _isAvailable = widget.mealPlan!.isAvailable;
      _isBestValue = widget.mealPlan!.isBestValue;
      _expiryDate = widget.mealPlan!.expiryDate;
      
      // Set up feature controllers
      _setupFeatureControllers(widget.mealPlan!.features);
    } else {
      // Add default empty feature
      _addFeature();
    }
  }
  
  void _setupFeatureControllers(List<String> features) {
    _featureControllers = [];
    for (final feature in features) {
      final controller = TextEditingController(text: feature);
      _featureControllers.add(controller);
    }
    if (_featureControllers.isEmpty) {
      _addFeature();
    }
  }
  
  void _addFeature() {
    setState(() {
      _featureControllers.add(TextEditingController());
    });
  }
  
  void _removeFeature(int index) {
    setState(() {
      _featureControllers[index].dispose();
      _featureControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _descriptionController.dispose();
    _longDescriptionController.dispose();
    _howItWorksController.dispose();
    _imageUrlController.dispose();
    _totalMealsController.dispose();
    _mealsRemainingController.dispose();
    _ownerNameController.dispose();
    _ownerIdController.dispose();
    
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(mealPlanCategoriesProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditMode ? 'Edit Meal Plan' : 'Add New Meal Plan',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Image section
              Text(
                'Plan Image',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Image preview
              _buildImagePreview(),
              const SizedBox(height: 8),
              
              // Image URL field
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'Enter URL for meal plan image',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {});
                    },
                    tooltip: 'Refresh preview',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Basic information section
              Text(
                'Basic Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Plan Title',
                  hintText: 'Enter meal plan title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a meal plan title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Text('No categories available. Please create a category first.');
                  }

                  // Check if the selected category exists in the list
                  final selectedCategoryExists = categories
                      .any((category) => category.id == _selectedCategoryId);
                  
                  // Reset selected category if it doesn't exist or if none is selected
                  if (!selectedCategoryExists && categories.isNotEmpty) {
                    // Use Future.microtask to avoid setState during build
                    Future.microtask(() {
                      setState(() {
                        _selectedCategoryId = categories.first.id;
                      });
                    });
                  }

                  final dropdownItems = categories
                      .where((category) => 
                        category.isActive || category.id == _selectedCategoryId)
                      .map((category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name + 
                                (category.isActive ? '' : ' (Inactive)')),
                          ))
                      .toList();
                  
                  final dropdownValue = dropdownItems
                      .any((item) => item.value == _selectedCategoryId)
                      ? _selectedCategoryId
                      : null;

                  return DropdownButtonFormField<String>(
                    value: dropdownValue,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: dropdownItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading categories'),
              ),
              const SizedBox(height: 16),

              // Price fields - side by side
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        hintText: 'Enter plan price',
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
                        try {
                          final price = double.parse(value);
                          if (price <= 0) {
                            return 'Price must be greater than zero';
                          }
                        } catch (e) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Original Price (optional)',
                        hintText: 'Enter original price if discounted',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Meals count - side by side
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalMealsController,
                      decoration: const InputDecoration(
                        labelText: 'Total Meals',
                        hintText: 'Enter total meals in plan',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter total meals';
                        }
                        try {
                          final meals = int.parse(value);
                          if (meals <= 0) {
                            return 'Meals must be greater than zero';
                          }
                        } catch (e) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _mealsRemainingController,
                      decoration: const InputDecoration(
                        labelText: 'Meals Remaining',
                        hintText: 'Enter remaining meals',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter remaining meals';
                        }
                        try {
                          final meals = int.parse(value);
                          if (meals < 0) {
                            return 'Remaining meals cannot be negative';
                          }
                          
                          final totalMeals = int.tryParse(_totalMealsController.text) ?? 0;
                          if (meals > totalMeals) {
                            return 'Remaining meals cannot exceed total meals';
                          }
                        } catch (e) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Short description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Short Description',
                  hintText: 'Enter a short description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Detailed information section
              Text(
                'Detailed Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Long description
              TextFormField(
                controller: _longDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Long Description',
                  hintText: 'Enter a detailed description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a long description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // How it works
              TextFormField(
                controller: _howItWorksController,
                decoration: const InputDecoration(
                  labelText: 'How It Works',
                  hintText: 'Explain how the meal plan works',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please explain how the meal plan works';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Features section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Features',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Feature'),
                    onPressed: _addFeature,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Feature list
              ..._buildFeatureFields(),
              const SizedBox(height: 24),
              
              // Additional settings section
              Text(
                'Additional Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Status dropdown
              DropdownButtonFormField<MealPlanStatus>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: MealPlanStatus.values.map((status) {
                  return DropdownMenuItem<MealPlanStatus>(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Expiry date picker
              Row(
                children: [
                  Text(
                    'Expiry Date (Optional):',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _expiryDate != null
                          ? DateFormat.yMMMd().format(_expiryDate!)
                          : 'No Date Selected',
                    ),
                    onPressed: () => _selectExpiryDate(context),
                  ),
                  if (_expiryDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _expiryDate = null;
                        });
                      },
                      tooltip: 'Clear date',
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Owner information (if assigning to a specific customer)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name (Optional)',
                        hintText: 'Customer name if assigned',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ownerIdController,
                      decoration: const InputDecoration(
                        labelText: 'Owner ID (Optional)',
                        hintText: 'Customer ID if assigned',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Toggle switches
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Available'),
                      subtitle: const Text('Toggle plan availability'),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Best Value'),
                      subtitle: const Text('Mark as best value option'),
                      value: _isBestValue,
                      onChanged: (value) {
                        setState(() {
                          _isBestValue = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditMode ? 'Update Plan' : 'Add Plan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _imageUrlController.text.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _imageUrlController.text,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
              ),
            )
          : const Center(
              child: Icon(Icons.image, size: 48),
            ),
    );
  }
  
  List<Widget> _buildFeatureFields() {
    return List.generate(_featureControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _featureControllers[index],
                decoration: InputDecoration(
                  labelText: 'Feature ${index + 1}',
                  hintText: 'Enter feature or benefit',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (index == 0 && (value == null || value.isEmpty)) {
                    return 'Please enter at least one feature';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _featureControllers.length > 1
                  ? () => _removeFeature(index)
                  : null,
              tooltip: 'Remove feature',
            ),
          ],
        ),
      );
    });
  }
  
  String _getStatusText(MealPlanStatus status) {
    switch (status) {
      case MealPlanStatus.active:
        return 'Active';
      case MealPlanStatus.inactive:
        return 'Inactive';
      case MealPlanStatus.discontinued:
        return 'Discontinued';
    }
  }
  
  Future<void> _selectExpiryDate(BuildContext context) async {
    final initialDate = _expiryDate ?? DateTime.now().add(const Duration(days: 30));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // 5 years from now
    );
    
    if (pickedDate != null && pickedDate != _expiryDate) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Get features from controllers, removing empty ones
    final features = _featureControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    final totalMeals = int.tryParse(_totalMealsController.text) ?? 0;
    final mealsRemaining = int.tryParse(_mealsRemainingController.text) ?? 0;
    final originalPrice = double.tryParse(_originalPriceController.text) ?? 0.0;
    
    // Get category name
    String categoryName = '';
    final categoriesAsync = ref.read(mealPlanCategoriesProvider);
    categoriesAsync.whenData((categories) {
      final category = categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => MealPlanCategory(
          name: 'Unknown',
          businessId: ref.read(currentBusinessIdProvider),
        ),
      );
      categoryName = category.name;
    });
    
    // Create or update the meal plan
    final mealPlan = MealPlan(
      id: _isEditMode ? widget.mealPlan!.id : null,
      title: _titleController.text.trim(),
      price: _priceController.text.trim(),
      originalPrice: originalPrice,
      description: _descriptionController.text.trim(),
      longDescription: _longDescriptionController.text.trim(),
      howItWorks: _howItWorksController.text.trim(),
      img: _imageUrlController.text.trim(),
      totalMeals: totalMeals,
      mealsRemaining: mealsRemaining,
      features: features,
      isBestValue: _isBestValue,
      isAvailable: _isAvailable,
      status: _status,
      categoryId: _selectedCategoryId,
      categoryName: categoryName,
      expiryDate: _expiryDate,
      ownerId: _ownerIdController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      businessId: ref.read(currentBusinessIdProvider),
      // If editing, keep existing allowed items and consumed items
      allowedItemIds: _isEditMode ? widget.mealPlan!.allowedItemIds : [],
      consumedItems: _isEditMode ? widget.mealPlan!.consumedItems : [],
      // If editing, keep created date and set updated date
      createdAt: _isEditMode ? widget.mealPlan!.createdAt : null,
      updatedAt: _isEditMode ? DateTime.now() : null,
    );

    widget.onSave(mealPlan);
  }
}