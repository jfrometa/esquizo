import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catalog/catalog_service.dart';

import 'package:uuid/uuid.dart';

class ProductForm extends ConsumerStatefulWidget {
  final CatalogItem? product;
  final Function(CatalogItem) onSave;
  final VoidCallback onCancel;

  const ProductForm({
    super.key,
    this.product,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategoryId = '';
  bool _isAvailable = true;
  final Map<String, dynamic> _metadata = {};

  final bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.product != null;

    if (_isEditMode) {
      // Populate form fields with existing product data
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _selectedCategoryId = widget.product!.categoryId;
      _isAvailable = widget.product!.isAvailable;
      _metadata.addAll(widget.product!.metadata);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogType = ref.watch(currentCatalogTypeProvider);
    final categoriesAsync = ref.watch(catalogCategoriesProvider(catalogType));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditMode ? 'Edit Product' : 'Add New Product',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Product Image Preview
              _buildImagePreview(),
              const SizedBox(height: 16),

              // Image URL field
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'Enter URL for product image',
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
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category dropdown
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Text(
                        'No categories available. Please create a category first.');
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

                  // Include ALL categories in dropdown (including inactive ones)
                  // when the category is already selected
                  final dropdownItems = categories
                      .where((category) =>
                          category.isActive ||
                          category.id == _selectedCategoryId)
                      .map((category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name +
                                (category.isActive ? '' : ' (Inactive)')),
                          ))
                      .toList();

                  // Only set value if it exists in items
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

              // Price field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: 'Enter product price',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter product description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Availability switch
              SwitchListTile(
                title: const Text('Available'),
                subtitle: const Text('Toggle product availability'),
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Custom metadata section - expandable
              ExpansionTile(
                title: const Text('Additional Options'),
                children: [
                  _buildMetadataFields(),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Option'),
                    onPressed: _addMetadataField,
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
                        : Text(_isEditMode ? 'Update Product' : 'Add Product'),
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
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
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  ),
                ),
              )
            : const Center(
                child: Icon(Icons.image, size: 48),
              ),
      ),
    );
  }

  Widget _buildMetadataFields() {
    return Column(
      children: _metadata.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: entry.key,
                  decoration: const InputDecoration(
                    labelText: 'Option',
                    hintText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final oldValue = entry.value;
                    _metadata.remove(entry.key);
                    _metadata[value] = oldValue;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: entry.value.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    hintText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _metadata[entry.key] = value;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _metadata.remove(entry.key);
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _addMetadataField() {
    setState(() {
      _metadata['option${_metadata.length + 1}'] = '';
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;

    // Create or update the product
    final product = CatalogItem(
      id: _isEditMode ? widget.product!.id : const Uuid().v4(),
      name: _nameController.text,
      description: _descriptionController.text,
      price: price,
      imageUrl: _imageUrlController.text,
      categoryId: _selectedCategoryId,
      isAvailable: _isAvailable,
      metadata: _metadata,
    );

    widget.onSave(product);
  }
}
