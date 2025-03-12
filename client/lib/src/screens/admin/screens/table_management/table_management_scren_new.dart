// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/services/resource_service.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/services/service_factory.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/table_form.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/responsive_layout.dart';
 

// // Extension for string conversion
// extension TableStatusExtension on TableStatus {
//   String get name {
//     switch (this) {
//       case TableStatusEnum.available:
//         return 'available';
//       case TableStatusEnum.occupied:
//         return 'occupied';
//       case TableStatusEnum.reserved:
//         return 'reserved';
//       case TableStatusEnum.maintenance:
//         return 'maintenance';
//       case TableStatusEnum.cleaning:
//         return 'cleaning';
//     }
//   }
  
//   static TableStatus fromString(String status) {
//     switch (status) {
//       case 'available':
//         return TableStatusEnum.available;
//       case 'occupied':
//         return TableStatusEnum.occupied;
//       case 'reserved':
//         return TableStatusEnum.reserved;
//       case 'maintenance':
//         return TableStatusEnum.maintenance;
//       default:
//         return TableStatusEnum.available;
//     }
//   }
// }

// // Table model that extends Resource
// class Table extends Resource {
//   final int number;
//   final int capacity;
//   final TableStatus status;
//   final Map<String, double> position; // x, y coordinates for floor plan
//   final String? currentOrderId;
  
//   Table({
//     required String id,
//     required String businessId,
//     required this.number,
//     required this.capacity,
//     this.status = TableStatusEnum.available,
//     this.position = const {'x': 0, 'y': 0},
//     this.currentOrderId,
//   }) : super(
//           id: id,
//           businessId: businessId,
//           type: 'table',
//           name: 'Table $number',
//           description: 'Capacity: $capacity',
//           attributes: {
//             'capacity': capacity,
//             'position': position,
//             'currentOrderId': currentOrderId,
//           },
//           status: status.name,
//           isActive: true,
//         );
  
//   factory Table.fromResource(Resource resource) {
//     final attributes = resource.attributes;
//     return Table(
//       id: resource.id,
//       businessId: resource.businessId,
//       number: int.tryParse(resource.name.replaceAll('Table ', '')) ?? 0,
//       capacity: attributes['capacity'] ?? 4,
//       status: TableStatusExtension.fromString(resource.status),
//       position: (attributes['position'] as Map<dynamic, dynamic>?)?.map(
//         (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
//       ) ?? {'x': 0, 'y': 0},
//       currentOrderId: attributes['currentOrderId'],
//     );
//   }
  
//   @override
//   Map<String, dynamic> toFirestore() {
//     final data = super.toFirestore();
//     data['attributes'] = {
//       'capacity': capacity,
//       'position': position,
//       'currentOrderId': currentOrderId,
//     };
//     return data;
//   }
  
//   Table copyWith({
//     String? id,
//     String? businessId,
//     int? number,
//     int? capacity,
//     TableStatus? status,
//     Map<String, double>? position,
//     String? currentOrderId,
//   }) {
//     return Table(
//       id: id ?? this.id,
//       businessId: businessId ?? this.businessId,
//       number: number ?? this.number,
//       capacity: capacity ?? this.capacity,
//       status: status ?? this.status,
//       position: position ?? this.position,
//       currentOrderId: currentOrderId ?? this.currentOrderId,
//     );
//   }
// }

// class TableManagementScreen extends ConsumerStatefulWidget {
//   const TableManagementScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<TableManagementScreen> createState() => _TableManagementScreenState();
// }

