import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/catalog_service.dart';
import 'package:uuid/uuid.dart';

class CategoryForm extends ConsumerStatefulWidget {
  final CatalogCategory? category;
  final Function(CatalogCategory) onSave;
  final VoidCallback onCancel;

  const CategoryForm({
    super.key,
    this.category,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  int _sortOrder = 0;
  bool _isActive = true;
  final bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.category != null;

    if (_isEditMode) {
      // Populate form fields with existing category data
      _nameController.text = widget.category!.name;
      _imageUrlController.text = widget.category!.imageUrl;
      _sortOrder = widget.category!.sortOrder;
      _isActive = widget.category!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditMode ? 'Edit Category' : 'Add New Category',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Category Icon/Image Preview
              _buildImagePreview(),
              const SizedBox(height: 16),

              // Image URL field
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'Enter URL for category image',
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
                  labelText: 'Category Name',
                  hintText: 'Enter category name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sort Order field
              TextFormField(
                initialValue: _sortOrder.toString(),
                decoration: const InputDecoration(
                  labelText: 'Sort Order',
                  hintText: 'Enter numeric sort order (lower appears first)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    _sortOrder = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Active switch
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Toggle category visibility'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
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
                        : Text(_isEditMode ? 'Update Category' : 'Add Category'),
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
      aspectRatio: 3 / 1,
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
                child: Icon(Icons.category, size: 48),
              ),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Create or update the category
    final category = CatalogCategory(
      id: _isEditMode ? widget.category!.id : const Uuid().v4(),
      name: _nameController.text,
      imageUrl: _imageUrlController.text,
      sortOrder: _sortOrder,
      isActive: _isActive,
    );

    widget.onSave(category);
  }
}