import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/catering/catering_category_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_category_model.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/icon_mapper.dart';

class CateringCategoryForm extends ConsumerStatefulWidget {
  final CateringCategory? category;

  const CateringCategoryForm({
    super.key,
    this.category,
  });

  @override
  ConsumerState<CateringCategoryForm> createState() =>
      _CateringCategoryFormState();
}

class _CateringCategoryFormState extends ConsumerState<CateringCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _tagsController;
  bool _isActive = false;
  String? _selectedIcon;
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
    final category = widget.category ?? CateringCategory.empty();
    _nameController = TextEditingController(text: category.name);
    _descriptionController = TextEditingController(text: category.description);
    _imageUrlController = TextEditingController(text: category.imageUrl);
    _tagsController = TextEditingController(text: category.tags.join(', '));
    _isActive = category.isActive;
    _selectedIcon = category.iconName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final tags = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

        final category = (widget.category ?? CateringCategory.empty()).copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          isActive: _isActive,
          tags: tags,
          iconName: _selectedIcon,
        );

        final repository =
            ref.read(cateringCategoryRepositoryProvider.notifier);

        if (category.id.isEmpty) {
          await repository.addCategory(category);
        } else {
          await repository.updateCategory(category);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                category.id.isEmpty
                    ? 'Category added successfully'
                    : 'Category updated successfully',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
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
    final isEdit = widget.category != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.sizeOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final isDesktop = mediaQuery.width >= 1100;

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _selectedIcon != null
                        ? Icon(
                            IconMapper.getIconData(_selectedIcon),
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
                      isEdit ? 'Edit Category' : 'New Category',
                      style: theme.textTheme.headlineSmall,
                    ),
                    Text(
                      'Configure your catering category details',
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

          // Basic information
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
              labelText: 'Category Name',
              hintText: 'Enter category name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label_outline),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a category name';
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
              hintText: 'Enter category description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_outlined),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
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

          // Active status
          SwitchListTile(
            title: const Text('Active'),
            subtitle: const Text('Toggle to enable or disable this category'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            secondary: Icon(
              _isActive ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
              color: _isActive ? colorScheme.primary : null,
            ),
          ),

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _isLoading ? null : _saveCategory,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(isEdit ? 'Update Category' : 'Create Category'),
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: form,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 16 + viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: form,
            ),
          ),
        ],
      ),
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                      final isSelected =
                          _selectedIcon == iconData.codePoint.toString();

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIcon = iconData.codePoint.toString();
                          });
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                iconName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
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
}
