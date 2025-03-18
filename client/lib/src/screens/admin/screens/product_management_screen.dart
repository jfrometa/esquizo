import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/category_form.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/product_form.dart';
import '../../../core/providers/catalog/catalog_provider.dart';
import '../../../core/services/catalog_service.dart';
import '../widgets/responsive_layout.dart';


class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends ConsumerState<ProductManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryId = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
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
      body: Column(
        children: [
          // Tab bar for products/categories
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Products'),
                      Tab(text: 'Categories'),
                    ],
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                    isScrollable: true,
                  ),
                ),
                const SizedBox(width: 16),
                // Search field
                if (isDesktop)
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Mobile search field
          if (!isDesktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showAddProductDialog();
          } else {
            _showAddCategoryDialog();
          }
        },
        tooltip: _tabController.index == 0 ? 'Add Product' : 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildProductsTab() {
    final catalogType = ref.watch(currentCatalogTypeProvider);
    final productsAsync = ref.watch(catalogItemsProvider(catalogType));
    final categoriesAsync = ref.watch(catalogCategoriesProvider(catalogType));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filter chips
        categoriesAsync.when(
          data: (categories) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategoryId.isEmpty,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = '';
                          });
                        },
                      ),
                    ),
                    ...categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = selected ? category.id : '';
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
        
        // Products list
        Expanded(
          child: productsAsync.when(
            data: (products) {
              // Filter products based on search and category
              final filteredProducts = products.where((product) {
                final matchesSearch = _searchQuery.isEmpty || 
                  product.name.toLowerCase().contains(_searchQuery) ||
                  product.description.toLowerCase().contains(_searchQuery);
                  
                final matchesCategory = _selectedCategoryId.isEmpty || 
                  product.categoryId == _selectedCategoryId;
                  
                return matchesSearch && matchesCategory;
              }).toList();
              
              if (filteredProducts.isEmpty) {
                return const Center(
                  child: Text('No products found'),
                );
              }
              
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ResponsiveGridView(
                  children: filteredProducts.map((product) => 
                    _buildProductCard(product)
                  ).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoriesTab() {
    final catalogType = ref.watch(currentCatalogTypeProvider);
    final categoriesAsync = ref.watch(catalogCategoriesProvider(catalogType));
    
    return categoriesAsync.when(
      data: (categories) {
        // Filter categories based on search
        final filteredCategories = categories.where((category) {
          return _searchQuery.isEmpty || 
            category.name.toLowerCase().contains(_searchQuery);
        }).toList();
        
        if (filteredCategories.isEmpty) {
          return const Center(
            child: Text('No categories found'),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveGridView(
            children: filteredCategories.map((category) => 
              _buildCategoryCard(category)
            ).toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
  
  Widget _buildProductCard(CatalogItem product) {
    final theme = Theme.of(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showEditProductDialog(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.image_not_supported,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.restaurant_menu,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: product.isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Product price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Product description
                  Text(
                    product.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditProductDialog(product),
                        tooltip: 'Edit',
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(
                          product.isAvailable ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () => _toggleProductAvailability(product),
                        tooltip: product.isAvailable ? 'Mark as unavailable' : 'Mark as available',
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _confirmDeleteProduct(product),
                        tooltip: 'Delete',
                        visualDensity: VisualDensity.compact,
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
  }
  
  Widget _buildCategoryCard(CatalogCategory category) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: () => _showEditCategoryDialog(category),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category image
              if (category.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    category.imageUrl,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.category,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Category name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: category.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showEditCategoryDialog(category),
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      category.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => _toggleCategoryActive(category),
                    tooltip: category.isActive ? 'Deactivate' : 'Activate',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _confirmDeleteCategory(category),
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ProductForm(
            onSave: (product) {
              Navigator.pop(context);
              _addProduct(product);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
  
  void _showEditProductDialog(CatalogItem product) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ProductForm(
            product: product,
            onSave: (updatedProduct) {
              Navigator.pop(context);
              _updateProduct(updatedProduct);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
  
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: CategoryForm(
            onSave: (category) {
              Navigator.pop(context);
              _addCategory(category);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
  
  void _showEditCategoryDialog(CatalogCategory category) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: CategoryForm(
            category: category,
            onSave: (updatedCategory) {
              Navigator.pop(context);
              _updateCategory(updatedCategory);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
  
  void _confirmDeleteProduct(CatalogItem product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
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
  
  void _confirmDeleteCategory(CatalogCategory category) {
    // Check if there are products in this category first
    final catalogType = ref.read(currentCatalogTypeProvider);
    final productsAsync = ref.read(catalogItemsByCategoryProvider(
      (catalogType: catalogType, categoryId: category.id)
    ).future);
    
    productsAsync.then((products) {
      if (products.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cannot Delete Category'),
            content: Text(
              'This category contains ${products.length} products. Please move or delete these products before deleting the category.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      
      // If there are no products, confirm deletion
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCategory(category);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    });
  }
  
  // CRUD operations
  Future<void> _addProduct(CatalogItem product) async {
    try {
      final catalogType = ref.read(currentCatalogTypeProvider);
      final catalogService = ref.read(catalogServiceProvider(catalogType));
      
      await catalogService.addItem(product);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      }
    }
  }
  
  Future<void> _updateProduct(CatalogItem product) async {
    try {
      final catalogType = ref.read(currentCatalogTypeProvider);
      final catalogService = ref.read(catalogServiceProvider(catalogType));
      
      await catalogService.updateItem(product);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteProduct(CatalogItem product) async {
    try {
      final catalogType = ref.read(currentCatalogTypeProvider);
      final catalogService = ref.read(catalogServiceProvider(catalogType));
      
      await catalogService.deleteItem(product.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting product: $e')),
        );
      }
    }
  }
  
  Future<void> _toggleProductAvailability(CatalogItem product) async {
    try {
      final catalogType = ref.read(currentCatalogTypeProvider);
      final catalogService = ref.read(catalogServiceProvider(catalogType));
      
      final updatedProduct = CatalogItem(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        categoryId: product.categoryId,
        isAvailable: !product.isAvailable,
        metadata: product.metadata,
      );
      
      await catalogService.updateItem(updatedProduct);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            product.isAvailable 
              ? 'Product marked as unavailable' 
              : 'Product marked as available'
          )),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product: $e')),
        );
      }
    }
  }
  
  Future<void> _addCategory(CatalogCategory category) async {
    try {
      final catalogType = ref.read(currentCatalogTypeProvider);
      final catalogService = ref.read(catalogServiceProvider(catalogType));
      
      await catalogService.addCategory(category);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding category: $e')),
        );
      }
    }
  }
  
  Future<void> _updateCategory(CatalogCategory category) async {
    try {
      final catalogType = ref.read(currentCatalogTypeProvider);
      final catalogService = ref.read(catalogServiceProvider(catalogType));
      
      await catalogService.updateCategory(category);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating category: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteCategory(CatalogCategory category) async {
    try {
      final catalogType = ref.read(currentCatalogTypeProvider);
      final catalogService = ref.read(catalogServiceProvider(catalogType));
      
      await catalogService.deleteCategory(category.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }
  
  Future<void> _toggleCategoryActive(CatalogCategory category) async {
    try {
      final catalogType = ref.read(currentCatalogTypeProvider);
      final catalogService = ref.read(catalogServiceProvider(catalogType));
      
      final updatedCategory = CatalogCategory(
        id: category.id,
        name: category.name,
        imageUrl: category.imageUrl,
        sortOrder: category.sortOrder,
        isActive: !category.isActive,
      );
      
      await catalogService.updateCategory(updatedCategory);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            category.isActive 
              ? 'Category deactivated' 
              : 'Category activated'
          )),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating category: $e')),
        );
      }
    }
  }
}