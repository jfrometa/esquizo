// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/table_model.dart';

// // Stats classes
// class TableStats {
//   final int totalTables;
//   final int occupiedTables;
//   final int reservedTables;
//   final int cleaningTables;
  
//   TableStats({
//     required this.totalTables,
//     required this.occupiedTables,
//     required this.reservedTables,
//     required this.cleaningTables,
//   });
// }


// class TableService {
//   final FirebaseFirestore _firestore;
  
//   TableService({FirebaseFirestore? firestore}) 
//       : _firestore = firestore ?? FirebaseFirestore.instance;
  
//   // Collection reference
//   CollectionReference get _tablesCollection => 
//       _firestore.collection('restaurants').doc('default').collection('tables');
  
//   // Get all tables
//   Stream<List<RestaurantTable>> getTables() {
//     return _tablesCollection
//         .orderBy('number')
//         .snapshots()
//         .map((snapshot) {
//           return snapshot.docs
//               .map((doc) => RestaurantTable.fromFirestore(doc))
//               .toList();
//         });
//   }
  
//   // Get a single table
//   Future<RestaurantTable?> getTable(String tableId) async {
//     final doc = await _tablesCollection.doc(tableId).get();
//     if (doc.exists) {
//       return RestaurantTable.fromFirestore(doc);
//     }
//     return null;
//   }
  
//   // Create a new table
//   Future<String> createTable(RestaurantTable table) async {
//     // Check if table number already exists
//     final existingTables = await _tablesCollection
//         .where('number', isEqualTo: table.number)
//         .get();
    
//     if (existingTables.docs.isNotEmpty) {
//       throw Exception('Ya existe una mesa con el número ${table.number}');
//     }
    
//     final docRef = await _tablesCollection.add(table.toFirestore());
//     return docRef.id;
//   }
  
//   // Update a table
//   Future<void> updateTable(RestaurantTable table) async {
//     // Check if table number already exists (excluding this table)
//     final existingTables = await _tablesCollection
//         .where('number', isEqualTo: table.number)
//         .where(FieldPath.documentId, isNotEqualTo: table.id)
//         .get();
    
//     if (existingTables.docs.isNotEmpty) {
//       throw Exception('Ya existe una mesa con el número ${table.number}');
//     }
    
//     await _tablesCollection.doc(table.id).update(table.toFirestore());
//   }
  
//   // Update table status
//   Future<void> updateTableStatus(String tableId, TableStatus status, [String? orderId]) async {
//     final updates = {
//       'status': status.toString().split('.').last,
//       'updatedAt': FieldValue.serverTimestamp(),
//     };
    
//     if (orderId != null) {
//       updates['currentOrderId'] = orderId;
//     } else if (status == TableStatusEnum.available) {
//       // Clear the current order ID if the table is available
//       updates['currentOrderId'] = FieldValue.delete();
//     }
    
//     await _tablesCollection.doc(tableId).update(updates);
//   }
  
//   // Delete a table
//   Future<void> deleteTable(String tableId) async {
//     await _tablesCollection.doc(tableId).delete();
//   }

//   // Stream all tables (real-time updates)
//   Stream<List<RestaurantTable>> getTablesStream() {
//     return _tablesCollection
//         .orderBy('number')
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => RestaurantTable.fromFirestore(doc))
//             .toList());
//   }
  
//   // Stream only active tables
//   Stream<List<RestaurantTable>> getActiveTablesStream() {
//     return _tablesCollection
//         .where('isActive', isEqualTo: true)
//         .orderBy('number')
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//             .map((doc) => RestaurantTable.fromFirestore(doc))
//             .toList());
//   }
  
//   // Get table by ID
//   Future<RestaurantTable?> getTableById(String tableId) async {
//     try {
//       final doc = await _tablesCollection.doc(tableId).get();
//       if (doc.exists) {
//         return RestaurantTable.fromFirestore(doc);
//       }
//       return null;
//     } catch (e) {
//       print('Error fetching table: $e');
//       return null;
//     }
//   }
  
//   // Get all tables
//   Future<List<RestaurantTable>> getAllTables() async {
//     try {
//       final snapshot = await _tablesCollection.orderBy('number').get();
//       return snapshot.docs
//           .map((doc) => RestaurantTable.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       print('Error fetching tables: $e');
//       return [];
//     }
//   }
  
//   // Add a new table
//   Future<void> addTable(RestaurantTable table) async {
//     try {
//       // Check if table number already exists
//       final existingTables = await _tablesCollection
//           .where('number', isEqualTo: table.number)
//           .limit(1)
//           .get();
      
//       if (existingTables.docs.isNotEmpty) {
//         throw Exception('Ya existe una mesa con el número ${table.number}');
//       }
      
//       await _tablesCollection.doc(table.id).set(table.toFirestore());
//     } catch (e) {
//       print('Error adding table: $e');
//       throw e;
//     }
//   }
  
  
//   // Get table statistics
//   Future<TableStats> getTableStats() async {
//     try {
//       final tables = await getAllTables();
      
//       final totalTables = tables.where((table) => table.isActive).length;
//       final occupiedTables = tables.where((table) => table.status == TableStatusEnum.occupied).length;
//       final reservedTables = tables.where((table) => table.status == TableStatusEnum.reserved).length;
//       final cleaningTables = tables.where((table) => table.status == TableStatusEnum.maintenance).length;
      
//       return TableStats(
//         totalTables: totalTables,
//         occupiedTables: occupiedTables,
//         reservedTables: reservedTables,
//         cleaningTables: cleaningTables,
//       );
//     } catch (e) {
//       print('Error calculating table stats: $e');
//       return TableStats(
//         totalTables: 0,
//         occupiedTables: 0,
//         reservedTables: 0,
//         cleaningTables: 0,
//       );
//     }
//   }
// }

// // Provider for table service
// final tableServiceProvider = Provider<TableService>((ref) {
//   return TableService();
// });

// // Provider for tables stream
// // final tablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
// //   final tableService = ref.watch(tableServiceProvider);
// //   return tableService.getTables();
// // });

// // Provider for a single table
// final tableProvider = FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
//   final tableService = ref.watch(tableServiceProvider);
//   return tableService.getTable(tableId);
// });

// // Table-related stream providers
// final tablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
//   final tableService = ref.watch(tableServiceProvider);
//   return tableService.getTablesStream();
// });

// final tablesStatusProvider = FutureProvider<List<RestaurantTable>>((ref) {
//   final tableService = ref.watch(tableServiceProvider);
//   return tableService.getAllTables();
// });

// final activeTablesProvider = StreamProvider<List<RestaurantTable>>((ref) {
//   final tableService = ref.watch(tableServiceProvider);
//   return tableService.getActiveTablesStream();
// });

// final availableTablesProvider = FutureProvider<List<RestaurantTable>>((ref) async {
//   final allTables = await ref.watch(tablesStatusProvider.future);
//   return allTables.where((table) => 
//     table.status == TableStatusEnum.available || 
//     table.status == TableStatusEnum.reserved
//   ).toList();
// });

// final tableByIdProvider = FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
//   final tableService = ref.watch(tableServiceProvider);
//   return tableService.getTableById(tableId);
// });
