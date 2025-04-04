// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart'; 
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/create_order.dart';
 

// // Restaurant-specific table service
// class TableService {
//   final FirebaseFirestore _firestore;
//   final String _restaurantId;
  
//   TableService({
//     FirebaseFirestore? firestore,
//     required String restaurantId,
//   }) : 
//     _firestore = firestore ?? FirebaseFirestore.instance,
//     _restaurantId = restaurantId;
  
//   // Collection reference
//   CollectionReference get _tablesCollection => 
//       _firestore.collection('businesses').doc(_restaurantId).collection('tables');

  
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
//   Future<void> updateTableStatus(String tableId, TableStatusEnum status, [String? orderId]) async {
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
//       debugPrint('Error fetching table: $e');
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
//       debugPrint('Error fetching tables: $e');
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
//       debugPrint('Error adding table: $e');
//       rethrow;
//     }

//   }
 
//   // Get table statistics
//   Future<TableStats> getTableStats() async {
//     try {
//       final snapshot = await _tablesCollection.get();
//       final tables = snapshot.docs.map((doc) => RestaurantTable.fromFirestore(doc)).toList();
      
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
//       debugPrint('Error calculating table stats: $e');
//       return TableStats(
//         totalTables: 0,
//         occupiedTables: 0,
//         reservedTables: 0,
//         cleaningTables: 0,
//       );
//     }
//   }
 

// }    