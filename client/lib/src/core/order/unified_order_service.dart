import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';

/// Unified service for handling all order-related operations.
/// This consolidates functionality from multiple services to ensure consistency.
class OrderService {
  final cloud_firestore.FirebaseFirestore _firestore;
  final String _businessId;
  final cloud_firestore.CollectionReference _ordersCollection;

  /// Constructor with optional FirebaseFirestore instance for testing
  OrderService({
    cloud_firestore.FirebaseFirestore? firestore,
    required String businessId,
  })  : _firestore = firestore ?? cloud_firestore.FirebaseFirestore.instance,
        _businessId = businessId,
        _ordersCollection =
            (firestore ?? cloud_firestore.FirebaseFirestore.instance)
                .collection('businesses')
                .doc(businessId)
                .collection('orders');

  // ===== QUERY OPERATIONS =====

  /// Stream all active orders (real-time updates)
  Stream<List<Order>> getActiveOrdersStream() {
    return _ordersCollection
        .where('status', whereNotIn: ['completed', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _mapOrdersFromSnapshot(snapshot));
  }

  /// Stream all orders without filtering
  Stream<List<Order>> getAllOrdersStream() {
    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _mapOrdersFromSnapshot(snapshot));
  }

  /// Stream completed orders for a specific user
  Stream<List<Order>> getCompletedOrdersStream(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: [
          OrderStatus.delivered.toString().split('.').last,
          OrderStatus.cancelled.toString().split('.').last,
        ])
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => _mapOrdersFromSnapshot(snapshot));
  }

  /// Stream orders by status (using OrderStatus enum)
  Stream<List<Order>> getOrdersByStatusStream(OrderStatus status) {
    final statusStr = status.toString().split('.').last;
    return getOrdersByStatusStringStream(statusStr);
  }

  /// Stream orders by status (using string status)
  Stream<List<Order>> getOrdersByStatusStringStream(String status) {
    return _ordersCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _mapOrdersFromSnapshot(snapshot));
  }

  /// Stream recent orders with a limit
  Stream<List<Order>> getRecentOrdersStream({int limit = 10}) {
    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => _mapOrdersFromSnapshot(snapshot));
  }

  /// Stream orders for a specific table
  Stream<List<Order>> getOrdersByTableStream(String tableId) {
    return _ordersCollection
        .where('tableId', isEqualTo: tableId)
        .where('status', whereNotIn: ['completed', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _mapOrdersFromSnapshot(snapshot));
  }

  /// Stream orders by user ID
  Stream<List<Order>> getUserOrdersStream(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _mapOrdersFromSnapshot(snapshot));
  }

  /// Stream orders by resource ID
  Stream<List<Order>> getOrdersByResourceStream(String resourceId) {
    return _ordersCollection
        .where('resourceId', isEqualTo: resourceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _mapOrdersFromSnapshot(snapshot));
  }

  /// Stream orders by date
  Stream<List<Order>> getOrdersByDateStream(DateTime? date) {
    if (date == null) {
      return getAllOrdersStream();
    }

    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    return _ordersCollection
        .where('createdAt',
            isGreaterThanOrEqualTo:
                cloud_firestore.Timestamp.fromDate(startDate))
        .where('createdAt',
            isLessThan: cloud_firestore.Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => _mapOrdersFromSnapshot(snapshot));
  }

  // ===== FUTURE OPERATIONS =====

  /// Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching order: $e');
      return null;
    }
  }

  /// Get active orders (non-stream version)
  Future<List<Order>> getActiveOrders() async {
    try {
      final snapshot = await _ordersCollection
          .where('status', whereNotIn: ['completed', 'cancelled'])
          .orderBy('createdAt', descending: true)
          .get();

      return _mapOrdersFromSnapshot(snapshot);
    } catch (e) {
      debugPrint('Error fetching active orders: $e');
      return [];
    }
  }

  /// Get orders by date range
  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _ordersCollection
          .where('createdAt',
              isGreaterThanOrEqualTo: cloud_firestore.Timestamp.fromDate(start))
          .where('createdAt',
              isLessThanOrEqualTo: cloud_firestore.Timestamp.fromDate(end))
          .orderBy('createdAt', descending: true)
          .get();

      return _mapOrdersFromSnapshot(snapshot);
    } catch (e) {
      debugPrint('Error fetching orders by date range: $e');
      return [];
    }
  }

  /// Get orders by status (non-stream version)
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final statusStr = status.toString().split('.').last;
    return getOrdersByStatusString(statusStr);
  }

  /// Get orders by status string (non-stream version)
  Future<List<Order>> getOrdersByStatusString(String status) async {
    try {
      final snapshot = await _ordersCollection
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return _mapOrdersFromSnapshot(snapshot);
    } catch (e) {
      debugPrint('Error fetching orders by status: $e');
      return [];
    }
  }

  /// Get all orders (non-stream version)
  Future<List<Order>> getAllOrders() async {
    try {
      final snapshot =
          await _ordersCollection.orderBy('createdAt', descending: true).get();

      return _mapOrdersFromSnapshot(snapshot);
    } catch (e) {
      debugPrint('Error fetching all orders: $e');
      return [];
    }
  }

  // ===== WRITE OPERATIONS =====

  /// Create a new order with table handling
  Future<String> createOrder(Order order) async {
    try {
      // Use transaction to ensure data consistency
      return await _firestore.runTransaction<String>((transaction) async {
        // Generate new ID if using temp ID
        final orderId = order.id.startsWith('temp_')
            ? _ordersCollection.doc().id
            : order.id;

        // If table is specified, check and update table status
        if (order.tableId?.isNotEmpty ?? false) {
          final tableDoc = await transaction
              .get(_firestore.collection('tables').doc(order.tableId));

          if (!tableDoc.exists) {
            throw Exception('La mesa especificada no existe');
          }

          final table = RestaurantTable.fromFirestore(tableDoc);

          // Check if table is available
          if (table.status == TableStatusEnum.occupied &&
              table.currentOrderId != null &&
              table.currentOrderId != order.id) {
            throw Exception('La mesa ya está ocupada con otro pedido');
          }

          // Update table status to occupied and set current order ID
          transaction.update(
            _firestore.collection('tables').doc(order.tableId),
            {
              'status': TableStatusEnum.occupied.toString().split('.').last,
              'currentOrderId': orderId,
              'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
            },
          );
        }

        // Create the order with new ID if needed
        final newOrder =
            order.id.startsWith('temp_') ? order.copyWith(id: orderId) : order;

        transaction.set(
          _ordersCollection.doc(orderId),
          newOrder.toFirestore(),
        );

        return orderId;
      });
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  /// Update an existing order
  Future<void> updateOrder(Order order) async {
    try {
      await _ordersCollection.doc(order.id).update(order.toFirestore());
    } catch (e) {
      debugPrint('Error updating order: $e');
      rethrow;
    }
  }

  /// Update order status with table handling
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      // Use transaction to ensure data consistency
      await _firestore.runTransaction((transaction) async {
        final orderDoc = await transaction.get(_ordersCollection.doc(orderId));

        if (!orderDoc.exists) {
          throw Exception('El pedido no existe');
        }

        final order = Order.fromFirestore(orderDoc);

        // Update order status
        transaction.update(
          _ordersCollection.doc(orderId),
          {
            'status': newStatus.toString().split('.').last,
            'lastUpdated': cloud_firestore.FieldValue.serverTimestamp(),
          },
        );

        // If order is completed or cancelled, update table status
        if ((newStatus == OrderStatus.completed ||
                newStatus == OrderStatus.cancelled) &&
            (order.tableId?.isNotEmpty ?? false)) {
          final tableDoc = await transaction
              .get(_firestore.collection('tables').doc(order.tableId));

          if (tableDoc.exists) {
            final table = RestaurantTable.fromFirestore(tableDoc);

            // Only update if this is the current order for the table
            if (table.currentOrderId == orderId) {
              transaction.update(
                _firestore.collection('tables').doc(order.tableId),
                {
                  'status': newStatus == OrderStatus.completed
                      ? TableStatusEnum.maintenance.toString().split('.').last
                      : TableStatusEnum.available.toString().split('.').last,
                  'currentOrderId': null,
                  'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
                },
              );
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  /// Complete order with payment processing
  Future<void> completeOrderWithPayment(
    String orderId, {
    required String paymentMethod,
    required double tipAmount,
    required String? cashierId,
    required String? cashierName,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final orderDoc = await transaction.get(_ordersCollection.doc(orderId));

        if (!orderDoc.exists) {
          throw Exception('El pedido no existe');
        }

        final order = Order.fromFirestore(orderDoc);

        // Update order with payment details
        transaction.update(
          _ordersCollection.doc(orderId),
          {
            'status': OrderStatus.completed.toString().split('.').last,
            'isPaid': true,
            'paidAt': cloud_firestore.FieldValue.serverTimestamp(),
            'paymentMethod': paymentMethod,
            'tipAmount': tipAmount,
            'totalAmount':
                (order.subtotal ?? 0) + (order.taxAmount ?? 0) + tipAmount,
            'cashierId': cashierId,
            'cashierName': cashierName,
            'lastUpdated': cloud_firestore.FieldValue.serverTimestamp(),
          },
        );

        // Update table status if applicable
        if (order.tableId?.isNotEmpty ?? false) {
          final tableDoc = await transaction
              .get(_firestore.collection('tables').doc(order.tableId));

          if (tableDoc.exists) {
            final table = RestaurantTable.fromFirestore(tableDoc);

            // Only update if this is the current order for the table
            if (table.currentOrderId == orderId) {
              transaction.update(
                _firestore.collection('tables').doc(order.tableId),
                {
                  'status':
                      TableStatusEnum.maintenance.toString().split('.').last,
                  'currentOrderId': null,
                  'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
                },
              );
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error completing order with payment: $e');
      rethrow;
    }
  }

  // ===== STATISTICS =====

  /// Get order statistics
  Future<OrderStats> getOrderStats() async {
    try {
      // Get counts for each order status
      final pendingSnapshot = await _ordersCollection
          .where('status',
              isEqualTo: OrderStatus.pending.toString().split('.').last)
          .count()
          .get();

      final preparingSnapshot = await _ordersCollection
          .where('status',
              isEqualTo: OrderStatus.preparing.toString().split('.').last)
          .count()
          .get();

      final readySnapshot = await _ordersCollection
          .where('status',
              isEqualTo:
                  OrderStatus.readyForDelivery.toString().split('.').last)
          .count()
          .get();

      // Get today's sales
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayOrders = await getOrdersByDateRange(startOfDay, endOfDay);
      final completedOrders = todayOrders
          .where((order) => order.status == OrderStatus.completed)
          .toList();

      // Calculate total orders for all time
      final allOrdersSnapshot = await _ordersCollection.count().get();
      final totalOrders = allOrdersSnapshot.count ?? 0;

      // Calculate completed orders for all time
      final completedOrdersSnapshot = await _ordersCollection
          .where('status',
              isEqualTo: OrderStatus.completed.toString().split('.').last)
          .count()
          .get();
      final totalCompletedOrders = completedOrdersSnapshot.count ?? 0;

      final dailySales = completedOrders.fold<double>(
          0, (sum, order) => sum + order.totalAmount);

      // Calculate average service time (in minutes)
      int totalMinutes = 0;
      int orderCount = 0;

      for (var order in completedOrders) {
        if (order.lastUpdated != null) {
          final duration = order.lastUpdated!.difference(order.createdAt);
          totalMinutes += duration.inMinutes;
          orderCount++;
        }
      }

      final averageServiceTime =
          orderCount > 0 ? (totalMinutes / orderCount).round() : 0;

      return OrderStats(
        pendingOrders: pendingSnapshot.count ?? 0,
        preparingOrders: preparingSnapshot.count ?? 0,
        readyOrders: readySnapshot.count ?? 0,
        dailySales: dailySales,
        averageServiceTime: averageServiceTime,
        totalOrders: totalOrders,
        completedOrders: totalCompletedOrders,
      );
    } catch (e) {
      debugPrint('Error calculating order stats: $e');
      return OrderStats(
        pendingOrders: 0,
        preparingOrders: 0,
        readyOrders: 0,
        dailySales: 0,
        averageServiceTime: 0,
        totalOrders: 0,
        completedOrders: 0,
      );
    }
  }

  // ===== HELPER METHODS =====

  /// Map a Firestore snapshot to a list of Order objects with error handling
  List<Order> _mapOrdersFromSnapshot(cloud_firestore.QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return Order.fromFirestore(doc);
      } catch (e) {
        debugPrint('Error parsing order document: $e');
        // Return empty order as fallback
        return Order.empty();
      }
    }).toList();
  }
}

/// Statistics about orders for analytics purposes
class OrderStats {
  final int pendingOrders;
  final int preparingOrders;
  final int readyOrders;
  final double dailySales;
  final int averageServiceTime;
  final int totalOrders;
  final int completedOrders;

  OrderStats({
    required this.pendingOrders,
    required this.preparingOrders,
    required this.readyOrders,
    required this.dailySales,
    required this.averageServiceTime,
    required this.totalOrders,
    required this.completedOrders,
  });
}

// ===== RIVERPOD PROVIDERS =====

/// Provider for the unified order service
final orderServiceProvider = Provider<OrderService>((ref) {
  final businessId = ref.watch(currentBusinessIdProvider);
  return OrderService(businessId: businessId);
});

/// Provider for active orders
final activeOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getActiveOrdersStream();
});

/// Provider for all orders
final allOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getAllOrdersStream();
});

/// Provider for orders by status
final ordersByStatusStreamProvider =
    StreamProvider.family<List<Order>, OrderStatus>((ref, status) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStream(status);
});

/// Provider for orders by status string
final ordersByStatusStringStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, status) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStringStream(status);
});

