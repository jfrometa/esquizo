// Providers for dashboard stats - FIXED
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/firebase/firebase_providers.dart';
import 'package:starter_architecture_flutter_firebase/src/core/order/unified_order_service.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/order_status_enum.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/widgets/forms/create_order.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/authentication/domain/models.dart';
import 'package:starter_architecture_flutter_firebase/src/core/business/business_config_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:flutter/foundation.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/admin/models/table_model.dart';

// Optimized admin statistics service
class AdminStatsService {
  final cloud_firestore.FirebaseFirestore _firestore;
  final String _businessId;

  AdminStatsService({
    cloud_firestore.FirebaseFirestore? firestore,
    required String businessId,
  }) : _firestore = firestore ?? cloud_firestore.FirebaseFirestore.instance,
       _businessId = businessId;

  // Get all stats in a single batch operation
  Future<Map<String, dynamic>> getAllStats() async {
    try {
      final result = <String, dynamic>{};

      // Get current date range for today's stats
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      // Run batch queries
      final futures = await Future.wait([
        // Get orders with status counts
        _getOrderStats(todayStart, todayEnd),

        // Get table stats
        _getTableStats(),

        // Get product stats
        _getProductStats(),
      ]);

      result['orderStats'] = futures[0];
      result['tableStats'] = futures[1];
      result['productStats'] = futures[2];

      return result;
    } catch (e) {
      debugPrint('Error getting admin stats: $e');
      rethrow;
    }
  }

  // Get order statistics with batch operations
  Future<OrderStats> _getOrderStats(
      DateTime todayStart, DateTime todayEnd) async {
    try {
      // Use aggregate queries for better performance
      final batch = _firestore.batch();

      // Query for orders for all stats - filtered by business ID
      final ordersQuery = await _firestore
          .collection('businesses')
          .doc(_businessId)
          .collection('orders')
          .where('createdAt',
              isGreaterThanOrEqualTo:
                  cloud_firestore.Timestamp.fromDate(todayStart))
          .where('createdAt',
              isLessThanOrEqualTo: cloud_firestore.Timestamp.fromDate(todayEnd))
          .get();

      final orders =
          ordersQuery.docs.map((doc) => Order.fromFirestore(doc)).toList();

      // Calculate stats from the single data set
      final pendingOrders =
          orders.where((o) => o.status == OrderStatus.pending).length;
      final preparingOrders =
          orders.where((o) => o.status == OrderStatus.preparing).length;
      final readyOrders =
          orders.where((o) => o.status == OrderStatus.readyForDelivery).length;
      final completedOrders =
          orders.where((o) => o.status == OrderStatus.completed).length;

      // Calculate daily sales from completed orders
      final completedOrdersList =
          orders.where((o) => o.status == OrderStatus.completed).toList();
      final dailySales = completedOrdersList.fold(
          0.0, (sum, order) => sum + order.totalAmount);

      // Calculate average service time
      int totalMinutes = 0;
      int orderCount = 0;

      for (var order in completedOrdersList) {
        if (order.lastUpdated != null) {
          final duration = order.lastUpdated!.difference(order.createdAt);
          totalMinutes += duration.inMinutes;
          orderCount++;
        }
      }

      final averageServiceTime =
          orderCount > 0 ? (totalMinutes / orderCount).round() : 0;

      return OrderStats(
        totalOrders: orders.length,
        pendingOrders: pendingOrders,
        preparingOrders: preparingOrders,
        readyOrders: readyOrders,
        completedOrders: completedOrders,
        dailySales: dailySales,
        averageServiceTime: averageServiceTime,
      );
    } catch (e) {
      debugPrint('Error getting order stats: $e');
      return OrderStats(
        totalOrders: 0,
        pendingOrders: 0,
        preparingOrders: 0,
        readyOrders: 0,
        completedOrders: 0,
        dailySales: 0,
        averageServiceTime: 0,
      );
    }
  }

