// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/restaurant/services/table_service.dart'; 
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/services/table_service.dart';
// import '../../services/resource_service.dart';

// class RestaurantTableService extends ResourceService {
//   RestaurantTableService({
//     required String businessId,
//     FirebaseFirestore? firestore,
//   }) : super(
//           businessId: businessId,
//           resourceType: 'table',
//           firestore: firestore,
//         );
  
//   // Convert generic Resource to RestaurantTable
//   RestaurantTable _convertToRestaurantTable(Resource resource) {
//     return RestaurantTable(
//       id: resource.id,
//       number: int.tryParse(resource.name) ?? 0,
//       capacity: resource.attributes['capacity'] ?? 4,
//       status: _parseTableStatus(resource.status),
//       isActive: resource.isActive,
//       currentOrderId: resource.attributes['currentOrderId'], 
//     );
//   }
  
//   // Parse table status from string
//   TableStatus _parseTableStatus(String status) {
//     switch (status) {
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
  
//   // Convert RestaurantTable to Resource
//   Resource _convertToResource(RestaurantTable table) {
//     return Resource(
//       id: table.id,
//       businessId: _businessId,
//       type: 'table',
//       name: table.number.toString(),
//       description: 'Table ${table.number}',
//       attributes: {
//         'capacity': table.capacity,
//         'currentOrderId': table.currentOrderId,
//         // 'location': table.location,
//       },
//       status: table.status.toString().split('.').last,
//       isActive: table.isActive,
//     );
//   }
  
//   // Get all tables
//   Stream<List<RestaurantTable>> getTablesStream() {
//     return super.getResourcesStream().map((resources) {
//       return resources.map(_convertToRestaurantTable).toList();
//     });
//   }
  
//   // Get active tables
//   Stream<List<RestaurantTable>> getActiveTablesStream() {
//     return super.getActiveResourcesStream().map((resources) {
//       return resources.map(_convertToRestaurantTable).toList();
//     });
//   }
  
//   // Get tables by status
//   Stream<List<RestaurantTable>> getTablesByStatusStream(TableStatus status) {
//     final statusString = status.toString().split('.').last;
//     return super.getResourcesByStatusStream(statusString).map((resources) {
//       return resources.map(_convertToRestaurantTable).toList();
//     });
//   }
  
//   // Get table by ID
//   Future<RestaurantTable?> getTableById(String tableId) async {
//     final resource = await super.getResourceById(tableId);
//     if (resource == null) {
//       return null;
//     }
//     return _convertToRestaurantTable(resource);
//   }
  
//   // Create a new table
//   Future<String> createTable(RestaurantTable table) async {
//     final resource = _convertToResource(table);
//     final docRef = await super.createResource(resource);
//     return docRef;
//   }
  
//   // Update a table
//   Future<void> updateTable(RestaurantTable table) async {
//     final resource = _convertToResource(table);
//     await super.updateResource(resource);
//   }
  
//   // Update table status
//   Future<void> updateTableStatus(String tableId, TableStatus status, [String? orderId]) async {
//     final statusString = status.toString().split('.').last;
//     final updates = <String, dynamic>{
//       'status': statusString,
//     };
    
//     if (orderId != null) {
//       updates['attributes.currentOrderId'] = orderId;
//     } else if (status == TableStatusEnum.available) {
//       updates['attributes.currentOrderId'] = FieldValue.delete();
//     }
    
//     await super.updateResourcePartial(tableId, updates);
//   }
  
//   // Get table statistics
//   Future<TableStats> getTableStats() async {
//     final resourceStats = await super.getResourceStats();
    
//     return TableStats(
//       totalTables: resourceStats.totalResources,
//       occupiedTables: resourceStats.statusCounts['occupied'] ?? 0,
//       reservedTables: resourceStats.statusCounts['reserved'] ?? 0,
//       cleaningTables: resourceStats.statusCounts['maintenance'] ?? 0,
//     );
//   }
// }