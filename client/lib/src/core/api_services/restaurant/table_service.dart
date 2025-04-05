import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

import 'package:starter_architecture_flutter_firebase/src/core/api_services/business/business_config_provider.dart';

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
