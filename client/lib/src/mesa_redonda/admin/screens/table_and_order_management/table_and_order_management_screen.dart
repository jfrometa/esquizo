import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/models/product_model.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/screens/admin_panel_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/services/order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/services/print_service.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/services/product_service.dart';
import 'package:starter_architecture_flutter_firebase/src/mesa_redonda/admin/services/table_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as CloudFireStore;  

// Create or view order screen with table context
class TableOrderScreen extends ConsumerStatefulWidget {
  final RestaurantTable table;
  final Order? existingOrder;

  const TableOrderScreen({
    Key? key,
    required this.table,
    this.existingOrder,
  }) : super(key: key);

  @override
  ConsumerState<TableOrderScreen> createState() => _TableOrderScreenState();
}

class _TableOrderScreenState extends ConsumerState<TableOrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Order _currentOrder;
  late List<OrderItem> _orderItems;
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  
  // Customer info
  final TextEditingController _customerNameController = TextEditingController();
  int _customerCount = 1;
  bool _isEditingNote = false;
  String? _selectedItemIdForNote;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize order
    if (widget.existingOrder != null) {
      _currentOrder = widget.existingOrder!;
      _orderItems = List.from(_currentOrder.items);
      _customerNameController.text = _currentOrder.customerName ?? '';
      _customerCount = _currentOrder.customerCount ?? 1;
    } else {
      _currentOrder = Order(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        tableNumber: widget.table.number,
        tableId: widget.table.id,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        items: [],
        status: OrderStatus.pending,
        totalAmount: 0,
        subtotal: 0,
        taxAmount: 0,
        customerCount: 1,
        isPaid: false,
        paymentMethod: '',
        tipAmount: 0.0,
        orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        email: '',
        userId: '',
        orderType: 'dine_in',
        address: '',
        latitude: '0.0',
        longitude: '0.0',
        paymentStatus: 'pending',
        timestamp: CloudFireStore.Timestamp.now(),
        orderDate: DateTime.now(),
        location: <String, dynamic>{},
      );
      _orderItems = [];
    }
    
    // If there's a waiter note in the existing order, set it
    _notesController.text = _currentOrder.waiterNotes ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _notesFocusNode.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(menuCategoriesProvider);
    final products = ref.watch(menuProductsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: widget.existingOrder != null 
            ? Text('Editar Pedido - Mesa ${widget.table.number}') 
            : Text('Nuevo Pedido - Mesa ${widget.table.number}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar Pedido',
            onPressed: _saveOrder,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Menú'),
            Tab(text: 'Pedido Actual'),
            Tab(text: 'Información'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              // Menu Tab
              _buildMenuTab(categories, products),
              
              // Current Order Tab
              _buildCurrentOrderTab(theme),
              
              // Order Information Tab
              _buildOrderInfoTab(theme),
            ],
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildMenuTab(AsyncValue<List<MenuCategory>> categories, AsyncValue<List<MenuItem>> products) {
    return categories.when(
      data: (categoryList) {
        return products.when(
          data: (productList) {
            if (categoryList.isEmpty) {
              return const Center(
                child: Text('No hay categorías disponibles'),
              );
            }
            
            return Column(
              children: [
                // Category filter chips
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryList.length + 1, // +1 for "All" option
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "All" filter option
                        return FilterChip(
                          label: const Text('Todos'),
                          selected: _selectedCategoryId == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategoryId = null;
                              });
                            }
                          },
                        );
                      }
                      
                      final category = categoryList[index - 1];
                      return FilterChip(
                        label: Text(category.name),
                        selected: _selectedCategoryId == category.id,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? category.id : null;
                          });
                        },
                      );
                    },
                  ),
                ),
                
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                
                // Product grid
                Expanded(
                  child: _buildProductGrid(productList, categoryList),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error al cargar productos: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error al cargar categorías: $error'),
      ),
    );
  }

  String? _selectedCategoryId;
  String _searchQuery = '';

  Widget _buildProductGrid(List<MenuItem> allProducts, List<MenuCategory> categories) {
    // Filter products based on selected category and search query
    final filteredProducts = allProducts.where((product) {
      final matchesCategory = _selectedCategoryId == null || product.categoryId == _selectedCategoryId;
      final matchesSearch = _searchQuery.isEmpty || 
                           product.name.toLowerCase().contains(_searchQuery) ||
                           product.description.toLowerCase().contains(_searchQuery);
      
      return matchesCategory && matchesSearch && product.isAvailable;
    }).toList();
    
    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text('No hay productos que coincidan con tu búsqueda'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        final category = categories.firstWhere(
          (cat) => cat.id == product.categoryId,
          orElse: () => MenuCategory(id: 'unknown', name: 'Sin categoría', sortOrder: 999),
        );
        
        return _buildProductCard(product, category);
      },
    );
  }

  Widget _buildProductCard(MenuItem product, MenuCategory category) {
    final theme = Theme.of(context);
    
    // Check if item is in current order
    final inOrderItem = _orderItems.firstWhere(
      (item) => item.productId == product.id,
      orElse: () => OrderItem(
        productId: '',
        name: '',
        price: 0,
        quantity: 0,
      ),
    );
    
    final isInOrder = inOrderItem.productId.isNotEmpty;
    final orderQuantity = isInOrder ? inOrderItem.quantity : 0;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () => _addItemToOrder(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category label and availability indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: theme.colorScheme.secondaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (product.isSpecial)
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                ],
              ),
            ),
            
            // Product image (placeholder)
            Expanded(
              child: Container(
                width: double.infinity,
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.restaurant,
                          size: 48,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                      )
                    : Icon(
                        Icons.restaurant,
                        size: 48,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
              ),
            ),
            
            // Product info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isInOrder)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'x$orderQuantity',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Quick add controls
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: isInOrder 
                        ? () => _updateOrderItemQuantity(product, orderQuantity - 1) 
                        : null,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text(
                    orderQuantity.toString(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _updateOrderItemQuantity(product, orderQuantity + 1),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentOrderTab(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          color: theme.colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mesa ${widget.table.number}',
                style: theme.textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(_currentOrder.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getStatusText(_currentOrder.status),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _getStatusColor(_currentOrder.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Order items list
        Expanded(
          child: _orderItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay productos en este pedido',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Productos'),
                    onPressed: () => _tabController.animateTo(0),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _orderItems.length,
              itemBuilder: (context, index) {
                final item = _orderItems[index];
                return _buildOrderItemTile(item, theme);
              },
            ),
        ),
        
        // Totals and actions
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    '\$${_calculateSubtotal().toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Impuestos (16%)',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    '\$${_calculateTax().toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    '\$${_calculateTotal().toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Imprimir'),
                    onPressed: _orderItems.isNotEmpty ? _printOrderPreview : null,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Pedido'),
                    onPressed: _orderItems.isNotEmpty ? _saveOrder : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemTile(OrderItem item, ThemeData theme) {
    return ListTile(
      title: Text(
        item.name,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.notes != null && item.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Nota: ${item.notes}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (_isEditingNote && _selectedItemIdForNote == item.productId)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _notesController,
                      focusNode: _notesFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Agregar nota especial...',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                      minLines: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      setState(() {
                        final updatedItem = OrderItem(
                          productId: item.productId,
                          name: item.name,
                          price: item.price,
                          quantity: item.quantity,
                          notes: _notesController.text,
                        );
                        
                        final index = _orderItems.indexWhere(
                          (i) => i.productId == item.productId
                        );
                        
                        if (index != -1) {
                          _orderItems[index] = updatedItem;
                        }
                        
                        _isEditingNote = false;
                        _selectedItemIdForNote = null;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isEditingNote = false;
                        _selectedItemIdForNote = null;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          '${item.quantity}',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'edit_note':
                  _startEditingNote(item);
                  break;
                case 'remove':
                  _removeItemFromOrder(item.productId);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_note',
                child: ListTile(
                  leading: Icon(Icons.edit_note),
                  title: Text('Editar Nota'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Eliminar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID and timestamp
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Pedido',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Divider(),
                  if (widget.existingOrder != null) ...[
                    _buildInfoRow('ID del Pedido', '#${widget.existingOrder!.id.substring(0, 8)}'),
                    _buildInfoRow('Creado', _formatDateTime(widget.existingOrder!.createdAt)),
                    if (widget.existingOrder!.lastUpdated != null)
                      _buildInfoRow('Actualizado', _formatDateTime(widget.existingOrder!.lastUpdated!)),
                  ] else
                    const Text('Este pedido aún no ha sido guardado'),
                  _buildInfoRow('Estado', _getStatusText(_currentOrder.status)),
                  _buildInfoRow('Mesa', widget.table.number.toString()),
                  _buildInfoRow('Capacidad', '${widget.table.capacity} personas'),
                ],
              ),
            ),
          ),
          
          // Customer information
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Cliente',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Divider(),
                  TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Cliente (opcional)',
                      hintText: 'Ej. Juan Pérez',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Número de Comensales:'),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _customerCount > 1 
                            ? () => setState(() => _customerCount--) 
                            : null,
                      ),
                      Text(
                        '$_customerCount',
                        style: theme.textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _customerCount++),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Waiter notes
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notas del Mesero',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Divider(),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Agrega notas importantes sobre el pedido...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          
          // Order actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acciones del Pedido',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Divider(),
                  if (widget.existingOrder != null) ...[
                    ListTile(
                      leading: Icon(
                        Icons.update,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Actualizar Estado del Pedido'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showUpdateStatusDialog,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.print,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text('Imprimir Pedido'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _printOrderPreview,
                    ),
                    if (_currentOrder.status != OrderStatus.cancelled && 
                        _currentOrder.status != OrderStatus.completed)
                      ListTile(
                        leading: Icon(
                          Icons.cancel_outlined,
                          color: theme.colorScheme.error,
                        ),
                        title: const Text('Cancelar Pedido'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _confirmCancelOrder,
                      ),
                  ] else
                    const Text('Las acciones estarán disponibles después de guardar el pedido'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final total = _calculateTotal();
    final itemCount = _orderItems.fold<int>(0, (sum, item) => sum + item.quantity);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$itemCount ${itemCount == 1 ? 'producto' : 'productos'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Guardar Pedido'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: _orderItems.isNotEmpty ? _saveOrder : null,
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _addItemToOrder(MenuItem product) {
    final existingItemIndex = _orderItems.indexWhere(
      (item) => item.productId == product.id
    );
    
    setState(() {
      if (existingItemIndex >= 0) {
        // Update existing item
        final existingItem = _orderItems[existingItemIndex];
        _orderItems[existingItemIndex] = OrderItem(
          productId: existingItem.productId,
          name: existingItem.name,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
          notes: existingItem.notes,
        );
      } else {
        // Add new item
        _orderItems.add(OrderItem(
          productId: product.id,
          name: product.name,
          price: product.price,
          quantity: 1,
        ));
      }
    });
    
    // Show snackbar confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} agregado al pedido'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'Ver Pedido',
          onPressed: () => _tabController.animateTo(1),
        ),
      ),
    );
  }

  void _updateOrderItemQuantity(MenuItem product, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItemFromOrder(product.id);
      return;
    }
    
    final existingItemIndex = _orderItems.indexWhere(
      (item) => item.productId == product.id
    );
    
    setState(() {
      if (existingItemIndex >= 0) {
        // Update existing item
        final existingItem = _orderItems[existingItemIndex];
        _orderItems[existingItemIndex] = OrderItem(
          productId: existingItem.productId,
          name: existingItem.name,
          price: existingItem.price,
          quantity: newQuantity,
          notes: existingItem.notes,
        );
      } else if (newQuantity > 0) {
        // Add new item
        _orderItems.add(OrderItem(
          productId: product.id,
          name: product.name,
          price: product.price,
          quantity: newQuantity,
        ));
      }
    });
  }

  void _removeItemFromOrder(String productId) {
    setState(() {
      _orderItems.removeWhere((item) => item.productId == productId);
    });
  }

  void _startEditingNote(OrderItem item) {
    setState(() {
      _notesController.text = item.notes ?? '';
      _isEditingNote = true;
      _selectedItemIdForNote = item.productId;
    });
    
    // Focus the text field after the state is updated
    Future.delayed(const Duration(milliseconds: 100), () {
      _notesFocusNode.requestFocus();
    });
  }

  double _calculateSubtotal() {
    return _orderItems.fold<double>(
      0, 
      (sum, item) => sum + (item.price * item.quantity)
    );
  }

  double _calculateTax() {
    return _calculateSubtotal() * 0.16; // 16% tax
  }

  double _calculateTotal() {
    return _calculateSubtotal() + _calculateTax();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.inProgress:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.teal;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.inProgress:
        return 'En Preparación';
      case OrderStatus.ready:
        return 'Listo para Servir';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  void _showUpdateStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Estado del Pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pendiente'),
              leading: Icon(
                Icons.hourglass_empty,
                color: Colors.orange,
              ),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(OrderStatus.pending);
              },
            ),
            ListTile(
              title: const Text('En Preparación'),
              leading: Icon(
                Icons.restaurant,
                color: Colors.blue,
              ),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(OrderStatus.inProgress);
              },
            ),
            ListTile(
              title: const Text('Listo para Servir'),
              leading: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(OrderStatus.ready);
              },
            ),
            ListTile(
              title: const Text('Entregado'),
              leading: Icon(
                Icons.delivery_dining,
                color: Colors.purple,
              ),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(OrderStatus.delivered);
              },
            ),
            ListTile(
              title: const Text('Completado'),
              leading: Icon(
                Icons.done_all,
                color: Colors.teal,
              ),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(OrderStatus.completed);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }


  void _updateOrderStatus(OrderStatus newStatus) {
    setState(() {
      _currentOrder = _currentOrder.copyWith(
        lastUpdated: DateTime.now(),
        items: _orderItems,
        status: newStatus,
        totalAmount: _calculateTotal(),
        subtotal: _calculateSubtotal(),
        taxAmount: _calculateTax(),
        customerName: _customerNameController.text.isEmpty ? null : _customerNameController.text,
        customerCount: _customerCount,
        waiterNotes: _notesController.text.isEmpty ? null : _notesController.text,
      );
    });
    if (widget.existingOrder != null) {
      _saveOrder();
    }
  }

  void _confirmCancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content: const Text('¿Estás seguro de que deseas cancelar este pedido? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Mantener'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(OrderStatus.cancelled);
            },
            child: const Text('Sí, Cancelar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _printOrderPreview() {
    // This would integrate with a printing service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviando pedido a la impresora...')),
    );
    
    final printService = ref.read(printServiceProvider);
    
    try {
          final orderForPrint = Order(
        id: _currentOrder.id,
        tableNumber: _currentOrder.tableNumber,
        tableId: _currentOrder.tableId,
        createdAt: _currentOrder.createdAt,
        lastUpdated: DateTime.now(),
        items: _orderItems,
        status: _currentOrder.status,
        totalAmount: _calculateTotal(),
        subtotal: _calculateSubtotal(),
        taxAmount: _calculateTax(),
        customerName: _customerNameController.text.isEmpty ? null : _customerNameController.text,
        customerCount: _customerCount,
        waiterNotes: _notesController.text.isEmpty ? null : _notesController.text,
        isPaid: _currentOrder.isPaid ?? false,
        paidAt: _currentOrder.paidAt,
        paymentMethod: _currentOrder.paymentMethod ?? '',
        tipAmount: _currentOrder.tipAmount ?? 0.0,
        cashierId: _currentOrder.cashierId,
        cashierName: _currentOrder.cashierName,
        orderNumber: _currentOrder.orderNumber ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        email: _currentOrder.email ?? '',
        userId: _currentOrder.userId ?? '',
        orderType: _currentOrder.orderType ?? 'dine_in',
        address: _currentOrder.address ?? '',
        latitude: _currentOrder.latitude ?? '0.0',
        longitude: _currentOrder.longitude ?? '0.0',
        paymentStatus: _currentOrder.paymentStatus ?? 'pending',
        timestamp: _currentOrder.timestamp ?? CloudFireStore.Timestamp.now(),
        orderDate: _currentOrder.orderDate ?? DateTime.now(),
        location: _currentOrder.location ?? <String, dynamic>{},
      );
      printService.printOrder(orderForPrint).then((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pedido enviado a impresión correctamente')),
          );
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al imprimir: $error')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _saveOrder() async {
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos en el pedido')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final orderService = ref.read(orderServiceProvider);
      final tableService = ref.read(tableServiceProvider);
      
           final orderToSave = Order(
        id: widget.existingOrder?.id ?? 'order_${DateTime.now().millisecondsSinceEpoch}',
        tableNumber: widget.table.number,
        tableId: widget.table.id,
        createdAt: widget.existingOrder?.createdAt ?? DateTime.now(),
        lastUpdated: DateTime.now(),
        items: _orderItems,
        status: _currentOrder.status,
        totalAmount: _calculateTotal(),
        subtotal: _calculateSubtotal(),
        taxAmount: _calculateTax(),
        customerName: _customerNameController.text.isEmpty ? null : _customerNameController.text,
        customerCount: _customerCount,
        waiterNotes: _notesController.text.isEmpty ? null : _notesController.text,
        isPaid: widget.existingOrder?.isPaid ?? false,
        paidAt: widget.existingOrder?.paidAt,
        paymentMethod: widget.existingOrder?.paymentMethod ?? '',
        tipAmount: widget.existingOrder?.tipAmount ?? 0.0,
        cashierId: widget.existingOrder?.cashierId,
        cashierName: widget.existingOrder?.cashierName,
        // Add missing required parameters
        orderNumber: widget.existingOrder?.orderNumber ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        email: widget.existingOrder?.email ?? '',
        userId: widget.existingOrder?.userId ?? '',
        orderType: widget.existingOrder?.orderType ?? 'dine_in',
        address: widget.existingOrder?.address ?? '',
        latitude: widget.existingOrder?.latitude ?? '0.0',
        longitude: widget.existingOrder?.longitude ?? '0.0',
        paymentStatus: widget.existingOrder?.paymentStatus ?? 'pending',
        timestamp: widget.existingOrder?.timestamp ?? CloudFireStore.Timestamp.now(),
        orderDate: widget.existingOrder?.orderDate ?? DateTime.now(),
        location: widget.existingOrder?.location ?? <String, dynamic>{},
      );
      // Save the order
      if (widget.existingOrder != null) {
        await orderService.updateOrder(orderToSave);
      } else {
        await orderService.createOrder(orderToSave);
        
        // If this is a new order, update the table status
        if (widget.table.status != TableStatus.occupied) {
          await tableService.updateTableStatus(
            widget.table.id, 
            TableStatus.occupied, 
            orderToSave.id,
          );
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen with the updated order
        Navigator.pop(context, orderToSave);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Menu Management Screen
class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({Key? key, required int initialTab}) : super(key: key);

  @override
  ConsumerState<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión del Menú'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Productos'),
            Tab(text: 'Categorías'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              ref.refresh(menuProductsProvider);
              ref.refresh(menuCategoriesProvider);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(theme),
          _buildCategoriesTab(theme),
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
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildProductsTab(ThemeData theme) {
    final products = ref.watch(menuProductsProvider);
    final categories = ref.watch(menuCategoriesProvider);
    
    return products.when(
      data: (productList) {
        return categories.when(
          data: (categoryList) {
            if (productList.isEmpty) {
              return const Center(
                child: Text('No hay productos en el menú'),
              );
            }
            
            return Column(
              children: [
                // Search and filter bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      // Implement search functionality
                    },
                  ),
                ),
                
                // Products list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      final product = productList[index];
                      final category = categoryList.firstWhere(
                        (cat) => cat.id == product.categoryId,
                        orElse: () => MenuCategory(id: 'unknown', name: 'Sin categoría', sortOrder: 999),
                      );
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showEditProductDialog(product, categoryList),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // Product image/placeholder
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.restaurant,
                                            size: 36,
                                            color: theme.colorScheme.primary.withOpacity(0.5),
                                          ),
                                        )
                                      : Icon(
                                          Icons.restaurant,
                                          size: 36,
                                          color: theme.colorScheme.primary.withOpacity(0.5),
                                        ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product.name,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (product.isSpecial)
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber.shade700,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category.name,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.description,
                                        style: theme.textTheme.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Switch(
                                            value: product.isAvailable,
                                            onChanged: (value) => _toggleProductAvailability(product),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Error al cargar categorías: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error al cargar productos: $error'),
      ),
    );
  }
  
  Widget _buildCategoriesTab(ThemeData theme) {
    final categories = ref.watch(menuCategoriesProvider);
    
    return categories.when(
      data: (categoryList) {
        if (categoryList.isEmpty) {
          return const Center(
            child: Text('No hay categorías definidas'),
          );
        }
        
        // Sort categories by sort order
        final sortedCategories = List<MenuCategory>.from(categoryList)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        
        return ReorderableListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedCategories.length,
          onReorder: (oldIndex, newIndex) {
            // Handle reordering
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            
            setState(() {
              final item = sortedCategories.removeAt(oldIndex);
              sortedCategories.insert(newIndex, item);
              
              // Update sort orders
              for (int i = 0; i < sortedCategories.length; i++) {
                final category = sortedCategories[i];
                if (category.sortOrder != i) {
                  _updateCategorySortOrder(category.id, i);
                }
              }
            });
          },
          itemBuilder: (context, index) {
            final category = sortedCategories[index];
            
            return Dismissible(
              key: Key(category.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar Categoría'),
                    content: Text('¿Estás seguro de que deseas eliminar la categoría "${category.name}"? Esta acción puede afectar a los productos asignados a esta categoría.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                _deleteCategory(category.id);
              },
              child: Card(
                key: Key('card_${category.id}'),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    category.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditCategoryDialog(category),
                  ),
                  onTap: () => _showEditCategoryDialog(category),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error al cargar categorías: $error'),
      ),
    );
  }
  
  // Dialog methods
  void _showAddProductDialog() {
    final categories = ref.read(menuCategoriesProvider);
    
    categories.when(
      data: (categoryList) {
        if (categoryList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes crear al menos una categoría primero')),
          );
          return;
        }
        
        showDialog(
          context: context,
          builder: (context) => AddEditProductDialog(
            categories: categoryList.map((category) => MenuCategory(
              id: category.id,
              name: category.name,
              sortOrder: category.sortOrder,
            )).toList(),
            onSave: (product) {
              ref.read(productServiceProvider).createProduct(product).then((_) {
                ref.refresh(menuProductsProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Producto agregado correctamente')),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              });
            },
          ),
        );
      },
      loading: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando categorías...')),
      ),
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      ),
    );
  }
  
  void _showEditProductDialog(MenuItem product, List<MenuCategory> categories) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(
        product: product,
        categories: categories,
        onSave: (updatedProduct) {
          ref.read(productServiceProvider).updateProduct(updatedProduct).then((_) {
            ref.refresh(menuProductsProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto actualizado correctamente')),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            );
          });
        },
      ),
    );
  }
  
  void _toggleProductAvailability(MenuItem product) {
    final updatedProduct = MenuItem(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      categoryId: product.categoryId,
      imageUrl: product.imageUrl,
      isAvailable: !product.isAvailable,
      isSpecial: product.isSpecial,
    );
    
    ref.read(productServiceProvider).updateProduct(updatedProduct).then((_) {
      ref.refresh(menuProductsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product.isAvailable
                ? '${product.name} marcado como no disponible'
                : '${product.name} marcado como disponible',
          ),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
  
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        onSave: (category) {
          ref.read(productServiceProvider).createCategory(category).then((_) {
            ref.refresh(menuCategoriesProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Categoría agregada correctamente')),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            );
          });
        },
      ),
    );
  }
  
  void _showEditCategoryDialog(MenuCategory category) {
    showDialog(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        category: category,
        onSave: (updatedCategory) {
          ref.read(productServiceProvider).updateCategory(updatedCategory).then((_) {
            ref.invalidate(menuCategoriesProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Categoría actualizada correctamente')),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $error')),
            );
          });
        },
      ),
    );
  }
  
  void _updateCategorySortOrder(String categoryId, int newSortOrder) {
    final categoryService = ref.read(productServiceProvider);
    
    categoryService.updateCategorySortOrder(categoryId, newSortOrder).then((_) {
      // No need to refresh the provider since we're already updating the UI
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el orden: $error')),
      );
    });
  }
  
  void _deleteCategory(String categoryId) {
    final categoryService = ref.read(productServiceProvider);
    
    categoryService.deleteCategory(categoryId).then((_) {
      ref.refresh(menuCategoriesProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría eliminada correctamente')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $error')),
      );
    });
  }
}

// Add/Edit Product Dialog
class AddEditProductDialog extends StatefulWidget {
  final MenuItem? product;
  final List<MenuCategory> categories;
  final Function(MenuItem) onSave;

  const AddEditProductDialog({
    Key? key,
    this.product,
    required this.categories,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _isSpecial = false;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _imageUrlController.text = widget.product!.imageUrl ?? '';
      _selectedCategoryId = widget.product!.categoryId;
      _isAvailable = widget.product!.isAvailable;
      _isSpecial = widget.product!.isSpecial;
    } else if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
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
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(widget.product != null ? 'Editar Producto' : 'Agregar Nuevo Producto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategoryId,
                items: widget.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un precio';
                  }
                  
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Por favor ingresa un precio válido';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la Imagen (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Disponible'),
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Especial del día'),
                value: _isSpecial,
                onChanged: (value) {
                  setState(() {
                    _isSpecial = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
  
  void _saveProduct() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final product = MenuItem(
        id: widget.product?.id ?? 'product_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        categoryId: _selectedCategoryId!,
        imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
        isAvailable: _isAvailable,
        isSpecial: _isSpecial,
      );
      
      widget.onSave(product);
      Navigator.pop(context);
    }
  }
}

// Add/Edit Category Dialog
class AddEditCategoryDialog extends StatefulWidget {
  final MenuCategory? category;
  final Function(MenuCategory) onSave;

  const AddEditCategoryDialog({
    Key? key,
    this.category,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _sortOrder = 0;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _sortOrder = widget.category!.sortOrder;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category != null ? 'Editar Categoría' : 'Agregar Nueva Categoría'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Categoría',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveCategory,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
  
  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = MenuCategory(
        id: widget.category?.id ?? 'category_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        sortOrder: widget.category?.sortOrder ?? _sortOrder,
      );
      
      widget.onSave(category);
      Navigator.pop(context);
    }
  }
}

// // Enhanced Models
// class MenuItem {
//   final String id;
//   final String name;
//   final String description;
//   final double price;
//   final String categoryId;
//   final String? imageUrl;
//   final bool isAvailable;
//   final bool isSpecial;

//   MenuItem({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.categoryId,
//     this.imageUrl,
//     this.isAvailable = true,
//     this.isSpecial = false,
//   });
// }

// class MenuCategory {
//   final String id;
//   final String name;
//   final int sortOrder;

//   MenuCategory({
//     required this.id,
//     required this.name,
//     required this.sortOrder,
//   });
// }

// Enhanced Order Model
// class Order {
//   final String id;
//   final int? tableNumber;
//   final String? tableId;
//   final DateTime createdAt;
//   final DateTime? lastUpdated;
//   final List<OrderItem> items;
//   final double totalAmount;
//   final OrderStatus status;
//   final String? customerName;
//   final int? customerCount;
//   final String? waiterNotes;

//   Order({
//     required this.id,
//     this.tableNumber,
//     this.tableId,
//     required this.createdAt,
//     this.lastUpdated,
//     required this.items,
//     required this.status,
//     required this.totalAmount,
//     this.customerName,
//     this.customerCount,
//     this.waiterNotes,
//   });
// }

// // Add the OrderItem class if it doesn't exist
// class OrderItem {
//   final String productId;
//   final String name;
//   final double price;
//   final int quantity;
//   final String? notes;

//   OrderItem({
//     required this.productId,
//     required this.name,
//     required this.price,
//     required this.quantity,
//     this.notes,
//   });
// }

// // Model-related providers
// final menuProductsProvider = FutureProvider<List<MenuItem>>((ref) {
//   final productService = ref.watch(productServiceProvider);
//   return productService.getProducts();
// });

// final menuCategoriesProvider = FutureProvider<List<MenuCategory>>((ref) {
//   final productService = ref.watch(productServiceProvider);
//   return productService.getCategories();
// });

 
// // Enhanced TableService with table management methods
// class TableService {
//   // Existing methods
  
//   Future<void> updateTableStatus(String tableId, TableStatus newStatus, [String? orderId]) async {
//     // Mock implementation - replace with real API calls
//     await Future.delayed(const Duration(milliseconds: 500));
//     // In a real app, you would update the table status in your database
//     // If orderId is provided, also update the currentOrderId field
//   }
// }

// Enhanced OrderService with order management methods
// class OrderService {
  // Existing methods
  
//   Future<void> createOrder(Order order) async {
//     // Mock implementation - replace with real API calls
//     await Future.delayed(const Duration(milliseconds: 500));
//     // In a real app, you would create the order in your database
//   }
  
//   Future<void> updateOrder(Order order) async {
//     // Mock implementation - replace with real API calls
//     await Future.delayed(const Duration(milliseconds: 500));
//     // In a real app, you would update the order in your database
//   }
  
//   Future<Order?> getOrderById(String orderId) async {
//     // Mock implementation - replace with real API calls
//     await Future.delayed(const Duration(milliseconds: 500));
    
//     // Return a mock order
//     return Order(
//       id: orderId,
//       tableNumber: 5,
//       tableId: 'table5',
//       createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
//       orderNumber: 'ORD-${orderId.substring(0, 6)}',
//       email: 'customer@example.com',
//       userId: 'user123',
//       orderType: OrderType.dineIn,
//       address: 'Restaurant Location',
//       latitude: 0.0,
//       longitude: 0.0,
//       paymentMethod:  'cash',
//       paymentStatus:  pending,
//       timestamp: DateTime.now().millisecondsSinceEpoch,
//       orderDate: DateTime.now(),
//       location: 'Main Restaurant',
//       id: orderId,
//       tableNumber: 5,
//       tableId: 'table5',
//       createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
//       items: [
//         OrderItem(
//           productId: 'product1',
//           name: 'Hamburguesa Clásica',
//           price: 9.99,
//           quantity: 2,
//         ),
//         OrderItem(
//           productId: 'product4',
//           name: 'Limonada',
//           price: 2.99,
//           quantity: 2,
//         ),
//       ],
//       status: OrderStatus.inProgress,
//       totalAmount: 25.96,
//       customerCount: 2,
//     );
//   }

// }