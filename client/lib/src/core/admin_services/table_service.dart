import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

import 'package:starter_architecture_flutter_firebase/src/core/providers/business/business_config_provider.dart';

import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/create_order.dart';

/// A unified service for managing restaurant tables
/// Consolidates functionality from multiple table-related services
class TableService {
  final FirebaseFirestore _firestore;
  final String _businessId;
  final CollectionReference _tablesCollection;

  /// Constructor with optional FirebaseFirestore instance for testing
  TableService({
    FirebaseFirestore? firestore,
    required String businessId,
    required String restaurantId,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _businessId = businessId,
        _tablesCollection = (firestore ?? FirebaseFirestore.instance)
            .collection('businesses')
            .doc(businessId)
            .collection('resources') as CollectionReference<Object?>;

  // ===== STREAM OPERATIONS =====

  /// Stream all tables with real-time updates
  Stream<List<RestaurantTable>> getTablesStream() {
    return _tablesCollection
        .orderBy('number')
        .snapshots()
        .map((snapshot) => _mapTablesToList(snapshot));
  }

  /// Stream only active tables with real-time updates
  Stream<List<RestaurantTable>> getActiveTablesStream() {
    return _tablesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('number')
        .snapshots()
        .map((snapshot) => _mapTablesToList(snapshot));
  }

  /// Stream tables filtered by status
  Stream<List<RestaurantTable>> getTablesByStatusStream(
      TableStatusEnum status) {
    final statusStr = status.toString().split('.').last;
    return _tablesCollection
        .where('status', isEqualTo: statusStr)
        .orderBy('number')
        .snapshots()
        .map((snapshot) => _mapTablesToList(snapshot));
  }

  /// Stream available tables (for reservations)
  Stream<List<RestaurantTable>> getAvailableTablesStream() {
    return _tablesCollection
        .where('status', whereIn: [
          TableStatusEnum.available.toString().split('.').last,
          TableStatusEnum.reserved.toString().split('.').last
        ])
        .orderBy('number')
        .snapshots()
        .map((snapshot) => _mapTablesToList(snapshot));
  }

  // ===== FUTURE OPERATIONS =====

  /// Get a single table by ID
  Future<RestaurantTable?> getTable(String tableId) async {
    try {
      final doc = await _tablesCollection.doc(tableId).get();

      if (doc.exists) {
        return RestaurantTable.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching table: $e');
      return null;
    }
  }

  /// Get all tables (non-stream version)
  Future<List<RestaurantTable>> getAllTables() async {
    try {
      final snapshot = await _tablesCollection.orderBy('number').get();

      return _mapTablesToList(snapshot);
    } catch (e) {
      debugPrint('Error fetching tables: $e');
      return [];
    }
  }

  /// Create a new table
  Future<String> createTable(RestaurantTable table) async {
    try {
      // Check if table number already exists
      final existingTables = await _tablesCollection
          .where('number', isEqualTo: table.number)
          .get();

      if (existingTables.docs.isNotEmpty) {
        throw Exception('Ya existe una mesa con el número ${table.number}');
      }

      // Generate a new ID if one wasn't provided
      final docRef = table.id.isEmpty
          ? _tablesCollection.doc()
          : _tablesCollection.doc(table.id);

      // Create the table with the new or specified ID
      final tableWithId =
          table.id.isEmpty ? table.copyWith(id: docRef.id) : table;

      await docRef.set(tableWithId.toFirestore());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating table: $e');
      rethrow;
    }
  }

  /// Update an existing table
  Future<void> updateTable(RestaurantTable table) async {
    try {
      // Check if table number already exists (excluding this table)
      final existingTables = await _tablesCollection
          .where('number', isEqualTo: table.number)
          .where(FieldPath.documentId, isNotEqualTo: table.id)
          .get();

      if (existingTables.docs.isNotEmpty) {
        throw Exception('Ya existe una mesa con el número ${table.number}');
      }

      await _tablesCollection.doc(table.id).update(table.toFirestore());
    } catch (e) {
      debugPrint('Error updating table: $e');
      rethrow;
    }
  }

  /// Update table status with optional order ID
  Future<void> updateTableStatus(String tableId, TableStatusEnum status,
      [String? orderId]) async {
    try {
      final updates = {
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (orderId != null) {
        updates['currentOrderId'] = orderId;
      } else if (status == TableStatusEnum.available) {
        // Clear the current order ID if the table is available
        updates['currentOrderId'] = FieldValue.delete();
      }

      await _tablesCollection.doc(tableId).update(updates);
    } catch (e) {
      debugPrint('Error updating table status: $e');
      rethrow;
    }
  }

  /// Delete a table
  Future<void> deleteTable(String tableId) async {
    try {
      // Check if table has active orders
      final table = await getTable(tableId);
      if (table != null && table.currentOrderId != null) {
        throw Exception('No se puede eliminar una mesa con órdenes activas');
      }

      await _tablesCollection.doc(tableId).delete();
    } catch (e) {
      debugPrint('Error deleting table: $e');
      rethrow;
    }
  }

  Future<void> addTable(RestaurantTable table) async {
    try {
      // Check if table number already exists
      final existingTables = await _tablesCollection
          .where('number', isEqualTo: table.number)
          .limit(1)
          .get();

      if (existingTables.docs.isNotEmpty) {
        throw Exception('Ya existe una mesa con el número ${table.number}');
      }

      await _tablesCollection.doc(table.id).set(table.toFirestore());
    } catch (e) {
      debugPrint('Error adding table: $e');
      rethrow;
    }
  }

  /// Get table statistics
  Future<TableStats> getTableStats() async {
    try {
      final snapshot = await _tablesCollection.get();
      final tables = _mapTablesToList(snapshot);

      final totalTables = tables.where((table) => table.isActive).length;
      final occupiedTables = tables
          .where((table) => table.status == TableStatusEnum.occupied)
          .length;
      final reservedTables = tables
          .where((table) => table.status == TableStatusEnum.reserved)
          .length;
      final cleaningTables = tables
          .where((table) => table.status == TableStatusEnum.maintenance)
          .length;

      return TableStats(
        totalTables: totalTables,
        occupiedTables: occupiedTables,
        reservedTables: reservedTables,
        cleaningTables: cleaningTables,
      );
    } catch (e) {
      debugPrint('Error calculating table stats: $e');
      return TableStats(
        totalTables: 0,
        occupiedTables: 0,
        reservedTables: 0,
        cleaningTables: 0,
      );
    }
  }

  // ===== HELPER METHODS =====

  /// Map a Firestore query snapshot to a list of RestaurantTable objects
  List<RestaurantTable> _mapTablesToList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return RestaurantTable.fromFirestore(doc);
      } catch (e) {
        debugPrint('Error parsing table document: $e');
        // Return a default table as fallback
        return RestaurantTable(
          id: doc.id,
          number: 0,
          name: 'Error Table',
          capacity: 0,
          status: TableStatusEnum.available,
          isActive: false,
          businessId: ((doc.data() as Map<String, dynamic>)?['businessId'] ??
              '') as String,
        );
      }
    }).toList();
  }
}