// class _TableManagementScreenState extends ConsumerState<TableManagementScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   String _filterStatus = '';
  
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
  
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TabBar(
//                     controller: _tabController,
//                     tabs: const [
//                       Tab(text: 'List View'),
//                       Tab(text: 'Floor Plan'),
//                     ],
//                     indicatorSize: TabBarIndicatorSize.label,
//                     labelColor: Theme.of(context).colorScheme.primary,
//                     unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
//                     isScrollable: true,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 if (_tabController.index == 0)
//                   _buildStatusFilter(),
//               ],
//             ),
//           ),
          
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildTableList(),
//                 _buildFloorPlan(),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddTableDialog,
//         tooltip: 'Add Table',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
  
//   Widget _buildStatusFilter() {
//     return DropdownButton<String>(
//       value: _filterStatus.isEmpty ? 'all' : _filterStatus,
//       items: const [
//         DropdownMenuItem(value: 'all', child: Text('All Tables')),
//         DropdownMenuItem(value: 'available', child: Text('Available')),
//         DropdownMenuItem(value: 'occupied', child: Text('Occupied')),
//         DropdownMenuItem(value: 'reserved', child: Text('Reserved')),
//         DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
//       ],
//       onChanged: (value) {
//         setState(() {
//           _filterStatus = value == 'all' ? '' : value!;
//         });
//       },
//       hint: const Text('Filter by Status'),
//     );
//   }
  
//   Widget _buildTableList() {
//     final resourceService = ref.watch(
//       serviceFactoryProvider.select((factory) => 
//         factory.createResourceService('table')
//       )
//     );
    
//     return ref.watch(tableResourcesProvider).when(
//       data: (resources) {
//         // Convert resources to Table objects
//         final tables = resources
//             .map((resource) => Table.fromResource(resource))
//             .toList();
        
//         // Apply status filter if set
//         final filteredTables = _filterStatus.isEmpty
//             ? tables
//             : tables.where((table) => table.status.name == _filterStatus).toList();
        
//         // Sort by table number
//         filteredTables.sort((a, b) => a.number.compareTo(b.number));
        
//         if (filteredTables.isEmpty) {
//           return const Center(
//             child: Text('No tables found'),
//           );
//         }
        
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: ResponsiveGridView(
//             children: filteredTables.map((table) => 
//               _buildTableCard(table)
//             ).toList(),
//           ),
//         );
//       },
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stackTrace) => Center(child: Text('Error: $error')),
//     );
//   }
  
//   Widget _buildFloorPlan() {
//     return ref.watch(tableResourcesProvider).when(
//       data: (resources) {
//         // Convert resources to Table objects
//         final tables = resources
//             .map((resource) => Table.fromResource(resource))
//             .toList();
        
//         return FloorPlanEditor(
//           tables: tables,
//           onTableMoved: _updateTablePosition,
//           onTableTapped: _showTableDetails,
//         );
//       },
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stackTrace) => Center(child: Text('Error: $error')),
//     );
//   }
  
//   Widget _buildTableCard(RestaurantTable table) {
//     final theme = Theme.of(context);
    
//     return Card(
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: () => _showTableDetails(table),
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Table number and status indicator
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.primaryContainer,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           'Table ${table.number}',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: theme.colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                       const Spacer(),
//                       Container(
//                         width: 12,
//                         height: 12,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: _getStatusColor(table.status),
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         _capitalizeFirst(table.status.name),
//                         style: TextStyle(
//                           color: _getStatusColor(table.status),
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   // Table icon
//                   Center(
//                     child: Icon(
//                       Icons.table_restaurant,
//                       size: 48,
//                       color: _getStatusColor(table.status).withOpacity(0.5),
//                     ),
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   // Capacity
//                   Row(
//                     children: [
//                       const Icon(Icons.people, size: 16),
//                       const SizedBox(width: 4),
//                       Text('Capacity: ${table.capacity}'),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 8),
                  
//                   // Current order if any
//                   if (table.currentOrderId != null) ...[
//                     Row(
//                       children: [
//                         const Icon(Icons.receipt_long, size: 16),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Order: #${table.currentOrderId!.substring(0, 6)}',
//                           style: TextStyle(
//                             color: theme.colorScheme.primary,
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 8),
//                   ],
                  
//                   // Action buttons
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.edit, size: 20),
//                         onPressed: () => _showEditTableDialog(table),
//                         tooltip: 'Edit',
//                         visualDensity: VisualDensity.compact,
//                       ),
//                       if (table.status != TableStatusEnum.occupied)
//                         IconButton(
//                           icon: const Icon(Icons.delete, size: 20),
//                           onPressed: () => _confirmDeleteTable(table),
//                           tooltip: 'Delete',
//                           visualDensity: VisualDensity.compact,
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             // Status color bar
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 height: 4,
//                 color: _getStatusColor(table.status),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   void _showAddTableDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 400),
//           child: TableForm(
//             onSave: (table) {
//               Navigator.pop(context);
//               _addTable(table);
//             },
//             onCancel: () => Navigator.pop(context),
//           ),
//         ),
//       ),
//     );
//   }
  
//   void _showEditTableDialog(RestaurantTable table) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 400),
//           child: TableForm(
//             table: table,
//             onSave: (updatedTable) {
//               Navigator.pop(context);
//               _updateTable(updatedTable);
//             },
//             onCancel: () => Navigator.pop(context),
//           ),
//         ),
//       ),
//     );
//   }
  
//   void _showTableDetails(RestaurantTable table) {
//     final theme = Theme.of(context);
    
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'Table ${table.number}',
//                   style: theme.textTheme.headlineSmall,
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(table.status).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     _capitalizeFirst(table.status.name),
//                     style: TextStyle(
//                       color: _getStatusColor(table.status),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 16),
            
