import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/catering/catering_order_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/cathering_order_item.dart';

class CateringOrderDetailsScreen extends ConsumerStatefulWidget {
  const CateringOrderDetailsScreen({super.key});

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
  
  // Controller for animated transitions
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final cateringOrders = ref.read(cateringOrderProvider)!;

    // Initialize temporary values with the existing order values
    tempHasChef = cateringOrders.hasChef ?? false;
    tempAlergias = cateringOrders.alergias;
    tempEventType = cateringOrders.eventType;
    tempPreferencia = cateringOrders.preferencia;
    tempAdicionales = cateringOrders.adicionales;
    tempCantidadPersonas = cateringOrders.peopleCount ?? 0;
  }

  void _saveChanges() {
    final cateringOrders = ref.read(cateringOrderProvider)!;
    // Save changes to the provider
    ref.read(cateringOrderProvider.notifier).finalizeCateringOrder(
      title: cateringOrders.title,
      img: cateringOrders.img,
      cantidadPersonas: tempCantidadPersonas,
      hasChef: tempHasChef,
      alergias: tempAlergias,
      eventType: tempEventType,
      preferencia: tempPreferencia,
      adicionales: tempAdicionales,
      description: cateringOrders.description,
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

  void _cancelEditing() {
    final cateringOrders = ref.read(cateringOrderProvider)!;
    // Revert temporary values to original
    setState(() {
      tempHasChef = cateringOrders.hasChef ?? false;
      tempAlergias = cateringOrders.alergias;
      tempEventType = cateringOrders.eventType;
      tempPreferencia = cateringOrders.preferencia;
      tempAdicionales = cateringOrders.adicionales;
      tempCantidadPersonas = cateringOrders.peopleCount ?? 0;
      isEditing = false;
    });
    
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final CateringOrderItem cateringOrders = ref.watch(cateringOrderProvider)!;
    final bool hasItems = cateringOrders.dishes.isNotEmpty;
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
                        onPressed: _cancelEditing,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _saveChanges,
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
          : _buildOrderDetails(cateringOrders, theme, colorScheme),
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
            'Your catering order has no items',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Catering'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderDetails(CateringOrderItem order, ThemeData theme, ColorScheme colorScheme) {
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
                  color: colorScheme.surfaceVariant.withOpacity(0.7),
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
                                order.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (order.description.isNotEmpty)
                                Text(
                                  order.description,
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
                final dish = order.dishes[index];
                return _buildOrderItemCard(
                  dish: dish, 
                  index: index, 
                  theme: theme, 
                  colorScheme: colorScheme,
                );
              },
              childCount: order.dishes.length,
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
                              '\$${order.totalPrice.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: () {
                            // Proceed to checkout action
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Checkout'),
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
                  ? colorScheme.surfaceVariant 
                  : colorScheme.surfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderItemCard({
    required CateringDish dish,
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
                    '× ${dish.quantity}',
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
                        dish.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((dish.pricePerUnit ?? 0) > 0)
                        Text(
                          '\$${(dish.pricePerUnit ?? 0).toStringAsFixed(2)} per unit',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                
                // Item price
                Text(
                  '\$${(dish.hasUnitSelection ? dish.quantity * (dish.pricePerUnit ?? 0) : dish.peopleCount * tempCantidadPersonas * (dish.pricePerPerson)).toStringAsFixed(2)}',
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
                        onPressed: () => _editDishDialog(context, dish, index),
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
  
  void _editDishDialog(BuildContext context, CateringDish dish, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quantityController = TextEditingController(
      text: dish.hasUnitSelection
          ? dish.quantity.toString()
          : dish.peopleCount.toString()
    );
    
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
              dish.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: dish.hasUnitSelection ? 'Quantity' : 'Servings per Person',
                labelStyle: TextStyle(color: colorScheme.onSurface),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: dish.hasUnitSelection
                    ? const Icon(Icons.format_list_numbered)
                    : const Icon(Icons.person),
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
            onPressed: () {
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
              
              if (dish.hasUnitSelection) {
                ref.read(cateringOrderProvider.notifier).updateDish(
                  index,
                  dish.copyWith(quantity: parsedValue),
                );
              } else {
                ref.read(cateringOrderProvider.notifier).updateDish(
                  index,
                  dish.copyWith(peopleCount: parsedValue),
                );
              }
              
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
        content: const Text('Are you sure you want to remove this item from your order?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              ref.read(cateringOrderProvider.notifier).removeFromCart(index);
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