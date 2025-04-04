import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/cart/cart_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/order/order_admin_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/user/auth_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/catalog_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/cart/model/cart_item.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/catalog/catalog_provider.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/service_factory.dart';
import '../../../../core/services/resource_service.dart';
import 'dart:math';

class CreateOrderForm extends ConsumerStatefulWidget {
  final String? preselectedTableId;
  final Function(Order) onSuccess;
  final VoidCallback onCancel;

  const CreateOrderForm({
    super.key,
    this.preselectedTableId,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  ConsumerState<CreateOrderForm> createState() => _CreateOrderFormState();
}

class _CreateOrderFormState extends ConsumerState<CreateOrderForm> {
  // Order creation state
  late CartService _cartService;
  String? _selectedTableId;
  bool _isDelivery = false;
  String? _specialInstructions;
  int _peopleCount = 1;
  String? _deliveryAddress;
  String? _contactPhone;
  String _paymentMethod = 'cash';
  bool _isCreatingOrder = false;

  // Filter and search state
  String _searchQuery = '';
  String _selectedCategoryId = '';
  final TextEditingController _searchController = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedTableId = widget.preselectedTableId;

    // Set up cart
    _initializeCart();

    // Set up search
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initializeCart() {
    _cartService = ref.read(cartServiceProvider);

    // Initialize cart with business ID and selected table
    _cartService.clearCart();
    // Fix: Add null check before using _selectedTableId
    _cartService.updateResourceId(
        _selectedTableId); // Make sure updateResourceId handles null
    _cartService.updateDeliveryOption(_isDelivery);
    _cartService.updatePeopleCount(_peopleCount);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    // Use SafeArea to avoid layout issues with system UI
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create New Order'),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Cart'),
              onPressed: _clearCart,
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: isDesktop
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        // Fix: Ensure cart is not null
                        '\$${(_cartService.cart?.total ?? 0.0).toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('Create Order'),
                  // Fix: Safe access to cart items with null check
                  onPressed: (_cartService.cart?.items.isEmpty ?? true) ||
                          _isCreatingOrder
                      ? null
                      : _createOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    // Important: Define container sizing to avoid unbounded height issues
    return Container(
      // Use constraints to provide bounded height for inner widgets
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Menu and Items
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildSearchAndFilterBar(),
                Expanded(
                  child: _buildMenuItems(),
                ),
              ],
            ),
          ),

          // Right side - Order Details and Cart
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      150, // Adjust as needed
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSettingsCard(),
                    const SizedBox(height: 16),
                    _buildCartSection(),
                    const SizedBox(height: 16),
                    _buildPaymentMethodCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar for menu/cart
          const TabBar(
            tabs: [
              Tab(text: 'Menu'),
              Tab(text: 'Order Details'),
            ],
            labelColor: Colors.black,
          ),