//             Row(
//               children: [
//                 _buildDetailItem(
//                   icon: Icons.people,
//                   label: 'Capacity',
//                   value: '${table.capacity} people',
//                 ),
//                 const SizedBox(width: 24),
//                 _buildDetailItem(
//                   icon: Icons.place,
//                   label: 'Position',
//                   value: 'x: ${table.position['x']?.toStringAsFixed(1)}, y: ${table.position['y']?.toStringAsFixed(1)}',
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 16),
            
//             if (table.currentOrderId != null) ...[
//               _buildDetailItem(
//                 icon: Icons.receipt_long,
//                 label: 'Current Order',
//                 value: '#${table.currentOrderId!.substring(0, 6)}',
//               ),
              
//               const SizedBox(height: 16),
              
//               OutlinedButton.icon(
//                 icon: const Icon(Icons.visibility),
//                 label: const Text('View Order'),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   context.push('/admin/orders/${table.currentOrderId}');
//                 },
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 36),
//                 ),
//               ),
//             ],
            
//             const SizedBox(height: 16),
            
//             if (table.status == TableStatusEnum.available || table.status == TableStatusEnum.reserved) ...[
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.add_shopping_cart),
//                 label: const Text('Create New Order'),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _createOrderForTable(table);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 36),
//                 ),
//               ),
              
//               const SizedBox(height: 8),
//             ],
            
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     icon: const Icon(Icons.edit),
//                     label: const Text('Edit Table'),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _showEditTableDialog(table);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: _buildStatusUpdateButton(table),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildDetailItem({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, size: 16),
//         const SizedBox(width: 4),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//               ),
//             ),
//             Text(value),
//           ],
//         ),
//       ],
//     );
//   }
  
//   Widget _buildStatusUpdateButton(Table table) {
//     // If occupied, show different options
//     if (table.status == TableStatusEnum.occupied) {
//       return OutlinedButton.icon(
//         icon: const Icon(Icons.check_circle),
//         label: const Text('Mark Available'),
//         onPressed: () {
//           Navigator.pop(context);
//           _confirmTableAvailable(table);
//         },
//         style: OutlinedButton.styleFrom(
//           foregroundColor: Colors.green,
//         ),
//       );
//     }
    
//     // For other statuses, show dropdown for status change
//     return OutlinedButton.icon(
//       icon: const Icon(Icons.update),
//       label: const Text('Change Status'),
//       onPressed: () {
//         Navigator.pop(context);
//         _showChangeStatusDialog(table);
//       },
//     );
//   }
  
//   void _confirmTableAvailable(Table table) {
//     if (table.currentOrderId != null) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Table has active order'),
//           content: const Text(
//             'This table has an active order. Please complete or cancel the order before marking the table as available.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('OK'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 if (table.currentOrderId != null) {
//                   context.push('/admin/orders/${table.currentOrderId}');
//                 }
//               },
//               child: const Text('View Order'),
//             ),
//           ],
//         ),
//       );
//       return;
//     }
    
//     // If no active order, confirm making available
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Mark Table as Available?'),
//         content: Text(
//           'Are you sure you want to mark Table ${table.number} as available?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _updateTableStatus(table, TableStatusEnum.available);
//             },
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );
//   }
  
//   void _showChangeStatusDialog(Table table) {
//     showDialog(
//       context: context,
//       builder: (context) => SimpleDialog(
//         title: Text('Change Status for Table ${table.number}'),
//         children: [
//           SimpleDialogOption(
//             onPressed: () {
//               Navigator.pop(context);
//               _updateTableStatus(table, TableStatusEnum.available);
//             },
//             child: const ListTile(
//               leading: Icon(Icons.check_circle, color: Colors.green),
//               title: Text('Available'),
//             ),
//           ),
//           SimpleDialogOption(
//             onPressed: () {
//               Navigator.pop(context);
//               _updateTableStatus(table, TableStatusEnum.reserved);
//             },
//             child: const ListTile(
//               leading: Icon(Icons.schedule, color: Colors.orange),
//               title: Text('Reserved'),
//             ),
//           ),
//           SimpleDialogOption(
//             onPressed: () {
//               Navigator.pop(context);
//               _updateTableStatus(table, TableStatusEnum.maintenance);
//             },
//             child: const ListTile(
//               leading: Icon(Icons.build, color: Colors.blue),
//               title: Text('Maintenance'),
//             ),
//           ),
//           SimpleDialogOption(
//             onPressed: () => Navigator.pop(context),
//             child: const ListTile(
//               leading: Icon(Icons.cancel),
//               title: Text('Cancel'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   void _confirmDeleteTable(Table table) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Table'),
//         content: Text('Are you sure you want to delete Table ${table.number}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteTable(table);
//             },
//             child: const Text('Delete'),
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.red,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // CRUD operations
//   Future<void> _addTable(RestaurantTable table) async {
//     try {
//       final resourceService = ref.read(
//         serviceFactoryProvider.select((factory) => 
//           factory.createResourceService('table')
//         )
//       );
      
