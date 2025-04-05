import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/table_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/order/order_admin_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/providers/restaurant/table_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/restaurant/restaurant_service.dart';
 import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
 import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

import 'dart:math' as math;
 
class TableManagementScreen extends ConsumerStatefulWidget {
  const TableManagementScreen({super.key});

  @override
  ConsumerState<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends ConsumerState<TableManagementScreen> {
  bool _isEditMode = false;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tables = ref.watch(tablesStatusProvider );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Mesas'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            tooltip: _isEditMode ? 'Guardar Cambios' : 'Editar Distribución',
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.refresh(tablesStatusProvider ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildInfoBar(theme),
              Expanded(
                child: tables.when(
                  data: (tableList) {
                    if (tableList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_restaurant,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay mesas configuradas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar Mesa'),
                              onPressed: _showAddTableDialog,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return _isEditMode
                        ? _buildEditModeView(tableList.cast<RestaurantTable>(), theme)
                        : _buildTableLayout(tableList.cast<RestaurantTable>(), theme);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('Error al cargar mesas: $error'),
                  ),
                ),
              ),
            ],
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: _isEditMode
          ? FloatingActionButton(
              onPressed: _showAddTableDialog,
              tooltip: 'Agregar Mesa',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: _buildLegend(theme),
    );
  }
  
  Widget _buildInfoBar(ThemeData theme) {
    final stats = ref.watch(restaurantStatsProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: stats.when(
        data: (data) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Mesas Ocupadas',
              '${data.occupiedTables}/${data.totalTables}',
              Icons.table_restaurant,
              Colors.orange,
            ),
            _buildStatItem(
              'Mesas Disponibles',
              '${data.totalTables - data.occupiedTables}',
              Icons.check_circle_outline,
              Colors.green,
            ),
            _buildStatItem(
              'En Limpieza',
              '${data.cleaningTables}',
              Icons.cleaning_services_outlined,
              Colors.blue,
            ),
          ],
        ),
        loading: () => const Center(child: LinearProgressIndicator()),
        error: (_, __) => const Text('Error al cargar estadísticas'),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTableLayout(List<RestaurantTable> tables, ThemeData theme) {
    // Sort tables by number
    final sortedTables = List<RestaurantTable>.from(tables)
      ..sort((a, b) => a.number.compareTo(b.number));
    
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/kako-logo.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.1),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: sortedTables.length,
        itemBuilder: (context, index) {
          return _buildTableCard(sortedTables[index]);
        },
      ),
    );
  }
  
  Widget _buildEditModeView(List<RestaurantTable> tables, ThemeData theme) {
    // Sort tables by number
    final sortedTables = List<RestaurantTable>.from(tables)
      ..sort((a, b) => a.number.compareTo(b.number));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedTables.length,
      itemBuilder: (context, index) {
        final table = sortedTables[index];
        
        return Dismissible(
          key: Key(table.id),
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
            if (table.status == TableStatusEnum.occupied) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se puede eliminar una mesa ocupada'),
                ),
              );
              return false;
            }
            
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar Mesa'),
                content: Text('¿Estás seguro de que deseas eliminar la Mesa ${table.number}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            _deleteTable(table.id);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(table.status).withOpacity(0.2),
                child: Text(
                  '${table.number}',
                  style: TextStyle(
                    color: _getStatusColor(table.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text('Mesa ${table.number}'),
              subtitle: Text(
                'Capacidad: ${table.capacity} personas • Estado: ${_getStatusText(table.status)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditTableDialog(table),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () => _showTableQRCode(table),
                  ),
                ],
              ),
              onTap: () => _showEditTableDialog(table),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildTableCard(RestaurantTable table) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor(table.status).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _handleTableTap(table),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Table number and status
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(table.status).withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Mesa ${table.number}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(table.status),
                      ),
                    ),
                  ),
                ),
                
                // Table visual representation
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: _buildTableShape(table, theme),
                    ),
                  ),
                ),
                
                // Table info
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Capacity
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${table.capacity} ${table.capacity == 1 ? 'persona' : 'personas'}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      
                      // Status text
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(table.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(table.status),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(table.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // QR code indicator
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.qr_code, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  padding: const EdgeInsets.all(4),
                ),
                onPressed: () => _showTableQRCode(table),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTableShape(RestaurantTable table, ThemeData theme) {
    final tableShape = table.shape ?? TableShape.rectangle;
    final color = _getStatusColor(table.status);
    
    switch (tableShape) {
      case TableShape.rectangle:
        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '${table.number}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      
      case TableShape.round:
        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${table.number}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        
      case TableShape.oval:
        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(40),
          ),
          alignment: Alignment.center,
          child: Text(
            '${table.number}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }
  
  Widget _buildLegend(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Disponible', Colors.green, theme),
          _buildLegendItem('Ocupada', Colors.red, theme),
          _buildLegendItem('Reservada', Colors.orange, theme),
          _buildLegendItem('Limpieza', Colors.blue, theme),
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
  
  void _handleTableTap(RestaurantTable table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                // Table header
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getStatusColor(table.status).withOpacity(0.2),
                        border: Border.all(
                          color: _getStatusColor(table.status),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${table.number}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _getStatusColor(table.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mesa ${table.number}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(table.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(table.status),
                              style: TextStyle(
                                color: _getStatusColor(table.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 32),
                
                // Table details
                _buildDetailRow('Capacidad', '${table.capacity} personas'),
                // if (table.location != null)
                //   _buildDetailRow('Ubicación', table.location!),
                
                const SizedBox(height: 24),
                
                // Button section
                Column(
                  children: [
                    if (table.status == TableStatusEnum.available) ...[
                      _buildActionButton(
                        icon: Icons.add_shopping_cart,
                        label: 'Crear Nuevo Pedido',
                        onPressed: () {
                          Navigator.pop(context);
                          _createNewOrderForTable(table);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.event_available,
                        label: 'Marcar como Reservada',
                        onPressed: () {
                          Navigator.pop(context);
                          _updateTableStatus(table, TableStatusEnum.reserved);
                        },
                      ),
                    ],
                    
                    if (table.status == TableStatusEnum.occupied) ...[
                      if (table.currentOrderId != null)
                        _buildActionButton(
                          icon: Icons.receipt_long,
                          label: 'Ver Pedido Actual',
                          onPressed: () {
                            Navigator.pop(context);
                            _viewTableOrder(table);
                          },
                        ),
                      _buildActionButton(
                        icon: Icons.done_all,
                        label: 'Marcar como Completada',
                        onPressed: () {
                          Navigator.pop(context);
                          _showCompleteTableDialog(table);
                        },
                      ),
                    ],
                    
                    if (table.status == TableStatusEnum.reserved) ...[
                      _buildActionButton(
                        icon: Icons.add_shopping_cart,
                        label: 'Crear Nuevo Pedido',
                        onPressed: () {
                          Navigator.pop(context);
                          _createNewOrderForTable(table);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.event_busy,
                        label: 'Cancelar Reserva',
                        onPressed: () {
                          Navigator.pop(context);
                          _updateTableStatus(table, TableStatusEnum.available);
                        },
                      ),
                    ],
                    
                    if (table.status == TableStatusEnum.cleaning)
                      _buildActionButton(
                        icon: Icons.check_circle,
                        label: 'Marcar como Disponible',
                        onPressed: () {
                          Navigator.pop(context);
                          _updateTableStatus(table, TableStatusEnum.available);
                        },
                      ),
                    
                    if (table.status != TableStatusEnum.cleaning)
                      _buildActionButton(
                        icon: Icons.cleaning_services,
                        label: 'Marcar para Limpieza',
                        onPressed: () {
                          Navigator.pop(context);
                          _updateTableStatus(table, TableStatusEnum.cleaning);
                        },
                      ),
                      
                    _buildActionButton(
                      icon: Icons.qr_code,
                      label: 'Ver Código QR',
                      onPressed: () {
                        Navigator.pop(context);
                        _showTableQRCode(table);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onPressed,
      ),
    );
  }
  
  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditTableDialog(),
    ).then((result) {
      if (result == true) {
        ref.refresh(tablesStatusProvider );
      }
    });
  }
  
  void _showEditTableDialog(RestaurantTable table) {
    showDialog(
      context: context,
      builder: (context) => AddEditTableDialog(table: table),
    ).then((result) {
      if (result == true) {
        ref.refresh(tablesStatusProvider );
      }
    });
  }
  
  void _showTableQRCode(RestaurantTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Código QR Mesa ${table.number}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
              ),
              child: CustomPaint(
                painter: QRCodePlaceholder(tableId: table.id),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Escanea este código para realizar pedidos directamente desde tu dispositivo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Imprimir'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enviando QR a impresión...')),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _createNewOrderForTable(RestaurantTable table) {
    Navigator.of(context).pushNamed(
      '/create-order',
      arguments: table,
    ).then((_) {
      ref.refresh(tablesStatusProvider );
    });
  }
  
  void _viewTableOrder(RestaurantTable table) {
    if (table.currentOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta mesa no tiene un pedido activo')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final orderService = ref.read(orderServiceProvider);
    
    orderService.getOrderById(table.currentOrderId!).then((order) {
      setState(() {
        _isLoading = false;
      });
      
      if (order != null) {
        Navigator.of(context).pushNamed(
          '/order-details',
          arguments: order,
        ).then((_) {
          ref.refresh(tablesStatusProvider );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cargar el pedido')),
        );
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
  
  void _showCompleteTableDialog(RestaurantTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Completar Mesa ${table.number}'),
        content: const Text('¿Confirmas que el cliente ya pagó y la mesa está lista para limpieza?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateTableStatus(table, TableStatusEnum.cleaning);
              
              // If there's an active order, mark it as completed
              if (table.currentOrderId != null) {
                final orderService = ref.read(orderServiceProvider);
                orderService.getOrderById(table.currentOrderId!).then((order) {
                  if (order != null) {
                    orderService.updateOrderStatus(order.id, OrderStatus.completed);
                  }
                });
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
  
  void _updateTableStatus(RestaurantTable table, TableStatusEnum newStatus) {
    setState(() {
      _isLoading = true;
    });
    
    final tableService = ref.read(tableServiceProvider);
    
    tableService.updateTableStatus(table.id, newStatus).then((_) {
      setState(() {
        _isLoading = false;
      });
      
      ref.refresh(tablesStatusProvider );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesa ${table.number} actualizada a ${_getStatusText(newStatus)}')),
      );
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
  
  void _deleteTable(String tableId) {
    setState(() {
      _isLoading = true;
    });
    
    final tableService = ref.read(tableServiceProvider);
    
    tableService.deleteTable(tableId).then((_) {
      setState(() {
        _isLoading = false;
      });
      
      ref.invalidate(tablesStatusProvider );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesa eliminada correctamente')),
      );
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
  
  Color _getStatusColor(TableStatusEnum status) {
    switch (status) {
      case TableStatusEnum.available:
        return Colors.green;
      case TableStatusEnum.occupied:
        return Colors.red;
      case TableStatusEnum.reserved:
        return Colors.orange;
      case TableStatusEnum.cleaning:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusText(TableStatusEnum status) {
    switch (status) {
      case TableStatusEnum.available:
        return 'Disponible';
      case TableStatusEnum.occupied:
        return 'Ocupada';
      case TableStatusEnum.reserved:
        return 'Reservada';
      case TableStatusEnum.cleaning:
        return 'Limpieza';
      default:
        return 'Desconocido';
    }
  }
}

class AddEditTableDialog extends ConsumerStatefulWidget {
  final RestaurantTable? table;
  
  const AddEditTableDialog({
    super.key,
    this.table,
  });

  @override
  ConsumerState<AddEditTableDialog> createState() => _AddEditTableDialogState();
}

class _AddEditTableDialogState extends ConsumerState<AddEditTableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();
  
  TableStatusEnum _status = TableStatusEnum.available;
  TableShape _shape = TableShape.rectangle;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.table != null) {
      _numberController.text = widget.table!.number.toString();
      _capacityController.text = widget.table!.capacity.toString();
      // _locationController.text = widget.table!.location ?? '';
      _status = widget.table!.status;
      _shape = widget.table!.shape ?? TableShape.rectangle;
    }
  }
  
  @override
  void dispose() {
    _numberController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(widget.table != null ? 'Editar Mesa' : 'Agregar Nueva Mesa'),
      content: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Table number
                  TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Mesa',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un número de mesa';
                      }
                      
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Ingresa un número válido';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Capacity
                  TextFormField(
                    controller: _capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacidad (número de personas)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa la capacidad';
                      }
                      
                      final capacity = int.tryParse(value);
                      if (capacity == null || capacity <= 0) {
                        return 'Ingresa un número válido';
                      }
                      
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Location (optional)
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación (opcional)',
                      border: OutlineInputBorder(),
                      hintText: 'Ej. Terraza, Interior, Ventana',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status
                  DropdownButtonFormField<TableStatusEnum>(
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    value: _status,
                    items: [
                      DropdownMenuItem(
                        value: TableStatusEnum.available,
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            const Text('Disponible'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: TableStatusEnum.reserved,
                        child: Row(
                          children: [
                            Icon(Icons.event_available, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            const Text('Reservada'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: TableStatusEnum.cleaning,
                        child: Row(
                          children: [
                            Icon(Icons.cleaning_services, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            const Text('Limpieza'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Table shape
                  const Text('Forma de la Mesa'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildShapeOption(TableShape.rectangle, 'Rectangular'),
                      _buildShapeOption(TableShape.round, 'Kako'),
                      _buildShapeOption(TableShape.oval, 'Ovalada'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveTable,
          child: Text(widget.table != null ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }
  
  Widget _buildShapeOption(TableShape shape, String label) {
    final theme = Theme.of(context);
    final isSelected = _shape == shape;
    
    Widget shapeWidget;
    
    switch (shape) {
      case TableShape.rectangle:
        shapeWidget = Container(
          width: 40,
          height: 30,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
        break;
        
      case TableShape.round:
        shapeWidget = Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
        );
        break;
        
      case TableShape.oval:
        shapeWidget = Container(
          width: 40,
          height: 30,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
        );
        break;
    }
    
    return InkWell(
      onTap: () {
        setState(() {
          _shape = shape;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? theme.colorScheme.primaryContainer : null,
        ),
        child: Column(
          children: [
            shapeWidget,
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveTable() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final tableService = ref.read(tableServiceProvider);
    
    final table = RestaurantTable(
      id: widget.table?.id ?? 'table_${DateTime.now().millisecondsSinceEpoch}',
      number: int.parse(_numberController.text),
      capacity: int.parse(_capacityController.text),
      status: _status,
      // location: _locationController.text.isEmpty ? null : _locationController.text,
      shape: _shape as TableShape?,
      currentOrderId: widget.table?.currentOrderId, businessId: '',
    );
    
    Future<void> operation;
    
    if (widget.table != null) {
      operation = tableService.updateTable(table);
    } else {
      operation = tableService.addTable(table);
    }
    
    operation.then((_) {
      Navigator.pop(context, true);
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
}
 

class QRCodePlaceholder extends CustomPainter {
  final String tableId;
  
  QRCodePlaceholder({required this.tableId});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    // Draw the finder patterns (corners)
    _drawFinderPattern(canvas, Offset(30, 30), 30, paint);
    _drawFinderPattern(canvas, Offset(size.width - 30, 30), 30, paint);
    _drawFinderPattern(canvas, Offset(30, size.height - 30), 30, paint);
    
    // Draw random dots to simulate QR code
    final random = math.Random(tableId.hashCode);
    for (int i = 0; i < 300; i++) {
      final x = 60 + random.nextDouble() * (size.width - 120);
      final y = 60 + random.nextDouble() * (size.height - 120);
      
      if (random.nextBool()) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 8, height: 8),
          paint,
        );
      }
    }
  }
  
  void _drawFinderPattern(Canvas canvas, Offset center, double size, Paint paint) {
    // Outer square
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size, height: size),
      paint,
    );
    
    // Inner white square
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.7),
      whitePaint,
    );
    
    // Inner black square
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size * 0.4, height: size * 0.4),
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

