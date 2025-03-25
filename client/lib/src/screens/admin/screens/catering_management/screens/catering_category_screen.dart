import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_category_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/form/catering_category_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_category_model.dart';

class CateringCategoryScreen extends ConsumerStatefulWidget {
  const CateringCategoryScreen({super.key});

  @override
  ConsumerState<CateringCategoryScreen> createState() =>
      _CateringCategoryScreenState();
}

class _CateringCategoryScreenState
    extends ConsumerState<CateringCategoryScreen> {
  final bool _isLoading = false;

  void _showCategoryForm({CateringCategory? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CateringCategoryForm(
        category: category,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(cateringCategoryRepositoryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
      ),
      body: categories.when(
        data: (categoryList) =>
            _buildCategoryList(categoryList, colorScheme, isDesktop),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildCategoryList(List<CateringCategory> categories,
      ColorScheme colorScheme, bool isDesktop) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Categories Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first catering category to get started',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCategoryForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        ),
      );
    }

    if (isDesktop) {
      return _buildDesktopCategoryList(categories, colorScheme);
    } else {
      return _buildMobileCategoryList(categories, colorScheme);
    }
  }

  Widget _buildDesktopCategoryList(
      List<CateringCategory> categories, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Categories',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('New Category'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: categories
                      .map((category) => DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    if (category.iconName != null)
                                      Icon(
                                        _getIconData(category.iconName),
                                        color: colorScheme.primary,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(category.name),
                                  ],
                                ),
                              ),
                              DataCell(Text(
                                category.description,
                                overflow: TextOverflow.ellipsis,
                              )),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: category.isActive
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: category.isActive
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Edit',
                                      onPressed: () =>
                                          _showCategoryForm(category: category),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Delete',
                                      onPressed: () =>
                                          _showDeleteConfirmation(category),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCategoryList(
      List<CateringCategory> categories, ColorScheme colorScheme) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = categories.removeAt(oldIndex);
          categories.insert(newIndex, item);
        });

        // Update the order in the database
        ref
            .read(cateringCategoryRepositoryProvider.notifier)
            .reorderCategories(categories);
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          key: ValueKey(category.id),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category.iconName != null
                    ? _getIconData(category.iconName)
                    : Icons.category_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.isActive
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      color: category.isActive
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  onPressed: () => _showCategoryForm(category: category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  onPressed: () => _showDeleteConfirmation(category),
                ),
              ],
            ),
            onTap: () => _showCategoryForm(category: category),
          ),
        );
      },
    );
  }

  // Helper method to safely convert icon name to IconData
  IconData _getIconData(String? iconName) {
    // Default icon if parsing fails
    if (iconName == null) return Icons.category_outlined;

    // Map of common icon names to their corresponding IconData constants
    final Map<String, IconData> iconMap = {
      '0xe318': Icons.restaurant, // Example mapping
      '0xe5d2': Icons.menu_book,
      '0xe25a': Icons.fastfood,
      '0xe57f': Icons.local_bar,
      '0xe544': Icons.icecream,
      '0xe532': Icons.cake,
      '0xe532': Icons.breakfast_dining,
      '0xe574': Icons.lunch_dining,
      '0xe574': Icons.dinner_dining,
      '0xe3f8': Icons.category_outlined,
      // Add more mappings as needed
    };

    // Try to find the icon in our map
    return iconMap[iconName] ?? Icons.category_outlined;
  }

  void _showDeleteConfirmation(CateringCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              ref
                  .read(cateringCategoryRepositoryProvider.notifier)
                  .deleteCategory(category.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${category.name} has been deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