          // Tab content - wrap in Expanded to provide size constraints
          Expanded(
            child: TabBarView(
              children: [
                // Menu tab - use Column with proper constraints
                Column(
                  children: [
                    _buildSearchAndFilterBar(),
                    // The Expanded here is critical to provide height constraints
                    Expanded(
                      child: _buildMenuItems(),
                    ),
                  ],
                ),

                // Order details tab
                SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderSettingsCard(),
                      const SizedBox(height: 16),
                      _buildCartSection(),
                      const SizedBox(height: 16),
                      _buildPaymentMethodCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    final catalogType = ref.watch(currentCatalogTypeProvider);
    final categoriesAsync = ref.watch(catalogCategoriesProvider(catalogType));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field - Fixed with explicit constraints
          SizedBox(
            height: 56,
            width: double.infinity,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Categories filter - Fix with SizedBox and proper ListView constraints
          SizedBox(
            height: 40,
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) return const SizedBox.shrink();

                return ListView(
                  shrinkWrap: true, // Important!
                  physics: const ClampingScrollPhysics(),
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
                    ...categories
                        .where((category) => category.isActive)
                        .map((category) {
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
                );
              },
              loading: () => const Center(child: LinearProgressIndicator()),
              // Fix: Better error handling
              error: (error, stack) => Text(
                  'Error loading categories: ${error.toString().substring(0, min(50, error.toString().length))}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final catalogType = ref.watch(currentCatalogTypeProvider);
    final itemsAsync = _selectedCategoryId.isEmpty
        ? ref.watch(catalogItemsProvider(catalogType))
        : ref.watch(catalogItemsByCategoryProvider((
            catalogType: catalogType,
            categoryId: _selectedCategoryId,
          )));

    // Container with fixed size constraints to avoid layout issues
    return Container(
      // This explicit height helps avoid unbounded height issues
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight: double.infinity,
      ),
      child: itemsAsync.when(
        data: (items) {
          // Filter items by search query
          final filteredItems = items.where((item) {
            if (_searchQuery.isEmpty) return true;

            return item.name.toLowerCase().contains(_searchQuery) ||
                (item.description?.toLowerCase() ?? '').contains(_searchQuery);
          }).toList();

          if (filteredItems.isEmpty) {
            return const Center(
              child: Text('No items found'),
            );
          }

          // Use a LimitedBox to avoid unbounded height issues with scrollable widgets
          return LimitedBox(
            maxHeight: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;

                if (isWide) {
                  // Grid for wider screens
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildMenuItemCard(filteredItems[index]);
                    },
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                  );
                } else {
                  // List for narrower screens
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildMenuItemCard(filteredItems[index]),
                      );
                    },
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                  );
                }
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
            child: Text(
                'Error: ${error.toString().substring(0, min(50, error.toString().length))}')),
      ),
    );
  }

  Widget _buildMenuItemCard(CatalogItem item) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showItemOptionsDialog(item),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 300;