//       // Convert to Resource
//       final resource = Resource(
//         id: table.id,
//         businessId: table.businessId,
//         type: 'table',
//         name: 'Table ${table.number}',
//         description: 'Capacity: ${table.capacity}',
//         attributes: {
//           'capacity': table.capacity,
//           'position': table.position,
//           'currentOrderId': table.currentOrderId,
//         },
//         status: table.status.name,
//         isActive: true,
//       );
      
//       await resourceService.addResource(resource);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Table added successfully')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error adding table: $e')),
//         );
//       }
//     }
//   }
  
//   Future<void> _updateTable(RestaurantTable table) async {
//     try {
//       final resourceService = ref.read(
//         serviceFactoryProvider.select((factory) => 
//           factory.createResourceService('table')
//         )
//       );
      
//       // Convert to Resource
//       final resource = Resource(
//         id: table.id,
//         businessId: table.businessId,
//         type: 'table',
//         name: 'Table ${table.number}',
//         description: 'Capacity: ${table.capacity}',
//         attributes: {
//           'capacity': table.capacity,
//           'position': table.position,
//           'currentOrderId': table.currentOrderId,
//         },
//         status: table.status.name,
//         isActive: true,
//       );
      
//       await resourceService.updateResource(resource);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Table updated successfully')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating table: $e')),
//         );
//       }
//     }
//   }
  
//   Future<void> _deleteTable(Table table) async {
//     try {
//       final resourceService = ref.read(
//         serviceFactoryProvider.select((factory) => 
//           factory.createResourceService('table')
//         )
//       );
      
//       await resourceService.deleteResource(table.id);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Table deleted successfully')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error deleting table: $e')),
//         );
//       }
//     }
//   }
  
//   Future<void> _updateTableStatus(Table table, TableStatus newStatus) async {
//     try {
//       final resourceService = ref.read(
//         serviceFactoryProvider.select((factory) => 
//           factory.createResourceService('table')
//         )
//       );
      
//       await resourceService.updateResourceStatus(table.id, newStatus.name);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(
//             'Table ${table.number} status updated to ${_capitalizeFirst(newStatus.name)}'
//           )),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating table status: $e')),
//         );
//       }
//     }
//   }
  
//   Future<void> _updateTablePosition(Table table, Map<String, double> newPosition) async {
//     try {
//       final resourceService = ref.read(
//         serviceFactoryProvider.select((factory) => 
//           factory.createResourceService('table')
//         )
//       );
      
//       // Create updated table with new position
//       final updatedTable = table.copyWith(position: newPosition);
      
//       // Convert to Resource
//       final resource = Resource(
//         id: updatedTable.id,
//         businessId: updatedTable.businessId,
//         type: 'table',
//         name: 'Table ${updatedTable.number}',
//         description: 'Capacity: ${updatedTable.capacity}',
//         attributes: {
//           'capacity': updatedTable.capacity,
//           'position': updatedTable.position,
//           'currentOrderId': updatedTable.currentOrderId,
//         },
//         status: updatedTable.status.name,
//         isActive: true,
//       );
      
//       await resourceService.updateResource(resource);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating table position: $e')),
//         );
//       }
//     }
//   }
  
//   void _createOrderForTable(Table table) {
//     // Navigate to create order screen with table pre-selected
//     context.push('/admin/orders/create?tableId=${table.id}');
//   }
  
//   Color _getStatusColor(TableStatus status) {
//     switch (status) {
//       case TableStatusEnum.available:
//         return Colors.green;
//       case TableStatusEnum.occupied:
//         return Colors.red;
//       case TableStatusEnum.reserved:
//         return Colors.orange;
//       case TableStatusEnum.maintenance:
//         return Colors.blue;
//     }
//   }
  
//   String _capitalizeFirst(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1);
//   }
// }

// // Provider for all table resources
// final tableResourcesProvider = StreamProvider<List<Resource>>((ref) {
//   final resourceService = ref.watch(
//     serviceFactoryProvider.select((factory) => 
//       factory.createResourceService('table')
//     )
//   );
  
//   return resourceService.getResourcesStream();
// });