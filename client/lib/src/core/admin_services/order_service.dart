// import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/admin_services/firebase_providers.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/providers/order/order_admin_providers.dart';
// import 'package:starter_architecture_flutter_firebase/src/core/services/restaurant/table_service.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
// import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

// /// Optimized order service that handles all order-related operations.
// /// Uses caching, transactions, and efficient queries.
// class OrderService {
//   final cloud_firestore.FirebaseFirestore _firestore;
//   final cloud_firestore.CollectionReference _ordersCollection;

//   // Private constructor for dependency injection
//   OrderService({cloud_firestore.FirebaseFirestore? firestore})
//       : _firestore = firestore ?? cloud_firestore.FirebaseFirestore.instance,
//         _ordersCollection =
//             (firestore ?? cloud_firestore.FirebaseFirestore.instance)
//                 .collection('orders');

//   // Stream active orders (real-time updates) with error handling and caching
//   Stream<List<Order>> getActiveOrdersStream() {
//     return _ordersCollection
//         .where('status', whereNotIn: ['completed', 'cancelled'])
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           try {
//             return snapshot.docs
//                 .map((doc) {
//                   try {
//                     return Order.fromFirestore(doc);
//                   } catch (e) {
//                     debugPrint('Error parsing order document: $e');
//                     return null;
//                   }
//                 })
//                 .where((order) => order != null)
//                 .cast<Order>()
//                 .toList();
//           } catch (e) {
//             debugPrint('Error processing orders snapshot: $e');
//             return <Order>[];
//           }
//         });
//   }

//   // Stream orders by status with pagination
//   Stream<List<Order>> getOrdersByStatusStream(OrderStatus status,
//       {int limit = 20}) {
//     final statusStr = status.toString().split('.').last;
//     return _ordersCollection
//         .where('status', isEqualTo: statusStr)
//         .orderBy('createdAt', descending: true)
//         .limit(limit)
//         .snapshots()
//         .map((snapshot) {
//       try {
//         return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
//       } catch (e) {
//         debugPrint('Error processing orders by status: $e');
//         return <Order>[];
//       }
//     });
//   }

//   // Get recent orders stream with limit and caching
//   Stream<List<Order>> getRecentOrdersStream({int limit = 10}) {
//     return _ordersCollection
//         .orderBy('createdAt', descending: true)
//         .limit(limit)
//         .snapshots()
//         .map((snapshot) {
//       try {
//         return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
//       } catch (e) {
//         debugPrint('Error processing recent orders: $e');
//         return <Order>[];
//       }
//     });
//   }

//   // Stream orders for a specific table
//   Stream<List<Order>> getOrdersByTableStream(String tableId) {
//     return _ordersCollection
//         .where('tableId', isEqualTo: tableId)
//         .where('status', whereNotIn: ['completed', 'cancelled'])
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snapshot) {
//           try {
//             return snapshot.docs
//                 .map((doc) => Order.fromFirestore(doc))
//                 .toList();
//           } catch (e) {
//             debugPrint('Error processing table orders: $e');
//             return <Order>[];
//           }
//         });
//   }

//   // Get order by ID with caching
//   Future<Order?> getOrderById(String orderId) async {
//     try {
//       final doc = await _ordersCollection.doc(orderId).get(
//           const cloud_firestore.GetOptions(
//               source: cloud_firestore.Source.serverAndCache));

//       if (doc.exists) {
//         return Order.fromFirestore(doc);
//       }
//       return null;
//     } catch (e) {
//       debugPrint('Error fetching order: $e');
//       return null;
//     }
//   }

//   // Create a new order with transaction and table integration
//   Future<String> createOrder(Order order, TableService tableService) async {
//     try {
//       // Use transaction to ensure data consistency
//       return await _firestore.runTransaction<String>((transaction) async {
//         // Generate new ID if using temp ID
//         final orderId = order.id.startsWith('temp_')
//             ? _ordersCollection.doc().id
//             : order.id;

//         // If table is specified, check and update table status
//         if (order.tableId?.isNotEmpty ?? false) {
//           final tableDoc = await transaction
//               .get(_firestore.collection('tables').doc(order.tableId));

//           if (!tableDoc.exists) {
//             throw Exception('La mesa especificada no existe');
//           }

//           final table = RestaurantTable.fromFirestore(tableDoc);

//           // Check if table is available
//           if (table.status == TableStatusEnum.occupied &&
//               table.currentOrderId != null &&
//               table.currentOrderId != order.id) {
//             throw Exception('La mesa ya está ocupada con otro pedido');
//           }

//           // Update table status to occupied and set current order ID
//           transaction.update(
//             _firestore.collection('tables').doc(order.tableId),
//             {
//               'status': TableStatusEnum.occupied.toString().split('.').last,
//               'currentOrderId': orderId,
//               'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
//             },
//           );
//         }

//         // Create the order with new ID if needed
//         final newOrder =
//             order.id.startsWith('temp_') ? order.copyWith(id: orderId) : order;

//         transaction.set(
//           _ordersCollection.doc(orderId),
//           newOrder.toFirestore(),
//         );

//         return orderId;
//       });
//     } catch (e) {
//       debugPrint('Error creating order: $e');
//       rethrow;
//     }
//   }

//   // Update order status with transaction and table integration
//   Future<void> updateOrderStatus(
//       String orderId, OrderStatus newStatus, TableService tableService) async {
//     try {
//       // Use transaction to ensure data consistency
//       await _firestore.runTransaction((transaction) async {
//         final orderDoc = await transaction.get(_ordersCollection.doc(orderId));

//         if (!orderDoc.exists) {
//           throw Exception('El pedido no existe');
//         }

//         final order = Order.fromFirestore(orderDoc);

//         // Update order status
//         transaction.update(
//           _ordersCollection.doc(orderId),
//           {
//             'status': newStatus.toString().split('.').last,
//             'lastUpdated': cloud_firestore.FieldValue.serverTimestamp(),
//           },
//         );

//         // If order is completed or cancelled, update table status
//         if ((newStatus == OrderStatus.completed ||
//                 newStatus == OrderStatus.cancelled) &&
//             (order.tableId?.isNotEmpty ?? false)) {
//           final tableDoc = await transaction
//               .get(_firestore.collection('tables').doc(order.tableId));

//           if (tableDoc.exists) {
//             final table = RestaurantTable.fromFirestore(tableDoc);

//             // Only update if this is the current order for the table
//             if (table.currentOrderId == orderId) {
//               transaction.update(
//                 _firestore.collection('tables').doc(order.tableId),
//                 {
//                   'status': newStatus == OrderStatus.completed
//                       ? TableStatusEnum.maintenance.toString().split('.').last
//                       : TableStatusEnum.available.toString().split('.').last,
//                   'currentOrderId': null,
//                   'updatedAt': cloud_firestore.FieldValue.serverTimestamp(),
//                 },
//               );
//             }
//           }
//         }
//       });
//     } catch (e) {
//       debugPrint('Error updating order status: $e');
//       rethrow;
//     }
//   }

//   // Get order statistics with optimized queries
//   Future<OrderStats> getOrderStats({bool useCache = true}) async {
//     try {
//       // final cacheOption = useCache
//       //     ? const cloud_firestore.GetOptions(
//       //         source: cloud_firestore.Source.serverAndCache)
//       //     : const cloud_firestore.GetOptions(
//       //         source: cloud_firestore.Source.server);

//       // Use aggregate queries for better performance
//       final pendingCount = await _ordersCollection
//           .where('status',
//               isEqualTo: OrderStatus.pending.toString().split('.').last)
//           .count()
//           .get();

//       final preparingCount = await _ordersCollection
//           .where('status',
//               isEqualTo: OrderStatus.preparing.toString().split('.').last)
//           .count()
//           .get();

//       final readyCount = await _ordersCollection
//           .where('status',
//               isEqualTo:
//                   OrderStatus.readyForDelivery.toString().split('.').last)
//           .count()
//           .get();

//       // Get today's sales
//       final now = DateTime.now();
//       final startOfDay = DateTime(now.year, now.month, now.day);
//       final endOfDay = startOfDay
//           .add(const Duration(days: 1))
//           .subtract(const Duration(milliseconds: 1));

//       final todayOrdersQuery = await _ordersCollection
//           .where('createdAt',
//               isGreaterThanOrEqualTo:
//                   cloud_firestore.Timestamp.fromDate(startOfDay))
//           .where('createdAt',
//               isLessThanOrEqualTo: cloud_firestore.Timestamp.fromDate(endOfDay))
//           .where('status',
//               isEqualTo: OrderStatus.completed.toString().split('.').last)
//           .get();

//       final todayOrders =
//           todayOrdersQuery.docs.map((doc) => Order.fromFirestore(doc)).toList();

//       final dailySales = todayOrders.fold<double>(
//           0, (sum, order) => sum + (order.totalAmount ?? 0));

//       // Calculate average service time
//       int totalMinutes = 0;
//       int orderCount = 0;

//       for (var order in todayOrders) {
//         if (order.lastUpdated != null) {
//           final duration = order.lastUpdated!.difference(order.createdAt);
//           totalMinutes += duration.inMinutes;
//           orderCount++;
//         }
//       }

//       final averageServiceTime =
//           orderCount > 0 ? (totalMinutes / orderCount).round() : 0;

//       return OrderStats(
//         pendingOrders: pendingCount.count ?? 0,
//         preparingOrders: preparingCount.count ?? 0,
//         readyOrders: readyCount.count ?? 0,
//         dailySales: dailySales,
//         averageServiceTime: averageServiceTime,
//         totalOrders: todayOrders.length,
//         completedOrders: orderCount,
//       );
//     } catch (e) {
//       debugPrint('Error calculating order stats: $e');
//       return OrderStats(
//         pendingOrders: 0,
//         preparingOrders: 0,
//         readyOrders: 0,
//         dailySales: 0,
//         averageServiceTime: 0,
//         totalOrders: 0,
//         completedOrders: 0,
//       );
//     }
//   }
// }

// // Providers with proper dependency injection and caching
// // final orderServiceProvider = Provider<OrderService>((ref) {
// //   final firestore = ref.watch(firebaseFirestoreProvider);
// //   return OrderService(firestore: firestore);
// // });

// // Active orders provider
// final activeOrdersProvider = StreamProvider<List<Order>>((ref) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getActiveOrdersStream();
// });

// // Recent orders provider
// final recentOrdersProvider = StreamProvider<List<Order>>((ref) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getRecentOrdersStream();
// });

// // Orders by status provider
// final ordersByStatusProvider =
//     StreamProvider.family<List<Order>, OrderStatus>((ref, status) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getOrdersByStatusStream(status);
// });

// // Orders by table provider
// final tableOrdersProvider =
//     StreamProvider.family<List<Order>, String>((ref, tableId) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getOrdersByTableStream(tableId);
// });

// // Order stats provider with cache invalidation
// final orderStatsProvider = FutureProvider<OrderStats>((ref) {
//   final orderService = ref.watch(orderServiceProvider);

//   // Refresh every 5 minutes
//   ref.onDispose(() async {
//     final timer = Future.delayed(const Duration(minutes: 5), () {
//       ref.invalidateSelf();
//     });
//     return await timer;
//   });

//   return orderService.getOrderStats();
// });

// // Specific order provider
// final orderByIdProvider = FutureProvider.family<Order?, String>((ref, orderId) {
//   final orderService = ref.watch(orderServiceProvider);
//   return orderService.getOrderById(orderId);
// });

// // Order Stats model
// class OrderStats {
//   final int pendingOrders;
//   final int preparingOrders;
//   final int readyOrders;
//   final double dailySales;
//   final int averageServiceTime;
//   final int totalOrders;
//   final int completedOrders;

//   OrderStats({
//     required this.pendingOrders,
//     required this.preparingOrders,
//     required this.readyOrders,
//     required this.dailySales,
//     required this.averageServiceTime,
//     required this.totalOrders,
//     required this.completedOrders,
//   });
// }