/// Provider for orders by table
final ordersByTableStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, tableId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByTableStream(tableId);
});

/// Provider for recent orders
final recentOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getRecentOrdersStream();
});

/// Provider for user orders
final userOrdersStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, userId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getUserOrdersStream(userId);
});

/// Provider for order by ID
final orderByIdProvider = FutureProvider.family<Order?, String>((ref, orderId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrderById(orderId);
});

/// Provider for order statistics
final orderStatsProvider = FutureProvider<OrderStats>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrderStats();
});

/// Provider for pending orders
final pendingOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStream(OrderStatus.pending);
});

/// Provider for preparing orders
final preparingOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStream(OrderStatus.preparing);
});

/// Provider for ready orders
final readyOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStream(OrderStatus.readyForDelivery);
});

/// Provider for completed orders by user
final completedOrdersProvider =
    StreamProvider.family<List<Order>, String>((ref, userId) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getCompletedOrdersStream(userId);
});

/// Provider for active order (currently being viewed/edited)
final activeOrderIdProvider = StateProvider<String?>((ref) => null);

/// Provider for active order data
final activeOrderProvider = FutureProvider<Order?>((ref) {
  final orderId = ref.watch(activeOrderIdProvider);
  if (orderId == null) {
    return null;
  }

  return ref.watch(orderByIdProvider(orderId)).value;
});

final activeOrdersProvider =
    StreamProvider.family<List<Order>, String>((ref, userId) {
  final orderService = ref.watch(orderServiceProvider);
  // Use the service to get orders by status for the specific user
  return orderService.getActiveOrdersStream();
});

// Add a provider for all active orders (no user filter)
final allActiveOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  // Use the service's existing method to get all active orders
  return orderService.getActiveOrdersStream();
});

/// Provider for orders by date
final ordersByDateProvider =
    StreamProvider.family<List<Order>, DateTime?>((ref, date) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByDateStream(date);
});

// Provider for orders by status
final ordersByStatusStringProvider =
    StreamProvider.family<List<Order>, String>((ref, status) {
  final orderService = ref.watch(orderServiceProvider);
  return orderService.getOrdersByStatusStringStream(status);
});

// // Provider for filtered orders by date
// final ordersByDateProvider =
//     StreamProvider.family<List<Order>, DateTime?>((ref, date) {
//   final orderService = ref.watch(orderServiceProvider);

//   if (date == null) {
//     return orderService.getAllOrdersStream();
//   }

//   return orderService.getOrdersByDateStream(date);
// });
