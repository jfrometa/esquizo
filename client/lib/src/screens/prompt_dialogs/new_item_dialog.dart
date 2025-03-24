import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An enhanced dialog for adding custom catering items with better UI and validation
class NewItemDialog {
  /// Shows a dialog or bottom sheet for adding a new catering item
  static Future<void> show({
    required BuildContext context,
    required void Function(String name, String description, int? quantity) onAddItem,
    String? initialName,
    String? initialDescription,
    int? initialQuantity,
  }) async {
    final TextEditingController nameController = TextEditingController(text: initialName);
    final TextEditingController descController = TextEditingController(text: initialDescription);
    final TextEditingController quantityController = TextEditingController(
      text: initialQuantity?.toString() ?? '1',
    );
    
    final formKey = GlobalKey<FormState>();
    bool isAdding = false;
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.sizeOf(context).width > 600;
    
    // Create a stateful builder to handle validation state
    Widget formContent(StateSetter setState) {
      return Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant_menu, 
                      color: colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      initialName != null ? 'Editar Item' : 'Nuevo Item',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Item name field
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del item *',
                hintText: 'Ej: Entrada de ceviche',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.fastfood),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre del item es requerido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Quantity field
            TextFormField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Cantidad *',
                hintText: 'Número de unidades',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.numbers),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                helperText: 'Cantidad por persona o mesa',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La cantidad es requerida';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Ingresa una cantidad válida';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Descripción (Opcional)',
                hintText: 'Agrega detalles o especificaciones',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 45),
                  child: Icon(Icons.description),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              maxLines: 3,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isAdding 
                    ? null 
                    : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text('Cancelar', 
                    style: TextStyle(color: isAdding ? colorScheme.onSurface.withOpacity(0.5) : null),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: isAdding
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          // Set loading state
                          setState(() => isAdding = true);
                          
                          // Get values
                          final name = nameController.text.trim();
                          final description = descController.text.trim();
                          final quantity = int.tryParse(quantityController.text) ?? 1;
                          
                          // Add haptic feedback
                          HapticFeedback.mediumImpact();
                          
                          // Add the item
                          onAddItem(name, description, quantity);
                          
                          // Close the dialog
                          Navigator.of(context).pop();
                        }
                      },
                  icon: isAdding
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add),
                  label: Text(initialName != null ? 'Actualizar' : 'Agregar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    try {
      if (isDesktop) {
        // Show a desktop dialog
        await showDialog(
          context: context,
          barrierDismissible: !isDesktop, // Only dismissible on mobile
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: theme.colorScheme.surface,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
              padding: const EdgeInsets.all(24),
              child: StatefulBuilder(builder: (context, setState) => formContent(setState)),
            ),
          ),
        );
      } else {
        // Show a full-screen dialog on mobile
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (BuildContext context) => Scaffold(
              appBar: AppBar(
                title: Text(
                  initialName != null ? 'Editar Item' : 'Nuevo Item',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                backgroundColor: colorScheme.surface,
                centerTitle: true,
                elevation: 0,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Item icon
                              Center(
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    size: 32,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Item name field
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nombre del item *',
                                  hintText: 'Ej: Entrada de ceviche',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.fastfood),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                ),
                                textCapitalization: TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El nombre del item es requerido';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Quantity field
                              TextFormField(
                                controller: quantityController,
                                decoration: InputDecoration(
                                  labelText: 'Cantidad *',
                                  hintText: 'Número de unidades',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.numbers),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                  helperText: 'Cantidad por persona o mesa',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La cantidad es requerida';
                                  }
                                  final quantity = int.tryParse(value);
                                  if (quantity == null || quantity <= 0) {
                                    return 'Ingresa una cantidad válida';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Description field
                              TextFormField(
                                controller: descController,
                                decoration: InputDecoration(
                                  labelText: 'Descripción (Opcional)',
                                  hintText: 'Agrega detalles o especificaciones',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(bottom: 45),
                                    child: Icon(Icons.description),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                ),
                                maxLines: 3,
                                minLines: 3,
                                textCapitalization: TextCapitalization.sentences,
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Save button
                              SizedBox(
                                height: 56,
                                child: FilledButton.icon(
                                  onPressed: isAdding
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          // Set loading state
                                          setState(() => isAdding = true);
                                          
                                          // Get values
                                          final name = nameController.text.trim();
                                          final description = descController.text.trim();
                                          final quantity = int.tryParse(quantityController.text) ?? 1;
                                          
                                          // Add haptic feedback
                                          HapticFeedback.mediumImpact();
                                          
                                          // Add the item
                                          onAddItem(name, description, quantity);
                                          
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                        }
                                      },
                                  icon: isAdding
                                    ? Container(
                                        width: 24,
                                        height: 24,
                                        padding: const EdgeInsets.all(2.0),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                  label: Text(
                                    initialName != null ? 'Actualizar' : 'Agregar Item',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colorScheme.secondary,
                                    foregroundColor: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Cancel button
                              SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: isAdding 
                                    ? null 
                                    : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: colorScheme.secondary),
                                  ),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      color: isAdding ? colorScheme.onSurface.withOpacity(0.5) : colorScheme.secondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    } finally {
      // Clean up controllers to prevent memory leaks
      nameController.dispose();
      descController.dispose();
      quantityController.dispose();
    }
  }
}

/// A card to showcase a catering item with edit and delete options
class CateringItemCard extends StatelessWidget {
  final String title;
  final int quantity;
  final String? description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double? price;

  const CateringItemCard({
    super.key,
    required this.title,
    required this.quantity,
    this.description,
    required this.onEdit,
    required this.onDelete,
    this.price,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$quantity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
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
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (description != null && description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              description!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  Column(
                    children: [
                      if (price != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'S/ ${price!.toStringAsFixed(2)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            onPressed: onEdit,
                            tooltip: 'Editar',
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                              padding: const EdgeInsets.all(8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            onPressed: onDelete,
                            tooltip: 'Eliminar',
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.errorContainer.withOpacity(0.5),
                              padding: const EdgeInsets.all(8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section widget for displaying catering items with a add button
class CateringItemsSection extends StatelessWidget {
  final List<Widget> items;
  final String title;
  final VoidCallback onAddItem;
  final bool isEmpty;
  final IconData sectionIcon;
  
  const CateringItemsSection({
    super.key,
    required this.items,
    required this.title,
    required this.onAddItem,
    this.isEmpty = false,
    this.sectionIcon = Icons.restaurant_menu,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      sectionIcon,
                      size: 20,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                FilledButton.tonalIcon(
                  onPressed: onAddItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.onSecondaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        sectionIcon,
                        size: 48,
                        color: colorScheme.outline.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay items agregados',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: onAddItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Item'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...items,
          ],
        ),
      ),
    );
  }
}