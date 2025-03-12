
import 'package:cloud_firestore/cloud_firestore.dart' as CloudFireStore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/core/restaurant/services/restaurant_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';
import 'package:starter_architecture_flutter_firebase/src/core/admin_services/firebase_providers.dart';
 
// Order Service Implementation
class OrderService {
  final CloudFireStore.FirebaseFirestore _firestore;
  final CloudFireStore.CollectionReference _ordersCollection;
  
  OrderService(this._firestore) : _ordersCollection = _firestore.collection('orders');
  
  // Stream active orders (real-time updates)
  Stream<List<Order>> getActiveOrdersStream() {
    return _ordersCollection
        .where('status', whereNotIn: ['completed', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return Order.fromFirestore(doc);
              } catch (e) {
                print('Error parsing order document: $e');
                // Return a placeholder or null based on your error handling strategy
                return Order.empty(); // Assuming there's an empty constructor or factory method
              }
            })
            .toList());
  }
  
  // Stream orders by status
  Stream<List<Order>> getOrdersByStatusStream(OrderStatus status) {
    final statusStr = status.toString().split('.').last;
    return _ordersCollection
        .where('status', isEqualTo: statusStr)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc))
            .toList());
  }

  // Get recent orders stream with limit
Stream<List<Order>> getRecentOrdersStream() {
  return _ordersCollection
      .orderBy('createdAt', descending: true)
      .limit(10) // Limit to 10 most recent orders
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .toList());
}
  
  // Stream orders for a specific table
  Stream<List<Order>> getOrdersByTableStream(String tableId) {
    return _ordersCollection
        .where('tableId', isEqualTo: tableId)
        .where('status', whereNotIn: ['completed', 'cancelled'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc))
            .toList());
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
      print('Error fetching order: $e');
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
      
      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching active orders: $e');
      return [];
    }
  }
  
  // Get orders by date range
  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _ordersCollection
          .where('createdAt', isGreaterThanOrEqualTo: CloudFireStore.Timestamp.fromDate(start))
          .where('createdAt', isLessThanOrEqualTo: CloudFireStore.Timestamp.fromDate(end))
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching orders by date range: $e');
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
          final tableDoc = await transaction.get(_firestore.collection('tables').doc(order.tableId));
          
          if (!tableDoc.exists) {
            throw Exception('La mesa especificada no existe');
          }
          
          final table = RestaurantTable.fromFirestore(tableDoc);
          
          // Check if table is available
          if (table.status == TableStatusEnum.occupied && table.currentOrderId != null && table.currentOrderId != order.id) {
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
        final newOrder = order.id.startsWith('temp_')
            ? order.copyWith(id: orderId)
            : order;
        
        transaction.set(
          _ordersCollection.doc(orderId),
          newOrder.toFirestore(),
        );
        
        return orderId;
      });
    } catch (e) {
      print('Error creating order: $e');
      throw e;
    }
  }
  
  // Update an existing order
  Future<void> updateOrder(Order order) async {
    try {
      await _ordersCollection.doc(order.id).update(order.toFirestore());
    } catch (e) {
      print('Error updating order: $e');
      throw e;
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
        if ((newStatus == OrderStatus.completed || newStatus == OrderStatus.cancelled) && 
            (order.tableId?.isNotEmpty ?? false)) {
          final tableDoc = await transaction.get(_firestore.collection('tables').doc(order.tableId));
          
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
      print('Error updating order status: $e');
      throw e;
    }
  }
  
  // Complete order and payment process
  Future<void> completeOrderWithPayment(String orderId, {
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
            'totalAmount': (order.subtotal ?? 0) + (order.taxAmount ?? 0) + tipAmount,
            'cashierId': cashierId,
            'cashierName': cashierName,
            'lastUpdated': CloudFireStore.FieldValue.serverTimestamp(),
          },
        );
        
        // Update table status if applicable
        if (order.tableId?.isNotEmpty ?? false) {
          final tableDoc = await transaction.get(_firestore.collection('tables').doc(order.tableId));
          
          if (tableDoc.exists) {
            final table = RestaurantTable.fromFirestore(tableDoc);
            
            // Only update if this is the current order for the table
            if (table.currentOrderId == orderId) {
              transaction.update(
                _firestore.collection('tables').doc(order.tableId),
                {
                  'status': TableStatusEnum.maintenance.toString().split('.').last,
                  'currentOrderId': null,
                  'updatedAt': CloudFireStore.FieldValue.serverTimestamp(),
                },
              );
            }
          }
        }
      });
    } catch (e) {
      print('Error completing order with payment: $e');
      throw e;
    }
  }
  
  // Get order statistics
  Future<OrderStats> getOrderStats() async {
    try {
      // Get counts for each order status
      final pendingSnapshot = await _ordersCollection
          .where('status', isEqualTo: OrderStatus.pending.toString().split('.').last)
          .count()
          .get();
      
      final preparingSnapshot = await _ordersCollection
          .where('status', isEqualTo: OrderStatus.preparing.toString().split('.').last)
          .count()
          .get();
      
      final readySnapshot = await _ordersCollection
          .where('status', isEqualTo: OrderStatus.readyForDelivery.toString().split('.').last)
          .count()
          .get();
      
      // Get today's sales
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final todayOrders = await getOrdersByDateRange(startOfDay, endOfDay);
      final completedOrders = todayOrders.where((order) => order.status == OrderStatus.completed).toList();
      
      final dailySales = completedOrders.fold<double>(
        0, (sum, order) => sum + order.totalAmount
      );
      
      // Calculate average service time (in minutes)
      int totalMinutes = 0;
      int orderCount = 0;
      
      for (var order in completedOrders) {
        if (order.createdAt != null && order.lastUpdated != null) {
          final duration = order.lastUpdated!.difference(order.createdAt);
          totalMinutes += duration.inMinutes;
          orderCount++;
        }
      }
      
      final averageServiceTime = orderCount > 0 ? (totalMinutes / orderCount).round() : 0;
      
      return OrderStats(
        pendingOrders: pendingSnapshot.count ?? 0,
        preparingOrders: preparingSnapshot.count ?? 0,
        readyOrders: readySnapshot.count ?? 0,
        dailySales: dailySales,
        averageServiceTime: averageServiceTime, totalOrders: 0, completedOrders: 0,
      );
    } catch (e) {
      print('Error calculating order stats: $e');
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
}


// Update the providers to use OrderService instead of direct Firebase calls
final activeOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final orderService = ref.watch(orderServiceProvider);
  // Use the service to get orders by status for the specific user
  return orderService._ordersCollection
      .where('userId', isEqualTo: userId)
      .where('status', whereIn: [
        OrderStatus.pending.toString().split('.').last,
        OrderStatus.paymentConfirmed.toString().split('.').last,
        OrderStatus.preparing.toString().split('.').last,
        OrderStatus.readyForDelivery.toString().split('.').last,
        OrderStatus.delivering.toString().split('.').last,
      ])
      .orderBy('orderDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .toList());
});

// Add a provider for all active orders (no user filter)
final allActiveOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderService = ref.watch(orderServiceProvider);
  // Use the service's existing method to get all active orders
  return orderService.getActiveOrdersStream();
});

// Create a provider for completed orders pagination using OrderService
final completedOrdersProvider = StreamProvider.family<List<Order>, String>((ref, userId) {
  final orderService = ref.watch(orderServiceProvider);
  // Use the service to get completed orders for the specific user
  return orderService._ordersCollection
      .where('userId', isEqualTo: userId)
      .where('status', whereIn: [
        OrderStatus.delivered.toString().split('.').last,
        OrderStatus.cancelled.toString().split('.').last,
      ])
      .orderBy('orderDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .toList());
});


final orderServiceProvider = Provider<OrderService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return OrderService(firestore);
});
