 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/available_items_for_packages_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_category_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/unified_catering_package_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_packages_provider.dart'; 
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/form/catering_package_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_category_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_package_model.dart';
 
class CateringPackageScreen extends ConsumerStatefulWidget {
  const CateringPackageScreen({super.key});

  @override
  ConsumerState<CateringPackageScreen> createState() => _CateringPackageScreenState();
}

class _CateringPackageScreenState extends ConsumerState<CateringPackageScreen> {
  String? _selectedCategoryId;
  bool _showOnlyPromoted = false;
  
  void _showPackageForm({CateringPackage? package}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CateringPackageForm(package: package),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packageAsyncValue = ref.watch(cateringPackagesProvider);
    final categoriesAsyncValue = ref.watch(cateringCategoryRepositoryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final isDesktop = size.width >= 1100;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Packages'),
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
            child: packageAsyncValue.when(
              data: (packages) {
                // Apply filters
                var filteredPackages = List<CateringPackage>.from(packages);
                if (_selectedCategoryId != null) {
                  filteredPackages = filteredPackages
                      .where((package) => package.categoryIds.contains(_selectedCategoryId))
                      .toList();
                }
                if (_showOnlyPromoted) {
                  filteredPackages = filteredPackages
                      .where((package) => package.isPromoted)
                      .toList();
                }
                
                if (filteredPackages.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }
                
                if (isDesktop) {
                  return _buildDesktopPackageList(filteredPackages, colorScheme);
                } else if (isTablet) {
                  return _buildTabletPackageGrid(filteredPackages, colorScheme);
                } else {
                  return _buildMobilePackageList(filteredPackages, colorScheme);
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPackageForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Package'),
      ),
    );
  }

  Widget _buildFilterBar(AsyncValue<List<CateringCategory>> categoriesAsyncValue, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
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
                      vertical: 8,
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
            label: const Text('Promoted'),
            selected: _showOnlyPromoted,
            onSelected: (selected) {
              setState(() {
                _showOnlyPromoted = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
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
            _selectedCategoryId != null || _showOnlyPromoted
                ? 'No Packages Match Your Filters'
                : 'No Packages Added Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategoryId != null || _showOnlyPromoted
                ? 'Try adjusting your filters'
                : 'Add your first catering package to get started',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (_selectedCategoryId != null || _showOnlyPromoted)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCategoryId = null;
                  _showOnlyPromoted = false;
                });
              },
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Clear Filters'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _showPackageForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Package'),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopPackageList(List<CateringPackage> packages, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Packages (${packages.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showPackageForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('New Package'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Categories')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Promoted')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: packages.map((package) {
                      final categories = ref.watch(packageCategoriesProvider(package));
                      
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                if (package.iconCodePoint != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      IconData(
                                        package.iconCodePoint!,
                                        fontFamily: package.iconFontFamily,
                                      ),
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      package.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (package.description.isNotEmpty)
                                      Text(
                                        package.description,
                                        style: Theme.of(context).textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              '\$${package.basePrice.toStringAsFixed(2)}',
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
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: package.isActive,
                              onChanged: (value) {
                                ref.read(unifiedCateringPackageRepositoryProvider.notifier)
                                    .togglePackageStatus(package.id, value);
                              },
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: package.isPromoted,
                              onChanged: (value) {
                                ref.read(unifiedCateringPackageRepositoryProvider.notifier)
                                    .togglePromoted(package.id, value);
                              },
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit',
                                  onPressed: () => _showPackageForm(package: package),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete',
                                  onPressed: () => _showDeleteConfirmation(package),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletPackageGrid(List<CateringPackage> packages, ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        final categories = ref.watch(packageCategoriesProvider(package));
        
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showPackageForm(package: package),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status and actions
                Container(
                  color: package.isPromoted
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      if (package.isPromoted)
                        Icon(
                          Icons.star,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                      Expanded(
                        child: Text(
                          package.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Switch(
                        value: package.isActive,
                        onChanged: (value) {
                          ref.read(unifiedCateringPackageRepositoryProvider.notifier)
                              .togglePackageStatus(package.id, value);
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
                            if (package.iconCodePoint != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  IconData(
                                    package.iconCodePoint!,
                                    fontFamily: package.iconFontFamily,
                                  ),
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\$${package.basePrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  '${package.items.length} items',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          package.description,
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
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Actions
                ButtonBar(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      onPressed: () => _showPackageForm(package: package),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      onPressed: () => _showDeleteConfirmation(package),
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

  Widget _buildMobilePackageList(List<CateringPackage> packages, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        final categories = ref.watch(packageCategoriesProvider(package));
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showPackageForm(package: package),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                if (package.isPromoted)
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
                          'Promoted Package',
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
                      if (package.iconCodePoint != null)
                        Container(
                          width: 56,
                          height: 56,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            IconData(
                              package.iconCodePoint!,
                              fontFamily: package.iconFontFamily,
                            ),
                            color: colorScheme.onPrimaryContainer,
                            size: 28,
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
                                    package.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${package.basePrice.toStringAsFixed(2)}',
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
                              package.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${package.items.length} items',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                            value: package.isActive,
                            onChanged: (value) {
                              ref.read(unifiedCateringPackageRepositoryProvider.notifier)
                                  .togglePackageStatus(package.id, value);
                            },
                          ),
                          Text(
                            package.isActive ? 'Active' : 'Inactive',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit',
                            onPressed: () => _showPackageForm(package: package),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                            onPressed: () => _showDeleteConfirmation(package),
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

  void _showDeleteConfirmation(CateringPackage package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Are you sure you want to delete "${package.name}"?'),
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
              ref.read(unifiedCateringPackageRepositoryProvider.notifier).deletePackage(package.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${package.name} has been deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}