// ===== RIVERPOD PROVIDERS =====

/// Provider for the unified table service
final tableServiceProvider = Provider<TableService>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  return TableService(businessId: businessId, restaurantId: businessId);
});

/// Provider for tables stream
final tablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTablesStream();
});

/// Provider for active tables only
final activeTablesProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getActiveTablesStream();
});

/// Provider for tables filtered by status
final tablesByStatusProvider =
    StreamProvider.family<List<RestaurantTable>, TableStatusEnum>(
        (ref, status) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTablesByStatusStream(status);
});

/// Provider for available tables
final availableTablesProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getAvailableTablesStream();
});

/// Provider for table by ID
final tableByIdProvider =
    FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTable(tableId);
});

/// Provider for table statistics
final tableStatsProvider = FutureProvider<TableStats>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTableStats();
});

final restaurantIdProvider = Provider<String>((ref) {
  return ref.watch(currentBusinessIdProvider);
});

// Provider for restaurant ID (could use the same as business ID or be different)

// Provider for table status
final tablesStatusProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTablesStream();
});

// Provider for a single table
final tableProvider =
    FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTable(tableId);
});

/// Optimized table service that centralizes all table-related operations.
/// Uses caching, transactions, and optimized queries for better performance.
// class TableService {
//   final FirebaseFirestore _firestore;
//   final CollectionReference _tablesCollection;

