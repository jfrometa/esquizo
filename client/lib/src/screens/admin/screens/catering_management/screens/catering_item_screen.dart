import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_category_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_item_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/form/catering_item_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_category_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_item_model.dart';
import 'package:starter_architecture_flutter_firebase/src/utils/icon_mapper.dart';

class CateringItemScreen extends ConsumerStatefulWidget {
  const CateringItemScreen({super.key});

  @override
  ConsumerState<CateringItemScreen> createState() => _CateringItemScreenState();
}

class _CateringItemScreenState extends ConsumerState<CateringItemScreen> {
  String? _selectedCategoryId;
  bool _showOnlyHighlighted = false;
  bool _showInactiveItems = false;
  String _searchQuery = '';

  void _showItemForm({CateringItem? item}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CateringItemForm(item: item),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsyncValue = ref.watch(cateringItemRepositoryProvider);
    final categoriesAsyncValue = ref.watch(cateringCategoryRepositoryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 600;
    final isDesktop = size.width >= 1100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Items'),
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
      body: Column(
        children: [
          _buildFilterBar(categoriesAsyncValue, colorScheme),
          Expanded(
            child: itemsAsyncValue.when(
              data: (items) {
                // Apply filters
                var filteredItems = items;

                // Filter by category
                if (_selectedCategoryId != null) {
                  filteredItems = filteredItems
                      .where((item) =>
                          item.categoryIds.contains(_selectedCategoryId))
                      .toList();
                }

                // Filter by highlight
                if (_showOnlyHighlighted) {
                  filteredItems = filteredItems
                      .where((item) => item.isHighlighted)
                      .toList();
                }

                // Filter by active status
                if (!_showInactiveItems) {
                  filteredItems =
                      filteredItems.where((item) => item.isActive).toList();
                }

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  filteredItems = filteredItems
                      .where((item) =>
                          item.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          item.description
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          (item.tags.any((tag) => tag
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))))
                      .toList();
                }

                if (filteredItems.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }

                if (isDesktop) {
                  return _buildDesktopItemList(filteredItems, colorScheme);
                } else if (isTablet) {
                  return _buildTabletItemGrid(filteredItems, colorScheme);
                } else {
                  return _buildMobileItemList(filteredItems, colorScheme);
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildFilterBar(
      AsyncValue<List<CateringCategory>> categoriesAsyncValue,
      ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Filter options
          Row(
            children: [
              Expanded(
                child: categoriesAsyncValue.when(
                  data: (categories) {
                    return DropdownButtonFormField<String?>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      value: _selectedCategoryId,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...categories.map(
                          (category) => DropdownMenuItem<String?>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Failed to load categories'),
                ),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Highlighted'),
                selected: _showOnlyHighlighted,
                onSelected: (selected) {
                  setState(() {
                    _showOnlyHighlighted = selected;
                  });
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Show Inactive'),
                selected: _showInactiveItems,
                onSelected: (selected) {
                  setState(() {
                    _showInactiveItems = selected;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    final hasFilters = _selectedCategoryId != null ||
        _showOnlyHighlighted ||
        _searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No Items Match Your Filters' : 'No Items Added Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters'
                : 'Add your first catering item to get started',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (hasFilters)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategoryId = null;
                  _showOnlyHighlighted = false;
                  _searchQuery = '';
                  _showInactiveItems = false;
                });
              },
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Clear Filters'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _showItemForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopItemList(
      List<CateringItem> items, ColorScheme colorScheme) {
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
                    'All Items (${items.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showItemForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('New Item'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Categories')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Highlighted')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: items.map((item) {
                      final categories =
                          ref.watch(itemCategoriesProvider(item));

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                if (item.iconCodePoint != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      categories.first.iconName != null
                                          ? IconMapper.getIconData(
                                              categories.first.iconName)
                                          : Icons.category_outlined,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (item.description.isNotEmpty)
                                      Text(
                                        item.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          DataCell(
                            Wrap(
                              spacing: 4,
                              children: categories.map((category) {
                                return Chip(
                                  label: Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.primaryContainer,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: item.isActive,
                              onChanged: (value) {
                                ref
                                    .read(
                                        cateringItemRepositoryProvider.notifier)
                                    .toggleItemStatus(item.id, value);
                              },
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: item.isHighlighted,
                              onChanged: (value) {
                                ref
                                    .read(
                                        cateringItemRepositoryProvider.notifier)
                                    .toggleHighlighted(item.id, value);
                              },
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit',
                                  onPressed: () => _showItemForm(item: item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete',
                                  onPressed: () =>
                                      _showDeleteConfirmation(item),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletItemGrid(
      List<CateringItem> items, ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final categories = ref.watch(itemCategoriesProvider(item));

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showItemForm(item: item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and highlights
                Container(
                  color: item.isHighlighted
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      if (item.isHighlighted)
                        Icon(
                          Icons.star,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                      Expanded(
                        child: Text(
                          item.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      Switch(
                        value: item.isActive,
                        onChanged: (value) {
                          ref
                              .read(cateringItemRepositoryProvider.notifier)
                              .toggleItemStatus(item.id, value);
                        },
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (item.iconCodePoint != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  categories.first.iconName != null
                                      ? IconMapper.getIconData(
                                          categories.first.iconName)
                                      : Icons.category_outlined,
                                  color: colorScheme.primary,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: categories.map((category) {
                            return Chip(
                              label: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              backgroundColor: colorScheme.primaryContainer,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                OverflowBar(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      onPressed: () => _showItemForm(item: item),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      onPressed: () => _showDeleteConfirmation(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileItemList(
      List<CateringItem> items, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final categories = ref.watch(itemCategoriesProvider(item));

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showItemForm(item: item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlighted badge
                if (item.isHighlighted)
                  Container(
                    color: colorScheme.primaryContainer,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: colorScheme.onPrimaryContainer,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Highlighted Item',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      if (item.iconCodePoint != null)
                        Container(
                          width: 56,
                          height: 56,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            categories.first.iconName != null
                                ? IconMapper.getIconData(
                                    categories.first.iconName)
                                : Icons.category_outlined,
                            color: colorScheme.primary,
                          ),
                        ),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Text(
                                  '\$${item.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.preparationTimeMinutes > 0
                                      ? '${item.preparationTimeMinutes} min'
                                      : 'Prep time not set',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: categories.map((category) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Active switch
                          Switch(
                            value: item.isActive,
                            onChanged: (value) {
                              ref
                                  .read(cateringItemRepositoryProvider.notifier)
                                  .toggleItemStatus(item.id, value);
                            },
                          ),
                          Text(
                            item.isActive ? 'Active' : 'Inactive',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                            onPressed: () => _showItemForm(item: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                            onPressed: () => _showDeleteConfirmation(item),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(CateringItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
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
                  .read(cateringItemRepositoryProvider.notifier)
                  .deleteItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.name} has been deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
