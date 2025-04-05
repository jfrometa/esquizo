import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/api_services/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/screens/catering_management/models/catering_order_model.dart';

class CateringOrderDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;
  
  const CateringOrderDetailsScreen({
    required this.orderId,
    super.key,
  });

  @override
  CateringOrderDetailsScreenState createState() =>
      CateringOrderDetailsScreenState();
}

class CateringOrderDetailsScreenState
    extends ConsumerState<CateringOrderDetailsScreen> {
  bool isEditing = false;

  // Temporary variables to store changes before applying
  late bool tempHasChef;
  late String tempAlergias;
  late String tempEventType;
  late String tempPreferencia;
  late String tempAdicionales;
  late int tempCantidadPersonas;

  @override
  void initState() {
    super.initState();
    // We'll initialize these values when the order data is available
    tempHasChef = false;
    tempAlergias = '';
    tempEventType = '';
    tempPreferencia = 'salado';
    tempAdicionales = '';
    tempCantidadPersonas = 0;
  }

  void _initTempValues(CateringOrder order) {
    tempHasChef = order.hasChef;
    tempAlergias = order.alergias;
    tempEventType = order.eventType;
    tempPreferencia = order.preferencia;
    tempAdicionales = order.adicionales;
    tempCantidadPersonas = order.guestCount;
  }

  void _saveChanges(CateringOrder order) {
    // Save changes to Firestore using the provider
    ref.read(cateringOrderProvider.notifier).updateFirestoreOrder(
          order.copyWith(
            guestCount: tempCantidadPersonas,
            hasChef: tempHasChef,
            alergias: tempAlergias,
            eventType: tempEventType,
            preferencia: tempPreferencia,
            adicionales: tempAdicionales,
          ),
        );
    
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order details updated'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
    
    setState(() {
      isEditing = false; // Exit edit mode
    });
  }

  void _cancelEditing(CateringOrder order) {
    // Revert temporary values to original
    setState(() {
      _initTempValues(order);
      isEditing = false;
    });
    
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    // Use StreamProvider to get the order stream
    final orderStream = ref.watch(cateringOrderStreamProvider(widget.orderId));
    
    return Scaffold(
      body: FutureBuilder<CateringOrder>(
        future: orderStream.first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error loading order: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Order not found'),
            );
          }
          
          final order = snapshot.data!;
          
          // Initialize temp values if not editing
          if (!isEditing) {
            _initTempValues(order);
          }
          
          return _buildScreenWithOrder(context, order);
        },
      ),
    );
  }
  
  Widget _buildScreenWithOrder(BuildContext context, CateringOrder order) {
    final bool hasItems = order.items.isNotEmpty;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 2,
        title: Text(
          isEditing ? 'Edit Order Details' : 'Order Details', 
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isEditing
                ? Row(
                    key: const ValueKey('editing_actions'),
                    children: [
                      TextButton.icon(
                        onPressed: () => _cancelEditing(order),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _saveChanges(order),
                        icon: const Icon(Icons.check),
                        label: const Text('Save'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  )
                : IconButton(
                    key: const ValueKey('edit_button'),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Order',
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
          ),
        ],
      ),
      body: !hasItems
          ? _buildEmptyState(theme, colorScheme)
          : _buildOrderDetails(order, theme, colorScheme),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.no_food,
            size: 64,
            color: colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'No Items in Order',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This catering order has no items',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderDetails(CateringOrder order, ThemeData theme, ColorScheme colorScheme) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order title card
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          radius: 24,
                          child: Icon(Icons.restaurant, color: colorScheme.onPrimary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.id.isNotEmpty ? order.id : "Catering Order",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (order.adicionales.isNotEmpty)
                                Text(
                                  order.adicionales,
                                  style: theme.textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Order details section
                _buildSectionHeader(theme, 'Order Information'),
                const SizedBox(height: 8),
                
                Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      _buildEditableField(
                        icon: Icons.people,
                        label: 'Number of People',
                        value: tempCantidadPersonas.toString(),
                        onChanged: (newValue) {
                          int? updatedValue = int.tryParse(newValue);
                          if (updatedValue != null) {
                            setState(() {
                              tempCantidadPersonas = updatedValue;
                            });
                          }
                        },
                        keyboardType: TextInputType.number,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                      const Divider(height: 1, indent: 56),
                      
                      _buildEditableField(
                        icon: Icons.event,
                        label: 'Event Type',
                        value: tempEventType,
                        onChanged: (newValue) {
                          setState(() {
                            tempEventType = newValue;
                          });
                        },
                        placeholder: 'E.g. Wedding, Birthday Party, Corporate',
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                      const Divider(height: 1, indent: 56),
                      
                      _buildEditableField(
                        icon: Icons.warning_amber,
                        label: 'Allergies',
                        value: tempAlergias,
                        onChanged: (newValue) {
                          setState(() {
                            tempAlergias = newValue;
                          });
                        },
                        placeholder: 'Any food allergies or restrictions',
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                      const Divider(height: 1, indent: 56),
                      
                      _buildEditableField(
                        icon: Icons.note,
                        label: 'Additional Notes',
                        value: tempAdicionales,
                        onChanged: (newValue) {
                          setState(() {
                            tempAdicionales = newValue;
                          });
                        },
                        placeholder: 'Special requests or additional information',
                        multiline: true,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                      const Divider(height: 1, indent: 56),
                      
                      // Chef service option
                      _buildChefToggle(theme, colorScheme),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Order items section
                _buildSectionHeader(theme, 'Order Items'),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        
        // Order items list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = order.items[index];
                return _buildOrderItemCard(
                  item: item, 
                  index: index, 
                  theme: theme, 
                  colorScheme: colorScheme,
                );
              },
              childCount: order.items.length,
            ),
          ),
        ),
        
        // Total price and summary
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  color: colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Order Price',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Only show checkout button for non-completed orders
                        if (!order.status.isTerminal)
                          FilledButton.icon(
                            onPressed: () {
                              // Handle checkout based on order status
                              // For now, just go back
                              Navigator.pop(context);
                            },
                            icon: order.status == CateringOrderStatus.pending 
                                ? const Icon(Icons.payment) 
                                : const Icon(Icons.visibility),
                            label: order.status == CateringOrderStatus.pending 
                                ? const Text('Checkout') 
                                : const Text('View Status'),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required String value,
    required Function(String) onChanged,
    required ThemeData theme,
    required ColorScheme colorScheme,
    String placeholder = '',
    bool multiline = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: isEditing ? () {} : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isEditing)
                      TextField(
                        controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(
                          TextPosition(offset: value.length),
                        ),
                        onChanged: onChanged,
                        keyboardType: keyboardType,
                        maxLines: multiline ? 3 : 1,
                        decoration: InputDecoration(
                          hintText: placeholder,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
                        ),
                      )
                    else
                      Text(
                        value.isEmpty ? placeholder : value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: value.isEmpty ? colorScheme.onSurfaceVariant.withOpacity(0.7) : colorScheme.onSurface,
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
  
  Widget _buildChefToggle(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.restaurant, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chef Service',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Include a professional chef for your event',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: tempHasChef,
              onChanged: isEditing
                  ? (value) {
                      setState(() {
                        tempHasChef = value;
                      });
                      HapticFeedback.selectionClick();
                    }
                  : null,
              activeColor: colorScheme.primary,
              inactiveTrackColor: isEditing 
                  ? colorScheme.surfaceContainerHighest 
                  : colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderItemCard({
    required CateringOrderItem item,
    required int index,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '× ${item.quantity}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.price > 0)
                        Text(
                          '\$${item.price.toStringAsFixed(2)} per unit',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                
                // Item price
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                
                // Edit/delete buttons when in edit mode
                if (isEditing)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: colorScheme.primary, size: 20),
                        onPressed: () => _editItemDialog(context, item, index),
                        tooltip: 'Edit item',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: colorScheme.error, size: 20),
                        onPressed: () => _showDeleteConfirmation(context, index),
                        tooltip: 'Remove item',
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _editItemDialog(BuildContext context, CateringOrderItem item, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quantityController = TextEditingController(text: item.quantity.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Item', style: theme.textTheme.titleLarge),
        icon: const Icon(Icons.edit),
        iconColor: colorScheme.primary,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: colorScheme.onSurface),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.format_list_numbered),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed:  () async {
              final parsedValue = int.tryParse(quantityController.text) ?? 1;
              
              if (parsedValue <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quantity must be greater than zero'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              
              // Get the current order from the stream's value
              final orderAsyncValue = await ref.read(cateringOrderStreamProvider(widget.orderId)).first;
              
              // Use the AsyncValue.when pattern to safely access the data
               
                // Create a new list of items with the updated quantity
                final updatedItems = List<CateringOrderItem>.from(orderAsyncValue.items);
                updatedItems[index] = item.copyWith(quantity: parsedValue);
                
                // Update the order with the new items
                ref.read(cateringOrderProvider.notifier).updateFirestoreOrder(
                  orderAsyncValue.copyWith(items: updatedItems),
                );
              
              
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Item updated'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            icon: const Icon(Icons.check),
            label: const Text('Update'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        icon: Icon(Icons.delete, color: colorScheme.error),
        content: const Text('Are you sure you want to remove this item from the order?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              // Get the current order
              final order = await ref.read(cateringOrderStreamProvider(widget.orderId)).first;
              
                // Create a new list of items without the removed item
                final updatedItems = List<CateringOrderItem>.from(order.items)
                  ..removeAt(index);
                
                // Update the order with the new items
                ref.read(cateringOrderProvider.notifier).updateFirestoreOrder(
                  order.copyWith(items: updatedItems),
                );
            
              
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Item removed'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            icon: const Icon(Icons.delete),
            label: const Text('Remove'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}