            // Fixed height container to ensure proper sizing
            return Container(
              height: isNarrow
                  ? 320
                  : 140, // Provide explicit height based on layout
              child: isNarrow
                  ? _buildNarrowItemLayout(item, theme)
                  : _buildWideItemLayout(item, theme),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNarrowItemLayout(CatalogItem item, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item image with explicit height
        if (item.imageUrl != null && item.imageUrl.isNotEmpty)
          Container(
            height: 140,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: theme.colorScheme.primaryContainer,
                  child: const Center(
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
          ),

        // Item details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!item.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    item.description ?? '',
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Add button
                if (item.isAvailable)
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text('Add'),
                      onPressed: () => _addItemToCart(item),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideItemLayout(CatalogItem item, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item image with fixed width and full height
        if (item.imageUrl != null && item.imageUrl.isNotEmpty)
          Container(
            width: 120,
            height: double.infinity,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: theme.colorScheme.primaryContainer,
                child: const Center(
                  child: Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),

        // Item details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!item.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    item.description ?? '',
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.isAvailable)
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120,
                      height: 36,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('Add'),
                        onPressed: () => _addItemToCart(item),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSettingsCard() {
    final theme = Theme.of(context);
    final resourceServiceAsync = ref.watch(tableResourcesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Settings',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Delivery/Dine-in toggle
            SwitchListTile(
              title: const Text('Delivery Order'),
              subtitle: Text(_isDelivery
                  ? 'Delivery to address'
                  : 'Dine-in at restaurant'),
              value: _isDelivery,
              onChanged: (value) {
                setState(() {
                  _isDelivery = value;
                  _cartService.updateDeliveryOption(value);

                  // Clear table selection if switching to delivery
                  if (value) {
                    _selectedTableId = null;
                    _cartService.updateResourceId(null);
                  }
                });
              },
            ),

            const SizedBox(height: 16),

            // Table selection (if dine-in)
            if (!_isDelivery) ...[
              SizedBox(
                height: 80, // Explicit height constraint
                child: resourceServiceAsync.when(
                  data: (resources) {
                    // Filter to available tables
                    final availableTables = resources
                        .where((res) =>
                            res.status == 'available' ||
                            res.id == _selectedTableId)
                        .toList();

                    if (availableTables.isEmpty) {
                      return const Text('No tables available');
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Select Table',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedTableId,
                        items: availableTables.map((table) {
                          // Fix: Add null checks for table attributes
                          final tableName = table.name.replaceAll('Table ', '');
                          final capacity = table.attributes?['capacity'] ?? 4;
                          return DropdownMenuItem<String>(
                            value: table.id,
                            child: Text('Table $tableName (Seats $capacity)'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTableId = value;
                            _cartService.updateResourceId(value);
                          });
                        },
                        validator: (value) {
                          if (!_isDelivery &&
                              (value == null || value.isEmpty)) {
                            return 'Please select a table';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  // Fix: Better error handling
                  error: (error, stack) => Text(
                      'Error loading tables: ${error.toString().substring(0, min(50, error.toString().length))}'),
                ),
              ),

              const SizedBox(height: 16),

              // People count
              Row(
                children: [
                  const Text('People:'),
                  Expanded(
                    child: Slider(
                      value: _peopleCount.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: _peopleCount.toString(),
                      onChanged: (value) {
                        setState(() {
                          _peopleCount = value.toInt();
                          _cartService.updatePeopleCount(_peopleCount);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    height: 40,
                    child: TextFormField(
                      initialValue: _peopleCount.toString(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        final count = int.tryParse(value);
                        if (count != null && count > 0 && count <= 20) {
                          setState(() {
                            _peopleCount = count;
                            _cartService.updatePeopleCount(count);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Delivery address
              SizedBox(
                width: double.infinity,
                height: 96,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    hintText: 'Enter delivery address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    setState(() {
                      _deliveryAddress = value;
                    });
                  },
                  validator: (value) {
                    if (_isDelivery && (value == null || value.isEmpty)) {
                      return 'Please enter a delivery address';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Contact phone
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    setState(() {
                      _contactPhone = value;
                    });
                  },
                  validator: (value) {
                    if (_isDelivery && (value == null || value.isEmpty)) {
                      return 'Please enter a contact phone number';
                    }
                    return null;
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Special instructions
            SizedBox(
              width: double.infinity,
              height: 96,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Special Instructions',
                  hintText: 'Enter any special instructions or requests',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _specialInstructions = value;
                    _cartService.updateSpecialInstructions(value);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSection() {
    final theme = Theme.of(context);
    // Fix: Add null check for cart access
    final cart = _cartService.cart;
    if (cart == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Cart unavailable'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cart Items',
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  '${cart.itemCount} items',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (cart.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text('No items in cart yet'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) =>
                    _buildCartItemTile(index, cart.items[index]),
              ),
            if (cart.items.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),

              // Cart summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('\$${cart.subtotal.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tax'),
                  Text('\$${cart.tax.toStringAsFixed(2)}'),
                ],
              ),

              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '\$${cart.total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemTile(int index, CartItem item) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    // For very small screens, use a more compact layout
    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${item.numericPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 18),
                onPressed: () =>
                    _updateCartItemQuantity(index, item.quantity - 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text('${item.quantity}'),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                onPressed: () =>
                    _updateCartItemQuantity(index, item.quantity + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeCartItem(index),
                tooltip: 'Remove',
                iconSize: 18,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          if (item.options.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: item.options.entries.map((option) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${option.key}: ${option.value}',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    }

    // Default layout for larger screens
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantity controls
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () =>
                  _updateCartItemQuantity(index, item.quantity + 1),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () =>
                  _updateCartItemQuantity(index, item.quantity - 1),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),

        const SizedBox(width: 8),

        // Item details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: theme.textTheme.titleSmall,
              ),

              // Item options
              if (item.options.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: item.options.entries.map((option) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${option.key}: ${option.value}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Item notes - Fix: Safer access to notes property
              if (item.notes?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Note: ${item.notes}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Price and remove button
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${item.numericPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeCartItem(index),
              tooltip: 'Remove',
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Payment method selection
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPaymentMethodChip('cash', 'Cash', Icons.payments),
                _buildPaymentMethodChip(
                    'credit_card', 'Credit Card', Icons.credit_card),
                _buildPaymentMethodChip(
                    'debit_card', 'Debit Card', Icons.credit_card),
                _buildPaymentMethodChip(
                    'mobile_payment', 'Mobile Payment', Icons.phone_android),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChip(String value, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _paymentMethod == value;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _paymentMethod = value;
          });
        }
      },
    );
  }

  void _showItemOptionsDialog(CatalogItem item) {
    // Get screen info for responsive sizing
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Calculate appropriate dialog width based on screen size
    final dialogWidth = screenWidth > 1200
        ? 800.0
        : screenWidth > 700
            ? 600.0
            : screenWidth * 0.9;

    showDialog(
      context: context,
      // Use barrierDismissible to allow clicking outside to dismiss
      barrierDismissible: true,
      builder: (context) => Dialog(
        // Don't use insetPadding - it can cause layout issues
        // Instead use a specific width with constraints
        child: Container(
          width: dialogWidth,
          // Use constraints with both min and max dimensions
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: screenHeight * 0.8,
          ),
          child: ItemOptionsDialog(
            item: item,
            onAddToCart: _addItemToCart,
          ),
        ),
      ),
    );
  }

  void _addItemToCart(CatalogItem item,
      {Map<String, dynamic>? options, String? notes, int quantity = 1}) {
    if (!item.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item is currently unavailable'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cartItem = CartItem(
      img: item.imageUrl ?? '',
      description: item.description ?? '',
      ingredients: [], // Default empty ingredients list
      isSpicy: false, // Default not spicy
      foodType: 'regular', // Default food type
      isOffer: false, // Default not an offer
      id: item.id,
      title: item.name,
      pricing: item.price.toString(),
      quantity: quantity,
      options: options ?? {},
      notes: notes,
    );

    _cartService.addItem(cartItem);

    // Force refresh UI
    setState(() {});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${item.name} to cart'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _updateCartItemQuantity(int index, int quantity) {
    _cartService.updateItemQuantity(index, quantity);
    // Force refresh UI
    setState(() {});
  }

  void _removeCartItem(int index) {
    _cartService.removeItem(index);
    // Force refresh UI
    setState(() {});
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text(
            'Are you sure you want to remove all items from the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cartService.clearCart();
              setState(() {});
            },
            child: const Text('Clear Cart'),
          ),
        ],
      ),
    );
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Fix: Safer access to cart items
    if (_cartService.cart?.items.isEmpty ?? true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add items to your cart'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isCreatingOrder = true;
    });

    try {
      final cart = _cartService.cart;
      // Validate cart is not null
      if (cart == null) {
        throw Exception("Cart is unavailable");
      }

      final userAsync = ref.watch(currentUserProvider.future);
      final orderService = ref.read(orderServiceProvider);
      // Fix: Add default for businessId
      final businessId = ref.read(currentBusinessIdProvider) ?? 'default';

      // Set resourceId based on table or delivery address
      final resourceId = _isDelivery ? null : _selectedTableId;

      // Get current user for order metadata
      final currentUser = await userAsync;

      // Create order
      final order = Order(
        id: const Uuid().v4(),
        businessId: businessId,
        userId: currentUser?.uid ?? 'anonymous',
        userName: currentUser?.displayName ?? 'Guest',
        // Fix: Add fallback for userEmail
        userEmail: currentUser?.email ?? 'unknown@example.com',
        userPhone: _contactPhone,
        items: cart.items
            .map((item) => OrderItem(
                  id: item.id,
                  name: item.title,
                  price: item.numericPrice.toDouble(),
                  quantity: item.quantity,
                  notes: item.notes,
                  productId: item.id,
                ))
            .toList(),
        subtotal: cart.subtotal,
        tax: cart.tax,
        total: cart.total,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        resourceId: resourceId,
        specialInstructions: _specialInstructions,
        isDelivery: _isDelivery,
        deliveryAddress: _deliveryAddress,
        deliveryFee: _isDelivery ? 5.0 : 0.0, // Example delivery fee
        discount: 0.0,
        peopleCount: _peopleCount,
        paymentMethod: _paymentMethod,
      );

      // Save order to database
      final orderId = await orderService.createOrder(order);

      // Update table status if using a table
      // Fix: Proper null checking for table ID
      if (!_isDelivery && _selectedTableId != null) {
        final resourceService = ref.read(serviceFactoryProvider
            .select((factory) => factory.createResourceService('table')));

        await resourceService.updateResourceStatus(
            _selectedTableId!, 'occupied');
      }

      // Fix: Better check for mounted state and context
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Fix: Safer substring use for orderId
            content: Text(
                'Order created successfully: #${orderId.length >= 6 ? orderId.substring(0, 6) : orderId}'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear cart
        _cartService.clearCart();

        // Call success callback with the created order
        widget.onSuccess(order);
      }
    } catch (e) {
      // Fix: Better check for mounted state and context
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating order: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isCreatingOrder = false;
      });
    }
  }
}

// Provider for table resources
final tableResourcesProvider = StreamProvider<List<Resource>>((ref) {
  final resourceService = ref.watch(serviceFactoryProvider
      .select((factory) => factory.createResourceService('table')));

  return resourceService.getResourcesStream();
});

// Item options dialog
class ItemOptionsDialog extends StatefulWidget {
  final CatalogItem item;
  final Function(CatalogItem,
      {Map<String, dynamic>? options, String? notes, int quantity}) onAddToCart;

  const ItemOptionsDialog({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  State<ItemOptionsDialog> createState() => _ItemOptionsDialogState();
}

class _ItemOptionsDialogState extends State<ItemOptionsDialog> {
  int _quantity = 1;
  String? _notes;
  final Map<String, dynamic> _selectedOptions = {};

  // Example item options - in a real app, these would come from the item metadata
  final Map<String, List<String>> _availableOptions = {
    'Size': ['Regular', 'Large', 'Extra Large'],
    'Temperature': ['Hot', 'Iced'],
    'Extras': ['Extra Cheese', 'Bacon', 'Avocado'],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 400;

    // Wrap with Container to ensure sizing
    return Container(
      // Define explicit constraints
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Item header with defined height constraints
              Container(
                height: isNarrow ? null : 120, // Height for horizontal layout
                child: isNarrow
                    // Vertical layout for narrow screens
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fix: Add null check for imageUrl and explicit height
                          if (widget.item.imageUrl != null &&
                              widget.item.imageUrl.isNotEmpty)
                            Container(
                              height: 180,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: theme.colorScheme.primaryContainer,
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported,
                                          size: 48),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            widget.item.name,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${widget.item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.item.description ?? '',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      )
                    // Horizontal layout for wider screens
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fix: Add null check for imageUrl
                          if (widget.item.imageUrl != null &&
                              widget.item.imageUrl.isNotEmpty)
                            Container(
                              width: 120,
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: theme.colorScheme.primaryContainer,
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.item.name,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${widget.item.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.item.description ?? '',
                                  style: theme.textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Quantity selector with fixed height
              Container(
                height: 60,
                child: Row(
                  children: [
                    const Text('Quantity:'),
                    Expanded(
                      child: Slider(
                        value: _quantity.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _quantity.toString(),
                        onChanged: (value) {
                          setState(() {
                            _quantity = value.toInt();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Options
              // Fix: Add null check for item.metadata
              if ((widget.item.metadata?.containsKey('options') ?? false) ||
                  _availableOptions.isNotEmpty) ...[
                const Text(
                  'Options',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // In a real app, options would come from item metadata
                // Using example options for now
                ..._availableOptions.entries.map((entry) {
                  final optionName = entry.key;
                  final values = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(optionName),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: values.map((value) {
                          final isSelected =
                              _selectedOptions[optionName] == value;

                          return ChoiceChip(
                            label: Text(value),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedOptions[optionName] = value;
                                } else {
                                  _selectedOptions.remove(optionName);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],

              const SizedBox(height: 16),

              // Special instructions
              SizedBox(
                width: double.infinity,
                height: 80,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Special Instructions',
                    hintText: 'Any special requests?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    setState(() {
                      _notes = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onAddToCart(
                            widget.item,
                            options: _selectedOptions,
                            notes: _notes,
                            quantity: _quantity,
                          );
                        },
                        child: Text(
                            'Add to Cart (\$${(widget.item.price * _quantity).toStringAsFixed(2)})'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data model for restaurant stats dashboard
class DashboardStats {
  final OrderStats orderStats;
  final SalesStats salesStats;
  final TableStats tableStats;
  final ProductStats productStats;

  DashboardStats({
    required this.orderStats,
    required this.salesStats,
    required this.tableStats,
    required this.productStats,
  });
}

class SalesStats {
  final double totalSales;
  final double todaySales;
  final int orderCount;
  final Map<String, double>? salesByDay;
  final double averageOrderValue;

  const SalesStats({
    required this.totalSales,
    required this.todaySales,
    required this.orderCount,
    this.salesByDay,
    this.averageOrderValue = 0,
  });

  // Calculate average order value
  double get avgOrderValue => orderCount > 0 ? totalSales / orderCount : 0;
}

/// Table statistics
class TableStats {
  final int totalTables;
  final int occupiedTables;
  final int reservedTables;
  final int availableTables;
  final double occupancyRate;
  final double turnoverRate; // average times a table is used per day

  final int cleaningTables;

  const TableStats({
    required this.totalTables,
    required this.occupiedTables,
    required this.reservedTables,
    required this.cleaningTables,
    this.availableTables = 0,
    this.occupancyRate = 0,
    this.turnoverRate = 0,
  });

  // Calculate available tables
  int get available => totalTables - occupiedTables - reservedTables;

  // Calculate occupancy rate
  double get occupancy =>
      totalTables > 0 ? (occupiedTables + reservedTables) / totalTables : 0;
}

/// Product statistics
class ProductStats {
  final int totalProducts;
  final int categories;
  final int outOfStock;
  final List<TopSellingProduct>? topProducts;

  const ProductStats({
    required this.totalProducts,
    required this.categories,
    required this.outOfStock,
    this.topProducts,
  });

  // Calculate in-stock products
  int get inStock => totalProducts - outOfStock;

  // Calculate in-stock percentage
  double get inStockPercentage =>
      totalProducts > 0 ? (totalProducts - outOfStock) / totalProducts : 0;
}

/// Top selling product data
class TopSellingProduct {
  final String id;
  final String name;
  final int quantity;
  final double revenue;
  final String category;

  const TopSellingProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.revenue,
    required this.category,
  });
}

/// Sales data point for charts
class SalesDataPoint {
  final DateTime date;
  final double sales;
  final int orders;

  const SalesDataPoint({
    required this.date,
    required this.sales,
    required this.orders,
  });
}

/// Category data point for charts
class CategoryDataPoint {
  final String category;
  final double sales;
  final int orders;
  final Color color;

  const CategoryDataPoint({
    required this.category,
    required this.sales,
    required this.orders,
    required this.color,
  });
}

/// Hourly data point for charts
class HourlyDataPoint {
  final int hour;
  final int orders;

  const HourlyDataPoint({
    required this.hour,
    required this.orders,
  });
}

/// Customer statistics
class CustomerStats {
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final double returnRate;
  final List<CustomerFrequency>? frequencyDistribution;

  const CustomerStats({
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    this.returnRate = 0,
    this.frequencyDistribution,
  });

  // Calculate return rate
  double get customerReturnRate =>
      totalCustomers > 0 ? returningCustomers / totalCustomers : 0;
}

/// Customer visit frequency
class CustomerFrequency {
  final String label; // e.g., "1 visit", "2-5 visits", etc.
  final int count;
  final double percentage;

  const CustomerFrequency({
    required this.label,
    required this.count,
    required this.percentage,
  });
}