//   // Private constructor for dependency injection
//   TableService({FirebaseFirestore? firestore})
//       : _firestore = firestore ?? FirebaseFirestore.instance,
//         _tablesCollection =
//             (firestore ?? FirebaseFirestore.instance).collection('tables');

//   // Get all tables with caching
//   Stream<List<RestaurantTable>> getTablesStream() {
//     return _tablesCollection.orderBy('tableNumber').snapshots().map((snapshot) {
//       try {
//         return snapshot.docs
//             .map((doc) => RestaurantTable.fromFirestore(doc))
//             .toList();
//       } catch (e) {
//         debugPrint('Error processing tables: $e');
//         return <RestaurantTable>[];
//       }
//     });
//   }

//   // Get all tables (future-based with caching)
//   Future<List<RestaurantTable>> getAllTables() async {
//     try {
//       final snapshot = await _tablesCollection
//           .orderBy('tableNumber')
//           .get(const GetOptions(source: Source.serverAndCache));

//       return snapshot.docs
//           .map((doc) => RestaurantTable.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       debugPrint('Error fetching tables: $e');
//       return [];
//     }
//   }

//   // Get active tables (with orders)
//   Stream<List<RestaurantTable>> getActiveTablesStream() {
//     return _tablesCollection
//         .where('status',
//             isEqualTo: TableStatusEnum.occupied.toString().split('.').last)
//         .orderBy('tableNumber')
//         .snapshots()
//         .map((snapshot) {
//       try {
//         return snapshot.docs
//             .map((doc) => RestaurantTable.fromFirestore(doc))
//             .toList();
//       } catch (e) {
//         debugPrint('Error processing active tables: $e');
//         return <RestaurantTable>[];
//       }
//     });
//   }

//   // Get tables by status
//   Future<List<RestaurantTable>> getTablesByStatus(
//       TableStatusEnum status) async {
//     try {
//       final statusStr = status.toString().split('.').last;
//       final snapshot = await _tablesCollection
//           .where('status', isEqualTo: statusStr)
//           .orderBy('tableNumber')
//           .get(const GetOptions(source: Source.serverAndCache));

//       return snapshot.docs
//           .map((doc) => RestaurantTable.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       debugPrint('Error fetching tables by status: $e');
//       return [];
//     }
//   }

//   // Get a specific table by ID with caching
//   Future<RestaurantTable?> getTableById(String tableId) async {
//     try {
//       final doc = await _tablesCollection
//           .doc(tableId)
//           .get(const GetOptions(source: Source.serverAndCache));

//       if (doc.exists) {
//         return RestaurantTable.fromFirestore(doc);
//       }
//       return null;
//     } catch (e) {
//       debugPrint('Error fetching table: $e');
//       return null;
//     }
//   }

//   // Create a new table
//   Future<String> createTable(RestaurantTable table) async {
//     try {
//       // Check for duplicate table number
//       final existingTables = await _tablesCollection
//           .where('tableNumber', isEqualTo: table.number)
//           .limit(1)
//           .get();

//       if (existingTables.docs.isNotEmpty) {
//         throw Exception('Ya existe una mesa con el número ${table.number}');
//       }

//       // Create with transaction
//       final tableId = _tablesCollection.doc().id;

//       await _firestore.runTransaction((transaction) async {
//         transaction.set(
//           _tablesCollection.doc(tableId),
//           table
//               .copyWith(
//                 id: tableId,
//                 createdAt: DateTime.now(),
//                 updatedAt: DateTime.now(),
//               )
//               .toFirestore(),
//         );
//       });

//       return tableId;
//     } catch (e) {
//       debugPrint('Error creating table: $e');
//       rethrow;
//     }
//   }