  // Get table statistics - filtered by business ID
  Future<TableStats> _getTableStats() async {
    try {
      // Get all tables in a single query - business-scoped
      final tablesQuery = await _firestore
          .collection('businesses')
          .doc(_businessId)
          .collection('resources')
          .where('type', isEqualTo: 'table')
          .get();

      final tables = tablesQuery.docs
          .map((doc) => RestaurantTable.fromFirestore(doc))
          .toList();

      // Count status occurrences
      final occupiedTables =
          tables.where((t) => t.status == TableStatusEnum.occupied).length;
      final reservedTables =
          tables.where((t) => t.status == TableStatusEnum.reserved).length;
      final cleaningTables =
          tables.where((t) => t.status == TableStatusEnum.maintenance).length;

      return TableStats(
        totalTables: tables.length,
        occupiedTables: occupiedTables,
        reservedTables: reservedTables,
        cleaningTables: cleaningTables,
      );
    } catch (e) {
      debugPrint('Error getting table stats: $e');
      return const TableStats(
        totalTables: 0,
        occupiedTables: 0,
        reservedTables: 0,
        cleaningTables: 0,
      );
    }
  }

  // Get product statistics - filtered by business ID
  Future<ProductStats> _getProductStats() async {
    try {
      // Run batch queries for categories and products - business-scoped
      final futures = await Future.wait([
        _firestore
            .collection('businesses')
            .doc(_businessId)
            .collection('menu_categories')
            .get(),
        _firestore
            .collection('businesses')
            .doc(_businessId)
            .collection('menu_items')
            .get(),
      ]);

      final categoriesQuery = futures[0];
      final productsQuery = futures[1];

      // Calculate stats
      final totalCategories = categoriesQuery.docs.length;
      final totalProducts = productsQuery.docs.length;

      // Count out of stock items
      int outOfStock = 0;
      for (var doc in productsQuery.docs) {
        final data = doc.data();
        if (data['isAvailable'] == false) {
          outOfStock++;
        }
      }

      return ProductStats(
        totalProducts: totalProducts,
        categories: totalCategories,
        outOfStock: outOfStock,
      );
    } catch (e) {
      debugPrint('Error getting product stats: $e');
      return const ProductStats(
        totalProducts: 0,
        categories: 0,
        outOfStock: 0,
      );
    }
  }

  // Get recent orders with limit - filtered by business ID
  Stream<List<Order>> getRecentOrdersStream({int limit = 5}) {
    return _firestore
        .collection('businesses')
        .doc(_businessId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
      } catch (e) {
        debugPrint('Error processing recent orders: $e');
        return <Order>[];
      }
    });
  }
}

// Providers
final adminStatsServiceProvider = Provider<AdminStatsService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final businessId = ref.watch(currentBusinessIdProvider);
  return AdminStatsService(firestore: firestore, businessId: businessId);
});

// Combined admin stats provider with cache invalidation
final combinedAdminStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final adminStatsService = ref.watch(adminStatsServiceProvider);

  // Set up cache invalidation based on time (refresh every 5 minutes)
  ref.onDispose(() {
    Future.delayed(const Duration(minutes: 5), () {
      ref.invalidateSelf();
    });
  });

  return adminStatsService.getAllStats();
});

// Individual stats providers that depend on the combined stats
final orderStatsProvider = FutureProvider<OrderStats>((ref) async {
  final allStats = await ref.watch(combinedAdminStatsProvider.future);
  return allStats['orderStats'] as OrderStats;
});

final tableStatsProvider = FutureProvider<TableStats>((ref) async {
  final allStats = await ref.watch(combinedAdminStatsProvider.future);
  return allStats['tableStats'] as TableStats;
});

final productStatsProvider = FutureProvider<ProductStats>((ref) async {
  final allStats = await ref.watch(combinedAdminStatsProvider.future);
  return allStats['productStats'] as ProductStats;
});

// Recent orders provider - this uses a stream for real-time updates
final recentOrdersProvider = StreamProvider<List<Order>>((ref) {
  final adminStatsService = ref.watch(adminStatsServiceProvider);
  return adminStatsService.getRecentOrdersStream();
});

// Sales stats derived from order stats
final salesStatsProvider = FutureProvider<SalesStats>((ref) async {
  final orderStats = await ref.watch(orderStatsProvider.future);

  return SalesStats(
    totalSales: orderStats
        .dailySales, // This would need to be expanded for historical data
    todaySales: orderStats.dailySales,
    orderCount: orderStats.totalOrders,
  );
});
