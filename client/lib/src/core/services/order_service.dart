import 'package:cloud_firestore/cloud_firestore.dart' as CloudFireStore;
import 'package:flutter/foundation.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/core/services/restaurant/restaurant_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';

class OrderService {
  final CloudFireStore.FirebaseFirestore _firestore;
  final CloudFireStore.CollectionReference _ordersCollection;
  final String _businessId;

  OrderService(
    CloudFireStore.FirebaseFirestore? firestore,
    String businessId,
  )   : _firestore = firestore ?? CloudFireStore.FirebaseFirestore.instance,
        _businessId = businessId,
        _ordersCollection =
            (firestore ?? CloudFireStore.FirebaseFirestore.instance)
                .collection('businesses')
                .doc(businessId)
                .collection('orders');

  // Stream active orders (real-time updates)
  Stream<List<Order>> getActiveOrdersStream() {
    return _ordersCollection
        .where('status', whereNotIn: ['completed', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              try {
                return Order.fromFirestore(doc);
              } catch (e) {
                debugPrint('Error parsing order document: $e');
                // Return a placeholder or null based on your error handling strategy
                return Order
                    .empty(); // Assuming there's an empty constructor or factory method
              }
            }).toList());
  }

  // Stream active orders (real-time updates)
  Stream<List<Order>> getCompletedOrdersStream(ref, userId) {
    // Use the service to get completed orders for the specific user
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: [
          OrderStatus.delivered.toString().split('.').last,
          OrderStatus.cancelled.toString().split('.').last,
        ])
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

  // Stream orders by status
  Stream<List<Order>> getOrdersByStatusStream(OrderStatus status) {
    final statusStr = status.toString().split('.').last;
    return _ordersCollection
        .where('status', isEqualTo: statusStr)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

  // Stream orders by status
  Stream<List<Order>> getOrdersByStatusStringStream(String status) {
    return _ordersCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

  // Get recent orders stream with limit
  Stream<List<Order>> getRecentOrdersStream() {
    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .limit(10) // Limit to 10 most recent orders
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

  // Stream orders for a specific table
  Stream<List<Order>> getOrdersByTableStream(String tableId) {
    return _ordersCollection
        .where('tableId', isEqualTo: tableId)
        .where('status', whereNotIn: ['completed', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

  // Get order by ID
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

  // Get active orders
  Future<List<Order>> getActiveOrders() async {
    try {
      final snapshot = await _ordersCollection
          .where('status', whereNotIn: ['completed', 'cancelled'])
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching active orders: $e');
      return [];
    }
  }

  // Get orders by date range
  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _ordersCollection
          .where('createdAt',
              isGreaterThanOrEqualTo: CloudFireStore.Timestamp.fromDate(start))
          .where('createdAt',
              isLessThanOrEqualTo: CloudFireStore.Timestamp.fromDate(end))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching orders by date range: $e');
      return [];
    }
  }

  // Create a new order
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
              'updatedAt': CloudFireStore.FieldValue.serverTimestamp(),
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

  // Update an existing order
  Future<void> updateOrder(Order order) async {
    try {
      await _ordersCollection.doc(order.id).update(order.toFirestore());
    } catch (e) {
      debugPrint('Error updating order: $e');
      rethrow;
    }
  }

  // Update order status
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
            'lastUpdated': CloudFireStore.FieldValue.serverTimestamp(),
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
                  'updatedAt': CloudFireStore.FieldValue.serverTimestamp(),
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

  // Complete order and payment process
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
            'paidAt': CloudFireStore.FieldValue.serverTimestamp(),
            'paymentMethod': paymentMethod,
            'tipAmount': tipAmount,
            'totalAmount':
                (order.subtotal ?? 0) + (order.taxAmount ?? 0) + tipAmount,
            'cashierId': cashierId,
            'cashierName': cashierName,
            'lastUpdated': CloudFireStore.FieldValue.serverTimestamp(),
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
                  'updatedAt': CloudFireStore.FieldValue.serverTimestamp(),
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

  // Get order statistics
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
        totalOrders: 0,
        completedOrders: 0,
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

// Get all orders (stream)
  Stream<List<Order>> getAllOrdersStream() {
    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

// Get orders by date (stream)
  Stream<List<Order>> getOrdersByDateStream(DateTime? date) {
    if (date == null) {
      return getAllOrdersStream();
    }

    // Create date range: start of day to end of day
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    return _ordersCollection
        .where('createdAt',
            isGreaterThanOrEqualTo:
                CloudFireStore.Timestamp.fromDate(startDate))
        .where('createdAt',
            isLessThan: CloudFireStore.Timestamp.fromDate(endDate))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

// Get orders by status (non-stream version)
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final snapshot = await _ordersCollection
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching orders by status: $e');
      return [];
    }
  }

// Get all orders (non-stream version)
  Future<List<Order>> getAllOrders() async {
    try {
      final snapshot =
          await _ordersCollection.orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching all orders: $e');
      return [];
    }
  }

  // Get orders for a specific resource
  Stream<List<Order>> getOrdersByResourceStream(String resourceId) {
    return _ordersCollection
        .where('resourceId', isEqualTo: resourceId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }

  // Get user orders
  Stream<List<Order>> getUserOrdersStream(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList());
  }
}

// Extension methods for Order class to handle Firestore conversion
extension OrderFirestoreExtension on Order {
  // Convert Order to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'businessId': businessId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'items': items.map((item) => item is Map ? item : item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status.name,
      'createdAt': CloudFireStore.Timestamp.fromDate(createdAt),
      'resourceId': resourceId,
      'specialInstructions': specialInstructions,
      'isDelivery': isDelivery,
      'deliveryAddress': deliveryAddress,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'peopleCount': peopleCount,
      'paymentMethod': paymentMethod,
      'lastUpdated': lastUpdated != null
          ? CloudFireStore.Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }

  // Create Order from Firestore document
  static Order fromFirestore(CloudFireStore.DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Order(
      id: data['id'] ?? doc.id,
      businessId: data['businessId'],
      userId: data['userId'] ?? '',
      userName: data['userName'],
      userEmail: data['userEmail'],
      userPhone: data['userPhone'],
      items: (data['items'])?.map((item) => item.fromMap(item)).toList() ?? [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: _parseOrderStatus(data['status']),
      createdAt: (data['createdAt'] as CloudFireStore.Timestamp?)?.toDate() ??
          DateTime.now(),
      resourceId: data['resourceId'],
      specialInstructions: data['specialInstructions'],
      isDelivery: data['isDelivery'] ?? false,
      deliveryAddress: data['deliveryAddress'],
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      peopleCount: data['peopleCount'],
      paymentMethod: data['paymentMethod'] ?? 'cash',
      lastUpdated: (data['lastUpdated'] as CloudFireStore.Timestamp?)?.toDate(),
    );
  }

  // Helper method to parse order status
  static OrderStatus _parseOrderStatus(String? status) {
    if (status == null) return OrderStatus.pending;

    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
