import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

/// Optimized table service that centralizes all table-related operations.
/// Uses caching, transactions, and optimized queries for better performance.
class TableService {
  final FirebaseFirestore _firestore;
  final CollectionReference _tablesCollection;

  // Private constructor for dependency injection
  TableService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _tablesCollection =
            (firestore ?? FirebaseFirestore.instance).collection('tables');

  // Get all tables with caching
  Stream<List<RestaurantTable>> getTablesStream() {
    return _tablesCollection.orderBy('tableNumber').snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => RestaurantTable.fromFirestore(doc))
            .toList();
      } catch (e) {
        debugPrint('Error processing tables: $e');
        return <RestaurantTable>[];
      }
    });
  }

  // Get all tables (future-based with caching)
  Future<List<RestaurantTable>> getAllTables() async {
    try {
      final snapshot = await _tablesCollection
          .orderBy('tableNumber')
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs
          .map((doc) => RestaurantTable.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching tables: $e');
      return [];
    }
  }

  // Get active tables (with orders)
  Stream<List<RestaurantTable>> getActiveTablesStream() {
    return _tablesCollection
        .where('status',
            isEqualTo: TableStatusEnum.occupied.toString().split('.').last)
        .orderBy('tableNumber')
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => RestaurantTable.fromFirestore(doc))
            .toList();
      } catch (e) {
        debugPrint('Error processing active tables: $e');
        return <RestaurantTable>[];
      }
    });
  }

  // Get tables by status
  Future<List<RestaurantTable>> getTablesByStatus(
      TableStatusEnum status) async {
    try {
      final statusStr = status.toString().split('.').last;
      final snapshot = await _tablesCollection
          .where('status', isEqualTo: statusStr)
          .orderBy('tableNumber')
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs
          .map((doc) => RestaurantTable.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching tables by status: $e');
      return [];
    }
  }

  // Get a specific table by ID with caching
  Future<RestaurantTable?> getTableById(String tableId) async {
    try {
      final doc = await _tablesCollection
          .doc(tableId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (doc.exists) {
        return RestaurantTable.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching table: $e');
      return null;
    }
  }

  // Create a new table
  Future<String> createTable(RestaurantTable table) async {
    try {
      // Check for duplicate table number
      final existingTables = await _tablesCollection
          .where('tableNumber', isEqualTo: table.number)
          .limit(1)
          .get();

      if (existingTables.docs.isNotEmpty) {
        throw Exception('Ya existe una mesa con el número ${table.number}');
      }

      // Create with transaction
      final tableId = _tablesCollection.doc().id;

      await _firestore.runTransaction((transaction) async {
        transaction.set(
          _tablesCollection.doc(tableId),
          table
              .copyWith(
                id: tableId,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
              .toFirestore(),
        );
      });

      return tableId;
    } catch (e) {
      debugPrint('Error creating table: $e');
      rethrow;
    }
  }

  // Update a table
  Future<void> updateTable(RestaurantTable table) async {
    try {
      // Check if changing table number to one that already exists
      if (table.number != null) {
        final existingTables = await _tablesCollection
            .where('tableNumber', isEqualTo: table.number)
            .where(FieldPath.documentId, isNotEqualTo: table.id)
            .limit(1)
            .get();

        if (existingTables.docs.isNotEmpty) {
          throw Exception('Ya existe otra mesa con el número ${table.number}');
        }
      }

      // Update with transaction
      await _firestore.runTransaction((transaction) async {
        final tableDoc = await transaction.get(_tablesCollection.doc(table.id));

        if (!tableDoc.exists) {
          throw Exception('La mesa no existe');
        }

        transaction.update(
          _tablesCollection.doc(table.id),
          {
            ...table.toFirestore(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      });
    } catch (e) {
      debugPrint('Error updating table: $e');
      rethrow;
    }
  }

  // Update table status
  Future<void> updateTableStatus(String tableId, TableStatusEnum newStatus,
      {String? orderId}) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final tableDoc = await transaction.get(_tablesCollection.doc(tableId));

        if (!tableDoc.exists) {
          throw Exception('La mesa no existe');
        }

        final Map<String, dynamic> updateData = {
          'status': newStatus.toString().split('.').last,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Update current order ID if provided
        if (orderId != null) {
          updateData['currentOrderId'] = orderId;
        } else if (newStatus != TableStatusEnum.occupied) {
          // Clear current order ID if table is no longer occupied
          updateData['currentOrderId'] = null;
        }

        transaction.update(_tablesCollection.doc(tableId), updateData);
      });
    } catch (e) {
      debugPrint('Error updating table status: $e');
      rethrow;
    }
  }

  // Delete a table
  Future<void> deleteTable(String tableId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final tableDoc = await transaction.get(_tablesCollection.doc(tableId));

        if (!tableDoc.exists) {
          throw Exception('La mesa no existe');
        }

        final table = RestaurantTable.fromFirestore(tableDoc);

        // Don't allow deletion of occupied tables
        if (table.status == TableStatusEnum.occupied) {
          throw Exception('No se puede eliminar una mesa ocupada');
        }

        transaction.delete(_tablesCollection.doc(tableId));
      });
    } catch (e) {
      debugPrint('Error deleting table: $e');
      rethrow;
    }
  }
}

// Optimized providers with proper dependency management
final tableServiceProvider = Provider<TableService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return TableService(firestore: firestore);
});

// Table-related stream providers
final tablesStreamProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTablesStream();
});

// Available tables provider (optimized with caching)
final availableTablesProvider =
    FutureProvider<List<RestaurantTable>>((ref) async {
  final tableService = ref.watch(tableServiceProvider);
  final availableTables =
      await tableService.getTablesByStatus(TableStatusEnum.available);
  final reservedTables =
      await tableService.getTablesByStatus(TableStatusEnum.reserved);

  return [...availableTables, ...reservedTables];
});

// Active tables provider
final activeTablesProvider = StreamProvider<List<RestaurantTable>>((ref) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getActiveTablesStream();
});

// Table by ID provider
final tableByIdProvider =
    FutureProvider.family<RestaurantTable?, String>((ref, tableId) {
  final tableService = ref.watch(tableServiceProvider);
  return tableService.getTableById(tableId);
});