//   // Update a table
//   Future<void> updateTable(RestaurantTable table) async {
//     try {
//       // Check if changing table number to one that already exists
//       if (table.number != null) {
//         final existingTables = await _tablesCollection
//             .where('tableNumber', isEqualTo: table.number)
//             .where(FieldPath.documentId, isNotEqualTo: table.id)
//             .limit(1)
//             .get();

//         if (existingTables.docs.isNotEmpty) {
//           throw Exception('Ya existe otra mesa con el número ${table.number}');
//         }
//       }

//       // Update with transaction
//       await _firestore.runTransaction((transaction) async {
//         final tableDoc = await transaction.get(_tablesCollection.doc(table.id));

//         if (!tableDoc.exists) {
//           throw Exception('La mesa no existe');
//         }

//         transaction.update(
//           _tablesCollection.doc(table.id),
//           {
//             ...table.toFirestore(),
//             'updatedAt': FieldValue.serverTimestamp(),
//           },
//         );
//       });
//     } catch (e) {
//       debugPrint('Error updating table: $e');
//       rethrow;
//     }
//   }

//   // Update table status
//   Future<void> updateTableStatus(String tableId, TableStatusEnum newStatus,
//       {String? orderId}) async {
//     try {
//       await _firestore.runTransaction((transaction) async {
//         final tableDoc = await transaction.get(_tablesCollection.doc(tableId));

//         if (!tableDoc.exists) {
//           throw Exception('La mesa no existe');
//         }

//         final Map<String, dynamic> updateData = {
//           'status': newStatus.toString().split('.').last,
//           'updatedAt': FieldValue.serverTimestamp(),
//         };

//         // Update current order ID if provided
//         if (orderId != null) {
//           updateData['currentOrderId'] = orderId;
//         } else if (newStatus != TableStatusEnum.occupied) {
//           // Clear current order ID if table is no longer occupied
//           updateData['currentOrderId'] = null;
//         }

//         transaction.update(_tablesCollection.doc(tableId), updateData);
//       });
//     } catch (e) {
//       debugPrint('Error updating table status: $e');
//       rethrow;
//     }
//   }

//   // Delete a table
//   Future<void> deleteTable(String tableId) async {
//     try {
//       await _firestore.runTransaction((transaction) async {
//         final tableDoc = await transaction.get(_tablesCollection.doc(tableId));

//         if (!tableDoc.exists) {
//           throw Exception('La mesa no existe');
//         }

//         final table = RestaurantTable.fromFirestore(tableDoc);

//         // Don't allow deletion of occupied tables
//         if (table.status == TableStatusEnum.occupied) {
//           throw Exception('No se puede eliminar una mesa ocupada');
//         }

//         transaction.delete(_tablesCollection.doc(tableId));
//       });
//     } catch (e) {
//       debugPrint('Error deleting table: $e');
//       rethrow;
//     }
//   }
// }

// // Optimized providers with proper dependency management
// final tableServiceProvider = Provider<TableService>((ref) {
//   final firestore = ref.watch(firebaseFirestoreProvider);
//   return TableService(firestore: firestore);
// });

// // Table-related stream providers
// final tablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
//   final tableService = ref.watch(tableServiceProvider);
//   return tableService.getTablesStream();
// });

// // Available tables provider (optimized with caching)
// final availableTablesProvider =
//     FutureProvider<List<RestaurantTable>>((ref) async {
//   final tableService = ref.watch(tableServiceProvider);
//   final availableTables =
//       await tableService.getTablesByStatus(TableStatusEnum.available);
//   final reservedTables =
//       await tableService.getTablesByStatus(TableStatusEnum.reserved);

//   return [...availableTables, ...reservedTables];
// });

// // Active tables provider
// final activeTablesProvider = StreamProvider<List<RestaurantTable>>((ref) {
//   final tableService = ref.watch(tableServiceProvider);
//   return tableService.getActiveTablesStream();
// });

// // Table by ID provider
// final tableByIdProvider =
//     FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
//   final tableService = ref.watch(tableServiceProvider);
//   return tableService.getTableById(tableId);
// });
